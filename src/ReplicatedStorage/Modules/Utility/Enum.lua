function enum(arr)
	local objects = {}
	
	for id, name in pairs(arr) do
		local obj = {
			id=id,
			name=name,
		}
		
		objects[name] = obj
	end
	
	return objects
end


return enum
