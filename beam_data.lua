local beam_data = {}

function beam_data.spawn(x1, y1, x2, y2, color_name, width, duration)
	local pid = idcounter.get_id("beam")
	beams[pid] = beam:new({
		id = pid,
		x1 = x1, y1 = y1, x2 = x2, y2 = y2,
		color = color[color_name], width = width, duration = duration
	})

	-- for i, v in pairs(shot_data[class]) do
	-- 	shots[pid][i] = v
	-- end

	beams[pid].birth_time = ctime

	-- if shots[pid]["duration_variance"] then
	-- 	shots[pid]["duration"] = shots[pid]["duration"] + shots[pid]["duration_variance"] * love.math.random()
	-- end

	return pid
end

return beam_data
