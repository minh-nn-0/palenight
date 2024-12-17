local movement = {}

local function apply_velocity(pos, vel, dt)
	return {
		x = pos.x + vel.x * dt,
		y = pos.y + vel.y * dt
	}

end

local function sinusodial_motion(eid, amplitude, frequency, dt)
	local sw = pn.get_stopwatch(eid)
	local omega = 2 * math.pi * frequency

	local vel = pn.get_velocity(eid)
	return {
		x = vel.x,
		y = omega * amplitude * math.cos(omega * sw)
	}
end

function movement.update(eid, dt)
	local pos = pn.get_position(eid)
	local vel = pn.get_velocity(eid)

	if pos and vel then
		if pn.have_tag(eid, "bat") then
			vel = sinusodial_motion(eid, 90, 0.5, dt)
		end

		pos = apply_velocity(pos,vel,dt)

		pn.set_position(eid, pos)
		pn.set_velocity(eid, vel)
	end
end


return movement

