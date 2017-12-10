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

return files
