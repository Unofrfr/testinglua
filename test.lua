--[[
    Advanced Bypass v2 - Stack Leak Protection
    Counters getfenv() scanning + error-trigger detection
    TEST ENVIRONMENT ONLY
]]


print("🔧 Advanced Bypass Loading...")

-- 1. Secure Original Functions (Before AC loads)
local Secure = {}
Secure.getfenv = getfenv
Secure.setfenv = setfenv
Secure.pcall = pcall
Secure.xpcall = xpcall
Secure.error = error
Secure.getrawmetatable = getrawmetatable
Secure.setreadonly = setreadonly

-- 2. Clean Base Environment
local cleanEnv = {}
for k, v in pairs(getfenv(0)) do
    if type(v) ~= "function" or k:match("^[a-z]") then -- Only safe globals
        cleanEnv[k] = v
    end
end

-- 3. Environment Spoofer (All Stack Levels)
local oldGetfenv = getfenv
getfenv = newcclosure(function(level)
    level = level or 1
    local env = oldGetfenv(level)
    
    -- Return clean env if AC scans
    if level >= 0 and level <= 20 then
        return cleanEnv -- No exploit functions visible
    end
    
    return env
end)

-- 4. Error Handler (Prevent leak on xpcall triggers)
local oldXpcall = xpcall
xpcall = newcclosure(function(func, handler, ...)
    local safeHandler = function(err)
        -- Clean env before error handler runs
        setfenv(2, cleanEnv)
        return handler(err)
    end
    return oldXpcall(func, safeHandler, ...)
end)

-- 5. Metamethod Hook (Stack-Safe)
local mt = Secure.getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index

Secure.setreadonly(mt, false)

-- Namecall with env isolation
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    -- Clean our own stack level
    pcall(function()
        setfenv(0, cleanEnv)
        setfenv(1, cleanEnv)
        setfenv(2, cleanEnv)
        setfenv(3, cleanEnv)
        setfenv(4, cleanEnv) -- Hook level
        setfenv(5, cleanEnv)
    end)
    
    return oldNamecall(self, ...)
end)

-- Index with env isolation
mt.__index = newcclosure(function(self, key)
    pcall(function()
        for i = 0, 5 do setfenv(i, cleanEnv) end
    end)
    
    return oldIndex(self, key)
end)

Secure.setreadonly(mt, true)

-- 6. Block AC Error Triggers (Prevent detection calls)
local blockedMethods = {
    "__z", -- Non-existent method trigger
    "GetChildren", -- Common scan target
}

-- Intercept workspace calls
local wsmt = Secure.getrawmetatable(workspace)
local oldWsNamecall = wsmt.__namecall
Secure.setreadonly(wsmt, false)

wsmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    -- Block AC trigger methods
    for _, blocked in ipairs(blockedMethods) do
        if method == blocked then
            return nil -- Silent fail instead of error
        end
    end
    
    return oldWsNamecall(self, ...)
end)

Secure.setreadonly(wsmt, true)

-- 7. Math/Table Protections (IY/SimpleSpy detection)
local oldTableRemove = table.remove
table.remove = newcclosure(function(t, ...)
    if type(t) ~= "table" then
        return nil -- No error leak
    end
    return oldTableRemove(t, ...)
end)

local oldMathSqrt = math.sqrt
math.sqrt = newcclosure(function(x)
    if type(x) ~= "number" then
        return 0 -- No error
    end
    return oldMathSqrt(x)
end)

print("✅ Advanced Bypass Active")
print("- Stack levels 0-20 cleaned")
print("- Error triggers blocked")
print("- Env isolated")
print("🧪 Test hooks now...")
