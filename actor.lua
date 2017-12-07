local actor = {}

function actor:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function actor:update(dt)
	self:check_status("reload")
	self:update_controls(dt)
	self:update_weapon(dt)
	self:update_location(dt)
end

-- TODO: move player controls elsewhere
local last_key_dir = { l = 0, r = 0, u = 0, d = 0 } -- left right up down
local doubletap_time = 0.2 -- time to double-tap
local aim_distance = 300
function actor:update_controls(dt)
	if self.ai.control == "player" then
		self.controls.x, self.controls.y = 0, 0
		if controller:down('dp_left') then self.controls.x = self.controls.x - 1 end
		if controller:down('dp_right') then self.controls.x = self.controls.x + 1 end
		if controller:down('dp_up') then self.controls.y = self.controls.y - 1 end
		if controller:down('dp_down') then self.controls.y = self.controls.y + 1 end

		if controller:pressed('dp_left') then
			if (guitime - last_key_dir.l) < doubletap_time and not player:check_status("dash_cooldown") then
				player:dash_left()
			end
			last_key_dir.l = guitime
		end
		if controller:pressed('dp_right') then
			if (guitime - last_key_dir.r) < doubletap_time and not player:check_status("dash_cooldown") then
				player:dash_right()
			end
			last_key_dir.r = guitime
		end

		self.controls.jump = controller:pressed('l1')
		self.controls.float = controller:down('l1')

		if controller:pressed('x') and self.weapon.ammo ~= self.weapon.ammo_max then
			self.controls.reload = true
		end
		if controller:pressed('y') then
			self.controls.swap_weapons = true
		end
		self.controls.fire_1 = controller:down('r1')

		if controller:getActiveDevice() == "joystick" then
			jx = controller:get('r_right') - controller:get('r_left')
			jy = controller:get('r_down') - controller:get('r_up')
			if jx == 0 and jy == 0 then
				if self.facing == 'r' then
					mouse = {x = player.x + aim_distance - camera.x,
							 y = player.y - camera.y}
				else
					mouse = {x = player.x - aim_distance - camera.x,
							 y = player.y - camera.y}
				end
			else
				norm = math.sqrt(jx * jx + jy * jy)
				mouse = {x = player.x + mymath.round(aim_distance * (jx / norm)) - camera.x,
						 y = player.y + mymath.round(aim_distance * (jy / norm)) - camera.y}
			end
		else
			mouse = {x = love.mouse.getX(), y = love.mouse.getY()}
		end
		self.controls.aim_x, self.controls.aim_y = mouse.x + camera.x, mouse.y + camera.y

		-- face the cursor
		if self.controls.aim_x >= self.x then
			self.facing = 'r'
		else
			self.facing = 'l'
		end
	elseif self.ai.control == "enemy" then
		ai.process(self)
	end
end

function actor:is_touching_floor()
	return (mainmap:can_stand_on_pos(self.x - self.half_w, self.y + self.half_h + 1)
			or mainmap:can_stand_on_pos(self.x + self.half_w, self.y + self.half_h + 1))
end

function actor:is_touching_left()
	return (mainmap:grid_blocks_dir(map.grid_at_pos(self.x - self.half_w - 2), map.grid_at_pos(self.y - self.half_h), 'r')
			or mainmap:grid_blocks_dir(map.grid_at_pos(self.x - self.half_w - 2), map.grid_at_pos(self.y + self.half_h - 1), 'r'))
end

function actor:is_touching_right()
	return (mainmap:grid_blocks_dir(map.grid_at_pos(self.x + self.half_w + 1), map.grid_at_pos(self.y - self.half_h), 'l')
			or mainmap:grid_blocks_dir(map.grid_at_pos(self.x + self.half_w + 1), map.grid_at_pos(self.y + self.half_h - 1), 'l'))
end

function actor:is_on_ledge_left()
	return (self.touching_floor and not mainmap:grid_blocks_dir(map.grid_at_pos(self.x - self.half_w - 8), map.grid_at_pos(self.y + self.half_h + 1), 'u'))
end

function actor:is_on_ledge_right()
	return (self.touching_floor and not mainmap:grid_blocks_dir(map.grid_at_pos(self.x + self.half_w + 7), map.grid_at_pos(self.y + self.half_h + 1), 'u'))
end

