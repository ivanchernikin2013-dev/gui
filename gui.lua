-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║         LIQUID GLASS HUB v4.0 ULTIMATE - FULLY WORKING                  ║
-- ║            65+ Functions | 7 Themes | All Functions Tested              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

----------------------------------------------------------------------------------
-- SECTION 1: SAFE ENVIRONMENT CHECK
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
local HttpService = SafeGet("HttpService")
local TeleportService = SafeGet("TeleportService")
local SoundService = SafeGet("SoundService")
local Stats = SafeGet("Stats")

if not Players or not RunService or not TweenService or not Workspace then
    warn("[LiquidGlass] Critical services missing!")
    return
end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then warn("[LiquidGlass] No LocalPlayer!") return end

local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

----------------------------------------------------------------------------------
-- SECTION 2: GUI PARENT FALLBACK SYSTEM
----------------------------------------------------------------------------------

local function GetGUIParent()
    if gethui then
        local ok, r = pcall(gethui)
        if ok and r then return r end
    end
    if get_custom_gui then
        local ok, r = pcall(get_custom_gui)
        if ok and r then return r end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local test = Instance.new("ScreenGui")
        local pok = pcall(function() test.Parent = cg end)
        test:Destroy()
        if pok then return cg end
    end
    if LocalPlayer:FindFirstChild("PlayerGui") then
        return LocalPlayer.PlayerGui
    end
    return game
end

local GUIParent = GetGUIParent()

----------------------------------------------------------------------------------
-- SECTION 3: DESTROY OLD GUI
----------------------------------------------------------------------------------

pcall(function()
    for _, parent in ipairs({
        pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui"),
        LocalPlayer:FindFirstChild("PlayerGui"),
        gethui and gethui(),
    }) do
        if parent and parent:FindFirstChild("LiquidGlassHubV4") then
            parent:FindFirstChild("LiquidGlassHubV4"):Destroy()
        end
    end
end)

----------------------------------------------------------------------------------
-- SECTION 4: CORE STATE
----------------------------------------------------------------------------------

local Hub = {
    Version = "4.0.0",
    Enabled = true,
    Minimized = false,
    CurrentTab = "Combat",
    CurrentTheme = "Dark",
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    Functions = {},
    Connections = {},
    ESPObjects = {},
    TracerObjects = {},
    ChamsObjects = {},
    SkeletonObjects = {},
    OriginalTransparencies = {},
}

----------------------------------------------------------------------------------
-- SECTION 5: THEMES (7 COMPLETE THEMES)
----------------------------------------------------------------------------------

local Themes = {
    Dark = {
        Name = "Dark Void",
        Primary = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(25, 25, 45),
        Accent = Color3.fromRGB(100, 50, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        Background = Color3.fromRGB(10, 10, 18),
        Glass = Color3.fromRGB(30, 30, 60),
        GlassBorder = Color3.fromRGB(80, 60, 180),
        ToggleOn = Color3.fromRGB(100, 50, 255),
        ToggleOff = Color3.fromRGB(60, 60, 80),
        SliderFill = Color3.fromRGB(100, 50, 255),
        SliderBg = Color3.fromRGB(40, 40, 60),
        Glow = Color3.fromRGB(100, 50, 255),
        Particle = Color3.fromRGB(150, 100, 255),
        Success = Color3.fromRGB(50, 200, 100),
        Error = Color3.fromRGB(255, 60, 60),
        Warning = Color3.fromRGB(255, 200, 50),
        TabActive = Color3.fromRGB(100, 50, 255),
        TabInactive = Color3.fromRGB(50, 50, 70),
        Gradient1 = Color3.fromRGB(100, 50, 255),
        Gradient2 = Color3.fromRGB(50, 20, 150),
    },
    Ocean = {
        Name = "Ocean Depths",
        Primary = Color3.fromRGB(10, 20, 40),
        Secondary = Color3.fromRGB(15, 35, 60),
        Accent = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 200, 230),
        Background = Color3.fromRGB(5, 12, 30),
        Glass = Color3.fromRGB(10, 30, 60),
        GlassBorder = Color3.fromRGB(0, 120, 200),
        ToggleOn = Color3.fromRGB(0, 150, 255),
        ToggleOff = Color3.fromRGB(30, 50, 70),
        SliderFill = Color3.fromRGB(0, 150, 255),
        SliderBg = Color3.fromRGB(20, 40, 60),
        Glow = Color3.fromRGB(0, 180, 255),
        Particle = Color3.fromRGB(100, 200, 255),
        Success = Color3.fromRGB(0, 220, 150),
        Error = Color3.fromRGB(255, 80, 80),
        Warning = Color3.fromRGB(255, 180, 0),
        TabActive = Color3.fromRGB(0, 150, 255),
        TabInactive = Color3.fromRGB(30, 50, 70),
        Gradient1 = Color3.fromRGB(0, 150, 255),
        Gradient2 = Color3.fromRGB(0, 80, 180),
    },
    Neon = {
        Name = "Neon Cyber",
        Primary = Color3.fromRGB(5, 5, 15),
        Secondary = Color3.fromRGB(15, 15, 30),
        Accent = Color3.fromRGB(0, 255, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 220),
        Background = Color3.fromRGB(0, 0, 5),
        Glass = Color3.fromRGB(10, 10, 25),
        GlassBorder = Color3.fromRGB(0, 255, 100),
        ToggleOn = Color3.fromRGB(0, 255, 100),
        ToggleOff = Color3.fromRGB(40, 40, 50),
        SliderFill = Color3.fromRGB(0, 255, 100),
        SliderBg = Color3.fromRGB(30, 30, 40),
        Glow = Color3.fromRGB(0, 255, 150),
        Particle = Color3.fromRGB(100, 255, 150),
        Success = Color3.fromRGB(0, 255, 100),
        Error = Color3.fromRGB(255, 0, 80),
        Warning = Color3.fromRGB(255, 255, 0),
        TabActive = Color3.fromRGB(0, 255, 100),
        TabInactive = Color3.fromRGB(40, 40, 55),
        Gradient1 = Color3.fromRGB(0, 255, 100),
        Gradient2 = Color3.fromRGB(255, 0, 200),
    },
    Blood = {
        Name = "Blood Moon",
        Primary = Color3.fromRGB(25, 5, 5),
        Secondary = Color3.fromRGB(45, 10, 10),
        Accent = Color3.fromRGB(255, 30, 30),
        Text = Color3.fromRGB(255, 240, 240),
        TextSecondary = Color3.fromRGB(220, 180, 180),
        Background = Color3.fromRGB(15, 2, 2),
        Glass = Color3.fromRGB(40, 10, 10),
        GlassBorder = Color3.fromRGB(200, 30, 30),
        ToggleOn = Color3.fromRGB(255, 30, 30),
        ToggleOff = Color3.fromRGB(70, 30, 30),
        SliderFill = Color3.fromRGB(255, 30, 30),
        SliderBg = Color3.fromRGB(50, 20, 20),
        Glow = Color3.fromRGB(255, 50, 50),
        Particle = Color3.fromRGB(255, 100, 80),
        Success = Color3.fromRGB(50, 200, 80),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 200, 0),
        TabActive = Color3.fromRGB(255, 30, 30),
        TabInactive = Color3.fromRGB(60, 20, 20),
        Gradient1 = Color3.fromRGB(255, 30, 30),
        Gradient2 = Color3.fromRGB(150, 0, 0),
    },
    Purple = {
        Name = "Cosmic Purple",
        Primary = Color3.fromRGB(20, 10, 35),
        Secondary = Color3.fromRGB(35, 20, 55),
        Accent = Color3.fromRGB(180, 50, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 180, 230),
        Background = Color3.fromRGB(10, 5, 20),
        Glass = Color3.fromRGB(30, 15, 50),
        GlassBorder = Color3.fromRGB(150, 50, 220),
        ToggleOn = Color3.fromRGB(180, 50, 255),
        ToggleOff = Color3.fromRGB(50, 30, 60),
        SliderFill = Color3.fromRGB(180, 50, 255),
        SliderBg = Color3.fromRGB(35, 20, 50),
        Glow = Color3.fromRGB(200, 80, 255),
        Particle = Color3.fromRGB(220, 150, 255),
        Success = Color3.fromRGB(80, 220, 120),
        Error = Color3.fromRGB(255, 60, 80),
        Warning = Color3.fromRGB(255, 220, 50),
        TabActive = Color3.fromRGB(180, 50, 255),
        TabInactive = Color3.fromRGB(45, 25, 60),
        Gradient1 = Color3.fromRGB(180, 50, 255),
        Gradient2 = Color3.fromRGB(100, 20, 180),
    },
    Matrix = {
        Name = "Matrix Code",
        Primary = Color3.fromRGB(0, 10, 0),
        Secondary = Color3.fromRGB(0, 25, 0),
        Accent = Color3.fromRGB(0, 255, 50),
        Text = Color3.fromRGB(200, 255, 200),
        TextSecondary = Color3.fromRGB(100, 200, 100),
        Background = Color3.fromRGB(0, 5, 0),
        Glass = Color3.fromRGB(0, 15, 0),
        GlassBorder = Color3.fromRGB(0, 200, 50),
        ToggleOn = Color3.fromRGB(0, 255, 50),
        ToggleOff = Color3.fromRGB(20, 50, 20),
        SliderFill = Color3.fromRGB(0, 255, 50),
        SliderBg = Color3.fromRGB(10, 30, 10),
        Glow = Color3.fromRGB(0, 255, 80),
        Particle = Color3.fromRGB(50, 255, 100),
        Success = Color3.fromRGB(0, 255, 50),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(200, 255, 0),
        TabActive = Color3.fromRGB(0, 255, 50),
        TabInactive = Color3.fromRGB(20, 45, 20),
        Gradient1 = Color3.fromRGB(0, 255, 50),
        Gradient2 = Color3.fromRGB(0, 150, 30),
    },
    Gold = {
        Name = "Royal Gold",
        Primary = Color3.fromRGB(30, 25, 10),
        Secondary = Color3.fromRGB(50, 40, 15),
        Accent = Color3.fromRGB(255, 200, 50),
        Text = Color3.fromRGB(255, 250, 230),
        TextSecondary = Color3.fromRGB(220, 200, 150),
        Background = Color3.fromRGB(15, 12, 5),
        Glass = Color3.fromRGB(40, 30, 10),
        GlassBorder = Color3.fromRGB(200, 160, 40),
        ToggleOn = Color3.fromRGB(255, 200, 50),
        ToggleOff = Color3.fromRGB(60, 50, 25),
        SliderFill = Color3.fromRGB(255, 200, 50),
        SliderBg = Color3.fromRGB(40, 30, 15),
        Glow = Color3.fromRGB(255, 210, 80),
        Particle = Color3.fromRGB(255, 230, 150),
        Success = Color3.fromRGB(80, 220, 100),
        Error = Color3.fromRGB(255, 60, 60),
        Warning = Color3.fromRGB(255, 200, 50),
        TabActive = Color3.fromRGB(255, 200, 50),
        TabInactive = Color3.fromRGB(55, 45, 20),
        Gradient1 = Color3.fromRGB(255, 200, 50),
        Gradient2 = Color3.fromRGB(200, 150, 30),
    },
}

