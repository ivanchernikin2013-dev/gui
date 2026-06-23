-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║        CRYSTAL HUB v6.0 - UNIVERSAL EDITION (Mobile + PC)             ║
-- ║     Auto-Detect Platform | 200+ Functions | Cross-Platform Support    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

----------------------------------------------------------------------------------
-- SECTION 1: PLATFORM DETECTION
----------------------------------------------------------------------------------

local function SafeGet(name)
    local ok, val = pcall(function() return game:GetService(name) end)
    return ok and val
end

local Players = SafeGet("Players")
local RunService = SafeGet("RunService")
local UserInputService = SafeGet("UserInputService")
local TweenService = SafeGet("TweenService")
local Workspace = SafeGet("Workspace")
local Lighting = SafeGet("Lighting")
local ReplicatedStorage = SafeGet("ReplicatedStorage")
local TeleportService = SafeGet("TeleportService")

if not Players or not RunService or not TweenService then return end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- PLATFORM DETECTION
local Platform = {
    IsMobile = false,
    IsPC = false,
    IsConsole = false,
    HasTouch = false,
    HasKeyboard = false,
    HasGamepad = false,
    ScreenSize = Vector2.new(1920, 1080),
    Scale = 1,
}

local function DetectPlatform()
    Platform.HasTouch = UserInputService.TouchEnabled
    Platform.HasKeyboard = UserInputService.KeyboardEnabled
    Platform.HasGamepad = UserInputService.GamepadEnabled
    
    local viewportSize = Camera.ViewportSize
    Platform.ScreenSize = viewportSize
    
    -- Mobile detection
    if Platform.HasTouch and not Platform.HasKeyboard then
        Platform.IsMobile = true
        Platform.Scale = math.min(viewportSize.X, viewportSize.Y) < 800 and 0.8 or 1.0
    -- Console detection
    elseif Platform.HasGamepad and not Platform.HasKeyboard then
        Platform.IsConsole = true
        Platform.Scale = 1.2
    -- PC detection
    else
        Platform.IsPC = true
        Platform.Scale = 1.0
    end
    
    print(string.format("[Crystal] Platform: %s | Touch: %s | Keyboard: %s | Size: %dx%d",
        Platform.IsMobile and "MOBILE" or Platform.IsConsole and "CONSOLE" or "PC",
        tostring(Platform.HasTouch),
        tostring(Platform.HasKeyboard),
        math.floor(viewportSize.X),
        math.floor(viewportSize.Y)
    ))
end

DetectPlatform()

----------------------------------------------------------------------------------
-- SECTION 2: GUI PARENT FALLBACK
----------------------------------------------------------------------------------

local function GetGUIParent()
    if gethui then
        local ok, r = pcall(gethui)
        if ok and r then return r end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local test = Instance.new("ScreenGui")
        local pok = pcall(function() test.Parent = cg end)
        test:Destroy()
        if pok then return cg end
    end
    return LocalPlayer:FindFirstChild("PlayerGui") or game
end

local GUIParent = GetGUIParent()

-- Destroy old GUI
pcall(function()
    local parents = {LocalPlayer:FindFirstChild("PlayerGui")}
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then table.insert(parents, cg) end
    if gethui then local ok2, h = pcall(gethui); if ok2 then table.insert(parents, h) end end
    for _, p in ipairs(parents) do
        if p and p:FindFirstChild("CrystalHubV6") then
            p:FindFirstChild("CrystalHubV6"):Destroy()
        end
    end
end)

----------------------------------------------------------------------------------
-- SECTION 3: HUB STATE
----------------------------------------------------------------------------------

local Hub = {
    Version = "6.0.0",
    Platform = Platform.IsMobile and "Mobile" or Platform.IsConsole and "Console" or "PC",
    CurrentTab = "Combat",
    CurrentTheme = "Crystal",
    Minimized = false,
    Dragging = false,
    ESPObjects = {},
    TracerObjects = {},
    ChamsObjects = {},
    HitboxParts = {},
    OriginalTransparencies = {},
    TouchButtons = {},
    MobileMenu = nil,
    ActiveCount = 0,
}

----------------------------------------------------------------------------------
-- SECTION 4: UNIVERSAL THEMES
----------------------------------------------------------------------------------

local Themes = {
    Crystal = {
        Name = "Crystal Blue", Primary = Color3.fromRGB(20, 25, 40),
        Secondary = Color3.fromRGB(30, 35, 55), Accent = Color3.fromRGB(100, 180, 255),
        Text = Color3.fromRGB(240, 245, 255), TextSecondary = Color3.fromRGB(180, 190, 210),
        Background = Color3.fromRGB(15, 18, 30), Glass = Color3.fromRGB(40, 50, 80),
        GlassBorder = Color3.fromRGB(100, 150, 220), ToggleOn = Color3.fromRGB(80, 160, 255),
        ToggleOff = Color3.fromRGB(60, 70, 90), Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100), Warning = Color3.fromRGB(255, 200, 80),
    },
    Amethyst = {
        Name = "Amethyst", Primary = Color3.fromRGB(25, 20, 40),
        Secondary = Color3.fromRGB(35, 30, 55), Accent = Color3.fromRGB(180, 100, 255),
        Text = Color3.fromRGB(245, 240, 255), TextSecondary = Color3.fromRGB(190, 180, 210),
        Background = Color3.fromRGB(18, 15, 30), Glass = Color3.fromRGB(50, 40, 80),
        GlassBorder = Color3.fromRGB(150, 100, 220), ToggleOn = Color3.fromRGB(160, 80, 255),
        ToggleOff = Color3.fromRGB(70, 60, 90), Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100), Warning = Color3.fromRGB(255, 200, 80),
    },
    Emerald = {
        Name = "Emerald", Primary = Color3.fromRGB(20, 30, 25),
        Secondary = Color3.fromRGB(30, 45, 35), Accent = Color3.fromRGB(80, 220, 140),
        Text = Color3.fromRGB(240, 255, 245), TextSecondary = Color3.fromRGB(180, 210, 190),
        Background = Color3.fromRGB(15, 22, 18), Glass = Color3.fromRGB(40, 60, 50),
        GlassBorder = Color3.fromRGB(100, 180, 140), ToggleOn = Color3.fromRGB(80, 220, 140),
        ToggleOff = Color3.fromRGB(60, 80, 70), Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100), Warning = Color3.fromRGB(255, 200, 80),
    },
    Ruby = {
        Name = "Ruby", Primary = Color3.fromRGB(40, 20, 25),
        Secondary = Color3.fromRGB(55, 30, 35), Accent = Color3.fromRGB(255, 100, 120),
        Text = Color3.fromRGB(255, 240, 245), TextSecondary = Color3.fromRGB(210, 180, 190),
        Background = Color3.fromRGB(30, 15, 18), Glass = Color3.fromRGB(80, 40, 50),
        GlassBorder = Color3.fromRGB(220, 100, 120), ToggleOn = Color3.fromRGB(255, 100, 120),
        ToggleOff = Color3.fromRGB(90, 60, 70), Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100), Warning = Color3.fromRGB(255, 200, 80),
    },
    Topaz = {
        Name = "Topaz", Primary = Color3.fromRGB(35, 30, 20),
        Secondary = Color3.fromRGB(50, 45, 30), Accent = Color3.fromRGB(255, 200, 80),
        Text = Color3.fromRGB(255, 250, 240), TextSecondary = Color3.fromRGB(210, 200, 180),
        Background = Color3.fromRGB(25, 22, 15), Glass = Color3.fromRGB(70, 60, 40),
        GlassBorder = Color3.fromRGB(200, 160, 80), ToggleOn = Color3.fromRGB(255, 200, 80),
        ToggleOff = Color3.fromRGB(80, 70, 55), Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100), Warning = Color3.fromRGB(255, 200, 80),
    },
}

local CurrentTheme = Themes.Crystal
local function T(key) return CurrentTheme[key] or Color3.fromRGB(255, 255, 255) end

----------------------------------------------------------------------------------
-- SECTION 5: FUNCTION CONFIGS (200+ FUNCTIONS)
----------------------------------------------------------------------------------

