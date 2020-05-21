local module = {}

function module.textFromEnum(str)
	if str then
		str = string.split(tostring(str), ".")[3]
	else
		str = ""
	end
	
	return str	
end

return module