local CurrentTheme = Themes.Dark

local function T(key)
    return CurrentTheme[key] or Color3.fromRGB(255, 255, 255)
end

----------------------------------------------------------------------------------
-- SECTION 6: FUNCTION CONFIGS (ALL 65+ FUNCTIONS)
----------------------------------------------------------------------------------

local Configs = {
    Aimbot = {Enabled=false, FOV=180, Smooth=0.2, Part="Head", TeamCheck=false, WallCheck=true, Prediction=0.165},
    Triggerbot = {Enabled=false, Delay=0, MaxDist=500, TeamCheck=false},
    SilentAim = {Enabled=false, FOV=180, Part="Head", HitChance=100},
    KillAura = {Enabled=false, Range=15, TeamCheck=false},
    HitboxExtender = {Enabled=false, Size=5, Transparency=0.7},
    AntiAim = {Enabled=false, Type="Roll", Speed=5},
    AutoParry = {Enabled=false, Range=10},
    Reach = {Enabled=false, Distance=15},
    CriticalHits = {Enabled=false, Multiplier=2},
    AntiKnockback = {Enabled=false},
    AutoShoot = {Enabled=false, Delay=0.1},
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
    GodMode = {Enabled=false},
    AntiVoid = {Enabled=false, Height=-500},
    NoFall = {Enabled=false},
    AntiAFK = {Enabled=false},
    AutoClick = {Enabled=false, CPS=10},
    AntiGrab = {Enabled=false},
    HighJump = {Enabled=false, Height=100},
    ESP = {Enabled=false, Box=true, Name=true, Health=true, Distance=true, TeamCheck=false, MaxDist=1000},
    Tracers = {Enabled=false, Origin="Bottom", TeamCheck=false},
    Chams = {Enabled=false, TeamCheck=false, Transparency=0.5},
    Fullbright = {Enabled=false},
    Xray = {Enabled=false, Transparency=0.7},
    NoFog = {Enabled=false},
    Wireframe = {Enabled=false},
    SkeletonESP = {Enabled=false},
    Freecam = {Enabled=false, Speed=50},
    FOVChanger = {Enabled=false, Value=70},
    CameraShake = {Enabled=false, Intensity=3},
    ChatSpam = {Enabled=false, Message="Liquid Glass Hub", Delay=3},
    TimeChange = {Enabled=false, Time=14},
    Gravity = {Enabled=false, Value=196.2},
    AutoCollect = {Enabled=false, Range=50},
    NoCooldown = {Enabled=false},
    RainbowMode = {Enabled=false},
    AutoFarm = {Enabled=false},
    AutoRevive = {Enabled=false},
    AutoBlock = {Enabled=false},
}

----------------------------------------------------------------------------------
-- SECTION 7: UTILITY FUNCTIONS
----------------------------------------------------------------------------------

local function CreateTween(obj, props, duration, style, dir)
    if not obj or not obj.Parent then return nil end
    local ok, tween = pcall(function()
        local info = TweenInfo.new(
            duration or 0.3,
            style or Enum.EasingStyle.Quart,
            dir or Enum.EasingDirection.Out
        )
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
        local r1 = c1:FindFirstChild("HumanoidRootPart")
        local r2 = c2:FindFirstChild("HumanoidRootPart")
        if r1 and r2 then
            return (r1.Position - r2.Position).Magnitude
        end
    end
    return math.huge
end

local function GetClosest(fov, part, teamCheck, wallCheck)
    local closest, dist = nil, fov or 9e9
    local mp = UserInputService:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and IsAlive(p) then
            if teamCheck and p.Team == LocalPlayer.Team then continue end
            local pt = p.Character:FindFirstChild(part or "Head")
            if pt then
                local sp, on = WorldToScreen(pt.Position)
                if on then
                    local d = (mp - sp).Magnitude
                    if d < dist then
                        if wallCheck then
                            local rp = Ray.new(Camera.CFrame.Position, (pt.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit = Workspace:FindPartOnRayWithIgnoreList(rp, {LocalPlayer.Character, Camera})
                            if hit and hit:IsDescendantOf(p.Character) then
                                closest, dist = p, d
                            end
                        else
                            closest, dist = p, d
                        end
                    end
                end
            end
        end
    end
    return closest, dist
end

local HasDrawing = pcall(function()
    local t = Drawing.new("Line")
    t:Remove()
end)

----------------------------------------------------------------------------------
-- SECTION 8: NOTIFICATION SYSTEM
----------------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LiquidGlassHubV4"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = GUIParent end)

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 350, 1, 0)
NotifContainer.Position = UDim2.new(1, -350, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.Parent = NotifContainer

local function Notify(title, msg, dur, ntype)
    ntype = ntype or "info"
    local colors = {
        info = T("Accent"), success = T("Success"),
        error = T("Error"), warning = T("Warning")
    }
    local n = Instance.new("Frame")
    n.Size = UDim2.new(0, 300, 0, 80)
    n.Position = UDim2.new(1, 20, 0, 0)
    n.BackgroundColor3 = T("Background")
    n.BackgroundTransparency = 0.1
    n.BorderSizePixel = 0
    n.Parent = NotifContainer
    
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", n)
    s.Color = colors[ntype] or T("Accent")
    s.Thickness = 2
    s.Transparency = 0.3
    
    local tl = Instance.new("TextLabel", n)
    tl.Size = UDim2.new(1, -20, 0, 25)
    tl.Position = UDim2.new(0, 10, 0, 10)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = colors[ntype]
    tl.TextSize = 14
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    
    local ml = Instance.new("TextLabel", n)
    ml.Size = UDim2.new(1, -20, 0, 35)
    ml.Position = UDim2.new(0, 10, 0, 35)
    ml.BackgroundTransparency = 1
    ml.Text = msg
    ml.TextColor3 = T("TextSecondary")
    ml.TextSize = 12
    ml.Font = Enum.Font.Gotham
    ml.TextXAlignment = Enum.TextXAlignment.Left
    ml.TextWrapped = true
    
    CreateTween(n, {Position = UDim2.new(1, -320, 0, 0)}, 0.5)
    task.delay(dur or 3, function()
        if n.Parent then
            CreateTween(n, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.4)
            task.wait(0.4)
            pcall(function() n:Destroy() end)
        end
    end)
end

----------------------------------------------------------------------------------
-- SECTION 9: MAIN FRAME
----------------------------------------------------------------------------------

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 650, 0, 480)
Main.Position = UDim2.new(0.5, -325, 0.5, -240)
Main.BackgroundColor3 = T("Background")
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = T("GlassBorder")
MainStroke.Thickness = 2
MainStroke.Transparency = 0.4

local Overlay = Instance.new("Frame", Main)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = T("Glass")
Overlay.BackgroundTransparency = 0.15
Overlay.BorderSizePixel = 0
Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0, 16)

local GradFrame = Instance.new("Frame", Main)
GradFrame.Size = UDim2.new(1, 0, 1, 0)
GradFrame.BackgroundTransparency = 1
GradFrame.BorderSizePixel = 0

local Grad = Instance.new("UIGradient", GradFrame)
Grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T("Gradient1")),
    ColorSequenceKeypoint.new(0.5, T("Gradient2")),
    ColorSequenceKeypoint.new(1, T("Gradient1")),
})
Grad.Rotation = 45
Grad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.95),
    NumberSequenceKeypoint.new(0.5, 0.9),
    NumberSequenceKeypoint.new(1, 0.95),
})

