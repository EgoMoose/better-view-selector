--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

local useRefProperty = require(script.Parent.useRefProperty)

local function useInstanceProperty<T>(instance: Instance, property: string, default: T)
	local ref = React.useRef(instance)
	return useRefProperty(ref, property, default)
end

return useInstanceProperty
