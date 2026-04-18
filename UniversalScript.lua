-- Universal Script by Claude
-- Works in most Roblox games
-- Features: Speed, Fly, Infinite Jump, Anti-AFK, Fullbright, ESP, Noclip

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- State variables
local States = {
    Speed = false,
    Fly = false,
    InfiniteJump = false,
    AntiAFK = false,
    Fullbright = false,
    ESP = false,
    Noclip = false,
}

local SpeedValue = 50
local OriginalWalkSpeed = Humanoid.WalkSpeed
local OriginalAmbient = Lighting.Ambient
local OriginalBrightness = Lighting.Brightness
local FlyConnection = nil
local NoclipConnection = nil
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "ESP_Folder"

-- Character refresh on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    OriginalWalkSpeed = Humanoid.WalkSpeed

    -- Re-apply active states on respawn
    if States.Speed then Humanoid.WalkSpeed = SpeedValue end
    if States.InfiniteJump then end -- handled by connection below
    if States.Noclip then enableNoclip() end
end)

-- =====================
-- SPEED
-- =====================
local function toggleSpeed()
    States.Speed = not States.Speed
    if States.Speed then
        Humanoid.WalkSpeed = SpeedValue
    else
        Humanoid.WalkSpeed = OriginalWalkSpeed
    end
end

-- =====================
-- FLY
-- =====================
local function enableFly()
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Parent = RootPart

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 1e4
    bodyGyro.Parent = RootPart

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not States.Fly then
            bodyVelocity:Destroy()
            bodyGyro:Destroy()
            FlyConnection:Disconnect()
            FlyConnection = nil
            return
        end

        local camera = workspace.CurrentCamera
        local direction = Vector3.new(0, 0, 0)
        local speed = 50

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction = direction - Vector3.new(0, 1, 0)
        end

        bodyVelocity.Velocity = direction * speed
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function toggleFly()
    States.Fly = not States.Fly
    if States.Fly then
        Humanoid.PlatformStand = true
        enableFly()
    else
        Humanoid.PlatformStand = false
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        for _, v in pairs(RootPart:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end
end

-- =====================
-- INFINITE JUMP
-- =====================
UserInputService.JumpRequest:Connect(function()
    if States.InfiniteJump and Character and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function toggleInfiniteJump()
    States.InfiniteJump = not States.InfiniteJump
end

-- =====================
-- ANTI-AFK
-- =====================
local AntiAFKConnection = nil
local function toggleAntiAFK()
    States.AntiAFK = not States.AntiAFK
    if States.AntiAFK then
        AntiAFKConnection = RunService.Heartbeat:Connect(function()
            if States.AntiAFK then
                LocalPlayer:Move(Vector3.new(0, 0, 0))
            end
        end)
        -- Fake VR movement to prevent kick
        local VRService = game:GetService("VRService")
    else
        if AntiAFKConnection then
            AntiAFKConnection:Disconnect()
            AntiAFKConnection = nil
        end
    end
end

-- =====================
-- FULLBRIGHT
-- =====================
local function toggleFullbright()
    States.Fullbright = not States.Fullbright
    if States.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
    else
        Lighting.Ambient = OriginalAmbient
        Lighting.Brightness = OriginalBrightness
        Lighting.GlobalShadows = true
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = true
            end
        end
    end
end

-- =====================
-- ESP
-- =====================
local function createESP(player)
    if player == LocalPlayer then return end
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP_" .. player.Name
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Parent = ESPFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name
    nameLabel.Parent = billboardGui

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeTransparency = 0
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextScaled = true
    distLabel.Text = "0 studs"
    distLabel.Parent = billboardGui

    -- Update distance
    RunService.Heartbeat:Connect(function()
        if not States.ESP then
            billboardGui:Destroy()
            return
        end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and RootPart then
            billboardGui.Adornee = char.HumanoidRootPart
            local dist = math.floor((RootPart.Position - char.HumanoidRootPart.Position).Magnitude)
            distLabel.Text = dist .. " studs"
        else
            billboardGui.Adornee = nil
        end
    end)
end

local function toggleESP()
    States.ESP = not States.ESP
    if States.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
        end
        Players.PlayerAdded:Connect(function(player)
            if States.ESP then createESP(player) end
        end)
    else
        ESPFolder:ClearAllChildren()
    end
end

-- =====================
-- NOCLIP
-- =====================
local function enableNoclip()
    NoclipConnection = RunService.Stepped:Connect(function()
        if States.Noclip then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        else
            NoclipConnection:Disconnect()
            NoclipConnection = nil
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)
end

local function toggleNoclip()
    States.Noclip = not States.Noclip
    if States.Noclip then
        enableNoclip()
    end
end

-- =====================
-- GUI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 380)
MainFrame.Position = UDim2.new(0, 20, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "Universal Script"
TitleLabel.Parent = TitleBar

-- Minimize Button
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -35, 0, 5)
MinButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 16
MinButton.Text = "-"
MinButton.BorderSizePixel = 0
MinButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinButton

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ContentFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 8)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = ContentFrame

-- Speed Slider Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Text = "Speed Value: 50"
SpeedLabel.Parent = ContentFrame

-- Speed Input
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(1, 0, 0, 28)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 14
SpeedInput.Text = "50"
SpeedInput.PlaceholderText = "Enter speed..."
SpeedInput.BorderSizePixel = 0
SpeedInput.Parent = ContentFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = SpeedInput

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val then
        SpeedValue = val
        SpeedLabel.Text = "Speed Value: " .. val
        if States.Speed then
            Humanoid.WalkSpeed = SpeedValue
        end
    else
        SpeedInput.Text = tostring(SpeedValue)
    end
end)

-- Button creator function
local function createToggleButton(name, toggleFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = name .. ": OFF"
    btn.BorderSizePixel = 0
    btn.Parent = ContentFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        toggleFunc()
        local state = States[name:gsub(" ", "")]
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
            btn.Text = name .. ": ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            btn.Text = name .. ": OFF"
        end
    end)

    return btn
end

createToggleButton("Speed", toggleSpeed)
createToggleButton("Fly", toggleFly)
createToggleButton("InfiniteJump", toggleInfiniteJump)
createToggleButton("AntiAFK", toggleAntiAFK)
createToggleButton("Fullbright", toggleFullbright)
createToggleButton("ESP", toggleESP)
createToggleButton("Noclip", toggleNoclip)

-- Minimize functionality
local minimized = false
MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentFrame.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 220, 0, 40) or UDim2.new(0, 220, 0, 380)
    MinButton.Text = minimized and "+" or "-"
end)

-- Draggable GUI
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("Universal Script loaded successfully!")
