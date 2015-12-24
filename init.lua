local ACDC = 0.2 -- Acceleration / decelleration
local MAXSP = 12 -- Maximum speed
local TURNSP = 0.03 -- Maximum yaw speed
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
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x=x, y=y, z=z}
end


local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end


-- Car55

local car1 = {
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.53, -0.75, -0.53, 0.53, 0.75, 0.53},
	visual = "cube",
	visual_size = {x = 1.5, y = 1.5},
	textures = { -- top base rightside leftside front back
		"mesecar_car1top.png",
		"mesecar_carbase.png",
		"mesecar_car1rightside.png",
		"mesecar_car1leftside.png",
		"mesecar_car1front.png",
		"mesecar_car1back.png",
	},
	stepheight = STEPH,
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
}


function car1:on_rightclick(clicker)
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


function car1.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end


function car1.get_staticdata(self)
	return tostring(self.v)
end


function car1.on_punch(self, puncher, time_from_last_punch, tool_capabilities, direction)
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
		puncher:get_inventory():add_item("main", "mesecar:mesecar1")
	end
end


function car1:on_step(dtime)
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
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end
	if absv > MAXSP then
		self.v = MAXSP * get_sign(self.v)
	end
	self.object:setacceleration({x = 0, y = -9.81, z = 0})
	self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	self.object:setpos(self.object:getpos())
end


-- Oerkka

local car2 = {
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.53, -0.75, -0.53, 0.53, 0.75, 0.53},
	visual = "cube",
	visual_size = {x = 1.5, y = 1.5},
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
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end
	if absv > MAXSP then
		self.v = MAXSP * get_sign(self.v)
	end
	self.object:setacceleration({x = 0, y = -9.81, z = 0})
	self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	self.object:setpos(self.object:getpos())
end


-- Nyancart

local car3 = {
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.53, -0.75, -0.53, 0.53, 0.75, 0.53},
	visual = "cube",
	visual_size = {x = 1.5, y = 1.5},
	textures = { -- top base rightside leftside front back
		"mesecar_car3top.png",
		"mesecar_carbase.png",
		"mesecar_car3rightside.png",
		"mesecar_car3leftside.png",
		"mesecar_car3front.png",
		"mesecar_car3back.png",
	},
	stepheight = STEPH,
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
}


function car3:on_rightclick(clicker)
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


function car3.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end


function car3.get_staticdata(self)
	return tostring(self.v)
end


function car3.on_punch(self, puncher, time_from_last_punch, tool_capabilities, direction)
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
		puncher:get_inventory():add_item("main", "mesecar:mesecar3")
	end
end


function car3:on_step(dtime)
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
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end
	if absv > MAXSP then
		self.v = MAXSP * get_sign(self.v)
	end
	self.object:setacceleration({x = 0, y = -9.81, z = 0})
	self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	self.object:setpos(self.object:getpos())
end


-- Mesecar

local car4 = {
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.53, -0.75, -0.53, 0.53, 0.75, 0.53},
	visual = "cube",
	visual_size = {x = 1.5, y = 1.5},
	textures = { -- top base rightside leftside front back
		"mesecar_car4top.png",
		"mesecar_carbase.png",
		"mesecar_car4rightside.png",
		"mesecar_car4leftside.png",
		"mesecar_car4front.png",
		"mesecar_car4back.png",
	},
	stepheight = STEPH,
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
}


function car4:on_rightclick(clicker)
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


function car4.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end


function car4.get_staticdata(self)
	return tostring(self.v)
end


function car4.on_punch(self, puncher, time_from_last_punch, tool_capabilities, direction)
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
		puncher:get_inventory():add_item("main", "mesecar:mesecar4")
	end
end


function car4:on_step(dtime)
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
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end
	if absv > MAXSP then
		self.v = MAXSP * get_sign(self.v)
	end
	self.object:setacceleration({x = 0, y = -9.81, z = 0})
	self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	self.object:setpos(self.object:getpos())
end


-- Register entities

minetest.register_entity("mesecar:mesecar1", car1)
minetest.register_entity("mesecar:mesecar2", car2)
minetest.register_entity("mesecar:mesecar3", car3)
minetest.register_entity("mesecar:mesecar4", car4)


-- Items

minetest.register_craftitem("mesecar:mesecar1", { -- Car55
	description = "Mese Car 1",
	inventory_image = "mesecar_car1front.png",
	wield_image = "mesecar_car1front.png",
	wield_scale = {x = 2, y = 2, z = 2},
	liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y + 1.25
		minetest.add_entity(pointed_thing.under, "mesecar:mesecar1")
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
})


minetest.register_craftitem("mesecar:mesecar2", { -- Oerkka
	description = "Mese Car 2",
	inventory_image = "mesecar_car2front.png",
	wield_image = "mesecar_car2front.png",
	wield_scale = {x = 2, y = 2, z = 2},
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


minetest.register_craftitem("mesecar:mesecar3", { -- Nyancart
	description = "Mese Car 3",
	inventory_image = "mesecar_car3front.png",
	wield_image = "mesecar_car3front.png",
	wield_scale = {x = 2, y = 2, z = 2},
	liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y + 1.25
		minetest.add_entity(pointed_thing.under, "mesecar:mesecar3")
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
})


minetest.register_craftitem("mesecar:mesecar4", { -- Mesecar
	description = "Mese Car 4",
	inventory_image = "mesecar_car4front.png",
	wield_image = "mesecar_car4front.png",
	wield_scale = {x = 2, y = 2, z = 2},
	liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y + 1.25
		minetest.add_entity(pointed_thing.under, "mesecar:mesecar4")
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
})


minetest.register_craftitem("mesecar:motor", {
	description = "Mesecar Motor",
	inventory_image = "mesecar_motor.png",
	groups = {not_in_creative_inventory=1},
})


minetest.register_craftitem("mesecar:battery", {
	description = "Mesecar Battery",
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
		{"default:steel_ingot", "default:mese_block", "default:steel_ingot"},
		{"default:copper_ingot", "default:copper_ingot", "default:steel_ingot"},
	},
})


minetest.register_craft({
	output = "mesecar:mesecar1", -- Car55
	recipe = {
		{"default:steel_ingot", "dye:blue", "default:steel_ingot"},
		{"default:steel_ingot", "group:wool", "default:glass"},
		{"mesecar:motor", "mesecar:battery", "mesecar:motor"},
	},
})


minetest.register_craft({
	output = "mesecar:mesecar2", -- Oerkka
	recipe = {
		{"default:steel_ingot", "dye:magenta", "default:steel_ingot"},
		{"default:steel_ingot", "group:wool", "default:glass"},
		{"mesecar:motor", "mesecar:battery", "mesecar:motor"},
	},
})


minetest.register_craft({
	output = "mesecar:mesecar3", -- Nyancart
	recipe = {
		{"default:steel_ingot", "dye:pink", "default:steel_ingot"},
		{"default:steel_ingot", "group:wool", "default:glass"},
		{"mesecar:motor", "mesecar:battery", "mesecar:motor"},
	},
})


minetest.register_craft({
	output = "mesecar:mesecar4", -- Mesecar
	recipe = {
		{"default:steel_ingot", "dye:yellow", "default:steel_ingot"},
		{"default:steel_ingot", "group:wool", "default:glass"},
		{"mesecar:motor", "mesecar:battery", "mesecar:motor"},
	},
})
