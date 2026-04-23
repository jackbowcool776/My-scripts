-- Universal Script by Claude
-- Full featured version with chat commands

if not game:IsLoaded() then game.Loaded:Wait() end

local success, err = pcall(function()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function getCharacter()
    return LocalPlayer.Character
end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

repeat task.wait(0.1) until getCharacter() and getHumanoid() and getRootPart()

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
local FlySpeed = 50
local JumpPower = 50
local GravityValue = 196.2
local FOVValue = 70
local OriginalWalkSpeed = getHumanoid().WalkSpeed
local OriginalJumpPower = getHumanoid().JumpPower
local OriginalGravity = workspace.Gravity
local OriginalFOV = Camera.FieldOfView
local OriginalAmbient = Lighting.Ambient
local OriginalBrightness = Lighting.Brightness
local FlyConnection = nil
local NoclipConnection = nil
local AntiAFKConnection = nil

local ESPFolder
pcall(function()
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ESP_Folder"
    ESPFolder.Parent = game:GetService("CoreGui")
end)

-- notify function
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

-- =====================
-- SPEED
-- =====================
local function toggleSpeed()
    States.Speed = not States.Speed
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = States.Speed and SpeedValue or OriginalWalkSpeed
    end
    notify("Speed", States.Speed and "ON" or "OFF")
end

-- =====================
-- FLY
-- =====================
local function toggleFly()
    States.Fly = not States.Fly
    local char = getCharacter()
    local root = getRootPart()
    local hum = getHumanoid()
    if not char or not root or not hum then return end

    if States.Fly then
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
        bv.Parent = root

        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
        bg.P = 1e4
        bg.Parent = root

        FlyConnection = RunService.Heartbeat:Connect(function()
            if not States.Fly then
                pcall(function() bv:Destroy() end)
                pcall(function() bg:Destroy() end)
                FlyConnection:Disconnect()
                FlyConnection = nil
                return
            end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            bv.Velocity = dir * FlySpeed
            bg.CFrame = cam.CFrame
        end)
    else
        if hum then hum.PlatformStand = false end
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
        if root then
            for _, v in pairs(root:GetChildren()) do
                if v.Name == "FlyVelocity" or v.Name == "FlyGyro" then
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end
    notify("Fly", States.Fly and "ON" or "OFF")
end

-- =====================
-- INFINITE JUMP
-- =====================
UserInputService.JumpRequest:Connect(function()
    if States.InfiniteJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
local function toggleInfiniteJump()
    States.InfiniteJump = not States.InfiniteJump
    notify("Infinite Jump", States.InfiniteJump and "ON" or "OFF")
end

-- =====================
-- ANTI-AFK
-- =====================
local function toggleAntiAFK()
    States.AntiAFK = not States.AntiAFK
    if States.AntiAFK then
        AntiAFKConnection = RunService.Heartbeat:Connect(function()
            if States.AntiAFK then
                pcall(function() LocalPlayer:Move(Vector3.new(0,0,0)) end)
            end
        end)
    else
        if AntiAFKConnection then AntiAFKConnection:Disconnect() AntiAFKConnection = nil end
    end
    notify("Anti-AFK", States.AntiAFK and "ON" or "OFF")
end

-- =====================
-- FULLBRIGHT
-- =====================
local function toggleFullbright()
    States.Fullbright = not States.Fullbright
    if States.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end
        end
    else
        Lighting.Ambient = OriginalAmbient
        Lighting.Brightness = OriginalBrightness
        Lighting.GlobalShadows = true
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v.Enabled = true end
        end
    end
    notify("Fullbright", States.Fullbright and "ON" or "OFF")
end

-- =====================
-- ESP
-- =====================
local function createESP(player)
    if player == LocalPlayer then return end
    pcall(function()
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_" .. player.Name
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0,100,0,40)
        bb.StudsOffset = Vector3.new(0,3,0)
        bb.Parent = ESPFolder

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1,0,0.5,0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255,50,50)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.Text = player.Name
        nameLabel.Parent = bb

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1,0,0.5,0)
        distLabel.Position = UDim2.new(0,0,0.5,0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(255,255,255)
        distLabel.TextStrokeTransparency = 0
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextScaled = true
        distLabel.Text = "0 studs"
        distLabel.Parent = bb

        RunService.Heartbeat:Connect(function()
            if not States.ESP then pcall(function() bb:Destroy() end) return end
            local char = player.Character
            local root = getRootPart()
            if char and char:FindFirstChild("HumanoidRootPart") and root then
                bb.Adornee = char.HumanoidRootPart
                local dist = math.floor((root.Position - char.HumanoidRootPart.Position).Magnitude)
                distLabel.Text = dist .. " studs"
            end
        end)
    end)
