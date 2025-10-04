--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

export type Props = {
	Rotation: CFrame,
	ColorMap: { [Enum.Axis]: Color3 },
}

local function ModernViewSelector(props: Props)
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})
end

return ModernViewSelector
