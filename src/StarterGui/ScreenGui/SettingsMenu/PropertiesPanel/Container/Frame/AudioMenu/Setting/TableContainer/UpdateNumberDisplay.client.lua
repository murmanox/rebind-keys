script.Parent.Slider.Value.Changed:Connect(function(new)
	script.Parent.Value.TextLabel.Text = tostring(new)
end)

--TODO: this can be handled by an object