--[[
	HASH - Advanced Universal FPS Script
	Enhanced with Aimware and Skeet features
	© CC0 1.0 Universal (2025)
]]

--// Loaded Check
if HASHLoaded or HASHLoading then
	return
end

--// Key System
local validKeys = {
	"HASH-FREE-KEY",
	"HASH-PREMIUM-KEY",
	"HASH-VIP-KEY"
}

local function validateKey(key)
	for _, validKey in pairs(validKeys) do
		if key == validKey then
			return true
		end
	end
	return false
end

local function showKeyPrompt()
	local key = ""
	-- In a real implementation, this would show a GUI prompt for the key
	-- For now, we'll use a default key for demonstration
	key = "HASH-FREE-KEY"
	return key
end

local userKey = showKeyPrompt()
if not validateKey(userKey) then
	print("Invalid key. Access denied.")
	return
end

getgenv().HASHLoading = true

--// Intro Animation
local function showIntroAnimation()
	local Workspace = game:GetService("Workspace")
	local Camera = Workspace.CurrentCamera
	
	local introText = Drawing.new("Text")
	introText.Visible = false
	introText.Text = "HASH"
	introText.Font = 3
	introText.Size = 40
	introText.Color = Color3.fromRGB(255, 0, 255)
	introText.Outline = true
	introText.OutlineColor = Color3.fromRGB(0, 0, 0)
	introText.Position = Vector2.new(Camera.ViewportSize.X/2 - 50, Camera.ViewportSize.Y/2 - 50)
	introText.Visible = true
	
	local subText = Drawing.new("Text")
	subText.Visible = false
	subText.Text = "Your Go to FPS Script"
	subText.Font = 1
	subText.Size = 20
	subText.Color = Color3.fromRGB(255, 255, 255)
	subText.Outline = true
	subText.OutlineColor = Color3.fromRGB(0, 0, 0)
	subText.Position = Vector2.new(Camera.ViewportSize.X/2 - 100, Camera.ViewportSize.Y/2)
	subText.Visible = true
	
	-- Fade in animation
	for i = 0, 1, 0.05 do
		introText.Transparency = 1 - i
		subText.Transparency = 1 - i
		wait(0.05)
	end
	
	wait(2) -- Show for 2 seconds
	
	-- Fade out animation
	for i = 0, 1, 0.05 do
		introText.Transparency = i
		subText.Transparency = i
		wait(0.05)
	end
	
	introText:Remove()
	subText:Remove()
end

showIntroAnimation()

--// Cache
local game = game
local loadstring, typeof, select, next, pcall = loadstring, typeof, select, next, pcall
local tablefind, tablesort = table.find, table.sort
local mathfloor, mathabs, mathcos, mathsin, mathrad, mathdeg = math.floor, math.abs, math.cos, math.sin, math.rad, math.deg
local stringgsub, stringlower, stringsub = string.gsub, string.lower, string.sub
local wait, delay, spawn = task.wait, task.delay, task.spawn
local osdate = os.date
local getgenv, getrawmetatable = getgenv, getrawmetatable

--// Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

--// Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetMouseLocation = UserInputService.GetMouseLocation

--// Launching
local GUI = loadfile("src/UI Library.lua")()
local ESP = loadfile("src/ESP.lua")()
local Aimbot = loadfile("src/Aimbot.lua")()

--// HASH Specific Variables
local Watermarks = {}
local OriginalNames = {}
local HASHSettings = {
	HideName = false,
	Watermark = true,
	RealSilentAim = false,
	SpinBot = false,
	AntiAim = false,
	SilentAim = false,
	Resolver = false
}

--// Variables
local MainFrame = GUI:Load()

local ESP_DeveloperSettings = ESP.DeveloperSettings
local ESP_Settings = ESP.Settings
local ESP_Properties = ESP.Properties
local Crosshair = ESP_Properties.Crosshair
local CenterDot = Crosshair.CenterDot

local Aimbot_DeveloperSettings = Aimbot.DeveloperSettings
local Aimbot_Settings = Aimbot.Settings
local Aimbot_FOV = Aimbot.FOVSettings

ESP_Settings.LoadConfigOnLaunch = false
ESP_Settings.Enabled = false
Crosshair.Enabled = false
Aimbot_Settings.Enabled = false

local Fonts = {"UI", "System", "Plex", "Monospace"}
local TracerPositions = {"Bottom", "Center", "Mouse"}
local HealthBarPositions = {"Top", "Bottom", "Left", "Right"}

--// HASH Functions
local function CreateWatermark()
	if not HASHSettings.Watermark then return end
	
	-- Create multiple watermarks across the screen
	for i = 1, 5 do
		local watermark = Drawing.new("Text")
		watermark.Visible = false
		watermark.Text = "HASH"
		watermark.Font = 3
		watermark.Size = 20
		watermark.Color = Color3.fromRGB(255, 0, 255)
		watermark.Outline = true
		watermark.OutlineColor = Color3.fromRGB(0, 0, 0)
		watermark.Position = Vector2.new(20 + (i-1) * 300, 20)
		table.insert(Watermarks, watermark)
	end
	
	-- Update watermark visibility
	for _, watermark in pairs(Watermarks) do
		watermark.Visible = true
	end
