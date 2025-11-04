-- Main/Lecy.lua
-- Lecy Hub v1.0 — Multi-Tool Loader & UI Hub (original)
-- Author: (isi namamu)
-- Usage:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/<username>/Lecy/main/Main/Lecy.lua"))()

-- Safety: placeholder features only. Replace TODO sections with game-specific logic
-- only if you understand rules / permissions. Do NOT paste code from other authors.

pcall(function() script.Name = "Lecy" end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    -- Wait for player to spawn (when run from executor, this usually exists)
    Players.PlayerAdded:Wait()
    localPlayer = Players.LocalPlayer
end

-- Wait for PlayerGui
localPlayer:WaitForChild("PlayerGui")

-- ======= Config =======
local CONFIG = {
    version = "1.0.0",
    owner = "<owner>",        -- set GitHub owner if you want remote load
    repo  = "Lecy",
    mainPath = "Main/Lecy.lua",
    uiName = "LecyUI",
}

-- ======= Helpers =======
local function new(inst, props)
    local obj = Instance.new(inst)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then obj.Parent = v else obj[k] = v end
        end
    end
    return obj
end

local function safePrint(...)
    pcall(function() print("[Lecy]", ...) end)
end

-- ======= Create UI =======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = CONFIG.uiName
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main window
local main = new("Frame", {
    Parent = screenGui,
    Name = "Main",
    Size = UDim2.new(0, 560, 0, 360),
    Position = UDim2.new(0.5, -280, 0.5, -180),
    BackgroundColor3 = Color3.fromRGB(22, 22, 25),
    BorderSizePixel = 0,
})
new("UICorner", {Parent = main, CornerRadius = UDim.new(0, 10)})

-- Left sidebar (tabs)
local sidebar = new("Frame", {
    Parent = main,
    Name = "Sidebar",
    Size = UDim2.new(0, 160, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(18, 18, 21),
    BorderSizePixel = 0,
})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 10)})

local title = new("TextLabel", {
    Parent = main,
    Name = "Title",
    Size = UDim2.new(1, -180, 0, 36),
    Position = UDim2.new(0, 180, 0, 10),
    BackgroundTransparency = 1,
    Text = "Lecy Hub",
    TextColor3 = Color3.fromRGB(230,230,230),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
})
local versionLabel = new("TextLabel", {
    Parent = main,
    Name = "Version",
    Size = UDim2.new(0, 120, 0, 24),
    Position = UDim2.new(1, -130, 0, 14),
    BackgroundTransparency = 1,
    Text = "v"..CONFIG.version,
    TextColor3 = Color3.fromRGB(165,165,165),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right,
})

-- Close button
local closeBtn = new("TextButton", {
    Parent = main,
    Name = "Close",
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -34, 0, 8),
    BackgroundColor3 = Color3.fromRGB(40,40,45),
    Text = "X",
    TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    BorderSizePixel = 0,
})
new("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0,6)})
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    safePrint("UI closed")
end)

-- Content area (right)
local content = new("Frame", {
    Parent = main,
    Name = "Content",
    Size = UDim2.new(1, -180, 1, -60),
    Position = UDim2.new(0, 170, 0, 46),
    BackgroundTransparency = 1,
})
-- tabs container inside sidebar
local tabs = {
    {id = "home", label = "Home"},
    {id = "tools", label = "Tools"},
    {id = "players", label = "Players"},
    {id = "settings", label = "Settings"},
}

local tabButtons = {}
local currentTab = "home"

local function createTabButton(tabInfo, y)
    local btn = new("TextButton", {
        Parent = sidebar,
        Name = "Tab_"..tabInfo.id,
        Size = UDim2.new(1, -16, 0, 40),
        Position = UDim2.new(0, 8, 0, y),
        BackgroundColor3 = Color3.fromRGB(28,28,32),
        BorderSizePixel = 0,
        Text = tabInfo.label,
        TextColor3 = Color3.fromRGB(215,215,215),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
    })
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
    btn.MouseButton1Click:Connect(function()
        for _,b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(28,28,32)
        end
        btn.BackgroundColor3 = Color3.fromRGB(65,65,70)
        currentTab = tabInfo.id
        safePrint("Tab switched to", tabInfo.label)
        -- rebuild content
        if tabInfo.id == "home" then buildHome() end
        if tabInfo.id == "tools" then buildTools() end
        if tabInfo.id == "players" then buildPlayers() end
        if tabInfo.id == "settings" then buildSettings() end
    end)
    table.insert(tabButtons, btn)
end

-- create tab buttons
for i, t in ipairs(tabs) do
    createTabButton(t, 12 + (i-1) * 48)
end

-- highlight default
tabButtons[1].BackgroundColor3 = Color3.fromRGB(65,65,70)

-- utility to clear content children
local function clearContent()
    for _,v in pairs(content:GetChildren()) do
        v:Destroy()
    end
end

-- ======= Modules state & API =======
local Modules = {} -- id -> {name, enabled, run}

local function registerModule(id, data)
    if not id or not data or not data.name or not data.run then
        return false, "invalid module"
    end
    Modules[id] = {
        id = id,
        name = data.name,
        enabled = data.enabled or false,
        run = data.run,
        meta = data.meta or {},
    }
    return true