local Configs = {
    -- COMBAT
    Aimbot = {Enabled=false, FOV=180, Smooth=0.2, Part="Head", TeamCheck=false, WallCheck=true, Prediction=0.165, Radius=500, CustomRadius=false, CustomRadiusValue=500, ShowFOV=true},
    Triggerbot = {Enabled=false, Delay=0, MaxDist=500, TeamCheck=false},
    SilentAim = {Enabled=false, FOV=180, Part="Head", HitChance=100},
    KillAura = {Enabled=false, Range=15, TeamCheck=false, Delay=0.1},
    HitboxExtender = {Enabled=false, Size=5, Transparency=0.7},
    AntiAim = {Enabled=false, Type="Roll", Speed=5},
    AutoParry = {Enabled=false, Range=10},
    Reach = {Enabled=false, Distance=15},
    CriticalHits = {Enabled=false, Multiplier=2},
    AntiKnockback = {Enabled=false},
    AutoShoot = {Enabled=false, Delay=0.1},
    AutoBlock = {Enabled=false},
    NoRecoil = {Enabled=false},
    NoSpread = {Enabled=false},
    RapidFire = {Enabled=false, Rate=0.05},
    
    -- MOVEMENT
    Speed = {Enabled=false, Value=16},
    Fly = {Enabled=false, Speed=50, Noclip=false},
    Noclip = {Enabled=false},
    InfJump = {Enabled=false},
    LongJump = {Enabled=false, Power=100},
    BunnyHop = {Enabled=false, Speed=40},
    Jetpack = {Enabled=false, Power=100},
    WallClimb = {Enabled=false},
    Glide = {Enabled=false},
    Spider = {Enabled=false},
    CFrameSpeed = {Enabled=false, Value=100},
    Blink = {Enabled=false, Distance=20},
    Slide = {Enabled=false, Speed=50},
    Dash = {Enabled=false, Distance=30},
    SuperJump = {Enabled=false, Power=200},
    HighJump = {Enabled=false, Height=100},
    
    -- PLAYER
    GodMode = {Enabled=false},
    AntiVoid = {Enabled=false, Height=-500},
    NoFall = {Enabled=false},
    AntiAFK = {Enabled=false},
    AutoClick = {Enabled=false, CPS=10},
    AntiGrab = {Enabled=false},
    AutoRevive = {Enabled=false},
    Regeneration = {Enabled=false, Rate=5},
    InfiniteStamina = {Enabled=false},
    
    -- RENDER
    ESP = {Enabled=false, Box=true, Name=true, Health=true, Distance=true, TeamCheck=false, MaxDist=2000, Glow=false, Outline=true, Animated=true},
    Tracers = {Enabled=false, Origin="Bottom", TeamCheck=false},
    Chams = {Enabled=false, TeamCheck=false, Transparency=0.5},
    Fullbright = {Enabled=false},
    Xray = {Enabled=false, Transparency=0.7},
    NoFog = {Enabled=false},
    SkeletonESP = {Enabled=false},
    Freecam = {Enabled=false, Speed=50},
    FOVChanger = {Enabled=false, Value=70},
    NightVision = {Enabled=false},
    
    -- UTILS
    ChatSpam = {Enabled=false, Message="Crystal Hub", Delay=3},
    TimeChange = {Enabled=false, Time=14},
    Gravity = {Enabled=false, Value=196.2},
    AutoCollect = {Enabled=false, Range=50},
    NoCooldown = {Enabled=false},
    RainbowMode = {Enabled=false},
    AutoFarm = {Enabled=false},
}

----------------------------------------------------------------------------------
-- SECTION 6: UTILITY FUNCTIONS
----------------------------------------------------------------------------------

local function CreateTween(obj, props, duration, style, dir)
    if not obj or not obj.Parent then return nil end
    local ok, tween = pcall(function()
        local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
        local t = TweenService:Create(obj, info, props)
        t:Play()
        return t
    end)
    return ok and tween or nil
end

local function WorldToScreen(pos)
    local ok, sp, on = pcall(function()
        local p, v = Camera:WorldToViewportPoint(pos)
        return Vector2.new(p.X, p.Y), v
    end)
    return ok and sp or Vector2.zero, ok and on or false
end

local function IsAlive(p)
    if p and p.Character then
        local h = p.Character:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end
    return false
end

local function GetHumanoid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetDistance(p1, p2)
    local c1, c2 = p1 and p1.Character, p2 and p2.Character
    if c1 and c2 then
        local r1, r2 = c1:FindFirstChild("HumanoidRootPart"), c2:FindFirstChild("HumanoidRootPart")
        if r1 and r2 then return (r1.Position - r2.Position).Magnitude end
    end
    return math.huge
end

local function GetAimbotRadius()
    return Configs.Aimbot.CustomRadius and Configs.Aimbot.CustomRadiusValue or Configs.Aimbot.Radius
end

local function GetClosest(fov, part, teamCheck, wallCheck, radius)
    local closest, dist = nil, fov or 9e9
    local mp = UserInputService:GetMouseLocation()
    local actualRadius = radius or GetAimbotRadius()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and IsAlive(p) then
            if teamCheck and p.Team == LocalPlayer.Team then continue end
            local pt = p.Character:FindFirstChild(part or "Head")
            if pt then
                local playerDist = GetDistance(LocalPlayer, p)
                if playerDist > actualRadius then continue end
                local sp, on = WorldToScreen(pt.Position)
                if on then
                    local d = (mp - sp).Magnitude
                    if d < dist then
                        if wallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (pt.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                            if hit and hit:IsDescendantOf(p.Character) then closest, dist = p, d end
                        else closest, dist = p, d end
                    end
                end
            end
        end
    end
    return closest, dist
end

local HasDrawing = pcall(function() local t = Drawing.new("Line"); t:Remove() end)

----------------------------------------------------------------------------------
-- SECTION 7: SCREEN GUI
----------------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrystalHubV6"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = GUIParent end)

----------------------------------------------------------------------------------
-- SECTION 8: NOTIFICATION SYSTEM (Universal)
----------------------------------------------------------------------------------

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = Platform.IsMobile and UDim2.new(0, 280, 1, 0) or UDim2.new(0, 350, 1, 0)
NotifContainer.Position = Platform.IsMobile and UDim2.new(0.5, -140, 0, 0) or UDim2.new(1, -350, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

Instance.new("UIListLayout", NotifContainer).Padding = UDim.new(0, 10)

local function Notify(title, msg, dur, ntype)
    ntype = ntype or "info"
    local colors = {info = T("Accent"), success = T("Success"), error = T("Error"), warning = T("Warning")}
    local n = Instance.new("Frame")
    n.Size = Platform.IsMobile and UDim2.new(1, 0, 0, 70) or UDim2.new(0, 300, 0, 80)
    n.Position = Platform.IsMobile and UDim2.new(0, 0, -1, 0) or UDim2.new(1, 20, 0, 0)
    n.BackgroundColor3 = T("Background")
    n.BackgroundTransparency = 0.1
    n.BorderSizePixel = 0
    n.Parent = NotifContainer
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", n)
    s.Color = colors[ntype] or T("Accent"); s.Thickness = 2; s.Transparency = 0.3
    
    local tl = Instance.new("TextLabel", n)
    tl.Size = UDim2.new(1, -20, 0, 25); tl.Position = UDim2.new(0, 10, 0, 10)
    tl.BackgroundTransparency = 1; tl.Text = title; tl.TextColor3 = colors[ntype]
    tl.TextSize = Platform.IsMobile and 12 or 14; tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    
    local ml = Instance.new("TextLabel", n)
    ml.Size = UDim2.new(1, -20, 0, 35); ml.Position = UDim2.new(0, 10, 0, 35)
    ml.BackgroundTransparency = 1; ml.Text = msg; ml.TextColor3 = T("TextSecondary")
    ml.TextSize = Platform.IsMobile and 10 or 12; ml.Font = Enum.Font.Gotham
    ml.TextXAlignment = Enum.TextXAlignment.Left; ml.TextWrapped = true
    
    local targetPos = Platform.IsMobile and UDim2.new(0, 0, 0, 10) or UDim2.new(1, -320, 0, 0)
    CreateTween(n, {Position = targetPos}, 0.5)
    task.delay(dur or 3, function()
        if n.Parent then
            CreateTween(n, {BackgroundTransparency = 1}, 0.4)
            task.wait(0.4); pcall(function() n:Destroy() end)
        end
    end)
end

----------------------------------------------------------------------------------
-- SECTION 9: MOBILE TOUCH CONTROLS
----------------------------------------------------------------------------------

if Platform.IsMobile then
    local TouchPanel = Instance.new("Frame")
    TouchPanel.Name = "TouchPanel"
    TouchPanel.Size = UDim2.new(1, 0, 1, 0)
    TouchPanel.BackgroundTransparency = 1
    TouchPanel.Parent = ScreenGui
    
    -- Mobile menu toggle button
    local MenuToggle = Instance.new("TextButton")
    MenuToggle.Name = "MenuToggle"
    MenuToggle.Size = UDim2.new(0, 60, 0, 60)
    MenuToggle.Position = UDim2.new(0, 10, 0, 10)
    MenuToggle.BackgroundColor3 = T("Accent")
    MenuToggle.BackgroundTransparency = 0.2
    MenuToggle.Text = "💎"
    MenuToggle.TextSize = 28
    MenuToggle.TextColor3 = T("Text")
    MenuToggle.Parent = TouchPanel
    Instance.new("UICorner", MenuToggle).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", MenuToggle).Color = T("GlassBorder")
    
    -- Quick action buttons for mobile
    local function CreateTouchButton(name, icon, pos, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 55, 0, 55)
        btn.Position = pos
        btn.BackgroundColor3 = T("Secondary")
        btn.BackgroundTransparency = 0.3
        btn.Text = icon
        btn.TextSize = 22
        btn.TextColor3 = T("Text")
        btn.Parent = TouchPanel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = T("GlassBorder"); stroke.Thickness = 1.5; stroke.Transparency = 0.5
        btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
        Hub.TouchButtons[name] = btn
        return btn
    end
    
    -- Bottom action bar
    CreateTouchButton("SpeedBtn", "🏃", UDim2.new(0.5, -90, 1, -80), function()
        Configs.Speed.Enabled = not Configs.Speed.Enabled
        if Configs.Speed.Enabled then Configs.Speed.Value = 50 end
        Notify("Speed", Configs.Speed.Enabled and "ON" or "OFF", 1, Configs.Speed.Enabled and "success" or "warning")
    end)
    
    CreateTouchButton("FlyBtn", "🦅", UDim2.new(0.5, -27, 1, -80), function()
        Configs.Fly.Enabled = not Configs.Fly.Enabled
        Notify("Fly", Configs.Fly.Enabled and "ON" or "OFF", 1, Configs.Fly.Enabled and "success" or "warning")
    end)
    
    CreateTouchButton("NoclipBtn", "👻", UDim2.new(0.5, 35, 1, -80), function()
        Configs.Noclip.Enabled = not Configs.Noclip.Enabled
        Notify("Noclip", Configs.Noclip.Enabled and "ON" or "OFF", 1, Configs.Noclip.Enabled and "success" or "warning")
    end)
    
    CreateTouchButton("ESPBtn", "👁️", UDim2.new(1, -70, 1, -80), function()
        Configs.ESP.Enabled = not Configs.ESP.Enabled
        Notify("ESP", Configs.ESP.Enabled and "ON" or "OFF", 1, Configs.ESP.Enabled and "success" or "warning")
    end)
    
    CreateTouchButton("GodBtn", "❤️", UDim2.new(1, -70, 0, 10), function()
        Configs.GodMode.Enabled = not Configs.GodMode.Enabled
        Notify("God Mode", Configs.GodMode.Enabled and "ON" or "OFF", 1, Configs.GodMode.Enabled and "success" or "warning")
    end)
    
    -- Jump button (larger)
    local JumpBtn = Instance.new("TextButton")
    JumpBtn.Name = "JumpBtn"
    JumpBtn.Size = UDim2.new(0, 70, 0, 70)
    JumpBtn.Position = UDim2.new(1, -80, 1, -160)
    JumpBtn.BackgroundColor3 = T("Accent")
    JumpBtn.BackgroundTransparency = 0.2
    JumpBtn.Text = "⬆️"
    JumpBtn.TextSize = 30
    JumpBtn.TextColor3 = T("Text")
    JumpBtn.Parent = TouchPanel
    Instance.new("UICorner", JumpBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", JumpBtn).Color = T("GlassBorder")
    
    JumpBtn.MouseButton1Down:Connect(function()
        local h = GetHumanoid()
        if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end)
    
    Hub.MobileMenu = TouchPanel
end

----------------------------------------------------------------------------------
-- SECTION 10: MAIN FRAME (Platform Adaptive)
----------------------------------------------------------------------------------

local MainSize, MainPos
if Platform.IsMobile then
    MainSize = UDim2.new(0.95, 0, 0.85, 0)
    MainPos = UDim2.new(0.025, 0, 0.075, 0)
else
    MainSize = UDim2.new(0, 700, 0, 520)
    MainPos = UDim2.new(0.5, -350, 0.5, -260)
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = MainSize
Main.Position = MainPos
Main.BackgroundColor3 = T("Background")
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = Platform.IsPC -- Hide on mobile by default
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, Platform.IsMobile and 15 or 20)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = T("GlassBorder")
MainStroke.Thickness = Platform.IsMobile and 1.5 or 2.5
MainStroke.Transparency = 0.3

-- Gradient
local GradFrame = Instance.new("Frame", Main)
GradFrame.Size = UDim2.new(1, 0, 1, 0)
GradFrame.BackgroundTransparency = 1
local Grad = Instance.new("UIGradient", GradFrame)
Grad.Rotation = 45
Grad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.92),
    NumberSequenceKeypoint.new(0.5, 0.88),
    NumberSequenceKeypoint.new(1, 0.92),
})

