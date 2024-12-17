local util = {}
function util.make_rect(x,y,w,h)
	return {
		x = x,
		y = y,
		w = w,
		h = h
	}
end
function util.scale_rect_logical(rect)
	return {
		x = rect.x * config.pixel_size,
		y = rect.y * config.pixel_size,
		w = rect.w * config.pixel_size,
		h = rect.h * config.pixel_size,
	}
end

return util

