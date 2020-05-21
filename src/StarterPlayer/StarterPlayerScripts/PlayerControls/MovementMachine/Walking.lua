local State = require(game.ReplicatedStorage.Modules.FiniteStateMachine.State)

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

local player = game.Players.LocalPlayer

local module = {}
module.__index = module
setmetatable(module, State)

-- TODO: Custom gamepad deadzone and movement sensitivity
local ZERO_VECTOR = Vector2.new(0, 0)
local GAMEPAD_DEADZONE = 0.2
local ActionVectorMap = {
	[Enum.PlayerActions.CharacterForward] = Vector2.new(0, -1),
	[Enum.PlayerActions.CharacterLeft] = Vector2.new(-1, 0),
	[Enum.PlayerActions.CharacterBackward] = Vector2.new(0, 1),
	[Enum.PlayerActions.CharacterRight] = Vector2.new(1, 0),
}
local actionMap = {
	Forward = Enum.PlayerActions.CharacterForward,
	Backward = Enum.PlayerActions.CharacterBackward,
	Left = Enum.PlayerActions.CharacterLeft,
	Right = Enum.PlayerActions.CharacterRight,
	Jump = Enum.PlayerActions.CharacterJump,
}

function module.new(parent)
	local self = State.new(parent, "Walking")
	setmetatable(self, module)
	
	self.MoveVector = ZERO_VECTOR
	self.GamepadMoveVector = ZERO_VECTOR
	self.connections = {}
	self.pressedKeys = {}
	self.isJumping = false
	self.canJump = false
	
	local character = player.Character
	local humanoid = character.Humanoid
	
	character.Humanoid.StateChanged:Connect(function(old, new)
		local groundedState = {
			[Enum.HumanoidStateType.Landed] = true,
			[Enum.HumanoidStateType.Running] = true,
			[Enum.HumanoidStateType.RunningNoPhysics] = true,
		}
		if groundedState[new] then
			self.canJump = true
		end
	end)
	
	RunService.RenderStepped:Connect(function(dt)
		self:onRenderStepped(dt)
	end)
		
	return self
end


local lastJumpTime = 0
function module:onRenderStepped(dt)
	local moveVector = self.MoveVector + self.GamepadMoveVector
	local clampedMoveVector = Vector3.new(
		math.clamp(moveVector.X, -1, 1),
		0,
		math.clamp(moveVector.Y, -1, 1)
	)
	
	if not player.Character then
		return
	end
	
	player:move(clampedMoveVector, true)
	
	local currentTime = tick()
	if self.isJumping and self.canJump and (currentTime - lastJumpTime) > 0.2 then
		lastJumpTime = currentTime
		player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		self.canJump = false
	end
end


local function initControlSettings(controls)
	--[[
	local controlSettings = self.parent.Settings.PlayerSettings.ControlSettings
	GAMEPAD_DEADZONE = controlSettings.AnalogueDeadZone or GAMEPAD_DEADZONE
	]]
end


local ControlActionMap = {}
function module:OnEnable()
	local StateMachine = self.parent
	local State = StateMachine.States
	local Controls = StateMachine.Controls
	
	initControlSettings(Controls)
	
	ControlActionMap = {}
	for action, v in pairs(Controls.Movement) do
		for _, key in pairs(v) do
			ControlActionMap[key] = actionMap[action]
		end
	end
	
	CAS:BindAction(
		"Walk",
		function(...)
			self:handleInput(...)
		end,
		false,
		unpack(Controls.getWalkKeys())
	)
	CAS:BindAction(
		"Jump",
		function(...)
			self:handleInput(...)
		end,
		false,
		unpack(Controls.getJumpKeys())
	)
	CAS:BindAction(
		"Option",
		function(...)
			self:onOptionsKeyPressed(...)
		end,
		false,
		unpack(Controls.getOptionKeys())
	)
	
	table.insert(self.connections, UIS.InputBegan:Connect(function(input)
		local key = input.KeyCode
		
		if key == Enum.KeyCode.R then
			self.parent:SetState(self.parent.States.Shopping)
		end
	end))
	
	-- This handles keys already pressed when the state changes
	table.foreach(UIS:GetKeysPressed(), function(k, v)
		-- TODO: optimise this with tables
		if table.find(Controls.getWalkKeys(), v) then
			self:handleInput("Walk", Enum.UserInputState.Begin, v)
		elseif table.find(Controls.getJumpKeys(), v) then
			self:handleInput("Jump", Enum.UserInputState.Begin, v)
		end
	end)
end


function module:onOptionsKeyPressed(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		self.parent:SetState(self.parent.States.Options)
	end
end


function module:handleInput(actionName, inputState, inputObject)
	local key = inputObject.KeyCode
	local playerAction = ControlActionMap[key]
	local gamepad = string.sub(string.split(tostring(inputObject.UserInputType), ".")[3], 1, -2) == "Gamepad"
	
	if actionName == "Walk" then
		if gamepad then
			self:handleGamepadMovement(actionName, inputState, inputObject)
		else
			self:handleMovement(actionName, inputState, inputObject, playerAction)
		end
	elseif actionName == "Jump" then
		self:handleJump(actionName, inputState, inputObject, playerAction)
	end
end


function module:handleGamepadMovement(actionName, inputState, inputObject)
	local pos = inputObject.Position
	
	if pos.Magnitude >= GAMEPAD_DEADZONE then
		self.GamepadMoveVector = Vector2.new(pos.X, -pos.Y)
	else
		self.GamepadMoveVector = ZERO_VECTOR
	end
end


function module:handleMovement(actionName, inputState, inputObject, playerAction)
	local key = inputObject.KeyCode
	
	local keyDirection = ActionVectorMap[playerAction]
	if inputState == Enum.UserInputState.Begin then
		self.pressedKeys[key] = true
		self.MoveVector = self.MoveVector + keyDirection
	else
		if self.pressedKeys[key] then
			self.pressedKeys[key] = nil
			self.MoveVector = self.MoveVector - keyDirection
		end
	end
end


function module:handleJump(actionName, inputState, inputObject, playerAction)
	if inputState == Enum.UserInputState.Begin then
		self.isJumping = true
	else
		self.isJumping = false
	end
end


function module:OnDisable()
	-- TODO: optimise action names using table
	CAS:UnbindAction("Walk")
	CAS:UnbindAction("Jump")
	CAS:UnbindAction("Option")
	self.MoveVector = Vector2.new(0, 0)
	self.pressedKeys = {}
	for k, v in pairs(self.connections) do
		self.connections[k] = v:Disconnect()
	end
end


return module