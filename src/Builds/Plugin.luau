--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local UserInterface = require(pluginRoot.Main.UserInterface)

local Plugin = {}

-- Public

function Plugin.build(plugin: Plugin)
	local unmount = UserInterface.mountAsync()
	plugin.Unloading:Once(function()
		unmount()
	end)
end

return Plugin
