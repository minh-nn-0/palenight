#pragma once

#include <mmath/core.hpp>
namespace pn
{
	struct transform
	{
		mmath::fvec2 _position;
		mmath::fvec2 _velocity;
		mmath::fvec2 _scale;
		float _rotation;
	};
};