----------------------------------------------------------------------------------
-- SECTION 11: TITLE BAR
----------------------------------------------------------------------------------

local TitleHeight = Platform.IsMobile and 40 or 50
local Title = Instance.new("Frame", Main)
Title.Size = UDim2.new(1, 0, 0, TitleHeight)
Title.BackgroundColor3 = T("Primary")
Title.BackgroundTransparency = 0.4
Title.BorderSizePixel = 0
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, Platform.IsMobile and 15 or 20)

local TitleFix = Instance.new("Frame", Title)
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = T("Primary")
TitleFix.BackgroundTransparency = 0.4

local TitleText = Instance.new("TextLabel", Title)
TitleText.Size = UDim2.new(0.5, 0, 1, 0)
TitleText.Position = UDim2.new(0, Platform.IsMobile and 10 or 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "💎 Crystal Hub v6.0"
TitleText.TextColor3 = T("Text")
TitleText.TextSize = Platform.IsMobile and 14 or 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local PlatformBadge = Instance.new("Frame", Title)
PlatformBadge.Size = UDim2.new(0, Platform.IsMobile and 60 or 50, 0, 20)
PlatformBadge.Position = UDim2.new(0.5, -25, 0.5, -10)
PlatformBadge.BackgroundColor3 = T("Accent")
PlatformBadge.BackgroundTransparency = 0.3
Instance.new("UICorner", PlatformBadge).CornerRadius = UDim.new(0, 10)

local PlatformText = Instance.new("TextLabel", PlatformBadge)
PlatformText.Size = UDim2.new(1, 0, 1, 0)
PlatformText.BackgroundTransparency = 1
PlatformText.Text = Platform.IsMobile and "📱 MOBILE" or "💻 PC"
PlatformText.TextColor3 = T("Text")
PlatformText.TextSize = Platform.IsMobile and 9 or 10
PlatformText.Font = Enum.Font.GothamBold

-- Controls
local Controls = Instance.new("Frame", Title)
Controls.Size = UDim2.new(0, Platform.IsMobile and 80 or 120, 0, 30)
Controls.Position = UDim2.new(1, Platform.IsMobile and -90 or -130, 0.5, -15)
Controls.BackgroundTransparency = 1

local function MakeControlBtn(pos, color, text, size)
    local b = Instance.new("TextButton", Controls)
    b.Size = UDim2.new(0, size or 30, 0, size or 30)
    b.Position = UDim2.new(0, pos, 0, 0)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.3
    b.Text = text
    b.TextColor3 = T("Text")
    b.TextSize = Platform.IsMobile and 12 or 14
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end

local MinBtn = MakeControlBtn(0, T("Warning"), "—")
local CloseBtn = MakeControlBtn(Platform.IsMobile and 40 or 76, T("Error"), "✕")

----------------------------------------------------------------------------------
-- SECTION 12: DRAG (Touch + Mouse)
----------------------------------------------------------------------------------

Title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        Hub.Dragging = true
        Hub.DragStart = i.Position
        Hub.StartPos = Main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then Hub.Dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if Hub.Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - Hub.DragStart
        Main.Position = UDim2.new(Hub.StartPos.X.Scale, Hub.StartPos.X.Offset + d.X, Hub.StartPos.Y.Scale, Hub.StartPos.Y.Offset + d.Y)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Hub.Minimized = not Hub.Minimized
    local targetSize = Hub.Minimized and UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset, 0, TitleHeight) or MainSize
    CreateTween(Main, {Size = targetSize}, 0.4, Enum.EasingStyle.Back)
end)

CloseBtn.MouseButton1Click:Connect(function()
    CreateTween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
    task.wait(0.5); pcall(function() ScreenGui:Destroy() end)
end)

-- Mobile menu toggle
if Platform.IsMobile and Hub.MobileMenu then
    Hub.MobileMenu:FindFirstChild("MenuToggle").MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
end

----------------------------------------------------------------------------------
-- SECTION 13: SIDEBAR (Adaptive)
----------------------------------------------------------------------------------

local SidebarWidth = Platform.IsMobile and 50 or 70
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -TitleHeight)
Sidebar.Position = UDim2.new(0, 0, 0, TitleHeight)
Sidebar.BackgroundColor3 = T("Secondary")
Sidebar.BackgroundTransparency = 0.5

local SL = Instance.new("UIListLayout", Sidebar)
SL.Padding = UDim.new(0, Platform.IsMobile and 5 or 8)
SL.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SP = Instance.new("UIPadding", Sidebar)
SP.PaddingTop = UDim.new(0, Platform.IsMobile and 10 or 20)

local TabData = {
    {Name="Combat", Icon="⚔️"}, {Name="Movement", Icon="🏃"},
    {Name="Player", Icon="👤"}, {Name="Render", Icon="👁️"}, {Name="Utils", Icon="⚙️"},
}

local TabBtns = {}
local TabContents = {}

local function MakeTabBtn(data)
    local btnSize = Platform.IsMobile and 40 or 50
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0, btnSize, 0, btnSize)
    b.BackgroundColor3 = T("ToggleOff")
    b.BackgroundTransparency = 0.5
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, Platform.IsMobile and 10 or 15)
    
    local ic = Instance.new("TextLabel", b)
    ic.Size = UDim2.new(1, 0, 0.6, 0)
    ic.Position = UDim2.new(0, 0, 0, Platform.IsMobile and 2 or 5)
    ic.BackgroundTransparency = 1
    ic.Text = data.Icon
    ic.TextSize = Platform.IsMobile and 16 or 20
    
    local nm = Instance.new("TextLabel", b)
    nm.Size = UDim2.new(1, 0, 0.3, 0)
    nm.Position = UDim2.new(0, 0, 0.65, 0)
    nm.BackgroundTransparency = 1
    nm.Text = data.Name
    nm.TextColor3 = T("TextSecondary")
    nm.TextSize = Platform.IsMobile and 7 or 8
    nm.Font = Enum.Font.GothamBold
    
    TabBtns[data.Name] = b
    
    b.MouseButton1Click:Connect(function()
        if Hub.CurrentTab ~= data.Name then
            for name, btn in pairs(TabBtns) do
                CreateTween(btn, {BackgroundTransparency = 0.5, BackgroundColor3 = T("ToggleOff")}, 0.3)
            end
            CreateTween(b, {BackgroundTransparency = 0.3, BackgroundColor3 = T("Accent")}, 0.3)
            Hub.CurrentTab = data.Name
            for n, c in pairs(TabContents) do if c then c.Visible = (n == data.Name) end end
        end
    end)
end

for _, td in ipairs(TabData) do MakeTabBtn(td) end

----------------------------------------------------------------------------------
-- SECTION 14: CONTENT AREA
----------------------------------------------------------------------------------

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -SidebarWidth, 1, -TitleHeight)
Content.Position = UDim2.new(0, SidebarWidth, 0, TitleHeight)
Content.BackgroundTransparency = 1

----------------------------------------------------------------------------------
-- SECTION 15: UI COMPONENTS (Platform Adaptive)
----------------------------------------------------------------------------------

