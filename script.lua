local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local waypoints = {}
local currentWaypoint = 1
local moving = false
local connection
local speedConnection
local isWaitingForGrab = false
local grabDetectedThisSession = false 

local gui = Instance.new("ScreenGui")
gui.Name = "MeloskaDuelHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 210)
main.Position = UDim2.new(1, -260, 0.5, -105)
main.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1
mainStroke.Color = Color3.fromRGB(40, 42, 55)
mainStroke.Transparency = 0.3
mainStroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 14)
headerFix.Position = UDim2.new(0, 0, 1, -14)
headerFix.BackgroundColor3 = header.BackgroundColor3
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -75, 1, 0) 
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Meloska Duel Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(138, 43, 226)
title.Parent = header
title.Active = true

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88,101,242)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(67,181,129)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(250,166,26))
}
titleGradient.Parent = title

local discordBtn = Instance.new("TextButton")
discordBtn.Name = "DiscordBtn"
discordBtn.Size = UDim2.new(0, 55, 0, 22)
discordBtn.Position = UDim2.new(1, -65, 0.5, -11)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Discord"
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 10
discordBtn.TextColor3 = Color3.new(1,1,1)
discordBtn.Parent = header
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 6)

discordBtn.MouseButton1Click:Connect(function()
    local url = "https://discord.gg/NGEMSasjjG"
    if setclipboard then
        setclipboard(url)
        local oldText = discordBtn.Text
        discordBtn.Text = "Copied!"
        discordBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        task.wait(2)
        discordBtn.Text = oldText
        discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end
end)

task.spawn(function()
    while true do
        TweenService:Create(titleGradient, TweenInfo.new(6, Enum.EasingStyle.Linear), {Rotation = titleGradient.Rotation + 360}):Play()
        task.wait(6)
    end
end)

local dragToggle, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local speedContainer = Instance.new("Frame")
speedContainer.Size = UDim2.new(1, -30, 0, 38)
speedContainer.Position = UDim2.new(0, 15, 0, 60)
speedContainer.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
speedContainer.Parent = main
Instance.new("UICorner", speedContainer).CornerRadius = UDim.new(0, 10)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -16, 1, 0)
speedLabel.Position = UDim2.new(0, 8, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "--"
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.TextSize = 13
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
speedLabel.Parent = speedContainer

local statusContainer = Instance.new("Frame")
statusContainer.Size = UDim2.new(1, -30, 0, 38)
statusContainer.Position = UDim2.new(0, 15, 0, 108)
statusContainer.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
statusContainer.Parent = main
Instance.new("UICorner", statusContainer).CornerRadius = UDim.new(0, 10)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 1, 0)
statusLabel.Position = UDim2.new(0, 8, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "im ready boi"
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(67, 181, 129)
statusLabel.Parent = statusContainer

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -30, 0, 42)
button.Position = UDim2.new(0, 15, 0, 158)
button.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
button.Text = "START AUTO DUEL"
button.Font = Enum.Font.GothamBold
button.TextSize = 13
button.TextColor3 = Color3.new(1,1,1)
button.Parent = main
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

local function stopMoving()
    if connection then connection:Disconnect() end
    moving = false
    isWaitingForGrab = false
    grabDetectedThisSession = false 
    button.Text = "START AUTO DUEL"
    button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    if statusLabel.Text ~= "FINISHED!" then
        statusLabel.Text = "im ready boi"
        statusLabel.TextColor3 = Color3.fromRGB(67, 181, 129)
    end
end

speedConnection = RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        speedLabel.Text = tostring(math.floor(hum.WalkSpeed))
        if hum.WalkSpeed < 23 then
            speedLabel.TextColor3 = Color3.fromRGB(237, 66, 69)
            if isWaitingForGrab and not grabDetectedThisSession then
                task.wait(0.3)
                isWaitingForGrab = false
                grabDetectedThisSession = true 
                statusLabel.Text = "Silent bot bringed you at: "..currentWaypoint
                statusLabel.TextColor3 = Color3.fromRGB(67, 181, 129)
            end
        else
            speedLabel.TextColor3 = Color3.fromRGB(67, 181, 129)
        end
    end
end)

local function moveToWaypoint()
    if connection then connection:Disconnect() end
    connection = RunService.Stepped:Connect(function()
        if not moving or isWaitingForGrab then return end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local wp = waypoints[currentWaypoint]
        local dist = (root.Position - wp.position).Magnitude
        if dist < 5 then
            if (currentWaypoint == 4 or currentWaypoint == 6) and not grabDetectedThisSession then
                isWaitingForGrab = true
                statusLabel.Text = "Grab the pet please..."
                statusLabel.TextColor3 = Color3.fromRGB(250, 166, 26)
                root.Velocity = Vector3.zero
                return
            end
            if currentWaypoint == #waypoints then
                statusLabel.Text = "FINISHED!"
                statusLabel.TextColor3 = Color3.fromRGB(67, 181, 129)
                stopMoving()
                return
            end
            currentWaypoint += 1
            statusLabel.Text = "Silent bot bringed you at: "..currentWaypoint
        else
            local dir = (wp.position - root.Position).Unit
            root.Velocity = Vector3.new(dir.X * wp.speed, root.Velocity.Y, dir.Z * wp.speed)
        end
    end)
end

local function startDuel()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    moving = true
    grabDetectedThisSession = false 
    button.Text = "STOP AUTO DUEL"
    button.BackgroundColor3 = Color3.fromRGB(237, 66, 69)
    if (root.Position - Vector3.new(-475,-7,96)).Magnitude > (root.Position - Vector3.new(-474,-7,23)).Magnitude then
        waypoints = {
            {position = Vector3.new(-475,-7,96), speed=59},
            {position = Vector3.new(-483,-5,95), speed=59},
            {position = Vector3.new(-487,-5,95), speed=55},
            {position = Vector3.new(-492,-5,95), speed=55}, 
            {position = Vector3.new(-473,-7,95), speed=29},
            {position = Vector3.new(-473,-7,11), speed=29}  
        }
    else
        waypoints = {
            {position = Vector3.new(-474,-7,23), speed=55},
            {position = Vector3.new(-484,-5,24), speed=55},
            {position = Vector3.new(-488,-5,24), speed=55},
            {position = Vector3.new(-493,-5,25), speed=55}, 
            {position = Vector3.new(-473,-7,25), speed=29},
            {position = Vector3.new(-474,-7,112), speed=29} 
        }
    end
    currentWaypoint = 1
    moveToWaypoint()
end

button.MouseButton1Click:Connect(function()
    if moving or isWaitingForGrab then
        stopMoving()
    else
        startDuel()
    end
end)
