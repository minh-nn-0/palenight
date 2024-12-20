local obstacle = {}

local function move_bat(bat)
		if pn.get_state(bat) ~= "die" then
			local sw = pn.get_stopwatch(bat)
			local pos = pn.get_position(bat)
			pn.set_position(bat, pos.x, 120 * math.sin(sw / 2 * 2 * math.pi) + config.logical_size[2]/2)
		end
end

local function duck_lay_egg(duck)
	local duck_pos = pn.get_position(duck)
	local egg = pn.add_entity()
	pn.set_position(egg, duck_pos.x, duck_pos.y + 10)
	pn.set_velocity(egg, 0, 30)
	pn.set_scale(egg, config.scale_of["duck"][1], config.scale_of["duck"][2])
	pn.set_cbox(egg, config.cbox_of["egg"])
	pn.add_tag(egg, "egg")
	pn.add_tag(egg, "hurtable")
	pn.set_image(egg, "tileset")
	pn.set_image_source(egg, 24, 48, 2, 2)
end

local function egg_fall_to_ground(egg)
	local egg_pos = pn.get_position(egg)
	pn.manual_emit_particles(SMOKE_PE, 50, egg_pos.x, egg_pos.y, {speed_variation = {min = 50, max = 100}})
	pn.set_active(egg, false)
end

function obstacle.update(dt)
	for _,bat in ipairs(pn.get_entities_with_tags({"bat"})) do
		move_bat(bat)
	end
	for _,duck in ipairs(pn.get_entities_with_tags({"duck"})) do


		if not pn.get_timer(duck).running --and math.random() > 0.5
			then
			duck_lay_egg(duck)
			beaver.play_sound("duckquack")
			pn.set_timer(duck, 1.6)
		end
	end
	for _,egg in ipairs(pn.get_entities_with_tags({"egg"})) do
		if pn.get_position(egg).y >= config:ground_level() - 2 * config.scale_of["duck"][2] then
			egg_fall_to_ground(egg)
		end
	end
end
return obstacle
