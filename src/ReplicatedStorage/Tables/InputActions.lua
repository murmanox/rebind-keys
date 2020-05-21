local actions = {}

actions.actions = {
	"Forward", "Backward", "Left", "Right", "Jump", "Inventory", "Interact", "Menu"
}

actions.name = {
	Forward = "Forward",
	Backward = "Backward",
	Left = "Left",
	Right = "Right",
	Jump = "Jump",
	Inventory = "Inventory",
	Interact = "Interact",
	Menu = "Settings",
}

for k, v in pairs(actions.name) do
	actions.name[v] = k
end

return actions