function actor:update_location(dt)
	if self:check_status("dash_right") then
		dash_x = 1
	elseif self:check_status("dash_left") then
		dash_x = -1
	else
		dash_x = 0
	end

	if dash_x == 1 then
		self.dx = self.top_speed + (self.dash_speed - self.top_speed) * ((self.status.dash_right - ctime) / self.dash_dur)
		self.dy = 0
	elseif dash_x == -1 then
		self.dx = dash_x * (self.top_speed + (self.dash_speed - self.top_speed) * ((self.status.dash_left - ctime) / self.dash_dur))
		self.dy = 0
	else
		key_x, key_y = self.controls.x, self.controls.y

		if self.touching_floor then
			-- on the ground

			if key_x == 0 then
				self.dx = mymath.abs_subtract(self.dx, self.walk_friction * dt)
				self.dy = mymath.abs_subtract(self.dy, self.walk_friction * dt)
			else
				self.dx = self.dx + (self.walk_accel * key_x * dt)
			end

			-- ledge gravity
			if (self.dx < 0 and key_x ~= -1 and self:is_on_ledge_left()) or (self.dx > 0 and key_x ~= 1 and self:is_on_ledge_right()) then
				self.dx = mymath.abs_subtract(self.dx, self.walk_friction * dt)
			end

			if self.controls.jump == true then
				self:jump()
				spark_data.spawn("jumpburst", self.color, self.x, self.y + self.half_h, 0, 0, 0, 1, 1)
				audio.play('land')
			end
		else
			-- aerial

			if key_x ~= 0 then
				self.dx = self.dx + (self.air_accel * key_x * dt)
			end

			if self.controls.float and self.dy < 0 then
				self.dy = self.dy + (gravity * 0.5 * dt) -- magic floating
			else
				self.dy = self.dy + (gravity * dt)
			end
			if self.controls.jump == true and (self.flies or self.double_jumps > 0) and not self:check_status("dash_cooldown") then
				self:jump()
				if not self.flies then
					spark_data.spawn("dashburst", self.color, self.x, self.y, 0, 100, math.pi * 3 / 2, 1, 1)
					self.double_jumps = self.double_jumps - 1
					audio.play('dash')
				end
			end
		end
	end

	-- impose soft cap on horiz. speed
	if self.dx > self.top_speed then
		self.dx = math.max(self.top_speed, self.dx - 7 * self.dx * dt)
	elseif self.dx < -self.top_speed then
		self.dx = math.min(-self.top_speed, self.dx - 7 * self.dx * dt)
	end

	-- even if we failed to jump, clear the command
	self.controls.jump = false

	-- XXX shunt out of walls

	-- collide with the map tiles we're inside
	hit, mx, my, m_time, nx, ny = physics.map_collision_aabb_sweep(self, self.dx * dt, self.dy * dt)

	-- debug sparks
	-- if hit then spark_data.spawn("tripop", self.color, mx + self.w/2, my + self.h/2, 100 * nx, 100 * ny, 0, 1, 1) end

	if hit then
		if ny < -0.5 and self.dy > 200 and not self.touching_floor then
			spark_data.spawn("jumpburst", self.color, mx, my + self.half_h, 0, 0, 0, 1, 1)
			audio.play('land')
		end

		r = self.dx * ny - self.dy * nx

		self.dx = r * ny
		self.dy = r * (-nx)

		if m_time < 1 then
			-- now try continuing our movement along the new vector
			hit, mx, my, m_time, nx, ny = physics.map_collision_aabb_sweep({x = mx, y = my, half_h = self.half_h, half_w = self.half_w},
																		   self.dx * dt * (1 - m_time), self.dy * dt * (1 - m_time))
			if hit then

				r = self.dx * ny - self.dy * nx

				self.dx = r * ny
				self.dy = r * (-nx)
			end
		end
	end

	self.x = mx
	self.y = my

	-- check for stuff to do at our new position
	if self.y >= mainmap.death_line then self:die() end

	if self:is_touching_floor() then
		if not self.touching_floor then
			self.double_jumps = self.double_jumps_max
		end
		self.touching_floor = true
	else
		self.touching_floor = false
	end
end

function actor:jump()
	self.dy = -self.jump_speed
end

function actor:dash_left()
	self.status.dash_left = ctime + self.dash_dur
	self.status.dash_cooldown = ctime + self.dash_dur + self.dash_cooldown
	spark_data.spawn("dashburst", self.color, self.x, self.y, 100, 0, 0, -1, 1)
	audio.play('dash')
