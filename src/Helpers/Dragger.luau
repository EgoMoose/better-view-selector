--!strict

local pluginRoot = script.Parent.Parent.Parent

local Trove = require(pluginRoot.Packages.Trove)
local Signal = require(pluginRoot.Packages.Signal)

local UserInputService = game:GetService("UserInputService")

local VALID_PRESS = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true,
}

local VALID_MOVEMENT = {
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.Touch] = true,
}

-- Class

local DraggerClass = {}
DraggerClass.__index = DraggerClass
DraggerClass.ClassName = "Dragger"

export type Dragger = typeof(setmetatable(
	{} :: {
		instance: GuiObject,
		isDragging: boolean,

		dragStarted: Signal.Signal<InputObject>,
		dragEnded: Signal.Signal<InputObject>,
		dragChanged: Signal.Signal<InputObject>,

		trove: Trove.Trove,
	},
	DraggerClass
))

-- Public Constructors

function DraggerClass.new(instance)
	local self = setmetatable({}, DraggerClass) :: Dragger

	self.instance = instance

	self.isDragging = false

	self.dragStarted = Signal.new()
	self.dragEnded = Signal.new()
	self.dragChanged = Signal.new()

	self.trove = Trove.new()

	self.trove:Add(self.instance.InputBegan:Connect(function(input)
		if not self.isDragging and VALID_PRESS[input.UserInputType] then
			self.isDragging = true
			self.dragStarted:Fire(input)
		end
	end))

	self.trove:Add(UserInputService.InputEnded:Connect(function(input)
		if self.isDragging and VALID_PRESS[input.UserInputType] then
			self.isDragging = false
			self.dragEnded:Fire(input)
		end
	end))

	self.trove:Add(UserInputService.InputChanged:Connect(function(input)
		if self.isDragging and VALID_MOVEMENT[input.UserInputType] then
			self.dragChanged:Fire(input)
		end
	end))

	return self
end

-- Public Methods

function DraggerClass.IsDragging(self: Dragger)
	return self.isDragging
end

function DraggerClass.GetDragStartedSignal(self: Dragger)
	return self.dragStarted
end

function DraggerClass.GetDragEndedSignal(self: Dragger)
	return self.dragEnded
end

function DraggerClass.GetDragChangedSignal(self: Dragger)
	return self.dragChanged
end

function DraggerClass.Destroy(self: Dragger)
	self.trove:Destroy()
end

--

return DraggerClass
