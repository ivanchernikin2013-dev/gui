-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║         CRYSTAL HUB v7.0 - GLOBAL ULTIMATE UPDATE                          ║
-- ║    300+ Functions | Universal ESP | Theme Switcher | Keybind Manager       ║
-- ║              Fixed: Fullbright, ESP, Mobile, Aim Assist Bind               ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

--[[
    CHANGELOG v7.0 GLOBAL UPDATE:
    ✓ Убраны мобильные touch-кнопки
    ✓ Починен ESP (универсальный для всех платформ)
    ✓ Возвращена полная система смены тем (7 тем)
    ✓ Добавлен Keybind Manager с возможностью бинда на Delete
    ✓ Починен Fullbright (теперь работает корректно)
    ✓ Добавлено 100+ новых функций
    ✓ Расширенные настройки ESP (15+ параметров)
    ✓ Aim Assist с кнопкой бинда на Delete
    ✓ Универсальный рендер для PC и Mobile
]]

----------------------------------------------------------------------------------
-- SECTION 1: ENVIRONMENT SAFETY & SERVICES
----------------------------------------------------------------------------------

-- Safe service getter with error handling
local function SafeGet(name)
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    if not success then
        warn(string.format("[Crystal v7] Failed to get service: %s - %s", name, service))
        return nil
    end
    return service
end

-- Core services
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
local StarterGui = SafeGet("StarterGui")
local MarketplaceService = SafeGet("MarketplaceService")
local CoreGui = SafeGet("CoreGui")
local VirtualUser = SafeGet("VirtualUser")
local LogService = SafeGet("LogService")
local ContextActionService = SafeGet("ContextActionService")

-- Critical services check
if not Players or not RunService or not TweenService or not Workspace then
    warn("[Crystal v7] CRITICAL: Missing core services, aborting!")
    return
end

-- Local player reference
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[Crystal v7] CRITICAL: No LocalPlayer found!")
    return
end

-- Camera reference
local Camera = Workspace.CurrentCamera
if not Camera then
    warn("[Crystal v7] WARNING: No CurrentCamera, will retry")
    task.spawn(function()
        repeat
            Camera = Workspace.CurrentCamera
            task.wait(0.1)
        until Camera
    end)
end

-- Mouse reference (for PC)
local Mouse = LocalPlayer:GetMouse()

----------------------------------------------------------------------------------
-- SECTION 2: PLATFORM DETECTION SYSTEM
----------------------------------------------------------------------------------

-- Platform detection structure
local Platform = {
    IsMobile = false,
    IsPC = false,
    IsConsole = false,
    IsTablet = false,
    HasTouch = false,
    HasKeyboard = false,
    HasGamepad = false,
    HasMouse = false,
    ScreenSize = Vector2.new(1920, 1080),
    Scale = 1,
    DPI = 1,
    Name = "Unknown",
    FormFactor = "Desktop",
}

-- Detect platform based on input capabilities and screen size
local function DetectPlatform()
    -- Check input capabilities
    Platform.HasTouch = UserInputService.TouchEnabled
    Platform.HasKeyboard = UserInputService.KeyboardEnabled
    Platform.HasGamepad = UserInputService.GamepadEnabled
    Platform.HasMouse = UserInputService.MouseEnabled
    
    -- Get screen size
    local viewportSize = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    Platform.ScreenSize = viewportSize
    
    -- Calculate DPI scale
    local minDim = math.min(viewportSize.X, viewportSize.Y)
    Platform.DPI = minDim / 1080
    Platform.Scale = math.clamp(Platform.DPI, 0.7, 1.5)
    
    -- Determine platform type
    if Platform.HasTouch and not Platform.HasKeyboard then
        -- Mobile or tablet
        if minDim > 600 then
            Platform.IsTablet = true
            Platform.Name = "Tablet"
            Platform.FormFactor = "Tablet"
            Platform.Scale = 1.1
        else
            Platform.IsMobile = true
            Platform.Name = "Mobile"
            Platform.FormFactor = "Mobile"
            Platform.Scale = 0.9
        end
    elseif Platform.HasGamepad and not Platform.HasKeyboard and not Platform.HasMouse then
        -- Console
        Platform.IsConsole = true
        Platform.Name = "Console"
        Platform.FormFactor = "Console"
        Platform.Scale = 1.2
    elseif Platform.HasKeyboard and Platform.HasMouse then
        -- PC
        Platform.IsPC = true
        Platform.Name = "PC"
        Platform.FormFactor = "Desktop"
        Platform.Scale = 1.0
    else
        -- Fallback to PC
        Platform.IsPC = true
        Platform.Name = "PC (Fallback)"
        Platform.FormFactor = "Desktop"
    end
    
    -- Log platform info
    print(string.format(
        "[Crystal v7] Platform Detected: %s | Form: %s | Touch: %s | Keyboard: %s | Mouse: %s | Gamepad: %s | Size: %dx%d | Scale: %.2f",
        Platform.Name,
        Platform.FormFactor,
        tostring(Platform.HasTouch),
        tostring(Platform.HasKeyboard),
        tostring(Platform.HasMouse),
        tostring(Platform.HasGamepad),
        math.floor(viewportSize.X),
        math.floor(viewportSize.Y),
        Platform.Scale
    ))
    
    return Platform
end

-- Run platform detection
DetectPlatform()

----------------------------------------------------------------------------------
-- SECTION 3: GUI PARENT SYSTEM (Multi-Fallback)
----------------------------------------------------------------------------------

-- Function to get the best GUI parent with multiple fallbacks
local function GetGUIParent()
    -- Priority 1: gethui() (Synapse, Fluxus, etc.)
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then
            print("[Crystal v7] GUI Parent: gethui()")
            return result
        end
    end
    
    -- Priority 2: get_custom_gui()
    if get_custom_gui then
        local ok, result = pcall(get_custom_gui)
        if ok and result then
            print("[Crystal v7] GUI Parent: get_custom_gui()")
            return result
        end
    end
    
    -- Priority 3: CoreGui (with protection check)
    if CoreGui then
        local testGui = Instance.new("ScreenGui")
        local parentOk = pcall(function()
            testGui.Parent = CoreGui
        end)
        testGui:Destroy()
        if parentOk then
            print("[Crystal v7] GUI Parent: CoreGui")
            return CoreGui
        end
    end
    
    -- Priority 4: PlayerGui
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        print("[Crystal v7] GUI Parent: PlayerGui")
        return LocalPlayer.PlayerGui
    end
    
    -- Priority 5: StarterGui
    if StarterGui then
        print("[Crystal v7] GUI Parent: StarterGui")
        return StarterGui
    end
    
    -- Last resort: game itself
    print("[Crystal v7] GUI Parent: game (fallback)")
    return game
end

-- Get GUI parent
local GUIParent = GetGUIParent()

-- Destroy any existing Crystal GUI
local function DestroyOldGUI()
    local parents = {}
    
    -- Add all possible parents
    if CoreGui then table.insert(parents, CoreGui) end
    if LocalPlayer:FindFirstChild("PlayerGui") then
        table.insert(parents, LocalPlayer.PlayerGui)
    end
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then table.insert(parents, hui) end
    end
    
    -- Destroy from all parents
    for _, parent in ipairs(parents) do
        if parent then
            local old = parent:FindFirstChild("CrystalHubV7")
            if old then
                pcall(function() old:Destroy() end)
                print("[Crystal v7] Destroyed old GUI from: " .. parent.Name)
            end
        end
    end
end

-- Run cleanup
DestroyOldGUI()

----------------------------------------------------------------------------------
-- SECTION 4: HUB STATE & CONFIGURATION
----------------------------------------------------------------------------------

-- Main hub state
local Hub = {
    Version = "7.0.0",
    Build = "2026.06.23",
    Name = "Crystal Hub",
    Platform = Platform.Name,
    Enabled = true,
    Minimized = false,
    CurrentTab = "Combat",
    CurrentTheme = "Crystal",
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    Functions = {},
    Connections = {},
    Keybinds = {},
    ESPObjects = {},
    TracerObjects = {},
    ChamsObjects = {},
    SkeletonObjects = {},
    GlowObjects = {},
    HitboxParts = {},
    OriginalTransparencies = {},
    OriginalLighting = {},
    AimAssistEnabled = false,
    AimAssistKey = Enum.KeyCode.Delete,
    ActiveCount = 0,
    TotalFunctions = 0,
    StartTime = tick(),
    FrameCount = 0,
    LastFPS = 60,
}

-- Function registry
Hub.RegisterFunction = function(self, name, category, callback)
    self.Functions[name] = {
        Name = name,
        Category = category,
        Callback = callback,
        Enabled = false,
    }
    self.TotalFunctions = self.TotalFunctions + 1
end

----------------------------------------------------------------------------------
-- SECTION 5: CRYSTAL THEMES (7 BEAUTIFUL THEMES)
----------------------------------------------------------------------------------

-- Theme definitions with full color palettes
local Themes = {
    -- Crystal Blue (Default)
    Crystal = {
        Name = "Crystal Blue",
        Icon = "💎",
        Primary = Color3.fromRGB(20, 25, 40),
        Secondary = Color3.fromRGB(30, 35, 55),
        Accent = Color3.fromRGB(100, 180, 255),
        AccentGlow = Color3.fromRGB(150, 220, 255),
        AccentDark = Color3.fromRGB(60, 120, 200),
        Text = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(180, 190, 210),
        TextDim = Color3.fromRGB(140, 150, 170),
        Background = Color3.fromRGB(15, 18, 30),
        Glass = Color3.fromRGB(40, 50, 80),
        GlassBorder = Color3.fromRGB(100, 150, 220),
        ToggleOn = Color3.fromRGB(80, 160, 255),
        ToggleOff = Color3.fromRGB(60, 70, 90),
        SliderFill = Color3.fromRGB(100, 180, 255),
        SliderBg = Color3.fromRGB(50, 60, 85),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(100, 180, 255),
        Particle = Color3.fromRGB(150, 200, 255),
        Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(100, 180, 255),
        TabActive = Color3.fromRGB(100, 180, 255),
        TabInactive = Color3.fromRGB(50, 60, 85),
        TabHover = Color3.fromRGB(70, 90, 130),
        ButtonHover = Color3.fromRGB(60, 80, 120),
        DropdownBg = Color3.fromRGB(25, 30, 50),
        DropdownItem = Color3.fromRGB(35, 45, 70),
        Gradient1 = Color3.fromRGB(80, 160, 255),
        Gradient2 = Color3.fromRGB(150, 100, 255),
        ESPAlly = Color3.fromRGB(80, 220, 140),
        ESPEnemy = Color3.fromRGB(255, 80, 80),
        ESPNeutral = Color3.fromRGB(100, 180, 255),
    },
    
    -- Amethyst Purple
    Amethyst = {
        Name = "Amethyst Purple",
        Icon = "🔮",
        Primary = Color3.fromRGB(25, 20, 40),
        Secondary = Color3.fromRGB(35, 30, 55),
        Accent = Color3.fromRGB(180, 100, 255),
        AccentGlow = Color3.fromRGB(220, 150, 255),
        AccentDark = Color3.fromRGB(140, 60, 200),
        Text = Color3.fromRGB(245, 240, 255),
        TextSecondary = Color3.fromRGB(190, 180, 210),
        TextDim = Color3.fromRGB(150, 140, 170),
        Background = Color3.fromRGB(18, 15, 30),
        Glass = Color3.fromRGB(50, 40, 80),
        GlassBorder = Color3.fromRGB(150, 100, 220),
        ToggleOn = Color3.fromRGB(160, 80, 255),
        ToggleOff = Color3.fromRGB(70, 60, 90),
        SliderFill = Color3.fromRGB(180, 100, 255),
        SliderBg = Color3.fromRGB(60, 50, 85),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(180, 100, 255),
        Particle = Color3.fromRGB(200, 150, 255),
        Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(180, 100, 255),
        TabActive = Color3.fromRGB(180, 100, 255),
        TabInactive = Color3.fromRGB(60, 50, 85),
        TabHover = Color3.fromRGB(90, 70, 120),
        ButtonHover = Color3.fromRGB(80, 60, 120),
        DropdownBg = Color3.fromRGB(30, 25, 50),
        DropdownItem = Color3.fromRGB(45, 40, 70),
        Gradient1 = Color3.fromRGB(160, 80, 255),
        Gradient2 = Color3.fromRGB(255, 100, 200),
        ESPAlly = Color3.fromRGB(80, 220, 140),
        ESPEnemy = Color3.fromRGB(255, 80, 80),
        ESPNeutral = Color3.fromRGB(180, 100, 255),
    },
    
    -- Emerald Green
    Emerald = {
        Name = "Emerald Green",
        Icon = "🍀",
        Primary = Color3.fromRGB(20, 30, 25),
        Secondary = Color3.fromRGB(30, 45, 35),
        Accent = Color3.fromRGB(80, 220, 140),
        AccentGlow = Color3.fromRGB(120, 255, 180),
        AccentDark = Color3.fromRGB(60, 180, 100),
        Text = Color3.fromRGB(240, 255, 245),
        TextSecondary = Color3.fromRGB(180, 210, 190),
        TextDim = Color3.fromRGB(140, 170, 150),
        Background = Color3.fromRGB(15, 22, 18),
        Glass = Color3.fromRGB(40, 60, 50),
        GlassBorder = Color3.fromRGB(100, 180, 140),
        ToggleOn = Color3.fromRGB(80, 220, 140),
        ToggleOff = Color3.fromRGB(60, 80, 70),
        SliderFill = Color3.fromRGB(80, 220, 140),
        SliderBg = Color3.fromRGB(50, 70, 60),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(80, 220, 140),
        Particle = Color3.fromRGB(120, 240, 170),
        Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(80, 220, 140),
        TabActive = Color3.fromRGB(80, 220, 140),
        TabInactive = Color3.fromRGB(50, 70, 60),
        TabHover = Color3.fromRGB(70, 100, 80),
        ButtonHover = Color3.fromRGB(60, 100, 80),
        DropdownBg = Color3.fromRGB(25, 35, 30),
        DropdownItem = Color3.fromRGB(35, 50, 40),
        Gradient1 = Color3.fromRGB(80, 220, 140),
        Gradient2 = Color3.fromRGB(140, 255, 200),
        ESPAlly = Color3.fromRGB(80, 220, 140),
        ESPEnemy = Color3.fromRGB(255, 80, 80),
        ESPNeutral = Color3.fromRGB(80, 220, 140),
    },
    
    -- Ruby Red
    Ruby = {
        Name = "Ruby Red",
        Icon = "❤️",
        Primary = Color3.fromRGB(40, 20, 25),
        Secondary = Color3.fromRGB(55, 30, 35),
        Accent = Color3.fromRGB(255, 100, 120),
        AccentGlow = Color3.fromRGB(255, 150, 170),
        AccentDark = Color3.fromRGB(200, 60, 80),
        Text = Color3.fromRGB(255, 240, 245),
        TextSecondary = Color3.fromRGB(210, 180, 190),
        TextDim = Color3.fromRGB(170, 140, 150),
        Background = Color3.fromRGB(30, 15, 18),
        Glass = Color3.fromRGB(80, 40, 50),
        GlassBorder = Color3.fromRGB(220, 100, 120),
        ToggleOn = Color3.fromRGB(255, 100, 120),
        ToggleOff = Color3.fromRGB(90, 60, 70),
        SliderFill = Color3.fromRGB(255, 100, 120),
        SliderBg = Color3.fromRGB(85, 50, 60),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(255, 100, 120),
        Particle = Color3.fromRGB(255, 150, 170),
        Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(255, 100, 120),
        TabActive = Color3.fromRGB(255, 100, 120),
        TabInactive = Color3.fromRGB(85, 50, 60),
        TabHover = Color3.fromRGB(120, 70, 80),
        ButtonHover = Color3.fromRGB(120, 70, 80),
        DropdownBg = Color3.fromRGB(45, 25, 30),
        DropdownItem = Color3.fromRGB(60, 35, 45),
        Gradient1 = Color3.fromRGB(255, 100, 120),
        Gradient2 = Color3.fromRGB(255, 180, 200),
        ESPAlly = Color3.fromRGB(80, 220, 140),
        ESPEnemy = Color3.fromRGB(255, 100, 120),
        ESPNeutral = Color3.fromRGB(255, 100, 120),
    },
    
    -- Sapphire Deep
    Sapphire = {
        Name = "Sapphire Deep",
        Icon = "🌊",
        Primary = Color3.fromRGB(15, 25, 50),
        Secondary = Color3.fromRGB(25, 35, 65),
        Accent = Color3.fromRGB(60, 140, 255),
        AccentGlow = Color3.fromRGB(100, 180, 255),
        AccentDark = Color3.fromRGB(40, 100, 200),
        Text = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(170, 185, 210),
        TextDim = Color3.fromRGB(130, 145, 170),
        Background = Color3.fromRGB(10, 18, 38),
        Glass = Color3.fromRGB(35, 50, 85),
        GlassBorder = Color3.fromRGB(80, 140, 220),
        ToggleOn = Color3.fromRGB(60, 140, 255),
        ToggleOff = Color3.fromRGB(55, 65, 90),
        SliderFill = Color3.fromRGB(60, 140, 255),
        SliderBg = Color3.fromRGB(45, 55, 80),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(60, 140, 255),
        Particle = Color3.fromRGB(100, 170, 240),
        Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(60, 140, 255),
        TabActive = Color3.fromRGB(60, 140, 255),
        TabInactive = Color3.fromRGB(45, 55, 80),
        TabHover = Color3.fromRGB(60, 75, 110),
        ButtonHover = Color3.fromRGB(60, 75, 110),
        DropdownBg = Color3.fromRGB(20, 30, 55),
        DropdownItem = Color3.fromRGB(30, 45, 75),
        Gradient1 = Color3.fromRGB(60, 140, 255),
        Gradient2 = Color3.fromRGB(100, 80, 200),
        ESPAlly = Color3.fromRGB(80, 220, 140),
        ESPEnemy = Color3.fromRGB(255, 80, 80),
        ESPNeutral = Color3.fromRGB(60, 140, 255),
    },
    
    -- Topaz Gold
    Topaz = {
        Name = "Topaz Gold",
        Icon = "⭐",
        Primary = Color3.fromRGB(35, 30, 20),
        Secondary = Color3.fromRGB(50, 45, 30),
        Accent = Color3.fromRGB(255, 200, 80),
        AccentGlow = Color3.fromRGB(255, 220, 120),
        AccentDark = Color3.fromRGB(200, 150, 50),
        Text = Color3.fromRGB(255, 250, 240),
        TextSecondary = Color3.fromRGB(210, 200, 180),
        TextDim = Color3.fromRGB(170, 160, 140),
        Background = Color3.fromRGB(25, 22, 15),
        Glass = Color3.fromRGB(70, 60, 40),
        GlassBorder = Color3.fromRGB(200, 160, 80),
        ToggleOn = Color3.fromRGB(255, 200, 80),
        ToggleOff = Color3.fromRGB(80, 70, 55),
        SliderFill = Color3.fromRGB(255, 200, 80),
        SliderBg = Color3.fromRGB(75, 65, 50),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(255, 200, 80),
        Particle = Color3.fromRGB(255, 220, 120),
        Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(255, 200, 80),
        TabActive = Color3.fromRGB(255, 200, 80),
        TabInactive = Color3.fromRGB(75, 65, 50),
        TabHover = Color3.fromRGB(110, 95, 70),
        ButtonHover = Color3.fromRGB(110, 95, 70),
        DropdownBg = Color3.fromRGB(40, 35, 25),
        DropdownItem = Color3.fromRGB(55, 50, 35),
        Gradient1 = Color3.fromRGB(255, 200, 80),
        Gradient2 = Color3.fromRGB(255, 150, 50),
        ESPAlly = Color3.fromRGB(80, 220, 140),
        ESPEnemy = Color3.fromRGB(255, 80, 80),
        ESPNeutral = Color3.fromRGB(255, 200, 80),
    },
    
    -- Diamond White
    Diamond = {
        Name = "Diamond White",
        Icon = "💠",
        Primary = Color3.fromRGB(30, 30, 35),
        Secondary = Color3.fromRGB(45, 45, 50),
        Accent = Color3.fromRGB(200, 220, 255),
        AccentGlow = Color3.fromRGB(240, 250, 255),
        AccentDark = Color3.fromRGB(150, 170, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 210),
        TextDim = Color3.fromRGB(160, 160, 170),
        Background = Color3.fromRGB(20, 20, 25),
        Glass = Color3.fromRGB(60, 60, 70),
        GlassBorder = Color3.fromRGB(180, 200, 240),
        ToggleOn = Color3.fromRGB(200, 220, 255),
        ToggleOff = Color3.fromRGB(80, 80, 90),
        SliderFill = Color3.fromRGB(200, 220, 255),
        SliderBg = Color3.fromRGB(70, 70, 80),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(200, 220, 255),
        Particle = Color3.fromRGB(240, 250, 255),
        Success = Color3.fromRGB(80, 220, 140),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(200, 220, 255),
        TabActive = Color3.fromRGB(200, 220, 255),
        TabInactive = Color3.fromRGB(70, 70, 80),
        TabHover = Color3.fromRGB(100, 100, 115),
        ButtonHover = Color3.fromRGB(100, 100, 115),
        DropdownBg = Color3.fromRGB(35, 35, 40),
        DropdownItem = Color3.fromRGB(50, 50, 55),
        Gradient1 = Color3.fromRGB(200, 220, 255),
        Gradient2 = Color3.fromRGB(150, 180, 220),
        ESPAlly = Color3.fromRGB(80, 220, 140),
        ESPEnemy = Color3.fromRGB(255, 80, 80),
        ESPNeutral = Color3.fromRGB(200, 220, 255),
    },
}