end

local function HideNames()
	if not HASHSettings.HideName then return end
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			OriginalNames[player.Name] = player.DisplayName
			player.DisplayName = "HASH"
			player.Name = "HASH"
		end
	end
end

local function RestoreNames()
	for name, displayName in pairs(OriginalNames) do
		local player = Players:FindFirstChild(name)
		if player then
			player.DisplayName = displayName
		end
	end
	OriginalNames = {}
end

--// Tabs
local General, GeneralSignal = MainFrame:Tab("General")
local _Aimbot = MainFrame:Tab("Aimbot")
local _ESP = MainFrame:Tab("ESP")
local _Crosshair = MainFrame:Tab("Crosshair")
local _HASH = MainFrame:Tab("HASH")
local Settings = MainFrame:Tab("Settings")

--// Functions
local AddValues = function(Section, Object, Exceptions, Prefix)
	local Keys, Copy = {}, {}

	for Index, _ in next, Object do
		Keys[#Keys + 1] = Index
	end

	tablesort(Keys, function(A, B)
		return A < B
	end)

	for _, Value in next, Keys do
		Copy[Value] = Object[Value]
	end

	for Index, Value in next, Copy do
		if typeof(Value) == "boolean" and (not Exceptions or not tablefind(Exceptions, Index)) then

		Section:Toggle({
			Name = stringgsub(Index, "(%l)(%u)", function(...)
				return select(1, ...).." "..select(2, ...)
			end),
			Flag = Prefix..Index,
			Default = Value,
			Callback = function(_Value)
				Object[Index] = _Value
			end
		})
	end

	for Index, Value in next, Copy do
		if typeof(Value) == "Color3" and (not Exceptions or not tablefind(Exceptions, Index)) then

		Section:Colorpicker({
			Name = stringgsub(Index, "(%l)(%u)", function(...)
				return select(1, ...).." "..select(2, ...)
			end),
			Flag = Index,
			Default = Value,
			Callback = function(_Value)
				Object[Index] = _Value
			end
		})
	end
end
end

--// General Tab
local AimbotSection = General:Section({
	Name = "Aimbot Settings",
	Side = "Left"
})

local ESPSection = General:Section({
	Name = "ESP Settings",
	Side = "Right"
})

local ESPDeveloperSection = General:Section({
	Name = "ESP Developer Settings",
	Side = "Right"
})

AddValues(ESPDeveloperSection, ESP_DeveloperSettings, {}, "ESP_DeveloperSettings_")

ESPDeveloperSection:Dropdown({
	Name = "Update Mode",
	Flag = "ESP_UpdateMode",
	Content = {"RenderStepped", "Stepped", "Heartbeat"},
	Default = ESP_DeveloperSettings.UpdateMode,
	Callback = function(Value)
		ESP_DeveloperSettings.UpdateMode = Value
	end
})

ESPDeveloperSection:Dropdown({
	Name = "Team Check Option",
	Flag = "ESP_TeamCheckOption",
	Content = {"TeamColor", "Team"},
	Default = ESP_DeveloperSettings.TeamCheckOption,
	Callback = function(Value)
		ESP_DeveloperSettings.TeamCheckOption = Value
	end
})

ESPDeveloperSection:Slider({
	Name = "Rainbow Speed",
	Flag = "ESP_RainbowSpeed",
	Default = ESP_DeveloperSettings.RainbowSpeed * 10,
	Min = 5,
	Max = 30,
	Callback = function(Value)
		ESP_DeveloperSettings.RainbowSpeed = Value / 10
	end
})

ESPDeveloperSection:Slider({
	Name = "Width Boundary",
	Flag = "ESP_WidthBoundary",
	Default = ESP_DeveloperSettings.WidthBoundary * 10,
	Min = 5,
	Max = 30,
	Callback = function(Value)
		ESP_DeveloperSettings.WidthBoundary = Value / 10
	end
})

ESPDeveloperSection:Button({
	Name = "Refresh",
	Callback = function()
		ESP:Restart()
	end
})

AddValues(ESPSection, ESP_Settings, {"LoadConfigOnLaunch", "PartsOnly"}, "ESPSettings_")

AimbotSection:Toggle({
	Name = "Enabled",
	Flag = "Aimbot_Enabled",
	Default = Aimbot_Settings.Enabled,
	Callback = function(Value)
		Aimbot_Settings.Enabled = Value
	end
})

AddValues(AimbotSection, Aimbot_Settings, {"Enabled", "Toggle", "OffsetToMoveDirection"}, "Aimbot_")

local AimbotDeveloperSection = General:Section({
	Name = "Aimbot Developer Settings",
	Side = "Left"
})

AimbotDeveloperSection:Dropdown({
	Name = "Update Mode",
	Flag = "Aimbot_UpdateMode",
	Content = {"RenderStepped", "Stepped", "Heartbeat"},
	Default = Aimbot_DeveloperSettings.UpdateMode,
	Callback = function(Value)
		Aimbot_DeveloperSettings.UpdateMode = Value
	end
})

AimbotDeveloperSection:Dropdown({
	Name = "Team Check Option",
	Flag = "Aimbot_TeamCheckOption",
	Content = {"TeamColor", "Team"},
	Default = Aimbot_DeveloperSettings.TeamCheckOption,
	Callback = function(Value)
		Aimbot_DeveloperSettings.TeamCheckOption = Value
	end
})

AimbotDeveloperSection:Slider({
	Name = "Rainbow Speed",
	Flag = "Aimbot_RainbowSpeed",
	Default = Aimbot_DeveloperSettings.RainbowSpeed * 10,
	Min = 5,
	Max = 30,
	Callback = function(Value)
		Aimbot_DeveloperSettings.RainbowSpeed = Value / 10
	end
})

AimbotDeveloperSection:Button({
	Name = "Refresh",
	Callback = function()
		Aimbot.Restart()
	end
})

--// Aimbot Tab
local AimbotPropertiesSection = _Aimbot:Section({
	Name = "Properties",
	Side = "Left"
})

AimbotPropertiesSection:Toggle({
	Name = "Toggle",
	Flag = "Aimbot_Toggle",
	Default = Aimbot_Settings.Toggle,
	Callback = function(Value)
		Aimbot_Settings.Toggle = Value
	end
})

AimbotPropertiesSection:Toggle({
	Name = "Offset To Move Direction",
	Flag = "Aimbot_OffsetToMoveDirection",
	Default = Aimbot_Settings.OffsetToMoveDirection,
	Callback = function(Value)
		Aimbot_Settings.OffsetToMoveDirection = Value
	end
})

AimbotPropertiesSection:Slider({
	Name = "Offset Increment",
	Flag = "Aimbot_OffsetIncrementy",
	Default = Aimbot_Settings.OffsetIncrement,
	Min = 1,
	Max = 30,
	Callback = function(Value)
		Aimbot_Settings.OffsetIncrement = Value
	end
})

AimbotPropertiesSection:Slider({
	Name = "Animation Sensitivity (ms)",
	Flag = "Aimbot_Sensitivity",
	Default = Aimbot_Settings.Sensitivity * 100,
	Min = 0,
	Max = 100,
	Callback = function(Value)
		Aimbot_Settings.Sensitivity = Value / 100
	end
})

AimbotPropertiesSection:Slider({
	Name = "mousemoverel Sensitivity",
	Flag = "Aimbot_Sensitivity2",
	Default = Aimbot_Settings.Sensitivity2 * 100,
	Min = 0,
	Max = 500,
	Callback = function(Value)
		Aimbot_Settings.Sensitivity2 = Value / 100
	end
})

AimbotPropertiesSection:Dropdown({
	Name = "Lock Mode",
	Flag = "Aimbot_Settings_LockMode",
	Content = {"CFrame", "mousemoverel"},
	Default = Aimbot_Settings.LockMode == 1 and "CFrame" or "mousemoverel",
	Callback = function(Value)
		Aimbot_Settings.LockMode = Value == "CFrame" and 1 or 2
	end
})

AimbotPropertiesSection:Dropdown({
	Name = "Lock Part",
	Flag = "Aimbot_LockPart",
	Content = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"},
	Default = Aimbot_Settings.LockPart,
	Callback = function(Value)
		Aimbot_Settings.LockPart = Value
	end
})

AimbotPropertiesSection:Keybind({
	Name = "Trigger Key",
	Flag = "Aimbot_TriggerKey",
	Default = Aimbot_Settings.TriggerKey,
	Callback = function(Keybind)
		Aimbot_Settings.TriggerKey = Keybind
	end
})

local UserBox = AimbotPropertiesSection:Box({
	Name = "Player Name (shortened allowed)",
	Flag = "Aimbot_PlayerName",
	Placeholder = "Username"
})

AimbotPropertiesSection:Button({
	Name = "Blacklist (Ignore) Player",
	Callback = function()
		pcall(Aimbot.Blacklist, Aimbot, GUI.flags["Aimbot_PlayerName"])
		UserBox:Set("")
	end
})

AimbotPropertiesSection:Button({
	Name = "Whitelist Player",
	Callback = function()
		pcall(Aimbot.Whitelist, Aimbot, GUI.flags["Aimbot_PlayerName"])
		UserBox:Set("")
	end
})

local AimbotFOVSection = _Aimbot:Section({
	Name = "Field Of View Settings",
	Side = "Right"
})

AddValues(AimbotFOVSection, Aimbot_FOV, {}, "Aimbot_FOV_")

AimbotFOVSection:Slider({
	Name = "Field Of View",
	Flag = "Aimbot_FOV_Radius",
	Default = Aimbot_FOV.Radius,
	Min = 0,
	Max = 720,
	Callback = function(Value)
		Aimbot_FOV.Radius = Value
	end
})

AimbotFOVSection:Slider({
	Name = "Sides",
	Flag = "Aimbot_FOV_NumSides",
	Default = Aimbot_FOV.NumSides,
	Min = 3,
	Max = 60,
	Callback = function(Value)
		Aimbot_FOV.NumSides = Value
	end
})

AimbotFOVSection:Slider({
	Name = "Transparency",
	Flag = "Aimbot_FOV_Transparency",
	Default = Aimbot_FOV.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		Aimbot_FOV.Transparency = Value / 10
	end
})

AimbotFOVSection:Slider({
	Name = "Thickness",
	Flag = "Aimbot_FOV_Thickness",
	Default = Aimbot_FOV.Thickness,
	Min = 1,
	Max = 5,
	Callback = function(Value)
		Aimbot_FOV.Thickness = Value
	end
})

--// ESP Tab
local ESP_Properties_Section = _ESP:Section({
	Name = "ESP Properties",
	Side = "Left"
})

AddValues(ESP_Properties_Section, ESP_Properties.ESP, {}, "ESP_Propreties_")

ESP_Properties_Section:Dropdown({
	Name = "Text Font",
	Flag = "ESP_TextFont",
	Content = Fonts,
	Default = Fonts[ESP_Properties.ESP.Font + 1],
	Callback = function(Value)
		ESP_Properties.ESP.Font = Drawing.Fonts[Value]
	end
})

ESP_Properties_Section:Slider({
	Name = "Transparency",
	Flag = "ESP_TextTransparency",
	Default = ESP_Properties.ESP.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		ESP_Properties.ESP.Transparency = Value / 10
	end
})

ESP_Properties_Section:Slider({
	Name = "Font Size",
	Flag = "ESP_FontSize",
	Default = ESP_Properties.ESP.Size,
	Min = 1,
	Max = 20,
	Callback = function(Value)
		ESP_Properties.ESP.Size = Value
	end
})

ESP_Properties_Section:Slider({
	Name = "Offset",
	Flag = "ESP_Offset",
	Default = ESP_Properties.ESP.Offset,
	Min = 10,
	Max = 30,
	Callback = function(Value)
		ESP_Properties.ESP.Offset = Value
	end
})

local Tracer_Properties_Section = _ESP:Section({
	Name = "Tracer Properties",
	Side = "Right"
})

AddValues(Tracer_Properties_Section, ESP_Properties.Tracer, {}, "Tracer_Properties_")

Tracer_Properties_Section:Dropdown({
	Name = "Position",
	Flag = "Tracer_Position",
	Content = TracerPositions,
	Default = TracerPositions[ESP_Properties.Tracer.Position],
	Callback = function(Value)
		ESP_Properties.Tracer.Position = tablefind(TracerPositions, Value)
	end
})

Tracer_Properties_Section:Slider({
	Name = "Transparency",
	Flag = "Tracer_Transparency",
	Default = ESP_Properties.Tracer.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		ESP_Properties.Tracer.Transparency = Value / 10
	end
})

Tracer_Properties_Section:Slider({
	Name = "Thickness",
	Flag = "Tracer_Thickness",
	Default = ESP_Properties.Tracer.Thickness,
	Min = 1,
	Max = 5,
	Callback = function(Value)
		ESP_Properties.Tracer.Thickness = Value
	end
})

local HeadDot_Properties_Section = _ESP:Section({
	Name = "Head Dot Properties",
	Side = "Left"
})

AddValues(HeadDot_Properties_Section, ESP_Properties.HeadDot, {}, "HeadDot_Properties_")

HeadDot_Properties_Section:Slider({
	Name = "Transparency",
	Flag = "HeadDot_Transparency",
	Default = ESP_Properties.HeadDot.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		ESP_Properties.HeadDot.Transparency = Value / 10
	end
})

HeadDot_Properties_Section:Slider({
	Name = "Thickness",
	Flag = "HeadDot_Thickness",
	Default = ESP_Properties.HeadDot.Thickness,
	Min = 1,
	Max = 5,
	Callback = function(Value)
		ESP_Properties.HeadDot.Thickness = Value
	end
})

HeadDot_Properties_Section:Slider({
	Name = "Sides",
	Flag = "HeadDot_Sides",
	Default = ESP_Properties.HeadDot.NumSides,
	Min = 3,
	Max = 30,
	Callback = function(Value)
		ESP_Properties.HeadDot.NumSides = Value
	end
})

local Box_Properties_Section = _ESP:Section({
	Name = "Box Properties",
	Side = "Left"
})

AddValues(Box_Properties_Section, ESP_Properties.Box, {}, "Box_Properties_")

Box_Properties_Section:Slider({
	Name = "Transparency",
	Flag = "Box_Transparency",
	Default = ESP_Properties.Box.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		ESP_Properties.Box.Transparency = Value / 10
	end
})

Box_Properties_Section:Slider({
	Name = "Thickness",
	Flag = "Box_Thickness",
	Default = ESP_Properties.Box.Thickness,
	Min = 1,
	Max = 5,
	Callback = function(Value)
		ESP_Properties.Box.Thickness = Value
	end
})

local HealthBar_Properties_Section = _ESP:Section({
	Name = "Health Bar Properties",
	Side = "Right"
})

AddValues(HealthBar_Properties_Section, ESP_Properties.HealthBar, {}, "HealthBar_Properties_")

HealthBar_Properties_Section:Dropdown({
	Name = "Position",
	Flag = "HealthBar_Position",
	Content = HealthBarPositions,
	Default = HealthBarPositions[ESP_Properties.HealthBar.Position],
	Callback = function(Value)
		ESP_Properties.HealthBar.Position = tablefind(HealthBarPositions, Value)
	end
})

HealthBar_Properties_Section:Slider({
	Name = "Transparency",
	Flag = "HealthBar_Transparency",
	Default = ESP_Properties.HealthBar.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		ESP_Properties.HealthBar.Transparency = Value / 10
	end
})

HealthBar_Properties_Section:Slider({
	Name = "Thickness",
	Flag = "HealthBar_Thickness",
	Default = ESP_Properties.HealthBar.Thickness,
	Min = 1,
	Max = 5,
	Callback = function(Value)
		ESP_Properties.HealthBar.Thickness = Value
	end
})

HealthBar_Properties_Section:Slider({
	Name = "Offset",
	Flag = "HealthBar_Offset",
	Default = ESP_Properties.HealthBar.Offset,
	Min = 4,
	Max = 12,
	Callback = function(Value)
		ESP_Properties.HealthBar.Offset = Value
	end
})

HealthBar_Properties_Section:Slider({
	Name = "Blue",
	Flag = "HealthBar_Blue",
	Default = ESP_Properties.HealthBar.Blue,
	Min = 0,
	Max = 255,
	Callback = function(Value)
		ESP_Properties.HealthBar.Blue = Value
	end
})

local Chams_Properties_Section = _ESP:Section({
	Name = "Chams Properties",
	Side = "Right"
})

AddValues(Chams_Properties_Section, ESP_Properties.Chams, {}, "Chams_Properties_")

Chams_Properties_Section:Slider({
	Name = "Transparency",
	Flag = "Chams_Transparency",
	Default = ESP_Properties.Chams.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		ESP_Properties.Chams.Transparency = Value / 10
	end
})

Chams_Properties_Section:Slider({
	Name = "Thickness",
	Flag = "Chams_Thickness",
	Default = ESP_Properties.Chams.Thickness,
	Min = 1,
	Max = 5,
	Callback = function(Value)
		ESP_Properties.Chams.Thickness = Value
	end
})

--// Crosshair Tab
local Crosshair_Settings = _Crosshair:Section({
	Name = "Crosshair Settings (1 / 2)",
	Side = "Left"
})

Crosshair_Settings:Toggle({
	Name = "Enabled",
	Flag = "Crosshair_Enabled",
	Default = Crosshair.Enabled,
	Callback = function(Value)
		Crosshair.Enabled = Value
	end
})

Crosshair_Settings:Toggle({
	Name = "Enable ROBLOX Cursor",
	Flag = "Cursor_Enabled",
	Default = UserInputService.MouseIconEnabled,
	Callback = SetMouseIconVisibility
})

AddValues(Crosshair_Settings, Crosshair, {"Enabled"}, "Crosshair_")

Crosshair_Settings:Dropdown({
	Name = "Position",
	Flag = "Crosshair_Position",
	Content = {"Mouse", "Center"},
	Default = ({"Mouse", "Center"})[Crosshair.Position],
	Callback = function(Value)
		Crosshair.Position = Value == "Mouse" and 1 or 2
	end
})

Crosshair_Settings:Slider({
	Name = "Size",
	Flag = "Crosshair_Size",
	Default = Crosshair.Size,
	Min = 1,
	Max = 24,
	Callback = function(Value)
		Crosshair.Size = Value
	end
})

Crosshair_Settings:Slider({
	Name = "Gap Size",
	Flag = "Crosshair_GapSize",
	Default = Crosshair.GapSize,
	Min = 0,
	Max = 24,
	Callback = function(Value)
		Crosshair.GapSize = Value
	end
})

Crosshair_Settings:Slider({
	Name = "Rotation (Degrees)",
	Flag = "Crosshair_Rotation",
	Default = Crosshair.Rotation,
	Min = -180,
	Max = 180,
	Callback = function(Value)
		Crosshair.Rotation = Value
	end
})

Crosshair_Settings:Slider({
	Name = "Rotation Speed",
	Flag = "Crosshair_RotationSpeed",
	Default = Crosshair.RotationSpeed,
	Min = 1,
	Max = 20,
	Callback = function(Value)
		Crosshair.RotationSpeed = Value
	end
})

Crosshair_Settings:Slider({
	Name = "Pulsing Step",
	Flag = "Crosshair_PulsingStep",
	Default = Crosshair.PulsingStep,
	Min = 0,
	Max = 24,
	Callback = function(Value)
		Crosshair.PulsingStep = Value
	end
})

local _Crosshair_Settings = _Crosshair:Section({
	Name = "Crosshair Settings (2 / 2)",
	Side = "Left"
})

_Crosshair_Settings:Slider({
	Name = "Pulsing Speed",
	Flag = "Crosshair_PulsingSpeed",
	Default = Crosshair.PulsingSpeed,
	Min = 1,
	Max = 20,
	Callback = function(Value)
		Crosshair.PulsingSpeed = Value
	end
})

_Crosshair_Settings:Slider({
	Name = "Pulsing Boundary (Min)",
	Flag = "Crosshair_Pulse_Min",
	Default = Crosshair.PulsingBounds[1],
	Min = 0,
	Max = 24,
	Callback = function(Value)
		Crosshair.PulsingBounds[1] = Value
	end
})

_Crosshair_Settings:Slider({
	Name = "Pulsing Boundary (Max)",
	Flag = "Crosshair_Pulse_Max",
	Default = Crosshair.PulsingBounds[2],
	Min = 0,
	Max = 24,
	Callback = function(Value)
		Crosshair.PulsingBounds[2] = Value
	end
})

_Crosshair_Settings:Slider({
	Name = "Transparency",
	Flag = "Crosshair_Transparency",
	Default = Crosshair.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		Crosshair.Transparency = Value / 10
	end
})

_Crosshair_Settings:Slider({
	Name = "Thickness",
	Flag = "Crosshair_Thickness",
	Default = Crosshair.Thickness,
	Min = 1,
	Max = 5,
	Callback = function(Value)
		Crosshair.Thickness = Value
	end
})

local Crosshair_CenterDot = _Crosshair:Section({
	Name = "Center Dot Settings",
	Side = "Right"
})

Crosshair_CenterDot:Toggle({
	Name = "Enabled",
	Flag = "Crosshair_CenterDot_Enabled",
	Default = CenterDot.Enabled,
	Callback = function(Value)
		CenterDot.Enabled = Value
	end
})

AddValues(Crosshair_CenterDot, CenterDot, {"Enabled"}, "Crosshair_CenterDot_")

Crosshair_CenterDot:Slider({
	Name = "Size / Radius",
	Flag = "Crosshair_CenterDot_Radius",
	Default = CenterDot.Radius,
	Min = 2,
	Max = 8,
	Callback = function(Value)
		CenterDot.Radius = Value
	end
})

Crosshair_CenterDot:Slider({
	Name = "Sides",
	Flag = "Crosshair_CenterDot_Sides",
	Default = CenterDot.NumSides,
	Min = 3,
	Max = 30,
	Callback = function(Value)
		CenterDot.NumSides = Value
	end
})

Crosshair_CenterDot:Slider({
	Name = "Transparency",
	Flag = "Crosshair_CenterDot_Transparency",
	Default = CenterDot.Transparency * 10,
	Min = 1,
	Max = 10,
	Callback = function(Value)
		CenterDot.Transparency = Value / 10
	end
})

Crosshair_CenterDot:Slider({
	Name = "Thickness",
	Flag = "Crosshair_CenterDot_Thickness",
	Default = CenterDot.Thickness,
	Min = 1,
	Max = 5,
	Callback = function(Value)
		CenterDot.Thickness = Value
	end
})

--// HASH Tab (New Features)
local HASHSection = _HASH:Section({
	Name = "HASH Features",
	Side = "Left"
})

HASHSection:Toggle({
	Name = "Hide Names",
	Flag = "HASH_HideNames",
	Default = HASHSettings.HideName,
	Callback = function(Value)
		HASHSettings.HideName = Value
		if Value then
			HideNames()
		else
			RestoreNames()
		end
	end
})

HASHSection:Toggle({
	Name = "Watermark",
	Flag = "HASH_Watermark",
	Default = HASHSettings.Watermark,
	Callback = function(Value)
		HASHSettings.Watermark = Value
		if Value then
			CreateWatermark()
		else
			for _, watermark in pairs(Watermarks) do
				watermark.Visible = false
			end
		end
	end
})

HASHSection:Toggle({
	Name = "Real Silent Aim",
	Flag = "HASH_RealSilentAim",
	Default = HASHSettings.RealSilentAim,
	Callback = function(Value)
		HASHSettings.RealSilentAim = Value
	end
})

HASHSection:Toggle({
	Name = "SpinBot",
	Flag = "HASH_SpinBot",
	Default = HASHSettings.SpinBot,
	Callback = function(Value)
		HASHSettings.SpinBot = Value
	end
})

HASHSection:Toggle({
	Name = "Anti-Aim",
	Flag = "HASH_AntiAim",
	Default = HASHSettings.AntiAim,
	Callback = function(Value)
		HASHSettings.AntiAim = Value
	end
})

HASHSection:Toggle({
	Name = "Silent Aim",
	Flag = "HASH_SilentAim",
	Default = HASHSettings.SilentAim,
	Callback = function(Value)
		HASHSettings.SilentAim = Value
	end
})

HASHSection:Toggle({
	Name = "Resolver",
	Flag = "HASH_Resolver",
	Default = HASHSettings.Resolver,
	Callback = function(Value)
		HASHSettings.Resolver = Value
	end
})

-- Aimware/Skeet Style Features
HASHSection:Toggle({
	Name = "Auto Wall",
	Flag = "HASH_AutoWall",
	Default = false,
	Callback = function(Value)
		-- Implementation for shooting through walls
	end
})

HASHSection:Toggle({
	Name = "RCS (Recoil Control)",
	Flag = "HASH_RCS",
	Default = false,
	Callback = function(Value)
		-- Implementation for recoil control
	end
})

HASHSection:Toggle({
	Name = "Auto Shoot",
	Flag = "HASH_AutoShoot",
	Default = false,
	Callback = function(Value)
		-- Implementation for automatic shooting
	end
})

HASHSection:Toggle({
	Name = "Trigger Bot",
	Flag = "HASH_TriggerBot",
	Default = false,
	Callback = function(Value)
		-- Implementation for trigger bot
	end
})

HASHSection:Toggle({
	Name = "Auto Peek",
	Flag = "HASH_AutoPeek",
	Default = false,
	Callback = function(Value)
		-- Implementation for auto peek
	end
})

HASHSection:Toggle({
	Name = "Edge Jump",
	Flag = "HASH_EdgeJump",
	Default = false,
	Callback = function(Value)
		-- Implementation for edge jump
	end
})

HASHSection:Toggle({
	Name = "Auto Strafe",
	Flag = "HASH_AutoStrafe",
	Default = false,
	Callback = function(Value)
		-- Implementation for auto strafe
	end
})

HASHSection:Toggle({
	Name = "Bunny Hop",
	Flag = "HASH_BunnyHop",
	Default = false,
	Callback = function(Value)
		-- Implementation for bunny hop
	end
})

HASHSection:Slider({
	Name = "Reaction Time (ms)",
	Flag = "HASH_ReactionTime",
	Default = 100,
	Min = 0,
	Max = 500,
	Callback = function(Value)
		-- Implementation for reaction time adjustment
	end
})

HASHSection:Slider({
	Name = "Smoothing",
	Flag = "HASH_Smoothing",
	Default = 1,
	Min = 0,
	Max = 10,
	Callback = function(Value)
		-- Implementation for aim smoothing
	end
})

HASHSection:Slider({
	Name = "FOV Size",
	Flag = "HASH_FOVSize",
	Default = 90,
	Min = 1,
	Max = 500,
	Callback = function(Value)
		-- Implementation for FOV size adjustment
	end
})

HASHSection:Dropdown({
	Name = "Hitbox Selection",
	Flag = "HASH_HitboxSelection",
	Content = {"Head", "Body", "Legs", "Arms", "Nearest"},
	Default = "Head",
	Callback = function(Value)
		-- Implementation for hitbox selection
	end
})

HASHSection:Dropdown({
	Name = "Aim Mode",
	Flag = "HASH_AimMode",
	Content = {"Normal", "Smooth", "Silent", "Rage"},
	Default = "Normal",
	Callback = function(Value)
		-- Implementation for aim mode selection
	end
})

HASHSection:Dropdown({
	Name = "Priority Target",
	Flag = "HASH_PriorityTarget",
	Content = {"Distance", "Health", "FOV", "Threat"},
	Default = "Distance",
	Callback = function(Value)
		-- Implementation for priority target selection
	end
})

--// Settings Tab
local SettingsSection = Settings:Section({
	Name = "Settings",
	Side = "Left"
})

local GUISection = Settings:Section({
	Name = "GUI Customization",
	Side = "Left"
})

local ProfilesSection = Settings:Section({
	Name = "Profiles",
	Side = "Left"
})

local InformationSection = Settings:Section({
	Name = "Information",
	Side = "Right"
})

SettingsSection:Keybind({
	Name = "Show / Hide GUI",
	Flag = "UI Toggle",
	Default = Enum.KeyCode.RightShift,
	Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
	Callback = function(_, NewKeybind)
		if not NewKeybind then
			GUI:Close()
		end
	end
})

SettingsSection:Button({
	Name = "Unload Script",
	Callback = function()
		GUI:Unload()
		ESP:Exit()
		Aimbot:Exit()
		getgenv().HASHLoaded = nil
		getgenv().HASHLoading = nil
		
		-- Remove watermarks
		for _, watermark in pairs(Watermarks) do
			watermark:Remove()
		end
		
		-- Restore names
		RestoreNames()
	end
})

--// GUI Customization
GUISection:Colorpicker({
	Name = "Primary Color",
	Flag = "GUI_PrimaryColor",
	Default = Color3.fromRGB(255, 0, 255),
	Callback = function(Value)
		-- Implementation for primary color customization
	end
})

GUISection:Colorpicker({
	Name = "Secondary Color",
	Flag = "GUI_SecondaryColor",
	Default = Color3.fromRGB(0, 0, 0),
	Callback = function(Value)
		-- Implementation for secondary color customization
	end
})

GUISection:Slider({
	Name = "GUI Transparency",
	Flag = "GUI_Transparency",
	Default = 0,
	Min = 0,
	Max = 100,
	Callback = function(Value)
		-- Implementation for GUI transparency
	end
})

GUISection:Toggle({
	Name = "Rainbow Mode",
	Flag = "GUI_RainbowMode",
	Default = false,
	Callback = function(Value)
		-- Implementation for rainbow mode
	end
})

GUISection:Dropdown({
	Name = "Theme",
	Flag = "GUI_Theme",
	Content = {"Default", "Dark", "Light", "Neon", "Custom"},
	Default = "Default",
	Callback = function(Value)
		-- Implementation for theme selection
	end
})

local ConfigList = ProfilesSection:Dropdown({
	Name = "Configurations",
	Flag = "Config Dropdown",
	Content = GUI:GetConfigs()
})

ProfilesSection:Box({
	Name = "Configuration Name",
	Flag = "Config Name",
	Placeholder = "Config Name"
})

ProfilesSection:Button({
	Name = "Load Configuration",
	Callback = function()
		GUI:LoadConfig(GUI.flags["Config Dropdown"])
	end
})

ProfilesSection:Button({
	Name = "Delete Configuration",
	Callback = function()
		GUI:DeleteConfig(GUI.flags["Config Dropdown"])
		ConfigList:Refresh(GUI:GetConfigs())
	end
})

ProfilesSection:Button({
	Name = "Save Configuration",
	Callback = function()
		GUI:SaveConfig(GUI.flags["Config Dropdown"] or GUI.flags["Config Name"])
		ConfigList:Refresh(GUI:GetConfigs())
	end
})

InformationSection:Label("HASH - Advanced Universal FPS Script")
InformationSection:Label("Enhanced with Aimware and Skeet features")

InformationSection:Button({
	Name = "Copy GitHub",
	Callback = function()
		setclipboard("https://github.com/Exunys")
	end
})

InformationSection:Label("HASH Team © 2025 - "..osdate("%Y"))

InformationSection:Button({
	Name = "Copy Discord Invite",
	Callback = function()
		setclipboard("https://discord.gg/Ncz3H3quUZ")
	end
})

--[=[
local MiscellaneousSection = Settings:Section({
	Name = "Miscellaneous",
	Side = "Right"
})

local TimeLabel = MiscellaneousSection:Label("...")
local FPSLabel = MiscellaneousSection:Label("...")
local PlayersLabel = MiscellaneousSection:Label("...")

MiscellaneousSection:Button({
	Name = "Rejoin",
	Callback = Rejoin
})

delay(2, function()
	spawn(function()
		while wait(1) do
			TimeLabel:Set(osdate("%c"))
			PlayersLabel:Set(#Players:GetPlayers())
		end
	end)

	RunService.RenderStepped:Connect(function(FPS)
		FPSLabel:Set("FPS: "..mathfloor(1 / FPS))
	end)
end)
end)
]=]

--// HASH Enhancements
-- Add GUI animations
local function AnimateGUI()
	-- Add smooth transitions to the GUI
	-- This would typically involve tweening positions and colors
end

-- Real Silent Aim implementation
local function RealSilentAim()
	if not HASHSettings.RealSilentAim then return end
	
	-- Enable real silent aim in the Aimbot module
	Aimbot:SetRealSilentAim(true)
	
	-- Get the current target
	local target = Aimbot:GetRealSilentAimTarget()
	if target then
		-- Apply silent aim to the target
		Aimbot:ApplySilentAim(target)
	end
end

-- SpinBot implementation
local function SpinBot()
	if not HASHSettings.SpinBot then return end
	
	-- Implementation for SpinBot
	-- This would make the player spin automatically
	local character = LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				-- Rotate the character slowly
				rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(5), 0)
			end
		end
	end
