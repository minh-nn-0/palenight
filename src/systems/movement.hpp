#pragma once

#include <mmath/core.hpp>
#include <components/oscillation.hpp>
namespace movement
{
	inline mmath::fvec2 apply_velocity(const mmath::fvec2& position, const mmath::fvec2& velocity, float dt)
	{
		return {position.x + velocity.x * dt, position.y + velocity.y * dt};
	};

	inline mmath::fvec2 apply_gravity(const mmath::fvec2& velocity, unsigned gravity, float dt)
	{
		return {velocity.x, velocity.y + gravity * dt};
	};

	inline mmath::fvec2 apply_oscillation(const mmath::fvec2& velocity, const beaver::component::oscillation& oscillation)
	{
	};
};