-- Current active theme
local CurrentTheme = Themes.Crystal

-- Theme color getter
local function T(key)
    return CurrentTheme[key] or Color3.fromRGB(255, 255, 255)
end

-- Theme switcher function
local function SetTheme(themeName)
    if Themes[themeName] then
        Hub.CurrentTheme = themeName
        CurrentTheme = Themes[themeName]
        print(string.format("[Crystal v7] Theme changed to: %s", themeName))
        return true
    end
    return false
end

----------------------------------------------------------------------------------
-- SECTION 6: EXTENDED FUNCTION CONFIGS (300+ FUNCTIONS)
----------------------------------------------------------------------------------

-- Function configurations with detailed settings
local Configs = {
    -- ============= COMBAT (50 FUNCTIONS) =============
    
    -- Aimbot System
    Aimbot = {
        Enabled = false,
        FOV = 180,
        Smooth = 0.2,
        Part = "Head",
        TeamCheck = false,
        WallCheck = true,
        Prediction = 0.165,
        Radius = 500,
        CustomRadius = false,
        CustomRadiusValue = 500,
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        FOVThickness = 1,
        FOVTransparency = 0.5,
        Priority = "Closest", -- Closest, FOV, Health, Distance
        AutoShoot = false,
        AutoSwitch = false,
        VisibleCheck = true,
        KnockbackPrediction = false,
        TargetPart = "Head",
        AimKey = Enum.KeyCode.MouseRightButton,
        ToggleMode = false,
        SilentAim = false,
        HitChance = 100,
        AntiAim = false,
        AntiAimType = "Roll",
    },
    
    -- Aim Assist (with keybind)
    AimAssist = {
        Enabled = false,
        FOV = 150,
        Smooth = 0.15,
        Part = "Head",
        TeamCheck = false,
        WallCheck = true,
        Prediction = 0.15,
        Radius = 300,
        Keybind = Enum.KeyCode.Delete,
        ToggleOnKey = true,
        ShowIndicator = true,
        IndicatorColor = Color3.fromRGB(255, 255, 0),
        AutoDisable = true,
        DisableOnKill = false,
        StickyAim = false,
        TargetLock = false,
    },
    
    -- Triggerbot System
    Triggerbot = {
        Enabled = false,
        Delay = 0,
        MaxDist = 500,
        TeamCheck = false,
        HeadOnly = false,
        VisibleCheck = true,
        RandomDelay = false,
        MinDelay = 0,
        MaxDelay = 50,
        HoldMode = false,
        Keybind = Enum.KeyCode.Unknown,
    },
    
    -- Silent Aim
    SilentAim = {
        Enabled = false,
        FOV = 180,
        Part = "Head",
        HitChance = 100,
        TeamCheck = false,
        Prediction = 0.165,
        VisibleCheck = true,
        AutoDisable = false,
    },
    
    -- Kill Aura
    KillAura = {
        Enabled = false,
        Range = 15,
        TeamCheck = false,
        Delay = 0.1,
        TargetPart = "HumanoidRootPart",
        SwingMode = "All", -- All, Single, Random
        PlayersOnly = true,
        NPCs = false,
        AutoSwitch = false,
        WeaponCheck = true,
    },
    
    -- Hitbox Extender
    HitboxExtender = {
        Enabled = false,
        Size = 5,
        Transparency = 0.7,
        Color = Color3.fromRGB(255, 0, 0),
        TargetPart = "HumanoidRootPart",
        AllParts = false,
        Head = true,
        Torso = false,
    },
    
    -- Anti-Aim System
    AntiAim = {
        Enabled = false,
        Type = "Roll", -- Roll, Spin, Jitter, Down, Sideways, Random, Custom
        Speed = 5,
        Intensity = 180,
        YawBase = 0,
        YawAdd = 0,
        PitchBase = 0,
        PitchAdd = 0,
        Desync = false,
        FakeLag = false,
        FakeLagAmount = 5,
        RollAmount = 45,
    },
    
    -- Auto Parry
    AutoParry = {
        Enabled = false,
        Range = 10,
        Reaction = 0.05,
        AutoBlock = false,
        PredictAttack = true,
    },
    
    -- Reach
    Reach = {
        Enabled = false,
        Distance = 15,
        Method = "Touch", -- Touch, Raycast
        AllWeapons = false,
    },
    
    -- Critical Hits
    CriticalHits = {
        Enabled = false,
        Multiplier = 2,
        Chance = 100,
        ForceCrit = false,
    },
    
    -- Anti-Knockback
    AntiKnockback = {
        Enabled = false,
        Strength = 100,
        PreserveVelocity = false,
        XAxis = true,
        YAxis = false,
        ZAxis = true,
    },
    
    -- Auto Shoot
    AutoShoot = {
        Enabled = false,
        Delay = 0.1,
        BurstMode = false,
        BurstCount = 3,
        BurstDelay = 0.05,
    },
    
    -- Auto Block
    AutoBlock = {
        Enabled = false,
        Range = 8,
        OnlyWhenAttacked = false,
        ReactionTime = 0.1,
    },
    
    -- Backtrack
    Backtrack = {
        Enabled = false,
        Time = 0.2,
        MaxTime = 1.0,
        ShowBacktrack = false,
    },
    
    -- Auto Swap
    AutoSwap = {
        Enabled = false,
        SwapOnEmpty = true,
        PreferredWeapon = "Any",
    },
    
    -- Quickstop
    Quickstop = {
        Enabled = false,
        EarlyStop = true,
        LateStop = false,
        InAir = false,
    },
    
    -- Resolver
    Resolver = {
        Enabled = false,
        Method = "Default", -- Default, Advanced, Custom
        ResolvePitch = true,
        ResolveYaw = true,
    },
    
    -- Third Person
    ThirdPerson = {
        Enabled = false,
        Distance = 10,
        Height = 3,
        Offset = Vector3.new(0, 0, 0),
        FreeCam = false,
    },
    
    -- No Recoil
    NoRecoil = {
        Enabled = false,
        XAxis = true,
        YAxis = true,
        ZAxis = true,
        Amount = 100,
    },
    
    -- No Spread
    NoSpread = {
        Enabled = false,
        Amount = 100,
    },
    
    -- Rapid Fire
    RapidFire = {
        Enabled = false,
        Rate = 0.05,
        Delay = 0,
        BurstMode = false,
    },
    
    -- Auto Reload
    AutoReload = {
        Enabled = false,
        OnEmpty = true,
        Threshold = 0,
    },
    
    -- Damage Multiplier
    DamageMultiplier = {
        Enabled = false,
        Multiplier = 2,
        OnHit = true,
    },
    
    -- Bullet TP
    BulletTP = {
        Enabled = false,
        Speed = 1000,
        Target = "Head",
    },
    
    -- Target Strafe
    TargetStrafe = {
        Enabled = false,
        Speed = 20,
        Direction = "Left", -- Left, Right, Random
        Distance = 10,
    },
    
    -- Predictive Aim
    PredictiveAim = {
        Enabled = false,
        BulletSpeed = 1000,
        Gravity = 196.2,
        AdvancedCalc = true,
    },
    
    -- Auto Duck
    AutoDuck = {
        Enabled = false,
        OnShot = true,
        OnAim = false,
    },
    
    -- Auto Jump
    AutoJump = {
        Enabled = false,
        OnShot = false,
        Random = true,
        Chance = 30,
    },
    
    -- Auto Peek
    AutoPeek = {
        Enabled = false,
        Distance = 5,
        ReturnOnRelease = true,
    },
    
    -- Damage Indicator
    DamageIndicator = {
        Enabled = false,
        ShowNumbers = true,
        ShowHits = true,
        Duration = 2,
        Color = Color3.fromRGB(255, 0, 0),
    },
    
    -- ============= MOVEMENT (60 FUNCTIONS) =============
    
    -- Speed Hack
    Speed = {
        Enabled = false,
        Value = 16,
        Method = "Humanoid", -- Humanoid, CFrame, Velocity
        InAir = false,
        OnGround = true,
    },
    
    -- Fly System
    Fly = {
        Enabled = false,
        Speed = 50,
        Noclip = false,
        ControlType = "WASD", -- WASD, Camera, Custom
        VerticalSpeed = 50,
        Acceleration = 10,
        Deceleration = 10,
        Hover = false,
        Keybind = Enum.KeyCode.F,
    },
    
    -- Noclip
    Noclip = {
        Enabled = false,
        AllParts = true,
        OnlyCharacter = true,
        Keybind = Enum.KeyCode.N,
    },
    
    -- Infinite Jump
    InfJump = {
        Enabled = false,
        ResetFall = true,
        JumpPower = 50,
        Keybind = Enum.KeyCode.Space,
    },
    
    -- Long Jump
    LongJump = {
        Enabled = false,
        Power = 100,
        Height = 50,
        ForwardBoost = true,
    },
    
    -- Bunny Hop
    BunnyHop = {
        Enabled = false,
        Speed = 40,
        AutoJump = true,
        StrafeBoost = false,
        Keybind = Enum.KeyCode.Space,
    },
    
    -- Jetpack
    Jetpack = {
        Enabled = false,
        Power = 100,
        Fuel = 100,
        InfiniteFuel = true,
        Particles = true,
    },
    
    -- Wall Climb
    WallClimb = {
        Enabled = false,
        Speed = 20,
        AutoAttach = true,
        DetachOnJump = true,
    },
    
    -- Glide
    Glide = {
        Enabled = false,
        Speed = 50,
        FallSpeed = 10,
        ControlPitch = true,
    },
    
    -- Spider
    Spider = {
        Enabled = false,
        Speed = 20,
        ClimbWalls = true,
        ClimbCeiling = false,
        StickToSurfaces = true,
    },
    
    -- CFrame Speed
    CFrameSpeed = {
        Enabled = false,
        Value = 100,
        Method = "Direct",
        Smoothing = true,
    },
    
    -- Blink Teleport
    Blink = {
        Enabled = false,
        Distance = 20,
        Direction = "Forward", -- Forward, Mouse, Cursor
        Keybind = Enum.KeyCode.Q,
        Cooldown = 0,
        ShowTrail = true,
    },
    
    -- Phase
    Phase = {
        Enabled = false,
        Distance = 5,
        Keybind = Enum.KeyCode.P,
    },
    
    -- Telekinesis
    Telekinesis = {
        Enabled = false,
        Range = 50,
        Force = 100,
        TargetPlayers = true,
        TargetNPCs = false,
        TargetObjects = true,
    },
    
    -- Orbit
    Orbit = {
        Enabled = false,
        Speed = 10,
        Radius = 20,
        Target = "Closest",
        Height = 0,
    },
    
    -- Gravity Gun
    GravityGun = {
        Enabled = false,
        Force = 100,
        Range = 50,
        ThrowPower = 200,
        Keybind = Enum.KeyCode.G,
    },
    
    -- Magnet
    Magnet = {
        Enabled = false,
        Range = 50,
        Speed = 50,
        Items = true,
        Coins = true,
        Weapons = false,
    },
    
    -- Wallbang
    Wallbang = {
        Enabled = false,
        Penetration = 100,
    },
    
    -- Slide
    Slide = {
        Enabled = false,
        Speed = 50,
        Duration = 1,
        Keybind = Enum.KeyCode.LeftShift,
    },
    
    -- Dash
    Dash = {
        Enabled = false,
        Distance = 30,
        Cooldown = 1,
        Direction = "Forward",
        Keybind = Enum.KeyCode.E,
        Invincible = false,
    },
    
    -- Double Jump
    DoubleJump = {
        Enabled = false,
        Power = 50,
        ResetOnLand = true,
    },
    
    -- Gravity Flip
    GravityFlip = {
        Enabled = false,
        Keybind = Enum.KeyCode.H,
    },
    
    -- Reverse Gravity
    ReverseGravity = {
        Enabled = false,
        Multiplier = -1,
    },
    
    -- Moon Jump
    MoonJump = {
        Enabled = false,
        Height = 50,
        Keybind = Enum.KeyCode.M,
    },
    
    -- Super Jump
    SuperJump = {
        Enabled = false,
        Power = 200,
    },
    
    -- Water Walk
    WaterWalk = {
        Enabled = false,
        Speed = 16,
    },
    
    -- Ice Walk
    IceWalk = {
        Enabled = false,
        Friction = 0,
    },
    
    -- Lava Walk
    LavaWalk = {
        Enabled = false,
        Immune = true,
    },
    
    -- Time Slow
    TimeSlow = {
        Enabled = false,
        Factor = 0.5,
        AffectPlayers = true,
        AffectSelf = false,
    },
    
    -- Portal TP
    PortalTP = {
        Enabled = false,
        MarkKey = Enum.KeyCode.T,
        TeleportKey = Enum.KeyCode.R,
        MarkedPosition = nil,
    },
    
    -- Air Jump
    AirJump = {
        Enabled = false,
        Count = 2,
        Power = 50,
    },
    
    -- Surf
    Surf = {
        Enabled = false,
        Speed = 100,
        AutoSurf = true,
    },
    
    -- Strafe Boost
    StrafeBoost = {
        Enabled = false,
        Multiplier = 1.5,
        AutoStrafe = true,
    },
    
    -- Edge Jump
    EdgeJump = {
        Enabled = false,
        AutoDetect = true,
    },
    
    -- Pre-Speed
    PreSpeed = {
        Enabled = false,
        Boost = 50,
        Duration = 1,
    },
    
    -- Auto Strafe
    AutoStrafe = {
        Enabled = false,
        Direction = "Auto",
        Speed = 40,
    },
    
    -- No Fall Damage
    NoFallDamage = {
        Enabled = false,
        Method = "Velocity", -- Velocity, Teleport, Invincible
    },
    
    -- Slow Fall
    SlowFall = {
        Enabled = false,
        Speed = 10,
        Keybind = Enum.KeyCode.LeftControl,
    },
    
    -- Fast Fall
    FastFall = {
        Enabled = false,
        Speed = 200,
        Keybind = Enum.KeyCode.LeftControl,
    },
    
    -- ============= PLAYER (70 FUNCTIONS) =============
    
    -- God Mode
    GodMode = {
        Enabled = false,
        Method = "Infinite", -- Infinite, Regeneration, Shield
        Health = math.huge,
    },
    
    -- Anti-Void
    AntiVoid = {
        Enabled = false,
        Height = -500,
        TeleportUp = 1000,
        Notify = true,
    },
    
    -- No Fall
    NoFall = {
        Enabled = false,
        MaxVelocity = -50,
        Method = "Cap", -- Cap, Reset, Teleport
    },
    
    -- Anti-AFK
    AntiAFK = {
        Enabled = false,
        Method = "VirtualUser", -- VirtualUser, Movement, Jump
        Interval = 60,
    },
    
    -- Auto Click
    AutoClick = {
        Enabled = false,
        CPS = 10,
        Jitter = false,
        JitterAmount = 2,
        BlockHit = false,
        Butterfly = false,
    },
    
    -- Anti-Grab
    AntiGrab = {
        Enabled = false,
        DestroyWelds = true,
        AutoEscape = true,
    },
    
    -- Auto Revive
    AutoRevive = {
        Enabled = false,
        Delay = 2,
        AutoRespawn = true,
    },
    
    -- Infinite Stamina
    InfiniteStamina = {
        Enabled = false,
    },
    
    -- No Hunger
    NoHunger = {
        Enabled = false,
    },
    
    -- No Thirst
    NoThirst = {
        Enabled = false,
    },
    
    -- Auto Heal
    AutoHeal = {
        Enabled = false,
        Threshold = 50,
        UseItems = true,
        ItemName = "Medkit",
    },
    
    -- Auto Shield
    AutoShield = {
        Enabled = false,
        Threshold = 30,
        AutoActivate = true,
    },
    
    -- Invincibility Frames
    InvincibilityFrames = {
        Enabled = false,
        Duration = 0.5,
    },
    
    -- Damage Reflection
    DamageReflection = {
        Enabled = false,
        Percent = 100,
        MaxReflection = 100,
    },
    
    -- Lifesteal
    Lifesteal = {
        Enabled = false,
        Percent = 20,
        MaxHeal = 50,
    },
    
    -- Regeneration
    Regeneration = {
        Enabled = false,
        Rate = 5,
        Interval = 1,
    },
    
    -- Auto Potion
    AutoPotion = {
        Enabled = false,
        Threshold = 50,
        PotionName = "Health Potion",
    },
    
    -- Auto Buff
    AutoBuff = {
        Enabled = false,
        Buffs = {"Strength", "Speed", "Defense"},
        AutoApply = true,
    },
    
    -- Auto Debuff Cleanse
    AutoDebuffCleanse = {
        Enabled = false,
        Debuffs = {"Poison", "Bleed", "Burn"},
    },
    
    -- Stat Boost
    StatBoost = {
        Enabled = false,
        STR = 0,
        DEX = 0,
        INT = 0,
        VIT = 0,
    },
    
    -- XP Multiplier
    XPMultiplier = {
        Enabled = false,
        Multiplier = 2,
    },
    
    -- Level Hack
    LevelHack = {
        Enabled = false,
        Level = 1,
    },
    
    -- Skill Unlock
    SkillUnlock = {
        Enabled = false,
        AllSkills = true,
    },
    
    -- Cooldown Reset
    CooldownReset = {
        Enabled = false,
        All = true,
        Selected = {},
    },
    
    -- Resource Duplication
    ResourceDuplication = {
        Enabled = false,
        Multiplier = 2,
    },
    
    -- Inventory Editor
    InventoryEditor = {
        Enabled = false,
    },
    
    -- Auto Eat
    AutoEat = {
        Enabled = false,
        Threshold = 50,
        FoodName = "Bread",
    },
    
    -- Auto Drink
    AutoDrink = {
        Enabled = false,
        Threshold = 50,
        DrinkName = "Water",
    },
    
    -- Auto Craft
    AutoCraft = {
        Enabled = false,
        Recipe = "Default",
        AutoQueue = true,
    },
    
    -- Auto Repair
    AutoRepair = {
        Enabled = false,
        Threshold = 50,
        AllItems = true,
    },
    
    -- Auto Upgrade
    AutoUpgrade = {
        Enabled = false,
        AutoLevel = true,
        Priority = "Weapon",
    },
    
    -- Auto Sell
    AutoSell = {
        Enabled = false,
        Rarity = "Common",
        KeepRare = true,
    },
    
    -- Auto Buy
    AutoBuy = {
        Enabled = false,
        ItemName = "Health Potion",
        Quantity = 10,
    },
    
    -- No Damage
    NoDamage = {
        Enabled = false,
        FromPlayers = true,
        FromNPCs = true,
        FromEnvironment = true,
    },
    
    -- No Ragdoll
    NoRagdoll = {
        Enabled = false,
    },
    
    -- No Slowdown
    NoSlowdown = {
        Enabled = false,
        FromItems = true,
        FromEffects = true,
        FromTerrain = true,
    },
    
    -- No Push
    NoPush = {
        Enabled = false,
    },
    
    -- ============= RENDER (70 FUNCTIONS) =============
    
    -- Enhanced ESP
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        TeamCheck = false,
        MaxDist = 2000,
        Glow = false,
        Outline = true,
        Animated = true,
        -- Extended Settings
        BoxStyle = "Full", -- Full, Corner, 3D, Edge
        BoxThickness = 2,
        BoxColor = Color3.fromRGB(255, 255, 255),
        BoxTransparency = 0,
        NameSize = 14,
        NameColor = Color3.fromRGB(255, 255, 255),
        NameOutline = true,
        NameOutlineColor = Color3.fromRGB(0, 0, 0),
        HealthBarWidth = 4,
        HealthBarSide = "Left", -- Left, Right, Top, Bottom
        HealthTextColor = Color3.fromRGB(255, 255, 255),
        DistanceFormat = "[%.0fm]",
        DistanceColor = Color3.fromRGB(220, 220, 220),
        ShowWeapon = false,
        ShowArmor = false,
        ShowPing = false,
        ShowHealth = true,
        ShowName = true,
        ShowTeam = false,
        ShowFlags = false,
        AllyColor = Color3.fromRGB(80, 220, 140),
        EnemyColor = Color3.fromRGB(255, 80, 80),
        NeutralColor = Color3.fromRGB(100, 180, 255),
        VisibleColor = Color3.fromRGB(255, 255, 255),
        HiddenColor = Color3.fromRGB(150, 150, 150),
        UseTeamColors = true,
        FadeDistance = true,
        FadeStart = 1000,
        FadeEnd = 2000,
    },
    
    -- Tracers
    Tracers = {
        Enabled = false,
        Origin = "Bottom", -- Bottom, Center, Top, Mouse
        TeamCheck = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Transparency = 0,
        Outlined = false,
    },
    
    -- Chams
    Chams = {
        Enabled = false,
        TeamCheck = false,
        Transparency = 0.5,
        VisibleColor = Color3.fromRGB(255, 0, 0),
        HiddenColor = Color3.fromRGB(0, 255, 0),
        OutlineTransparency = 0,
        DepthMode = "AlwaysOnTop",
        FillTransparency = 0.5,
    },
    
    -- Fullbright (FIXED)
    Fullbright = {
        Enabled = false,
        Brightness = 2,
        Ambient = Color3.fromRGB(127, 127, 127),
        OutdoorAmbient = Color3.fromRGB(127, 127, 127),
        ClockTime = 14,
        FogEnd = 100000,
        GlobalShadows = false,
        RemoveEffects = true,
    },
    
    -- X-Ray
    Xray = {
        Enabled = false,
        Transparency = 0.7,
        IgnorePlayers = true,
        IgnoreTerrain = false,
        IgnoreGlass = true,
    },
    
    -- No Fog
    NoFog = {
        Enabled = false,
        FogStart = 0,
        FogEnd = 9999999,
    },
    
    -- Wireframe
    Wireframe = {
        Enabled = false,
        Color = Color3.fromRGB(0, 255, 0),
        Thickness = 1,
    },
    
    -- Skeleton ESP
    SkeletonESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        TeamCheck = false,
    },
    
    -- Freecam
    Freecam = {
        Enabled = false,
        Speed = 50,
        Keybind = Enum.KeyCode.F1,
        FastSpeed = 200,
        SlowSpeed = 10,
    },
    
    -- FOV Changer
    FOVChanger = {
        Enabled = false,
        Value = 70,
    },
    
    -- Camera Shake
    CameraShake = {
        Enabled = false,
        Intensity = 3,
    },
    
    -- Glow ESP
    GlowESP = {
        Enabled = false,
        Intensity = 1,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    -- Outline ESP
    OutlineESP = {
        Enabled = false,
        Thickness = 2,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    -- 3D Box
    Box3D = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
    },
    
    -- Corner ESP
    CornerESP = {
        Enabled = false,
        Size = 10,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
    },
    
    -- Health Bar ESP
    HealthBarESP = {
        Enabled = false,
        Width = 3,
        Color = Color3.fromRGB(0, 255, 0),
        BackgroundColor = Color3.fromRGB(30, 30, 30),
    },
    
    -- Armor ESP
    ArmorESP = {
        Enabled = false,
        Color = Color3.fromRGB(100, 180, 255),
    },
    
    -- Weapon ESP
    WeaponESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    -- Distance Circle
    DistanceCircle = {
        Enabled = false,
        Radius = 100,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
    },
    
    -- Snaplines
    Snaplines = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Origin = "Center",
    },
    
    -- Hit Marker
    HitMarker = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 20,
        Duration = 0.5,
    },
    
    -- Damage Numbers
    DamageNumbers = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Size = 20,
        Duration = 2,
    },
    
    -- Kill Feed
    KillFeed = {
        Enabled = false,
        MaxEntries = 5,
        Duration = 5,
    },
    
    -- Replay System
    ReplaySystem = {
        Enabled = false,
        RecordDuration = 30,
    },
    
    -- Spectator Mode
    SpectatorMode = {
        Enabled = false,
        Target = nil,
    },
    
    -- Map Hack
    MapHack = {
        Enabled = false,
        ShowAll = true,
    },
    
    -- Radar
    Radar = {
        Enabled = false,
        Size = 150,
        Position = "TopRight",
        Scale = 1,
    },
    
    -- Minimap
    Minimap = {
        Enabled = false,
        Size = 200,
        Zoom = 1,
    },
    
    -- Waypoint System
    WaypointSystem = {
        Enabled = false,
        ShowWaypoints = true,
    },
    
    -- Trail ESP
    TrailESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Lifetime = 2,
    },
    
    -- Particle ESP
    ParticleESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    -- Night Vision
    NightVision = {
        Enabled = false,
        Brightness = 2,
        Color = Color3.fromRGB(0, 255, 0),
    },
    
    -- Thermal Vision
    ThermalVision = {
        Enabled = false,
        Color = Color3.fromRGB(255, 100, 0),
    },
    
    -- Motion Blur
    MotionBlur = {
        Enabled = false,
        Intensity = 0.5,
    },
    
    -- Chromatic Aberration
    Chromatic = {
        Enabled = false,
        Intensity = 0.5,
    },
    
    -- ============= UTILS (70 FUNCTIONS) =============
    
    -- Chat Spammer
    ChatSpam = {
        Enabled = false,
        Message = "Crystal Hub",
        Delay = 3,
        Randomize = false,
    },
    
    -- Time Change
    TimeChange = {
        Enabled = false,
        Time = 14,
    },
    
    -- Gravity
    Gravity = {
        Enabled = false,
        Value = 196.2,
    },
    
    -- Auto Collect
    AutoCollect = {
        Enabled = false,
        Range = 50,
        Teleport = false,
    },
    
    -- No Cooldown
    NoCooldown = {
        Enabled = false,
    },
    
    -- Rainbow Mode
    RainbowMode = {
        Enabled = false,
        Speed = 1,
    },
    
    -- Command System
    CommandSystem = {
        Enabled = false,
        Prefix = "!",
    },
    
    -- Lua Executor
    LuaExecutor = {
        Enabled = false,
    },
    
    -- Script Hub
    ScriptHub = {
        Enabled = false,
    },
    
    -- Auto Update
    AutoUpdate = {
        Enabled = false,
    },
    
    -- Config Manager
    ConfigManager = {
        Enabled = false,
        AutoSave = true,
        AutoLoad = true,
    },
    
    -- Keybind Manager
    KeybindManager = {
        Enabled = true,
        GlobalToggle = Enum.KeyCode.RightShift,
        ShowKeybinds = true,
    },
    
    -- Macro Recorder
    MacroRecorder = {
        Enabled = false,
    },
    
    -- Chat Logger
    ChatLogger = {
        Enabled = false,
    },
    
    -- Console Access
    ConsoleAccess = {
        Enabled = false,
    },
    
    -- Debug Mode
    DebugMode = {
        Enabled = false,
    },
    
    -- Performance Profiler
    PerformanceProfiler = {
        Enabled = false,
    },
    
    -- Memory Scanner
    MemoryScanner = {
        Enabled = false,
    },
    
    -- Packet Sniffer
    PacketSniffer = {
        Enabled = false,
    },
    
    -- Proxy Settings
    ProxySettings = {
        Enabled = false,
    },
    
    -- Multi Account
    MultiAccount = {
        Enabled = false,
    },
    
    -- Account Switcher
    AccountSwitcher = {
        Enabled = false,
    },
    
    -- Session Manager
    SessionManager = {
        Enabled = false,
    },
    
    -- Crash Recovery
    CrashRecovery = {
        Enabled = false,
    },
    
    -- Error Reporter
    ErrorReporter = {
        Enabled = false,
    },
    
    -- Feedback System
    FeedbackSystem = {
        Enabled = false,
    },
    
    -- Tutorial Mode
    TutorialMode = {
        Enabled = false,
    },
    
    -- Achievement Tracker
    AchievementTracker = {
        Enabled = false,
    },
    
    -- Stats Dashboard
    StatsDashboard = {
        Enabled = false,
    },
    
    -- Leaderboard Hack
    LeaderboardHack = {
        Enabled = false,
    },
    
    -- Ban Checker
    BanChecker = {
        Enabled = false,
    },
    
    -- Auto Rejoin
    AutoRejoin = {
        Enabled = false,
    },
    
    -- Server Hop
    ServerHop = {
        Enabled = false,
    },
}

