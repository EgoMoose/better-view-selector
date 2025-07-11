--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

type AxisProps = {
	Text: string,
	Color: Color3,
	Vector: Vector3,
	Thickness: UDim,
	ZIndex: number,
}

local function Axis(props: AxisProps)
	local x, y = props.Vector.X, props.Vector.Y
	local rotationDeg = math.deg(-math.atan2(y, x))

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Rotation = rotationDeg,
		ZIndex = props.ZIndex,
	}, {
		UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
		}),
		Line = React.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = props.Color,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(math.sqrt(x * x + y * y) * 0.5, 0, props.Thickness.Scale, props.Thickness.Offset),
		}, {
			Label = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 1),
				Size = UDim2.fromOffset(0, 0),
				Rotation = -rotationDeg,
				FontFace = Font.fromEnum(Enum.Font.Legacy),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = props.Color,
				Text = props.Text,
				TextSize = 8,
			}),
		}),
	})
end

export type Props = {
	Rotation: CFrame,
	ColorMap: { [Enum.Axis]: Color3 },
}

local function LegacyViewer(props: Props)
	local axes = React.useMemo(function()
		local sorted = {}
		for _, enum in Enum.Axis:GetEnumItems() do
			local vector = props.Rotation:VectorToWorldSpace(Vector3.FromAxis(enum))
			table.insert(sorted, {
				enum = enum,
				vector = vector,
			})
		end

		table.sort(sorted, function(a, b)
			return a.vector.Z < b.vector.Z
		end)

		return sorted
	end, { props.Rotation })

	local children: { [string]: React.Node } = {}
	for zIndex, axis in axes do
		children[`{axis.enum.Name}Axis`] = React.createElement(Axis, {
			Text = axis.enum.Name,
			Color = props.ColorMap[axis.enum],
			Vector = axis.vector,
			Thickness = UDim.new(0, 1),
			ZIndex = zIndex,
		})
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, children)
end

return LegacyViewer
