local actions = require(game.ReplicatedStorage.Tables.InputActions)
local tableUtil = require(game.ReplicatedStorage.Modules.Utility.Table)
local StringUtil = require(game.ReplicatedStorage.Modules.Utility.String)

local menu = script.Parent
local properties = menu.PropertiesPanel.Container

local AudioMenu = properties.Frame.AudioMenu
local KeybindMenu = properties.Frame.SettingsMenu

local Tabs = menu.Tabs.Container
local AudioTab = Tabs.AudioSettings.TextButton
local KeybindTab = Tabs.KeybindSettings.TextButton

local tabMenuMap = {
	[AudioTab] = AudioMenu,
	[KeybindTab] = KeybindMenu,
}


local function darkenWhenHovered(guiObject)
	local frameDefaultColour = Color3.fromRGB(255, 255, 255)
	local frameHoveredColour = Color3.fromRGB(235, 235, 235)
	guiObject.BackgroundColor3 = frameDefaultColour
	
	guiObject.MouseEnter:Connect(function()
		guiObject.BackgroundColor3 = frameHoveredColour
	end)

	guiObject.MouseLeave:Connect(function()
		guiObject.BackgroundColor3 = frameDefaultColour
	end)
end


local currentMenu = AudioMenu
local function initButton(button)
	button.MouseButton1Click:Connect(function()
		local menu = tabMenuMap[button]
		
		if currentMenu == menu then
			return
		end
		
		currentMenu.Visible = false
		menu.Visible = true
		currentMenu = menu
	end)
end


initButton(AudioTab)
initButton(KeybindTab)

darkenWhenHovered(AudioTab.Parent)
darkenWhenHovered(KeybindTab.Parent)

menu.Visible = false
