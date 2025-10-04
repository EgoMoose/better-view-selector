--!strict

local RunService = game:GetService("RunService") :: RunService

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

local stories = script:FindFirstAncestor("Stories")
local CreateStory = require(stories.Helpers.CreateStory)

local uiRoot = script:FindFirstAncestor("UserInterface")
local FreeDrag = require(uiRoot.Components.Generic.FreeDrag)
local ModernViewSelector = require(uiRoot.Components.Viewers.ModernViewSelector)

local function story()
	local rotation, setRotation = React.useState(CFrame.identity)

	React.useEffect(function()
		local cf = rotation
		local connection = RunService.PreRender:Connect(function(dt)
			-- stylua: ignore
			cf = cf * CFrame.fromEulerAnglesXYZ(
				math.rad(15 * dt),
				math.rad(30 * dt),
				math.rad(45 * dt)
			)

			setRotation(cf)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local _isDragging, setIsDragging = React.useState(false)

	return React.createElement(FreeDrag, {
		SetIsDragging = setIsDragging,

		AnchorPoint = Vector2.new(0.5, 0.5),
		InitialPosition = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(50, 50),

		Scale = 1,
		Disabled = false,
	}, {
		Viewer = React.createElement(ModernViewSelector, {
			Rotation = rotation,
			ColorMap = {
				[Enum.Axis.X] = Color3.new(1, 0, 0),
				[Enum.Axis.Y] = Color3.new(0, 1, 0),
				[Enum.Axis.Z] = Color3.new(0, 0, 1),
			},
		}),
	})
end

return CreateStory(story)
