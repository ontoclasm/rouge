local shot = {}

function shot:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function shot:update(dt)
	-- if we have a special update function, run it
	if self.f ~= nil then self.f(self, dt) end

	if self.duration ~= nil then
		if ctime > self.birth_time + self.duration then
			self:die()
		end
	end

	-- collide: first with tiles, then mobs
	hit, mx, my, mt = physics.map_collision_aabb_sweep(self, self.dx * dt, self.dy * dt)

	if self.faction == "player" then
		for j,z in pairs(enemies) do
			-- if math.abs(self.x - z.x) <= 64 and math.abs(self.y - z.y) <= 64 then
			hx, hy, ht = physics.collision_aabb_sweep(self, z, self.dx * dt, self.dy * dt)
			if ht and ht < mt then
				hit = {"enemy", j}
				mt, mx, my = ht, hx, hy
			end
			-- end
		end
	elseif self.faction == "enemy" then
		hx, hy, ht = physics.collision_aabb_sweep(self, player, self.dx * dt, self.dy * dt)
		if ht and ht < mt then
			hit = {"player"}
			mt, mx, my = ht, hx, hy
		end
	end

	self.x = mx
	self.y = my

	-- now, if we hit something, explode
	if hit then
		if hit[1] == "block" then
			if mainmap:block_at(hit[2], hit[3]) == "void" then
				self:die(true)
			else
				mainmap:hurt_block(hit[2], hit[3], self.damage)
				self:die()
				audio.play('hit2')
			end
		elseif hit[1] == "enemy" then
			enemies[hit[2]]:hurt(self.damage)
			self:die()
			audio.play('hit1')
			camera.shake(10)
		elseif hit[1] == "player" then
			player:hurt(self.damage)
			self:die()
			audio.play('hit1')
			camera.shake(10)
		end
	end
end

function shot:die(silent)
	if not silent then
		spark_data.spawn("tripop", self.color, self.x + self.w/2, self.y + self.h/2,
						 0, 0, math.pi * love.math.random(0,1) / 2, -1 + 2 * love.math.random(0,1), -1 + 2 * love.math.random(0,1))
	end
	shots[self.id] = nil
end

function shot:draw()
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", view_x(self), view_y(self), self.w, self.h)
end

return shot