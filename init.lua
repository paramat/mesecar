-- mesecar 0.1.0 by paramat, a fork of Dan Duncombe's car mod
-- For latest stable Minetest and back to 0.4.7
-- Depends default
-- Licenses: code WTFPL, textures CC-BY-SA

local TURNS = 0.04 -- 0.04 -- Maximum turn speed.

-- Functions

local function is_ground(pos)
	return minetest.registered_nodes[minetest.get_node(pos).name].walkable
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw) * v
	local z = math.sin(yaw) * v
	return {x=x,y=y,z=z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

-- Cart entity

local boat = {
	physical = true,
	collisionbox = {-0.6,0.75,-0.6, 0.6,0.75,0.6},
	visual = "mesh",
	visual_size = {x=1,y=1.6},
	mesh = "mesecar.x",
	textures = {"mesecar_mesecar.png"},
	
	driver = nil,
	v = 0,
}

function boat:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function boat:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function boat:get_staticdata()
	return tostring(v)
end

function boat:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "mesecar:mesecar")
	end
end

-- On globalstep

function boat:on_step(dtime)
	self.v = get_v(self.object:getvelocity()) * get_sign(self.v)
	local absv = math.abs(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v + 0.3
		elseif ctrl.down then
			self.v = self.v - 0.3
		end
		local turn
		local maxturn = (1 + dtime) * TURNS
		if absv < 4 then
			turn = maxturn * absv / 4
		else
			turn = maxturn
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw() + turn)
		elseif ctrl.right then
			self.object:setyaw(self.object:getyaw() - turn)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02 * s -- decceleration
	if s ~= get_sign(self.v) then -- if decceleration reverses direction
		self.object:setvelocity({x=0,y=0,z=0}) -- stop
		self.v = 0
		return
	end
	if absv > 8 then
		self.v = 8 * get_sign(self.v) -- limit speed to ~20mph
	end
	local p = self.object:getpos()
	p.y = p.y - 0.5
	if not is_ground(p) then
		self.object:setacceleration({x=0,y=-9.81,z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y + 1
		if is_ground(p) then
			self.object:setacceleration({x=0,y=0,z=0})
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			local pos = self.object:getpos()
			pos.y = math.floor(pos.y) + 1.5
			self.object:setpos(pos)
		else
			self.object:setacceleration({x=0,y=0,z=0})
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			local pos = self.object:getpos()
			pos.y = math.floor(pos.y) + 0.5
			self.object:setpos(pos)
		end
	end
end

minetest.register_entity("mesecar:mesecar", boat)

minetest.register_craftitem("mesecar:mesecar", {
	description = "Mese Car",
	inventory_image = "mesecar_mesecar.png",
	wield_scale = {x=2,y=2,z=1},
	liquids_pointable = true,
	groups = {not_in_creative_inventory=1},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y + 2
		minetest.add_entity(pointed_thing.under, "mesecar:mesecar")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craftitem("mesecar:motor", {
	description = "Mese Motor",
	inventory_image = "mesecar_motor.png",
	groups = {not_in_creative_inventory=1},
})

minetest.register_craftitem("mesecar:battery", {
	description = "Mese Battery",
	inventory_image = "mesecar_battery.png",
	groups = {not_in_creative_inventory=1},
})

minetest.register_craft({
	output = "mesecar:motor",
	recipe = {
		{"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"},
		{"default:copper_ingot", "default:steel_ingot", "default:copper_ingot"},
		{"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "mesecar:battery",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese_block", "default:copper_ingot"},
		{"default:copper_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "mesecar:mesecar",
	recipe = {
		{"wool:black", "wool:orange", "default:glass"},
		{"mesecar:battery", "default:copper_ingot", "mesecar:motor"},
		{"default:steelblock", "default:steelblock", "default:steelblock"},
	},
})