end

local function toggleModule(id, state)
    local m = Modules[id]
    if not m then return end
    m.enabled = state
    local ok, err = pcall(function() m.run(state) end)
    if not ok then safePrint("Module error:", err) end
end

-- ======= Placeholder Modules (safe examples) =======
-- AutoFish (placeholder) — prints action; replace with actual logic for your target game
registerModule("auto_fish", {
    name = "Auto Fish",
    enabled = false,
    run = function(state)
        if state then
            safePrint("Auto Fish: started (placeholder)")
            -- sample loop stored on module state
            Modules.auto_fish._running = true
            Modules.auto_fish._thread = spawn(function()
                while Modules.auto_fish._running do
                    -- TODO: replace with game-specific detection & action
                    safePrint("Auto Fish: scanning... (placeholder)")
                    wait(2)
                end
            end)
        else
            Modules.auto_fish._running = false
            safePrint("Auto Fish: stopped")
        end
    end,
    meta = {desc = "Placeholder auto-fish. Replace detection & actions per game."},
})

-- AutoFarm (placeholder)
registerModule("auto_farm", {
    name = "Auto Farm",
    enabled = false,
    run = function(state)
        if state then
            Modules.auto_farm._running = true
            safePrint("Auto Farm: started (placeholder)")
            Modules.auto_farm._thread = spawn(function()
                while Modules.auto_farm._running do
                    -- TODO: implement safe farm contact
                    safePrint("Auto Farm: working... (placeholder)")
                    wait(3)
                end
            end)
        else
            Modules.auto_farm._running = false
            safePrint("Auto Farm: stopped")
        end
    end,
    meta = {desc = "Placeholder auto farm."},
})

-- Simple ESP (placeholder)
registerModule("esp", {
    name = "Simple ESP",
    enabled = false,
    run = function(state)
        if state then
            safePrint("ESP: enabled (placeholder)")
            -- Real ESP would use Drawing or BillboardGui and must be implemented per game
        else
            safePrint("ESP: disabled")
        end
    end,
    meta = {desc = "Simple ESP placeholder."},
})

-- Player Utilities (example)
registerModule("player_teleport", {
    name = "Teleport to Spawn",
    enabled = false,
    run = function(state)
        if state then
            safePrint("Teleport: executing (placeholder)")
            -- Example: teleport local player to workspace spawn location (if exists)
            local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildWhichIsA("SpawnLocation")
            if spawn and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    localPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,3,0)
                    safePrint("Teleported to spawn (if permitted).")
                end)
            else
                safePrint("Teleport: spawn not found or character missing.")
            end
            -- module is one-shot, so turn off immediately
            Modules.player_teleport.enabled = false
        end
    end,
    meta = {desc = "One-shot teleport to spawn (placeholder)."},
})