end

local function toggleESP()
    States.ESP = not States.ESP
    if States.ESP then
        for _, p in pairs(Players:GetPlayers()) do createESP(p) end
        Players.PlayerAdded:Connect(function(p) if States.ESP then createESP(p) end end)
    else
        if ESPFolder then ESPFolder:ClearAllChildren() end
    end
    notify("ESP", States.ESP and "ON" or "OFF")
end

-- =====================
-- NOCLIP
-- =====================
local function toggleNoclip()
    States.Noclip = not States.Noclip
    if States.Noclip then
        NoclipConnection = RunService.Stepped:Connect(function()
            if not States.Noclip then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
                local char = getCharacter()
                if char then
                    for _, p in pairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end
                end
                return
            end
            local char = getCharacter()
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
    notify("Noclip", States.Noclip and "ON" or "OFF")
end

-- =====================
-- TELEPORT TO PLAYER
-- =====================
local function teleportToPlayer(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local root = getRootPart()
        if root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            notify("Teleport", "Teleported to " .. name)
        end
    else
        notify("Teleport", "Player not found!")
    end
end

-- =====================
-- SPECTATE PLAYER
-- =====================
local spectateConnection = nil
local function spectatePlayer(name)
    if spectateConnection then
        spectateConnection:Disconnect()
        spectateConnection = nil
        Camera.CameraType = Enum.CameraType.Custom
        notify("Spectate", "Stopped spectating")
        return
    end
    local target = Players:FindFirstChild(name)
    if target then
        spectateConnection = RunService.Heartbeat:Connect(function()
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 10)
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end)
        notify("Spectate", "Spectating " .. name)
    else
        notify("Spectate", "Player not found!")
    end
end

-- =====================
-- REJOIN
-- =====================
local function rejoin()
    local id = game.PlaceId
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(id, LocalPlayer)
end

-- =====================
-- FPS UNLOCKER
-- =====================
local function setFPS(fps)
    setfpscap(fps)
end

-- =====================
-- JUMP POWER
-- =====================
local function setJumpPower(val)
    JumpPower = val
    local hum = getHumanoid()
    if hum then hum.JumpPower = val end
end

-- =====================
-- GRAVITY
-- =====================
local function setGravity(val)
    GravityValue = val
    workspace.Gravity = val
end

-- =====================
-- TIME OF DAY
-- =====================
local function setTimeOfDay(val)
    Lighting.ClockTime = val
end

-- =====================
-- FOV
-- =====================
local function setFOV(val)
    FOVValue = val
    Camera.FieldOfView = val
end

-- =====================
-- CHAT COMMANDS
-- =====================
local chatCommands = {
    ["!fly"] = function() toggleFly() end,
    ["!speed"] = function() toggleSpeed() end,
    ["!jump"] = function() toggleInfiniteJump() end,
    ["!afk"] = function() toggleAntiAFK() end,
    ["!bright"] = function() toggleFullbright() end,
    ["!esp"] = function() toggleESP() end,
    ["!noclip"] = function() toggleNoclip() end,
    ["!rejoin"] = function() rejoin() end,
    ["!tp"] = function(args)
        if args[2] then teleportToPlayer(args[2]) end
    end,
    ["!spec"] = function(args)
        if args[2] then spectatePlayer(args[2]) end
    end,
}

LocalPlayer.Chatted:Connect(function(msg)
    local args = msg:lower():split(" ")
    local cmd = args[1]
    if chatCommands[cmd] then
        chatCommands[cmd](args)
    end
end)

-- =====================
-- GUI SETUP
-- =====================
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalScript"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game:GetService("CoreGui") end)

-- Colors
local BG = Color3.fromRGB(25,25,35)
local TabBG = Color3.fromRGB(15,15,25)
local RowBG = Color3.fromRGB(35,35,48)
local InputBG = Color3.fromRGB(50,50,68)
local SwitchOFF = Color3.fromRGB(60,60,75)
local SwitchON = Color3.fromRGB(50,150,80)
local AccentBlue = Color3.fromRGB(60,100,200)

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,260,0,50)
MainFrame.Position = UDim2.new(0,20,0.5,-25)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = gui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,40)
TitleBar.BackgroundColor3 = TabBG
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1,-80,1,0)
TitleLabel.Position = UDim2.new(0,10,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "Universal Script"
TitleLabel.Parent = TitleBar

-- Toggle GUI button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,30,0,30)
ToggleBtn.Position = UDim2.new(1,-35,0,5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Text = "▼"
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = TitleBar
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,6)

