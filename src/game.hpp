#pragma once

#include <beaver/core.hpp>
#include <beaver/ecs/core.hpp>
#include <beaver/scripting/scripting_ecs.hpp>
#include <beaver/scripting/scripting_core_components.hpp>
#include <beaver/scripting/scripting_core.hpp>
namespace pn
{
	using fsm = beaver::component::fsm<std::string>;

	struct game
	{
		game(); 
		~game();
		beaver::sdlgame _beaver;
		sol::state _lua;
		beaver::ecs_core<> _entity_manager;
		int _playereid;

		void load_config();
		void setup_binding();
		bool update(float dt);
		void draw();
		void run();
	};
};
