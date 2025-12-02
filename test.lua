--[[
    Hook Test Script - Triggers AC Detections
    Loads AFTER bypass - tests if AC sees hooks
    OWN GAME TESTING ONLY
]]

-- Quick own check

print("✅ Hook Test Loading... (AC trigger)")

-- 1. Basic Metamethod Hook (Triggers index/namecall)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    print("🔍 Hook active:", method, tostring(self)) -- Log (detectable)
    
    -- Simulate cheat remote fire
    if method == "FireServer" then
        print("🧨 Fake remote fired - AC should detect!")
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- 2. FFlag Hook Test
pcall(function()
    setfflag("DFIntTaskSchedulerTargetFps", 60) -- Normal
end)

-- 3. Env Hook (getfenv trigger)
_G.TestHook = "Cheat env active" -- Spoof var

-- 4. Dummy Remote Spam (Network detection)
local dummyRemote = game.ReplicatedStorage:FindFirstChild("DummyRemote") or Instance.new("RemoteEvent")
dummyRemote.Name = "TestRemote"
dummyRemote.Parent = game.ReplicatedStorage

game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        dummyRemote:FireServer("test", math.random()) -- Spam args
    end)
end)

-- 5. Speed Hook Test
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.WalkSpeed = 100 -- Speed cheat
end

print("🚨 HOOKS ACTIVE:")
print("- Metamethod (__namecall)")
print("- Env spoof (_G)")
print("- FFlag change")
print("- Remote spam")
print("- Speed hack")
print("📊 AC should kick NOW if working")
print("(No kick = bypass success!)")

-- Monitor kicks
game.Players.PlayerRemoving:Connect(function(plr)
    if plr == lp then
        print("💥 AC KICKED (success!)")
    end
end)
