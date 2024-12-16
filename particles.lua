local particle = {}

function particle.decrease_size_overtime(pid)
	for _,p in ipairs(pn.get_particles(SMOKE_PE)) do
		local elapsed, lifetime = pn.get_particle_lifetime(SMOKE_PE, p)

		local _, init_size = pn.get_particle_size(SMOKE_PE,p)
		pn.set_particle_size(SMOKE_PE, p, init_size * (1 - elapsed/lifetime))
	end
	pn.cleanup_entities();
end
