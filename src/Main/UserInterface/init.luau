--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local ReactRoblox = require(pluginRoot.Packages.ReactRoblox)
local React = require(pluginRoot.Packages.React)

local UserInterface = {}

function UserInterface.mount(parent: Instance)
	local root = ReactRoblox.createRoot(parent)

	local function App()
		return React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.25, 0.25),
		})
	end

	root:render(React.createElement(App))

	return function()
		root:unmount()
	end
end

return UserInterface