-- ======= Builders for each tab =======
function buildHome()
    clearContent()
    local header = new("TextLabel", {
        Parent = content,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        Text = "Welcome to Lecy Hub",
        TextColor3 = Color3.fromRGB(230,230,230),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local info = new("TextLabel", {
        Parent = content,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0,0,0,36),
        BackgroundTransparency = 1,
        Text = "Use the Tools tab to enable modules. Remote loader available in Settings.",
        TextColor3 = Color3.fromRGB(185,185,185),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    -- quick module status
    local y = 110
    for id,m in pairs(Modules) do
        local row = new("Frame", {
            Parent = content,
            Size = UDim2.new(1, 0, 0, 34),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundTransparency = 1,
        })
        local name = new("TextLabel", {
            Parent = row,
            Size = UDim2.new(0.6, -6, 1, 0),
            Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1,
            Text = m.name,
            TextColor3 = Color3.fromRGB(220,220,220),
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local status = new("TextLabel", {
            Parent = row,
            Size = UDim2.new(0.4, -6, 1, 0),
            Position = UDim2.new(0.6, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = m.enabled and "ON" or "OFF",
            TextColor3 = m.enabled and Color3.fromRGB(120, 255, 140) or Color3.fromRGB(200,200,200),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        y = y + 40
    end
end

function buildTools()
    clearContent()
    local header = new("TextLabel", {
        Parent = content,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        Text = "Tools",
        TextColor3 = Color3.fromRGB(230,230,230),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    -- list modules as toggle rows
    local y = 44
    for id,m in pairs(Modules) do
        local row = new("Frame", {
            Parent = content,
            Size = UDim2.new(1, 0, 0, 44),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundTransparency = 1,
        })
        local nm = new("TextLabel", {
            Parent = row,
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = m.name,
            TextColor3 = Color3.fromRGB(220,220,220),
            Font = Enum.Font.GothamSemibold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local toggle = new("TextButton", {
            Parent = row,
            Size = UDim2.new(0.28, 0, 0.7, 0),
            Position = UDim2.new(0.68, 0, 0.15, 0),
            BackgroundColor3 = m.enabled and Color3.fromRGB(65,200,110) or Color3.fromRGB(65,65,70),
            Text = m.enabled and "ON" or "OFF",
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            BorderSizePixel = 0,
        })
        new("UICorner", {Parent = toggle, CornerRadius = UDim.new(0,6)})
        toggle.MouseButton1Click:Connect(function()
            local newState = not m.enabled
            toggle.BackgroundColor3 = newState and Color3.fromRGB(65,200,110) or Color3.fromRGB(65,65,70)
            toggle.Text = newState and "ON" or "OFF"
            toggleModule(id, newState)
        end)
        y = y + 50
    end
end

function buildPlayers()
    clearContent()
    local header = new("TextLabel", {
        Parent = content,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        Text = "Players",
        TextColor3 = Color3.fromRGB(230,230,230),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    -- list players with a simple action
    local playersList = new("ScrollingFrame", {
        Parent = content,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 36),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
    })
    local layout = new("UIListLayout", {Parent = playersList})
    layout.Padding = UDim.new(0,8)
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local row = new("Frame", {
                Parent = playersList,
                Size = UDim2.new(1, -12, 0, 36),
                BackgroundTransparency = 1,
            })
            local name = new("TextLabel", {
                Parent = row,
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text = p.Name,
                TextColor3 = Color3.fromRGB(220,220,220),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            local tpBtn = new("TextButton", {
                Parent = row,
                Size = UDim2.new(0.34, 0, 0.7, 0),
                Position = UDim2.new(0.66, 0, 0.15, 0),
                BackgroundColor3 = Color3.fromRGB(70,70,75),
                Text = "Teleport",
                TextColor3 = Color3.fromRGB(255,255,255),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                BorderSizePixel = 0,
            })
            new("UICorner", {Parent = tpBtn, CornerRadius = UDim.new(0,6)})
            tpBtn.MouseButton1Click:Connect(function()
                -- Teleport to player's character (placeholder and may be blocked)
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        localPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                        safePrint("Teleported to", p.Name)
                    end)
                else
                    safePrint("Teleport failed: target character not available")
                end
            end)
        end
    end
    -- adjust canvas size
    playersList.CanvasSize = UDim2.new(0,0,0, (#Players:GetPlayers() - 1) * 44 + 12)
end

function buildSettings()
    clearContent()
    local header = new("TextLabel", {
        Parent = content,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        Text = "Settings & Loader",
        TextColor3 = Color3.fromRGB(230,230,230),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local label = new("TextLabel", {
        Parent = content,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0,0,0,40),
        BackgroundTransparency = 1,
        Text = "Remote loader: set CONFIG.owner to your GitHub username and host modules under Main/",
        TextColor3 = Color3.fromRGB(185,185,185),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    -- Load remote module button (example)
    local loadBtn = new("TextButton", {
        Parent = content,
        Size = UDim2.new(0, 200, 0, 36),
        Position = UDim2.new(0, 0, 0, 100),
        BackgroundColor3 = Color3.fromRGB(60,60,65),
        Text = "Load Remote Module (example)",
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
    })
    new("UICorner", {Parent = loadBtn, CornerRadius = UDim.new(0,6)})
    loadBtn.MouseButton1Click:Connect(function()
        loadBtn.Text = "Loading..."
        local owner = CONFIG.owner
        if not owner or owner == "<owner>" then
            loadBtn.Text = "Set CONFIG.owner"
            wait(1.2)
            loadBtn.Text = "Load Remote Module (example)"
            return
        end
        local remotePath = "Main/RemoteModule.lua" -- expected file in your repo
        local url = ("https://raw.githubusercontent.com/%s/%s/main/%s"):format(owner, CONFIG.repo, remotePath)
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if not ok or not res or #res == 0 then
            loadBtn.Text = "Load failed"
            safePrint("Remote load error or empty response")
            wait(1.2)
            loadBtn.Text = "Load Remote Module (example)"
            return
        end
        local ok2, func = pcall(function() return loadstring(res) end)
        if not ok2 or not func then
            loadBtn.Text = "Invalid module"
            safePrint("Remote loadstring failed")
            wait(1.2)
            loadBtn.Text = "Load Remote Module (example)"
            return
        end
        local ok3, ret = pcall(func)
        if not ok3 then
            loadBtn.Text = "Exec failed"
            safePrint("Remote execution error:", ret)
            wait(1.2)
            loadBtn.Text = "Load Remote Module (example)"
            return
        end
        -- if remote module returns a module table like {id=...,name=...,run=function...}
        if type(ret) == "table" and ret.id and ret.name and ret.run then
            registerModule(ret.id, {name = ret.name, run = ret.run, enabled = ret.enabled})
            loadBtn.Text = "Loaded"
            safePrint("Remote module loaded:", ret.name)
            wait(1.2)
            loadBtn.Text = "Load Remote Module (example)"
        else
            loadBtn.Text = "Bad payload"
            safePrint("Remote did not return module table")
            wait(1.2)
            loadBtn.Text = "Load Remote Module (example)"
        end
    end)
end

-- init default tab
buildHome()

-- Expose API globally so user can programmatically manipulate modules
_G.Lecy = {
    modules = Modules,
    registerModule = registerModule,
    toggleModule = toggleModule,
    config
