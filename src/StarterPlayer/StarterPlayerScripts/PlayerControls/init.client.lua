local Settings = require(script.PlayerSettings)
local MovementMachine = require(script.MovementMachine)

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local Humanoid = char:WaitForChild("Humanoid")

local Movement = MovementMachine.new(Settings)
