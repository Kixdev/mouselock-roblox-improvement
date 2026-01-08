--==================================================
-- MOUSELOCK OVERLAY (Cursor Free) - Responsive UI
-- - Keeps game's default walk/sprint/jump exactly
-- - SCRIPT ON = mouselock facing active
-- - Only 2 buttons: DESTROY + SCRIPT ON/OFF
-- - Press comma (,) to hide/show entire UI
-- - Responsive across PC/Laptop/Phone
--==================================================

--==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--==================== PLAYER ======================
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================== STATE =======================
local scriptEnabled = true
local uiHidden = false

-- Hide UI toggle key: comma (,)
local HIDE_UI_KEY = Enum.KeyCode.Comma

--==================== GUI ROOT ====================
local gui = Instance.new("ScreenGui")
gui.Name = "MouseLockOverlayDBG"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Responsive scale container (we scale a single frame)
local rootFrame = Instance.new("Frame")
rootFrame.Name = "Root"
rootFrame.BackgroundTransparency = 1
rootFrame.Size = UDim2.fromScale(1, 1)
rootFrame.Parent = gui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = rootFrame

--==================== RESPONSIVE SCALE ====================
local function computeScale(viewport)
	-- Base design reference: 1920x1080
	local vw, vh = viewport.X, viewport.Y
	if vw <= 0 or vh <= 0 then return 1 end

	-- Use the smaller ratio so UI fits on any aspect ratio
	local sx = vw / 1920
	local sy = vh / 1080
	local s = math.min(sx, sy)

	-- Clamp so it doesn't get too tiny or too huge
	-- On phones it'll usually land around ~0.85-1.25 depending on res
	return math.clamp(s, 0.75, 1.15)
end

local function updateScale()
	local cam = workspace.CurrentCamera
	if not cam then return end
	uiScale.Scale = computeScale(cam.ViewportSize)
end

-- Update scale on start and when viewport changes
task.defer(updateScale)
local vpConn
vpConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	-- camera can change on respawn
	task.defer(function()
		updateScale()
		local cam = workspace.CurrentCamera
		if cam then
			cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
		end
	end)
end)
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

--==================== UI ELEMENTS =================
local function makeBtn(name, text, posScaleY, bg)
	local b = Instance.new("TextButton")
	b.Name = name
	b.AnchorPoint = Vector2.new(0, 1) -- bottom-left anchor
	b.Position = UDim2.fromScale(0.02, posScaleY) -- responsive position
	b.Size = UDim2.new(0, 180, 0, 38) -- scaled by UIScale
	b.BackgroundColor3 = bg
	b.BorderSizePixel = 0
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 18
	b.Font = Enum.Font.SourceSansBold
	b.Text = text
	b.AutoButtonColor = true
	b.Parent = rootFrame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = b

	-- Add a subtle stroke so it stays readable on bright scenes
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Transparency = 0.65
	stroke.Parent = b

	return b
end

local btnDestroy = makeBtn("Destroy", "DESTROY", 0.82, Color3.fromRGB(200, 60, 60))
local btnToggle = makeBtn("Toggle", "SCRIPT: ON", 0.88, Color3.fromRGB(70, 190, 90))

local status = Instance.new("TextLabel")
status.Name = "Status"
status.AnchorPoint = Vector2.new(0, 1)
status.Position = UDim2.fromScale(0.02, 0.94)
status.Size = UDim2.new(0, 520, 0, 30) -- scaled by UIScale
status.BackgroundTransparency = 0.35
status.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
status.BorderSizePixel = 0
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.SourceSans
status.TextSize = 18
status.Text = ""
status.Parent = rootFrame
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 10)

local statusStroke = Instance.new("UIStroke")
statusStroke.Thickness = 1
statusStroke.Transparency = 0.7
statusStroke.Parent = status

-- Make text shrink gracefully on small screens
local textConstraint = Instance.new("UITextSizeConstraint")
textConstraint.MinTextSize = 12
textConstraint.MaxTextSize = 18
textConstraint.Parent = status

--==================== UI VISIBILITY =================
local function setUiHidden(hidden)
	uiHidden = hidden
	for _, child in ipairs(rootFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			child.Visible = not uiHidden
		end
	end
end

local function refreshUI()
	btnToggle.Text = scriptEnabled and "SCRIPT: ON" or "SCRIPT: OFF"
	btnToggle.BackgroundColor3 = scriptEnabled and Color3.fromRGB(70, 190, 90) or Color3.fromRGB(200, 60, 60)
	status.Text = ("Overlay: %s | Cursor free | Hide UI: ,")
		:format(scriptEnabled and "ON (mouselock active)" or "OFF")
end

refreshUI()

--==================== CHARACTER BIND ==============
local root
local function bindCharacter(char)
	root = char:WaitForChild("HumanoidRootPart")
end
bindCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(bindCharacter)

--==================== CORE: FACE CAMERA (Yaw only) ==========
local function faceCameraYaw()
	if not scriptEnabled then return end
	if not root then return end

	local cam = workspace.CurrentCamera
	if not cam then return end

	local look = cam.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.01 then return end

	root.CFrame = CFrame.new(root.Position, root.Position + flat.Unit)
end

local renderConn = RunService.RenderStepped:Connect(faceCameraYaw)

--==================== INPUT =======================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == HIDE_UI_KEY then
		setUiHidden(not uiHidden)
	end
end)

--==================== BUTTONS =====================
btnToggle.MouseButton1Click:Connect(function()
	scriptEnabled = not scriptEnabled
	refreshUI()
end)

btnDestroy.MouseButton1Click:Connect(function()
	if renderConn then renderConn:Disconnect() end
	if vpConn then vpConn:Disconnect() end
	gui:Destroy()
	if script then script:Destroy() end
end)

print("MouseLock Overlay loaded (responsive). Press ',' to hide/show UI.")