-- Tab buttons frame
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,36)
TabBar.Position = UDim2.new(0,0,0,40)
TabBar.BackgroundColor3 = Color3.fromRGB(20,20,30)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,4)
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0,6)
TabPadding.PaddingTop = UDim.new(0,5)
TabPadding.Parent = TabBar

-- Scroll frame for content
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1,0,1,-76)
ScrollFrame.Position = UDim2.new(0,0,0,76)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80,80,100)
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0,6)
ContentLayout.Parent = ScrollFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0,8)
ContentPadding.PaddingLeft = UDim.new(0,10)
ContentPadding.PaddingRight = UDim.new(0,10)
ContentPadding.PaddingBottom = UDim.new(0,8)
ContentPadding.Parent = ScrollFrame

-- =====================
-- HELPER: INPUT BOX
-- =====================
local function createInputBox(parent, labelText, defaultVal, onChanged)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,52)
    container.BackgroundColor3 = RowBG
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,22)
    lbl.Position = UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(180,180,180)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = labelText .. ": " .. defaultVal
    lbl.Parent = container

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1,-20,0,22)
    input.Position = UDim2.new(0,10,0,26)
    input.BackgroundColor3 = InputBG
    input.TextColor3 = Color3.fromRGB(255,255,255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    input.Text = tostring(defaultVal)
    input.PlaceholderText = "Enter value..."
    input.BorderSizePixel = 0
    input.Parent = container
    Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)

    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            lbl.Text = labelText .. ": " .. val
            onChanged(val)
        else
            input.Text = tostring(defaultVal)
        end
    end)
    return container
end

-- =====================
-- HELPER: TOGGLE ROW
-- =====================
local switchStates = {}
local function createToggleRow(parent, labelText, toggleFunc, stateKey)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = RowBG
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-60,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText
    label.Parent = row

    local switchBG = Instance.new("Frame")
    switchBG.Size = UDim2.new(0,44,0,24)
    switchBG.Position = UDim2.new(1,-52,0.5,-12)
    switchBG.BackgroundColor3 = SwitchOFF
    switchBG.BorderSizePixel = 0
    switchBG.Parent = row
    Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1,0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,18,0,18)
    circle.Position = UDim2.new(0,3,0.5,-9)
    circle.BackgroundColor3 = Color3.fromRGB(180,180,180)
    circle.BorderSizePixel = 0
    circle.Parent = switchBG
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    local function updateSwitch(on)
        TweenService:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Quad),
            {Position = on and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9),
             BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,180,180)}
        ):Play()
        TweenService:Create(switchBG, TweenInfo.new(0.15, Enum.EasingStyle.Quad),
            {BackgroundColor3 = on and SwitchON or SwitchOFF}
        ):Play()
    end

    if stateKey then switchStates[stateKey] = updateSwitch end

    btn.MouseButton1Click:Connect(function()
        toggleFunc()
        if stateKey then updateSwitch(States[stateKey]) end
    end)
    return row
end

-- =====================
-- HELPER: SECTION LABEL
-- =====================
local function createSectionLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,18)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(120,120,160)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "— " .. text:upper() .. " —"
    lbl.Parent = parent
end

