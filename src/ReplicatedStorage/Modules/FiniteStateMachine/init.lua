local module = {}
module.__index = module


function module.new(name)
	print("Init", name, "FSM")
	local self = setmetatable({}, module)
	
	self.currentState = nil
	self.previousState = nil
	
	return self
end


function module:SetState(State)
	print("Setting currentState to:", State.name)
	
	if State == self.currentState then
		print("	currentState is already set to", State.name)
		return
	end
	
	if self.currentState then
		self.currentState:OnDisable()
	end
	
	self.previousState = self.currentState
	self.currentState = State
	self.currentState:OnEnable()
end


return module
