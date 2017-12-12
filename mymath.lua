local mymath = {}

local dx, dy, v

function mymath.average_angles(...)
	dx, dy = 0,0
	for i=1,select('#',...) do local a= select(i,...) x, y = x+math.cos(a), y+math.sin(a) end
	return math.atan2(y, x)
end

function mymath.angle_difference(source, target)
	local a = target - source

	if (a > math.pi) then
		a = a - math.pi * 2
	elseif (a < -math.pi) then
		a = a + math.pi * 2
	end

	return a
end

function mymath.clamp(low, n, high) return math.min(math.max(low, n), high) end

function mymath.vector_length(x, y) return (x^2+y^2)^0.5 end

function mymath.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function mymath.collision(a, b)
	return a.x < b.x+b.w and
		   b.x < a.x+a.w and
		   a.y < b.y+b.h and
		   b.y < a.y+a.h
end

local window_border = 32
function mymath.in_window(x, y)
	return (camera.x - window_border <= x and x < (camera.x + window.w + window_border)
			and camera.y - window_border <= y and y < (camera.y + window.h + window_border))
end

function mymath.abs_subtract(a, d)
	-- moves towards zero by d, d>=0
	if d >= math.abs(a) then return 0
	elseif a>0 then return a-d
	else return a+d
	end
end

function mymath.sign(n) return n>0 and 1 or n<0 and -1 or 0 end

function mymath.round(n) return math.floor(n + 0.5) end

function mymath.abs_floor(n)
	if n >= 0 then return math.floor(n)
	else return math.ceil(n) end
end

function mymath.abs_ceil(n)
	if n >= 0 then return math.ceil(n)
	else return math.floor(n) end
end

function mymath.one_chance_in(n) return love.math.random(1,n) == 1 end

function mymath.random_spread(angle, spread) return angle + (spread * (2 * love.math.random() - 1)) end

return mymath
