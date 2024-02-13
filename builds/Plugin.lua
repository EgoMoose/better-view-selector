--!strict

local pluginRoot = script.Parent.Parent
local BetterViewSelector = require(pluginRoot.BetterViewSelector)
local Serializer = require(pluginRoot.BetterViewSelector.Helpers.Serializer)

local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")

local SETTING_KEY = "EgoMoose_BetterViewSelectorSettings"

local module = {}

local function requestCFrameFromInstance(instance: Instance?): CFrame?
	if instance then
		local success, value = pcall(function()
			if instance:IsA("BasePart") then
				return instance.CFrame
			elseif instance:IsA("Model") then
				if instance.PrimaryPart then
					return instance.PrimaryPart.CFrame
				else
					return instance:GetPivot()
				end
			elseif instance:IsA("Attachment") then
				return instance.WorldCFrame
			else
				error("Can't get cframe from " .. instance.ClassName)
			end
		end)

		if success then
			return value
		end
	end
	return nil
end

function module.build(plugin: Plugin)
	local function useLegacy(): boolean
		return true
	end

	local function useLocalSpace(): boolean
		return StudioService.UseLocalSpace
	end

	local function getSelectedCFrame(): CFrame?
		local selected = Selection:Get()
		if #selected == 1 then
			return requestCFrameFromInstance(selected[1])
		end
		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.IgnoreGuiInset = false
	screenGui.Name = "BetterViewSelectorScreenGui"
	screenGui.Enabled = false
	screenGui.Parent = CoreGui

	local useLegacyChanged = Instance.new("BindableEvent")

	-- stylua: ignore
	local serialized = Serializer.decode(plugin:GetSetting(SETTING_KEY)) or {
		version = 1,
		anchor = Vector2.new(1, 0),
		position = UDim2.new(1, -30, 0, 30),
	}

	local controller = BetterViewSelector.setup(screenGui, {
		anchor = serialized.anchor,
		position = serialized.position,

		getSelectedCFrame = getSelectedCFrame,

		useLegacy = useLegacy,
		useLegacyChanged = useLegacyChanged.Event,

		useLocalSpace = useLocalSpace,
		useLocalSpaceChanged = StudioService:GetPropertyChangedSignal("UseLocalSpace"),
	})

	plugin.Unloading:Connect(function()
		plugin:SetSetting(SETTING_KEY, Serializer.encode(controller.save()))
	end)

	local renderStepped: RBXScriptConnection?
	local function onButtonToggled(enabled: boolean)
		if renderStepped then
			renderStepped:Disconnect()
			renderStepped = nil
		end

		if enabled then
			renderStepped = RunService.RenderStepped:Connect(controller.render)
		end

		screenGui.Enabled = enabled
	end

	----------------------------------------------------

	RunService.Heartbeat:Wait() -- let the roblox view selector plugin init

	local viewSelectorScreenGui = CoreGui:FindFirstChild("ViewSelectorScreenGui")
	if viewSelectorScreenGui then
		viewSelectorScreenGui.Parent = nil
		viewSelectorScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			onButtonToggled(viewSelectorScreenGui.Enabled)

			if viewSelectorScreenGui.Enabled then
				RunService:UnbindFromRenderStep("ViewSelectorAfterCamera")
			end
		end)

		onButtonToggled(viewSelectorScreenGui.Enabled)
	end
end

return module
