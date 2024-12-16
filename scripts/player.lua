local util = require "utilities"
local player = {
	score = 0
}
local FRAMES_DOG_MOVE = {{1, 300}, {0, 300}}
local FRAMES_DOG_JUMP = {{2, 250}, {3, 250}}
local FRAMES_DOG_FALL = {{5, 150}};

local JUMP_CHARGER = config.base_jump
function player.load()
	PEID = pn.add_entity();
	pn.add_tag(PEID, "player");
	pn.set_position(PEID, 20, config:ground_level() - config.grid_size)
	pn.set_velocity(PEID, 0, 0)

	pn.set_stopwatch(PEID)
	pn.set_cbox(PEID, util.scale_rect_logical(config.cbox_of["player"]))
	pn.set_image(PEID, "spritesheet_dog")
	pn.set_scale(PEID, config.pixel_size, config.pixel_size)

	pn.set_state_entry(PEID, "move",
		function()
			pn.set_tileanimation(PEID, {
				frames = FRAMES_DOG_MOVE,
				framewidth = 8,
				frameheight = 8,
				["repeat"] = true
			})
		end)

	pn.set_state_entry(PEID, "jump",
		function()
			pn.set_tileanimation(PEID, {
				frames = FRAMES_DOG_JUMP,
				framewidth = 8,
				frameheight = 8,
				["repeat"] = false,
			})
		end)

	pn.set_state_entry(PEID, "fall",
		function()
			pn.set_tileanimation(PEID, {
				frames = FRAMES_DOG_FALL,
				framewidth = 8,
				frameheight = 8,
				["repeat"] = false,
			})
		end)
	pn.set_state_entry(PEID, "hurt",
		function()
			pn.set_tileanimation(PEID, {
				frames = {{1,300}},
				framewidth = 8,
				frameheight = 8,
				["repeat"] = false,
			})
			pn.set_rotation(PEID, math.random(-90,90))
			local vel = pn.get_velocity(PEID)
			pn.set_velocity(PEID, 0, vel.y)
			pn.set_timer(PEID, 2)
		end)
end

local function attack_animation()
	if not pn.has_tag(PEID, "attacking") then
		local attackanim = pn.add_entity()
		pn.set_image(attackanim, "tileset")
		pn.set_scale(attackanim, 5,5)
		pn.set_tileanimation(attackanim, {
			frames = {{8,150}, {9,150}},
			framewidth = 16,
			frameheight = 8,
			["repeat"] = false
		})
		pn.add_tag(attackanim, "one_time_animation")
		pn.add_tag(attackanim, "attack_anim")
		pn.set_cbox(attackanim, util.scale_rect_logical(config.cbox_of["attack"]))

		pn.add_tag(PEID, "attacking")
	end
end

function player.is_invicible()
	return pn.get_previous_state(PEID) == "hurt" and pn.get_timer(PEID).running == true
end
function player.update(dt)
	local ppos = pn.get_position(PEID)
	local pvel = pn.get_velocity(PEID)
	local pstate = pn.get_state(PEID)

	-- Clamp position
	ppos.x = math.max(ppos.x, 0)
	ppos.x = math.min(ppos.x, config.logical_size[1] - config.grid_size)
	ppos.y = math.min(ppos.y, config:ground_level() - config.grid_size)

	if pstate == "hurt" then
		if pn.get_timer(PEID).running == false then
			pstate = "move"
			pn.set_timer(PEID, 2)
			pn.set_rotation(PEID, 0)
		end
	else
		if player.is_invicible() then
			local sw = pn.get_stopwatch(PEID)
			if math.floor(sw / 0.1) % 2 == 0 then
				pn.set_tint(PEID, 255,255,255,0)
			else
				pn.set_tint(PEID, 255,255,255,255)
			end
		else
			pn.set_tint(PEID, 255,255,255,255)
		end

		if pvel.y > 0 and pstate == "jump" then
			pstate = "fall"
		end

		if ppos.y >= config:ground_level() - config.grid_size then
			pstate = "move"
		end

		-- MOVEMENT
		-- Left and right movement
		if beaver.get_input("LEFT") > 0 then
			ppos.x = ppos.x - config.player_speed * dt
		end

		if beaver.get_input("RIGHT") > 0 then
			ppos.x = ppos.x + config.player_speed * dt
		end

		if beaver.get_input("X") == 1 then
			attack_animation()
		end


		-- HOLD JUMP
		if beaver.get_input("Z") > 0 and pstate == "move" then
			JUMP_CHARGER = math.min(JUMP_CHARGER + beaver.get_input("Z"), config.max_jump)

			pn.manual_emit_particles(SMOKE_PE, 2, ppos.x, ppos.y + config.grid_size, {
												linear_acceleration = {x = 0, y = -5},
												lifetime = 0.3,
												size_variation = {min = 2, max = 4},
												speed_variation = {min = 10, max = 10},
												direction = math.rad(200),
												spread = math.rad(30)
			})
		end

		-- RELEASE JUMP
		if JUMP_CHARGER ~= config.base_jump and beaver.get_input("Z") == 0 then
			pstate = "jump"

			pn.manual_emit_particles(SMOKE_PE, 50, ppos.x, ppos.y + config.grid_size, {
												linear_acceleration = {x = -50, y = -30},
												lifetime = 1,
												size_variation = {min = 5, max = 10},
												speed_variation = {min = 10, max = 30},
												direction = math.rad(200),
												spread = math.rad(30)
			})
			pvel.y = -JUMP_CHARGER
			JUMP_CHARGER = config.base_jump
		end

	end


	pn.set_position(PEID, ppos.x, ppos.y)
	pn.set_state(PEID, pstate)
	pn.set_velocity(PEID, pvel.x, pvel.y)
end

return player
