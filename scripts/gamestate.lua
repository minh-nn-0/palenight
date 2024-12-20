local starfield = require "starfield"
local particle = require "particle"
local player = require "player"
local obstacle_spawner = require "obstacle_spawning"
local obstacle = require "obstacle"
local collision = require "collision"

local gamestate = {}

local state = "menu"
function gamestate.update(dt)
	return gamestate[state].update(dt)
end
function gamestate.draw()
	return gamestate[state].draw()
end
function gamestate.load()
	player.load()
	beaver.set_volume_music(40)
	beaver.play_music("bgm1")
end

local stars = starfield.new(30)

local logo_start_posy = -100
local logo_end_posy = 100
local start_start_posy = -200
local start_end_posy = logo_end_posy + 100
local quit_start_posy = -300
local quit_end_posy = logo_end_posy + 150
local logo_tween_time = 1
local text_tween_time = 1

local logo_posy = logo_start_posy
local start_posy = logo_posy
local quit_posy = logo_posy

local function ease_in_out(t)
    return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
end
local function ease_in_out_back(t)
	local c1 = 1.70158;
	local c2 = c1 * 1.525;

	return t < 0.5 and ((2 * t) ^ 2 * ((c2 + 1) * 2 * t - c2)) / 2
  		or ((2 * t - 2) ^ 2 * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2;
end



local arrow = pn.add_entity()
pn.set_position(arrow, -500, -500)
pn.set_scale(arrow, 3,3)
pn.set_image(arrow, "tileset")
pn.set_image_source(arrow, 24,40,8,8)

local timer = pn.add_entity()
pn.set_stopwatch(timer)

local option = 1
local function move_arrow()
	if beaver.get_input("UP") == 1 then option = option - 1 end
	if beaver.get_input("DOWN") == 1 then option = option + 1 end

	option = math.max(1, math.min(option, 2))
	pn.set_position(arrow, config.logical_size[1]/2 - 80, logo_end_posy + 60 + 55 * option)
end

local text_in = true
local text_out = false
gamestate["menu"] = {
	load = function()
		pn.set_stopwatch(timer)
	end,
	update = function(dt)
		starfield.update(stars, -80, dt)
		if (text_in == true) then
			local t = pn.get_stopwatch(timer)
			logo_posy = logo_start_posy + (logo_end_posy - logo_start_posy) * ease_in_out_back(math.min(t / logo_tween_time,1))
			start_posy = start_start_posy + (start_end_posy - start_start_posy) * ease_in_out_back(math.min(t / text_tween_time, 1))
			quit_posy = quit_start_posy + (quit_end_posy - quit_start_posy) * ease_in_out_back(math.min(t / text_tween_time, 1))
			if t >= text_tween_time then text_in = false end
		else
			move_arrow()
			if beaver.get_input("X") == 1 then
				if option == 2 then return false
				else
					pn.set_stopwatch(timer)
					text_out = true
				end
			end
		end

		if text_out == true then
			pn.set_position(arrow, -500, -500)
			local t = pn.get_stopwatch(timer)
			logo_posy = logo_end_posy + (logo_start_posy - logo_end_posy) * ease_in_out_back(math.min(t / logo_tween_time,1))
			start_posy = start_end_posy + (start_start_posy - start_end_posy) * ease_in_out_back(math.min(t / text_tween_time, 1))
			quit_posy = quit_end_posy + (quit_start_posy - quit_end_posy) * ease_in_out_back(math.min(t / text_tween_time, 1))
			if t >= text_tween_time then
				state = "ingame"
				gamestate[state].load()
			end
		end
		pn.update_animation(dt)
		pn.update_timer(dt)
		return true
	end,

	draw = function()
		beaver.set_draw_color(255,255,255,255)
		starfield.draw(stars)
		beaver.draw_line(0, config:ground_level(), config.logical_size[1], config:ground_level())
		beaver.draw_text_centered(config.logical_size[1]/2, logo_posy, "mago100", "PALENIGHT")
		beaver.draw_text_centered(config.logical_size[1]/2, start_posy, "mago50", "START")
		beaver.draw_text_centered(config.logical_size[1]/2, quit_posy, "mago50", "QUIT")
	end
}

gamestate["ingame"] = {
	load = function()
		pn.set_stopwatch(timer)
		obstacle_spawner.init()
		SMOKE_PE = pn.add_entity()
		pn.set_particle_emitter_config(SMOKE_PE, {
			emitting_position = {x = 200, y = 200},
			linear_acceleration = {x = 0, y = 0}, -- Slow upward drift
			lifetime = 1.5, -- Longer lifetime for smoke
			direction = math.rad(270),
			spread = math.rad(30),
			size_variation = {min = 5, max = 15}, -- Larger, billowing particles
			speed_variation = {min = 10, max = 30}, -- Slow movement
			rate = 500, -- Moderate rate
			color_gradient = {
				{time = 0.0, color = {200, 200, 200, 255}}, -- Dark gray at start
				{time = 0.5, color = {100, 100, 100, 255}}, -- Light gray, slightly transparent
				{time = 1.0, color = {50, 50, 50, 255}}, -- Almost white and fully transparent
			},
		})

		pn.set_particle_emitter_auto(SMOKE_PE, false)
	end,
	reset = function()
		pn.set_stopwatch(timer)
		player.reset()
		for _, eid in ipairs(pn.get_entities_with_tags({"obstacle"})) do
			pn.set_active(eid, false)
		end
	end,
	update = function(dt)
		pn.update_movement(dt)
		starfield.update(stars, -80, dt)
		player.update(dt)
		obstacle_spawner.update(pn.get_stopwatch(timer),dt)
		obstacle.update(dt)
		collision.update()
		for _,eid in ipairs(pn.get_active_entities()) do
			if pn.has_tag(eid,"one_time_animation") and pn.get_animation(eid).playing == false then
				pn.set_active(eid, false)
			end

			if pn.has_tag(eid, "attack_anim") then
				local ppos = pn.get_position(PEID)
				pn.set_position(eid, ppos.x, ppos.y)
				if not pn.is_active(eid) then
					pn.remove_tag(PEID, "attacking")
				end
			end

			local pos = pn.get_position(eid)
			if pos then
				if pos.x <= -config.grid_size or pos.y >= config.logical_size[2] then
					pn.set_active(eid, false)
				end
			end
			if not pn.is_active(eid) then print(eid .. " just be inactive") end
		end
		pn.update_animation(dt)
		pn.update_timer(dt)
		pn.update_countdown(dt)
		pn.update_particle_emitter(dt)
		particle.decrease_size_overtime(SMOKE_PE)
		pn.cleanup_entities();

		if player.get_health() == 0 then state = "gameover";gamestate[state].load() end

		return true
	end,

	draw = function()
		starfield.draw(stars)
		beaver.set_draw_color(255,255,255,255)
		beaver.draw_line(0, config:ground_level(), config.logical_size[1], config:ground_level())

		beaver.draw_text(450, 10, "mago32", "SCORE: " .. player.score)
		beaver.draw_text(250, 10, "mago32", "TIME: " .. string.format("%.3f", pn.get_stopwatch(timer)))


		-- Draw heart
		for i = 1,3 do
			beaver.draw_texture("tileset", {
				src = player.get_health() >= i and {x = 8, y = 48, w = 8, h = 8} or {x = 0, y  = 48, w = 8, h = 8},
				dst = {x = 40 * i, y = 10, w = 30, h = 30}
			})
		end
		if config.debug then
			for _, eid in ipairs(pn.get_active_entities()) do
				local cbox = pn.get_cbox(eid)
				local scale = pn.get_scale(eid)
				if cbox then
					local pos = pn.get_position(eid)
					beaver.draw_rectangle(pos.x + cbox.x * scale.x, pos.y + cbox.y * scale.y, cbox.w * scale.x, cbox.h * scale.y, true)
				end
			end

			for _, eid in ipairs(pn.get_active_entities()) do
				local pos = pn.get_position(eid)
				local vel = pn.get_velocity(eid)
				if pos and vel then
					beaver.draw_text(pos.x, pos.y - config.grid_size - 30, "mago", "eid " .. eid .. "\n"
																			.. "posx " .. string.format("%.3f", pos.x) .. "\n"
																			.. "posy " .. string.format("%.3f", pos.y) .. "\n"
																			.. "velx " .. string.format("%.3f", vel.x) .. "\n"
																			.. "vely " .. string.format("%.3f", vel.y))
				end
			end
		beaver.draw_text(10,10,"mago", "active entities size ".. #pn.get_active_entities())
		beaver.draw_text(10,20,"mago", "player timer "..string.format("%.3f", pn.get_timer(PEID) and pn.get_timer(PEID).elapsed or 0))
		beaver.draw_text(10,30,"mago", "player state " .. pn.get_state(PEID) .. pn.get_previous_state(PEID))
		end
	end
}

local survived_time = ""
gamestate["gameover"] = {
	load = function()
		text_in = true
		text_out = false
		survived_time = string.format("%.3f", pn.get_stopwatch(timer))
		pn.set_stopwatch(timer)
		beaver.play_music("gameover")
	end,
	update = function(dt)
		starfield.update(stars, -80, dt)
		if (text_in == true) then
			local t = pn.get_stopwatch(timer)
			logo_posy = logo_start_posy + (logo_end_posy - logo_start_posy) * ease_in_out_back(math.min(t / logo_tween_time,1))
			start_posy = start_start_posy + (start_end_posy - start_start_posy) * ease_in_out_back(math.min(t / text_tween_time, 1))
			quit_posy = quit_start_posy + (quit_end_posy - quit_start_posy) * ease_in_out_back(math.min(t / text_tween_time, 1))
			if t >= text_tween_time then text_in = false end
		else
			if beaver.get_input("X") == 1 then
				pn.set_stopwatch(timer)
				beaver.play_music("bgm1")
				text_out = true
			end
		end

		if text_out == true then
			pn.set_position(arrow, -500, -500)
			local t = pn.get_stopwatch(timer)
			logo_posy = logo_end_posy + (logo_start_posy - logo_end_posy) * ease_in_out_back(math.min(t / logo_tween_time,1))
			start_posy = start_end_posy + (start_start_posy - start_end_posy) * ease_in_out_back(math.min(t / text_tween_time, 1))
			quit_posy = quit_end_posy + (quit_start_posy - quit_end_posy) * ease_in_out_back(math.min(t / text_tween_time, 1))
			if t >= text_tween_time then
				state = "ingame"
				gamestate[state].reset()
			end
		end
		pn.update_timer(dt)
		return true
	end,

	draw = function()
		starfield.draw(stars)
		beaver.set_draw_color(255,255,255,255)
		beaver.draw_line(0, config:ground_level(), config.logical_size[1], config:ground_level())
		beaver.draw_text_centered(config.logical_size[1]/2, logo_posy - 100, "mago100", "GAMEOVER")
		beaver.draw_text_centered(config.logical_size[1]/2, logo_posy + 30, "mago32", "Time survived: " .. survived_time .."     Score earned: " .. player.score)

		local t = pn.get_stopwatch(timer)
		if math.floor(t / 0.5) % 2 == 0 then
			beaver.draw_text_centered(config.logical_size[1]/2, start_posy + 20, "mago32", "Press X to start again")
		end
	end
}

return gamestate
