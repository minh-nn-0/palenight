return {
	logical_size = {640, 360},
	gravity = 0,
	pixel_size = 4,
	grid_size = 32,
	ground_level = function(self) return self.logical_size[2] - self.grid_size end,
	player_speed = 3,
	base_velocity = 100,
	base_jump = 200
}