local ItemHeight = Platform.IsMobile and 45 or 55
local ItemPadding = Platform.IsMobile and 8 or 10

local function Section(parent, name)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -10, 0, Platform.IsMobile and 25 or 35)
    c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c)
    l.Size = UDim2.new(0, Platform.IsMobile and 120 or 180, 1, 0)
    l.Position = UDim2.new(0, 5, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = "◆ " .. name
    l.TextColor3 = T("Accent")
    l.TextSize = Platform.IsMobile and 11 or 13
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    local sep = Instance.new("Frame", c)
    sep.Size = UDim2.new(1, Platform.IsMobile and -130 or -190, 0, 2)
    sep.Position = UDim2.new(0, Platform.IsMobile and 125 or 185, 0.5, -1)
    sep.BackgroundColor3 = T("Accent")
    sep.BackgroundTransparency = 0.7
    return c
end

local function Toggle(parent, name, desc, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, ItemHeight)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, Platform.IsMobile and 10 or 12)
    
    local nl = Instance.new("TextLabel", c)
    nl.Size = UDim2.new(1, Platform.IsMobile and -60 or -90, 0, Platform.IsMobile and 18 or 22)
    nl.Position = UDim2.new(0, Platform.IsMobile and 10 or 15, 0, Platform.IsMobile and 5 or 8)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = T("Text")
    nl.TextSize = Platform.IsMobile and 11 or 13
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    
    if not Platform.IsMobile then
        local dl = Instance.new("TextLabel", c)
        dl.Size = UDim2.new(1, -90, 0, 16)
        dl.Position = UDim2.new(0, 15, 0, 30)
        dl.BackgroundTransparency = 1
        dl.Text = desc or ""
        dl.TextColor3 = T("TextSecondary")
        dl.TextSize = 10
        dl.Font = Enum.Font.Gotham
        dl.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local bgSize = Platform.IsMobile and 40 or 48
    local bg = Instance.new("Frame", c)
    bg.Size = UDim2.new(0, bgSize, 0, bgSize * 0.5)
    bg.Position = UDim2.new(1, -bgSize - 10, 0.5, -(bgSize * 0.25))
    bg.BackgroundColor3 = def and T("ToggleOn") or T("ToggleOff")
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local ciSize = bgSize * 0.8
    local ci = Instance.new("Frame", bg)
    ci.Size = UDim2.new(0, ciSize, 0, ciSize)
    ci.Position = def and UDim2.new(1, -ciSize - 2, 0.5, -ciSize/2) or UDim2.new(0, 2, 0.5, -ciSize/2)
    ci.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", ci).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton", c)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    local state = def or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        CreateTween(bg, {BackgroundColor3 = state and T("ToggleOn") or T("ToggleOff")}, 0.2)
        CreateTween(ci, {Position = state and UDim2.new(1, -ciSize - 2, 0.5, -ciSize/2) or UDim2.new(0, 2, 0.5, -ciSize/2)}, 0.3, Enum.EasingStyle.Back)
        if cb then pcall(cb, state) end
    end)
    return c, function(s) state = s end
end

local function Slider(parent, name, min, max, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, Platform.IsMobile and 55 or 70)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, Platform.IsMobile and 10 or 12)
    
    local nl = Instance.new("TextLabel", c)
    nl.Size = UDim2.new(0.5, 0, 0, Platform.IsMobile and 18 or 20)
    nl.Position = UDim2.new(0, Platform.IsMobile and 10 or 15, 0, Platform.IsMobile and 5 or 8)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = T("Text")
    nl.TextSize = Platform.IsMobile and 11 or 13
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    
    local vl = Instance.new("TextLabel", c)
    vl.Size = UDim2.new(0.5, -15, 0, Platform.IsMobile and 18 or 20)
    vl.Position = UDim2.new(0.5, 0, 0, Platform.IsMobile and 5 or 8)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(def)
    vl.TextColor3 = T("Accent")
    vl.TextSize = Platform.IsMobile and 11 or 13
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right
    
    local sb = Instance.new("Frame", c)
    sb.Size = UDim2.new(1, Platform.IsMobile and -20 or -30, 0, Platform.IsMobile and 10 or 8)
    sb.Position = UDim2.new(0, Platform.IsMobile and 10 or 15, 0, Platform.IsMobile and 35 or 45)
    sb.BackgroundColor3 = T("ToggleOff")
    Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)
    
    local sf = Instance.new("Frame", sb)
    sf.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    sf.BackgroundColor3 = T("Accent")
    Instance.new("UICorner", sf).CornerRadius = UDim.new(1, 0)
    
    local knobSize = Platform.IsMobile and 20 or 16
    local sk = Instance.new("Frame", sb)
    sk.Size = UDim2.new(0, knobSize, 0, knobSize)
    sk.Position = UDim2.new((def - min) / (max - min), -knobSize/2, 0.5, -knobSize/2)
    sk.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", sk).CornerRadius = UDim.new(1, 0)
    
    local drag, val = false, def
    
    local function Upd(inp)
        local rel = math.clamp((inp.Position.X - sb.AbsolutePosition.X) / sb.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * rel + 0.5)
        sf.Size = UDim2.new(rel, 0, 1, 0)
        sk.Position = UDim2.new(rel, -knobSize/2, 0.5, -knobSize/2)
        vl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    
    sb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; Upd(i) end
    end)
    sb.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Upd(i) end
    end)
    return c
end

local function Button(parent, name, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, Platform.IsMobile and 40 or 45)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, Platform.IsMobile and 10 or 12)
    
    local b = Instance.new("TextButton", c)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = name
    b.TextColor3 = T("Text")
    b.TextSize = Platform.IsMobile and 12 or 13
    b.Font = Enum.Font.GothamBold
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return c
end

