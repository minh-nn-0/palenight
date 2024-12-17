#include "game.hpp"

#include <beaver/ecs/systems/movement.hpp>
#include <beaver/ecs/systems/collision.hpp>
#include <beaver/ecs/systems/animation.hpp>
#include <beaver/ecs/systems/render_entity.hpp>
using namespace beaver::component;
constexpr std::string game_path()
{
	return {GAMEPATH};
};

void pn::game::load_config()
{
	try 
	{
		_lua.safe_script_file(game_path() + "/config.lua");
	} catch (const sol::error& e)
	{
		std::println("error loading script: {}", e.what()); 
	};
};

void load_script(sol::state& lua)
{	
	try 
	{
		auto script_result = lua.safe_script_file(game_path() + "/scripts/main.lua");
	} catch (const sol::error& e)
	{
		std::println("error loading script: {}", e.what()); 
	};


	sol::protected_function load = lua["LOAD"];
	auto load_result = load();
	if (!load_result.valid()) 
		throw std::runtime_error(std::format("runtime error: {}", sol::error{load_result}.what()));
};


pn::game::game(): _beaver("palenight", 1280, 720)
{
	beaver::init_lua(_lua);
	sol::table gametable = _lua["pn"].get_or_create<sol::table>();
	gametable.set_function("gamepath", [&]() -> std::string {return game_path();});
	load_config();
	setup_binding();
	load_script(_lua);
};

pn::game::~game()
{
	std::println("EXIT");
};


bool pn::game::update(float dt)
{
	using namespace beaver::component;

	sol::protected_function lua_update = _lua["UPDATE"];
	auto update_result = lua_update(dt);
	if (!update_result.valid())
		throw std::runtime_error(std::format("runtime error: {}", sol::error{update_result}.what()));


	return true;
};

void pn::game::draw()
{
	sol::protected_function lua_draw = _lua["DRAW"];
	auto draw_result = lua_draw();
	if (!draw_result.valid())
		throw std::runtime_error(std::format("runtime error: {}", sol::error{draw_result}.what()));

	for (std::size_t eid: _entity_manager.with<position, image_render>()) 
		beaver::system::render::render_entity(eid, _entity_manager, _beaver);

	for (const auto& eid: _entity_manager.with<particle_emitter>())
		_entity_manager.get_component<particle_emitter>(eid)->draw(_beaver._graphics);
};

void pn::game::setup_binding()
{
	beaver::bind_core(_beaver, _lua);
	
	sol::table gametable = _lua["pn"].get<sol::table>();
	beaver::bind_ecs_core_components(_entity_manager, _beaver, gametable, _lua);
	gametable.set_function("update_movement", [&](float dt)
			{
				for (auto&& eid:_entity_manager.with<position, velocity>()) 
				{
					position new_pos = _entity_manager.get_component<position>(eid).value();
					velocity new_vel = _entity_manager.get_component<velocity>(eid).value();


					if (!_entity_manager.has_tag(eid, "no_gravity"))
						new_vel = beaver::system::movement::apply_gravity(new_vel, _lua["config"]["gravity"], dt);
					else new_vel._value.y = 0;

					//if (_entity_manager.has_component<oscillation>(eid))
					//{
					//	oscillation& osc = _entity_manager.get_component<oscillation>(eid).value();
					//	osc._timer += dt;

					//	new_pos = apply_oscillation(osc);
					//};

					new_pos = beaver::system::movement::apply_velocity(new_pos, new_vel, dt);

					_entity_manager.set_component<position>(eid, new_pos);
					_entity_manager.set_component<velocity>(eid, new_vel);
				};
			});
	gametable.set_function("update_animation", [&](float dt)
			{
				beaver::system::animation::update_tile_animation(_beaver._assets, _entity_manager, dt);
			});
	gametable.set_function("update_countdown", [&](float dt)
			{
				for (auto&& eid: _entity_manager.with<timing::countdown>())
				{
					_entity_manager.get_component<timing::countdown>(eid)->update(dt);
				};
			});
	gametable.set_function("update_timer", [&](float dt)
			{
				for (auto&& eid: _entity_manager.with<timing::stopwatch>())
				{
					_entity_manager.get_component<timing::stopwatch>(eid)->update(dt);
				};
			});
	gametable.set_function("update_particle_emitter", [&](float dt)
			{
				for (auto&& eid: _entity_manager.with<particle_emitter>())
				{
					_entity_manager.get_component<particle_emitter>(eid)->update(dt);
				};
			});
	gametable.set_function("update_state", [&]()
			{
				for (auto&& eid: _entity_manager.with<beaver::fsmstr>())
				{
					_entity_manager.get_component<beaver::fsmstr>(eid)->update();
				};
			});
	gametable.set_function("find_collisions", [&](std::size_t eid) -> std::vector<std::size_t>
			{
				return beaver::system::collision::find_collisions(eid, _entity_manager);
			});
	gametable.set_function("colliding_with", [&](std::size_t eid, std::size_t other_eid)
			{
				auto collisions = beaver::system::collision::find_collisions(eid, _entity_manager);
				return std::ranges::find(collisions, other_eid) != collisions.end();
			});
	gametable.set_function("cleanup_entities", [&]() {_entity_manager.clear_inactive();});
	
};
void pn::game::run()
{
	beaver::run_game(_beaver, 
			[&](float dt){return update(dt);},
			[&]{draw();});

	std::println("exiting game");
};