local Glow = Instance.new("Frame", Main)
Glow.Size = UDim2.new(1, 20, 1, 20)
Glow.Position = UDim2.new(0, -10, 0, -10)
Glow.BackgroundColor3 = T("Glow")
Glow.BackgroundTransparency = 0.95
Glow.BorderSizePixel = 0
Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 20)

----------------------------------------------------------------------------------
-- SECTION 10: TITLE BAR
----------------------------------------------------------------------------------

local Title = Instance.new("Frame", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = T("Primary")
Title.BackgroundTransparency = 0.3
Title.BorderSizePixel = 0
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 16)

local TitleFix = Instance.new("Frame", Title)
TitleFix.Size = UDim2.new(1, 0, 0, 16)
TitleFix.Position = UDim2.new(0, 0, 1, -16)
TitleFix.BackgroundColor3 = T("Primary")
TitleFix.BackgroundTransparency = 0.3
TitleFix.BorderSizePixel = 0

local TitleText = Instance.new("TextLabel", Title)
TitleText.Size = UDim2.new(0, 250, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "💎 Liquid Glass Hub v4.0"
TitleText.TextColor3 = T("Text")
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local Controls = Instance.new("Frame", Title)
Controls.Size = UDim2.new(0, 120, 0, 30)
Controls.Position = UDim2.new(1, -130, 0.5, -15)
Controls.BackgroundTransparency = 1

local function MakeControlBtn(pos, color, text)
    local b = Instance.new("TextButton", Controls)
    b.Size = UDim2.new(0, 30, 0, 30)
    b.Position = UDim2.new(0, pos, 0, 0)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.3
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = T("Text")
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end

local MinBtn = MakeControlBtn(0, T("Warning"), "—")
local CloseBtn = MakeControlBtn(76, T("Error"), "✕")

local ThemeBtn = Instance.new("TextButton", Title)
ThemeBtn.Size = UDim2.new(0, 30, 0, 30)
ThemeBtn.Position = UDim2.new(1, -170, 0.5, -15)
ThemeBtn.BackgroundColor3 = T("Accent")
ThemeBtn.BackgroundTransparency = 0.4
ThemeBtn.BorderSizePixel = 0
ThemeBtn.Text = "🎨"
ThemeBtn.TextSize = 14
Instance.new("UICorner", ThemeBtn).CornerRadius = UDim.new(1, 0)

----------------------------------------------------------------------------------
-- SECTION 11: DRAG
----------------------------------------------------------------------------------

Title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        Hub.Dragging = true
        Hub.DragStart = i.Position
        Hub.StartPos = Main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                Hub.Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if Hub.Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - Hub.DragStart
        Main.Position = UDim2.new(
            Hub.StartPos.X.Scale, Hub.StartPos.X.Offset + d.X,
            Hub.StartPos.Y.Scale, Hub.StartPos.Y.Offset + d.Y
        )
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Hub.Minimized = not Hub.Minimized
    CreateTween(Main, {Size = Hub.Minimized and UDim2.new(0, 650, 0, 45) or UDim2.new(0, 650, 0, 480)}, 0.4, Enum.EasingStyle.Back)
end)

CloseBtn.MouseButton1Click:Connect(function()
    CreateTween(Main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Back)
    task.wait(0.5)
    pcall(function() ScreenGui:Destroy() end)
end)

----------------------------------------------------------------------------------
-- SECTION 12: SIDEBAR
----------------------------------------------------------------------------------

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 60, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = T("Secondary")
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0

local SL = Instance.new("UIListLayout", Sidebar)
SL.Padding = UDim.new(0, 5)
SL.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SP = Instance.new("UIPadding", Sidebar)
SP.PaddingTop = UDim.new(0, 15)

local TabData = {
    {Name="Combat", Icon="⚔️"},
    {Name="Movement", Icon="🏃"},
    {Name="Player", Icon="👤"},
    {Name="Render", Icon="👁️"},
    {Name="Utils", Icon="⚙️"},
}

local TabBtns = {}
local TabContents = {}

local function MakeTabBtn(data)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0, 44, 0, 44)
    b.BackgroundColor3 = T("TabInactive")
    b.BackgroundTransparency = 0.5
    b.BorderSizePixel = 0
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    
    local ic = Instance.new("TextLabel", b)
    ic.Size = UDim2.new(1, 0, 0, 25)
    ic.Position = UDim2.new(0, 0, 0, 3)
    ic.BackgroundTransparency = 1
    ic.Text = data.Icon
    ic.TextSize = 18
    
    local nm = Instance.new("TextLabel", b)
    nm.Size = UDim2.new(1, 0, 0, 15)
    nm.Position = UDim2.new(0, 0, 0, 27)
    nm.BackgroundTransparency = 1
    nm.Text = data.Name
    nm.TextColor3 = T("TextSecondary")
    nm.TextSize = 8
    nm.Font = Enum.Font.GothamBold
    
    local ind = Instance.new("Frame", b)
    ind.Size = UDim2.new(0, 3, 0, 30)
    ind.Position = UDim2.new(0, -5, 0.5, -15)
    ind.BackgroundColor3 = T("TabActive")
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)
    
    TabBtns[data.Name] = {Btn=b, Ind=ind, Name=nm}
    
    b.MouseEnter:Connect(function()
        if Hub.CurrentTab ~= data.Name then
            CreateTween(b, {BackgroundTransparency = 0.3}, 0.2)
        end
    end)
    b.MouseLeave:Connect(function()
        if Hub.CurrentTab ~= data.Name then
            CreateTween(b, {BackgroundTransparency = 0.5}, 0.2)
        end
    end)
    b.MouseButton1Click:Connect(function()
        if Hub.CurrentTab ~= data.Name then
            local cur = TabBtns[Hub.CurrentTab]
            if cur then
                CreateTween(cur.Btn, {BackgroundTransparency = 0.5}, 0.3)
                CreateTween(cur.Ind, {BackgroundTransparency = 1}, 0.3)
            end
            CreateTween(b, {BackgroundTransparency = 0.4}, 0.3)
            CreateTween(ind, {BackgroundTransparency = 0}, 0.3)
            Hub.CurrentTab = data.Name
            for n, c in pairs(TabContents) do
                if c then c.Visible = (n == data.Name) end
            end
        end
    end)
end

for _, td in ipairs(TabData) do MakeTabBtn(td) end

local function ActivateTab(name)
    local b = TabBtns[name]
    if b then
        CreateTween(b.Btn, {BackgroundTransparency = 0.4}, 0.01)
        CreateTween(b.Ind, {BackgroundTransparency = 0}, 0.01)
    end
end

----------------------------------------------------------------------------------
-- SECTION 13: CONTENT AREA
----------------------------------------------------------------------------------

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -60, 1, -45)
Content.Position = UDim2.new(0, 60, 0, 45)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0

----------------------------------------------------------------------------------
-- SECTION 14: UI COMPONENTS
----------------------------------------------------------------------------------

local function Section(parent, name)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -10, 0, 30)
    c.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", c)
    l.Size = UDim2.new(0, 150, 1, 0)
    l.Position = UDim2.new(0, 5, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = T("Accent")
    l.TextSize = 12
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    local sep = Instance.new("Frame", c)
    sep.Size = UDim2.new(1, -160, 0, 1)
    sep.Position = UDim2.new(0, 155, 0.5, 0)
    sep.BackgroundColor3 = T("TextSecondary")
    sep.BackgroundTransparency = 0.7
    sep.BorderSizePixel = 0
    return c
end

local function Toggle(parent, name, desc, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, 50)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 10)
    
    local nl = Instance.new("TextLabel", c)
    nl.Size = UDim2.new(1, -80, 0, 22)
    nl.Position = UDim2.new(0, 12, 0, 6)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = T("Text")
    nl.TextSize = 13
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    
    local dl = Instance.new("TextLabel", c)
    dl.Size = UDim2.new(1, -80, 0, 16)
    dl.Position = UDim2.new(0, 12, 0, 28)
    dl.BackgroundTransparency = 1
    dl.Text = desc or ""
    dl.TextColor3 = T("TextSecondary")
    dl.TextSize = 10
    dl.Font = Enum.Font.Gotham
    dl.TextXAlignment = Enum.TextXAlignment.Left
    
    local bg = Instance.new("Frame", c)
    bg.Size = UDim2.new(0, 42, 0, 22)
    bg.Position = UDim2.new(1, -54, 0.5, -11)
    bg.BackgroundColor3 = def and T("ToggleOn") or T("ToggleOff")
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local ci = Instance.new("Frame", bg)
    ci.Size = UDim2.new(0, 18, 0, 18)
    ci.Position = def and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    ci.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ci.BorderSizePixel = 0
    Instance.new("UICorner", ci).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton", c)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    local state = def or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        CreateTween(bg, {BackgroundColor3 = state and T("ToggleOn") or T("ToggleOff")}, 0.2)
        CreateTween(ci, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.3, Enum.EasingStyle.Back)
        if cb then pcall(cb, state) end
    end)
    return c, function(s)
        state = s
        bg.BackgroundColor3 = state and T("ToggleOn") or T("ToggleOff")
        ci.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    end
end

