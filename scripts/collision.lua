local player = require "player"
local particle = require "particle"
local collision = {}


local function new_collision_pe()

	local colpe = pn.add_entity()
	pn.add_tag(colpe, "colpe")
	pn.set_particle_emitter_config(colpe, {
		linear_acceleration = {x = 0, y = 50},
		lifetime = 0.6,
		direction = math.rad(270),
		spread = math.rad(360),
		size_variation = {min = 2, max = 10},
		speed_variation = {min = 30, max = 300},
	})
	pn.set_particle_emitter_auto(colpe, false)

	return colpe
end
local random_color = {
	{34, 120, 200, 255},
	{180, 65, 90, 255},
	{75, 150, 120, 255},
	{220, 88, 50, 255},
	{95, 40, 150, 255},
	{145, 200, 75, 255},
	{255, 120, 0, 255},
	{0, 140, 255, 255},
	{105, 60, 220, 255},
	{200, 200, 50, 255},
}


local function spawn_coin_or_heart(position)
	if math.random() > 0.5 then
		local heart = pn.add_entity()
		pn.add_tag(heart, "heart")
		pn.add_tag(heart, "collectible")
		pn.add_tag(heart, "stay_on_ground")
		pn.set_position(heart, position.x, position.y)
		pn.set_velocity(heart, 0, -400)
		pn.set_scale(heart, config.scale_of["heart"][1], config.scale_of["heart"][2])
		pn.set_cbox(heart, config.cbox_of["heart"])
		pn.set_image(heart, "tileset")
		pn.set_image_source(heart, 8,48,8,8)
	else
		local coin = pn.add_entity()
		pn.add_tag(coin, "coin")
		pn.add_tag(coin, "collectible")
		pn.add_tag(coin, "stay_on_ground")
		pn.set_position(coin, position.x, position.y)
		pn.set_velocity(coin, 0, -400)
		pn.set_scale(coin, config.scale_of["coin"][1], config.scale_of["coin"][2])
		pn.set_cbox(coin, config.cbox_of["coin"])
		pn.set_image(coin, "tileset")
		pn.set_image_source(coin, 24,56,4,4)
	end
end


function collision.update()
	for _, eid in ipairs(pn.get_active_entities()) do

		-- obstacle (attack animation colliding with "normal" entity that is not player) 
		if pn.has_tag(eid, "attack_anim") then
			for _, coll in ipairs(pn.find_collisions(eid)) do
				if pn.has_tag(coll, "attackable") then
					beaver.play_sound("hurt")
					pn.set_state(coll, "die")
					player.score = player.score + 1
					local cbox = pn.get_cbox(coll)
					local pos= pn.get_position(coll)
					local vel = pn.get_velocity(coll)

					pn.set_velocity(coll, vel.x, -300)
					local hitx = pos.x + cbox.x + cbox.w / 2
					local hity = pos.y + cbox.y + cbox.h / 2

					local colpe = new_collision_pe()
					pn.manual_emit_particles(colpe, 20, hitx, hity, {})

					for _, part in ipairs(pn.get_particles(colpe)) do
						local cl1_id = math.random(#random_color)
						local cl2_id = math.random(#random_color)
						while cl1_id == cl2_id do
							cl1_id = math.random(#random_color)
							cl2_id = math.random(#random_color)
						end

						local cl1 = random_color[cl1_id]
						local cl2 = random_color[cl2_id]
						pn.set_particle_color_gradient(colpe, part, {
							{time = 0.0, color = {cl1[1], cl1[2], cl1[3], cl1[4]}},
							{time = 1.0, color = {cl2[1], cl2[2], cl2[3], cl2[4]}},
						})
					end

					if (math.random() > 0.5) then spawn_coin_or_heart(pos) end
				end
			end
		end

		for _, pe in ipairs(pn.get_entities_with_tags({"colpe"})) do
			particle.decrease_size_overtime(pe)
			if #pn.get_particles(pe) == 0 then pn.set_active(pe, false) end
		end



		-- player (every "normal" entity except attack animation colliding with player that is not invicible)
		if pn.colliding_with(eid, PEID) and not player.is_invicible() and
			pn.has_tag(eid, "hurtable") and pn.get_state(PEID) ~= "hurt" then
				pn.set_state(PEID, "hurt")
				beaver.play_sound("hurt")
		end
	end
end

return collision
