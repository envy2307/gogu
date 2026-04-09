 --SidebarGui.luau
-- Place in: src/StarterPlayerScripts/
-- LocalScript

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- SCREEN GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SidebarGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ============================================================
-- BUTTON DATA
-- ============================================================
local BUTTONS = {
	{
		name   = "Home",
		color  = Color3.fromRGB(46, 174, 74),    -- green
		dark   = Color3.fromRGB(28, 110, 46),
		icon   = "🏠",
		label  = "HOME",
	},
	{
		name   = "Shop",
		color  = Color3.fromRGB(30, 144, 255),   -- blue
		dark   = Color3.fromRGB(18, 90, 180),
		icon   = "🏪",
		label  = "SHOP",
	},
	{
		name   = "Inventory",
		color  = Color3.fromRGB(210, 40, 40),    -- red
		dark   = Color3.fromRGB(140, 20, 20),
		icon   = "🎒",
		label  = "BAG",
	},
	{
		name   = "Store",
		color  = Color3.fromRGB(130, 60, 200),   -- purple
		dark   = Color3.fromRGB(80, 30, 140),
		icon   = "🛒",
		label  = "STORE",
	},
}

-- ============================================================
-- HELPER: rounded corner
-- ============================================================
local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.new(1,1,1)
	s.Thickness = thickness or 1.5
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function tween(obj, props, t, style, dir)
	local info = TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	TweenService:Create(obj, info, props):Play()
end

