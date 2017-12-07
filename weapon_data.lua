local weapon_data = {}

function weapon_data.spawn(class)
	o = {}

	for i, v in pairs(weapon_data[class]) do
		o[i] = v
	end

	o.ammo = o.ammo_max

	return o
end


weapon_data["default"] =
{
	class = "default", name = "Assault Rifle", color = color.ltblue,
	shot = "pellet",
	sfx_fire = "gunfire1",
	ammo_max = 24, ammo_glyph = ".", reload_time = 0.8,
	shot_speed = 1100, shot_speed_variance = 200, cooldown = 0.10, recoil = 3, kick = 50,
	cof_min = 0, cof_max = 10, cof_growth = 10
}

weapon_data["plasma"] =
{
	class = "plasma", name = "Plasma Gun", color = color.yellow,
	shot = "plasma",
	sfx_fire = "gunfire2",
	ammo_max = 6, ammo_glyph = "*", reload_time = 1.5,
	shot_speed = 500, shot_speed_variance = 0, cooldown = 1, recoil = 30, kick = 218,
	cof_min = 5, cof_max = 40, cof_growth = 25
}

weapon_data["shotgun"] =
{
	class = "shotgun", name = "Shotgun", color = color.rouge,
	shot = "buckshot",
	sfx_fire = "gunfire2",
	ammo_max = 2, ammo_glyph = "!", reload_time = 0.8,
	shot_speed = 300, shot_speed_variance = 500, shot_count = 8, cooldown = 0.60, recoil = 40, kick = 218,
	cof_min = 15, cof_max = 15, cof_growth = 0
}

return weapon_data
