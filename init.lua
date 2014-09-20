-- mesecar 0.3.3 by paramat
-- For latest stable Minetest and back to 0.4.10
-- Depends default
-- Licenses: code WTFPL, textures CC-BY-SA

-- narrow collision box for diagonal movement
-- 2 cars with different textures: skycar, oerkka

local ACDC = 0.2 -- Acceleration / decelleration
local MAXSP = 12 -- Maximum speed
local TURNSP = 0.03 -- Maximum turn speed
local STEPH = 0.6 -- Stepheight, 0.6 = climb slabs, 1.1 = climb nodes
local XSCAL = 1.5
local YSCAL = 1.5

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
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

-- Car entity

local car = {
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.53, -0.75, -0.53, 0.53, 0.75, 0.53},
	visual = "cube",
	visual_size = {x=XSCAL, y=YSCAL},
	textures = { -- top base rightside leftside front back
		"mesecar_cartop.png",
		"mesecar_carbase.png",
		"mesecar_carrightside.png",
		"mesecar_carleftside.png",
		"mesecar_carfront.png",
		"mesecar_carback.png",
	},
	stepheight = STEPH,
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
}

function car:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
		default.player_attached[name] = false
		default.player_set_animation(clicker, "stand" , 30)
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x = 0, y = 3, z = -2}, {x = 0, y = 0, z = 0})
		default.player_attached[name] = true
		minetest.after(0.2, function()
			default.player_set_animation(clicker, "sit" , 30)
		end)
		self.object:setyaw(clicker:get_look_yaw() - math.pi / 2)
	end
end

function car.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end

function car.get_staticdata(self)
	return tostring(self.v)
end

function car.on_punch(self, puncher, time_from_last_punch, tool_capabilities, direction)
	if self.driver then
		self.driver:set_detach()
		local name = self.driver:get_player_name()
		default.player_attached[name] = false
		default.player_set_animation(self.driver, "stand" , 30)
		self.driver = nil
	end
	-- delay remove to ensure player is detached
	minetest.after(0.1, function()
		self.object:remove()
	end)
	if puncher and puncher:is_player() and not minetest.setting_getbool("creative_mode") then
		puncher:get_inventory():add_item("main", "mesecar:mesecar")
	end
end

function car:on_step(dtime)
	self.v = get_v(self.object:getvelocity()) * get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v + ACDC
		elseif ctrl.down then
			self.v = self.v - ACDC
		end
	end
	if self.v == 0 and self.object:getvelocity().y == 0 then
		return
	end
	local absv = math.abs(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		local turn
		local maxturn = (1 + dtime * 2) * TURNSP
		if absv < 4 then
			turn = maxturn * absv / 4
		else
			turn = maxturn * (1 - (absv - 4) / 16)
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw() + turn)
		elseif ctrl.right then
			self.object:setyaw(self.object:getyaw() - turn)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.03 * s
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

-- Car entity 2

local car2 = {
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.53, -0.75, -0.53, 0.53, 0.75, 0.53},
	visual = "cube",
	visual_size = {x=XSCAL, y=YSCAL},
	textures = { -- top base rightside leftside front back
		"mesecar_car2top.png",
		"mesecar_carbase.png",
		"mesecar_car2rightside.png",
		"mesecar_car2leftside.png",
		"mesecar_car2front.png",
		"mesecar_car2back.png",
	},
	stepheight = STEPH,
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
}

function car2:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
		default.player_attached[name] = false
		default.player_set_animation(clicker, "stand" , 30)
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x = 0, y = 3, z = -2}, {x = 0, y = 0, z = 0})
		default.player_attached[name] = true
		minetest.after(0.2, function()
			default.player_set_animation(clicker, "sit" , 30)
		end)
		self.object:setyaw(clicker:get_look_yaw() - math.pi / 2)
	end
end

function car2.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end

function car2.get_staticdata(self)
	return tostring(self.v)
end

function car2.on_punch(self, puncher, time_from_last_punch, tool_capabilities, direction)
	if self.driver then
		self.driver:set_detach()
		local name = self.driver:get_player_name()
		default.player_attached[name] = false
		default.player_set_animation(self.driver, "stand" , 30)
		self.driver = nil
	end
	-- delay remove to ensure player is detached
	minetest.after(0.1, function()
		self.object:remove()
	end)
	if puncher and puncher:is_player() and not minetest.setting_getbool("creative_mode") then
		puncher:get_inventory():add_item("main", "mesecar:mesecar2")
	end
end

function car2:on_step(dtime)
	self.v = get_v(self.object:getvelocity()) * get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v + ACDC
		elseif ctrl.down then
			self.v = self.v - ACDC
		end
	end
	if self.v == 0 and self.object:getvelocity().y == 0 then
		return
	end
	local absv = math.abs(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		local turn
		local maxturn = (1 + dtime * 2) * TURNSP
		if absv < 4 then
			turn = maxturn * absv / 4
		else
			turn = maxturn * (1 - (absv - 4) / 16)
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw() + turn)
		elseif ctrl.right then
			self.object:setyaw(self.object:getyaw() - turn)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.03 * s
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

-- Register entities

minetest.register_entity("mesecar:mesecar", car)
minetest.register_entity("mesecar:mesecar2", car2)

-- Items

minetest.register_craftitem("mesecar:mesecar", {
	description = "Mese Car",
	inventory_image = "mesecar_carfront.png",
	wield_image = "mesecar_carfront.png",
	wield_scale = {x=2, y=2, z=2},
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y + 1.25
		minetest.add_entity(pointed_thing.under, "mesecar:mesecar")
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
})

minetest.register_craftitem("mesecar:mesecar2", {
	description = "Mese Car 2",
	inventory_image = "mesecar_carfront.png",
	wield_image = "mesecar_carfront.png",
	wield_scale = {x=2, y=2, z=2},
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y + 1.25
		minetest.add_entity(pointed_thing.under, "mesecar:mesecar2")
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
})

