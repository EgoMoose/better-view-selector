local pluginRoot = script.Parent.Parent.Parent

local Janitor = require(pluginRoot.Packages.Janitor)

local TEXT_OFFSET = {
	[Enum.Axis.X] = Vector2.new(0, 0),
	[Enum.Axis.Y] = Vector2.new(3, 0),
	[Enum.Axis.Z] = Vector2.new(0, 0),
}

local DEFAULT_AXIS_COLORS = {
	[true] = {
		[Enum.Axis.X] = Color3.new(1, 0, 0),
		[Enum.Axis.Y] = Color3.new(0, 1, 0),
		[Enum.Axis.Z] = Color3.new(0, 0, 1),
	},
	[false] = {
		[Enum.Axis.X] = Color3.new(1, 0, 1),
		[Enum.Axis.Y] = Color3.new(1, 1, 0),
		[Enum.Axis.Z] = Color3.new(0, 1, 1),
	},
}

local LegacyViewSelectorClass = {}
LegacyViewSelectorClass.__index = LegacyViewSelectorClass
LegacyViewSelectorClass.ClassName = "LegacyViewSelector"

function LegacyViewSelectorClass.new()
	local self = setmetatable({}, LegacyViewSelectorClass)

	self.container = Instance.new("ImageButton")
	self.container.Image = ""
	self.container.ImageTransparency = 1
	self.container.BackgroundTransparency = 1
	self.container.Size = UDim2.new(0, 50, 0, 50)

	self.axes = {}
	for _, axis in Enum.Axis:GetEnumItems() do
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0.5, 0, 0, 1)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.BorderSizePixel = 0
		frame.Parent = self.container

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0, 0, 0, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Legacy
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.Text = axis.Name
		label.TextSize = 8
		label.Parent = self.container

		self.axes[axis] = {
			frame = frame,
			label = label,
		}
	end

	self.janitor = Janitor.new()
	self.janitor:Add(self.container)

	return self
end

-- Private

function LegacyViewSelectorClass:_setAxis(axis: Enum.Axis, vector: Vector2, zIndex: number)
	local textOffset = TEXT_OFFSET[axis]
	local length = vector.Magnitude

	local axisInstances = self.axes[axis]
	local frame = axisInstances.frame
	local label = axisInstances.label

	frame.Size = UDim2.new(0, length, 0, 1)
	frame.Position = UDim2.new(0.5, vector.X / 2 - length / 2, 0.5, vector.Y / 2 - 0.5)
	frame.Rotation = math.deg(math.atan2(vector.Y, vector.X))
	frame.ZIndex = zIndex

	label.Position = UDim2.new(0.5, vector.X + textOffset.X, 0.5, vector.Y + textOffset.Y)
	label.ZIndex = zIndex
end

-- Public

function LegacyViewSelectorClass:GetContainer()
	return self.container
end

function LegacyViewSelectorClass:SetVisible(visible: boolean)
	self.container.Visible = visible
end

function LegacyViewSelectorClass:SetAxisColor(isWorldSpace: boolean)
	local colors = DEFAULT_AXIS_COLORS[isWorldSpace]
	for axis, color in colors do
		local axisInstances = self.axes[axis]
		axisInstances.frame.BackgroundColor3 = color
		axisInstances.label.TextColor3 = color
	end
end

function LegacyViewSelectorClass:Render(rotation: CFrame)
	local camera = workspace.CurrentCamera
	local pixelHeight = math.min(self.container.AbsoluteSize.X, self.container.AbsoluteSize.Y) / 2
	local pixelHeightAsPercent = pixelHeight / (camera.ViewportSize.Y / 2)

	local distance = (1 / pixelHeightAsPercent) / math.tan(math.rad(camera.FieldOfView / 2))
	local origin = camera.CFrame * Vector3.new(0, 0, -distance)

	local axes = {}
	local p = camera:WorldToViewportPoint(origin)

	for _, axis in Enum.Axis:GetEnumItems() do
		local lv = Vector3.FromAxis(axis)
		local v = camera:WorldToViewportPoint(origin + rotation:VectorToWorldSpace(lv)) - p

		table.insert(axes, {
			axis = axis,
			vector = v,
		})
	end

	table.sort(axes, function(a, b)
		return a.vector.Z > b.vector.Z
	end)

	for i, value in ipairs(axes) do
		self:_setAxis(value.axis, value.vector, i)
	end
end

function LegacyViewSelectorClass:Destroy()
	self.janitor:Destroy()
end

return LegacyViewSelectorClass
