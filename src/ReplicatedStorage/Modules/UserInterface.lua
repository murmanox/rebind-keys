local player = game.Players.LocalPlayer
local PlayerGui = player:FindFirstChild("PlayerGui")
local ScreenGui = PlayerGui:FindFirstChild("ScreenGui")


local module = {
	Button = {},
	Message = {},
}

do	-- button
	function module.Button.darkenWhenHovered(guiObject)
		local frameDefaultColour = Color3.fromRGB(220, 220, 220)
		local frameHoveredColour = Color3.fromRGB(235, 235, 235)
		guiObject.BackgroundColor3 = frameDefaultColour
		
		local t = {}
		
		t.MouseEnter = guiObject.MouseEnter:Connect(function()
			guiObject.BackgroundColor3 = frameHoveredColour
		end)
	
		t.MouseLeave = guiObject.MouseLeave:Connect(function()
			guiObject.BackgroundColor3 = frameDefaultColour
		end)
		
		return t
	end
end


do -- message
	function module.Message.createMessage(title, str, parent, clickThrough)
		if clickThrough == nil then	clickThrough = true end
		local message = game.ReplicatedStorage.GUI.Message:Clone()
	
		message.Parent = parent
		message.Message.Title.Text.Text = title
		message.Message.Content.Text.Text = str
	
		if not clickThrough then
			local size = game.Workspace.CurrentCamera.ViewportSize
			message.TransparentBackground.Size = UDim2.new(0, size.X, 0, size.Y)
		end
				
		return message.Message
	end
	
	
	function module.Message.destroyMessage(msg)
		msg.Parent.Parent.Parent:Destroy()
	end
end


return module