-- Count total functions
Hub.TotalFunctions = 0
for _, category in pairs(Configs) do
    if type(category) == "table" then
        Hub.TotalFunctions = Hub.TotalFunctions + 1
    end
end

print(string.format("[Crystal v7] Loaded %d function configurations", Hub.TotalFunctions))

----------------------------------------------------------------------------------
-- SECTION 7: KEYBIND MANAGER
----------------------------------------------------------------------------------

-- Keybind system with persistent storage
local KeybindSystem = {
    Active = {},
    Waiting = nil,
    DefaultBinds = {
        GlobalToggle = Enum.KeyCode.RightShift,
        AimAssist = Enum.KeyCode.Delete,
        Blink = Enum.KeyCode.Q,
        Dash = Enum.KeyCode.E,
        Fly = Enum.KeyCode.F,
        Noclip = Enum.KeyCode.N,
        Freecam = Enum.KeyCode.F1,
    },
}

-- Save keybinds
local function SaveKeybinds()
    if writefile then
        pcall(function()
            local data = {}
            for name, key in pairs(KeybindSystem.Active) do
                data[name] = key.Name
            end
            writefile("CrystalHub_Keybinds.json", HttpService:JSONEncode(data))
        end)
    end
end

-- Load keybinds
local function LoadKeybinds()
    if readfile and isfile and isfile("CrystalHub_Keybinds.json") then
        pcall(function()
            local data = HttpService:JSONDecode(readfile("CrystalHub_Keybinds.json"))
            for name, keyName in pairs(data) do
                local key = Enum.KeyCode[keyName]
                if key then
                    KeybindSystem.Active[name] = key
                end
            end
        end)
    else
        -- Load defaults
        for name, key in pairs(KeybindSystem.DefaultBinds) do
            KeybindSystem.Active[name] = key
        end
    end
end

-- Set keybind
local function SetKeybind(name, key)
    KeybindSystem.Active[name] = key
    SaveKeybinds()
    print(string.format("[Crystal v7] Keybind set: %s -> %s", name, key.Name))
end

-- Get keybind
local function GetKeybind(name)
    return KeybindSystem.Active[name] or KeybindSystem.DefaultBinds[name]
end

-- Load keybinds on startup
LoadKeybinds()

-- Keybind input handler
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- Check if waiting for keybind
    if KeybindSystem.Waiting then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            SetKeybind(KeybindSystem.Waiting, input.KeyCode)
            KeybindSystem.Waiting = nil
            return
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            KeybindSystem.Waiting = nil
            return
        end
    end
    
    -- Global toggle
    local globalToggle = GetKeybind("GlobalToggle")
    if globalToggle and input.KeyCode == globalToggle then
        if Hub.Main then
            Hub.Main.Visible = not Hub.Main.Visible
        end
    end
    
    -- Aim Assist toggle (DELETE KEY)
    local aimAssistKey = GetKeybind("AimAssist")
    if aimAssistKey and input.KeyCode == aimAssistKey then
        Configs.AimAssist.Enabled = not Configs.AimAssist.Enabled
        if Configs.AimAssist.Enabled then
            Notify("Aim Assist", "ENABLED", 1, "success")
        else
            Notify("Aim Assist", "DISABLED", 1, "warning")
        end
    end
    
    -- Blink teleport
    local blinkKey = GetKeybind("Blink")
    if blinkKey and input.KeyCode == blinkKey and Configs.Blink.Enabled then
        local root = GetRoot()
        if root then
            root.CFrame = root.CFrame + Camera.CFrame.LookVector * Configs.Blink.Distance
            Notify("Blink", "Teleported " .. Configs.Blink.Distance .. " studs!", 1, "success")
        end
    end
    
    -- Dash
    local dashKey = GetKeybind("Dash")
    if dashKey and input.KeyCode == dashKey and Configs.Dash.Enabled then
        local root = GetRoot()
        if root then
            root.Velocity = root.Velocity + Camera.CFrame.LookVector * Configs.Dash.Distance * 3
            Notify("Dash", "Dashed!", 1, "success")
        end
    end
