local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera
local teamCheck = false
local fov = 500
local smoothing = 1
local totalShots = 0
local totalHits = 0
local accuracy = 0.0
local Binds = {
OpenMenu = Enum.KeyCode.M,
Aimbot   = Enum.KeyCode.E,
SilentAim = Enum.KeyCode.Q,
Speed    = Enum.KeyCode.V,
Fly      = Enum.KeyCode.F,
Noclip   = Enum.KeyCode.G,
}
local SpeedEnabled = false
local NormalWalkSpeed = 16
local FlyEnabled = false
local NoclipEnabled = false
local FlyConnection = nil
local NoclipConnection = nil
local BodyVelocity = nil
local BodyGyro = nil
local SilentAimSettings = {
Enabled = false,
HitChance = 90,
TargetPart = "Head",
}
local FOVring = Drawing.new("Circle")
FOVring.Visible       = true
FOVring.Thickness     = 1.5
FOVring.Radius        = fov
FOVring.Transparency  = 1
FOVring.Color         = Color3.fromRGB(255, 128, 128)
FOVring.Position      = Camera.ViewportSize / 2
FOVring.Filled        = false
local ESPSettings = {
Enabled       = true,
ShowBox       = true,
ShowName      = true,
ShowHP        = true,
ShowSkeleton  = false,
SkeletonColor = Color3.fromRGB(0, 255, 0),
ShowFOVCircle = true,
RainbowESP    = false,
}
local CurrentTheme = "Dark"
local Theme = {
Dark = {
Background     = Color3.fromRGB(20,  20,  26),
Accent         = Color3.fromRGB(0,   170, 100),
Text           = Color3.fromRGB(220, 220, 235),
SecondaryText  = Color3.fromRGB(200, 200, 220),
Divider        = Color3.fromRGB(55,  55,  70),
ToggleOff      = Color3.fromRGB(70,  70,  85),
},
Light = {
Background     = Color3.fromRGB(245, 245, 250),
Accent         = Color3.fromRGB(0,   140, 220),
Text           = Color3.fromRGB(30,  30,  40),
SecondaryText  = Color3.fromRGB(70,  70,  90),
Divider        = Color3.fromRGB(210, 210, 220),
ToggleOff      = Color3.fromRGB(180, 180, 190),
}
}
local watermarkBg = Drawing.new("Square")
watermarkBg.Visible       = true
watermarkBg.Position      = Vector2.new(Camera.ViewportSize.X - 170, 5)
watermarkBg.Size          = Vector2.new(120, 35)
watermarkBg.Thickness     = 1
watermarkBg.Filled        = true
watermarkBg.Color         = Color3.fromRGB(0, 0, 0)
watermarkBg.Transparency  = 0.70
watermarkBg.Radius        = 8
local watermark = Drawing.new("Text")
watermark.Visible       = true
watermark.Position      = Vector2.new(Camera.ViewportSize.X - 140, 12)
watermark.Size          = 22
watermark.Center        = false
watermark.Outline       = true
watermark.OutlineColor  = Color3.fromRGB(0,0,0)
watermark.Color         = Color3.fromRGB(180, 180, 180)
watermark.Text          = "Hl-ow HUB"
watermark.Font          = Drawing.Fonts.Monospace
local rainbowTime = 0
RunService.RenderStepped:Connect(function(delta)
rainbowTime = rainbowTime + delta * 1.2
local hue = rainbowTime % 1
local color = Color3.fromHSV(hue, 1, 1)
if ESPSettings.RainbowESP then
watermark.Color = color
for _, data in pairs(espElements) do
if data.nameTag then data.nameTag.Color = color end
if data.healthText then data.healthText.Color = color end
for _, line in ipairs(data.lines) do
line.Color = color
end
for _, line in ipairs(data.skeletonLines) do
line.Color = color
end
end
end
end)
local hintText = Drawing.new("Text")
hintText.Visible       = true
hintText.Position      = Vector2.new(Camera.ViewportSize.X / 2, 60)
hintText.Size          = 28
hintText.Center        = true
hintText.Outline       = true
hintText.OutlineColor  = Color3.fromRGB(0,0,0)
hintText.Color         = Color3.fromRGB(200, 200, 200)
hintText.Text          = "МЕНЮ → M\nАИМБОТ (зажим) → E\nSILENT AIM (вкл/выкл) → Q\nСКОРОСТЬ → V\nПОЛЁТ → F\nНОКЛИП → G"
hintText.Font          = Drawing.Fonts.Monospace
task.delay(10, function()
hintText.Visible = false
end)
local selfHPText = Drawing.new("Text")
selfHPText.Visible       = true
selfHPText.Center        = true
selfHPText.Outline       = true
selfHPText.OutlineColor  = Color3.fromRGB(0,0,0)
selfHPText.Color         = Color3.fromRGB(220, 220, 220)
selfHPText.Size          = 26
selfHPText.Font          = Drawing.Fonts.Monospace
RunService.RenderStepped:Connect(function()
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") then
local humanoid = LocalPlayer.Character.Humanoid
local headPos = LocalPlayer.Character.Head.Position + Vector3.new(0, 2.8, 0)
local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
if onScreen then
local hpPerc = math.clamp(math.floor(humanoid.Health / humanoid.MaxHealth * 100 + 0.5), 0, 100)
selfHPText.Text = tostring(hpPerc) .. "%"
selfHPText.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
selfHPText.Visible = true
if hpPerc > 70 then
selfHPText.Color = Color3.fromRGB(100, 220, 140)
elseif hpPerc > 30 then
selfHPText.Color = Color3.fromRGB(220, 180, 60)
else
selfHPText.Color = Color3.fromRGB(220, 60, 60)
end
else
selfHPText.Visible = false
end
else
selfHPText.Visible = false
end
end)
local function getClosest(cframe, useFOV)
local target = nil
local mag = math.huge
local screenCenter = Camera.ViewportSize / 2
for _, v in pairs(Players:GetPlayers()) do
if v.Character and v.Character:FindFirstChild("Head")
and v.Character:FindFirstChild("Humanoid")
and v.Character:FindFirstChild("HumanoidRootPart")
and v ~= LocalPlayer
and (v.Team ~= LocalPlayer.Team or not teamCheck) then
local targetPart = v.Character[SilentAimSettings.TargetPart] or v.Character.Head
local targetPos = targetPart.Position
if useFOV then
local closestPoint = Ray.new(cframe.Position, cframe.LookVector * 5000):ClosestPoint(targetPos)
local magBuf = (targetPos - closestPoint).Magnitude
if magBuf < mag and magBuf < fov then
mag = magBuf
target = v
end
else
local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
if onScreen then
local screenVec = Vector2.new(screenPos.X, screenPos.Y)
local dist = (screenVec - screenCenter).Magnitude
if dist < mag and dist < fov then
mag = dist
target = v
end
end
end
end
end
return target
end
local function updateLearning(success)
totalShots = totalShots + 1
if success then totalHits = totalHits + 1 end
accuracy = totalShots > 0 and (totalHits / totalShots) or 0
if accuracy < 0.3 then
fov = fov + 10
smoothing = math.max(0.05, smoothing - 0.01)
elseif accuracy > 0.7 then
smoothing = math.min(1, smoothing + 0.01)
end
FOVring.Radius = fov
end
RunService.RenderStepped:Connect(function()
if not UserInputService:IsKeyDown(Binds.Aimbot) then return end
local cam = Camera
local screenCenter = cam.ViewportSize / 2
local closestTarget = getClosest(cam.CFrame, false)
if closestTarget and closestTarget.Character and closestTarget.Character:FindFirstChild("Head") then
local headPos = closestTarget.Character.Head.Position
local ssHeadPoint, onScreen = cam:WorldToScreenPoint(headPos)
local screenHead = Vector2.new(ssHeadPoint.X, ssHeadPoint.Y)
if onScreen and (screenHead - screenCenter).Magnitude < fov then
local targetCFrame = CFrame.new(cam.CFrame.Position, headPos)
cam.CFrame = cam.CFrame:Lerp(targetCFrame, smoothing)
end
end
end)
local function onFired()
if not SilentAimSettings.Enabled then return end
if math.random(1, 100) > SilentAimSettings.HitChance then
return
end
local character = LocalPlayer.Character
if not character then return end
local target = getClosest(Camera.CFrame, true)
if not target or not target.Character then return end
local targetPart = target.Character[SilentAimSettings.TargetPart] or target.Character.Head
if not targetPart then return end
local tool = character:FindFirstChildWhichIsA("Tool")
if tool then
local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("Part")
if handle then
local ray = Ray.new(handle.Position, (targetPart.Position - handle.Position).Unit * 500)
local hit, position = workspace:FindPartOnRay(ray, character)
if hit and hit.Parent:FindFirstChildWhichIsA("Humanoid") then
local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
if humanoid then
humanoid:TakeDamage(25)
updateLearning(true)
end
end
end
else
local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
local hit, position = workspace:FindPartOnRay(ray, character)
if hit and hit.Parent:FindFirstChildWhichIsA("Humanoid") then
local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
if humanoid then
humanoid:TakeDamage(25)
updateLearning(true)
end
end
end
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 then
onFired()
end
end)
local espElements = {}
local function createESP(player)
if player == LocalPlayer then return end
local esp = {}
esp.nameTag = Drawing.new("Text")
esp.nameTag.Visible    = false
esp.nameTag.Center     = true
esp.nameTag.Outline    = true
esp.nameTag.Size       = 16
esp.nameTag.Color      = Color3.fromRGB(200, 200, 200)
esp.nameTag.Text       = player.Name
esp.nameTag.Font       = Drawing.Fonts.Monospace
esp.healthText = Drawing.new("Text")
esp.healthText.Visible    = false
esp.healthText.Outline    = true
esp.healthText.Size       = 15
esp.healthText.Color      = Color3.fromRGB(180, 180, 180)
esp.healthText.Font       = Drawing.Fonts.Monospace
esp.lines = {}
for i = 1, 4 do
local line = Drawing.new("Line")
line.Visible      = false
line.Thickness    = 2
line.Transparency = 1
line.Color        = Color3.fromRGB(200, 200, 200)
table.insert(esp.lines, line)
end
esp.skeletonLines = {}
for i = 1, 15 do
local line = Drawing.new("Line")
line.Visible      = false
line.Thickness    = 2
line.Transparency = 1
line.Color        = ESPSettings.SkeletonColor
table.insert(esp.skeletonLines, line)
end
espElements[player] = esp
end
for _, player in pairs(Players:GetPlayers()) do
createESP(player)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
local esp = espElements[player]
if esp then
if esp.nameTag then esp.nameTag:Remove() end
if esp.healthText then esp.healthText:Remove() end
for _, line in ipairs(esp.lines) do
line:Remove()
end
for _, line in ipairs(esp.skeletonLines) do
line:Remove()
end
espElements[player] = nil
end
end)
local function updateSkeleton(esp, player)
if not ESPSettings.ShowSkeleton then
for _, line in ipairs(esp.skeletonLines) do
line.Visible = false
end
return
end
local char = player.Character
if not char then
for _, line in ipairs(esp.skeletonLines) do
line.Visible = false
end
return
end
local parts = {}
if char:FindFirstChild("Head") and char:FindFirstChild("Torso") then
parts.Head = char:FindFirstChild("Head")
parts.Torso = char:FindFirstChild("Torso")
parts.LeftArm = char:FindFirstChild("Left Arm")
parts.RightArm = char:FindFirstChild("Right Arm")
parts.LeftLeg = char:FindFirstChild("Left Leg")
parts.RightLeg = char:FindFirstChild("Right Leg")
else
parts.Head = char:FindFirstChild("Head")
parts.UpperTorso = char:FindFirstChild("UpperTorso")
parts.LowerTorso = char:FindFirstChild("LowerTorso")
parts.LeftUpperArm = char:FindFirstChild("LeftUpperArm")
parts.LeftLowerArm = char:FindFirstChild("LeftLowerArm")
parts.LeftHand = char:FindFirstChild("LeftHand")
parts.RightUpperArm = char:FindFirstChild("RightUpperArm")
parts.RightLowerArm = char:FindFirstChild("RightLowerArm")
parts.RightHand = char:FindFirstChild("RightHand")
parts.LeftUpperLeg = char:FindFirstChild("LeftUpperLeg")
parts.LeftLowerLeg = char:FindFirstChild("LeftLowerLeg")
parts.LeftFoot = char:FindFirstChild("LeftFoot")
parts.RightUpperLeg = char:FindFirstChild("RightUpperLeg")
parts.RightLowerLeg = char:FindFirstChild("RightLowerLeg")
parts.RightFoot = char:FindFirstChild("RightFoot")
end
local function getScreenPos(part)
if part then
local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
if onScreen then
return Vector2.new(pos.X, pos.Y)
end
end
return nil
end
for _, line in ipairs(esp.skeletonLines) do
line.Visible = false
end
local lines = {}
local index = 0
if parts.Head and parts.Torso then
index = index + 1; lines[index] = {parts.Head, parts.Torso}
index = index + 1; lines[index] = {parts.Torso, parts.LeftArm}
index = index + 1; lines[index] = {parts.Torso, parts.RightArm}
index = index + 1; lines[index] = {parts.Torso, parts.LeftLeg}
index = index + 1; lines[index] = {parts.Torso, parts.RightLeg}
elseif parts.UpperTorso then
index = index + 1; lines[index] = {parts.Head, parts.UpperTorso}
index = index + 1; lines[index] = {parts.UpperTorso, parts.LowerTorso}
index = index + 1; lines[index] = {parts.UpperTorso, parts.LeftUpperArm}
index = index + 1; lines[index] = {parts.LeftUpperArm, parts.LeftLowerArm}
index = index + 1; lines[index] = {parts.LeftLowerArm, parts.LeftHand}
index = index + 1; lines[index] = {parts.UpperTorso, parts.RightUpperArm}
index = index + 1; lines[index] = {parts.RightUpperArm, parts.RightLowerArm}
index = index + 1; lines[index] = {parts.RightLowerArm, parts.RightHand}
index = index + 1; lines[index] = {parts.LowerTorso, parts.LeftUpperLeg}
index = index + 1; lines[index] = {parts.LeftUpperLeg, parts.LeftLowerLeg}
index = index + 1; lines[index] = {parts.LeftLowerLeg, parts.LeftFoot}
index = index + 1; lines[index] = {parts.LowerTorso, parts.RightUpperLeg}
index = index + 1; lines[index] = {parts.RightUpperLeg, parts.RightLowerLeg}
index = index + 1; lines[index] = {parts.RightLowerLeg, parts.RightFoot}
end
for i, pair in ipairs(lines) do
local fromPos = getScreenPos(pair[1])
local toPos = getScreenPos(pair[2])
if fromPos and toPos then
local line = esp.skeletonLines[i]
line.From = fromPos
line.To = toPos
line.Visible = true
if not ESPSettings.RainbowESP then
line.Color = ESPSettings.SkeletonColor
end
end
end
end
local function updateESP()
if not ESPSettings.Enabled then
for _, data in pairs(espElements) do
if data.nameTag then data.nameTag.Visible = false end
if data.healthText then data.healthText.Visible = false end
for _, ln in ipairs(data.lines) do
ln.Visible = false
end
for _, ln in ipairs(data.skeletonLines) do
ln.Visible = false
end
end
return
end
for player, data in pairs(espElements) do
if player and player.Character then
local hrp = player.Character:FindFirstChild("HumanoidRootPart")
local head = player.Character:FindFirstChild("Head")
local hum = player.Character:FindFirstChild("Humanoid")
if hrp and head and hum then
local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
if onScreen then
local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
local bottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.0, 0))
local height = math.abs(top.Y - bottom.Y)
local width = height * 0.55
local left = Vector2.new(rootPos.X - width/2, top.Y)
local right = Vector2.new(rootPos.X + width/2, top.Y)
local bl = Vector2.new(left.X, bottom.Y)
local br = Vector2.new(right.X, bottom.Y)
if ESPSettings.ShowBox then
local boxColor = ESPSettings.RainbowESP and Color3.fromHSV((tick() * 0.8) % 1, 1, 1) or Color3.fromRGB(200, 200, 200)
data.lines[1].From = left
data.lines[1].To = right
data.lines[1].Color = boxColor
data.lines[1].Visible = true
data.lines[2].From = right
data.lines[2].To = br
data.lines[2].Color = boxColor
data.lines[2].Visible = true
data.lines[3].From = br
data.lines[3].To = bl
data.lines[3].Color = boxColor
data.lines[3].Visible = true
data.lines[4].From = bl
data.lines[4].To = left
data.lines[4].Color = boxColor
data.lines[4].Visible = true
else
for _, ln in ipairs(data.lines) do
ln.Visible = false
end
end
data.nameTag.Visible = ESPSettings.ShowName
if ESPSettings.ShowName then
data.nameTag.Position = Vector2.new(rootPos.X, top.Y - 24)
if ESPSettings.RainbowESP then
data.nameTag.Color = Color3.fromHSV((tick() * 0.8 + 0.1) % 1, 1, 1)
end
end
if ESPSettings.ShowHP then
local hpPerc = math.clamp(math.floor(hum.Health / hum.MaxHealth * 100), 0, 100)
data.healthText.Text = hpPerc .. "%"
if ESPSettings.RainbowESP then
data.healthText.Color = Color3.fromHSV((tick() * 0.8 + 0.2) % 1, 1, 1)
else
if hpPerc > 70 then
data.healthText.Color = Color3.fromRGB(100, 220, 140)
elseif hpPerc > 30 then
data.healthText.Color = Color3.fromRGB(220, 180, 60)
else
data.healthText.Color = Color3.fromRGB(220, 60, 60)
end
end
data.healthText.Position = Vector2.new(right.X + 6, rootPos.Y - 10)
data.healthText.Visible = true
else
data.healthText.Visible = false
end
updateSkeleton(data, player)
else
data.nameTag.Visible = false
data.healthText.Visible = false
for _, ln in ipairs(data.lines) do
ln.Visible = false
end
for _, ln in ipairs(data.skeletonLines) do
ln.Visible = false
end
end
else
data.nameTag.Visible = false
data.healthText.Visible = false
for _, ln in ipairs(data.lines) do
ln.Visible = false
end
for _, ln in ipairs(data.skeletonLines) do
ln.Visible = false
end
end
else
if data then
data.nameTag.Visible = false
data.healthText.Visible = false
for _, ln in ipairs(data.lines) do
ln.Visible = false
end
for _, ln in ipairs(data.skeletonLines) do
ln.Visible = false
end
end
end
end
end
RunService.RenderStepped:Connect(updateESP)
local function toggleFly()
FlyEnabled = not FlyEnabled
local character = LocalPlayer.Character
if not character then return end
local humanoid = character:FindFirstChild("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
if not humanoid or not rootPart then return end
if FlyEnabled then
humanoid.PlatformStand = true
BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.Velocity = Vector3.new(0, 0, 0)
BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
BodyVelocity.Parent = rootPart
BodyGyro = Instance.new("BodyGyro")
BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
BodyGyro.P = 1000
BodyGyro.D = 50
BodyGyro.Parent = rootPart
FlyConnection = RunService.RenderStepped:Connect(function()
if not FlyEnabled or not character or not rootPart or not humanoid then
if FlyConnection then
FlyConnection:Disconnect()
FlyConnection = nil
end
return
end
local moveDirection = Vector3.new(0, 0, 0)
local cameraCFrame = Camera.CFrame
if UserInputService:IsKeyDown(Enum.KeyCode.W) then
moveDirection = moveDirection + cameraCFrame.LookVector * Vector3.new(1, 0, 1)
end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then
moveDirection = moveDirection - cameraCFrame.LookVector * Vector3.new(1, 0, 1)
end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then
moveDirection = moveDirection - cameraCFrame.RightVector * Vector3.new(1, 0, 1)
end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then
moveDirection = moveDirection + cameraCFrame.RightVector * Vector3.new(1, 0, 1)
end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
moveDirection = moveDirection + Vector3.new(0, 1, 0)
end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
moveDirection = moveDirection + Vector3.new(0, -1, 0)
end
if moveDirection.Magnitude > 0 then
moveDirection = moveDirection.Unit * 50
end
BodyVelocity.Velocity = moveDirection
BodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + (cameraCFrame.LookVector * Vector3.new(1, 0, 1)))
end)
else
if FlyConnection then
FlyConnection:Disconnect()
FlyConnection = nil
end
if BodyVelocity then
BodyVelocity:Destroy()
BodyVelocity = nil
end
if BodyGyro then
BodyGyro:Destroy()
BodyGyro = nil
end
if humanoid then
humanoid.PlatformStand = false
end
end
end
local function toggleNoclip()
NoclipEnabled = not NoclipEnabled
local character = LocalPlayer.Character
if not character then return end
if NoclipEnabled then
NoclipConnection = RunService.Stepped:Connect(function()
if not NoclipEnabled or not character then
if NoclipConnection then
NoclipConnection:Disconnect()
NoclipConnection = nil
end
return
end
for _, part in pairs(character:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = false
end
end
end)
else
if NoclipConnection then
NoclipConnection:Disconnect()
NoclipConnection = nil
end
if character then
for _, part in pairs(character:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = true
end
end
end
end
end
local function teleportToPlayer(targetName)
local targetPlayer = Players:FindFirstChild(targetName)
if not targetPlayer then
for _, player in pairs(Players:GetPlayers()) do
if player.Name:lower():find(targetName:lower()) then
targetPlayer = player
break
end
end
end
if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
local character = LocalPlayer.Character
if character and character:FindFirstChild("HumanoidRootPart") then
local targetRoot = targetPlayer.Character.HumanoidRootPart
character:SetPrimaryPartCFrame(CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0)))
return true, "Телепортирован к " .. targetPlayer.Name
else
return false, "У вас нет персонажа"
end
else
return false, "Игрок не найден или не имеет персонажа"
end
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.Enabled = false
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 750)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -375)
mainFrame.BackgroundColor3 = Theme[CurrentTheme].Background
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 18)
uiCorner.Parent = mainFrame
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 54)
titleBar.BackgroundColor3 = Theme[CurrentTheme].Background
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Hl-ow Menu"
titleLabel.TextColor3 = Theme[CurrentTheme].Text
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = mainFrame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
titleBar.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
RunService.RenderStepped:Connect(function()
if dragging and dragInput then
local delta = dragInput.Position - dragStart
mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.92, 0, 0, 1)
divider.Position = UDim2.new(0.04, 0, 0, 54)
divider.BackgroundColor3 = Theme[CurrentTheme].Divider
divider.BorderSizePixel = 0
divider.Parent = mainFrame
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 55)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame
local tabNames = {"ESP", "AIM", "MOVEMENT", "TELEPORT", "BINDS"}
local tabButtons = {}
local contentFrames = {}
for i, name in ipairs(tabNames) do
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1/#tabNames, -4, 1, -4)
btn.Position = UDim2.new((i-1)/#tabNames, 2, 0, 2)
btn.BackgroundColor3 = (i == 1) and Theme[CurrentTheme].Accent or Theme[CurrentTheme].ToggleOff
btn.Text = name
btn.TextColor3 = Theme[CurrentTheme].Text
btn.TextSize = 14
btn.Font = Enum.Font.GothamSemibold
btn.Parent = tabBar
tabButtons[name] = btn
local cont = Instance.new("ScrollingFrame")
cont.Size = UDim2.new(1, 0, 1, -100)
cont.Position = UDim2.new(0, 0, 0, 100)
cont.BackgroundTransparency = 1
cont.Visible = (i == 1)
cont.CanvasSize = UDim2.new(0, 0, 0, 0)
cont.ScrollBarThickness = 8
cont.ScrollBarImageColor3 = Theme[CurrentTheme].Accent
cont.Parent = mainFrame
contentFrames[name] = cont
end
for name, btn in pairs(tabButtons) do
btn.MouseButton1Click:Connect(function()
for _, cont in pairs(contentFrames) do cont.Visible = false end
contentFrames[name].Visible = true
for _, b in pairs(tabButtons) do b.BackgroundColor3 = Theme[CurrentTheme].ToggleOff end
btn.BackgroundColor3 = Theme[CurrentTheme].Accent
end)
end
local function createToggle(parent, name, initial, callback, yPos)
local cont = Instance.new("Frame")
cont.Size = UDim2.new(0.92, 0, 0, 50)
cont.Position = UDim2.new(0.04, 0, 0, yPos)
cont.BackgroundTransparency = 1
cont.Parent = parent
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0.68, 0, 1, 0)
lbl.BackgroundTransparency = 1
lbl.Text = name
lbl.TextColor3 = Theme[CurrentTheme].SecondaryText
lbl.TextSize = 18
lbl.Font = Enum.Font.GothamSemibold
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.Parent = cont
local bg = Instance.new("Frame")
bg.Size = UDim2.new(0, 58, 0, 30)
bg.Position = UDim2.new(1, -78, 0.5, -15)
bg.BackgroundColor3 = initial and Theme[CurrentTheme].Accent or Theme[CurrentTheme].ToggleOff
bg.BorderSizePixel = 0
bg.Parent = cont
Instance.new("UICorner", bg).CornerRadius = UDim.new(1)
local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 24, 0, 24)
knob.Position = initial and UDim2.new(0, 30, 0.5, -12) or UDim2.new(0, 4, 0.5, -12)
knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
knob.BorderSizePixel = 0
knob.Parent = bg
Instance.new("UICorner", knob).CornerRadius = UDim.new(1)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1,0,1,0)
btn.BackgroundTransparency = 1
btn.Text = ""
btn.Parent = cont
local state = initial
btn.MouseButton1Click:Connect(function()
state = not state
bg.BackgroundColor3 = state and Theme[CurrentTheme].Accent or Theme[CurrentTheme].ToggleOff
knob:TweenPosition(state and UDim2.new(0,30,0.5,-12) or UDim2.new(0,4,0.5,-12), "Out", "Quad", 0.18, true)
callback(state)
end)
return cont
end
local function createSlider(parent, name, min, max, default, callback, yPos)
local cont = Instance.new("Frame")
cont.Size = UDim2.new(0.92, 0, 0, 60)
cont.Position = UDim2.new(0.04, 0, 0, yPos)
cont.BackgroundTransparency = 1
cont.Parent = parent
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, 0, 0, 25)
lbl.BackgroundTransparency = 1
lbl.Text = name .. ": " .. default .. "%"
lbl.TextColor3 = Theme[CurrentTheme].SecondaryText
lbl.TextSize = 16
lbl.Font = Enum.Font.GothamSemibold
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.Parent = cont
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, 0, 0, 10)
sliderBg.Position = UDim2.new(0, 0, 0, 30)
sliderBg.BackgroundColor3 = Theme[CurrentTheme].ToggleOff
sliderBg.BorderSizePixel = 0
sliderBg.Parent = cont
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(default/100, 0, 1, 0)
sliderFill.BackgroundColor3 = Theme[CurrentTheme].Accent
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
local value = default
local dragging = false
local function updateSlider(input)
local pos = input.Position.X - sliderBg.AbsolutePosition.X
local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
value = math.floor(percent * (max - min) + min)
sliderFill.Size = UDim2.new(percent, 0, 1, 0)
lbl.Text = name .. ": " .. value .. "%"
callback(value)
end
sliderBg.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
updateSlider(input)
end
end)
sliderBg.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end
end)
UserInputService.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
updateSlider(input)
end
end)
return cont
end
local function createDropdown(parent, name, options, default, callback, yPos)
local cont = Instance.new("Frame")
cont.Size = UDim2.new(0.92, 0, 0, 50)
cont.Position = UDim2.new(0.04, 0, 0, yPos)
cont.BackgroundTransparency = 1
cont.Parent = parent
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0.5, 0, 1, 0)
lbl.BackgroundTransparency = 1
lbl.Text = name
lbl.TextColor3 = Theme[CurrentTheme].SecondaryText
lbl.TextSize = 18
lbl.Font = Enum.Font.GothamSemibold
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.Parent = cont
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 120, 0, 36)
dropdown.Position = UDim2.new(1, -130, 0.5, -18)
dropdown.BackgroundColor3 = Theme[CurrentTheme].Accent
dropdown.Text = default
dropdown.TextColor3 = Color3.new(1,1,1)
dropdown.TextSize = 16
dropdown.Font = Enum.Font.GothamBold
dropdown.Parent = cont
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 8)
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 120, 0, #options * 36)
menu.Position = UDim2.new(1, -130, 1, 5)
menu.BackgroundColor3 = Theme[CurrentTheme].Background
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = cont
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)
for i, opt in ipairs(options) do
local optBtn = Instance.new("TextButton")
optBtn.Size = UDim2.new(1, 0, 0, 36)
optBtn.Position = UDim2.new(0, 0, 0, (i-1)*36)
optBtn.BackgroundColor3 = Theme[CurrentTheme].Background
optBtn.Text = opt
optBtn.TextColor3 = Theme[CurrentTheme].Text
optBtn.TextSize = 16
optBtn.Font = Enum.Font.Gotham
optBtn.Parent = menu
optBtn.MouseButton1Click:Connect(function()
dropdown.Text = opt
menu.Visible = false
callback(opt)
end)
end
dropdown.MouseButton1Click:Connect(function()
menu.Visible = not menu.Visible
end)
return cont
end
local espContent = contentFrames["ESP"]
local y = 0
createToggle(espContent, "ESP Enabled", ESPSettings.Enabled, function(v)
ESPSettings.Enabled = v
end, y).Parent = espContent
y = y + 58
createToggle(espContent, "Show Box", ESPSettings.ShowBox, function(v)
ESPSettings.ShowBox = v
end, y).Parent = espContent
y = y + 58
createToggle(espContent, "Show Name", ESPSettings.ShowName, function(v)
ESPSettings.ShowName = v
end, y).Parent = espContent
y = y + 58
createToggle(espContent, "Show HP %", ESPSettings.ShowHP, function(v)
ESPSettings.ShowHP = v
end, y).Parent = espContent
y = y + 58
local skelToggle = createToggle(espContent, "Show Skeleton", ESPSettings.ShowSkeleton, function(v)
ESPSettings.ShowSkeleton = v
end, y)
skelToggle.Parent = espContent
y = y + 58
local colorPickerFrame = Instance.new("Frame")
colorPickerFrame.Size = UDim2.new(0, 220, 0, 200)
colorPickerFrame.Position = UDim2.new(0.5, -110, 0.5, -100)
colorPickerFrame.BackgroundColor3 = Theme[CurrentTheme].Background
colorPickerFrame.BorderSizePixel = 0
colorPickerFrame.Visible = false
colorPickerFrame.Parent = screenGui
Instance.new("UICorner", colorPickerFrame).CornerRadius = UDim.new(0, 8)
local pickerTitle = Instance.new("TextLabel")
pickerTitle.Size = UDim2.new(1, 0, 0, 30)
pickerTitle.BackgroundTransparency = 1
pickerTitle.Text = "Выберите цвет скелета"
pickerTitle.TextColor3 = Theme[CurrentTheme].Text
pickerTitle.TextSize = 16
pickerTitle.Font = Enum.Font.GothamBold
pickerTitle.Parent = colorPickerFrame
local colors = {
Color3.fromRGB(255, 255, 255),
Color3.fromRGB(255, 0, 0),
Color3.fromRGB(0, 255, 0),
Color3.fromRGB(0, 0, 255),
Color3.fromRGB(255, 255, 0),
Color3.fromRGB(255, 0, 255),
Color3.fromRGB(0, 255, 255),
Color3.fromRGB(255, 128, 0),
Color3.fromRGB(128, 0, 255),
}
local colCount = 3
local btnSize = 50
local spacing = 10
for i, color in ipairs(colors) do
local row = math.floor((i-1) / colCount)
local col = (i-1) % colCount
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, btnSize, 0, btnSize)
btn.Position = UDim2.new(0, 10 + col*(btnSize+spacing), 0, 40 + row*(btnSize+spacing))
btn.BackgroundColor3 = color
btn.Text = ""
btn.Parent = colorPickerFrame
btn.MouseButton1Click:Connect(function()
ESPSettings.SkeletonColor = color
colorPickerFrame.Visible = false
if not ESPSettings.RainbowESP then
for _, data in pairs(espElements) do
for _, line in ipairs(data.skeletonLines) do
line.Color = color
end
end
end
end)
end
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Theme[CurrentTheme].Accent
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = colorPickerFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)
closeBtn.MouseButton1Click:Connect(function()
colorPickerFrame.Visible = false
end)
local skelButton = skelToggle:FindFirstChildWhichIsA("TextButton")
if skelButton then
skelButton.MouseButton2Click:Connect(function()
local absPos = skelToggle.AbsolutePosition
local absSize = skelToggle.AbsoluteSize
colorPickerFrame.Position = UDim2.new(0, absPos.X + absSize.X + 10, 0, absPos.Y)
colorPickerFrame.Visible = not colorPickerFrame.Visible
end)
end
createToggle(espContent, "Show FOV Circle", ESPSettings.ShowFOVCircle, function(v)
ESPSettings.ShowFOVCircle = v
FOVring.Visible = v
end, y).Parent = espContent
y = y + 58
createToggle(espContent, "Rainbow ESP", ESPSettings.RainbowESP, function(v)
ESPSettings.RainbowESP = v
end, y).Parent = espContent
y = y + 58
espContent.CanvasSize = UDim2.new(0, 0, 0, y)
local aimContent = contentFrames["AIM"]
y = 0
createToggle(aimContent, "Silent Aim", SilentAimSettings.Enabled, function(v)
SilentAimSettings.Enabled = v
end, y).Parent = aimContent
y = y + 58
createSlider(aimContent, "Hit Chance", 1, 100, SilentAimSettings.HitChance, function(v)
SilentAimSettings.HitChance = v
end, y).Parent = aimContent
y = y + 70
createDropdown(aimContent, "Target Part", {"Head", "Torso", "HumanoidRootPart"}, SilentAimSettings.TargetPart, function(v)
SilentAimSettings.TargetPart = v
end, y).Parent = aimContent
y = y + 60
aimContent.CanvasSize = UDim2.new(0, 0, 0, y)
local movementContent = contentFrames["MOVEMENT"]
y = 0
createToggle(movementContent, "Speed (V)", SpeedEnabled, function(v)
SpeedEnabled = v
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
local humanoid = LocalPlayer.Character.Humanoid
if SpeedEnabled then
NormalWalkSpeed = humanoid.WalkSpeed
humanoid.WalkSpeed = 28
else
humanoid.WalkSpeed = NormalWalkSpeed
end
end
end, y).Parent = movementContent
y = y + 58
createToggle(movementContent, "Fly (F)", FlyEnabled, function(v)
if v ~= FlyEnabled then
toggleFly()
end
end, y).Parent = movementContent
y = y + 58
createToggle(movementContent, "Noclip (G)", NoclipEnabled, function(v)
if v ~= NoclipEnabled then
toggleNoclip()
end
end, y).Parent = movementContent
y = y + 58
movementContent.CanvasSize = UDim2.new(0, 0, 0, y)
local teleportContent = contentFrames["TELEPORT"]
y = 10
local titleTP = Instance.new("TextLabel")
titleTP.Size = UDim2.new(0.92, 0, 0, 30)
titleTP.Position = UDim2.new(0.04, 0, 0, y)
titleTP.BackgroundTransparency = 1
titleTP.Text = "Телепорт к игроку"
titleTP.TextColor3 = Theme[CurrentTheme].Text
titleTP.TextSize = 20
titleTP.Font = Enum.Font.GothamBold
titleTP.TextXAlignment = Enum.TextXAlignment.Left
titleTP.Parent = teleportContent
y = y + 40
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.92, 0, 0, 40)
nameBox.Position = UDim2.new(0.04, 0, 0, y)
nameBox.BackgroundColor3 = Theme[CurrentTheme].ToggleOff
nameBox.Text = ""
nameBox.PlaceholderText = "Введите никнейм..."
nameBox.TextColor3 = Theme[CurrentTheme].Text
nameBox.PlaceholderColor3 = Theme[CurrentTheme].SecondaryText
nameBox.TextSize = 18
nameBox.Font = Enum.Font.Gotham
nameBox.ClearTextOnFocus = false
nameBox.Parent = teleportContent
y = y + 50
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.92, 0, 0, 30)
statusLabel.Position = UDim2.new(0.04, 0, 0, y)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Theme[CurrentTheme].SecondaryText
statusLabel.TextSize = 16
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = teleportContent
y = y + 40
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0.92, 0, 0, 50)
teleportBtn.Position = UDim2.new(0.04, 0, 0, y)
teleportBtn.BackgroundColor3 = Theme[CurrentTheme].Accent
teleportBtn.Text = "ТЕЛЕПОРТИРОВАТЬСЯ"
teleportBtn.TextColor3 = Color3.new(1,1,1)
teleportBtn.TextSize = 18
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.Parent = teleportContent
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 8)
teleportBtn.MouseButton1Click:Connect(function()
local targetName = nameBox.Text
if targetName and targetName ~= "" then
local success, message = teleportToPlayer(targetName)
statusLabel.Text = message
if success then
statusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
else
statusLabel.TextColor3 = Color3.fromRGB(220, 100, 100)
end
else
statusLabel.Text = "Введите никнейм"
statusLabel.TextColor3 = Color3.fromRGB(220, 100, 100)
end
end)
y = y + 60
teleportContent.CanvasSize = UDim2.new(0, 0, 0, y)
local bindsContent = contentFrames["BINDS"]
local bindY = 10
local listeningFor = nil
local function createBindRow(name, defaultKey)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.92, 0, 0, 50)
frame.Position = UDim2.new(0.04, 0, 0, bindY)
frame.BackgroundTransparency = 1
frame.Parent = bindsContent
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0.6, 0, 1, 0)
lbl.BackgroundTransparency = 1
lbl.Text = name
lbl.TextColor3 = Theme[CurrentTheme].SecondaryText
lbl.TextSize = 18
lbl.Font = Enum.Font.GothamSemibold
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.Parent = frame
local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0, 130, 0, 36)
keyBtn.Position = UDim2.new(1, -150, 0.5, -18)
keyBtn.BackgroundColor3 = Theme[CurrentTheme].Accent
keyBtn.Text = defaultKey and UserInputService:GetStringForKeyCode(defaultKey) or "[None]"
keyBtn.TextColor3 = Color3.new(1,1,1)
keyBtn.TextSize = 16
keyBtn.Font = Enum.Font.GothamBold
keyBtn.Parent = frame
Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0,8)
keyBtn.MouseButton1Click:Connect(function()
if listeningFor then return end
listeningFor = name
keyBtn.Text = "..."
keyBtn.BackgroundColor3 = Color3.fromRGB(100,100,255)
end)
bindY = bindY + 58
return frame
end
createBindRow("OpenMenu", Binds.OpenMenu).Parent = bindsContent
createBindRow("Aimbot (hold)", Binds.Aimbot).Parent = bindsContent
createBindRow("Silent Aim", Binds.SilentAim).Parent = bindsContent
createBindRow("Speed", Binds.Speed).Parent = bindsContent
createBindRow("Fly", Binds.Fly).Parent = bindsContent
createBindRow("Noclip", Binds.Noclip).Parent = bindsContent
bindsContent.CanvasSize = UDim2.new(0, 0, 0, bindY)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if listeningFor then
local key = input.KeyCode
if key ~= Enum.KeyCode.Unknown then
if key == Enum.KeyCode.Backspace then
Binds[listeningFor] = nil
else
Binds[listeningFor] = key
end
for _, child in ipairs(bindsContent:GetChildren()) do
if child:IsA("Frame") then
local lbl = child:FindFirstChildWhichIsA("TextLabel")
local btn = child:FindFirstChildWhichIsA("TextButton")
if lbl and btn and lbl.Text == listeningFor then
btn.Text = Binds[listeningFor] and UserInputService:GetStringForKeyCode(Binds[listeningFor]) or "[None]"
btn.BackgroundColor3 = Theme[CurrentTheme].Accent
end
end
end
listeningFor = nil
end
return
end
if input.KeyCode == Binds.OpenMenu then
screenGui.Enabled = not screenGui.Enabled
end
if input.KeyCode == Binds.SilentAim then
SilentAimSettings.Enabled = not SilentAimSettings.Enabled
for _, child in ipairs(aimContent:GetChildren()) do
if child:IsA("Frame") then
local lbl = child:FindFirstChildWhichIsA("TextLabel")
if lbl and lbl.Text == "Silent Aim" then
local bg = child:FindFirstChildWhichIsA("Frame")
local knob = bg and bg:FindFirstChildWhichIsA("Frame")
if bg and knob then
bg.BackgroundColor3 = SilentAimSettings.Enabled and Theme[CurrentTheme].Accent or Theme[CurrentTheme].ToggleOff
knob.Position = SilentAimSettings.Enabled and UDim2.new(0,30,0.5,-12) or UDim2.new(0,4,0.5,-12)
end
break
end
end
end
end
if input.KeyCode == Binds.Speed then
SpeedEnabled = not SpeedEnabled
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
local humanoid = LocalPlayer.Character.Humanoid
if SpeedEnabled then
NormalWalkSpeed = humanoid.WalkSpeed
humanoid.WalkSpeed = 28
else
humanoid.WalkSpeed = NormalWalkSpeed
end
end
end
if input.KeyCode == Binds.Fly then
toggleFly()
for _, child in ipairs(movementContent:GetChildren()) do
if child:IsA("Frame") then
local lbl = child:FindFirstChildWhichIsA("TextLabel")
if lbl and lbl.Text == "Fly (F)" then
local bg = child:FindFirstChildWhichIsA("Frame")
local knob = bg and bg:FindFirstChildWhichIsA("Frame")
if bg and knob then
bg.BackgroundColor3 = FlyEnabled and Theme[CurrentTheme].Accent or Theme[CurrentTheme].ToggleOff
knob.Position = FlyEnabled and UDim2.new(0,30,0.5,-12) or UDim2.new(0,4,0.5,-12)
end
break
end
end
end
end
if input.KeyCode == Binds.Noclip then
toggleNoclip()
for _, child in ipairs(movementContent:GetChildren()) do
if child:IsA("Frame") then
local lbl = child:FindFirstChildWhichIsA("TextLabel")
if lbl and lbl.Text == "Noclip (G)" then
local bg = child:FindFirstChildWhichIsA("Frame")
local knob = bg and bg:FindFirstChildWhichIsA("Frame")
if bg and knob then
bg.BackgroundColor3 = NoclipEnabled and Theme[CurrentTheme].Accent or Theme[CurrentTheme].ToggleOff
knob.Position = NoclipEnabled and UDim2.new(0,30,0.5,-12) or UDim2.new(0,4,0.5,-12)
end
break
end
end
end
end
end)
LocalPlayer.CharacterAdded:Connect(function(character)
if FlyEnabled then
FlyEnabled = false
if FlyConnection then
FlyConnection:Disconnect()
FlyConnection = nil
end
end
if NoclipEnabled then
NoclipEnabled = false
if NoclipConnection then
NoclipConnection:Disconnect()
NoclipConnection = nil
end
end
if SpeedEnabled then
SpeedEnabled = false
end
end)
print("Скрипт полностью загружен | Silent Aim добавлен | ESP с скелетом | Fly, Noclip, Teleport | Настраиваемые бинды")
