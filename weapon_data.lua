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
	cof_min = 0, cof_max = 10, cof_growth = 10,

	["fire"] = function(self, owner, t_x, t_y)
		local angle = math.atan2(t_y - owner.y, t_x - owner.x)

		local shot_angle = mymath.random_spread(angle, owner.cof)
		local shot_speed = self.shot_speed + self.shot_speed_variance * love.math.random()

		shot_data.spawn(self.shot, owner.x, owner.y,
						shot_speed * math.cos(shot_angle), shot_speed * math.sin(shot_angle),
						owner.name, owner.faction)

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		if owner.cof_factor < 100 then
			owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		end

		-- kick in the opposite direction. kick vertically only if airborne
		owner.dx = owner.dx - self.kick * math.cos(angle)
		if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(5, angle)
		end
	end
}

weapon_data["plasma"] =
{
	class = "plasma", name = "Plasma Gun", color = color.yellow,
	shot = "plasma",
	sfx_fire = "gunfire2",
	ammo_max = 6, ammo_glyph = "*", reload_time = 1.5,
	shot_speed = 300, shot_speed_distance_scaling = 1.2, shot_speed_max = 700, cooldown = 1, recoil = 30, kick = 218,
	cof_min = 5, cof_max = 40, cof_growth = 25,

	["fire"] = function(self, owner, t_x, t_y)
		local angle = math.atan2(t_y - owner.y, t_x - owner.x)

		local shot_angle = mymath.random_spread(angle, owner.cof)
		local shot_speed = math.min(self.shot_speed + self.shot_speed_distance_scaling * mymath.dist(owner.x, owner.y, t_x, t_y),
									self.shot_speed_max)

		shot_data.spawn(self.shot, owner.x, owner.y,
						shot_speed * math.cos(shot_angle), shot_speed * math.sin(shot_angle),
						owner.name, owner.faction)

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		if owner.cof_factor < 100 then
			owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		end

		-- XXX recoil by messing up the player's aim? feels odd
		-- if owner.class == "player" then
		-- 	local recoil_angle = math.pi * (-1 + love.math.random())
		-- 	love.mouse.setPosition(mouse.x + owner.weapon.recoil * math.cos(recoil_angle),
		-- 						   mouse.y + owner.weapon.recoil * math.sin(recoil_angle))
		-- end

		-- kick in the opposite direction. kick vertically only if airborne
		owner.dx = owner.dx - self.kick * math.cos(angle)
		if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(20, angle)
		end
	end
}

weapon_data["shotgun"] =
{
	class = "shotgun", name = "Shotgun", color = color.rouge,
	shot = "buckshot",
	sfx_fire = "gunfire2",
	ammo_max = 2, ammo_glyph = "!", reload_time = 0.8,
	shot_speed = 300, shot_speed_variance = 500, shot_count = 8, cooldown = 0.60, recoil = 40, kick = 218,
	cof_min = 15, cof_max = 15, cof_growth = 0,

	["fire"] = function(self, owner, t_x, t_y)
		local angle = math.atan2(t_y - owner.y, t_x - owner.x)

		for k = 1, self.shot_count do
			local shot_angle = mymath.random_spread(angle, owner.cof)
			local shot_speed = self.shot_speed + self.shot_speed_variance * love.math.random()

			shot_data.spawn(self.shot, owner.x, owner.y,
							shot_speed * math.cos(shot_angle), shot_speed * math.sin(shot_angle),
							owner.name, owner.faction)
		end

		owner.shot_cooldown = owner.shot_cooldown + self.cooldown
		if owner.cof_factor < 100 then
			owner.cof_factor = math.min(100, owner.cof_factor + self.cof_growth)
		end

		-- XXX recoil by messing up the player's aim? feels odd
		-- if owner.class == "player" then
		-- 	local recoil_angle = math.pi * (-1 + love.math.random())
		-- 	love.mouse.setPosition(mouse.x + owner.weapon.recoil * math.cos(recoil_angle),
		-- 						   mouse.y + owner.weapon.recoil * math.sin(recoil_angle))
		-- end

		-- kick in the opposite direction. kick vertically only if airborne
		owner.dx = owner.dx - self.kick * math.cos(angle)
		if not owner.touching_floor then owner.dy = owner.dy -self.kick * math.sin(angle) end

		self.ammo = self.ammo - 1

		audio.play(self.sfx_fire)
		if owner.class == "player" then
			camera.shake(5, angle)
		end
	end
}

return weapon_data
