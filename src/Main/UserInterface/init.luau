--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local ReactRoblox = require(pluginRoot.Packages.ReactRoblox)
local React = require(pluginRoot.Packages.React)

local LegacyViewSelector = require(script.Components.Viewers.LegacyViewer)
local Hooks = require(script.Hooks)

local UserInterface = {}

function UserInterface.mount(parent: Instance)
	local root = ReactRoblox.createRoot(parent)

	local function App()
		local selectedCF = Hooks.useInstanceProperty(workspace.Part, "CFrame", CFrame.identity)
		local rotationCF = Hooks.useCameraSpaceCFrame(selectedCF)

		return React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(50, 50),
			BackgroundTransparency = 1,
		}, {
			Viewer = React.createElement(LegacyViewSelector, {
				Rotation = rotationCF,
				ColorMap = {
					[Enum.Axis.X] = Color3.new(1, 0, 1),
					[Enum.Axis.Y] = Color3.new(1, 1, 0),
					[Enum.Axis.Z] = Color3.new(0, 1, 1),
				},
			}),
		})
	end

	root:render(React.createElement(App))

	return function()
		root:unmount()
	end
end

return UserInterface
