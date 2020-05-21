--[[
	Holds the player's settings data for the current session. When the player leaves
	the game this data should be saved to the data store.
	
	This data will consist of everything found in the settings menu, such as:
	Keybindings,
	Audio settings:
		(music volume),
	Gamepad settings:
		(deadzone, sensitivity),
	Gameplay settings:
		(hold button to skip text, text display speed),
]]--

local actions = require(game.ReplicatedStorage.Tables.InputActions)
local tableUtil = require(game.ReplicatedStorage.Modules.Utility.Table)

local module = {}
local KeyCodeValueMap = {}

local playerSettingsData = {}

for _, v in pairs(Enum.KeyCode:GetEnumItems()) do
	KeyCodeValueMap[v.Value] = v
end


function KeyCodeFromValue(v)
	return KeyCodeValueMap[v] or v
end


local function newControl(kb1, kb2, xbx)
	local t = {}
	
	t.Keyboard1 = kb1
	t.Keyboard2 = kb2
	t.Controller = xbx
	
	return t
end


-- simulating data store data for now
playerSettingsData = {
	Audio = {
		MusicVolume = 0.5,
		EffectsVolume = 1,
		VoiceVolume = 0,
	},
	Controls = {
		Movement = {
			Forward = newControl(Enum.KeyCode.E.Value, Enum.KeyCode.W.Value, Enum.KeyCode.Thumbstick1.Value),
			Backward = newControl(Enum.KeyCode.D.Value, nil, Enum.KeyCode.Thumbstick1.Value),
		}
	},
}


local defaultSettings = {
	Audio = {
		MusicVolume = 1,
	},
	Controls = {
		Movement = {
			Forward = newControl(Enum.KeyCode.E, nil, Enum.KeyCode.Thumbstick1),
			Backward = newControl(Enum.KeyCode.D, nil, Enum.KeyCode.Thumbstick1),
			Left = newControl(Enum.KeyCode.S, nil, Enum.KeyCode.Thumbstick1),
			Right = newControl(Enum.KeyCode.F, nil, Enum.KeyCode.Thumbstick1),
			Jump = newControl(Enum.KeyCode.Space, nil, Enum.KeyCode.ButtonA),
		},
		Action = {
			Inventory = newControl(Enum.KeyCode.R, Enum.KeyCode.I, Enum.KeyCode.ButtonSelect),
			Interact = newControl(Enum.KeyCode.G, nil, Enum.KeyCode.ButtonX),
		},
		Option = {
			Menu = newControl(Enum.KeyCode.O, nil, Enum.KeyCode.ButtonSelect)
		}
	},
	ControlSettings = {
		AnalogueDeadZone = 0.2,		-- movement deadzone
		AnalogueSensitivity = 1,	-- movement sensitivity
	},
	Gameplay = {
		
	}
}


local sessionData
local function getPlayerData()
	
	if not sessionData then
		-- get data from datastore handler
		local data
		local success, errormsg = pcall(function()
			data = playerSettingsData
		end)
		
		-- merge player settings over default settings
		if data then
			sessionData = tableUtil.mergeTables(data, defaultSettings)
		else
			-- new player or datastores not working
			sessionData = defaultSettings
		end
	end
	
	return sessionData
end


local function getPlayerControls()
	local data = getPlayerData().Controls
	
	-- convert integers into Enums
	for _, category in pairs(data) do
		for _, action in pairs(category) do
			for k, v in pairs(action) do
				action[k] = KeyCodeFromValue(v)
			end
		end
	end
	
	tableUtil.printTable(data)
	
	return data
end


local function getPlayerAudio()
	local data = getPlayerData().Audio
	tableUtil.printTable(data)
	return data
end


local function getPlayerControlSettings()
	
end


local function getPlayerGameplay()
	
end


module.PlayerSettings = {
	--Audio = getPlayerAudio(),
	Controls = getPlayerControls(),
	--ControlSettings = getPlayerControlSettings(),
	--Gameplay = getPlayerGameplay()
}


function getKeyTables(tbl)
	local t = {}
	
	for _, action in pairs(tbl) do
		if type(action) == "table" then
			for k, keyTable in pairs(action) do
				if type(keyTable) == "table" then
					--print("inserting", k)
					t[k] = keyTable
				end
			end
		end
	end
	
	return t
end


function module.PlayerSettings.SetControl(action, name, key)
	
	local t = getKeyTables(module.PlayerSettings.Controls)
	action = actions.name[action]
	t[action][name] = key
end


function module.PlayerSettings.Controls.getActionKeyPairs() -- issue with option
	local t = {}
	
	for _, category in pairs(module.PlayerSettings.Controls) do
		if type(category) ~= "function" then
			for name, action in pairs(category) do
				t[name] = action
			end
		end
	end
	
	return t
end


function getKeys(...)
	-- accepts tables with keys and returns a concatenated,
	-- non-repeating list of all keys in those lists.
	local args = {...}
	local t = {}
	
	for _, tbl in pairs(args) do
		for _, key in pairs(tbl) do
			if key and not table.find(t, key) then
				table.insert(t, key)
			end
		end
	end
	
	return t
end


-- TODO: find a way to cache this output on calls between changes.
function module.PlayerSettings.Controls.getMovementKeys()
	return getKeys(tableUtil.dunpack(module.PlayerSettings.Controls.Movement))
end


function module.PlayerSettings.Controls.getWalkKeys()
	return getKeys(
		module.PlayerSettings.Controls.Movement.Forward,
		module.PlayerSettings.Controls.Movement.Backward,
		module.PlayerSettings.Controls.Movement.Left,
		module.PlayerSettings.Controls.Movement.Right
	)
end


function module.PlayerSettings.Controls.getJumpKeys()
	return getKeys(module.PlayerSettings.Controls.Movement.Jump)
end


function module.PlayerSettings.Controls.getOptionKeys()
	return getKeys(
		module.PlayerSettings.Controls.Option.Menu
	)
end


function module.PlayerSettings.Controls.getActionKeys()
	return getKeys(
		module.PlayerSettings.Controls.Action.Inventory,
		module.PlayerSettings.Controls.Action.Interact
	)
end


--tableUtil.printTable(module.playerSettings.Controls.getWalkingKeys())
--tableUtil.printTable(module.playerSettings.Controls)
--tableUtil.printTable(module.playerSettings.Controls.getMovementKeys())


return module
