--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local ReactRoblox = require(pluginRoot.Packages.ReactRoblox)
local React = require(pluginRoot.Packages.React)

local function createStory(component: React.FC<any>)
	return function(target: Frame)
		local element = React.createElement(component, {})
		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		local portal = ReactRoblox.createPortal(element, target)
		root:render(portal)
		return function()
			root:unmount()
		end
	end
end

return createStory
