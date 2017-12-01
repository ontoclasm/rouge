local idcounter = {enemy = 0, shot = 0, weapon = 0, spark = 0}

function idcounter.get_id(type)
	idcounter[type] = idcounter[type] + 1
	return idcounter[type]
end

return idcounter