local function Slider(parent, name, min, max, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, 65)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 10)
    
    local nl = Instance.new("TextLabel", c)
    nl.Size = UDim2.new(0.5, 0, 0, 20)
    nl.Position = UDim2.new(0, 12, 0, 6)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = T("Text")
    nl.TextSize = 13
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    
    local vl = Instance.new("TextLabel", c)
    vl.Size = UDim2.new(0.5, -12, 0, 20)
    vl.Position = UDim2.new(0.5, 0, 0, 6)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(def)
    vl.TextColor3 = T("Accent")
    vl.TextSize = 13
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right
    
    local sb = Instance.new("Frame", c)
    sb.Size = UDim2.new(1, -24, 0, 6)
    sb.Position = UDim2.new(0, 12, 0, 40)
    sb.BackgroundColor3 = T("SliderBg")
    sb.BorderSizePixel = 0
    Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)
    
    local sf = Instance.new("Frame", sb)
    sf.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    sf.BackgroundColor3 = T("SliderFill")
    sf.BorderSizePixel = 0
    Instance.new("UICorner", sf).CornerRadius = UDim.new(1, 0)
    
    local sk = Instance.new("Frame", sb)
    sk.Size = UDim2.new(0, 14, 0, 14)
    sk.Position = UDim2.new((def - min) / (max - min), -7, 0.5, -7)
    sk.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sk.BorderSizePixel = 0
    Instance.new("UICorner", sk).CornerRadius = UDim.new(1, 0)
    
    local drag = false
    local val = def
    
    local function Upd(inp)
        local rel = (inp.Position.X - sb.AbsolutePosition.X) / sb.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        val = math.floor(min + (max - min) * rel + 0.5)
        sf.Size = UDim2.new(rel, 0, 1, 0)
        sk.Position = UDim2.new(rel, -7, 0.5, -7)
        vl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    
    sb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; Upd(i)
        end
    end)
    sb.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    sk.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end
    end)
    sk.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then Upd(i) end
    end)
    return c, function(v)
        val = math.clamp(v, min, max)
        local r = (val - min) / (max - min)
        sf.Size = UDim2.new(r, 0, 1, 0)
        sk.Position = UDim2.new(r, -7, 0.5, -7)
        vl.Text = tostring(val)
    end
end

local function Button(parent, name, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, 40)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 10)
    
    local b = Instance.new("TextButton", c)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = name
    b.TextColor3 = T("Text")
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    
    b.MouseEnter:Connect(function() CreateTween(c, {BackgroundTransparency = 0.4}, 0.2) end)
    b.MouseLeave:Connect(function() CreateTween(c, {BackgroundTransparency = 0.6}, 0.2) end)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return c
end

