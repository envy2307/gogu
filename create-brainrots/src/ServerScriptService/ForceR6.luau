game:GetService("StarterPlayer").CharacterAppearanceLoaded:Connect(function(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.RigType = Enum.HumanoidRigType.R6
	end
end)