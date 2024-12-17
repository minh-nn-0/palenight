package.path = package.path .. ";" .. pn.gamepath() .. "/?.lua"
package.path = package.path .. ";" .. pn.gamepath() .. "/scripts/?.lua"

beaver = require "beaver"
geo = require "geometry"
pn = pn or {}

local util = require "utilities"
config = {
	debug = false,
	logical_size = {640, 360},
	gravity = 800,
	pixel_size = 5,
	grid_size = 40,
	ground_level = function(self) return self.logical_size[2] - self.grid_size end,
	player_speed = 250,
	base_velocity = 100,
	base_jump = 250,
	max_jump = 450,
	cbox_of = {
		["player"] = util.make_rect(0,3,7,4),
		["duck"] = util.make_rect(0,0,7,5),
		["bat"] = util.make_rect(0,0,7,4),
		["box"] = util.make_rect(0,3,5,5),
		["coin"] = util.make_rect(0,0,5,5),
		["attack"] = util.make_rect(2,3,13,4),
	}
}

