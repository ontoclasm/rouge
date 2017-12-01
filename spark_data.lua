local spark_data = {}

function spark_data.spawn(class, color, x, y, dx, dy, r, sx, sy)
	local pid = idcounter.get_id("spark")
	sparks[pid] = spark:new({
		id = pid,
		color = color, birth_time = ctime,
		x = x, y = y, dx = dx, dy = dy, r = r, sx = sx, sy = sy
	})

	for i, v in pairs(spark_data[class]) do
		sparks[pid][i] = v
	end

	return pid
end

spark_data["dashburst"] =
{
	class = "dashburst",
	sprite = "dashburst", center_x = 32, center_y = 16,
	duration = 0.4
}

spark_data["jumpburst"] =
{
	class = "jumpburst",
	sprite = "jumpburst", center_x = 16, center_y = 32,
	duration = 0.4
}

spark_data["tripop"] =
{
	class = "tripop",
	sprite = "tripop", center_x = 16, center_y = 16,
	duration = 0.4
}

return spark_data
