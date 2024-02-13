--!strict

local pluginRoot = script.Parent.Parent.Parent

local LuaEncode = require(pluginRoot.Packages.LuaEncode)

local module = {}

function module.encode(t: { [any]: any })
	-- these are the default params written for
	return LuaEncode(t, {})
end

function module.decode(encoded: string?): { [any]: any }?
	if encoded then
		-- this will only work with plugins
		local moduleScript = Instance.new("ModuleScript")
		local success, result = pcall(function()
			moduleScript.Source = "return " .. encoded
			return require(moduleScript) :: any
		end)
		return if success then result else nil
	end
	return nil
end

return module
