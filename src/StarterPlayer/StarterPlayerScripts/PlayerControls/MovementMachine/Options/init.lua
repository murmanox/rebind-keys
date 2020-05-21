local State = require(game.ReplicatedStorage.Modules.FiniteStateMachine.State)
local SettingsMenu = require(script.GUI)

local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

local module = {}
module.__index = module
setmetatable(module, State)


function module.new(parent)
	local self = State.new(parent, "Options")
	setmetatable(self, module)
	
	self.parent = parent
	self.connections = {}
	self.boundActions = {}
	
	self:initGui()
	
	return self
end


function module:initGui()
	self.menu, self.menuItems = SettingsMenu.new(
		self.parent,	-- statemachine
		self.parent.Controls.getActionKeyPairs()	-- items
	)
end


function module:OnEnable()
	
	-- code for handling rebinding keys should be here
	self.menu.Visible = true
	
	bindKeys(self)
	
	local closeButton = self.menuItems.closeButton
	table.insert(self.connections, closeButton.MouseButton1Click:Connect(function()
		setPreviousState(self)
	end))
end


local function bindAction(str, func, display, ...)	
	CAS:BindAction(
		str,
		func,
		display,
		unpack({...})
	)
	
	return str
end


function bindKeys(self)
	local StateMachine = self.parent
	local Controls = StateMachine.Controls
	
	table.insert(self.boundActions, bindAction(
		"Option",
		function(...)
			handleOptionKeyPress(self, ...)
		end,
		false,
		unpack(Controls.getOptionKeys())
	))
end


function unbindActions(self)
	for k, v in pairs(self.boundActions) do
		CAS:UnbindAction(v)
		self.boundActions[k] = nil
	end
end


function handleOptionKeyPress(self, actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		-- check player not rebinding key
		local playerBindingKey = game.StarterPlayer.StarterPlayerScripts.Variables.BindingKey.Value
		if not playerBindingKey then
			setPreviousState(self)
		end
	end
end


function setPreviousState(self)
	local StateMachine = self.parent
	local States = StateMachine.States
	StateMachine:SetState(StateMachine.previousState)
end


function module:OnDisable()
	self.menu.Visible = false
	unbindActions(self)
	for k, v in pairs(self.connections) do
		self.connections[k] = v:Disconnect()
	end
end


return module
