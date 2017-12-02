local block_data = {}

block_data["void"] =
{
	hp = 0,
	breakable = false,
	collision_type = "solid",
	slope = false,
}

block_data["air"] =
{
	hp = 0,
	breakable = false,
	collision_type = "empty",
	slope = false,
}

block_data["wall"] =
{
	hp = 60,
	breakable = true,
	collision_type = "solid",
	slope = false,
}

block_data["slope_45"] =
{
	hp = 0,
	breakable = false,
	collision_type = "slope",
	collision_dirs = { u = false, d = true, l = false, r = true},
	slope = -1,
	slope_y_offset = 0,
}

block_data["slope_-45"] =
{
	hp = 0,
	breakable = false,
	collision_type = "slope",
	collision_dirs = { u = false, d = true, l = true, r = false},
	slope = 1,
	slope_y_offset = 0,
}

block_data["slope_45_a"] =
{
	hp = 0,
	breakable = false,
	collision_type = "slope",
	collision_dirs = { u = false, d = true, l = false, r = true},
	slope = -1,
	slope_y_offset = 16,
}

block_data["slope_45_b"] =
{
	hp = 0,
	breakable = false,
	collision_type = "slope",
	collision_dirs = { u = false, d = true, l = false, r = true},
	slope = -1,
	slope_y_offset = -16,
}

block_data["slope_-45_a"] =
{
	hp = 0,
	breakable = false,
	collision_type = "slope",
	collision_dirs = { u = false, d = true, l = false, r = true},
	slope = 1,
	slope_y_offset = 16,
}

block_data["slope_-45_b"] =
{
	hp = 0,
	breakable = false,
	collision_type = "slope",
	collision_dirs = { u = false, d = true, l = false, r = true},
	slope = 1,
	slope_y_offset = -16,
}

return block_data