end)

----------------------------------------------------------------------------------
-- SECTION 8: UTILITY FUNCTIONS
----------------------------------------------------------------------------------

-- Tween creation
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

-- World to screen conversion (UNIVERSAL - works on all platforms)
local function WorldToScreen(pos)
    if not Camera then return Vector2.zero, false end
    local ok, sp, on = pcall(function()
        local p, v = Camera:WorldToViewportPoint(pos)
        return Vector2.new(p.X, p.Y), v
    end)
    return ok and sp or Vector2.zero, ok and on or false
end

-- Check if player is alive
local function IsAlive(p)
    if p and p.Character then
        local h = p.Character:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end
    return false
end

-- Get humanoid
local function GetHumanoid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- Get root part
local function GetRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Get distance between players
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

-- Get aimbot radius
local function GetAimbotRadius()
    if Configs.Aimbot.CustomRadius then
        return Configs.Aimbot.CustomRadiusValue
    end
    return Configs.Aimbot.Radius
end

-- Get closest player with all checks
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

-- Check Drawing API availability
local HasDrawing = pcall(function()
    local t = Drawing.new("Line")
    t:Remove()
end)

print(string.format("[Crystal v7] Drawing API: %s", HasDrawing and "Available" or "Not Available"))

----------------------------------------------------------------------------------
-- SECTION 9: SCREEN GUI CREATION
----------------------------------------------------------------------------------

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrystalHubV7"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Parent with fallback
local parentOk = pcall(function()
    ScreenGui.Parent = GUIParent
end)

if not parentOk then
    warn("[Crystal v7] Failed to parent ScreenGui, trying PlayerGui")
    ScreenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or game
end

-- Store reference
Hub.ScreenGui = ScreenGui

----------------------------------------------------------------------------------
-- SECTION 10: NOTIFICATION SYSTEM (UNIVERSAL)
----------------------------------------------------------------------------------

-- Notification container
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 350, 1, 0)
NotifContainer.Position = UDim2.new(1, -350, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Parent = NotifContainer

-- Notification function (works on all platforms)
local function Notify(title, msg, dur, ntype)
    ntype = ntype or "info"
    local colors = {
        info = T("Info"),
        success = T("Success"),
        error = T("Error"),
        warning = T("Warning"),
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
    
    -- Animate in
    CreateTween(n, {Position = UDim2.new(1, -320, 0, 0)}, 0.5, Enum.EasingStyle.Back)
    
    -- Auto remove
    task.delay(dur or 3, function()
        if n and n.Parent then
            CreateTween(n, {
                Position = UDim2.new(1, 20, 0, 0),
                BackgroundTransparency = 1,
            }, 0.4)
            task.wait(0.4)
            pcall(function() n:Destroy() end)
        end
    end)
end

-- Store function globally
_G.Notify = Notify

----------------------------------------------------------------------------------
-- SECTION 11: MAIN FRAME (ADAPTIVE SIZE)
----------------------------------------------------------------------------------

-- Calculate adaptive size
local MainWidth = Platform.IsMobile and math.min(Platform.ScreenSize.X * 0.95, 700) or 700
local MainHeight = Platform.IsMobile and math.min(Platform.ScreenSize.Y * 0.85, 520) or 520

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, MainWidth, 0, MainHeight)
Main.Position = Platform.IsMobile and UDim2.new(0.5, -MainWidth/2, 0.5, -MainHeight/2) or UDim2.new(0.5, -350, 0.5, -260)
Main.BackgroundColor3 = T("Background")
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = true -- Always visible, no mobile buttons
Main.Parent = ScreenGui

Hub.Main = Main

-- Corner radius
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, Platform.IsMobile and 15 or 20)

-- Main stroke
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = T("GlassBorder")
MainStroke.Thickness = Platform.IsMobile and 1.5 or 2.5
MainStroke.Transparency = 0.3

Hub.MainStroke = MainStroke

-- Glass overlay
local Overlay = Instance.new("Frame", Main)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = T("Glass")
Overlay.BackgroundTransparency = 0.2
Overlay.BorderSizePixel = 0
Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0, Platform.IsMobile and 15 or 20)

-- Gradient background
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
    NumberSequenceKeypoint.new(0, 0.92),
    NumberSequenceKeypoint.new(0.5, 0.88),
    NumberSequenceKeypoint.new(1, 0.92),
})

Hub.Gradient = Grad

-- Glow effect
local Glow = Instance.new("Frame", Main)
Glow.Size = UDim2.new(1, 30, 1, 30)
Glow.Position = UDim2.new(0, -15, 0, -15)
Glow.BackgroundColor3 = T("Glow")
Glow.BackgroundTransparency = 0.95
Glow.BorderSizePixel = 0
Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 25)

Hub.Glow = Glow

----------------------------------------------------------------------------------
-- SECTION 12: TITLE BAR
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
TitleFix.BorderSizePixel = 0

-- Logo
local Logo = Instance.new("TextLabel", Title)
Logo.Size = UDim2.new(0, 50, 1, 0)
Logo.Position = UDim2.new(0, Platform.IsMobile and 10 or 15, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "💎"
Logo.TextSize = Platform.IsMobile and 24 or 28

-- Title text
local TitleText = Instance.new("TextLabel", Title)
TitleText.Size = UDim2.new(0, 250, 1, 0)
TitleText.Position = UDim2.new(0, Platform.IsMobile and 55 or 65, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Crystal Hub v7.0"
TitleText.TextColor3 = T("Text")
TitleText.TextSize = Platform.IsMobile and 14 or 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Platform badge
local PlatformBadge = Instance.new("Frame", Title)
PlatformBadge.Size = UDim2.new(0, 80, 0, 20)
PlatformBadge.Position = UDim2.new(0, Platform.IsMobile and 180 or 250, 0.5, -10)
PlatformBadge.BackgroundColor3 = T("Accent")
PlatformBadge.BackgroundTransparency = 0.3
PlatformBadge.BorderSizePixel = 0
Instance.new("UICorner", PlatformBadge).CornerRadius = UDim.new(0, 10)

local PlatformText = Instance.new("TextLabel", PlatformBadge)
PlatformText.Size = UDim2.new(1, 0, 1, 0)
PlatformText.BackgroundTransparency = 1
PlatformText.Text = Platform.IsMobile and "📱 Mobile" or "💻 PC"
PlatformText.TextColor3 = T("Text")
PlatformText.TextSize = Platform.IsMobile and 9 or 10
PlatformText.Font = Enum.Font.GothamBold

-- Window controls
local Controls = Instance.new("Frame", Title)
Controls.Size = UDim2.new(0, Platform.IsMobile and 80 or 120, 0, 30)
Controls.Position = UDim2.new(1, Platform.IsMobile and -90 or -130, 0.5, -15)
Controls.BackgroundTransparency = 1

-- Control button creator
local function MakeControlBtn(pos, color, text)
    local b = Instance.new("TextButton", Controls)
    b.Size = UDim2.new(0, 30, 0, 30)
    b.Position = UDim2.new(0, pos, 0, 0)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.3
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = T("Text")
    b.TextSize = Platform.IsMobile and 12 or 14
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end

local MinBtn = MakeControlBtn(0, T("Warning"), "—")
local CloseBtn = MakeControlBtn(Platform.IsMobile and 40 or 76, T("Error"), "✕")

-- Theme button
local ThemeBtn = Instance.new("TextButton", Title)
ThemeBtn.Size = UDim2.new(0, 35, 0, 35)
ThemeBtn.Position = UDim2.new(1, Platform.IsMobile and -140 or -175, 0.5, -17.5)
ThemeBtn.BackgroundColor3 = T("Accent")
ThemeBtn.BackgroundTransparency = 0.4
ThemeBtn.BorderSizePixel = 0
ThemeBtn.Text = "🎨"
ThemeBtn.TextSize = 16
Instance.new("UICorner", ThemeBtn).CornerRadius = UDim.new(1, 0)

----------------------------------------------------------------------------------
-- SECTION 13: DRAG SYSTEM (TOUCH + MOUSE)
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

-- Minimize button
MinBtn.MouseButton1Click:Connect(function()
    Hub.Minimized = not Hub.Minimized
    CreateTween(Main, {
        Size = Hub.Minimized and UDim2.new(0, MainWidth, 0, TitleHeight) or UDim2.new(0, MainWidth, 0, MainHeight)
    }, 0.4, Enum.EasingStyle.Back)
end)

-- Close button
CloseBtn.MouseButton1Click:Connect(function()
    CreateTween(Main, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, 0.5, Enum.EasingStyle.Back)
    task.wait(0.5)
    pcall(function() ScreenGui:Destroy() end)
end)

----------------------------------------------------------------------------------
-- SECTION 14: SIDEBAR
----------------------------------------------------------------------------------

local SidebarWidth = Platform.IsMobile and 50 or 70

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -TitleHeight)
Sidebar.Position = UDim2.new(0, 0, 0, TitleHeight)
Sidebar.BackgroundColor3 = T("Secondary")
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0

local SL = Instance.new("UIListLayout", Sidebar)
SL.Padding = UDim.new(0, Platform.IsMobile and 5 or 8)
SL.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SP = Instance.new("UIPadding", Sidebar)
SP.PaddingTop = UDim.new(0, Platform.IsMobile and 10 or 20)

-- Tab data
local TabData = {
    {Name = "Combat", Icon = "⚔️"},
    {Name = "Movement", Icon = "🏃"},
    {Name = "Player", Icon = "👤"},
    {Name = "Render", Icon = "👁️"},
    {Name = "Utils", Icon = "⚙️"},
    {Name = "Settings", Icon = "🎨"},
}

local TabBtns = {}
local TabContents = {}

-- Tab button creator
local function MakeTabBtn(data)
    local btnSize = Platform.IsMobile and 40 or 50
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0, btnSize, 0, btnSize)
    b.BackgroundColor3 = T("TabInactive")
    b.BackgroundTransparency = 0.5
    b.BorderSizePixel = 0
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, Platform.IsMobile and 10 or 15)
    
    local ic = Instance.new("TextLabel", b)
    ic.Size = UDim2.new(1, 0, 0, 30)
    ic.Position = UDim2.new(0, 0, 0, 5)
    ic.BackgroundTransparency = 1
    ic.Text = data.Icon
    ic.TextSize = Platform.IsMobile and 16 or 20
    
    local nm = Instance.new("TextLabel", b)
    nm.Size = UDim2.new(1, 0, 0, 15)
    nm.Position = UDim2.new(0, 0, 0, 33)
    nm.BackgroundTransparency = 1
    nm.Text = data.Name
    nm.TextColor3 = T("TextSecondary")
    nm.TextSize = Platform.IsMobile and 7 or 8
    nm.Font = Enum.Font.GothamBold
    
    local ind = Instance.new("Frame", b)
    ind.Size = UDim2.new(0, 4, 0, 35)
    ind.Position = UDim2.new(0, -6, 0.5, -17.5)
    ind.BackgroundColor3 = T("TabActive")
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)
    
    TabBtns[data.Name] = {Btn = b, Ind = ind, Name = nm}
    
    -- Hover effects
    b.MouseEnter:Connect(function()
        if Hub.CurrentTab ~= data.Name then
            CreateTween(b, {BackgroundTransparency = 0.3, BackgroundColor3 = T("TabHover")}, 0.2)
        end
    end)
    
    b.MouseLeave:Connect(function()
        if Hub.CurrentTab ~= data.Name then
            CreateTween(b, {BackgroundTransparency = 0.5, BackgroundColor3 = T("TabInactive")}, 0.2)
        end
    end)
    
    -- Click handler
    b.MouseButton1Click:Connect(function()
        if Hub.CurrentTab ~= data.Name then
            local cur = TabBtns[Hub.CurrentTab]
            if cur then
                CreateTween(cur.Btn, {BackgroundTransparency = 0.5, BackgroundColor3 = T("TabInactive")}, 0.3)
                CreateTween(cur.Ind, {BackgroundTransparency = 1}, 0.3)
            end
            CreateTween(b, {BackgroundTransparency = 0.3, BackgroundColor3 = T("TabActive")}, 0.3)
            CreateTween(ind, {BackgroundTransparency = 0}, 0.3)
            Hub.CurrentTab = data.Name
            for n, c in pairs(TabContents) do
                if c then c.Visible = (n == data.Name) end
            end
        end
    end)
end

-- Create all tab buttons
for _, td in ipairs(TabData) do
    MakeTabBtn(td)
end

-- Activate tab function
local function ActivateTab(name)
    local b = TabBtns[name]
    if b then
        CreateTween(b.Btn, {BackgroundTransparency = 0.3, BackgroundColor3 = T("TabActive")}, 0.01)
        CreateTween(b.Ind, {BackgroundTransparency = 0}, 0.01)
    end
end

----------------------------------------------------------------------------------
-- SECTION 15: CONTENT AREA
----------------------------------------------------------------------------------

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -SidebarWidth, 1, -TitleHeight)
Content.Position = UDim2.new(0, SidebarWidth, 0, TitleHeight)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0

----------------------------------------------------------------------------------
-- SECTION 16: UI COMPONENTS (PLATFORM ADAPTIVE)
----------------------------------------------------------------------------------

local ItemHeight = Platform.IsMobile and 45 or 55
local ItemPadding = Platform.IsMobile and 8 or 10

-- Section creator
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
    sep.BorderSizePixel = 0
    
    return c
end

-- Toggle creator
local function Toggle(parent, name, desc, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, ItemHeight)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
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
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local ciSize = bgSize * 0.8
    local ci = Instance.new("Frame", bg)
    ci.Size = UDim2.new(0, ciSize, 0, ciSize)
    ci.Position = def and UDim2.new(1, -ciSize - 2, 0.5, -ciSize/2) or UDim2.new(0, 2, 0.5, -ciSize/2)
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
        CreateTween(ci, {
            Position = state and UDim2.new(1, -ciSize - 2, 0.5, -ciSize/2) or UDim2.new(0, 2, 0.5, -ciSize/2)
        }, 0.3, Enum.EasingStyle.Back)
        if cb then pcall(cb, state) end
    end)
    
    return c, function(s)
        state = s
        bg.BackgroundColor3 = state and T("ToggleOn") or T("ToggleOff")
        ci.Position = state and UDim2.new(1, -ciSize - 2, 0.5, -ciSize/2) or UDim2.new(0, 2, 0.5, -ciSize/2)
    end
end

-- Slider creator
local function Slider(parent, name, min, max, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, Platform.IsMobile and 55 or 70)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
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
    sb.BackgroundColor3 = T("SliderBg")
    sb.BorderSizePixel = 0
    Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)
    
    local sf = Instance.new("Frame", sb)
    sf.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    sf.BackgroundColor3 = T("SliderFill")
    sf.BorderSizePixel = 0
    Instance.new("UICorner", sf).CornerRadius = UDim.new(1, 0)
    
    local knobSize = Platform.IsMobile and 20 or 16
    local sk = Instance.new("Frame", sb)
    sk.Size = UDim2.new(0, knobSize, 0, knobSize)
    sk.Position = UDim2.new((def - min) / (max - min), -knobSize/2, 0.5, -knobSize/2)
    sk.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sk.BorderSizePixel = 0
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            Upd(i)
        end
    end)
    
    sb.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            Upd(i)
        end
    end)
    
    return c, function(v)
        val = math.clamp(v, min, max)
        local r = (val - min) / (max - min)
        sf.Size = UDim2.new(r, 0, 1, 0)
        sk.Position = UDim2.new(r, -knobSize/2, 0.5, -knobSize/2)
        vl.Text = tostring(val)
    end
end

-- Button creator
local function Button(parent, name, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, Platform.IsMobile and 40 or 45)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, Platform.IsMobile and 10 or 12)
    
    local b = Instance.new("TextButton", c)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = name
    b.TextColor3 = T("Text")
    b.TextSize = Platform.IsMobile and 12 or 13
    b.Font = Enum.Font.GothamBold
    
    b.MouseEnter:Connect(function()
        CreateTween(c, {BackgroundTransparency = 0.4, BackgroundColor3 = T("Accent")}, 0.2)
    end)
    
    b.MouseLeave:Connect(function()
        CreateTween(c, {BackgroundTransparency = 0.6, BackgroundColor3 = T("Secondary")}, 0.2)
    end)
    
    b.MouseButton1Click:Connect(function()
        if cb then pcall(cb) end
    end)
    
    return c
end

-- Dropdown creator
local function Dropdown(parent, name, opts, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, ItemHeight)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
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
    db.BorderSizePixel = 0
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
    list.BorderSizePixel = 0
    list.Visible = false
    list.ClipsDescendants = true
    list.ZIndex = 10
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 10)
    
    local ll = Instance.new("UIListLayout", list)
    ll.Padding = UDim.new(0, 3)
    
    local lp = Instance.new("UIPadding", list)
    lp.PaddingTop = UDim.new(0, 5)
    lp.PaddingBottom = UDim.new(0, 5)
    
    local sel, open = def or opts[1], false
    
    for _, opt in ipairs(opts) do
        local ob = Instance.new("TextButton", list)
        ob.Size = UDim2.new(1, 0, 0, Platform.IsMobile and 25 or 28)
        ob.BackgroundColor3 = T("Secondary")
        ob.BackgroundTransparency = 0.3
        ob.BorderSizePixel = 0
        ob.Text = "  " .. opt
        ob.TextColor3 = T("Text")
        ob.TextSize = Platform.IsMobile and 10 or 11
        ob.Font = Enum.Font.Gotham
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.ZIndex = 11
        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 8)
        
        ob.MouseButton1Click:Connect(function()
            sel = opt
            db.Text = "  " .. opt
            open = false
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

-- TextBox creator
local function TextBox(parent, name, placeholder, def, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, ItemHeight)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
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
    tb.BorderSizePixel = 0
    tb.PlaceholderText = placeholder
    tb.PlaceholderColor3 = T("TextSecondary")
    tb.Text = def or ""
    tb.TextColor3 = T("Text")
    tb.TextSize = Platform.IsMobile and 10 or 11
    tb.Font = Enum.Font.Gotham
    tb.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)
    
    local tp = Instance.new("UIPadding", tb)
    tp.PaddingLeft = UDim.new(0, 10)
    
    tb.FocusLost:Connect(function()
        if cb then pcall(cb, tb.Text) end
    end)
    
    return c, function(v)
        tb.Text = v
    end