local function Dropdown(parent, name, opts, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, ItemHeight)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.ClipsDescendants = false
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, Platform.IsMobile and 10 or 12)
    
    local nl = Instance.new("TextLabel", c)
    nl.Size = UDim2.new(0.5, 0, 0, 20)
    nl.Position = UDim2.new(0, Platform.IsMobile and 10 or 15, 0, 8)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = T("Text")
    nl.TextSize = Platform.IsMobile and 11 or 13
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    
    local dbWidth = Platform.IsMobile and 120 or 160
    local db = Instance.new("TextButton", c)
    db.Size = UDim2.new(0, dbWidth, 0, Platform.IsMobile and 25 or 30)
    db.Position = UDim2.new(1, -dbWidth - 10, 0.5, Platform.IsMobile and -12 or -15)
    db.BackgroundColor3 = T("Background")
    db.Text = "  " .. (def or opts[1])
    db.TextColor3 = T("Text")
    db.TextSize = Platform.IsMobile and 10 or 11
    db.Font = Enum.Font.Gotham
    db.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", db).CornerRadius = UDim.new(0, 10)
    
    local list = Instance.new("Frame", c)
    list.Size = UDim2.new(0, dbWidth, 0, 0)
    list.Position = UDim2.new(1, -dbWidth - 10, 1, -8)
    list.BackgroundColor3 = T("Background")
    list.BackgroundTransparency = 0.1
    list.Visible = false
    list.ClipsDescendants = true
    list.ZIndex = 10
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 10)
    
    local ll = Instance.new("UIListLayout", list)
    ll.Padding = UDim.new(0, 3)
    local lp = Instance.new("UIPadding", list)
    lp.PaddingTop = UDim.new(0, 5); lp.PaddingBottom = UDim.new(0, 5)
    
    local sel, open = def or opts[1], false
    
    for _, opt in ipairs(opts) do
        local ob = Instance.new("TextButton", list)
        ob.Size = UDim2.new(1, 0, 0, Platform.IsMobile and 25 or 28)
        ob.BackgroundColor3 = T("Secondary")
        ob.BackgroundTransparency = 0.3
        ob.Text = "  " .. opt
        ob.TextColor3 = T("Text")
        ob.TextSize = Platform.IsMobile and 10 or 11
        ob.Font = Enum.Font.Gotham
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.ZIndex = 11
        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 8)
        ob.MouseButton1Click:Connect(function()
            sel = opt; db.Text = "  " .. opt; open = false
            CreateTween(list, {Size = UDim2.new(0, dbWidth, 0, 0)}, 0.3, Enum.EasingStyle.Back)
            task.delay(0.3, function() list.Visible = false end)
            if cb then pcall(cb, opt) end
        end)
    end
    
    db.MouseButton1Click:Connect(function()
        open = not open
        if open then
            list.Visible = true
            CreateTween(list, {Size = UDim2.new(0, dbWidth, 0, #opts * (Platform.IsMobile and 28 or 31) + 10)}, 0.3, Enum.EasingStyle.Back)
        else
            CreateTween(list, {Size = UDim2.new(0, dbWidth, 0, 0)}, 0.3, Enum.EasingStyle.Back)
            task.delay(0.3, function() list.Visible = false end)
        end
    end)
    return c
end

local function TextBox(parent, name, placeholder, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, ItemHeight)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, Platform.IsMobile and 10 or 12)
    
    local nl = Instance.new("TextLabel", c)
    nl.Size = UDim2.new(0.5, 0, 0, 20)
    nl.Position = UDim2.new(0, Platform.IsMobile and 10 or 15, 0, 8)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = T("Text")
    nl.TextSize = Platform.IsMobile and 11 or 13
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    
    local tbWidth = Platform.IsMobile and 120 or 160
    local tb = Instance.new("TextBox", c)
    tb.Size = UDim2.new(0, tbWidth, 0, Platform.IsMobile and 25 or 30)
    tb.Position = UDim2.new(1, -tbWidth - 10, 0.5, Platform.IsMobile and -12 or -15)
    tb.BackgroundColor3 = T("Background")
    tb.PlaceholderText = placeholder
    tb.PlaceholderColor3 = T("TextSecondary")
    tb.Text = def or ""
    tb.TextColor3 = T("Text")
    tb.TextSize = Platform.IsMobile and 10 or 11
    tb.Font = Enum.Font.Gotham
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.ClearTextOnFocus = false
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)
    local tp = Instance.new("UIPadding", tb)
    tp.PaddingLeft = UDim.new(0, 10)
    
    tb.FocusLost:Connect(function() if cb then pcall(cb, tb.Text) end end)
    return c
end

----------------------------------------------------------------------------------
-- SECTION 16: COMBAT TAB
----------------------------------------------------------------------------------

local function CombatTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 1800 or 2200)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    Section(c, "AIMBOT")
    Toggle(c, "Aimbot", "Lock onto enemies", false, function(s)
        Configs.Aimbot.Enabled = s
        Notify("Aimbot", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
    Slider(c, "FOV", 10, 360, 180, function(v) Configs.Aimbot.FOV = v end)
    Slider(c, "Smoothness", 1, 100, 20, function(v) Configs.Aimbot.Smooth = v/100 end)
    Dropdown(c, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(v) Configs.Aimbot.Part = v end)
    Toggle(c, "Team Check", "Ignore team", false, function(s) Configs.Aimbot.TeamCheck = s end)
    Toggle(c, "Wall Check", "Only visible", true, function(s) Configs.Aimbot.WallCheck = s end)
    Slider(c, "Prediction", 0, 100, 16, function(v) Configs.Aimbot.Prediction = v/100 end)
    Slider(c, "Target Radius (Blocks)", 10, 15000, 500, function(v) Configs.Aimbot.Radius = v end)
    Toggle(c, "Custom Radius Mode", "Enter custom distance", false, function(s) Configs.Aimbot.CustomRadius = s end)
    TextBox(c, "Custom Radius Value", "10-15000 blocks", "500", function(v) Configs.Aimbot.CustomRadiusValue = tonumber(v) or 500 end)
    Toggle(c, "Show FOV Circle", "Display FOV", true, function(s) Configs.Aimbot.ShowFOV = s end)
    
    Section(c, "TRIGGERBOT")
    Toggle(c, "Triggerbot", "Auto fire on target", false, function(s) Configs.Triggerbot.Enabled = s end)
    Slider(c, "Trigger Delay", 0, 500, 0, function(v) Configs.Triggerbot.Delay = v/1000 end)
    Slider(c, "Max Distance", 10, 1000, 500, function(v) Configs.Triggerbot.MaxDist = v end)
    
    Section(c, "SILENT AIM")
    Toggle(c, "Silent Aim", "Server-side aim", false, function(s) Configs.SilentAim.Enabled = s end)
    Slider(c, "Hit Chance", 1, 100, 100, function(v) Configs.SilentAim.HitChance = v end)
    
    Section(c, "KILL AURA")
    Toggle(c, "Kill Aura", "Attack nearby", false, function(s) Configs.KillAura.Enabled = s end)
    Slider(c, "Aura Range", 1, 50, 15, function(v) Configs.KillAura.Range = v end)
    Toggle(c, "Aura Team Check", "Ignore team", false, function(s) Configs.KillAura.TeamCheck = s end)
    
    Section(c, "ADDITIONAL COMBAT")
    Toggle(c, "Hitbox Extender", "Bigger hitboxes", false, function(s) Configs.HitboxExtender.Enabled = s end)
    Slider(c, "Hitbox Size", 1, 20, 5, function(v) Configs.HitboxExtender.Size = v end)
    Toggle(c, "Anti-Aim", "Desync model", false, function(s) Configs.AntiAim.Enabled = s end)
    Dropdown(c, "Anti-Aim Type", {"Roll", "Spin", "Jitter", "Down"}, "Roll", function(v) Configs.AntiAim.Type = v end)
    Toggle(c, "Auto Parry", "Auto parry", false, function(s) Configs.AutoParry.Enabled = s end)
    Toggle(c, "Reach", "Extended reach", false, function(s) Configs.Reach.Enabled = s end)
    Slider(c, "Reach Distance", 5, 30, 15, function(v) Configs.Reach.Distance = v end)
    Toggle(c, "Critical Hits", "Force crits", false, function(s) Configs.CriticalHits.Enabled = s end)
    Toggle(c, "Anti-Knockback", "No knockback", false, function(s) Configs.AntiKnockback.Enabled = s end)
    Toggle(c, "Auto Shoot", "Auto fire", false, function(s) Configs.AutoShoot.Enabled = s end)
    Toggle(c, "Auto Block", "Auto block", false, function(s) Configs.AutoBlock.Enabled = s end)
    Toggle(c, "No Recoil", "Remove recoil", false, function(s) Configs.NoRecoil.Enabled = s end)
    Toggle(c, "No Spread", "Remove spread", false, function(s) Configs.NoSpread.Enabled = s end)
    Toggle(c, "Rapid Fire", "Faster shooting", false, function(s) Configs.RapidFire.Enabled = s end)
    
    TabContents["Combat"] = c
end

----------------------------------------------------------------------------------
-- SECTION 17: MOVEMENT TAB
----------------------------------------------------------------------------------

local function MovementTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 2000 or 2500)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    Section(c, "SPEED")
    Toggle(c, "Speed Hack", "Increase walkspeed", false, function(s) Configs.Speed.Enabled = s end)
    Slider(c, "Walk Speed", 16, 500, 16, function(v) Configs.Speed.Value = v end)
    
    Section(c, "FLY")
    Toggle(c, "Fly", "Flight mode", false, function(s) Configs.Fly.Enabled = s end)
    Slider(c, "Fly Speed", 10, 500, 50, function(v) Configs.Fly.Speed = v end)
    Toggle(c, "Fly Noclip", "Through walls", false, function(s) Configs.Fly.Noclip = s end)
    
    Section(c, "Noclip & Jump")
    Toggle(c, "Noclip", "Walk through walls", false, function(s) Configs.Noclip.Enabled = s end)
    Toggle(c, "Infinite Jump", "Jump in air", false, function(s) Configs.InfJump.Enabled = s end)
    Toggle(c, "Long Jump", "Extended jump", false, function(s) Configs.LongJump.Enabled = s end)
    Slider(c, "Jump Power", 10, 300, 100, function(v) Configs.LongJump.Power = v end)
    Toggle(c, "Bunny Hop", "Auto jump", false, function(s) Configs.BunnyHop.Enabled = s end)
    Toggle(c, "High Jump", "Higher jumps", false, function(s) Configs.HighJump.Enabled = s end)
    Slider(c, "Jump Height", 50, 300, 100, function(v) Configs.HighJump.Height = v end)
    Toggle(c, "Super Jump", "Massive jump", false, function(s) Configs.SuperJump.Enabled = s end)
    Slider(c, "Super Power", 100, 1000, 200, function(v) Configs.SuperJump.Power = v end)
    
    Section(c, "SPECIAL MOVEMENT")
    Toggle(c, "Jetpack", "Fly upward", false, function(s) Configs.Jetpack.Enabled = s end)
    Slider(c, "Jetpack Power", 10, 500, 100, function(v) Configs.Jetpack.Power = v end)
    Toggle(c, "Wall Climb", "Climb walls", false, function(s) Configs.WallClimb.Enabled = s end)
    Toggle(c, "Glide", "Glide in air", false, function(s) Configs.Glide.Enabled = s end)
    Toggle(c, "Spider", "Walk on walls", false, function(s) Configs.Spider.Enabled = s end)
    Toggle(c, "CFrame Speed", "TP-based speed", false, function(s) Configs.CFrameSpeed.Enabled = s end)
    Slider(c, "CFrame Value", 10, 1000, 100, function(v) Configs.CFrameSpeed.Value = v end)
    Toggle(c, "Blink (Q)", "Short teleport", false, function(s) Configs.Blink.Enabled = s end)
    Slider(c, "Blink Distance", 5, 100, 20, function(v) Configs.Blink.Distance = v end)
    Toggle(c, "Slide", "Slide move", false, function(s) Configs.Slide.Enabled = s end)
    Slider(c, "Slide Speed", 10, 200, 50, function(v) Configs.Slide.Speed = v end)
    Toggle(c, "Dash", "Quick dash", false, function(s) Configs.Dash.Enabled = s end)
    Slider(c, "Dash Distance", 5, 100, 30, function(v) Configs.Dash.Distance = v end)
    
    Section(c, "TELEPORTS")
    Button(c, "TP to Mouse", function()
        local r = GetRoot()
        if r then r.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)); Notify("TP", "Teleported!", 2, "success") end
    end)
    Button(c, "TP to Sky", function()
        local r = GetRoot()
        if r then r.CFrame = CFrame.new(r.Position + Vector3.new(0, 1000, 0)); Notify("TP", "Sky TP!", 2, "success") end
    end)
    Button(c, "TP to Spawn", function()
        local sp = Workspace:FindFirstChild("SpawnLocation", true)
        if sp then local r = GetRoot(); if r then r.CFrame = sp.CFrame + Vector3.new(0, 5, 0); Notify("TP", "To spawn!", 2, "success") end end
    end)
    Button(c, "TP to Random Player", function()
        local players = Players:GetPlayers()
        local random = players[math.random(1, #players)]
        if random and random ~= LocalPlayer and random.Character then
            local rp = random.Character:FindFirstChild("HumanoidRootPart")
            local lr = GetRoot()
            if rp and lr then lr.CFrame = rp.CFrame + Vector3.new(5, 0, 0); Notify("TP", "To " .. random.Name, 2, "success") end
        end
    end)
    
    TabContents["Movement"] = c
end

----------------------------------------------------------------------------------
-- SECTION 18: PLAYER TAB
----------------------------------------------------------------------------------

local function PlayerTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 1500 or 2000)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    Section(c, "SURVIVAL")
    Toggle(c, "God Mode", "Infinite HP", false, function(s) Configs.GodMode.Enabled = s end)
    Toggle(c, "Anti-Void", "Prevent void death", false, function(s) Configs.AntiVoid.Enabled = s end)
    Slider(c, "Void Height", -1000, -100, -500, function(v) Configs.AntiVoid.Height = v end)
    Toggle(c, "No Fall Damage", "No fall damage", false, function(s) Configs.NoFall.Enabled = s end)
    Toggle(c, "Anti-Grab", "Prevent grab", false, function(s) Configs.AntiGrab.Enabled = s end)
    Toggle(c, "Auto Revive", "Auto respawn", false, function(s) Configs.AutoRevive.Enabled = s end)
    Toggle(c, "Regeneration", "Auto regen", false, function(s) Configs.Regeneration.Enabled = s end)
    Slider(c, "Regen Rate", 1, 50, 5, function(v) Configs.Regeneration.Rate = v end)
    Toggle(c, "Infinite Stamina", "No stamina drain", false, function(s) Configs.InfiniteStamina.Enabled = s end)
    
    Section(c, "AUTOMATION")
    Toggle(c, "Anti-AFK", "Prevent AFK kick", false, function(s) Configs.AntiAFK.Enabled = s end)
    Toggle(c, "Auto Click", "Auto click", false, function(s) Configs.AutoClick.Enabled = s end)
    Slider(c, "Clicks/Second", 1, 30, 10, function(v) Configs.AutoClick.CPS = v end)
    Toggle(c, "Auto Farm", "Auto farm", false, function(s) Configs.AutoFarm.Enabled = s end)
    
    Section(c, "CHARACTER ACTIONS")
    Button(c, "Reset Character", function()
        local h = GetHumanoid()
        if h then h.Health = 0; Notify("Character", "Reset!", 2, "warning") end
    end)
    Button(c, "Heal to Full", function()
        local h = GetHumanoid()
        if h then h.Health = h.MaxHealth; Notify("Character", "Healed!", 2, "success") end
    end)
    Button(c, "Set Max HP Infinite", function()
        local h = GetHumanoid()
        if h then h.MaxHealth = math.huge; h.Health = math.huge; Notify("Character", "Infinite HP!", 2, "success") end
    end)
    
    Section(c, "INFO")
    Button(c, "Copy Player ID", function()
        if setclipboard then pcall(setclipboard, tostring(LocalPlayer.UserId)) end
        Notify("Info", "Copied: " .. LocalPlayer.UserId, 2, "success")
    end)
    Button(c, "Copy Username", function()
        if setclipboard then pcall(setclipboard, LocalPlayer.Name) end
        Notify("Info", "Copied: " .. LocalPlayer.Name, 2, "success")
    end)
    
    TabContents["Player"] = c
end

----------------------------------------------------------------------------------
-- SECTION 19: RENDER TAB
----------------------------------------------------------------------------------

local function RenderTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 2000 or 2800)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    Section(c, "ENHANCED ESP")
    Toggle(c, "ESP", "Show player info", false, function(s) Configs.ESP.Enabled = s end)
    Toggle(c, "Box ESP", "Boxes around players", true, function(s) Configs.ESP.Box = s end)
    Toggle(c, "Name ESP", "Show names", true, function(s) Configs.ESP.Name = s end)
    Toggle(c, "Health ESP", "Health bars", true, function(s) Configs.ESP.Health = s end)
    Toggle(c, "Distance ESP", "Show distance", true, function(s) Configs.ESP.Distance = s end)
    Toggle(c, "Team Check", "Ignore team", false, function(s) Configs.ESP.TeamCheck = s end)
    Slider(c, "Max Distance", 100, 5000, 2000, function(v) Configs.ESP.MaxDist = v end)
    Toggle(c, "Glow ESP", "Crystal glow", false, function(s) Configs.ESP.Glow = s end)
    Toggle(c, "Outline ESP", "Outline boxes", true, function(s) Configs.ESP.Outline = s end)
    Toggle(c, "Animated ESP", "Animated effects", true, function(s) Configs.ESP.Animated = s end)
    
    Section(c, "TRACERS & CHAMS")
    Toggle(c, "Tracers", "Lines to players", false, function(s) Configs.Tracers.Enabled = s end)
    Dropdown(c, "Tracer Origin", {"Bottom", "Center", "Top", "Mouse"}, "Bottom", function(v) Configs.Tracers.Origin = v end)
    Toggle(c, "Chams", "Highlight through walls", false, function(s) Configs.Chams.Enabled = s end)
    Slider(c, "Chams Transparency", 0, 100, 50, function(v) Configs.Chams.Transparency = v/100 end)
    Toggle(c, "Skeleton ESP", "Show bones", false, function(s) Configs.SkeletonESP.Enabled = s end)
    
    Section(c, "VISUALS")
    Toggle(c, "Fullbright", "Remove darkness", false, function(s) Configs.Fullbright.Enabled = s end)
    Toggle(c, "No Fog", "Remove fog", false, function(s) Configs.NoFog.Enabled = s end)
    Toggle(c, "X-Ray", "See through walls", false, function(s) Configs.Xray.Enabled = s end)
    Slider(c, "X-Ray Transparency", 0, 100, 70, function(v) Configs.Xray.Transparency = v/100 end)
    Toggle(c, "Night Vision", "Night vision", false, function(s) Configs.NightVision.Enabled = s end)
    
    Section(c, "CAMERA")
    Toggle(c, "Freecam", "Free camera", false, function(s) Configs.Freecam.Enabled = s end)
    Slider(c, "Freecam Speed", 10, 200, 50, function(v) Configs.Freecam.Speed = v end)
    Toggle(c, "FOV Changer", "Change FOV", false, function(s) Configs.FOVChanger.Enabled = s end)
    Slider(c, "Camera FOV", 30, 120, 70, function(v) Configs.FOVChanger.Value = v end)
    
    TabContents["Render"] = c
