mesecar 0.4.0 by paramat
For Minetest 0.4.10 and later
Depends default
Licenses: code WTFPL, textures CC BY-SA

4 styles of microcar: car55, oerkka, nyancart and mesecar.
Will only turn when moving, turn speed reduces near top speed.
Dual-motor 4 wheel drive update (inspired by Tesla Model S).
By default will climb slabs but not full blocks, edit STEPH to 1.1 to climb blocks.
16 pixel textures scaled to a 1.5 node cube, the player is sitting inside and has to be hidden because scaling the car also scales the driver.
My pathv6alt mod https://forum.minetest.net/viewtopic.php?f=11&t=10064 generates roads in mgv6 to drive on.
Noisegrid lua mapgen also has roads https://forum.minetest.net/viewtopic.php?f=11&t=9296.

Crafting recipies

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
