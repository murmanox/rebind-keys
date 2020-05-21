local module = {}
module.__index = module


function module.new(parent, name)
	print("Init", name, "state")
	local self = {}
	setmetatable(self, module)
	
	self.name = name or "NoName"
	self.parent = parent
	
	return self
end


function module:OnEnable()
	print("	State enabled: " .. self.name)
end


function module:OnDisable()
	print("	State disabled: " .. self.name)
end


function module:Refresh()
	self:OnDisble()
	self:OnEnable()
end


return module