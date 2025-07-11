--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

local useSelection = require(script.Parent.useSelection)

local function tryGetCFrame(instance: Instance): CFrame?
	local success, value = pcall(function()
		if instance:IsA("BasePart") then
			return instance:GetPivot()
		elseif instance:IsA("Model") then
			if instance.PrimaryPart then
				return instance.PrimaryPart:GetPivot()
			else
				return instance:GetPivot()
			end
		elseif instance:IsA("Attachment") then
			return instance.WorldCFrame
		else
			error("Can't get CFrame from " .. instance.ClassName)
		end
	end)

	return if success then value else nil
end

local function useSelectionCFrames()
	local selection = useSelection()

	return React.useMemo(function()
		local results = {}
		for _, selected in selection do
			local result = tryGetCFrame(selected)
			if result then
				table.insert(results, result)
			end
		end
		return results
	end, { selection })
end

return useSelectionCFrames
