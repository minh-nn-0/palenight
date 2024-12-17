local particles = {}

function particles.decrease_size_overtime(eid)
	for _, pid in ipairs(pn.get_particles(eid)) do
		local elapsed, lifetime = pn.get_particle_lifetime(eid, pid)

		local _, init_size = pn.get_particle_size(eid, pid)
		pn.set_particle_size(eid, pid, init_size * (1 - elapsed/lifetime))
	end
end

return particles
