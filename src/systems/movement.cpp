namespace movement
{
	constexpr mmath::fvec2 apply_velocity(const mmath::fvec2& pos,
										const mmath::fvec2& vel, float dt)
	{
		return {
			pos.x + vel.x * dt, 
			pos.y + vel.y * dt
		};
	}
};
