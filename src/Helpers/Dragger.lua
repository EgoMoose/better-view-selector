local pluginRoot = script.Parent.Parent.Parent

local Janitor = require(pluginRoot.Packages.Janitor)
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

-- Public Constructors

function DraggerClass.new(instance)
	local self = setmetatable({}, DraggerClass)

	self.instance = instance

	self.isDragging = false

	self.dragStarted = Signal.new()
	self.dragEnded = Signal.new()
	self.dragChanged = Signal.new()

	self.janitor = Janitor.new()

	self.janitor:Add(self.instance.InputBegan:Connect(function(input)
		if not self.isDragging and VALID_PRESS[input.UserInputType] then
			self.isDragging = true
			self.dragStarted:Fire(input)
		end
	end))

	self.janitor:Add(UserInputService.InputEnded:Connect(function(input)
		if self.isDragging and VALID_PRESS[input.UserInputType] then
			self.isDragging = false
			self.dragEnded:Fire(input)
		end
	end))

	self.janitor:Add(UserInputService.InputChanged:Connect(function(input)
		if self.isDragging and VALID_MOVEMENT[input.UserInputType] then
			self.dragChanged:Fire(input)
		end
	end))

	return self
end

-- Public Methods

function DraggerClass:IsDragging()
	return self.isDragging
end

function DraggerClass:GetDragStartedSignal()
	return self.dragStarted
end

function DraggerClass:GetDragEndedSignal()
	return self.dragEnded
end

function DraggerClass:GetDragChangedSignal()
	return self.dragChanged
end

function DraggerClass:Destroy()
	self.janitor:Destroy()
end

--

return DraggerClass
