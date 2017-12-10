local files = {}
-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function files.file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
end

function files.lines_from(file)
	lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end

function files.parse_map_file(file, w, h)
	local f = files.lines_from(file)
	local m = map:new(w, h)
	for j,str in ipairs(f) do
		i = 1
		for c in str:gmatch"." do
			if c == "o" then
				m:set_block("wall", i, j)
			elseif c == "-" then
				m:set_block("air", i, j)
			elseif c == "d" then
				m:set_block("slope_45", i, j)
			elseif c == "b" then
				m:set_block("slope_-45", i, j)
			elseif c == "e" then
				m:set_block("slope_45_a", i, j)
			elseif c == "f" then
				m:set_block("slope_-45_a", i, j)
			elseif c == "E" then
				m:set_block("slope_45_b", i, j)
			elseif c == "F" then
				m:set_block("slope_-45_b", i, j)
			elseif c == "g" then
				m:set_block("slope_23_a", i, j)
			elseif c == "h" then
				m:set_block("slope_-23_a", i, j)
			elseif c == "G" then
				m:set_block("slope_23_b", i, j)
			elseif c == "H" then
				m:set_block("slope_-23_b", i, j)
			else
				m:set_block("void", i, j)
			end
			i = i+1
		end
	end
	return m
end

return files