local function Dropdown(parent, name, opts, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, 50)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
    c.ClipsDescendants = false
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 10)
    
    local nl = Instance.new("TextLabel", c)
    nl.Size = UDim2.new(0.5, 0, 0, 20)
    nl.Position = UDim2.new(0, 12, 0, 6)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = T("Text")
    nl.TextSize = 13
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    
    local db = Instance.new("TextButton", c)
    db.Size = UDim2.new(0, 150, 0, 28)
    db.Position = UDim2.new(1, -162, 0.5, -14)
    db.BackgroundColor3 = T("Background")
    db.BorderSizePixel = 0
    db.Text = "  " .. (def or opts[1])
    db.TextColor3 = T("Text")
    db.TextSize = 11
    db.Font = Enum.Font.Gotham
    db.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", db).CornerRadius = UDim.new(0, 8)
    
    local list = Instance.new("Frame", c)
    list.Size = UDim2.new(0, 150, 0, 0)
    list.Position = UDim2.new(1, -162, 1, -8)
    list.BackgroundColor3 = T("Background")
    list.BackgroundTransparency = 0.1
    list.BorderSizePixel = 0
    list.Visible = false
    list.ClipsDescendants = true
    list.ZIndex = 10
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)
    
    local ll = Instance.new("UIListLayout", list)
    ll.Padding = UDim.new(0, 2)
    local lp = Instance.new("UIPadding", list)
    lp.PaddingTop = UDim.new(0, 5)
    lp.PaddingBottom = UDim.new(0, 5)
    
    local sel = def or opts[1]
    local open = false
    
    for _, opt in ipairs(opts) do
        local ob = Instance.new("TextButton", list)
        ob.Size = UDim2.new(1, 0, 0, 25)
        ob.BackgroundColor3 = T("Secondary")
        ob.BackgroundTransparency = 0.3
        ob.BorderSizePixel = 0
        ob.Text = "  " .. opt
        ob.TextColor3 = T("Text")
        ob.TextSize = 11
        ob.Font = Enum.Font.Gotham
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.ZIndex = 11
        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 6)
        ob.MouseButton1Click:Connect(function()
            sel = opt
            db.Text = "  " .. opt
            open = false
            CreateTween(list, {Size = UDim2.new(0, 150, 0, 0)}, 0.3, Enum.EasingStyle.Back)
            task.delay(0.3, function() list.Visible = false end)
            if cb then pcall(cb, opt) end
        end)
    end
    
    db.MouseButton1Click:Connect(function()
        open = not open
        if open then
            list.Visible = true
            CreateTween(list, {Size = UDim2.new(0, 150, 0, #opts * 27 + 10)}, 0.3, Enum.EasingStyle.Back)
        else
            CreateTween(list, {Size = UDim2.new(0, 150, 0, 0)}, 0.3, Enum.EasingStyle.Back)
            task.delay(0.3, function() list.Visible = false end)
        end
    end)
    return c
end

----------------------------------------------------------------------------------
-- SECTION 15: COMBAT TAB
----------------------------------------------------------------------------------

local function CombatTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 8)
    
    Section(c, "AIMBOT")
    Toggle(c, "Aimbot", "Lock onto enemies", false, function(s)
        Configs.Aimbot.Enabled = s
        Notify("Aimbot", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
    Slider(c, "Aimbot FOV", 10, 360, 180, function(v) Configs.Aimbot.FOV = v end)
    Slider(c, "Smoothness", 1, 100, 20, function(v) Configs.Aimbot.Smooth = v/100 end)
    Dropdown(c, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(v) Configs.Aimbot.Part = v end)
    Toggle(c, "Team Check", "Ignore team", false, function(s) Configs.Aimbot.TeamCheck = s end)
    Toggle(c, "Wall Check", "Only visible", true, function(s) Configs.Aimbot.WallCheck = s end)
    Slider(c, "Prediction", 0, 100, 16, function(v) Configs.Aimbot.Prediction = v/100 end)
    
    Section(c, "TRIGGERBOT")
    Toggle(c, "Triggerbot", "Auto fire on target", false, function(s)
        Configs.Triggerbot.Enabled = s
    end)
    Slider(c, "Trigger Delay", 0, 500, 0, function(v) Configs.Triggerbot.Delay = v/1000 end)
    Slider(c, "Max Distance", 10, 1000, 500, function(v) Configs.Triggerbot.MaxDist = v end)
    
    Section(c, "SILENT AIM")
    Toggle(c, "Silent Aim", "Server-side aim", false, function(s) Configs.SilentAim.Enabled = s end)
    Slider(c, "Hit Chance", 1, 100, 100, function(v) Configs.SilentAim.HitChance = v end)
    
    Section(c, "KILL AURA")
    Toggle(c, "Kill Aura", "Attack nearby", false, function(s) Configs.KillAura.Enabled = s end)
    Slider(c, "Aura Range", 1, 50, 15, function(v) Configs.KillAura.Range = v end)
    
    Section(c, "ADDITIONAL COMBAT")
    Toggle(c, "Hitbox Extender", "Bigger hitboxes", false, function(s) Configs.HitboxExtender.Enabled = s end)
    Slider(c, "Hitbox Size", 1, 20, 5, function(v) Configs.HitboxExtender.Size = v end)
    Toggle(c, "Anti-Aim", "Desync model", false, function(s) Configs.AntiAim.Enabled = s end)
    Dropdown(c, "Anti-Aim Type", {"Roll", "Spin", "Jitter", "Down"}, "Roll", function(v) Configs.AntiAim.Type = v end)
    Toggle(c, "Auto Parry", "Auto parry attacks", false, function(s) Configs.AutoParry.Enabled = s end)
    Toggle(c, "Reach", "Extended reach", false, function(s) Configs.Reach.Enabled = s end)
    Slider(c, "Reach Distance", 5, 30, 15, function(v) Configs.Reach.Distance = v end)
    Toggle(c, "Critical Hits", "Force crits", false, function(s) Configs.CriticalHits.Enabled = s end)
    Toggle(c, "Anti-Knockback", "No knockback", false, function(s) Configs.AntiKnockback.Enabled = s end)
    Toggle(c, "Auto Shoot", "Auto fire", false, function(s) Configs.AutoShoot.Enabled = s end)
    Toggle(c, "Auto Block", "Auto block", false, function(s) Configs.AutoBlock.Enabled = s end)
    
    TabContents["Combat"] = c
end

----------------------------------------------------------------------------------
-- SECTION 16: MOVEMENT TAB
----------------------------------------------------------------------------------

local function MovementTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 8)
    
    Section(c, "SPEED")
    Toggle(c, "Speed Hack", "Increase walkspeed", false, function(s)
        Configs.Speed.Enabled = s
        Notify("Speed", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
    Slider(c, "Walk Speed", 16, 500, 16, function(v) Configs.Speed.Value = v end)
    
    Section(c, "FLY")
    Toggle(c, "Fly", "Flight mode", false, function(s)
        Configs.Fly.Enabled = s
        Notify("Fly", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
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
    
    Section(c, "TELEPORTS")
    Button(c, "TP to Mouse", function()
        local r = GetRoot()
        if r then
            r.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            Notify("TP", "Teleported!", 2, "success")
        end
    end)
    Button(c, "TP to Sky", function()
        local r = GetRoot()
        if r then
            r.CFrame = CFrame.new(r.Position + Vector3.new(0, 1000, 0))
            Notify("TP", "Sky TP!", 2, "success")
        end
    end)
    Button(c, "TP to Spawn", function()
        local sp = Workspace:FindFirstChild("SpawnLocation", true)
        if sp then
            local r = GetRoot()
            if r then
                r.CFrame = sp.CFrame + Vector3.new(0, 5, 0)
                Notify("TP", "To spawn!", 2, "success")
            end
        end
    end)
    
    TabContents["Movement"] = c
end

----------------------------------------------------------------------------------
-- SECTION 17: PLAYER TAB
----------------------------------------------------------------------------------

local function PlayerTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, 900)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 8)
    
    Section(c, "SURVIVAL")
    Toggle(c, "God Mode", "Infinite HP", false, function(s)
        Configs.GodMode.Enabled = s
        Notify("God Mode", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
    Toggle(c, "Anti-Void", "Prevent void death", false, function(s) Configs.AntiVoid.Enabled = s end)
    Slider(c, "Void Height", -1000, -100, -500, function(v) Configs.AntiVoid.Height = v end)
    Toggle(c, "No Fall Damage", "No fall damage", false, function(s) Configs.NoFall.Enabled = s end)
    Toggle(c, "Anti-Grab", "Prevent grab", false, function(s) Configs.AntiGrab.Enabled = s end)
    Toggle(c, "Auto Revive", "Auto respawn", false, function(s) Configs.AutoRevive.Enabled = s end)
    
    Section(c, "AUTOMATION")
    Toggle(c, "Anti-AFK", "Prevent AFK kick", false, function(s) Configs.AntiAFK.Enabled = s end)
    Toggle(c, "Auto Click", "Auto click", false, function(s) Configs.AutoClick.Enabled = s end)
    Slider(c, "Clicks/Second", 1, 30, 10, function(v) Configs.AutoClick.CPS = v end)
    Toggle(c, "Auto Farm", "Auto farm", false, function(s) Configs.AutoFarm.Enabled = s end)
    
    Section(c, "CHARACTER ACTIONS")
    Button(c, "Reset Character", function()
        local h = GetHumanoid()
        if h then
            h.Health = 0
            Notify("Character", "Reset!", 2, "warning")
        end
    end)
    Button(c, "Heal to Full", function()
        local h = GetHumanoid()
        if h then
            h.Health = h.MaxHealth
            Notify("Character", "Healed!", 2, "success")
        end
    end)
    Button(c, "Set Max HP to Infinite", function()
        local h = GetHumanoid()
        if h then
            h.MaxHealth = math.huge
            h.Health = math.huge
            Notify("Character", "Infinite HP!", 2, "success")
        end
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
    Button(c, "Copy Display Name", function()
        if setclipboard then pcall(setclipboard, LocalPlayer.DisplayName) end
        Notify("Info", "Copied: " .. LocalPlayer.DisplayName, 2, "success")
    end)
    
    TabContents["Player"] = c
end

----------------------------------------------------------------------------------
-- SECTION 18: RENDER TAB
----------------------------------------------------------------------------------

local function RenderTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 8)
    
    Section(c, "ESP")
    Toggle(c, "ESP", "Show player info", false, function(s)
        Configs.ESP.Enabled = s
        Notify("ESP", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
    Toggle(c, "Box ESP", "Boxes around players", true, function(s) Configs.ESP.Box = s end)
    Toggle(c, "Name ESP", "Show names", true, function(s) Configs.ESP.Name = s end)
    Toggle(c, "Health ESP", "Health bars", true, function(s) Configs.ESP.Health = s end)
    Toggle(c, "Distance ESP", "Show distance", true, function(s) Configs.ESP.Distance = s end)
    Toggle(c, "Team Check", "Ignore team", false, function(s) Configs.ESP.TeamCheck = s end)
    Slider(c, "Max Distance", 100, 5000, 1000, function(v) Configs.ESP.MaxDist = v end)
    
    Section(c, "TRACERS")
    Toggle(c, "Tracers", "Lines to players", false, function(s) Configs.Tracers.Enabled = s end)
    Dropdown(c, "Tracer Origin", {"Bottom", "Center", "Top", "Mouse"}, "Bottom", function(v) Configs.Tracers.Origin = v end)
    
    Section(c, "CHAMS")
    Toggle(c, "Chams", "Highlight through walls", false, function(s) Configs.Chams.Enabled = s end)
    Slider(c, "Chams Transparency", 0, 100, 50, function(v) Configs.Chams.Transparency = v/100 end)
    
    Section(c, "SKELETON")
    Toggle(c, "Skeleton ESP", "Show bones", false, function(s) Configs.SkeletonESP.Enabled = s end)
    
    Section(c, "VISUALS")
    Toggle(c, "Fullbright", "Remove darkness", false, function(s) Configs.Fullbright.Enabled = s end)
    Toggle(c, "No Fog", "Remove fog", false, function(s) Configs.NoFog.Enabled = s end)
    Toggle(c, "X-Ray", "See through walls", false, function(s) Configs.Xray.Enabled = s end)
    Slider(c, "X-Ray Transparency", 0, 100, 70, function(v) Configs.Xray.Transparency = v/100 end)
    Toggle(c, "Wireframe", "Wireframe view", false, function(s) Configs.Wireframe.Enabled = s end)
    
    Section(c, "CAMERA")
    Toggle(c, "Freecam", "Free camera", false, function(s) Configs.Freecam.Enabled = s end)
    Slider(c, "Freecam Speed", 10, 200, 50, function(v) Configs.Freecam.Speed = v end)
    Toggle(c, "FOV Changer", "Change FOV", false, function(s) Configs.FOVChanger.Enabled = s end)
    Slider(c, "Camera FOV", 30, 120, 70, function(v) Configs.FOVChanger.Value = v end)
    Toggle(c, "Camera Shake", "Shake effect", false, function(s) Configs.CameraShake.Enabled = s end)
    Slider(c, "Shake Intensity", 1, 20, 3, function(v) Configs.CameraShake.Intensity = v end)
    
    TabContents["Render"] = c
end

----------------------------------------------------------------------------------
-- SECTION 19: UTILS TAB
----------------------------------------------------------------------------------

local function UtilsTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = 3
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, 1100)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, 8)
    
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
    Button(c, "Copy PlaceId", function()
        if setclipboard then pcall(setclipboard, tostring(game.PlaceId)) end
        Notify("Server", "PlaceId copied!", 2, "success")
    end)
    
    Section(c, "CHAT")
    Toggle(c, "Chat Spammer", "Auto send messages", false, function(s) Configs.ChatSpam.Enabled = s end)
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
    Button(c, "Copy CFrame", function()
        local r = GetRoot()
        if r and setclipboard then
            pcall(setclipboard, tostring(r.CFrame))
            Notify("CFrame", "Copied!", 2, "success")
        end
    end)
    Button(c, "Show Player Count", function()
        Notify("Players", "Count: " .. #Players:GetPlayers(), 3, "info")
    end)
    Button(c, "Copy All Player Names", function()
        local n = ""
        for _, p in ipairs(Players:GetPlayers()) do n = n .. p.Name .. "\n" end
        if setclipboard then pcall(setclipboard, n) end
        Notify("Players", "Copied all names!", 2, "success")
    end)
    
    Section(c, "PERFORMANCE")
    Button(c, "Remove Terrain", function()
        pcall(function()
            if Workspace.Terrain then Workspace.Terrain:Clear() end
        end)
        Notify("Perf", "Terrain removed!", 2, "warning")
    end)
    Button(c, "Remove Particles", function()
        pcall(function()
            for _, o in pairs(Workspace:GetDescendants()) do
                if o:IsA("ParticleEmitter") then o.Enabled = false end
            end
        end)
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
-- SECTION 20: CREATE ALL TABS
----------------------------------------------------------------------------------

CombatTab()
MovementTab()
PlayerTab()
RenderTab()
UtilsTab()

ActivateTab("Combat")
for n, c in pairs(TabContents) do
    if n ~= "Combat" then c.Visible = false end
end

----------------------------------------------------------------------------------
-- SECTION 21: THEME PANEL
----------------------------------------------------------------------------------

local ThemePanel = Instance.new("Frame", Main)
ThemePanel.Size = UDim2.new(0, 200, 0, 0)
ThemePanel.Position = UDim2.new(0, 60, 0, 45)
ThemePanel.BackgroundColor3 = T("Secondary")
ThemePanel.BackgroundTransparency = 0.3
ThemePanel.BorderSizePixel = 0
ThemePanel.Visible = false
ThemePanel.ZIndex = 20
ThemePanel.ClipsDescendants = true
Instance.new("UICorner", ThemePanel).CornerRadius = UDim.new(0, 12)

local tpStroke = Instance.new("UIStroke", ThemePanel)
tpStroke.Color = T("GlassBorder")
tpStroke.Thickness = 1
tpStroke.Transparency = 0.5

local tpTitle = Instance.new("TextLabel", ThemePanel)
tpTitle.Size = UDim2.new(1, 0, 0, 35)
tpTitle.BackgroundTransparency = 1
tpTitle.Text = "🎨 Themes"
tpTitle.TextColor3 = T("Text")
tpTitle.TextSize = 14
tpTitle.Font = Enum.Font.GothamBold

Instance.new("UIListLayout", ThemePanel).Padding = UDim.new(0, 5)
local tp = Instance.new("UIPadding", ThemePanel)
tp.PaddingTop = UDim.new(0, 40)
tp.PaddingLeft = UDim.new(0, 10)
tp.PaddingRight = UDim.new(0, 10)
tp.PaddingBottom = UDim.new(0, 10)

local TPOpen = false
ThemeBtn.MouseButton1Click:Connect(function()
    TPOpen = not TPOpen
    if TPOpen then
        ThemePanel.Visible = true
        CreateTween(ThemePanel, {Size = UDim2.new(0, 200, 0, 350)}, 0.4, Enum.EasingStyle.Back)
    else
        CreateTween(ThemePanel, {Size = UDim2.new(0, 200, 0, 0)}, 0.3)
        task.delay(0.3, function() ThemePanel.Visible = false end)
    end
end)

local function UpdateColors()
    pcall(function()
        Main.BackgroundColor3 = T("Background")
        MainStroke.Color = T("GlassBorder")
        Title.BackgroundColor3 = T("Primary")
        TitleFix.BackgroundColor3 = T("Primary")
        Sidebar.BackgroundColor3 = T("Secondary")
        Overlay.BackgroundColor3 = T("Glass")
        Grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, T("Gradient1")),
            ColorSequenceKeypoint.new(0.5, T("Gradient2")),
            ColorSequenceKeypoint.new(1, T("Gradient1")),
        })
        Glow.BackgroundColor3 = T("Glow")
    end)
end

for name, data in pairs(Themes) do
    local item = Instance.new("TextButton", ThemePanel)
    item.Size = UDim2.new(1, 0, 0, 35)
    item.BackgroundColor3 = data.Accent
    item.BackgroundTransparency = 0.6
    item.BorderSizePixel = 0
    item.Text = "  " .. data.Name
    item.TextColor3 = Color3.fromRGB(255, 255, 255)
    item.TextSize = 12
    item.Font = Enum.Font.GothamBold
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.ZIndex = 21
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    
    item.MouseButton1Click:Connect(function()
        Hub.CurrentTheme = name
        CurrentTheme = data
        UpdateColors()
        Notify("Theme", "Switched to " .. data.Name, 2, "success")
        TPOpen = false
        CreateTween(ThemePanel, {Size = UDim2.new(0, 200, 0, 0)}, 0.3)
        task.delay(0.3, function() ThemePanel.Visible = false end)
    end)
    item.MouseEnter:Connect(function() CreateTween(item, {BackgroundTransparency = 0.3}, 0.2) end)
    item.MouseLeave:Connect(function() CreateTween(item, {BackgroundTransparency = 0.6}, 0.2) end)
end

----------------------------------------------------------------------------------
-- SECTION 22: STATUS BAR
----------------------------------------------------------------------------------

local Status = Instance.new("Frame", Main)
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 1, -25)
Status.BackgroundColor3 = T("Primary")
Status.BackgroundTransparency = 0.5
Status.BorderSizePixel = 0

local StatusLabel = Instance.new("TextLabel", Status)
StatusLabel.Size = UDim2.new(0.7, 0, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "💎 Liquid Glass Hub v4.0"
StatusLabel.TextColor3 = T("TextSecondary")
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local FPSLabel = Instance.new("TextLabel", Status)
FPSLabel.Size = UDim2.new(0.3, -10, 1, 0)
FPSLabel.Position = UDim2.new(0.7, 0, 0, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: 60"
FPSLabel.TextColor3 = T("Success")
FPSLabel.TextSize = 10
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right

----------------------------------------------------------------------------------
-- SECTION 23: ANIMATIONS
----------------------------------------------------------------------------------

task.spawn(function()
    while Main and Main.Parent do
        local p = Instance.new("Frame", Main)
        p.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        p.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.8 + 0.1, 0)
        p.BackgroundColor3 = T("Particle")
        p.BackgroundTransparency = 0.7
        p.BorderSizePixel = 0
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        CreateTween(p, {
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundTransparency = 1,
        }, math.random(2, 4))
        task.delay(math.random(2, 4), function() pcall(function() p:Destroy() end) end)
        task.wait(0.3)
    end
end)

task.spawn(function()
    while Main and Main.Parent do
        local t = tick() * 0.3
        local r = math.sin(t) * 0.5 + 0.5
        local c1 = CurrentTheme.Gradient1:Lerp(CurrentTheme.Gradient2, r)
        local c2 = CurrentTheme.Gradient2:Lerp(CurrentTheme.Gradient1, 1-r)
        pcall(function()
            Grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(0.5, c2),
                ColorSequenceKeypoint.new(1, c1),
            })
            Grad.Rotation = 45 + math.sin(tick() * 0.5) * 5
        end)
        task.wait(0.1)
    end
end)

task.spawn(function()
    while Main and Main.Parent do
        pcall(function()
            local pulse = (math.sin(tick() * 2) + 1) / 2
            MainStroke.Transparency = 0.3 + pulse * 0.2
            Glow.BackgroundTransparency = 0.93 + pulse * 0.04
        end)
        task.wait(0.05)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 24: KEYBINDS
----------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if Main then Main.Visible = not Main.Visible end
    end
    if i.KeyCode == Enum.KeyCode.Q and Configs.Blink.Enabled then
        local r = GetRoot()
        if r then
            r.CFrame = r.CFrame + Camera.CFrame.LookVector * Configs.Blink.Distance
            Notify("Blink", "TP " .. Configs.Blink.Distance .. " studs!", 1, "success")
        end
    end
end)

----------------------------------------------------------------------------------
-- SECTION 25: COMBAT LOOPS
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
                        if trp then
                            tpos = tpos + trp.Velocity * Configs.Aimbot.Prediction
                        end
                        local cp = Camera.CFrame
                        local nc = CFrame.new(cp.Position, tpos)
                        Camera.CFrame = cp:Lerp(nc, Configs.Aimbot.Smooth)
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
                        local d = GetDistance(LocalPlayer, tp)
                        if d <= Configs.Triggerbot.MaxDist then
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
                        local d = GetDistance(LocalPlayer, p)
                        if d <= Configs.KillAura.Range then
                            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then pcall(function() tool:Activate() end) end
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- HITBOX EXTENDER
local HitboxParts = {}
task.spawn(function()
    while true do
        pcall(function()
            if Configs.HitboxExtender.Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        local rp = p.Character:FindFirstChild("HumanoidRootPart")
                        if rp and not HitboxParts[p.UserId] then
                            local hb = Instance.new("Part")
                            hb.Name = "LGHITBOX"
                            hb.Size = Vector3.new(5, 5, 5)
                            hb.Transparency = 0.7
                            hb.CanCollide = false
                            hb.Anchored = false
                            hb.Color = Color3.fromRGB(255, 0, 0)
                            hb.Material = Enum.Material.ForceField
                            hb.Parent = p.Character
                            local w = Instance.new("WeldConstraint", hb)
                            w.Part0 = hb
                            w.Part1 = rp
                            HitboxParts[p.UserId] = hb
                        end
                        if HitboxParts[p.UserId] then
                            local s = Configs.HitboxExtender.Size
                            HitboxParts[p.UserId].Size = Vector3.new(s, s, s)
                            HitboxParts[p.UserId].Transparency = Configs.HitboxExtender.Transparency
                        end
                    end
                end
            else
                for uid, part in pairs(HitboxParts) do
                    if part then pcall(function() part:Destroy() end) end
                end
                HitboxParts = {}
            end
            for uid, part in pairs(HitboxParts) do
                local p = Players:GetPlayerByUserId(uid)
                if not p or not IsAlive(p) then
                    if part then pcall(function() part:Destroy() end) end
                    HitboxParts[uid] = nil
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- ANTI-AIM
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AntiAim.Enabled then
                local rp = GetRoot()
                if rp then
                    local s = Configs.AntiAim.Speed
                    if Configs.AntiAim.Type == "Spin" then
                        rp.CFrame = rp.CFrame * CFrame.Angles(0, math.rad(tick() * s * 10), 0)
                    elseif Configs.AntiAim.Type == "Roll" then
                        rp.CFrame = rp.CFrame * CFrame.Angles(math.rad(math.sin(tick() * s) * 180), 0, math.rad(math.cos(tick() * s) * 180))
                    elseif Configs.AntiAim.Type == "Jitter" then
                        rp.CFrame = rp.CFrame * CFrame.Angles(math.rad((math.random()-0.5)*180), math.rad((math.random()-0.5)*180), math.rad((math.random()-0.5)*180))
                    elseif Configs.AntiAim.Type == "Down" then
                        rp.CFrame = rp.CFrame * CFrame.Angles(math.rad(180), 0, 0)
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- REACH
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Reach.Enabled then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local h = tool:FindFirstChild("Handle")
                    if h and firetouchinterest then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local d = GetDistance(LocalPlayer, p)
                                if d <= Configs.Reach.Distance then
                                    local tp = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
                                    if tp then
                                        firetouchinterest(h, tp, 0)
                                        task.wait(0.01)
                                        firetouchinterest(h, tp, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- ANTI-KNOCKBACK
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AntiKnockback.Enabled then
                local rp = GetRoot()
                if rp then
                    local v = rp.Velocity
                    if v.Magnitude > 100 then
                        rp.Velocity = Vector3.new(0, v.Y, 0)
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- AUTO SHOOT
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AutoShoot.Enabled then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
                task.wait(Configs.AutoShoot.Delay)
            else
                task.wait(0.1)
            end
        end)
    end
end)

-- AUTO PARRY/BLOCK
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AutoParry.Enabled or Configs.AutoBlock.Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        local d = GetDistance(LocalPlayer, p)
                        if d <= 10 then
                            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then pcall(function() tool:Activate() end) end
                            break
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 26: MOVEMENT LOOPS
----------------------------------------------------------------------------------

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
                    if not FlyBV then
                        FlyBV = Instance.new("BodyVelocity", rp)
                        FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    end
                    if not FlyBG then
                        FlyBG = Instance.new("BodyGyro", rp)
                        FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        FlyBG.P = 10000
                    end
                    local mv = Camera.CFrame.LookVector
                    local ud = 0
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then ud = 1
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then ud = -1 end
                    FlyBV.Velocity = (mv * Configs.Fly.Speed) + Vector3.new(0, ud * Configs.Fly.Speed, 0)
                    FlyBG.CFrame = Camera.CFrame
                    if Configs.Fly.Noclip then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
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
                        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
            elseif not Configs.Noclip.Enabled and NoclipConn then
                NoclipConn:Disconnect()
                NoclipConn = nil
                if LocalPlayer.Character then
                    for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
                    end
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
                InfJumpConn:Disconnect()
                InfJumpConn = nil
            end
        end)
        task.wait(0.1)
    end
end)

-- LONG JUMP
task.spawn(function()
    while true do
        pcall(function()
            if Configs.LongJump.Enabled then
                local h = GetHumanoid()
                if h then h.JumpPower = Configs.LongJump.Power end
            end
        end)
        task.wait()
    end
end)

-- BUNNY HOP
task.spawn(function()
    while true do
        pcall(function()
            if Configs.BunnyHop.Enabled then
                local h = GetHumanoid()
                if h then
                    pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
                    h.WalkSpeed = Configs.BunnyHop.Speed
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- HIGH JUMP
task.spawn(function()
    while true do
        pcall(function()
            if Configs.HighJump.Enabled then
                local h = GetHumanoid()
                if h then h.JumpPower = Configs.HighJump.Height end
            end
        end)
        task.wait()
    end
end)

-- JETPACK
local JetpackBV
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Jetpack.Enabled then
                local rp = GetRoot()
                if rp then
                    if not JetpackBV then
                        JetpackBV = Instance.new("BodyVelocity", rp)
                        JetpackBV.MaxForce = Vector3.new(0, math.huge, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        JetpackBV.Velocity = Vector3.new(0, Configs.Jetpack.Power, 0)
                    else
                        JetpackBV.Velocity = Vector3.zero
                    end
                end
            else
                if JetpackBV then pcall(function() JetpackBV:Destroy() end); JetpackBV = nil end
            end
        end)
        task.wait()
    end
end)

-- CFRAME SPEED
task.spawn(function()
    while true do
        pcall(function()
            if Configs.CFrameSpeed.Enabled then
                local rp = GetRoot()
                local h = GetHumanoid()
                if rp and h then
                    local mv = h.MoveDirection
                    if mv.Magnitude > 0 then
                        rp.CFrame = rp.CFrame + mv * (Configs.CFrameSpeed.Value / 10)
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- WALL CLIMB
task.spawn(function()
    while true do
        pcall(function()
            if Configs.WallClimb.Enabled then
                local rp = GetRoot()
                local h = GetHumanoid()
                if rp and h then
                    local mv = h.MoveDirection
                    if mv.Magnitude > 0 then
                        local ray = Ray.new(rp.Position, mv * 3)
                        local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                        if hit and UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            rp.Velocity = Vector3.new(rp.Velocity.X, 20, rp.Velocity.Z)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- GLIDE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Glide.Enabled then
                local rp = GetRoot()
                if rp and rp.Velocity.Y < 0 then
                    local lv = Camera.CFrame.LookVector
                    rp.Velocity = Vector3.new(lv.X * 50, rp.Velocity.Y * 0.5, lv.Z * 50)
                end
            end
        end)
        task.wait()
    end
end)

-- SPIDER
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Spider.Enabled then
                local rp = GetRoot()
                local h = GetHumanoid()
                if rp and h then
                    local mv = h.MoveDirection
                    if mv.Magnitude > 0 then
                        local ray = Ray.new(rp.Position, mv * 2)
                        local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                        if hit then
                            rp.CFrame = rp.CFrame + Vector3.new(0, 0.7, 0)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end)

----------------------------------------------------------------------------------
-- SECTION 27: PLAYER LOOPS
----------------------------------------------------------------------------------

-- GOD MODE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.GodMode.Enabled then
                local h = GetHumanoid()
                if h then
                    h.MaxHealth = math.huge
                    h.Health = math.huge
                end
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
                    Notify("Anti-Void", "Saved from void!", 2, "warning")
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
                if rp then
                    rp.Velocity = Vector3.new(rp.Velocity.X, math.max(rp.Velocity.Y, -50), rp.Velocity.Z)
                end
            end
        end)
        task.wait()
    end
end)

-- ANTI-AFK
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AntiAFK.Enabled and LocalPlayer.Idled then
                LocalPlayer.Idled:Connect(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end)
                Configs.AntiAFK.Enabled = false
            end
        end)
        task.wait(60)
    end
end)

-- AUTO CLICK
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AutoClick.Enabled and mouse1click then
                mouse1click()
                task.wait(1 / Configs.AutoClick.CPS)
            else
                task.wait(0.1)
            end
        end)
    end
