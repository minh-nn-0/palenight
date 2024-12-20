local util = require "utilities"
local obstacle_spawner = {}

local obstacles_to_spawn = {}
local spawn_interval = 1
local time_passed_since_last_wave = 0
local progress_interval = 10
local progress = 1
local obstacles_spawner_eid = pn.add_entity()
pn.add_tag(obstacles_spawner_eid, "spawner")
pn.set_timer(obstacles_spawner_eid, spawn_interval)
pn.set_state(obstacles_spawner_eid, "waiting")
function obstacle_spawner.init()
	obstacles_to_spawn = {}
end

local function setup_obstacle_state(eid)
	pn.set_state_entry(eid, "normal",
		function()
			pn.add_tag(eid, "no_gravity")
			pn.add_tag(eid, "attackable")
			pn.add_tag(eid, "hurtable")
			pn.add_tag(eid, "obstacle")
		end)
	pn.set_state_entry(eid, "die",
		function()
			pn.set_rotation(eid, math.random(-90, 90))
			pn.remove_tag(eid, "no_gravity")
			pn.remove_tag(eid, "attackable")
			pn.remove_tag(eid, "hurtable")
		end)
	pn.set_state(eid, "normal")
end

local function spawn_bat()
		local bat = pn.add_entity()
		pn.add_tag(bat, "bat")
		pn.set_image(bat, "tileset")
		pn.set_tileanimation(bat, {
			frames = {{37,200},{38,200},{39,200}},
			framewidth = 8,
			frameheight = 8,
			["repeat"] = true
		})
		pn.set_scale(bat, config.scale_of["bat"][1], config.scale_of["bat"][2])
		pn.set_position(bat,
			config.logical_size[1],
			config.logical_size[2] / 3 + (math.random(0, 3) * config.grid_size))
		pn.set_velocity(bat,
			math.random(-(config.base_velocity + progress * 20), - (config.base_velocity + progress * 20 - 20)),
			0)

		pn.set_cbox(bat, config.cbox_of["bat"])
		setup_obstacle_state(bat)
		pn.set_stopwatch(bat)
end

local function spawn_duck()
	local duck = pn.add_entity()
	pn.add_tag(duck, "duck")
	pn.set_image(duck, "tileset")
	pn.set_tileanimation(duck, {
		frames = {{28,200},{29,200}},
		framewidth = 8,
		frameheight = 8,
		["repeat"] = true
	})

	pn.set_scale(duck, config.scale_of["duck"][1], config.scale_of["duck"][2])
	pn.set_position(duck,
		config.logical_size[1],
		config:ground_level() - 150 + (math.random(0, 1) * config.grid_size))
	pn.set_velocity(duck,
		math.random(-(config.base_velocity + progress * 20), - (config.base_velocity + progress * 20 - 20)),
		0)

	pn.set_cbox(duck, config.cbox_of["duck"])
	setup_obstacle_state(duck)
	pn.set_timer(duck, 1.6)
end

local function spawn_box()
	local box = pn.add_entity()
	pn.add_tag(box, "box")
	pn.set_image(box, "tileset")
	pn.set_tileanimation(box, {
		frames = {{9,200}},
		framewidth = 8,
		frameheight = 8,
		["repeat"] = false
	})

	pn.set_scale(box, config.scale_of["box"][1], config.scale_of["box"][2])
	pn.set_position(box,
		config.logical_size[1],
		config:ground_level() - config.grid_size)
	pn.set_velocity(box,
		-(config.base_velocity + progress * 10),
		0)

	pn.set_cbox(box, config.cbox_of["box"])
	setup_obstacle_state(box)
	pn.remove_tag(box, "attackable")
end

local function spawn_obstacle()
	local otype = table.remove(obstacles_to_spawn, 1)

	if otype == "bat" then spawn_bat()
	elseif otype == "duck" then spawn_duck()
	else spawn_box()
	end
end

function obstacle_spawner.update(time, dt)
	local state = pn.get_state(obstacles_spawner_eid)

	progress = math.ceil(time / progress_interval)

	if state == "waiting" then
		time_passed_since_last_wave = time_passed_since_last_wave + dt
	end

	if time_passed_since_last_wave >= 5 then
		state = "spawning"
		for _ = 1, progress do
			local rand = math.random()
			local otype = "duck"
			--local otype = "box"
			--if rand < 0.5 then otype = "duck"
			--elseif rand < 0.8 then otype = "bat"
			--end
			table.insert(obstacles_to_spawn, otype)
		end
		time_passed_since_last_wave = 0
	end

	if state == "spawning" then
		if #obstacles_to_spawn > 0 then
			local timer = pn.get_timer(obstacles_spawner_eid)
			if timer.running == false then
				spawn_obstacle()
				pn.set_timer(obstacles_spawner_eid, spawn_interval)
			end
		else
			state = "waiting"
		end
	end

	pn.set_state(obstacles_spawner_eid, state)


end

return obstacle_spawner
