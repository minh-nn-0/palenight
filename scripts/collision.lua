local player = require "player"
local collision = {}



COLLISION_PE = pn.add_entity()
pn.set_particle_emitter_config(COLLISION_PE, {
	linear_acceleration = {x = 0, y = 50},
	lifetime = 0.3,
	direction = math.rad(270),
	spread = math.rad(260),
	size_variation = {min = 5, max = 10},
	speed_variation = {min = 30, max = 200},
	color_gradient = {
		{time = 0.0, color = {255, 100, 100, 255}},
		{time = 1.0, color = {150, 50, 50, 255}},
	},
})
pn.set_particle_emitter_auto(COLLISION_PE, false)

function collision.update()
	for _, eid in ipairs(pn.get_active_entities()) do
		-- player (every "normal" entity except attack animation colliding with player that is not invicible)
		if pn.colliding_with(eid, PEID) and not player.is_invicible() and
			pn.get_state(eid) == "normal" and not pn.has_tag(eid, "attack_anim") then
			pn.set_state(PEID, "hurt")
			beaver.play_sound("hurt")
		end

		-- obstacle (attack animation colliding with "normal" entity that is not player) 
		if pn.has_tag(eid, "attack_anim") then
			for _, coll in ipairs(pn.find_collisions(eid)) do
				if coll ~= PEID and pn.get_state(coll) == "normal" then
					beaver.play_sound("hurt")
					pn.set_state(coll, "die")
					player.score = player.score + 1
					local cbox = pn.get_cbox(coll)
					local pos= pn.get_position(coll)
					local hitx = pos.x + cbox.x + cbox.w / 2
					local hity = pos.y + cbox.y + cbox.h / 2
					pn.manual_emit_particles(COLLISION_PE, 50, hitx, hity, {})
				end
			end
		end
	end
end

return collision