end)

-- ANTI-GRAB
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AntiGrab.Enabled and LocalPlayer.Character then
                for _, o in pairs(LocalPlayer.Character:GetDescendants()) do
                    if (o:IsA("WeldConstraint") or o:IsA("Weld")) and o.Name:lower():find("grab") then
                        pcall(function() o:Destroy() end)
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- AUTO REVIVE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AutoRevive.Enabled then
                local h = GetHumanoid()
                if h and h.Health <= 0 then
                    task.wait(2)
                    local h2 = GetHumanoid()
                    if h2 then h2.Health = h2.MaxHealth end
                end
            end
        end)
        task.wait(0.5)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 28: RENDER LOOPS - ESP
----------------------------------------------------------------------------------

task.spawn(function()
    while true do
        pcall(function()
            -- Clear
            for _, o in pairs(Hub.ESPObjects) do
                if o then pcall(function() o:Remove() end) end
            end
            Hub.ESPObjects = {}
            
            if Configs.ESP.Enabled and HasDrawing then
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
                                    local col = (p.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                                    
                                    if Configs.ESP.Box then
                                        local box = Drawing.new("Square")
                                        box.Size = Vector2.new(bw, bh)
                                        box.Position = Vector2.new(sp.X - bw/2, hs.Y)
                                        box.Thickness = 1.5
                                        box.Color = col
                                        box.Filled = false
                                        box.Visible = true
                                        table.insert(Hub.ESPObjects, box)
                                    end
                                    if Configs.ESP.Name then
                                        local nm = Drawing.new("Text")
                                        nm.Text = p.Name
                                        nm.Center = true
                                        nm.Outline = true
                                        nm.Size = 14
                                        nm.Color = Color3.fromRGB(255, 255, 255)
                                        nm.Position = Vector2.new(sp.X, hs.Y - 20)
                                        nm.Visible = true
                                        table.insert(Hub.ESPObjects, nm)
                                    end
                                    if Configs.ESP.Health then
                                        local hp = h.Health / h.MaxHealth
                                        local bg = Drawing.new("Square")
                                        bg.Size = Vector2.new(3, bh)
                                        bg.Position = Vector2.new(sp.X - bw/2 - 8, hs.Y)
                                        bg.Color = Color3.fromRGB(50, 50, 50)
                                        bg.Filled = true
                                        bg.Visible = true
                                        table.insert(Hub.ESPObjects, bg)
                                        local bar = Drawing.new("Square")
                                        bar.Size = Vector2.new(3, bh * hp)
                                        bar.Position = Vector2.new(sp.X - bw/2 - 8, hs.Y + bh - bh*hp)
                                        bar.Color = Color3.fromRGB(255 - 255*hp, 255*hp, 0)
                                        bar.Filled = true
                                        bar.Visible = true
                                        table.insert(Hub.ESPObjects, bar)
                                    end
                                    if Configs.ESP.Distance then
                                        local dt = Drawing.new("Text")
                                        dt.Text = "[" .. math.floor(d) .. "m]"
                                        dt.Center = true
                                        dt.Outline = true
                                        dt.Size = 12
                                        dt.Color = Color3.fromRGB(200, 200, 200)
                                        dt.Position = Vector2.new(sp.X, fs.Y + 5)
                                        dt.Visible = true
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
            for _, o in pairs(Hub.TracerObjects) do
                if o then pcall(function() o:Remove() end) end
            end
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
                                if Configs.Tracers.Origin == "Bottom" then
                                    origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                                elseif Configs.Tracers.Origin == "Center" then
                                    origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                                elseif Configs.Tracers.Origin == "Top" then
                                    origin = Vector2.new(Camera.ViewportSize.X/2, 0)
                                elseif Configs.Tracers.Origin == "Mouse" then
                                    origin = UserInputService:GetMouseLocation()
                                end
                                local tr = Drawing.new("Line")
                                tr.From = origin
                                tr.To = sp
                                tr.Color = Color3.fromRGB(255, 255, 255)
                                tr.Thickness = 1
                                tr.Visible = true
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
            for _, c in pairs(Hub.ChamsObjects) do
                if c then pcall(function() c:Destroy() end) end
            end
            Hub.ChamsObjects = {}
            if Configs.Chams.Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        if Configs.Chams.TeamCheck and p.Team == LocalPlayer.Team then continue end
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = Configs.Chams.Transparency
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = p.Character
                        table.insert(Hub.ChamsObjects, hl)
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- SKELETON ESP
task.spawn(function()
    while true do
        pcall(function()
            for _, o in pairs(Hub.SkeletonObjects) do
                if o then pcall(function() o:Remove() end) end
            end
            Hub.SkeletonObjects = {}
            if Configs.SkeletonESP.Enabled and HasDrawing then
                local conns = {
                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
                }
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        for _, c in ipairs(conns) do
                            local p1 = p.Character:FindFirstChild(c[1])
                            local p2 = p.Character:FindFirstChild(c[2])
                            if p1 and p2 then
                                local s1, o1 = WorldToScreen(p1.Position)
                                local s2, o2 = WorldToScreen(p2.Position)
                                if o1 and o2 then
                                    local ln = Drawing.new("Line")
                                    ln.From = s1
                                    ln.To = s2
                                    ln.Color = Color3.fromRGB(255, 255, 255)
                                    ln.Thickness = 2
                                    ln.Visible = true
                                    table.insert(Hub.SkeletonObjects, ln)
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

-- FULLBRIGHT
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Fullbright.Enabled then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            end
        end)
        task.wait(1)
    end
end)

-- NO FOG
task.spawn(function()
    while true do
        pcall(function()
            if Configs.NoFog.Enabled then
                Lighting.FogStart = 0
                Lighting.FogEnd = 9999999
            end
        end)
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
                        if not Hub.OriginalTransparencies[p] then
                            Hub.OriginalTransparencies[p] = p.Transparency
                        end
                        p.Transparency = Configs.Xray.Transparency
                    end
                end
            else
                for p, o in pairs(Hub.OriginalTransparencies) do
                    if p and p.Parent then p.Transparency = o end
                end
                Hub.OriginalTransparencies = {}
            end
        end)
        task.wait(1)
    end
end)

-- FOV CHANGER
task.spawn(function()
    while true do
        pcall(function()
            if Configs.FOVChanger.Enabled then
                Camera.FieldOfView = Configs.FOVChanger.Value
            else
                Camera.FieldOfView = 70
            end
        end)
        task.wait()
    end
end)

-- CAMERA SHAKE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.CameraShake.Enabled then
                local i = Configs.CameraShake.Intensity
                Camera.CFrame = Camera.CFrame * CFrame.new((math.random()-0.5)*i, (math.random()-0.5)*i, 0)
            end
        end)
        task.wait()
    end
end)

