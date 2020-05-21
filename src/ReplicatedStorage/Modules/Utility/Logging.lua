function logging(rights)
	
	return function(level, ...)
		if level <= rights then
			print(...)
		end
	end
end


return logging
