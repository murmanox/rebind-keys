local module = {
	In = {},
	Out = {},
}


local function createClippingFrame(obj, startSize)
	local startSize = startSize or obj.Size
	
	local clippingFrame = Instance.new("Frame")
	clippingFrame.Name = "Clip"
	
	clippingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	clippingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	clippingFrame.Size = startSize
	
	clippingFrame.BorderSizePixel = 0
	clippingFrame.ClipsDescendants = true
	clippingFrame.BackgroundTransparency = 1
	
	clippingFrame.Parent = obj.Parent
	obj.Parent = clippingFrame
	
	return clippingFrame
end


function module.WipeFromCentre(obj, tweenInfo, startSize)
	startSize = startSize or obj.Size
	tweenInfo = tweenInfo or nil
	
	local clippingFrame = createClippingFrame(obj, startSize)
	obj.Visible = true
	
	clippingFrame:GetPropertyChangedSignal("Size"):Connect(function(new)
		local size = clippingFrame.Size
		
		obj.Size = UDim2.new(1/size.X.Scale, 0, 1/size.Y.Scale, 0)
	end)
	
	if not tweenInfo then
		tweenInfo = {
			UDim2.new(1, 0, 1, 0),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Quad,
			1,
			false,
			nil
		}
	end
	
	clippingFrame:TweenSize(unpack(tweenInfo))
end


local function temp(obj, clippingFrame, tweenInfo)
	clippingFrame:GetPropertyChangedSignal("Size"):Connect(function(new)
		local size = clippingFrame.Size
		
		obj.Size = UDim2.new(1/size.X.Scale, 0, 1/size.Y.Scale, 0)
	end)
	
	clippingFrame:TweenSize(unpack(tweenInfo))
end


function module.In.VerticalWipeFromCentre(obj, duration)
	local startSize = UDim2.new(1, 0, 0, 0)
	duration = duration or 1
	
	local tweenInfo = {
		UDim2.new(1, 0, 1, 0),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Quad,
		duration,
		false,
		nil
	}
	
	local clippingFrame = createClippingFrame(obj, startSize)
	obj.Visible = true
	
	temp(obj, clippingFrame, tweenInfo)
end


function module.Out.VerticalWipe(obj, duration)
	local startSize = UDim2.new(1, 0, 1, 0)
	duration = duration or 1
	
	local tweenInfo = {
		UDim2.new(1, 0, 0, 0),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Quad,
		duration,
		true,
		function()
			obj.Parent.Parent.Parent:Destroy()
		end
	}
	
	local clippingFrame = createClippingFrame(obj, startSize)
	obj.Visible = true
	
	temp(obj, clippingFrame, tweenInfo)
end


return module
