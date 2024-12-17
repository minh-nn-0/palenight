#pragma once

#include <mmath/core.hpp>
namespace pn
{
	struct oscillation
	{
		float _amplitude; // maximum displacement
		float _frequency; // cycles per seconds
		float _phase; // offset (radian)
		mmath::fvec2 _direction; // direction
		enum class WAVEFORM
		{
			SINUSODIAL,
			TRIANGULAR,
			SQUARE
		} _waveform;
	};
}
