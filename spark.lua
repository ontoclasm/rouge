local spark = {}

function spark:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function spark:update(dt)
	if ctime > self.birth_time + self.duration then
		self:die()
	end

	if self.gravity_multiplier then
		self.dy = self.dy + (self.gravity_multiplier * gravity * dt)
	end

	self.x = self.x + (self.dx * dt)
	self.y = self.y + (self.dy * dt)
end

function spark:die()
	sparks[self.id] = nil
end

function spark:draw()
	n = img.tile[self.sprite]['n'] or 1

	if n ~= 1 then
		-- figure out which frame we want
		frame = 1 + self:anim_time() % n
	else
		frame = 1
	end

	love.graphics.setColor(self.color)
	love.graphics.draw(img.tileset, img.tile[self.sprite][frame],
					   view_x(self), view_y(self), self.r, self.sx, self.sy,
					   self.center_x, self.center_y)
end

function spark:anim_time()
	return math.floor(10 * (ctime - self.birth_time))
end

return spark
