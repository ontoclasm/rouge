local beam = {}

function beam:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function beam:update(dt)
	if ctime > self.birth_time + self.duration then
		self:die()
	end
end

function beam:die()
	beams[self.id] = nil
end

function beam:draw()
	local k = 1 - (ctime - self.birth_time) / self.duration
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], k)
	love.graphics.setLineWidth(self.width * k)
	love.graphics.line(self.x1 - camera.x, self.y1 - camera.y, self.x2 - camera.x, self.y2 - camera.y)
	love.graphics.setColor(color.white)
	love.graphics.setLineWidth(1)
end

return beam