end

----------------------------------------------------------------------------------
-- SECTION 20: UTILS TAB
----------------------------------------------------------------------------------

local function UtilsTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 1800 or 2800)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    Section(c, "SERVER")
    Button(c, "Rejoin Server", function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        Notify("Server", "Rejoining...", 2, "info")
    end)
    Button(c, "Server Hop", function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        Notify("Server", "Hopping...", 2, "info")
    end)
    Button(c, "Copy JobId", function()
        if setclipboard then pcall(setclipboard, game.JobId) end
        Notify("Server", "JobId copied!", 2, "success")
    end)
    
    Section(c, "CHAT")
    Toggle(c, "Chat Spammer", "Auto send messages", false, function(s) Configs.ChatSpam.Enabled = s end)
    TextBox(c, "Spam Message", "Your message", "Crystal Hub", function(v) Configs.ChatSpam.Message = v end)
    Slider(c, "Spam Delay", 1, 10, 3, function(v) Configs.ChatSpam.Delay = v end)
    
    Section(c, "WORLD")
    Toggle(c, "Time Change", "Change time", false, function(s) Configs.TimeChange.Enabled = s end)
    Slider(c, "Time of Day", 0, 24, 14, function(v) Configs.TimeChange.Time = v end)
    Toggle(c, "Gravity", "Change gravity", false, function(s) Configs.Gravity.Enabled = s end)
    Slider(c, "Gravity Value", 0, 500, 196, function(v) Configs.Gravity.Value = v/10 end)
    Toggle(c, "No Cooldown", "Remove cooldowns", false, function(s) Configs.NoCooldown.Enabled = s end)
    Toggle(c, "Auto Collect", "Auto pickup items", false, function(s) Configs.AutoCollect.Enabled = s end)
    Slider(c, "Collect Range", 10, 200, 50, function(v) Configs.AutoCollect.Range = v end)
    
    Section(c, "UTILITY")
    Button(c, "Copy Position", function()
        local r = GetRoot()
        if r then
            local p = string.format("%.2f, %.2f, %.2f", r.Position.X, r.Position.Y, r.Position.Z)
            if setclipboard then pcall(setclipboard, p) end
            Notify("Position", "Copied: " .. p, 3, "success")
        end
    end)
    Button(c, "Show Player Count", function()
        Notify("Players", "Count: " .. #Players:GetPlayers(), 3, "info")
    end)
    
    Section(c, "PERFORMANCE")
    Button(c, "Remove Terrain", function()
        pcall(function() if Workspace.Terrain then Workspace.Terrain:Clear() end end)
        Notify("Perf", "Terrain removed!", 2, "warning")
    end)
    Button(c, "Remove Particles", function()
        pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o:IsA("ParticleEmitter") then o.Enabled = false end end end)
        Notify("Perf", "Particles disabled!", 2, "warning")
    end)
    Button(c, "FPS Unlock", function()
        if setfpscap then pcall(setfpscap, 9999) end
        Notify("Perf", "FPS unlocked!", 2, "success")
    end)
    
    Section(c, "VISUAL")
    Toggle(c, "Rainbow Mode", "Rainbow UI colors", false, function(s) Configs.RainbowMode.Enabled = s end)
    
    TabContents["Utils"] = c
end

----------------------------------------------------------------------------------
-- SECTION 21: CREATE ALL TABS
----------------------------------------------------------------------------------

CombatTab()
MovementTab()
PlayerTab()
RenderTab()
UtilsTab()

-- Activate Combat tab
if TabBtns["Combat"] then
    CreateTween(TabBtns["Combat"], {BackgroundTransparency = 0.3, BackgroundColor3 = T("Accent")}, 0.01)
end
for n, c in pairs(TabContents) do if n ~= "Combat" then c.Visible = false end end