end

function actor:dash_right()
	self.status.dash_right = ctime + self.dash_dur
	self.status.dash_cooldown = ctime + self.dash_dur + self.dash_cooldown
	spark_data.spawn("dashburst", self.color, self.x, self.y, -100, 0, 0, 1, 1)
	audio.play('dash')
end

function actor:update_weapon(dt)
	self.cof = (self.weapon.cof_min + (self.weapon.cof_max - self.weapon.cof_min) *
				  (self.cof_factor / 100) ^ 2) / 100
	if self.controls.swap_weapons then
		self:swap_weapons()
	elseif self.shot_cooldown == 0 then
		if not self:check_status("reload") and (self.weapon.ammo == 0 or self.controls.reload) then
			self:reload()
		elseif self.controls.fire_1 and not self:check_status("reload") then
			self.weapon:fire(self, self.controls.aim_x, self.controls.aim_y);
		elseif self.cof_factor > 0 then
			self.cof_factor = math.max(0, self.cof_factor - 200 * dt)
		end
		self.controls.reload = false
	else
		self.shot_cooldown = math.max(0, self.shot_cooldown - dt)
	end

	self.controls.swap_weapons = false
end

function actor:reload()
	if self:check_status("reload") or self.weapon.ammo == self.weapon.ammo_max then
		return false
	else
		self:apply_status("reload", self.weapon.reload_time)
		return true
	end
end

function actor:swap_weapons()
	if self:check_status("reload") then
		self:end_status("reload", true)
	end
	w = self.weapon
	self.weapon = self.weapon2
	self.weapon2 = w
end

function actor:apply_status(s, dur)
	self.status[s] = dur + ctime
end

local status_complete_effect =
{
	["reload"] = function (self)
		self.weapon.ammo = self.weapon.ammo_max
	end
}

function actor:end_status(s, cancelled) -- if cancelled == true, skip the end effect
	if not cancelled then
		if status_complete_effect[s] then
			status_complete_effect[s](self)
		end
	end
	self.status[s] = nil
end

function actor:check_status(s)
	for i,v in pairs(self.status) do
		if i == s then
			if v < ctime then
				-- duration ran out
				self:end_status(s, false)
				return false
			else
				return true
			end
		end
	end
	return false
end

function actor:hurt(damage)
	self.hp = self.hp - damage
	if self.hp <= 0 then self:die() end
	self.flash_color = color.white
	self.flash_time = ctime + 0.5
	return self.hp
end

function actor:die()
	if self.class == "player" then
		-- love.event.push("quit") -- rip 2017
		self.x, self.y = 250, 250
		self.dx, self.dy = 0,0
		self.hp = 1000 -- debug. cheater
	else
		enemies[self.id] = nil
	end
end

-- in 20ths of a second for now
function actor:anim_time()
	return math.floor(10 * (ctime - self.anim_start))
end

function actor:sprite_anim()
	-- stand, run right, run left, dash right, dash left, jump, fall
	if self:check_status("dash_right") then
		return 'dr'
	elseif self:check_status("dash_left") then
		return 'dl'
	elseif not self.touching_floor then
		if self.dy <= 0 then
			return 'au'
		else
			return 'ad'
		end
	elseif self.controls.x == 1 then
		return 'wr'
	elseif self.controls.x == -1 then
		return 'wl'
	else
		return 'id'
	end
end

function actor:draw()
	s = self:sprite_anim()
	n = img.tile[self.sprite .. s .. self.facing]['n'] or 1

	if n ~= 1 then
		-- figure out which frame we want
		frame = 1 + self:anim_time() % n
	else
		frame = 1
	end

	if self.flash_time > ctime then
		love.graphics.setColor(color.mix(self.color, self.flash_color, 2 * (self.flash_time - ctime)))
	else
		love.graphics.setColor(self.color)
	end
	love.graphics.draw(img.tileset, img.tile[self.sprite .. s .. self.facing][frame],
					   camera.view_x(self) - 16, camera.view_y(self) - 24)

	if self.anim_last ~= s then
		self.anim_start = ctime
		self.anim_last = s
	end

	-- debug
	love.graphics.print(self.id, math.floor(self.x + self.half_w - camera.x), math.floor(self.y - self.half_h - camera.y))
end

return actor
