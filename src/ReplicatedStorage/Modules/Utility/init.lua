local module = {}

if not script:GetChildren() then
	return module
end

--print("Utility functions:")
for _, child in pairs(script:GetChildren()) do
	--print("	" .. child.Name)
	module[child.Name] = require(child)
end


function module.tableConcat(t1, t2)
	local t = t1
	
	for _, tbl in pairs(t2) do
		for k, v in pairs(tbl) do
			table.insert(t, v)
		end
	end
	
	return t
end


return module
