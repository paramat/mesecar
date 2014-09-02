-- mesecar 0.2.0 by paramat, a fork of Dan Duncombe's car mod
-- For latest stable Minetest and back to 0.4.9
-- Depends default wool dye
-- Licenses: code WTFPL, textures CC-BY-SA

-- new in 0.2.0:
-- added step height and max speed parameters
-- bugfix floating above slabs
-- resize car, collisionbox
-- new texture
-- update crafting

local MAXSP = 8 -- Maxspeed in nodes per second
local TURNSP = 0.04 -- Maximum turn speed
local STEPH = 0.6 -- Stepheight, 0.6 = climb slabs, 1.1 = climb nodes

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
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

-- Car entity

local car = {
	physical = true,
	collisionbox = {-0.55, 0, -0.55, 0.55, 1.45, 0.55},
	visual = "mesh",
	visual_size = {x=0.9, y=1.3},
	mesh = "mesecar.x",
	textures = {"mesecar_mesecar.png"},
	stepheight = STEPH,
	driver = nil,
	v = 0,
}

function car:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0, y=5, z=0}, {x=0, y=0, z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function car:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function car:get_staticdata()
	return tostring(v)
end

function car:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "mesecar:mesecar")
	end
end

-- On globalstep

function car:on_step(dtime)
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
		local maxturn = (1 + dtime) * TURNSP
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
	self.v = self.v - 0.02 * s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if absv > MAXSP then
		self.v = MAXSP * get_sign(self.v)
	end
	self.object:setacceleration({x=0, y=-9.81, z=0})
	self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	self.object:setpos(self.object:getpos())
end

minetest.register_entity("mesecar:mesecar", car)

-- Items

minetest.register_craftitem("mesecar:mesecar", {
	description = "Mese Car",
	inventory_image = "mesecar_mesecar.png",
	liquids_pointable = true,
	groups = {not_in_creative_inventory=1},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y + 1
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

-- Crafting

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
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "mesecar:mesecar",
	recipe = {
		{"dye:yellow", "wool:black", "default:glass"},
		{"mesecar:battery", "default:copper_ingot", "mesecar:motor"},
		{"default:steelblock", "default:steelblock", "default:steelblock"},
	},
})