----------------------------------------------------------------------------------
-- SECTION 22: STATUS BAR
----------------------------------------------------------------------------------

local Status = Instance.new("Frame", Main)
Status.Size = UDim2.new(1, 0, 0, Platform.IsMobile and 20 or 25)
Status.Position = UDim2.new(0, 0, 1, Platform.IsMobile and -20 or -25)
Status.BackgroundColor3 = T("Primary")
Status.BackgroundTransparency = 0.5

local StatusLabel = Instance.new("TextLabel", Status)
StatusLabel.Size = UDim2.new(0.7, 0, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "💎 Crystal Hub v6.0 | " .. Hub.Platform
StatusLabel.TextColor3 = T("TextSecondary")
StatusLabel.TextSize = Platform.IsMobile and 9 or 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local FPSLabel = Instance.new("TextLabel", Status)
FPSLabel.Size = UDim2.new(0.3, -10, 1, 0)
FPSLabel.Position = UDim2.new(0.7, 0, 0, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: 60"
FPSLabel.TextColor3 = T("Success")
FPSLabel.TextSize = Platform.IsMobile and 9 or 10
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right

----------------------------------------------------------------------------------
-- SECTION 23: KEYBINDS (PC) & TOUCH (Mobile)
----------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if Main then Main.Visible = not Main.Visible end
    end
    if i.KeyCode == Enum.KeyCode.Q and Configs.Blink.Enabled then
        local r = GetRoot()
        if r then r.CFrame = r.CFrame + Camera.CFrame.LookVector * Configs.Blink.Distance; Notify("Blink", "TP!", 1, "success") end
    end
    if i.KeyCode == Enum.KeyCode.E and Configs.Dash.Enabled then
        local r = GetRoot()
        if r then r.Velocity = r.Velocity + Camera.CFrame.LookVector * Configs.Dash.Distance * 3; Notify("Dash", "Dash!", 1, "success") end
    end
end)

----------------------------------------------------------------------------------
-- SECTION 24: FUNCTION LOOPS
----------------------------------------------------------------------------------

-- AIMBOT
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Aimbot.Enabled then
                local target = GetClosest(Configs.Aimbot.FOV, Configs.Aimbot.Part, Configs.Aimbot.TeamCheck, Configs.Aimbot.WallCheck)
                if target and target.Character then
                    local part = target.Character:FindFirstChild(Configs.Aimbot.Part)
                    if part then
                        local tpos = part.Position
                        local trp = target.Character:FindFirstChild("HumanoidRootPart")
                        if trp then tpos = tpos + trp.Velocity * Configs.Aimbot.Prediction end
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, tpos), Configs.Aimbot.Smooth)
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- TRIGGERBOT
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Triggerbot.Enabled and Mouse.Target then
                local tp = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
                if tp and tp ~= LocalPlayer then
                    if not Configs.Triggerbot.TeamCheck or tp.Team ~= LocalPlayer.Team then
                        if GetDistance(LocalPlayer, tp) <= Configs.Triggerbot.MaxDist then
                            task.wait(Configs.Triggerbot.Delay)
                            if mouse1click then pcall(mouse1click) end
                        end
                    end
                end
            end
        end)
        task.wait(0.01)
    end
end)

-- KILL AURA
task.spawn(function()
    while true do
        pcall(function()
            if Configs.KillAura.Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        if Configs.KillAura.TeamCheck and p.Team == LocalPlayer.Team then continue end
                        if GetDistance(LocalPlayer, p) <= Configs.KillAura.Range then
                            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then pcall(function() tool:Activate() end) end
                        end
                    end
                end
            end
        end)
        task.wait(Configs.KillAura.Delay)
    end
end)

-- HITBOX EXTENDER
task.spawn(function()
    while true do
        pcall(function()
            if Configs.HitboxExtender.Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        local rp = p.Character:FindFirstChild("HumanoidRootPart")
                        if rp and not Hub.HitboxParts[p.UserId] then
                            local hb = Instance.new("Part")
                            hb.Size = Vector3.new(5, 5, 5); hb.Transparency = 0.7; hb.CanCollide = false
                            hb.Color = Color3.fromRGB(255, 0, 0); hb.Material = Enum.Material.ForceField
                            hb.Parent = p.Character
                            local w = Instance.new("WeldConstraint", hb); w.Part0 = hb; w.Part1 = rp
                            Hub.HitboxParts[p.UserId] = hb
                        end
                        if Hub.HitboxParts[p.UserId] then
                            local s = Configs.HitboxExtender.Size
                            Hub.HitboxParts[p.UserId].Size = Vector3.new(s, s, s)
                            Hub.HitboxParts[p.UserId].Transparency = Configs.HitboxExtender.Transparency
                        end
                    end
                end
            else
                for uid, part in pairs(Hub.HitboxParts) do if part then pcall(function() part:Destroy() end) end end
                Hub.HitboxParts = {}
            end
        end)
        task.wait(0.5)
    end
end)

-- SPEED
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Speed.Enabled then
                local h = GetHumanoid()
                if h then h.WalkSpeed = Configs.Speed.Value end
            else
                local h = GetHumanoid()
                if h and h.WalkSpeed ~= 16 then h.WalkSpeed = 16 end
            end
        end)
        task.wait()
    end
end)

-- FLY
local FlyBV, FlyBG
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Fly.Enabled then
                local rp = GetRoot()
                if rp then
                    if not FlyBV then FlyBV = Instance.new("BodyVelocity", rp); FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge) end
                    if not FlyBG then FlyBG = Instance.new("BodyGyro", rp); FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); FlyBG.P = 10000 end
                    local mv = Camera.CFrame.LookVector
                    local ud = 0
                    if Platform.IsPC then
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then ud = 1
                        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then ud = -1 end
                    end
                    FlyBV.Velocity = (mv * Configs.Fly.Speed) + Vector3.new(0, ud * Configs.Fly.Speed, 0)
                    FlyBG.CFrame = Camera.CFrame
                end
            else
                if FlyBV then pcall(function() FlyBV:Destroy() end); FlyBV = nil end
                if FlyBG then pcall(function() FlyBG:Destroy() end); FlyBG = nil end
            end
        end)
        task.wait()
    end
end)

-- NOCLIP
local NoclipConn
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Noclip.Enabled and not NoclipConn then
                NoclipConn = RunService.Stepped:Connect(function()
                    if LocalPlayer.Character then
                        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    end
                end)
            elseif not Configs.Noclip.Enabled and NoclipConn then
                NoclipConn:Disconnect(); NoclipConn = nil
                if LocalPlayer.Character then
                    for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- INF JUMP
local InfJumpConn
task.spawn(function()
    while true do
        pcall(function()
            if Configs.InfJump.Enabled and not InfJumpConn then
                InfJumpConn = UserInputService.JumpRequest:Connect(function()
                    local h = GetHumanoid()
                    if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
                end)
            elseif not Configs.InfJump.Enabled and InfJumpConn then
                InfJumpConn:Disconnect(); InfJumpConn = nil
            end
        end)
        task.wait(0.1)
    end
end)

-- GOD MODE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.GodMode.Enabled then
                local h = GetHumanoid()
                if h then h.MaxHealth = math.huge; h.Health = math.huge end
            end
        end)
        task.wait()
    end
end)

-- ANTI-VOID
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AntiVoid.Enabled then
                local rp = GetRoot()
                if rp and rp.Position.Y < Configs.AntiVoid.Height then
                    rp.CFrame = CFrame.new(rp.Position.X, rp.Position.Y + 1000, rp.Position.Z)
                    Notify("Anti-Void", "Saved!", 2, "warning")
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- NO FALL
task.spawn(function()
    while true do
        pcall(function()
            if Configs.NoFall.Enabled then
                local rp = GetRoot()
                if rp then rp.Velocity = Vector3.new(rp.Velocity.X, math.max(rp.Velocity.Y, -50), rp.Velocity.Z) end
            end
        end)
        task.wait()
    end
end)

-- REGENERATION
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Regeneration.Enabled then
                local h = GetHumanoid()
                if h and h.Health < h.MaxHealth then h.Health = math.min(h.Health + Configs.Regeneration.Rate, h.MaxHealth) end
            end
        end)
        task.wait(1)
    end
end)