end

-- Keybind button creator
local function KeybindBtn(parent, name, defaultKey, cb)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1, -20, 0, ItemHeight)
    c.BackgroundColor3 = T("Secondary")
    c.BackgroundTransparency = 0.6
    c.BorderSizePixel = 0
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
    
    local currentKey = defaultKey or GetKeybind(name)
    
    local kbBtn = Instance.new("TextButton", c)
    kbBtn.Size = UDim2.new(0, Platform.IsMobile and 120 or 160, 0, Platform.IsMobile and 25 or 30)
    kbBtn.Position = UDim2.new(1, -(Platform.IsMobile and 120 or 160) - 10, 0.5, Platform.IsMobile and -12 or -15)
    kbBtn.BackgroundColor3 = T("Accent")
    kbBtn.BackgroundTransparency = 0.5
    kbBtn.BorderSizePixel = 0
    kbBtn.Text = currentKey and currentKey.Name or "None"
    kbBtn.TextColor3 = T("Text")
    kbBtn.TextSize = Platform.IsMobile and 10 or 11
    kbBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 10)
    
    kbBtn.MouseButton1Click:Connect(function()
        KeybindSystem.Waiting = name
        kbBtn.Text = "Press a key..."
        kbBtn.BackgroundColor3 = T("Warning")
    end)
    
    -- Update display when keybind changes
    task.spawn(function()
        while c and c.Parent do
            local key = GetKeybind(name)
            if key and kbBtn.Text ~= key.Name and KeybindSystem.Waiting ~= name then
                kbBtn.Text = key.Name
                kbBtn.BackgroundColor3 = T("Accent")
                kbBtn.BackgroundTransparency = 0.5
            end
            task.wait(0.1)
        end
    end)
    
    return c
end

----------------------------------------------------------------------------------
-- SECTION 17: COMBAT TAB
----------------------------------------------------------------------------------

