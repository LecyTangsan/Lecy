-- CommandExecutor (Script)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFolder = ReplicatedStorage:WaitForChild("Remote")
local FEEDBACK = remoteFolder:WaitForChild("CommandFeedback")

local AdminModule = require(script:WaitForChild("AdminModule"))

-- helpers
local function findPlayerByName(name)
    if not name then return nil end
    name = tostring(name):lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == name then return p end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) then return p end
    end
    return nil
end

-- Perintah: teleport requester ke target (cek exist)
local function cmd_teleport(requester, args)
    local targetName = args[1]
    if not targetName then return false, "Usage: tp <playerName>" end
    local target = findPlayerByName(targetName)
    if not target or not target.Character then return false, "Target not found or not spawned" end
    local trgRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local reqRoot = requester.Character and requester.Character:FindFirstChild("HumanoidRootPart")
    if not trgRoot or not reqRoot then return false, "Missing HumanoidRootPart" end
    reqRoot.CFrame = trgRoot.CFrame + Vector3.new(2,0,2)
    return true, "Teleported to "..target.Name
end

-- Perintah: infinite jump toggle (server hanya set attribute)
local function cmd_infinitejump(requester, args)
    local mode = args[1] and args[1]:lower()
    if mode == "on" then
        requester:SetAttribute("InfiniteJumpEnabled", true)
        return true, "Infinite jump enabled"
    elseif mode == "off" then
        requester:SetAttribute("InfiniteJumpEnabled", false)
        return true, "Infinite jump disabled"
    else
        return false, "Usage: ij on|off"
    end
end

-- Perintah: set speed untuk requester
local function cmd_speed(requester, args)
    local num = tonumber(args[1])
    if not num then return false, "Usage: speed <number>" end
    local MIN, MAX = 8, 200
    local s = math.clamp(num, MIN, MAX)
    local humanoid = requester.Character and requester.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = s
        return true, "WalkSpeed set to "..tostring(s)
    else
        return false, "No humanoid found"
    end
end

-- Perintah: remove ladders di radius requester
local function cmd_removeladders(requester, args)
    local radius = tonumber(args[1]) or 100
    radius = math.clamp(radius, 1, 1000)
    if not requester.Character or not requester.Character:FindFirstChild("HumanoidRootPart") then
        return false, "No character position"
    end
    local origin = requester.Character.HumanoidRootPart.Position
    local removed = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("ladder") then
            if (obj.Position - origin).Magnitude <= radius then
                obj.CanCollide = false
                obj.Transparency = 1
                delay(3, function()
                    if obj and obj.Parent then obj:Destroy() end
                end)
                removed = removed + 1
            end
        end
    end
    return true, ("Scheduled removal of %d ladder(s)"):format(removed)
end

-- daftar perintah
local COMMANDS = {
    ["tp"] = cmd_teleport,
    ["teleport"] = cmd_teleport,
    ["ij"] = cmd_infinitejump,
    ["infinitejump"] = cmd_infinitejump,
    ["speed"] = cmd_speed,
    ["rmladders"] = cmd_removeladders,
    ["removeladders"] = cmd_removeladders,
}

-- parsing
local function parseCommandLine(msg)
    local parts = {}
    for token in string.gmatch(msg, "%S+") do
        table.insert(parts, token)
    end
    local cmd = parts[1]
    if not cmd then return nil, {} end
    table.remove(parts, 1)
    return cmd:lower(), parts
end

-- prefix command: /cmd, /exec, /admin (diikuti spasi)
local COMMAND_PREFIXES = {"/cmd", "/exec", "/admin"}
local function isCommandMessage(msg)
    for _, p in ipairs(COMMAND_PREFIXES) do
        if msg:sub(1, #p):lower() == p then
            -- ambil sisanya (skip prefix + optional space)
            local rest = msg:sub(#p+1)
            if rest:sub(1,1) == " " then rest = rest:sub(2) end
            return true, rest
        end
    end
    return false, nil
end

-- send feedback ke player (via RemoteEvent ke client)
local function sendFeedback(player, text)
    if FEEDBACK and player and player:IsA("Player") then
        FEEDBACK:FireClient(player, text)
    end
end

-- handle chat
local function onPlayerChat(player, msg)
    local ok, rest = isCommandMessage(msg)
    if not ok then return end
    if not AdminModule.isAdmin(player) then
        sendFeedback(player, "Access denied: not an admin.")
        return
    end
    local cmdName, args = parseCommandLine(rest)
    if not cmdName then
        sendFeedback(player, "No command provided.")
        return
    end
    local fn = COMMANDS[cmdName]
    if not fn then
        sendFeedback(player, "Unknown command: "..cmdName)
        return
    end
    local success, res1, res2 = pcall(function() return fn(player, args) end)
    if not success then
        warn("Command error:", res1)
        sendFeedback(player, "Command error: "..tostring(res1))
        return
    end
    -- fn returns (bool, message)
    local ok2, message = res1, res2
    -- if fn returned (true,"...") it will be mapped to res1 true, res2 "..."
    if type(res1) == "boolean" and type(res2) == "string" then
        sendFeedback(player, res2)
    else
        -- fallback
        sendFeedback(player, "Command executed.")
    end
end

-- attach listeners
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        onPlayerChat(player, msg)
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(msg)
        onPlayerChat(player, msg)
    end)
end
