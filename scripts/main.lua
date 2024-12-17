local starfield = require "starfield"
local particle = require "particle"
local player = require "player"
local obstacle_spawner = require "obstacle_spawning"
local collision = require "collision"

local FRAMES_DUCK = {{28, 200}, {29, 200}};
local FRAMES_BAT = {{37, 200}, {38, 200}, {39,200}};

beaver.new_image(pn.gamepath() .. "/assets/images/endlessrunner_dog.png", "spritesheet_dog")
beaver.new_image(pn.gamepath() .. "/assets/images/endlessrunner_tileset.png", "tileset")

beaver.new_font(pn.gamepath() .. "/assets/fonts/mago1.ttf", 16, "mago")

beaver.new_sound(pn.gamepath() .. "/assets/audios/pnhit.wav", "hurt")
beaver.new_sound(pn.gamepath() .. "/assets/audios/pnattack.wav", "attack")
beaver.new_sound(pn.gamepath() .. "/assets/audios/pnjump.wav", "jump")
beaver.new_music(pn.gamepath() .. "/assets/audios/man-is-he-mega.mp3", "bgm1")

function LOAD()
	beaver.set_render_logical_size(config.logical_size[1], config.logical_size[2])

	player.load()
	obstacle_spawner.init()
	STARFIELD = starfield.new(30)

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

	pn.set_particle_emitter_auto(SMOKE_PE, true)
	beaver.set_volume_music(40)
	beaver.play_music("bgm1")
end
function UPDATE(dt)
	pn.update_movement(dt)
	starfield.update(STARFIELD, -80, dt)
	player.update(dt)
	obstacle_spawner.update(dt)
	collision.update(dt)
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
	particle.decrease_size_overtime(COLLISION_PE)
	pn.cleanup_entities();
end
function DRAW()
	beaver.set_draw_color(25,29,30,255)
	beaver.clear()
	starfield.draw(STARFIELD)
	beaver.set_draw_color(255,255,255,255)
	beaver.draw_line(0, config:ground_level(), config.logical_size[1], config:ground_level())

	beaver.draw_text(400, 10, "mago", "SCORE: " .. player.score)
	beaver.draw_text(200, 10, "mago", "TIME: " .. string.format("%.f", beaver.get_elapsed_time()))


	if config.debug then
		for _, eid in ipairs(pn.get_active_entities()) do
			local cbox = pn.get_cbox(eid)
			if cbox then
				local pos = pn.get_position(eid)
				beaver.draw_rectangle(pos.x + cbox.x, pos.y + cbox.y, cbox.w, cbox.h, true)
			end
		end

		for _, eid in ipairs(pn.get_active_entities()) do
			local pos = pn.get_position(eid)
			if pos then
				beaver.draw_text(pos.x, pos.y - config.grid_size, "mago", "eid " .. eid .. "\n"
																		.. "posx " .. string.format("%.3f", pos.x) .. "\n"
																		.. "posy " .. string.format("%.3f", pos.y))
			end
		end
	beaver.draw_text(10,10,"mago", "active entities size ".. #pn.get_active_entities())
	beaver.draw_text(10,20,"mago", "player timer "..string.format("%.3f", pn.get_timer(PEID) and pn.get_timer(PEID).elapsed or 0))
	beaver.draw_text(10,30,"mago", "player state " .. pn.get_state(PEID) .. pn.get_previous_state(PEID))
	end
end





