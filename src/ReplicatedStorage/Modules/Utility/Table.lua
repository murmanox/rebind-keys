local module = {}


function module.copyTable(tbl)
	local t = {}
	
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			t[k] = module.copyTable(v)
		else
			t[k] = v
		end
	end
	
	return t
end


function module.mergeTables(t1, t2, copy, iter)
	-- merge t2 into t1, only overwriting if there is no data in t1 (nil) 
    
    iter = iter or 0
    copy = copy or true
    
    if iter == 0 then
        t1 = module.copyTable(t1)
        if copy then
            t2 = module.copyTable(t2)
        end
    end
    
	for k, v in pairs(t2) do
		if t1[k] == nil then
            t1[k] = v
		else
			-- value is found in t1
			if type(t1[k]) == "table" then
				module.mergeTables(t1[k], v, false, iter + 1)
			end
		end
    end
    
    return t1
end


function module.printTable(tbl, indent)
	if not indent then indent = 0 end

	for k, v in pairs(tbl) do
	    local formatting = string.rep("        ", indent) .. k .. ": "
	    if type(v) == "table" then
		    print(formatting)
		    module.printTable(v, indent+1)
	    else
	    	print(formatting .. tostring(v))
	    end
	end
end


function module.dunpack(tbl)
    local t = {}
    for k, v in pairs(tbl) do
       table.insert(t, v) 
    end
    return unpack(t)
end


return module