-- =====================
-- HELPER: BUTTON
-- =====================
local function createButton(parent, text, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = AccentBlue
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- =====================
-- HELPER: PLAYER DROPDOWN
-- =====================
local function createPlayerDropdown(parent, onSelected)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,52)
    container.BackgroundColor3 = RowBG
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,22)
    lbl.Position = UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(180,180,180)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "Select Player:"
    lbl.Parent = container

    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(1,-20,0,22)
    selected.Position = UDim2.new(0,10,0,26)
    selected.BackgroundColor3 = InputBG
    selected.TextColor3 = Color3.fromRGB(255,255,255)
    selected.Font = Enum.Font.Gotham
    selected.TextSize = 13
    selected.Text = "Click to select..."
    selected.BorderSizePixel = 0
    selected.Parent = container
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0,5)

    local selectedPlayer = nil
    local dropOpen = false
    local dropFrame = nil

    selected.MouseButton1Click:Connect(function()
        if dropOpen and dropFrame then
            dropFrame:Destroy()
            dropFrame = nil
            dropOpen = false
            return
        end
        dropOpen = true
        dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(1,-20,0,0)
        dropFrame.Position = UDim2.new(0,10,1,2)
        dropFrame.BackgroundColor3 = Color3.fromRGB(40,40,55)
        dropFrame.BorderSizePixel = 0
        dropFrame.ZIndex = 10
        dropFrame.Parent = container
        Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,6)

        local dropLayout = Instance.new("UIListLayout")
        dropLayout.Padding = UDim.new(0,2)
        dropLayout.Parent = dropFrame

        local dropPad = Instance.new("UIPadding")
        dropPad.PaddingTop = UDim.new(0,4)
        dropPad.PaddingBottom = UDim.new(0,4)
        dropPad.PaddingLeft = UDim.new(0,4)
        dropPad.PaddingRight = UDim.new(0,4)
        dropPad.Parent = dropFrame

        local playerList = Players:GetPlayers()
        local itemHeight = 26
        dropFrame.Size = UDim2.new(1,-20,0, #playerList * (itemHeight+2) + 8)

        for _, p in pairs(playerList) do
            if p ~= LocalPlayer then
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1,0,0,itemHeight)
                item.BackgroundColor3 = Color3.fromRGB(55,55,75)
                item.TextColor3 = Color3.fromRGB(255,255,255)
                item.Font = Enum.Font.Gotham
                item.TextSize = 13
                item.Text = p.Name
                item.BorderSizePixel = 0
                item.ZIndex = 11
                item.Parent = dropFrame
                Instance.new("UICorner", item).CornerRadius = UDim.new(0,4)

                item.MouseButton1Click:Connect(function()
                    selectedPlayer = p.Name
                    selected.Text = p.Name
                    onSelected(p.Name)
                    dropFrame:Destroy()
                    dropFrame = nil
                    dropOpen = false
                end)
            end
        end
    end)

    return container, function() return selectedPlayer end
end

-- =====================
-- TAB SYSTEM
-- =====================
local tabs = {}
local activeTab = nil
local tabContents = {}

local function createTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0,70,0,26)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35,35,50)
    tabBtn.TextColor3 = Color3.fromRGB(180,180,180)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 11
    tabBtn.Text = (icon and icon .. " " or "") .. name
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = TabBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0,6)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,0,1,0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = ScrollFrame

    local cLayout = Instance.new("UIListLayout")
    cLayout.Padding = UDim.new(0,6)
    cLayout.Parent = content

    tabs[name] = {btn = tabBtn, content = content}
    tabContents[name] = content

    tabBtn.MouseButton1Click:Connect(function()
        for tname, tdata in pairs(tabs) do
            tdata.content.Visible = false
            tdata.btn.BackgroundColor3 = Color3.fromRGB(35,35,50)
            tdata.btn.TextColor3 = Color3.fromRGB(180,180,180)
        end
        content.Visible = true
        tabBtn.BackgroundColor3 = AccentBlue
        tabBtn.TextColor3 = Color3.fromRGB(255,255,255)
        activeTab = name
    end)

    return content
end

-- Remove default content layout since tabs handle it
ContentLayout:Destroy()
ContentPadding:Destroy()

-- =====================
-- BUILD TABS
-- =====================

-- MOVEMENT TAB
local moveTab = createTab("Move", "🏃")

local movePad = Instance.new("UIPadding")
movePad.PaddingTop = UDim.new(0,8)
movePad.PaddingLeft = UDim.new(0,10)
movePad.PaddingRight = UDim.new(0,10)
movePad.PaddingBottom = UDim.new(0,8)
movePad.Parent = moveTab

createSectionLabel(moveTab, "Walk Speed")
createInputBox(moveTab, "Walk Speed", 50, function(val)
    SpeedValue = val
    if States.Speed then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = val end
    end
end)
createToggleRow(moveTab, "Speed", toggleSpeed, "Speed")

createSectionLabel(moveTab, "Fly")
createInputBox(moveTab, "Fly Speed", 50, function(val) FlySpeed = val end)
createToggleRow(moveTab, "Fly", toggleFly, "Fly")

createSectionLabel(moveTab, "Jump")
createInputBox(moveTab, "Jump Power", 50, function(val) setJumpPower(val) end)
createToggleRow(moveTab, "Infinite Jump", toggleInfiniteJump, "InfiniteJump")

createSectionLabel(moveTab, "Other")
createToggleRow(moveTab, "Noclip", toggleNoclip, "Noclip")
createToggleRow(moveTab, "Anti-AFK", toggleAntiAFK, "AntiAFK")

-- WORLD TAB
local worldTab = createTab("World", "🌍")

local worldPad = Instance.new("UIPadding")
worldPad.PaddingTop = UDim.new(0,8)
worldPad.PaddingLeft = UDim.new(0,10)
worldPad.PaddingRight = UDim.new(0,10)
worldPad.PaddingBottom = UDim.new(0,8)
worldPad.Parent = worldTab