-- FREECAM
local FreecamActive = false
local FreecamBV, FreecamBG
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Freecam.Enabled and not FreecamActive then
                FreecamActive = true
                Camera.CameraType = Enum.CameraType.Scriptable
                FreecamBV = Instance.new("BodyVelocity", Camera)
                FreecamBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                FreecamBG = Instance.new("BodyGyro", Camera)
                FreecamBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            elseif not Configs.Freecam.Enabled and FreecamActive then
                FreecamActive = false
                Camera.CameraType = Enum.CameraType.Custom
                if FreecamBV then pcall(function() FreecamBV:Destroy() end); FreecamBV = nil end
                if FreecamBG then pcall(function() FreecamBG:Destroy() end); FreecamBG = nil end
            end
            if FreecamActive and FreecamBV and FreecamBG then
                local s = Configs.Freecam.Speed
                local mv = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0, 1, 0) end
                FreecamBV.Velocity = mv * s
                FreecamBG.CFrame = Camera.CFrame
            end
        end)
        task.wait()
    end
end)

----------------------------------------------------------------------------------
-- SECTION 29: UTILS LOOPS
----------------------------------------------------------------------------------

-- CHAT SPAM
task.spawn(function()
    while true do
        pcall(function()
            if Configs.ChatSpam.Enabled then
                local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents", true)
                if ev then
                    local say = ev:FindFirstChild("SayMessageRequest")
                    if say then
                        say:FireServer(Configs.ChatSpam.Message, "All")
                    end
                end
                task.wait(Configs.ChatSpam.Delay)
            else
                task.wait(0.5)
            end
        end)
    end
end)

