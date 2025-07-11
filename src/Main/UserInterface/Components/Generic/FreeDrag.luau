--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

local uiRoot = script:FindFirstAncestor("UserInterface")
local Hooks = require(uiRoot.Hooks)

export type Props = {
	SetIsDragging: (boolean) -> (),

	InitialPosition: UDim2,
	AnchorPoint: Vector2,
	Size: UDim2,

	Scale: number,

	Disabled: boolean,
	children: React.ReactNode,
}

local function convertToAbsSize(udim2: UDim2, containerSize: Vector2)
	return Vector2.new(
		udim2.X.Scale * containerSize.X + udim2.X.Offset,
		udim2.Y.Scale * containerSize.Y + udim2.Y.Offset
	)
end

local function FreeDrag(props: Props)
	local position, setPosition = React.useState(props.InitialPosition)

	local containerRef = React.useRef(nil)
	local containerSize = Hooks.useRefProperty(containerRef, "AbsoluteSize", Vector2.zero)

	local absSize = convertToAbsSize(props.Size, containerSize) * props.Scale
	local absAnchorPosition = convertToAbsSize(position, containerSize) * props.Scale
	local absAnchorSize = props.AnchorPoint * absSize
	local absPosition = absAnchorPosition - absAnchorSize

	local clampedPosition = UDim2.fromOffset(
		math.clamp(absPosition.X, 0, math.max(0, containerSize.X - absSize.X)),
		math.clamp(absPosition.Y, 0, math.max(0, containerSize.Y - absSize.Y))
	)

	local dragStart = React.useRef(nil :: { input: Vector3, position: UDim2 }?)
	local dragger = Hooks.useMouseDrag({
		onDragCallback = function(_rbx, input)
			if dragStart.current then
				local delta3 = (input.Position - dragStart.current.input) / props.Scale
				setPosition(dragStart.current.position + UDim2.fromOffset(delta3.X, delta3.Y))
			end
		end,
		onBeganCallback = function(_rbx, input)
			dragStart.current = {
				input = input.Position,
				position = UDim2.fromOffset(
					(clampedPosition.X.Offset + absAnchorSize.X) / props.Scale,
					(clampedPosition.Y.Offset + absAnchorSize.Y) / props.Scale
				),
			}
		end,
	})

	local isDragging = dragger.isActive()
	React.useEffect(function()
		if props.Disabled then
			dragger.cancel()
			props.SetIsDragging(false)
		else
			props.SetIsDragging(isDragging)
		end
	end, { isDragging })

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ref = containerRef,
	}, {
		Dragger = React.createElement("ImageButton", {
			Size = props.Size,
			Position = clampedPosition,
			BackgroundTransparency = 1,

			Image = "",
			AutoButtonColor = false,

			[React.Event.InputBegan] = dragger.onInputBegan,
			[React.Event.InputChanged] = dragger.onInputChanged,
			[React.Event.InputEnded] = dragger.onInputEnded,
		}, {
			UIScale = props.Scale ~= 1 and React.createElement("UIScale", {
				Scale = props.Scale,
			}),
		}, props.children),
	})
end

return FreeDrag