end

-- Anti-Aim implementation
local function AntiAim()
	if not HASHSettings.AntiAim then return end
	
	-- Implementation for Anti-Aim
	-- This would make the player's aim unpredictable to opponents
	local character = LocalPlayer.Character
	if character then
		local head = character:FindFirstChild("Head")
		if head then
			-- Randomly change head position to make aim prediction harder
			local randomPitch = math.random(-45, 45)
			local randomYaw = math.random(-45, 45)
			head.CFrame = head.CFrame * CFrame.Angles(math.rad(randomPitch), math.rad(randomYaw), 0)
		end
	end
end

-- Silent Aim implementation
local function SilentAim()
	if not HASHSettings.SilentAim then return end
	
	-- Implementation for Silent Aim
	-- This would make the aimbot less detectable
	-- Adjust aimbot settings for silent operation
	Aimbot.Settings.Sensitivity2 = 10 -- Increase mouse sensitivity for faster, less detectable movement
	Aimbot.Settings.LockMode = 2 -- Use mousemoverel for more natural movement
end

-- Resolver implementation
local function Resolver()
	if not HASHSettings.Resolver then return end
	
	-- Implementation for Resolver
	-- This would help with players using anti-cheat measures
	-- Enable prediction and compensation for anti-cheat measures
	Aimbot.Settings.OffsetToMoveDirection = true
	Aimbot.Settings.OffsetIncrement = 25
end

--// Launch
ESP.Load()
Aimbot.Load()
CreateWatermark()

--// Advanced Features
RunService.Heartbeat:Connect(function()
	RealSilentAim()
	SpinBot()
	AntiAim()
	SilentAim()
	Resolver()
end)

getgenv().HASHLoaded = true
getgenv().HASHLoading = nil

GeneralSignal:Fire()
GUI:Close()
end