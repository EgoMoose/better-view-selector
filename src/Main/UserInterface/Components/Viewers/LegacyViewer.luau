--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

type AxisProps = {
	Text: string,
	Color: Color3,
	Vector: Vector2,
	ZIndex: number,
}

local function Axis(props: AxisProps)
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = props.ZIndex,
	}, {
		Line = React.createElement("Frame", {
			BorderSizePixel = 0,
			Size = UDim2.new(0.5, 0, 0, 1),
			Position = UDim2.new(0, 0, 0, 0),
		}),
		Label = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(0, 0),
			FontFace = Font.fromEnum(Enum.Font.Legacy),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = props.Color,
			Text = props.Text,
			TextSize = 8,
		}),
	})
end

export type Props = {
	CFrame: CFrame,
}

local function LegacyViewer()
	local children: { [string]: React.Node } = {}
	for _, enum in Enum.Axis:GetEnumItems() do
		children[`{enum.Name}Axis`] = React.createElement(Axis, {
			Text = enum.Name,
			Color = Color3.new(1, 0, 0),
			Vector = Vector2.zero,
			ZIndex = 1,
		})
	end

	return React.createElement("Frame", {
		Size = UDim2.fromOffset(50, 50),
		BackgroundTransparency = 1,
	}, children)
end

return LegacyViewer
