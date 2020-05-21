local utility = require(game.ReplicatedStorage.Modules.Utility)
local Walking = require(script.Walking)
local Shopping = require(script.Shopping)
local Options = require(script.Options)
local FiniteStateMachine = require(game.ReplicatedStorage.Modules.FiniteStateMachine)


local module = {}
module.__index = module
setmetatable(module, FiniteStateMachine)


function module.new(Settings)
	local self = FiniteStateMachine.new("movement")
	setmetatable(self, module)
	
	self.Settings = Settings
	self.Controls = self.Settings.PlayerSettings.Controls
	
	self.States = {
		Walking = Walking.new(self),
		Shopping = Shopping.new(self),
		Options = Options.new(self)
	}
	
	self:SetState(self.States.Walking)
	
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


function module:SetControls(controls)
	
end


function GetKeysFromList(tbl)
	local t = {}
	
	for k, v in pairs(tbl) do
		if v then
			table.insert(t, v)
		end
	end
	
	return t
end


function initControls(controls)
	local t = {}
	
	for k, v in pairs(controls) do
		t[k] = {
			Value = Enum.PlayerActions["Character"..k],
			Keys = v
		}
	end
	
	return t
end


return module
