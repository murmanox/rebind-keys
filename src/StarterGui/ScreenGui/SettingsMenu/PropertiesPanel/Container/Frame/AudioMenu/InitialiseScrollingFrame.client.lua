local Canvas = script.Parent
local Constraint = script.Parent.UIListLayout
local Padding = script.Parent.UIPadding


local function isScrollBarShowing()
	return Canvas.AbsoluteWindowSize.Y <= Canvas.CanvasSize.Y.Offset and true or false
end


local function UpdateCanvasSize()	
	local offset = 0
	if isScrollBarShowing() then
		offset = Canvas.ScrollBarThickness
	end
	
	Padding.PaddingRight = UDim.new(0, offset)
	Canvas.CanvasSize = UDim2.new(1, 0, 0, Constraint.AbsoluteContentSize.Y)
end


Constraint:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	UpdateCanvasSize()
end)


UpdateCanvasSize()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateCanvasSize)