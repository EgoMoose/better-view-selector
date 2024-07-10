--!strict

local pluginRoot = script.Parent.Parent
local BetterViewSelector = require(pluginRoot.BetterViewSelector)

local RunService = game:GetService("RunService")

local module = {}

-- Private

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

-- Public

function module.build(screenGui: ScreenGui)
	local targetObject = Instance.new("ObjectValue")
	targetObject.Name = "Selection"
	targetObject.Parent = screenGui

	local useLegacyBool = Instance.new("BoolValue")
	useLegacyBool.Name = "UseLegacy"
	useLegacyBool.Value = true
	useLegacyBool.Parent = screenGui

	local function useLegacy()
		return useLegacyBool.Value
	end

	local useLocalSpaceBool = Instance.new("BoolValue")
	useLocalSpaceBool.Name = "useLocalSpace"
	useLocalSpaceBool.Value = true
	useLocalSpaceBool.Parent = screenGui

	local function useLocalSpace()
		return useLocalSpaceBool.Value
	end

	local controller = BetterViewSelector.setup(screenGui, {
		anchor = Vector2.new(1, 0),
		position = UDim2.new(1, -30, 0, 30),

		getSelectedCFrame = function()
			return requestCFrameFromInstance(targetObject.Value)
		end,

		useLegacy = useLegacy,
		useLegacyChanged = useLegacyBool.Changed,

		useLocalSpace = useLocalSpace,
		useLocalSpaceChanged = useLocalSpaceBool.Changed,
	})

	RunService.RenderStepped:Connect(controller.render)
end

return module
