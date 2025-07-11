--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local ReactRoblox = require(pluginRoot.Packages.ReactRoblox)
local React = require(pluginRoot.Packages.React)

return {
	name = "BetterViewSelector",
	storyRoots = { script.Parent.Parent },
	react = React,
	reactRoblox = ReactRoblox,
}
