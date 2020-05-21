local State = require(game.ReplicatedStorage.Modules.FiniteStateMachine.State)

local UIS = game:GetService("UserInputService")

local module = {}
module.__index = module
setmetatable(module, State)


function module.new(parent)
	local self = State.new(parent, "Shopping")
	setmetatable(self, module)
	
	self.connections = {}
	
	return self
end


function module:OnEnable()
	table.insert(self.connections, UIS.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.R then
			self.parent:SetState(self.parent.previousState)
		end
	end))
end


function module:OnDisable()
	for k, v in pairs(self.connections)	do
		self.connections[k] = v:Disconnect()
	end
end


return module
