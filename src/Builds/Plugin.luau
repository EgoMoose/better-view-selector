--!strict
local RunService = game:GetService("RunService")

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local UserInterface = require(pluginRoot.Main.UserInterface)

local Plugin = {}

-- Public

function Plugin.build(plugin: Plugin)
	if RunService:IsStudio() and RunService:IsEdit() then
		local unmount = UserInterface.mountAsync()
		plugin.Unloading:Once(function()
			unmount()
		end)
	end
end

return Plugin
