local StringUtil = require(game.ReplicatedStorage.Modules.Utility.String)
local UI = require(game.ReplicatedStorage.Modules.UserInterface)
local Transition = require(game.ReplicatedStorage.Modules.Transitions)

-- I want to avoid using WaitForChild here as it can cause errors when requesting module.
local player = game.Players.LocalPlayer
local PlayerGui = player:FindFirstChild("PlayerGui")
local ScreenGui = PlayerGui:FindFirstChild("ScreenGui")

local connections = {}

local module = {}
module.__index = module


do	-- init
	function module.new(StateMachine, items)
		local self = setmetatable({}, module)
		
		PlayerGui = PlayerGui or player:WaitForChild("PlayerGui")
		ScreenGui = ScreenGui or PlayerGui:WaitForChild("ScreenGui")
		local gui = ScreenGui.SettingsMenu
		
		self.gui = gui:Clone()
		self.gui.Parent = ScreenGui
		self.StateMachine = StateMachine
		
		initSettingsMenu(self, items)
		
		local tbl = {
			closeButton = self.gui.PropertiesPanel.Container.Header.CloseButton.TextButton
		}
		
		return self.gui, tbl
	end
	
	
	function initSettingsMenu(self, keys)
		local actions = require(game.ReplicatedStorage.Tables.InputActions)
		local properties = self.gui.PropertiesPanel.Container
		local location = properties.Frame.SettingsMenu
		local template = location.Binding:Clone()
		location.Binding:Destroy()
		
		for i, action in pairs(actions.actions) do
			local binding = template:Clone()
			local container = binding.Container
			binding.Parent = location
			binding.LayoutOrder = i
			
			binding.Container.Action.TextButton.ActionName.Text = actions.name[action]
			
			for k, v in pairs(keys[action]) do
				container[k].TextButton.TextLabel.Text = StringUtil.textFromEnum(v)
			end
			
			initContainer(self.StateMachine, container)
					
			binding.Visible = true
		end
	end
	
	
	function initContainer(StateMachine, container)
		local Buttons = {container.Keyboard1, container.Keyboard2}
		
		for _, button in pairs(Buttons) do
			connections[button] = UI.Button.darkenWhenHovered(button)
			captureInputOnLeftClick(StateMachine, button.TextButton)
		end
	end
end


local function disconnectAll(tbl)
	for k, v in pairs(tbl) do
		tbl[k] = v:Disconnect()
	end
end


function onMouseClick(StateMachine, guiObject)
	local UIS = game:GetService("UserInputService")
	local button = guiObject
	local label = button.TextLabel
	
	local previousText = label.Text
	label.Text = ""
	
	local event = Instance.new("BindableEvent")
	-- capture input
	local c = UIS.InputBegan:Connect(function(input)
		local key = input.KeyCode
		
		local inputType = input.UserInputType
		if inputType == Enum.UserInputType.Keyboard then
			if key == Enum.KeyCode.Backspace then
				key = nil
			end
			button.TextLabel.Text = StringUtil.textFromEnum(key)
			-- change key on server?
			
			-- change key in PlayerSettings
			if previousText ~= button.TextLabel.Text then
				local action = guiObject.Parent.Parent.Action.TextButton.ActionName.Text
				local inputType = guiObject.Parent.Name
				
				StateMachine.Settings.PlayerSettings.SetControl(
					action,
					inputType,
					key
				)
			end
			event:Fire()
		end	
	end)
	
	
	-- disconnect mouse events
	disconnectAll(connections[guiObject.Parent])
	event.Event:Wait()
	c = c:Disconnect()
	
	-- reconnect mouse events
	UI.Button.darkenWhenHovered(guiObject.Parent)
end


local playerBindingKey = game.StarterPlayer.StarterPlayerScripts.Variables.BindingKey
function captureInputOnLeftClick(StateMachine, guiObject)
	guiObject.MouseButton1Click:Connect(function()
		playerBindingKey.Value = true
		local closeGuiEvent = Instance.new("BindableEvent")
		
		local action = guiObject.Parent.Parent.Action.TextButton.ActionName.Text
		local message = UI.Message.createMessage(action, "PRESS ANY KEY TO REBIND", ScreenGui, false)
		
		Transition.In.VerticalWipeFromCentre(message, 0.2)
		
		local coMouse = coroutine.wrap(function()
			onMouseClick(StateMachine, guiObject)
			closeGuiEvent:Fire()
		end)
		coMouse()
		
		closeGuiEvent.Event:Wait()
		playerBindingKey.Value = false
		Transition.Out.VerticalWipe(message, 0.2)
	end)
end


return module
