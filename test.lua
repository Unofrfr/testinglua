--[[
    Bypass Test Script - For Your AC Tuning
    Visual ESP + Safe Aim Assist (No hooks needed)
    Run AFTER bypass loader
]]



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espEnabled = true
local aimAssistEnabled = false
local ESPObjects = {}

print("✅ Bypass Test Loaded - ESP + Aim Assist")

-- ESP Creation
local function createESP(player)
    if ESPObjects[player] or player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Size = Vector2.new(0, 0)
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    
    local name = Drawing.new("Text")
    name.Size = 16
    name.Center = true
    name.Outline = true
    name.Font = 2
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false
    
    ESPObjects[player] = {Box = box, Name = name}
end

local function removeESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end

-- ESP Update
local function updateESP()
    for player, objs in pairs(ESPObjects) do
        task.spawn(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
                local char = player.Character
                local hrp, head = char.HumanoidRootPart, char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if hum and hum.Health > 0 and head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen and espEnabled then
                        local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                        local bottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 4, 0))
                        
                        local height = math.abs(bottom.Y - top.Y)
                        local width = height / 2
                        
                        objs.Box.Position = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
                        objs.Box.Size = Vector2.new(width, height)
                        objs.Box.Visible = true
                        
                        objs.Name.Text = player.Name
                        objs.Name.Position = Vector2.new(screenPos.X, top.Y - 16)
                        objs.Name.Visible = true
                    else
                        objs.Box.Visible = false
                        objs.Name.Visible = false
                    end
                else
                    objs.Box.Visible = false
                    objs.Name.Visible = false
                end
            end
        end)
    end
end

-- Safe Aim Assist (Smooth camera lerp, no hooks)
local function doAimAssist()
    if not aimAssistEnabled then return end
    
    local closestPlayer = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDist and dist < 100 then -- FOV limit
                    closestPlayer = player
                    shortestDist = dist
                end
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character.Head then
        local targetPos = closestPlayer.Character.Head.Position
        local cameraDir = (targetPos - Camera.CFrame.Position).Unit
        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + cameraDir)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.15) -- Smooth
    end
end

-- Toggle Toggles (T key ESP, G key Aim)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        espEnabled = not espEnabled
        print("ESP:", espEnabled and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.G then
        aimAssistEnabled = not aimAssistEnabled
        print("Aim Assist:", aimAssistEnabled and "ON" or "OFF")
    end
end)

-- Player Handling
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(createESP)
end)

Players.PlayerRemoving:Connect(removeESP)

for _, player in Players:GetPlayers() do
    if player.Character then createESP(player) end
    player.CharacterAdded:Connect(function() createESP(player) end)
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    doAimAssist()
    updateESP()
end)

print("🎮 Test Controls:")
print("- T: Toggle ESP")
print("- G: Toggle Aim Assist")
print("✅ Run cheats - watch your AC kick!")
print("(Bypass protects from basic scans)")