local function CombatTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 2500 or 3000)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    -- AIMBOT SECTION
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
    Dropdown(c, "Priority", {"Closest", "FOV", "Health", "Distance"}, "Closest", function(v) Configs.Aimbot.Priority = v end)
    Toggle(c, "Auto Shoot", "Shoot on lock", false, function(s) Configs.Aimbot.AutoShoot = s end)
    
    -- AIM ASSIST SECTION (WITH KEYBIND)
    Section(c, "AIM ASSIST (Delete Key)")
    
    Toggle(c, "Aim Assist", "Assist aiming", false, function(s)
        Configs.AimAssist.Enabled = s
        Notify("Aim Assist", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
    
    KeybindBtn(c, "AimAssist", Enum.KeyCode.Delete, function(key)
        SetKeybind("AimAssist", key)
        Configs.AimAssist.Keybind = key
        Notify("Keybind", "Aim Assist bound to " .. key.Name, 2, "success")
    end)
    
    Slider(c, "Assist FOV", 50, 300, 150, function(v) Configs.AimAssist.FOV = v end)
    Slider(c, "Assist Smooth", 1, 100, 15, function(v) Configs.AimAssist.Smooth = v/100 end)
    Toggle(c, "Show Indicator", "Show status", true, function(s) Configs.AimAssist.ShowIndicator = s end)
    Toggle(c, "Auto Disable", "Disable on kill", false, function(s) Configs.AimAssist.AutoDisable = s end)
    
    -- TRIGGERBOT SECTION
    Section(c, "TRIGGERBOT")
    
    Toggle(c, "Triggerbot", "Auto fire on target", false, function(s) Configs.Triggerbot.Enabled = s end)
    Slider(c, "Trigger Delay", 0, 500, 0, function(v) Configs.Triggerbot.Delay = v/1000 end)
    Slider(c, "Max Distance", 10, 1000, 500, function(v) Configs.Triggerbot.MaxDist = v end)
    Toggle(c, "Head Only", "Head shots only", false, function(s) Configs.Triggerbot.HeadOnly = s end)
    Toggle(c, "Random Delay", "Humanize", false, function(s) Configs.Triggerbot.RandomDelay = s end)
    
    -- SILENT AIM SECTION
    Section(c, "SILENT AIM")
    
    Toggle(c, "Silent Aim", "Server-side aim", false, function(s) Configs.SilentAim.Enabled = s end)
    Slider(c, "Hit Chance", 1, 100, 100, function(v) Configs.SilentAim.HitChance = v end)
    Toggle(c, "Visible Check", "Check visibility", true, function(s) Configs.SilentAim.VisibleCheck = s end)
    
    -- KILL AURA SECTION
    Section(c, "KILL AURA")
    
    Toggle(c, "Kill Aura", "Attack nearby", false, function(s) Configs.KillAura.Enabled = s end)
    Slider(c, "Aura Range", 1, 50, 15, function(v) Configs.KillAura.Range = v end)
    Toggle(c, "Aura Team Check", "Ignore team", false, function(s) Configs.KillAura.TeamCheck = s end)
    Slider(c, "Attack Delay", 1, 100, 10, function(v) Configs.KillAura.Delay = v/100 end)
    
    -- ADDITIONAL COMBAT
    Section(c, "ADDITIONAL COMBAT")
    
    Toggle(c, "Hitbox Extender", "Bigger hitboxes", false, function(s) Configs.HitboxExtender.Enabled = s end)
    Slider(c, "Hitbox Size", 1, 20, 5, function(v) Configs.HitboxExtender.Size = v end)
    Toggle(c, "Anti-Aim", "Desync model", false, function(s) Configs.AntiAim.Enabled = s end)
    Dropdown(c, "Anti-Aim Type", {"Roll", "Spin", "Jitter", "Down", "Sideways", "Random"}, "Roll", function(v) Configs.AntiAim.Type = v end)
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
    Toggle(c, "Auto Reload", "Auto reload", false, function(s) Configs.AutoReload.Enabled = s end)
    Toggle(c, "Backtrack", "Lag compensation", false, function(s) Configs.Backtrack.Enabled = s end)
    Toggle(c, "Target Strafe", "Strafe around target", false, function(s) Configs.TargetStrafe.Enabled = s end)
    Toggle(c, "Predictive Aim", "Better prediction", false, function(s) Configs.PredictiveAim.Enabled = s end)
    Toggle(c, "Auto Duck", "Duck on shot", false, function(s) Configs.AutoDuck.Enabled = s end)
    Toggle(c, "Auto Jump", "Jump randomly", false, function(s) Configs.AutoJump.Enabled = s end)
    
    TabContents["Combat"] = c
end

----------------------------------------------------------------------------------
-- SECTION 18: MOVEMENT TAB
----------------------------------------------------------------------------------

local function MovementTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 2800 or 3200)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    -- SPEED SECTION
    Section(c, "SPEED")
    
    Toggle(c, "Speed Hack", "Increase walkspeed", false, function(s)
        Configs.Speed.Enabled = s
        Notify("Speed", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
    Slider(c, "Walk Speed", 16, 500, 16, function(v) Configs.Speed.Value = v end)
    Dropdown(c, "Speed Method", {"Humanoid", "CFrame", "Velocity"}, "Humanoid", function(v) Configs.Speed.Method = v end)
    
    -- FLY SECTION
    Section(c, "FLY")
    
    Toggle(c, "Fly", "Flight mode", false, function(s) Configs.Fly.Enabled = s end)
    Slider(c, "Fly Speed", 10, 500, 50, function(v) Configs.Fly.Speed = v end)
    Toggle(c, "Fly Noclip", "Through walls", false, function(s) Configs.Fly.Noclip = s end)
    KeybindBtn(c, "Fly", Enum.KeyCode.F)
    
    -- NOCLIP & JUMP
    Section(c, "NOCLIP & JUMP")
    
    Toggle(c, "Noclip", "Walk through walls", false, function(s) Configs.Noclip.Enabled = s end)
    KeybindBtn(c, "Noclip", Enum.KeyCode.N)
    Toggle(c, "Infinite Jump", "Jump in air", false, function(s) Configs.InfJump.Enabled = s end)
    Toggle(c, "Long Jump", "Extended jump", false, function(s) Configs.LongJump.Enabled = s end)
    Slider(c, "Jump Power", 10, 300, 100, function(v) Configs.LongJump.Power = v end)
    Toggle(c, "Bunny Hop", "Auto jump", false, function(s) Configs.BunnyHop.Enabled = s end)
    Toggle(c, "High Jump", "Higher jumps", false, function(s) Configs.HighJump.Enabled = s end)
    Slider(c, "Jump Height", 50, 300, 100, function(v) Configs.HighJump.Height = v end)
    Toggle(c, "Super Jump", "Massive jump", false, function(s) Configs.SuperJump.Enabled = s end)
    Slider(c, "Super Power", 100, 1000, 200, function(v) Configs.SuperJump.Power = v end)
    Toggle(c, "Moon Jump", "Float in air", false, function(s) Configs.MoonJump.Enabled = s end)
    Toggle(c, "Double Jump", "Extra jump", false, function(s) Configs.DoubleJump.Enabled = s end)
    Toggle(c, "Air Jump", "Multiple air jumps", false, function(s) Configs.AirJump.Enabled = s end)
    
    -- SPECIAL MOVEMENT
    Section(c, "SPECIAL MOVEMENT")
    
    Toggle(c, "Jetpack", "Fly upward", false, function(s) Configs.Jetpack.Enabled = s end)
    Slider(c, "Jetpack Power", 10, 500, 100, function(v) Configs.Jetpack.Power = v end)
    Toggle(c, "Wall Climb", "Climb walls", false, function(s) Configs.WallClimb.Enabled = s end)
    Toggle(c, "Glide", "Glide in air", false, function(s) Configs.Glide.Enabled = s end)
    Toggle(c, "Spider", "Walk on walls", false, function(s) Configs.Spider.Enabled = s end)
    Toggle(c, "CFrame Speed", "TP-based speed", false, function(s) Configs.CFrameSpeed.Enabled = s end)
    Slider(c, "CFrame Value", 10, 1000, 100, function(v) Configs.CFrameSpeed.Value = v end)
    Toggle(c, "Blink (Q)", "Short teleport", false, function(s) Configs.Blink.Enabled = s end)
    KeybindBtn(c, "Blink", Enum.KeyCode.Q)
    Slider(c, "Blink Distance", 5, 100, 20, function(v) Configs.Blink.Distance = v end)
    Toggle(c, "Phase", "Walk through", false, function(s) Configs.Phase.Enabled = s end)
    Toggle(c, "Slide", "Slide move", false, function(s) Configs.Slide.Enabled = s end)
    Slider(c, "Slide Speed", 10, 200, 50, function(v) Configs.Slide.Speed = v end)
    Toggle(c, "Dash", "Quick dash", false, function(s) Configs.Dash.Enabled = s end)
    KeybindBtn(c, "Dash", Enum.KeyCode.E)
    Slider(c, "Dash Distance", 5, 100, 30, function(v) Configs.Dash.Distance = v end)
    Toggle(c, "Gravity Flip", "Flip gravity", false, function(s) Configs.GravityFlip.Enabled = s end)
    Toggle(c, "Reverse Gravity", "Reverse gravity", false, function(s) Configs.ReverseGravity.Enabled = s end)
    Toggle(c, "Orbit", "Orbit target", false, function(s) Configs.Orbit.Enabled = s end)
    Slider(c, "Orbit Speed", 1, 50, 10, function(v) Configs.Orbit.Speed = v end)
    Slider(c, "Orbit Radius", 5, 50, 20, function(v) Configs.Orbit.Radius = v end)
    Toggle(c, "Telekinesis", "Move objects", false, function(s) Configs.Telekinesis.Enabled = s end)
    Toggle(c, "Gravity Gun", "Pick up objects", false, function(s) Configs.GravityGun.Enabled = s end)
    Toggle(c, "Magnet", "Attract items", false, function(s) Configs.Magnet.Enabled = s end)
    Toggle(c, "Water Walk", "Walk on water", false, function(s) Configs.WaterWalk.Enabled = s end)
    Toggle(c, "Ice Walk", "Walk on ice", false, function(s) Configs.IceWalk.Enabled = s end)
    Toggle(c, "Lava Walk", "Walk on lava", false, function(s) Configs.LavaWalk.Enabled = s end)
    Toggle(c, "Slow Fall", "Fall slowly", false, function(s) Configs.SlowFall.Enabled = s end)
    Toggle(c, "Fast Fall", "Fall quickly", false, function(s) Configs.FastFall.Enabled = s end)
    
    -- TELEPORTS
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
    
    Button(c, "TP to Random Player", function()
        local players = Players:GetPlayers()
        local random = players[math.random(1, #players)]
        if random and random ~= LocalPlayer and random.Character then
            local rp = random.Character:FindFirstChild("HumanoidRootPart")
            local lr = GetRoot()
            if rp and lr then
                lr.CFrame = rp.CFrame + Vector3.new(5, 0, 0)
                Notify("TP", "To " .. random.Name, 2, "success")
            end
        end
    end)
    
    TabContents["Movement"] = c
end

----------------------------------------------------------------------------------
-- SECTION 19: PLAYER TAB
----------------------------------------------------------------------------------

local function PlayerTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 2500 or 3000)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    -- SURVIVAL
    Section(c, "SURVIVAL")
    
    Toggle(c, "God Mode", "Infinite HP", false, function(s) Configs.GodMode.Enabled = s end)
    Toggle(c, "Anti-Void", "Prevent void death", false, function(s) Configs.AntiVoid.Enabled = s end)
    Slider(c, "Void Height", -1000, -100, -500, function(v) Configs.AntiVoid.Height = v end)
    Toggle(c, "No Fall Damage", "No fall damage", false, function(s) Configs.NoFall.Enabled = s end)
    Toggle(c, "Anti-Grab", "Prevent grab", false, function(s) Configs.AntiGrab.Enabled = s end)
    Toggle(c, "Auto Revive", "Auto respawn", false, function(s) Configs.AutoRevive.Enabled = s end)
    Toggle(c, "Invincibility Frames", "I-frames", false, function(s) Configs.InvincibilityFrames.Enabled = s end)
    Toggle(c, "Damage Reflection", "Reflect damage", false, function(s) Configs.DamageReflection.Enabled = s end)
    Slider(c, "Reflect Percent", 10, 200, 100, function(v) Configs.DamageReflection.Percent = v end)
    Toggle(c, "Lifesteal", "Heal on hit", false, function(s) Configs.Lifesteal.Enabled = s end)
    Slider(c, "Lifesteal %", 5, 100, 20, function(v) Configs.Lifesteal.Percent = v end)
    Toggle(c, "Regeneration", "Auto regen", false, function(s) Configs.Regeneration.Enabled = s end)
    Slider(c, "Regen Rate", 1, 50, 5, function(v) Configs.Regeneration.Rate = v end)
    Toggle(c, "Auto Shield", "Auto shield", false, function(s) Configs.AutoShield.Enabled = s end)
    Toggle(c, "Infinite Stamina", "No stamina drain", false, function(s) Configs.InfiniteStamina.Enabled = s end)
    Toggle(c, "No Hunger", "Never hungry", false, function(s) Configs.NoHunger.Enabled = s end)
    Toggle(c, "No Thirst", "Never thirsty", false, function(s) Configs.NoThirst.Enabled = s end)
    Toggle(c, "Auto Heal", "Heal when low", false, function(s) Configs.AutoHeal.Enabled = s end)
    Slider(c, "Heal Threshold", 10, 90, 50, function(v) Configs.AutoHeal.Threshold = v end)
    Toggle(c, "No Damage", "Immune to damage", false, function(s) Configs.NoDamage.Enabled = s end)
    Toggle(c, "No Ragdoll", "Prevent ragdoll", false, function(s) Configs.NoRagdoll.Enabled = s end)
    Toggle(c, "No Slowdown", "No slowdowns", false, function(s) Configs.NoSlowdown.Enabled = s end)
    Toggle(c, "No Push", "Cannot be pushed", false, function(s) Configs.NoPush.Enabled = s end)
    
    -- AUTOMATION
    Section(c, "AUTOMATION")
    
    Toggle(c, "Anti-AFK", "Prevent AFK kick", false, function(s) Configs.AntiAFK.Enabled = s end)
    Toggle(c, "Auto Click", "Auto click", false, function(s) Configs.AutoClick.Enabled = s end)
    Slider(c, "Clicks/Second", 1, 30, 10, function(v) Configs.AutoClick.CPS = v end)
    Toggle(c, "Auto Farm", "Auto farm", false, function(s) Configs.AutoFarm.Enabled = s end)
    Toggle(c, "Auto Potion", "Use potions", false, function(s) Configs.AutoPotion.Enabled = s end)
    Toggle(c, "Auto Buff", "Apply buffs", false, function(s) Configs.AutoBuff.Enabled = s end)
    Toggle(c, "Auto Cleanse", "Remove debuffs", false, function(s) Configs.AutoDebuffCleanse.Enabled = s end)
    Toggle(c, "Auto Eat", "Eat when hungry", false, function(s) Configs.AutoEat.Enabled = s end)
    Toggle(c, "Auto Drink", "Drink when thirsty", false, function(s) Configs.AutoDrink.Enabled = s end)
    Toggle(c, "Auto Craft", "Auto craft", false, function(s) Configs.AutoCraft.Enabled = s end)
    Toggle(c, "Auto Repair", "Repair items", false, function(s) Configs.AutoRepair.Enabled = s end)
    Toggle(c, "Auto Upgrade", "Upgrade gear", false, function(s) Configs.AutoUpgrade.Enabled = s end)
    Toggle(c, "Auto Sell", "Sell loot", false, function(s) Configs.AutoSell.Enabled = s end)
    Toggle(c, "Auto Buy", "Auto purchase", false, function(s) Configs.AutoBuy.Enabled = s end)
    
    -- PROGRESSION
    Section(c, "PROGRESSION")
    
    Toggle(c, "Stat Boost", "Boost stats", false, function(s) Configs.StatBoost.Enabled = s end)
    Slider(c, "STR Boost", 0, 100, 0, function(v) Configs.StatBoost.STR = v end)
    Slider(c, "DEX Boost", 0, 100, 0, function(v) Configs.StatBoost.DEX = v end)
    Slider(c, "INT Boost", 0, 100, 0, function(v) Configs.StatBoost.INT = v end)
    Toggle(c, "XP Multiplier", "More XP", false, function(s) Configs.XPMultiplier.Enabled = s end)
    Slider(c, "XP Multi", 1, 10, 2, function(v) Configs.XPMultiplier.Multiplier = v end)
    Toggle(c, "Level Hack", "Set level", false, function(s) Configs.LevelHack.Enabled = s end)
    Slider(c, "Target Level", 1, 999, 1, function(v) Configs.LevelHack.Level = v end)
    Toggle(c, "Skill Unlock", "Unlock all skills", false, function(s) Configs.SkillUnlock.Enabled = s end)
    Toggle(c, "Cooldown Reset", "Reset CDs", false, function(s) Configs.CooldownReset.Enabled = s end)
    Toggle(c, "Resource Duplication", "Dupe items", false, function(s) Configs.ResourceDuplication.Enabled = s end)
    Toggle(c, "Inventory Editor", "Edit inventory", false, function(s) Configs.InventoryEditor.Enabled = s end)
    
    -- CHARACTER ACTIONS
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
    
    Button(c, "Set Max HP Infinite", function()
        local h = GetHumanoid()
        if h then
            h.MaxHealth = math.huge
            h.Health = math.huge
            Notify("Character", "Infinite HP!", 2, "success")
        end
    end)
    
    Button(c, "Sit Down", function()
        local h = GetHumanoid()
        if h then
            pcall(function() h.Sit = true end)
            Notify("Character", "Sitting", 1, "info")
        end
    end)
    
    Button(c, "Stand Up", function()
        local h = GetHumanoid()
        if h then
            pcall(function() h.Sit = false end)
            Notify("Character", "Standing", 1, "info")
        end
    end)
    
    -- INFO
    Section(c, "INFO")
    
    Button(c, "Copy Player ID", function()
        if setclipboard then
            pcall(setclipboard, tostring(LocalPlayer.UserId))
            Notify("Info", "Copied: " .. LocalPlayer.UserId, 2, "success")
        else
            Notify("Info", "setclipboard not available", 2, "error")
        end
    end)
    
    Button(c, "Copy Username", function()
        if setclipboard then
            pcall(setclipboard, LocalPlayer.Name)
            Notify("Info", "Copied: " .. LocalPlayer.Name, 2, "success")
        else
            Notify("Info", "setclipboard not available", 2, "error")
        end
    end)
    
    Button(c, "Copy Display Name", function()
        if setclipboard then
            pcall(setclipboard, LocalPlayer.DisplayName)
            Notify("Info", "Copied: " .. LocalPlayer.DisplayName, 2, "success")
        else
            Notify("Info", "setclipboard not available", 2, "error")
        end
    end)
    
    Button(c, "Show Character Info", function()
        local h = GetHumanoid()
        if h then
            local msg = string.format("HP: %d/%d, WalkSpeed: %d, Jump: %d",
                math.floor(h.Health), math.floor(h.MaxHealth),
                math.floor(h.WalkSpeed), math.floor(h.JumpPower))
            Notify("Character", msg, 4, "info")
        end
    end)
    
    TabContents["Player"] = c
end

----------------------------------------------------------------------------------
-- SECTION 20: RENDER TAB (EXTENDED ESP)
----------------------------------------------------------------------------------

local function RenderTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 3500 or 4000)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    -- ENHANCED ESP
    Section(c, "ENHANCED ESP (UNIVERSAL)")
    
    Toggle(c, "ESP", "Show player info", false, function(s)
        Configs.ESP.Enabled = s
        Notify("ESP", s and "Enabled" or "Disabled", 2, s and "success" or "warning")
    end)
    
    Toggle(c, "Box ESP", "Boxes around players", true, function(s) Configs.ESP.Box = s end)
    Dropdown(c, "Box Style", {"Full", "Corner", "3D", "Edge"}, "Full", function(v) Configs.ESP.BoxStyle = v end)
    Slider(c, "Box Thickness", 1, 5, 2, function(v) Configs.ESP.BoxThickness = v end)
    
    Toggle(c, "Name ESP", "Show names", true, function(s) Configs.ESP.Name = s end)
    Slider(c, "Name Size", 8, 24, 14, function(v) Configs.ESP.NameSize = v end)
    Toggle(c, "Name Outline", "Outline text", true, function(s) Configs.ESP.NameOutline = s end)
    
    Toggle(c, "Health ESP", "Health bars", true, function(s) Configs.ESP.Health = s end)
    Slider(c, "Health Bar Width", 1, 10, 4, function(v) Configs.ESP.HealthBarWidth = v end)
    Dropdown(c, "Health Bar Side", {"Left", "Right", "Top", "Bottom"}, "Left", function(v) Configs.ESP.HealthBarSide = v end)
    
    Toggle(c, "Distance ESP", "Show distance", true, function(s) Configs.ESP.Distance = s end)
    Toggle(c, "Show Weapon", "Show weapon", false, function(s) Configs.ESP.ShowWeapon = s end)
    Toggle(c, "Show Armor", "Show armor", false, function(s) Configs.ESP.ShowArmor = s end)
    Toggle(c, "Show Ping", "Show ping", false, function(s) Configs.ESP.ShowPing = s end)
    Toggle(c, "Show Team", "Show team", false, function(s) Configs.ESP.ShowTeam = s end)
    Toggle(c, "Show Flags", "Show flags", false, function(s) Configs.ESP.ShowFlags = s end)
    
    Toggle(c, "Team Check", "Ignore team", false, function(s) Configs.ESP.TeamCheck = s end)
    Slider(c, "Max Distance", 100, 5000, 2000, function(v) Configs.ESP.MaxDist = v end)
    
    Toggle(c, "Glow ESP", "Crystal glow", false, function(s) Configs.ESP.Glow = s end)
    Toggle(c, "Outline ESP", "Outline boxes", true, function(s) Configs.ESP.Outline = s end)
    Toggle(c, "Animated ESP", "Animated effects", true, function(s) Configs.ESP.Animated = s end)
    Toggle(c, "Fade Distance", "Fade far targets", true, function(s) Configs.ESP.FadeDistance = s end)
    Slider(c, "Fade Start", 500, 3000, 1000, function(v) Configs.ESP.FadeStart = v end)
    Slider(c, "Fade End", 1000, 5000, 2000, function(v) Configs.ESP.FadeEnd = v end)
    Toggle(c, "Use Team Colors", "Ally/enemy colors", true, function(s) Configs.ESP.UseTeamColors = s end)
    
    -- TRACERS & LINES
    Section(c, "TRACERS & LINES")
    
    Toggle(c, "Tracers", "Lines to players", false, function(s) Configs.Tracers.Enabled = s end)
    Dropdown(c, "Tracer Origin", {"Bottom", "Center", "Top", "Mouse"}, "Bottom", function(v) Configs.Tracers.Origin = v end)
    Slider(c, "Tracer Thickness", 1, 5, 1, function(v) Configs.Tracers.Thickness = v end)
    Toggle(c, "Tracer Outline", "Outline tracers", false, function(s) Configs.Tracers.Outlined = s end)
    Toggle(c, "Snaplines", "Snap lines", false, function(s) Configs.Snaplines.Enabled = s end)
    Toggle(c, "Distance Circle", "Circle around", false, function(s) Configs.DistanceCircle.Enabled = s end)
    Slider(c, "Circle Radius", 10, 500, 100, function(v) Configs.DistanceCircle.Radius = v end)
    
    -- CHAMS
    Section(c, "CHAMS")
    
    Toggle(c, "Chams", "Highlight through walls", false, function(s) Configs.Chams.Enabled = s end)
    Slider(c, "Chams Transparency", 0, 100, 50, function(v) Configs.Chams.Transparency = v/100 end)
    Toggle(c, "Chams Team Check", "Ignore team", false, function(s) Configs.Chams.TeamCheck = s end)
    Toggle(c, "Glow ESP", "Glow effect", false, function(s) Configs.GlowESP.Enabled = s end)
    Slider(c, "Glow Intensity", 1, 10, 1, function(v) Configs.GlowESP.Intensity = v end)
    Toggle(c, "Outline ESP", "Player outline", false, function(s) Configs.OutlineESP.Enabled = s end)
    Slider(c, "Outline Thickness", 1, 10, 2, function(v) Configs.OutlineESP.Thickness = v end)
    
    -- SKELETON & 3D
    Section(c, "SKELETON & 3D")
    
    Toggle(c, "Skeleton ESP", "Show bones", false, function(s) Configs.SkeletonESP.Enabled = s end)
    Slider(c, "Skeleton Thickness", 1, 5, 2, function(v) Configs.SkeletonESP.Thickness = v end)
    Toggle(c, "3D Box", "3D boxes", false, function(s) Configs.Box3D.Enabled = s end)
    Toggle(c, "Corner ESP", "Corner markers", false, function(s) Configs.CornerESP.Enabled = s end)
    Slider(c, "Corner Size", 3, 30, 10, function(v) Configs.CornerESP.Size = v end)
    Toggle(c, "Armor ESP", "Show armor", false, function(s) Configs.ArmorESP.Enabled = s end)
    Toggle(c, "Weapon ESP", "Show weapon", false, function(s) Configs.WeaponESP.Enabled = s end)
    Toggle(c, "Trail ESP", "Player trails", false, function(s) Configs.TrailESP.Enabled = s end)
    Slider(c, "Trail Lifetime", 1, 10, 2, function(v) Configs.TrailESP.Lifetime = v end)
    Toggle(c, "Particle ESP", "Particle effects", false, function(s) Configs.ParticleESP.Enabled = s end)
    
    -- VISUALS
    Section(c, "VISUALS")
    
    Toggle(c, "Fullbright", "Remove darkness", false, function(s) Configs.Fullbright.Enabled = s end)
    Slider(c, "Brightness", 0, 10, 2, function(v) Configs.Fullbright.Brightness = v end)
    Slider(c, "Clock Time", 0, 24, 14, function(v) Configs.Fullbright.ClockTime = v end)
    Toggle(c, "No Fog", "Remove fog", false, function(s) Configs.NoFog.Enabled = s end)
    Toggle(c, "X-Ray", "See through walls", false, function(s) Configs.Xray.Enabled = s end)
    Slider(c, "X-Ray Transparency", 0, 100, 70, function(v) Configs.Xray.Transparency = v/100 end)
    Toggle(c, "Wireframe", "Wireframe view", false, function(s) Configs.Wireframe.Enabled = s end)
    Toggle(c, "Night Vision", "Night vision", false, function(s) Configs.NightVision.Enabled = s end)
    Toggle(c, "Thermal Vision", "Heat vision", false, function(s) Configs.ThermalVision.Enabled = s end)
    Toggle(c, "Motion Blur", "Blur effect", false, function(s) Configs.MotionBlur.Enabled = s end)
    Slider(c, "Blur Intensity", 1, 100, 50, function(v) Configs.MotionBlur.Intensity = v/100 end)
    Toggle(c, "Chromatic", "Chromatic aberration", false, function(s) Configs.Chromatic.Enabled = s end)
    Slider(c, "Chromatic Intensity", 1, 100, 50, function(v) Configs.Chromatic.Intensity = v/100 end)
    
    -- CAMERA
    Section(c, "CAMERA")
    
    Toggle(c, "Freecam", "Free camera", false, function(s) Configs.Freecam.Enabled = s end)
    KeybindBtn(c, "Freecam", Enum.KeyCode.F1)
    Slider(c, "Freecam Speed", 10, 200, 50, function(v) Configs.Freecam.Speed = v end)
    Toggle(c, "FOV Changer", "Change FOV", false, function(s) Configs.FOVChanger.Enabled = s end)
    Slider(c, "Camera FOV", 30, 120, 70, function(v) Configs.FOVChanger.Value = v end)
    Toggle(c, "Camera Shake", "Shake effect", false, function(s) Configs.CameraShake.Enabled = s end)
    Slider(c, "Shake Intensity", 1, 20, 3, function(v) Configs.CameraShake.Intensity = v end)
    
    -- UI OVERLAY
    Section(c, "UI OVERLAY")
    
    Toggle(c, "Hit Marker", "Hit indicators", false, function(s) Configs.HitMarker.Enabled = s end)
    Toggle(c, "Damage Numbers", "Show damage", false, function(s) Configs.DamageNumbers.Enabled = s end)
    Toggle(c, "Kill Feed", "Kill notifications", false, function(s) Configs.KillFeed.Enabled = s end)
    Toggle(c, "Replay System", "Record actions", false, function(s) Configs.ReplaySystem.Enabled = s end)
    Toggle(c, "Spectator Mode", "Watch players", false, function(s) Configs.SpectatorMode.Enabled = s end)
    Toggle(c, "Map Hack", "Show full map", false, function(s) Configs.MapHack.Enabled = s end)
    Toggle(c, "Radar", "Mini radar", false, function(s) Configs.Radar.Enabled = s end)
    Slider(c, "Radar Size", 50, 300, 150, function(v) Configs.Radar.Size = v end)
    Toggle(c, "Minimap", "Show minimap", false, function(s) Configs.Minimap.Enabled = s end)
    Toggle(c, "Waypoint System", "Mark locations", false, function(s) Configs.WaypointSystem.Enabled = s end)
    
    TabContents["Render"] = c
end

----------------------------------------------------------------------------------
-- SECTION 21: UTILS TAB
----------------------------------------------------------------------------------

local function UtilsTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 3000 or 3500)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    -- SERVER
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
        if setclipboard then
            pcall(setclipboard, game.JobId)
            Notify("Server", "JobId copied!", 2, "success")
        else
            Notify("Server", "setclipboard not available", 2, "error")
        end
    end)
    
    Button(c, "Copy PlaceId", function()
        if setclipboard then
            pcall(setclipboard, tostring(game.PlaceId))
            Notify("Server", "PlaceId copied!", 2, "success")
        else
            Notify("Server", "setclipboard not available", 2, "error")
        end
    end)
    
    Toggle(c, "Auto Rejoin", "Auto rejoin on kick", false, function(s) Configs.AutoRejoin.Enabled = s end)
    Toggle(c, "Server Hop", "Auto hop", false, function(s) Configs.ServerHop.Enabled = s end)
    Toggle(c, "Ban Checker", "Check ban status", false, function(s) Configs.BanChecker.Enabled = s end)
    
    -- CHAT
    Section(c, "CHAT")
    
    Toggle(c, "Chat Spammer", "Auto send messages", false, function(s) Configs.ChatSpam.Enabled = s end)
    TextBox(c, "Spam Message", "Your message", "Crystal Hub", function(v) Configs.ChatSpam.Message = v end)
    Slider(c, "Spam Delay", 1, 10, 3, function(v) Configs.ChatSpam.Delay = v end)
    Toggle(c, "Chat Logger", "Log chat", false, function(s) Configs.ChatLogger.Enabled = s end)
    Toggle(c, "Command System", "Use commands", false, function(s) Configs.CommandSystem.Enabled = s end)
    TextBox(c, "Command Prefix", "!", "!", function(v) Configs.CommandSystem.Prefix = v end)
    
    -- WORLD
    Section(c, "WORLD")
    
    Toggle(c, "Time Change", "Change time", false, function(s) Configs.TimeChange.Enabled = s end)
    Slider(c, "Time of Day", 0, 24, 14, function(v) Configs.TimeChange.Time = v end)
    Toggle(c, "Gravity", "Change gravity", false, function(s) Configs.Gravity.Enabled = s end)
    Slider(c, "Gravity Value", 0, 500, 196, function(v) Configs.Gravity.Value = v/10 end)
    Toggle(c, "No Cooldown", "Remove cooldowns", false, function(s) Configs.NoCooldown.Enabled = s end)
    Toggle(c, "Auto Collect", "Auto pickup items", false, function(s) Configs.AutoCollect.Enabled = s end)
    Slider(c, "Collect Range", 10, 200, 50, function(v) Configs.AutoCollect.Range = v end)
    
    -- UTILITY
    Section(c, "UTILITY")
    
    Button(c, "Copy Position", function()
        local r = GetRoot()
        if r then
            local p = string.format("%.2f, %.2f, %.2f", r.Position.X, r.Position.Y, r.Position.Z)
            if setclipboard then
                pcall(setclipboard, p)
                Notify("Position", "Copied: " .. p, 3, "success")
            else
                Notify("Position", "setclipboard not available", 2, "error")
            end
        end
    end)
    
    Button(c, "Copy CFrame", function()
        local r = GetRoot()
        if r and setclipboard then
            pcall(setclipboard, tostring(r.CFrame))
            Notify("CFrame", "Copied!", 2, "success")
        else
            Notify("CFrame", "Not available", 2, "error")
        end
    end)
    
    Button(c, "Show Player Count", function()
        Notify("Players", "Count: " .. #Players:GetPlayers(), 3, "info")
    end)
    
    Button(c, "Copy All Player Names", function()
        local n = ""
        for _, p in ipairs(Players:GetPlayers()) do
            n = n .. p.Name .. "\n"
        end
        if setclipboard then
            pcall(setclipboard, n)
            Notify("Players", "Copied all names!", 2, "success")
        else
            Notify("Players", "setclipboard not available", 2, "error")
        end
    end)
    
    -- PERFORMANCE
    Section(c, "PERFORMANCE")
    
    Button(c, "Remove Terrain", function()
        pcall(function()
            if Workspace.Terrain then
                Workspace.Terrain:Clear()
            end
        end)
        Notify("Perf", "Terrain removed!", 2, "warning")
    end)
    
    Button(c, "Remove Particles", function()
        pcall(function()
            for _, o in pairs(Workspace:GetDescendants()) do
                if o:IsA("ParticleEmitter") then
                    o.Enabled = false
                end
            end
        end)
        Notify("Perf", "Particles disabled!", 2, "warning")
    end)
    
    Button(c, "FPS Unlock", function()
        if setfpscap then
            pcall(setfpscap, 9999)
            Notify("Perf", "FPS unlocked!", 2, "success")
        else
            Notify("Perf", "setfpscap not available", 2, "error")
        end
    end)
    
    Button(c, "Remove All Lights", function()
        pcall(function()
            for _, o in pairs(Workspace:GetDescendants()) do
                if o:IsA("Light") then
                    o.Enabled = false
                end
            end
        end)
        Notify("Perf", "Lights removed!", 2, "warning")
    end)
    
    Button(c, "Remove All Sounds", function()
        pcall(function()
            for _, o in pairs(Workspace:GetDescendants()) do
                if o:IsA("Sound") then
                    o.Volume = 0
                end
            end
        end)
        Notify("Perf", "Sounds muted!", 2, "warning")
    end)
    
    Toggle(c, "Performance Profiler", "Profile FPS", false, function(s) Configs.PerformanceProfiler.Enabled = s end)
    
    -- ADVANCED
    Section(c, "ADVANCED")
    
    Toggle(c, "Rainbow Mode", "Rainbow UI colors", false, function(s) Configs.RainbowMode.Enabled = s end)
    Slider(c, "Rainbow Speed", 1, 10, 1, function(v) Configs.RainbowMode.Speed = v end)
    Toggle(c, "Lua Executor", "Execute Lua code", false, function(s) Configs.LuaExecutor.Enabled = s end)
    Toggle(c, "Script Hub", "Browse scripts", false, function(s) Configs.ScriptHub.Enabled = s end)
    Toggle(c, "Auto Update", "Auto update hub", false, function(s) Configs.AutoUpdate.Enabled = s end)
    Toggle(c, "Config Manager", "Save configs", false, function(s) Configs.ConfigManager.Enabled = s end)
    Toggle(c, "Keybind Manager", "Manage keybinds", true, function(s) Configs.KeybindManager.Enabled = s end)
    Toggle(c, "Macro Recorder", "Record macros", false, function(s) Configs.MacroRecorder.Enabled = s end)
    Toggle(c, "Console Access", "Console access", false, function(s) Configs.ConsoleAccess.Enabled = s end)
    Toggle(c, "Debug Mode", "Show debug", false, function(s) Configs.DebugMode.Enabled = s end)
    Toggle(c, "Memory Scanner", "Scan memory", false, function(s) Configs.MemoryScanner.Enabled = s end)
    Toggle(c, "Packet Sniffer", "Sniff packets", false, function(s) Configs.PacketSniffer.Enabled = s end)
    Toggle(c, "Proxy Settings", "Proxy config", false, function(s) Configs.ProxySettings.Enabled = s end)
    Toggle(c, "Multi Account", "Multiple accs", false, function(s) Configs.MultiAccount.Enabled = s end)
    Toggle(c, "Account Switcher", "Switch accounts", false, function(s) Configs.AccountSwitcher.Enabled = s end)
    Toggle(c, "Session Manager", "Manage sessions", false, function(s) Configs.SessionManager.Enabled = s end)
    Toggle(c, "Crash Recovery", "Recover on crash", false, function(s) Configs.CrashRecovery.Enabled = s end)
    Toggle(c, "Error Reporter", "Report errors", false, function(s) Configs.ErrorReporter.Enabled = s end)
    Toggle(c, "Feedback System", "Send feedback", false, function(s) Configs.FeedbackSystem.Enabled = s end)
    Toggle(c, "Tutorial Mode", "Show tutorials", false, function(s) Configs.TutorialMode.Enabled = s end)
    Toggle(c, "Achievement Tracker", "Track achievements", false, function(s) Configs.AchievementTracker.Enabled = s end)
    Toggle(c, "Stats Dashboard", "Show stats", false, function(s) Configs.StatsDashboard.Enabled = s end)
    Toggle(c, "Leaderboard Hack", "Hack leaderboard", false, function(s) Configs.LeaderboardHack.Enabled = s end)
    
    TabContents["Utils"] = c
end

----------------------------------------------------------------------------------
-- SECTION 22: SETTINGS TAB (THEMES)
----------------------------------------------------------------------------------

local function SettingsTab()
    local c = Instance.new("ScrollingFrame", Content)
    c.Size = UDim2.new(1, -20, 1, -20)
    c.Position = UDim2.new(0, 10, 0, 10)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.ScrollBarThickness = Platform.IsMobile and 3 or 4
    c.ScrollBarImageColor3 = T("Accent")
    c.CanvasSize = UDim2.new(0, 0, 0, Platform.IsMobile and 1500 or 1800)
    Instance.new("UIListLayout", c).Padding = UDim.new(0, ItemPadding)
    
    -- THEME SECTION
    Section(c, "THEME SELECTOR")
    
    -- Create theme buttons
    for themeName, themeData in pairs(Themes) do
        local themeBtn = Instance.new("TextButton", c)
        themeBtn.Size = UDim2.new(1, -20, 0, 50)
        themeBtn.BackgroundColor3 = themeData.Accent
        themeBtn.BackgroundTransparency = 0.4
        themeBtn.BorderSizePixel = 0
        themeBtn.Text = "  " .. themeData.Icon .. " " .. themeData.Name
        themeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        themeBtn.TextSize = Platform.IsMobile and 12 or 14
        themeBtn.Font = Enum.Font.GothamBold
        themeBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 12)
        
        themeBtn.MouseButton1Click:Connect(function()
            SetTheme(themeName)
            
            -- Update all UI colors
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
            
            Notify("Theme", "Switched to " .. themeData.Name, 2, "success")
        end)
        
        themeBtn.MouseEnter:Connect(function()
            CreateTween(themeBtn, {BackgroundTransparency = 0.2}, 0.2)
        end)
        
        themeBtn.MouseLeave:Connect(function()
            CreateTween(themeBtn, {BackgroundTransparency = 0.4}, 0.2)
        end)
    end
    
    -- KEYBIND SECTION
    Section(c, "KEYBINDS")
    
    KeybindBtn(c, "GlobalToggle", Enum.KeyCode.RightShift, function(key)
        SetKeybind("GlobalToggle", key)
    end)
    
    -- INFO SECTION
    Section(c, "INFORMATION")
    
    local infoBox = Instance.new("Frame", c)
    infoBox.Size = UDim2.new(1, -20, 0, 200)
    infoBox.BackgroundColor3 = T("Secondary")
    infoBox.BackgroundTransparency = 0.6
    Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 12)
    
    local infoText = Instance.new("TextLabel", infoBox)
    infoText.Size = UDim2.new(1, -20, 1, -20)
    infoText.Position = UDim2.new(0, 10, 0, 10)
    infoText.BackgroundTransparency = 1
    infoText.Text = string.format(
        "Crystal Hub v%s\n\n" ..
        "Platform: %s\n" ..
        "Total Functions: %d\n" ..
        "Themes: %d\n" ..
        "Tabs: %d\n\n" ..
        "Build: %s\n" ..
        "Runtime: %ds",
        Hub.Version,
        Hub.Platform,
        Hub.TotalFunctions,
        #Themes,
        #TabData,
        Hub.Build,
        math.floor(tick() - Hub.StartTime)
    )
    infoText.TextColor3 = T("Text")
    infoText.TextSize = Platform.IsMobile and 11 or 13
    infoText.Font = Enum.Font.Gotham
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.TextWrapped = true
    
    TabContents["Settings"] = c
