local module = {}


function module.new(init)
	local self = {
		value = nil,
		set = function(tbl, value)
			tbl.value = value
			print("setting value" .. value)
		end,
		get = function(tbl)
			return tbl.value
		end
	}
	
	if init then
		self.value = init
	end
	
	return self
end


return module
