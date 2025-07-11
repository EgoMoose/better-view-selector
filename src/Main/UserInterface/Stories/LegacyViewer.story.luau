--!strict

local RunService = game:GetService("RunService") :: RunService

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

local stories = script:FindFirstAncestor("Stories")
local CreateStory = require(stories.Helpers.CreateStory)

local uiRoot = script:FindFirstAncestor("UserInterface")
local LegacyViewSelector = require(uiRoot.Components.Viewers.LegacyViewer)

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

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(50, 50),
	}, {
		Viewer = React.createElement(LegacyViewSelector, {
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