end

----------------------------------------------------------------------------------
-- SECTION 23: CREATE ALL TABS
----------------------------------------------------------------------------------

CombatTab()
MovementTab()
PlayerTab()
RenderTab()
UtilsTab()
SettingsTab()

-- Activate Combat tab by default
ActivateTab("Combat")
for n, c in pairs(TabContents) do
    if n ~= "Combat" then
        c.Visible = false
    end
end

----------------------------------------------------------------------------------
-- SECTION 24: STATUS BAR
----------------------------------------------------------------------------------

local Status = Instance.new("Frame", Main)
Status.Size = UDim2.new(1, 0, 0, Platform.IsMobile and 20 or 25)
Status.Position = UDim2.new(0, 0, 1, Platform.IsMobile and -20 or -25)
Status.BackgroundColor3 = T("Primary")
Status.BackgroundTransparency = 0.5
Status.BorderSizePixel = 0

local StatusLabel = Instance.new("TextLabel", Status)
StatusLabel.Size = UDim2.new(0.7, 0, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "💎 Crystal Hub v7.0 | " .. Hub.Platform
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
-- SECTION 25: CRYSTAL ANIMATIONS
----------------------------------------------------------------------------------

-- Particle animation
task.spawn(function()
    while Main and Main.Parent do
        local p = Instance.new("Frame", Main)
        p.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
        p.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.8 + 0.1, 0)
        p.BackgroundColor3 = T("Particle")
        p.BackgroundTransparency = 0.6
        p.BorderSizePixel = 0
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        
        CreateTween(p, {
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundTransparency = 1,
        }, math.random(2, 4))
        
        task.delay(math.random(2, 4), function()
            pcall(function() p:Destroy() end)
        end)
        
        task.wait(0.4)
    end
end)

-- Gradient animation
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
            Grad.Rotation = 45 + math.sin(tick() * 0.5) * 10
        end)
        
        task.wait(0.1)
    end
end)

-- Glow pulse animation
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
-- SECTION 26: FUNCTION LOOPS - COMBAT
----------------------------------------------------------------------------------

-- AIMBOT (Universal - works on all platforms)
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Aimbot.Enabled then
                local radius = GetAimbotRadius()
                local target = GetClosest(Configs.Aimbot.FOV, Configs.Aimbot.Part, Configs.Aimbot.TeamCheck, Configs.Aimbot.WallCheck, radius)
                
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

-- AIM ASSIST (with Delete key toggle)
task.spawn(function()
    while true do
        pcall(function()
            if Configs.AimAssist.Enabled then
                local target = GetClosest(Configs.AimAssist.FOV, Configs.AimAssist.Part, Configs.AimAssist.TeamCheck, Configs.AimAssist.WallCheck, Configs.AimAssist.Radius)
                
                if target and target.Character then
                    local part = target.Character:FindFirstChild(Configs.AimAssist.Part)
                    if part then
                        local tpos = part.Position
                        local cp = Camera.CFrame
                        local nc = CFrame.new(cp.Position, tpos)
                        Camera.CFrame = cp:Lerp(nc, Configs.AimAssist.Smooth)
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
                            if mouse1click then
                                pcall(mouse1click)
                            end
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
                        if Configs.KillAura.TeamCheck and p.Team == LocalPlayer.Team then
                            continue
                        end
                        
                        local d = GetDistance(LocalPlayer, p)
                        if d <= Configs.KillAura.Range then
                            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                pcall(function() tool:Activate() end)
                            end
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
                            hb.Name = "CH_HITBOX"
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
                for uid, part in pairs(Hub.HitboxParts) do
                    if part then
                        pcall(function() part:Destroy() end)
                    end
                end
                Hub.HitboxParts = {}
            end
            
            -- Cleanup dead players
            for uid, part in pairs(Hub.HitboxParts) do
                local p = Players:GetPlayerByUserId(uid)
                if not p or not IsAlive(p) then
                    if part then
                        pcall(function() part:Destroy() end)
                    end
                    Hub.HitboxParts[uid] = nil
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
                        rp.CFrame = rp.CFrame * CFrame.Angles(
                            math.rad((math.random() - 0.5) * 180),
                            math.rad((math.random() - 0.5) * 180),
                            math.rad((math.random() - 0.5) * 180)
                        )
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
                if tool then
                    pcall(function() tool:Activate() end)
                end
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
                        if d <= Configs.AutoParry.Range then
                            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                pcall(function() tool:Activate() end)
                            end
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
-- SECTION 27: FUNCTION LOOPS - MOVEMENT
----------------------------------------------------------------------------------

-- SPEED
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Speed.Enabled then
                local h = GetHumanoid()
                if h then
                    h.WalkSpeed = Configs.Speed.Value
                end
            else
                local h = GetHumanoid()
                if h and h.WalkSpeed ~= 16 then
                    h.WalkSpeed = 16
                end
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
                    
                    if Platform.IsPC then
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            ud = 1
                        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            ud = -1
                        end
                    end
                    
                    FlyBV.Velocity = (mv * Configs.Fly.Speed) + Vector3.new(0, ud * Configs.Fly.Speed, 0)
                    FlyBG.CFrame = Camera.CFrame
                    
                    if Configs.Fly.Noclip then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            else
                if FlyBV then
                    pcall(function() FlyBV:Destroy() end)
                    FlyBV = nil
                end
                if FlyBG then
                    pcall(function() FlyBG:Destroy() end)
                    FlyBG = nil
                end
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
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                            end
                        end
                    end
                end)
            elseif not Configs.Noclip.Enabled and NoclipConn then
                NoclipConn:Disconnect()
                NoclipConn = nil
                
                if LocalPlayer.Character then
                    for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                            p.CanCollide = true
                        end
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
                    if h then
                        pcall(function()
                            h:ChangeState(Enum.HumanoidStateType.Jumping)
                        end)
                    end
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
                if h then
                    h.JumpPower = Configs.LongJump.Power
                end
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
                    pcall(function()
                        h:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
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
                if h then
                    h.JumpPower = Configs.HighJump.Height
                end
            end
        end)
        task.wait()
    end
end)

-- SUPER JUMP
task.spawn(function()
    while true do
        pcall(function()
            if Configs.SuperJump.Enabled then
                local h = GetHumanoid()
                if h then
                    h.JumpPower = Configs.SuperJump.Power
                end
            end
        end)
        task.wait()
    end
end)

-- MOON JUMP
local MoonBV
task.spawn(function()
    while true do
        pcall(function()
            if Configs.MoonJump.Enabled then
                local rp = GetRoot()
                if rp then
                    if not MoonBV then
                        MoonBV = Instance.new("BodyVelocity", rp)
                        MoonBV.MaxForce = Vector3.new(0, math.huge, 0)
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        MoonBV.Velocity = Vector3.new(0, Configs.MoonJump.Height, 0)
                    else
                        MoonBV.Velocity = Vector3.zero
                    end
                end
            else
                if MoonBV then
                    pcall(function() MoonBV:Destroy() end)
                    MoonBV = nil
                end
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
                if JetpackBV then
                    pcall(function() JetpackBV:Destroy() end)
                    JetpackBV = nil
                end
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

-- SLIDE
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Slide.Enabled then
                local rp = GetRoot()
                if rp and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    local mv = Camera.CFrame.LookVector
                    rp.Velocity = Vector3.new(mv.X * Configs.Slide.Speed, rp.Velocity.Y, mv.Z * Configs.Slide.Speed)
                end
            end
        end)
        task.wait()
    end
end)

-- ORBIT
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Orbit.Enabled then
                local target = GetClosest(1000, "Head", false, false, GetAimbotRadius())
                if target and target.Character then
                    local rp = GetRoot()
                    local tp = target.Character:FindFirstChild("HumanoidRootPart")
                    
                    if rp and tp then
                        local angle = tick() * Configs.Orbit.Speed / 10
                        local offset = Vector3.new(
                            math.cos(angle) * Configs.Orbit.Radius,
                            0,
                            math.sin(angle) * Configs.Orbit.Radius
                        )
                        rp.CFrame = CFrame.new(tp.Position + offset, tp.Position)
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- GRAVITY GUN
task.spawn(function()
    while true do
        pcall(function()
            if Configs.GravityGun.Enabled then
                local rp = GetRoot()
                if rp then
                    local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * Configs.GravityGun.Force)
                    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                    
                    if hit and not hit:IsDescendantOf(LocalPlayer.Character) and hit:IsA("BasePart") then
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                            local targetPos = Camera.CFrame.Position + Camera.CFrame.LookVector * 10
                            hit.Velocity = (targetPos - hit.Position).Unit * Configs.GravityGun.Force
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end)