-- ============================================================
-- SIDEBAR
-- ============================================================
local BTN_SIZE   = 64
local BTN_GAP    = 12
local SIDEBAR_X  = 14

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, BTN_SIZE, 0, #BUTTONS * (BTN_SIZE + BTN_GAP) - BTN_GAP)
sidebar.Position = UDim2.new(0, SIDEBAR_X, 0.5, -(#BUTTONS * (BTN_SIZE + BTN_GAP) - BTN_GAP) / 2)
sidebar.BackgroundTransparency = 1
sidebar.ZIndex = 10
sidebar.Parent = screenGui

-- ============================================================
-- OVERLAY (darkens screen behind fullscreen menus)
-- ============================================================
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.Position = UDim2.new(0, 0, 0, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.ZIndex = 15
overlay.Visible = false
overlay.Parent = screenGui

-- ============================================================
-- STATE
-- ============================================================
local openMenu   = nil
local isAnimating = false

local function closeAll(instant)
	if isAnimating and not instant then return end
	if openMenu then
		local m = openMenu
		isAnimating = true
		tween(m, {Position = UDim2.new(0.5, 0, 1.5, 0), BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tween(overlay, {BackgroundTransparency = 1}, 0.3)
		task.delay(0.31, function()
			m.Visible = false
			overlay.Visible = false
			openMenu = nil
			isAnimating = false
		end)
	else
		overlay.Visible = false
	end
end

overlay.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		closeAll()
	end
end)

-- ============================================================
-- BUILD BUTTONS + MENUS
-- ============================================================
local menuFrames = {}

for i, data in ipairs(BUTTONS) do

	-- ---- BUTTON ----
	local btn = Instance.new("TextButton")
	btn.Name = data.name .. "Btn"
	btn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
	btn.Position = UDim2.new(0, 0, 0, (i-1) * (BTN_SIZE + BTN_GAP))
	btn.BackgroundColor3 = data.color
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 10
	btn.Parent = sidebar
	addCorner(btn, 16)
	addStroke(btn, Color3.fromRGB(255,255,255), 1)

	-- Subtle gradient on button
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180,180,180)),
	}
	grad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0.9),
	}
	grad.Rotation = 135
	grad.Parent = btn

	-- Icon label (emoji)
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 0.6, 0)
	iconLabel.Position = UDim2.new(0, 0, 0.05, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = data.icon
	iconLabel.TextScaled = true
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextColor3 = Color3.new(1,1,1)
	iconLabel.ZIndex = 11
	iconLabel.Parent = btn

	-- Text label under icon
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 0.32, 0)
	textLabel.Position = UDim2.new(0, 0, 0.68, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = data.label
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = Color3.new(1,1,1)
	textLabel.ZIndex = 11
	textLabel.Parent = btn

	-- ---- MENU (fullscreen) ----
	local menuSize, menuAnchor, menuPos
	if data.name == "Inventory" then
		-- 80% of screen
		menuSize   = UDim2.new(0.80, 0, 0.80, 0)
		menuAnchor = Vector2.new(0.5, 0.5)
		menuPos    = UDim2.new(0.5, 0, 0.5, 0)
	else
		-- Full screen (with a little padding so it feels like a panel)
		menuSize   = UDim2.new(0.92, 0, 0.90, 0)
		menuAnchor = Vector2.new(0.5, 0.5)
		menuPos    = UDim2.new(0.5, 0, 0.5, 0)
	end

	local menu = Instance.new("Frame")
	menu.Name = data.name .. "Menu"
	menu.Size = menuSize
	menu.AnchorPoint = menuAnchor
	menu.Position = UDim2.new(0.5, 0, 1.5, 0) -- starts off-screen below
	menu.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.ZIndex = 20
	menu.Parent = screenGui
	addCorner(menu, 24)
	addStroke(menu, data.color, 2)

	-- Top accent bar
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 58)
	topBar.BackgroundColor3 = data.dark
	topBar.BorderSizePixel = 0
	topBar.ZIndex = 21
	topBar.Parent = menu
	addCorner(topBar, 24)

	-- Fix bottom corners of topbar (make it flat at bottom)
	local topBarBottom = Instance.new("Frame")
	topBarBottom.Size = UDim2.new(1, 0, 0.5, 0)
	topBarBottom.Position = UDim2.new(0, 0, 0.5, 0)
	topBarBottom.BackgroundColor3 = data.dark
	topBarBottom.BorderSizePixel = 0
	topBarBottom.ZIndex = 21
	topBarBottom.Parent = topBar

	-- Gradient on topbar
	local topGrad = Instance.new("UIGradient")
	topGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, data.color),
		ColorSequenceKeypoint.new(1, data.dark),
	}
	topGrad.Rotation = 90
	topGrad.Parent = topBar

	-- Menu icon in topbar
	local menuIcon = Instance.new("TextLabel")
	menuIcon.Size = UDim2.new(0, 44, 0, 44)
	menuIcon.Position = UDim2.new(0, 14, 0, 7)
	menuIcon.BackgroundTransparency = 1
	menuIcon.Text = data.icon
	menuIcon.TextScaled = true
	menuIcon.Font = Enum.Font.GothamBold
	menuIcon.TextColor3 = Color3.new(1,1,1)
	menuIcon.ZIndex = 23
	menuIcon.Parent = topBar

	-- Menu title
	local menuTitle = Instance.new("TextLabel")
	menuTitle.Size = UDim2.new(0, 300, 1, 0)
	menuTitle.Position = UDim2.new(0, 66, 0, 0)
	menuTitle.BackgroundTransparency = 1
	menuTitle.Text = data.name:upper()
	menuTitle.TextSize = 22
	menuTitle.Font = Enum.Font.GothamBold
	menuTitle.TextColor3 = Color3.new(1,1,1)
	menuTitle.TextXAlignment = Enum.TextXAlignment.Left
	menuTitle.ZIndex = 23
	menuTitle.Parent = topBar

	-- Close button (X)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 38, 0, 38)
	closeBtn.Position = UDim2.new(1, -50, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.BackgroundTransparency = 0.85
	closeBtn.Text = "✕"
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.BorderSizePixel = 0
	closeBtn.ZIndex = 24
	closeBtn.Parent = topBar
	addCorner(closeBtn, 10)

	closeBtn.MouseButton1Click:Connect(closeAll)

	-- ---- MENU CONTENT ----
	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Size = UDim2.new(1, -20, 1, -68)
	contentFrame.Position = UDim2.new(0, 10, 0, 63)
	contentFrame.BackgroundTransparency = 1
	contentFrame.BorderSizePixel = 0
	contentFrame.ScrollBarThickness = 4
	contentFrame.ScrollBarImageColor3 = data.color
	contentFrame.ZIndex = 22
	contentFrame.Parent = menu

	if data.name == "Home" then
		-- TP to spawn button
		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(1, -20, 0, 60)
		desc.Position = UDim2.new(0, 10, 0, 20)
		desc.BackgroundTransparency = 1
		desc.Text = "Teleport back to your spawn point"
		desc.TextSize = 16
		desc.Font = Enum.Font.Gotham
		desc.TextColor3 = Color3.fromRGB(180, 180, 200)
		desc.TextWrapped = true
		desc.TextXAlignment = Enum.TextXAlignment.Center
		desc.ZIndex = 23
		desc.Parent = contentFrame

		local tpBtn = Instance.new("TextButton")
		tpBtn.Size = UDim2.new(0.7, 0, 0, 60)
		tpBtn.Position = UDim2.new(0.15, 0, 0, 100)
		tpBtn.BackgroundColor3 = data.color
		tpBtn.Text = "🏠  Teleport Home"
		tpBtn.TextSize = 20
		tpBtn.Font = Enum.Font.GothamBold
		tpBtn.TextColor3 = Color3.new(1,1,1)
		tpBtn.BorderSizePixel = 0
		tpBtn.AutoButtonColor = false
		tpBtn.ZIndex = 23
		tpBtn.Parent = contentFrame
		addCorner(tpBtn, 14)

		local tpGrad = Instance.new("UIGradient")
		tpGrad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, data.color),
			ColorSequenceKeypoint.new(1, data.dark),
		}
		tpGrad.Rotation = 90
		tpGrad.Parent = tpBtn

		-- Hover effect
		tpBtn.MouseEnter:Connect(function()
			tween(tpBtn, {BackgroundColor3 = data.dark}, 0.15)
		end)
		tpBtn.MouseLeave:Connect(function()
			tween(tpBtn, {BackgroundColor3 = data.color}, 0.15)
		end)

		-- Teleport logic
		tpBtn.MouseButton1Click:Connect(function()
			local char = player.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
			if hrp and spawnLocation then
				hrp.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
			elseif hrp then
				-- fallback: tp to 0,5,0
				hrp.CFrame = CFrame.new(0, 5, 0)
			end
			closeAll()
		end)

	elseif data.name == "Shop" then
		local comingSoon = Instance.new("TextLabel")
		comingSoon.Size = UDim2.new(1, 0, 0, 200)
		comingSoon.Position = UDim2.new(0, 0, 0.3, 0)
		comingSoon.BackgroundTransparency = 1
		comingSoon.Text = "🏪\n\nShop coming soon!"
		comingSoon.TextSize = 22
		comingSoon.Font = Enum.Font.GothamBold
		comingSoon.TextColor3 = Color3.fromRGB(100, 160, 255)
		comingSoon.TextWrapped = true
		comingSoon.ZIndex = 23
		comingSoon.Parent = contentFrame

	elseif data.name == "Inventory" then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.new(1, 0, 0, 200)
		emptyLabel.Position = UDim2.new(0, 0, 0.25, 0)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Text = "🎒\n\nYour inventory is empty."
		emptyLabel.TextSize = 20
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
		emptyLabel.TextWrapped = true
		emptyLabel.ZIndex = 23
		emptyLabel.Parent = contentFrame

	elseif data.name == "Store" then
		local comingSoon = Instance.new("TextLabel")
		comingSoon.Size = UDim2.new(1, 0, 0, 200)
		comingSoon.Position = UDim2.new(0, 0, 0.3, 0)
		comingSoon.BackgroundTransparency = 1
		comingSoon.Text = "🛒\n\nStore coming soon!"
		comingSoon.TextSize = 22
		comingSoon.Font = Enum.Font.GothamBold
		comingSoon.TextColor3 = Color3.fromRGB(180, 100, 255)
		comingSoon.TextWrapped = true
		comingSoon.ZIndex = 23
		comingSoon.Parent = contentFrame
	end

	menuFrames[data.name] = menu

	-- ---- BUTTON CLICK ----
	btn.MouseButton1Click:Connect(function()
		if isAnimating then return end

		-- Green: instant TP, no menu
		if data.name == "Home" then
			local char = player.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
			if hrp and spawnLocation then
				hrp.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
			elseif hrp then
				hrp.CFrame = CFrame.new(0, 5, 0)
			end
			return
		end

		if openMenu == menu then
			closeAll()
			return
		end

		-- Close previous
		if openMenu then
			local prev = openMenu
			tween(prev, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			task.delay(0.21, function() prev.Visible = false end)
		end

		-- Show overlay
		overlay.Visible = true
		overlay.BackgroundTransparency = 1
		tween(overlay, {BackgroundTransparency = 0.45}, 0.3)

		-- Slide menu up from bottom
		menu.Position = UDim2.new(0.5, 0, 1.5, 0)
		menu.Visible = true
		isAnimating = true
		tween(menu, {Position = menuPos}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		task.delay(0.36, function()
			isAnimating = false
		end)

		openMenu = menu
	end)

	-- Hover effects on sidebar button
	btn.MouseEnter:Connect(function()
		tween(btn, {Size = UDim2.new(0, BTN_SIZE + 6, 0, BTN_SIZE + 6),
			Position = UDim2.new(0, -3, 0, (i-1) * (BTN_SIZE + BTN_GAP) - 3)}, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE),
			Position = UDim2.new(0, 0, 0, (i-1) * (BTN_SIZE + BTN_GAP))}, 0.15)
	end)
end