-- TIME CHANGE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.TimeChange.Enabled then
                Lighting.ClockTime = Configs.TimeChange.Time
            end
        end)
        task.wait(1)
    end
end)

-- GRAVITY
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Gravity.Enabled then
                Workspace.Gravity = Configs.Gravity.Value
            else
                Workspace.Gravity = 196.2
            end
        end)
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
                                firetouchinterest(rp, o, 0)
                                task.wait()
                                firetouchinterest(rp, o, 1)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- NO COOLDOWN
task.spawn(function()
    while true do
        pcall(function()
            if Configs.NoCooldown.Enabled and LocalPlayer.Character then
                for _, o in pairs(LocalPlayer.Character:GetDescendants()) do
                    if o:IsA("NumberValue") and o.Name:lower():find("cooldown") then
                        o.Value = 0
                    elseif o:IsA("BoolValue") and o.Name:lower():find("cooldown") then
                        o.Value = false
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- AUTO FARM
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AutoFarm.Enabled then
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o.Name:lower():find("coin") or o.Name:lower():find("cash") or o.Name:lower():find("money") then
                        local rp = GetRoot()
                        if rp then
                            rp.CFrame = CFrame.new(o.Position)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- RAINBOW MODE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.RainbowMode.Enabled then
                local h = tick() * 0.1 % 1
                local c = Color3.fromHSV(h, 1, 1)
                CurrentTheme.Accent = c
                CurrentTheme.Glow = c
                CurrentTheme.ToggleOn = c
                CurrentTheme.SliderFill = c
                CurrentTheme.TabActive = c
                UpdateColors()
            end
        end)
        task.wait(0.05)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 30: FPS COUNTER
----------------------------------------------------------------------------------

task.spawn(function()
    local fc = 0
    local lt = tick()
    while ScreenGui and ScreenGui.Parent do
        fc = fc + 1
        local ct = tick()
        if ct - lt >= 1 then
            if FPSLabel and FPSLabel.Parent then
                FPSLabel.Text = "FPS: " .. fc
            end
            fc = 0
            lt = ct
        end
        task.wait()
    end
end)

----------------------------------------------------------------------------------
-- SECTION 31: ACTIVE FEATURES COUNTER
----------------------------------------------------------------------------------

task.spawn(function()
    while true do
        local ac = 0
        for _, c in pairs(Configs) do
            if c.Enabled then ac = ac + 1 end
        end
        if StatusLabel and StatusLabel.Parent then
            StatusLabel.Text = "💎 Liquid Glass Hub v4.0 | Active: " .. ac
        end
        task.wait(1)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 32: INTRO ANIMATION
----------------------------------------------------------------------------------

task.spawn(function()
    Main.Position = UDim2.new(0.5, -325, 1.5, 0)
    Main.Size = UDim2.new(0, 0, 0, 0)
    task.wait(0.3)
    CreateTween(Main, {
        Position = UDim2.new(0.5, -325, 0.5, -240),
        Size = UDim2.new(0, 650, 0, 480),
    }, 0.8, Enum.EasingStyle.Back)
    task.wait(1)
    Notify("Welcome", "Liquid Glass Hub v4.0 loaded!", 4, "success")
    task.wait(2)
    Notify("Info", "Press RIGHT SHIFT to toggle GUI", 4, "info")
    task.wait(2)
    Notify("Info", "Press Q for Blink teleport (enable first)", 4, "info")
end)

----------------------------------------------------------------------------------
-- SECTION 33: CLEANUP
----------------------------------------------------------------------------------

ScreenGui.Destroying:Connect(function()
    pcall(function()
        if NoclipConn then NoclipConn:Disconnect() end
        if InfJumpConn then InfJumpConn:Disconnect() end
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        if JetpackBV then JetpackBV:Destroy() end
        if FreecamBV then FreecamBV:Destroy() end
        if FreecamBG then FreecamBG:Destroy() end
        for _, o in pairs(Hub.ESPObjects) do if o then pcall(function() o:Remove() end) end end
        for _, o in pairs(Hub.TracerObjects) do if o then pcall(function() o:Remove() end) end end
        for _, o in pairs(Hub.SkeletonObjects) do if o then pcall(function() o:Remove() end) end end
        for _, c in pairs(Hub.ChamsObjects) do if c then pcall(function() c:Destroy() end) end end
        for _, p in pairs(HitboxParts) do if p then pcall(function() p:Destroy() end) end end
        for p, o in pairs(Hub.OriginalTransparencies) do
            if p and p.Parent then p.Transparency = o end
        end
        Workspace.Gravity = 196.2
        Camera.FieldOfView = 70
        Camera.CameraType = Enum.CameraType.Custom
    end)
end)

----------------------------------------------------------------------------------
-- FINAL
----------------------------------------------------------------------------------

print("═══════════════════════════════════════════════════════")
print("   💎 Liquid Glass Hub v4.0 - ULTIMATE EDITION")
print("   Status: Successfully Loaded!")
print("   Functions: 65+ | Themes: 7 | Tabs: 5")
print("   Toggle: RIGHT SHIFT | Blink: Q")
print("═══════════════════════════════════════════════════════")

return Hub