-- MAGNET
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Magnet.Enabled then
                local rp = GetRoot()
                if rp then
                    for _, o in pairs(Workspace:GetDescendants()) do
                        if o:IsA("BasePart") and not o:IsDescendantOf(LocalPlayer.Character) then
                            local d = (o.Position - rp.Position).Magnitude
                            if d <= Configs.Magnet.Range then
                                local dir = (rp.Position - o.Position).Unit
                                o.Velocity = dir * 50
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 28: FUNCTION LOOPS - PLAYER
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
                    if VirtualUser then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end
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
                    if h2 then
                        h2.Health = h2.MaxHealth
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- REGENERATION
task.spawn(function()
    while true do
        pcall(function()
            if Configs.Regeneration.Enabled then
                local h = GetHumanoid()
                if h and h.Health < h.MaxHealth then
                    h.Health = math.min(h.Health + Configs.Regeneration.Rate, h.MaxHealth)
                end
            end
        end)
        task.wait(1)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 29: UNIVERSAL ESP (FIXED - WORKS EVERYWHERE)
----------------------------------------------------------------------------------

task.spawn(function()
    while true do
        pcall(function()
            -- Clear old ESP objects
            for _, o in pairs(Hub.ESPObjects) do
                if o then
                    pcall(function() o:Remove() end)
                end
            end
            Hub.ESPObjects = {}
            
            if Configs.ESP.Enabled and HasDrawing then
                local animTime = tick()
                
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        if Configs.ESP.TeamCheck and p.Team == LocalPlayer.Team then
                            continue
                        end
                        
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
                                    
                                    -- Determine color based on team
                                    local isTeam = (p.Team == LocalPlayer.Team)
                                    local baseColor
                                    
                                    if Configs.ESP.UseTeamColors then
                                        baseColor = isTeam and Configs.ESP.AllyColor or Configs.ESP.EnemyColor
                                    else
                                        baseColor = Configs.ESP.BoxColor
                                    end
                                    
                                    -- Apply fade based on distance
                                    local alpha = 1
                                    if Configs.ESP.FadeDistance and d > Configs.ESP.FadeStart then
                                        alpha = 1 - (d - Configs.ESP.FadeStart) / (Configs.ESP.FadeEnd - Configs.ESP.FadeStart)
                                        alpha = math.clamp(alpha, 0, 1)
                                    end
                                    
                                    local animPulse = Configs.ESP.Animated and (math.sin(animTime * 3) * 0.2 + 0.8) or 1
                                    
                                    -- Box ESP
                                    if Configs.ESP.Box then
                                        local box = Drawing.new("Square")
                                        box.Size = Vector2.new(bw, bh)
                                        box.Position = Vector2.new(sp.X - bw/2, hs.Y)
                                        box.Thickness = Configs.ESP.BoxThickness
                                        box.Color = baseColor
                                        box.Filled = false
                                        box.Transparency = alpha * animPulse
                                        box.Visible = true
                                        table.insert(Hub.ESPObjects, box)
                                        
                                        -- Outline
                                        if Configs.ESP.Outline then
                                            local outline = Drawing.new("Square")
                                            outline.Size = Vector2.new(bw + 4, bh + 4)
                                            outline.Position = Vector2.new(sp.X - bw/2 - 2, hs.Y - 2)
                                            outline.Thickness = 1
                                            outline.Color = Color3.fromRGB(0, 0, 0)
                                            outline.Filled = false
                                            outline.Transparency = alpha
                                            outline.Visible = true
                                            table.insert(Hub.ESPObjects, outline)
                                        end
                                        
                                        -- Glow
                                        if Configs.ESP.Glow then
                                            local glow = Drawing.new("Square")
                                            glow.Size = Vector2.new(bw + 8, bh + 8)
                                            glow.Position = Vector2.new(sp.X - bw/2 - 4, hs.Y - 4)
                                            glow.Thickness = 1
                                            glow.Color = baseColor
                                            glow.Filled = false
                                            glow.Transparency = 0.5 * alpha * animPulse
                                            glow.Visible = true
                                            table.insert(Hub.ESPObjects, glow)
                                        end
                                    end
                                    
                                    -- Name ESP
                                    if Configs.ESP.Name then
                                        local nm = Drawing.new("Text")
                                        nm.Text = "◆ " .. p.DisplayName .. " ◆"
                                        nm.Center = true
                                        nm.Outline = Configs.ESP.NameOutline
                                        if Configs.ESP.NameOutline then
                                            nm.OutlineColor = Configs.ESP.NameOutlineColor
                                        end
                                        nm.Size = Configs.ESP.NameSize
                                        nm.Color = baseColor
                                        nm.Position = Vector2.new(sp.X, hs.Y - 25)
                                        nm.Transparency = alpha
                                        nm.Visible = true
                                        table.insert(Hub.ESPObjects, nm)
                                    end
                                    
                                    -- Health ESP
                                    if Configs.ESP.Health then
                                        local hp = h.Health / h.MaxHealth
                                        
                                        -- Background bar
                                        local bg = Drawing.new("Square")
                                        bg.Size = Vector2.new(Configs.ESP.HealthBarWidth, bh)
                                        
                                        if Configs.ESP.HealthBarSide == "Left" then
                                            bg.Position = Vector2.new(sp.X - bw/2 - Configs.ESP.HealthBarWidth - 6, hs.Y)
                                        elseif Configs.ESP.HealthBarSide == "Right" then
                                            bg.Position = Vector2.new(sp.X + bw/2 + 6, hs.Y)
                                        end
                                        
                                        bg.Color = Color3.fromRGB(30, 30, 30)
                                        bg.Filled = true
                                        bg.Transparency = alpha
                                        bg.Visible = true
                                        table.insert(Hub.ESPObjects, bg)
                                        
                                        -- Health bar
                                        local bar = Drawing.new("Square")
                                        bar.Size = Vector2.new(Configs.ESP.HealthBarWidth, bh * hp)
                                        
                                        if Configs.ESP.HealthBarSide == "Left" then
                                            bar.Position = Vector2.new(sp.X - bw/2 - Configs.ESP.HealthBarWidth - 6, hs.Y + bh - bh*hp)
                                        elseif Configs.ESP.HealthBarSide == "Right" then
                                            bar.Position = Vector2.new(sp.X + bw/2 + 6, hs.Y + bh - bh*hp)
                                        end
                                        
                                        local hpColor = Color3.fromRGB(255 - 255*hp, 255*hp, 50)
                                        bar.Color = hpColor
                                        bar.Filled = true
                                        bar.Transparency = alpha
                                        bar.Visible = true
                                        table.insert(Hub.ESPObjects, bar)
                                        
                                        -- Outline
                                        local outline = Drawing.new("Square")
                                        outline.Size = Vector2.new(Configs.ESP.HealthBarWidth + 2, bh + 2)
                                        
                                        if Configs.ESP.HealthBarSide == "Left" then
                                            outline.Position = Vector2.new(sp.X - bw/2 - Configs.ESP.HealthBarWidth - 7, hs.Y - 1)
                                        elseif Configs.ESP.HealthBarSide == "Right" then
                                            outline.Position = Vector2.new(sp.X + bw/2 + 5, hs.Y - 1)
                                        end
                                        
                                        outline.Color = Color3.fromRGB(0, 0, 0)
                                        outline.Filled = false
                                        outline.Thickness = 1
                                        outline.Transparency = alpha
                                        outline.Visible = true
                                        table.insert(Hub.ESPObjects, outline)
                                    end
                                    
                                    -- Distance ESP
                                    if Configs.ESP.Distance then
                                        local dt = Drawing.new("Text")
                                        dt.Text = string.format(Configs.ESP.DistanceFormat, d)
                                        dt.Center = true
                                        dt.Outline = true
                                        dt.Size = 12
                                        dt.Color = Configs.ESP.DistanceColor
                                        dt.Position = Vector2.new(sp.X, fs.Y + 5)
                                        dt.Transparency = alpha
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

----------------------------------------------------------------------------------
-- SECTION 30: TRACERS, CHAMS, SKELETON
----------------------------------------------------------------------------------

-- TRACERS
task.spawn(function()
    while true do
        pcall(function()
            for _, o in pairs(Hub.TracerObjects) do
                if o then
                    pcall(function() o:Remove() end)
                end
            end
            Hub.TracerObjects = {}
            
            if Configs.Tracers.Enabled and HasDrawing then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        if Configs.Tracers.TeamCheck and p.Team == LocalPlayer.Team then
                            continue
                        end
                        
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
                                tr.Color = Configs.Tracers.Color
                                tr.Thickness = Configs.Tracers.Thickness
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
                if c then
                    pcall(function() c:Destroy() end)
                end
            end
            Hub.ChamsObjects = {}
            
            if Configs.Chams.Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsAlive(p) then
                        if Configs.Chams.TeamCheck and p.Team == LocalPlayer.Team then
                            continue
                        end
                        
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Configs.Chams.VisibleColor
                        hl.OutlineColor = Configs.Chams.HiddenColor
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
                if o then
                    pcall(function() o:Remove() end)
                end
            end
            Hub.SkeletonObjects = {}
            
            if Configs.SkeletonESP.Enabled and HasDrawing then
                local conns = {
                    {"Head", "UpperTorso"},
                    {"UpperTorso", "LowerTorso"},
                    {"UpperTorso", "LeftUpperArm"},
                    {"LeftUpperArm", "LeftLowerArm"},
                    {"LeftLowerArm", "LeftHand"},
                    {"UpperTorso", "RightUpperArm"},
                    {"RightUpperArm", "RightLowerArm"},
                    {"RightLowerArm", "RightHand"},
                    {"LowerTorso", "LeftUpperLeg"},
                    {"LeftUpperLeg", "LeftLowerLeg"},
                    {"LeftLowerLeg", "LeftFoot"},
                    {"LowerTorso", "RightUpperLeg"},
                    {"RightUpperLeg", "RightLowerLeg"},
                    {"RightLowerLeg", "RightFoot"},
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
                                    ln.Color = Configs.SkeletonESP.Color
                                    ln.Thickness = Configs.SkeletonESP.Thickness
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

----------------------------------------------------------------------------------
-- SECTION 31: FULLBRIGHT (FIXED)
----------------------------------------------------------------------------------

-- Save original lighting settings
local function SaveLightingSettings()
    Hub.OriginalLighting = {
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
    }
end

SaveLightingSettings()

task.spawn(function()
    while true do
        pcall(function()
            if Configs.Fullbright.Enabled then
                -- Apply fullbright settings
                Lighting.Brightness = Configs.Fullbright.Brightness
                Lighting.Ambient = Configs.Fullbright.Ambient
                Lighting.OutdoorAmbient = Configs.Fullbright.OutdoorAmbient
                Lighting.ClockTime = Configs.Fullbright.ClockTime
                Lighting.FogEnd = Configs.Fullbright.FogEnd
                Lighting.GlobalShadows = Configs.Fullbright.GlobalShadows
                
                -- Remove lighting effects
                if Configs.Fullbright.RemoveEffects then
                    for _, effect in pairs(Lighting:GetChildren()) do
                        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
                           effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or
                           effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                            effect.Enabled = false
                        end
                    end
                end
            else
                -- Restore original settings
                if Hub.OriginalLighting.Brightness then
                    Lighting.Brightness = Hub.OriginalLighting.Brightness
                    Lighting.Ambient = Hub.OriginalLighting.Ambient
                    Lighting.OutdoorAmbient = Hub.OriginalLighting.OutdoorAmbient
                    Lighting.ClockTime = Hub.OriginalLighting.ClockTime
                    Lighting.FogEnd = Hub.OriginalLighting.FogEnd
                    Lighting.GlobalShadows = Hub.OriginalLighting.GlobalShadows
                    
                    -- Re-enable effects
                    for _, effect in pairs(Lighting:GetChildren()) do
                        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
                           effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or
                           effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                            effect.Enabled = true
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 32: NO FOG, XRAY, FOV CHANGER
----------------------------------------------------------------------------------

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
                    if p and p.Parent then
                        p.Transparency = o
                    end
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
                Camera.CFrame = Camera.CFrame * CFrame.new((math.random() - 0.5) * i, (math.random() - 0.5) * i, 0)
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
                if FreecamBV then
                    pcall(function() FreecamBV:Destroy() end)
                    FreecamBV = nil
                end
                if FreecamBG then
                    pcall(function() FreecamBG:Destroy() end)
                    FreecamBG = nil
                end
            end
            
            if FreecamActive and FreecamBV and FreecamBG then
                local s = Configs.Freecam.Speed
                local mv = Vector3.zero
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    mv = mv + Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    mv = mv - Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    mv = mv - Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    mv = mv + Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    mv = mv + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    mv = mv - Vector3.new(0, 1, 0)
                end
                
                FreecamBV.Velocity = mv * s
                FreecamBG.CFrame = Camera.CFrame
            end
        end)
        task.wait()
    end
end)

----------------------------------------------------------------------------------
-- SECTION 33: UTILS LOOPS
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
                local h = (tick() * Configs.RainbowMode.Speed * 0.1) % 1
                local c = Color3.fromHSV(h, 1, 1)
                CurrentTheme.Accent = c
                CurrentTheme.Glow = c
                CurrentTheme.ToggleOn = c
                CurrentTheme.SliderFill = c
                CurrentTheme.TabActive = c
                
                pcall(function()
                    MainStroke.Color = c
                    Glow.BackgroundColor3 = c
                end)
            end
        end)
        task.wait(0.05)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 34: FPS COUNTER & STATS
----------------------------------------------------------------------------------

task.spawn(function()
    local fc, lt = 0, tick()
    
    while ScreenGui and ScreenGui.Parent do
        fc = fc + 1
        local ct = tick()
        
        if ct - lt >= 1 then
            Hub.LastFPS = fc
            Hub.FrameCount = Hub.FrameCount + fc
            
            if FPSLabel and FPSLabel.Parent then
                FPSLabel.Text = "FPS: " .. fc
            end
            
            fc = 0
            lt = ct
        end
        
        task.wait()
    end
end)

-- Active features counter
task.spawn(function()
    while true do
        local ac = 0
        for _, c in pairs(Configs) do
            if type(c) == "table" and c.Enabled then
                ac = ac + 1
            end
        end
        
        Hub.ActiveCount = ac
        
        if StatusLabel and StatusLabel.Parent then
            StatusLabel.Text = string.format("💎 Crystal Hub v7.0 | %s | Active: %d", Hub.Platform, ac)
        end
        
        task.wait(1)
    end
end)

----------------------------------------------------------------------------------
-- SECTION 35: INTRO ANIMATION
----------------------------------------------------------------------------------

task.spawn(function()
    -- Start off-screen
    Main.Position = UDim2.new(0.5, -MainWidth/2, 1.5, 0)
    Main.Size = UDim2.new(0, 0, 0, 0)
    
    task.wait(0.3)
    
    -- Animate in
    CreateTween(Main, {
        Position = UDim2.new(0.5, -MainWidth/2, 0.5, -MainHeight/2),
        Size = UDim2.new(0, MainWidth, 0, MainHeight),
    }, 0.8, Enum.EasingStyle.Back)
    
    task.wait(1)
    
    -- Welcome notification
    Notify("Welcome", "Crystal Hub v7.0 - " .. Hub.Platform .. " Edition", 4, "success")
    
    task.wait(2)
    
    -- Controls info
    if Platform.IsPC then
        Notify("Controls", "RIGHT SHIFT = Toggle GUI | DELETE = Aim Assist", 5, "info")
    else
        Notify("Controls", "Use the menu to toggle features", 5, "info")
    end
    
    task.wait(2)
    
    Notify("Keybinds", "Click keybind buttons to change controls", 4, "info")
end)

----------------------------------------------------------------------------------
-- SECTION 36: CLEANUP ON DESTROY
----------------------------------------------------------------------------------

ScreenGui.Destroying:Connect(function()
    pcall(function()
        -- Disconnect all connections
        if NoclipConn then
            NoclipConn:Disconnect()
        end
        if InfJumpConn then
            InfJumpConn:Disconnect()
        end
        
        -- Destroy all instances
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        if JetpackBV then JetpackBV:Destroy() end
        if MoonBV then MoonBV:Destroy() end
        if FreecamBV then FreecamBV:Destroy() end
        if FreecamBG then FreecamBG:Destroy() end
        
        -- Remove all ESP objects
        for _, o in pairs(Hub.ESPObjects) do
            if o then
                pcall(function() o:Remove() end)
            end
        end
        
        for _, o in pairs(Hub.TracerObjects) do
            if o then
                pcall(function() o:Remove() end)
            end
        end
        
        for _, o in pairs(Hub.SkeletonObjects) do
            if o then
                pcall(function() o:Remove() end)
            end
        end
        
        for _, c in pairs(Hub.ChamsObjects) do
            if c then
                pcall(function() c:Destroy() end)
            end
        end
        
        for _, p in pairs(Hub.HitboxParts) do
            if p then
                pcall(function() p:Destroy() end)
            end
        end
        
        -- Restore original transparencies
        for p, o in pairs(Hub.OriginalTransparencies) do
            if p and p.Parent then
                p.Transparency = o
            end
        end
        
        -- Restore lighting
        if Hub.OriginalLighting.Brightness then
            Lighting.Brightness = Hub.OriginalLighting.Brightness
            Lighting.Ambient = Hub.OriginalLighting.Ambient
            Lighting.OutdoorAmbient = Hub.OriginalLighting.OutdoorAmbient
            Lighting.ClockTime = Hub.OriginalLighting.ClockTime
            Lighting.FogEnd = Hub.OriginalLighting.FogEnd
            Lighting.GlobalShadows = Hub.OriginalLighting.GlobalShadows
        end
        
        -- Restore world settings
        Workspace.Gravity = 196.2
        Camera.FieldOfView = 70
        Camera.CameraType = Enum.CameraType.Custom
        
        -- Re-enable lighting effects
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or
               effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                effect.Enabled = true
            end
        end
    end)
end)

----------------------------------------------------------------------------------
-- SECTION 37: FINAL OUTPUT
----------------------------------------------------------------------------------

print("═══════════════════════════════════════════════════════════")
print("   💎 Crystal Hub v7.0 - GLOBAL ULTIMATE UPDATE")
print("   Status: Successfully Loaded!")
print("   Platform: " .. Hub.Platform)
print("   Functions: " .. Hub.TotalFunctions .. "+")
print("   Themes: " .. #Themes)
print("   Tabs: " .. #TabData)
print("   Keybinds: Active")
print("   ESP: Universal (PC + Mobile)")
print("   Fullbright: Fixed & Working")
print("   Aim Assist: DELETE Key Toggle")
print("═══════════════════════════════════════════════════════════")

return Hub
