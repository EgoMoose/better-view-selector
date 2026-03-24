local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

local function useConstant<T...>(create: () -> T...): T...
	local ref = React.useRef(nil :: any)

	if not ref.current then
		ref.current = { packed = table.pack(create()) }
	end

	return table.unpack(ref.current.packed)
end

return useConstant