createSectionLabel(worldTab, "Visuals")
createToggleRow(worldTab, "Fullbright", toggleFullbright, "Fullbright")
createToggleRow(worldTab, "ESP", toggleESP, "ESP")

createSectionLabel(worldTab, "Gravity")
createInputBox(worldTab, "Gravity", 196, function(val) setGravity(val) end)

createSectionLabel(worldTab, "Time of Day")
createInputBox(worldTab, "Clock Time (0-24)", 14, function(val) setTimeOfDay(val) end)

createSectionLabel(worldTab, "Camera")
createInputBox(worldTab, "FOV", 70, function(val) setFOV(val) end)

createSectionLabel(worldTab, "Performance")
createInputBox(worldTab, "FPS Cap", 144, function(val) pcall(function() setFPS(val) end) end)

-- PLAYERS TAB
local playersTab = createTab("Player", "👤")

local playersPad = Instance.new("UIPadding")
playersPad.PaddingTop = UDim.new(0,8)
playersPad.PaddingLeft = UDim.new(0,10)
playersPad.PaddingRight = UDim.new(0,10)
playersPad.PaddingBottom = UDim.new(0,8)
playersPad.Parent = playersTab

createSectionLabel(playersTab, "Teleport to Player")
local _, getTeleportTarget = createPlayerDropdown(playersTab, function(name) end)
createButton(playersTab, "Teleport", function()
    local t = getTeleportTarget()
    if t then teleportToPlayer(t) end
end)

createSectionLabel(playersTab, "Spectate Player")
local _, getSpectateTarget = createPlayerDropdown(playersTab, function(name) end)
createButton(playersTab, "Spectate / Stop", function()
    local t = getSpectateTarget()
    if t then spectatePlayer(t) end
end)

createSectionLabel(playersTab, "Server")
createButton(playersTab, "Rejoin", function() rejoin() end)

-- COMMANDS TAB
local cmdsTab = createTab("Cmds", "💬")

local cmdsPad = Instance.new("UIPadding")
cmdsPad.PaddingTop = UDim.new(0,8)
cmdsPad.PaddingLeft = UDim.new(0,10)
cmdsPad.PaddingRight = UDim.new(0,10)
cmdsPad.PaddingBottom = UDim.new(0,8)
cmdsPad.Parent = cmdsTab

local cmdList = {
    {"!fly", "Toggle fly"},
    {"!speed", "Toggle speed"},
    {"!jump", "Toggle infinite jump"},
    {"!afk", "Toggle anti-afk"},
    {"!bright", "Toggle fullbright"},
    {"!esp", "Toggle ESP"},
    {"!noclip", "Toggle noclip"},
    {"!rejoin", "Rejoin server"},
    {"!tp [name]", "Teleport to player"},
    {"!spec [name]", "Spectate player"},
}

for _, cmd in pairs(cmdList) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,42)
    row.BackgroundColor3 = RowBG
    row.BorderSizePixel = 0
    row.Parent = cmdsTab
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local cmdLabel = Instance.new("TextLabel")
    cmdLabel.Size = UDim2.new(1,-10,0,20)
    cmdLabel.Position = UDim2.new(0,10,0,4)
    cmdLabel.BackgroundTransparency = 1
    cmdLabel.TextColor3 = Color3.fromRGB(100,200,255)
    cmdLabel.Font = Enum.Font.GothamBold
    cmdLabel.TextSize = 13
    cmdLabel.TextXAlignment = Enum.TextXAlignment.Left
    cmdLabel.Text = cmd[1]
    cmdLabel.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1,-10,0,16)
    descLabel.Position = UDim2.new(0,10,0,22)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Color3.fromRGB(150,150,180)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Text = cmd[2]
    descLabel.Parent = row
end

-- =====================
-- OPEN/CLOSE + DEFAULT TAB
-- =====================
local guiOpen = false
local openHeight = 420

-- Start on Move tab
tabs["Move"].btn.MouseButton1Click:Fire()

ToggleBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad),
        {Size = guiOpen and UDim2.new(0,260,0,openHeight) or UDim2.new(0,260,0,50)}
    ):Play()
    ToggleBtn.Text = guiOpen and "▲" or "▼"
end)

-- =====================
-- DRAGGING
-- =====================
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
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[Universal Script] Loaded! Type !help in chat to see commands.")

end)

if not success then
    warn("[Universal Script] Error: " .. tostring(err))
end
