local starfield = {}

function starfield.new(number)
	local stars = {}
	for _ = 1, number do
		table.insert(stars, {
			x = math.random(config.logical_size[1]),
			y = math.random(config:ground_level()),
			level = math.random(3),
			size = math.random() * 2 + 1
		})
	end
	return stars
end

function starfield.update(field, speed, dt)
	for i,_ in pairs(field) do
		field[i].x = field[i].x + speed * dt

		if field[i].x <= -1 then
			field[i] = {
				x = config.logical_size[1],
				y = math.random(config:ground_level()),
				level = math.random(3),
				size = math.random() * 2 + 2
			}
		end
	end
end

function starfield.draw(field)
	for _, star in pairs(field) do
		local alpha = 0.3/star.level
		beaver.set_draw_color(255,255,255,math.floor(255*alpha))
		beaver.draw_circle(star.x + 0.2 * star.level, star.y, star.size, true)
		beaver.set_draw_color(255,255,255,255)
	end
end

return starfield
