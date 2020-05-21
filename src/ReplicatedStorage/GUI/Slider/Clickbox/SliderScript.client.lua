local Clickbox = script.Parent
local Slider = Clickbox.Parent
local Value = Slider.Value
local Bar = Clickbox.Slider.Bar


Value.Changed:Connect(function(new)
	if new < 0 or new > 100 then
		Value.Value = math.clamp(new, 0, 100)
		return
	end
	
	Bar.Position = UDim2.new(new / 100, 0, Bar.Position.Y.Scale, 0)
end)


local function temp(x)
	local position = math.floor(x - Clickbox.AbsolutePosition.X)
	local percentage = math.floor((position / Clickbox.AbsoluteSize.X) * 100)
	percentage = math.clamp(percentage, 0, 100)
	Value.Value = percentage
end


Clickbox.MouseButton1Down:Connect(function(x)
	local connections = {}
	local UIS = game:GetService("UserInputService")
	
	temp(x)
	
	connections[1] = UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local x = input.Position.X
			temp(x)
		end
	end)
	
	connections[2] = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			for k, v in pairs(connections) do
				connections[k] = v:Disconnect()
			end
		end
	end)
end)


--[[Clickbox.MouseWheelForward:Connect(function(x)
	Value.Value = Value.Value + 1
end)

Clickbox.MouseWheelBackward:Connect(function(x)
	Value.Value = Value.Value - 1
end)]]