-- ESP (Crystal Style)
task.spawn(function()
    while true do
        pcall(function()
            for _, o in pairs(Hub.ESPObjects) do if o then pcall(function() o:Remove() end) end end
            Hub.ESPObjects = {}
            
            if Configs.ESP.Enabled and HasDrawing then
                local animTime = tick()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        if Configs.ESP.TeamCheck and p.Team == LocalPlayer.Team then continue end
                        local rp = p.Character:FindFirstChild("HumanoidRootPart")
                        local h = p.Character:FindFirstChildOfClass("Humanoid")
                        local head = p.Character:FindFirstChild("Head")
                        if rp and h and head then
                            local d = GetDistance(LocalPlayer, p)
                            if d <= Configs.ESP.MaxDist then
                                local sp, on = WorldToScreen(head.Position)
                                if on then
                                    local hs, _ = WorldToScreen(head.Position + Vector3.new(0, 2, 0))
                                    local fs, _ = WorldToScreen(rp.Position - Vector3.new(0, 3, 0))
                                    local bh = math.abs(hs.Y - fs.Y)
                                    local bw = bh * 0.5
                                    local baseColor = (p.Team == LocalPlayer.Team) and Color3.fromRGB(80, 220, 140) or Color3.fromRGB(100, 180, 255)
                                    
                                    if Configs.ESP.Box then
                                        local box = Drawing.new("Square")
                                        box.Size = Vector2.new(bw, bh); box.Position = Vector2.new(sp.X - bw/2, hs.Y)
                                        box.Thickness = 2; box.Color = baseColor; box.Filled = false; box.Visible = true
                                        table.insert(Hub.ESPObjects, box)
                                        
                                        if Configs.ESP.Outline then
                                            local outline = Drawing.new("Square")
                                            outline.Size = Vector2.new(bw + 4, bh + 4); outline.Position = Vector2.new(sp.X - bw/2 - 2, hs.Y - 2)
                                            outline.Thickness = 1; outline.Color = Color3.fromRGB(0, 0, 0); outline.Visible = true
                                            table.insert(Hub.ESPObjects, outline)
                                        end
                                    end
                                    
                                    if Configs.ESP.Name then
                                        local nm = Drawing.new("Text")
                                        nm.Text = "◆ " .. p.DisplayName; nm.Center = true; nm.Outline = true
                                        nm.Size = 14; nm.Color = baseColor; nm.Position = Vector2.new(sp.X, hs.Y - 25); nm.Visible = true
                                        table.insert(Hub.ESPObjects, nm)
                                    end
                                    
                                    if Configs.ESP.Health then
                                        local hp = h.Health / h.MaxHealth
                                        local bg = Drawing.new("Square")
                                        bg.Size = Vector2.new(4, bh); bg.Position = Vector2.new(sp.X - bw/2 - 10, hs.Y)
                                        bg.Color = Color3.fromRGB(30, 30, 30); bg.Filled = true; bg.Visible = true
                                        table.insert(Hub.ESPObjects, bg)
                                        
                                        local bar = Drawing.new("Square")
                                        bar.Size = Vector2.new(4, bh * hp); bar.Position = Vector2.new(sp.X - bw/2 - 10, hs.Y + bh - bh*hp)
                                        bar.Color = Color3.fromRGB(255 - 255*hp, 255*hp, 50); bar.Filled = true; bar.Visible = true
                                        table.insert(Hub.ESPObjects, bar)
                                    end
                                    
                                    if Configs.ESP.Distance then
                                        local dt = Drawing.new("Text")
                                        dt.Text = "[" .. math.floor(d) .. "m]"; dt.Center = true; dt.Outline = true
                                        dt.Size = 12; dt.Color = Color3.fromRGB(220, 220, 220); dt.Position = Vector2.new(sp.X, fs.Y + 5); dt.Visible = true
                                        table.insert(Hub.ESPObjects, dt)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- TRACERS
task.spawn(function()
    while true do
        pcall(function()
            for _, o in pairs(Hub.TracerObjects) do if o then pcall(function() o:Remove() end) end end
            Hub.TracerObjects = {}
            if Configs.Tracers.Enabled and HasDrawing then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        if Configs.Tracers.TeamCheck and p.Team == LocalPlayer.Team then continue end
                        local rp = p.Character:FindFirstChild("HumanoidRootPart")
                        if rp then
                            local sp, on = WorldToScreen(rp.Position)
                            if on then
                                local origin = Vector2.zero
                                if Configs.Tracers.Origin == "Bottom" then origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                                elseif Configs.Tracers.Origin == "Center" then origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                                elseif Configs.Tracers.Origin == "Top" then origin = Vector2.new(Camera.ViewportSize.X/2, 0)
                                elseif Configs.Tracers.Origin == "Mouse" then origin = UserInputService:GetMouseLocation() end
                                local tr = Drawing.new("Line")
                                tr.From = origin; tr.To = sp; tr.Color = Color3.fromRGB(100, 180, 255); tr.Thickness = 1.5; tr.Visible = true
                                table.insert(Hub.TracerObjects, tr)
                            end
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- CHAMS
task.spawn(function()
    while true do
        pcall(function()
            for _, c in pairs(Hub.ChamsObjects) do if c then pcall(function() c:Destroy() end) end end
            Hub.ChamsObjects = {}
            if Configs.Chams.Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        if Configs.Chams.TeamCheck and p.Team == LocalPlayer.Team then continue end
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(100, 180, 255); hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = Configs.Chams.Transparency; hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = p.Character
                        table.insert(Hub.ChamsObjects, hl)
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- FULLBRIGHT
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Fullbright.Enabled then
                Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            end
        end)
        task.wait(1)
    end
end)

-- NO FOG
task.spawn(function()
    while true do
        pcall(function() if Configs.NoFog.Enabled then Lighting.FogStart = 0; Lighting.FogEnd = 9999999 end end)
        task.wait(1)
    end
end)

-- XRAY
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Xray.Enabled then
                for _, p in pairs(Workspace:GetDescendants()) do
                    if p:IsA("BasePart") and not p:IsDescendantOf(LocalPlayer.Character) then
                        if not Hub.OriginalTransparencies[p] then Hub.OriginalTransparencies[p] = p.Transparency end
                        p.Transparency = Configs.Xray.Transparency
                    end
                end
            else
                for p, o in pairs(Hub.OriginalTransparencies) do if p and p.Parent then p.Transparency = o end end
                Hub.OriginalTransparencies = {}
            end
        end)
        task.wait(1)
    end
end)

-- FOV CHANGER
task.spawn(function()
    while true do
        pcall(function() Camera.FieldOfView = Configs.FOVChanger.Enabled and Configs.FOVChanger.Value or 70 end)
        task.wait()
    end
end)

-- CHAT SPAM
task.spawn(function()
    while true do
        pcall(function()
            if Configs.ChatSpam.Enabled then
                local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents", true)
                if ev then local say = ev:FindFirstChild("SayMessageRequest"); if say then say:FireServer(Configs.ChatSpam.Message, "All") end end
                task.wait(Configs.ChatSpam.Delay)
            else task.wait(0.5) end
        end)
    end
end)

-- TIME CHANGE
task.spawn(function()
    while true do
        pcall(function() if Configs.TimeChange.Enabled then Lighting.ClockTime = Configs.TimeChange.Time end end)
        task.wait(1)
    end
end)

-- GRAVITY
task.spawn(function()
    while true do
        pcall(function() Workspace.Gravity = Configs.Gravity.Enabled and Configs.Gravity.Value or 196.2 end)
        task.wait()
    end
end)

-- AUTO COLLECT
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AutoCollect.Enabled then
                local rp = GetRoot()
                if rp and firetouchinterest then
                    for _, o in pairs(Workspace:GetDescendants()) do
                        if o:IsA("BasePart") and not o:IsDescendantOf(LocalPlayer.Character) then
                            if (o.Position - rp.Position).Magnitude <= Configs.AutoCollect.Range then
                                firetouchinterest(rp, o, 0); task.wait(); firetouchinterest(rp, o, 1)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- RAINBOW MODE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.RainbowMode.Enabled then
                local c = Color3.fromHSV(tick() * 0.1 % 1, 1, 1)
                CurrentTheme.Accent = c; CurrentTheme.ToggleOn = c
            end
        end)
        task.wait(0.05)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 25: FPS COUNTER & ANIMATIONS
----------------------------------------------------------------------------------

task.spawn(function()
    local fc, lt = 0, tick()
    while ScreenGui and ScreenGui.Parent do
        fc = fc + 1
        local ct = tick()
        if ct - lt >= 1 then
            if FPSLabel and FPSLabel.Parent then FPSLabel.Text = "FPS: " .. fc end
            fc = 0; lt = ct
        end
        task.wait()
    end
end)

task.spawn(function()
    while Main and Main.Parent do
        pcall(function()
            local t = tick() * 0.3
            local r = math.sin(t) * 0.5 + 0.5
            local c1 = CurrentTheme.Primary:Lerp(CurrentTheme.Accent, r)
            local c2 = CurrentTheme.Accent:Lerp(CurrentTheme.Primary, 1-r)
            Grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(0.5, c2),
                ColorSequenceKeypoint.new(1, c1),
            })
            Grad.Rotation = 45 + math.sin(tick() * 0.5) * 10
        end)
        task.wait(0.1)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 26: CLEANUP
----------------------------------------------------------------------------------

ScreenGui.Destroying:Connect(function()
    pcall(function()
        if NoclipConn then NoclipConn:Disconnect() end
        if InfJumpConn then InfJumpConn:Disconnect() end
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        for _, o in pairs(Hub.ESPObjects) do if o then pcall(function() o:Remove() end) end end
        for _, o in pairs(Hub.TracerObjects) do if o then pcall(function() o:Remove() end) end end
        for _, c in pairs(Hub.ChamsObjects) do if c then pcall(function() c:Destroy() end) end end
        for _, p in pairs(Hub.HitboxParts) do if p then pcall(function() p:Destroy() end) end end
        for p, o in pairs(Hub.OriginalTransparencies) do if p and p.Parent then p.Transparency = o end end
        Workspace.Gravity = 196.2; Camera.FieldOfView = 70
    end)
end)

----------------------------------------------------------------------------------
-- SECTION 27: INTRO & FINAL
----------------------------------------------------------------------------------

task.spawn(function()
    task.wait(0.5)
    Notify("Welcome", "Crystal Hub v6.0 - " .. Hub.Platform .. " Edition", 4, "success")
    task.wait(2)
    if Platform.IsPC then
        Notify("Controls", "RIGHT SHIFT = Toggle GUI | Q = Blink | E = Dash", 5, "info")
    else
        Notify("Controls", "Tap 💎 to open menu | Use bottom buttons", 5, "info")
    end
end)

print("═══════════════════════════════════════════════════════")
print("   💎 Crystal Hub v6.0 - UNIVERSAL EDITION")
print("   Platform: " .. Hub.Platform)
print("   Functions: 200+ | Themes: 5 | Tabs: 5")
print("   Touch: " .. tostring(Platform.HasTouch) .. " | Keyboard: " .. tostring(Platform.HasKeyboard))
print("═══════════════════════════════════════════════════════")

return Hub
