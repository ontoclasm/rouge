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

	if sparks[pid]["duration_variance"] then
		sparks[pid]["duration"] = sparks[pid]["duration"] + sparks[pid]["duration_variance"] * love.math.random()
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

spark_data["spark"] =
{
	class = "spark",
	sprite = "spark", center_x = 16, center_y = 16,
	duration = 0.2,
	duration_variance = 0.5,
	gravity_multiplier = 0.3,
}

spark_data["chunk"] =
{
	class = "chunk",
	sprite = "chunk", center_x = 16, center_y = 16,
	duration = 0.5,
	duration_variance = 0.5,
	gravity_multiplier = 0.5,
}

spark_data["explosion"] =
{
	class = "explosion",
	sprite = "explosion", center_x = 32, center_y = 32,
	duration = 0.2
}

return spark_data
