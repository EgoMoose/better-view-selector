--!strict

local pluginRoot = script.Parent

local Trove = require(pluginRoot.Packages.Trove)

local Dragger = require(pluginRoot.BetterViewSelector.Helpers.Dragger)
local LegacyViewSelector = require(pluginRoot.BetterViewSelector.ViewSelectors.LegacyViewSelector)

local GuiService = game:GetService("GuiService")

local VIEWPORT_DRAG_GAP = 30

local module = {}

-- Private

type State = {
	position: UDim2,
	selectors: { [boolean]: LegacyViewSelector.LegacyViewSelector },
	trove: Trove.Trove,
}

local state: State = {
	position = UDim2.new(0.5, 0, 0.5, 0),

	selectors = {
		[true] = LegacyViewSelector.new(),
		--[false] = ModernViewSelector.new(), -- TODO?
	},

	trove = Trove.new(),
}

local function constrainInside(rect: Rect, bounds: Rect)
	local minX = rect.Min.X
	local minY = rect.Min.Y

	if rect.Min.X < bounds.Min.X then
		minX = bounds.Min.X
	elseif rect.Max.X > bounds.Max.X then
		minX = bounds.Max.X - rect.Width
	end

	if rect.Min.Y < bounds.Min.Y then
		minY = bounds.Min.Y
	elseif rect.Max.Y > bounds.Max.Y then
		minY = bounds.Max.Y - rect.Height
	end

	return Rect.new(minX, minY, minX + rect.Width, minY + rect.Height)
end

local function getViewportConstrainedPosition(container: GuiObject, containerRect: Rect)
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local anchorOffset = container.AbsoluteSize * container.AnchorPoint

	local viewportBounds = Rect.new(
		VIEWPORT_DRAG_GAP,
		VIEWPORT_DRAG_GAP,
		viewportSize.X - VIEWPORT_DRAG_GAP,
		viewportSize.Y - VIEWPORT_DRAG_GAP
	)

	local constrainedRect = constrainInside(containerRect, viewportBounds)
	
	-- stylua: ignore
	return UDim2.fromScale(
		(constrainedRect.Min.X + anchorOffset.X) / viewportSize.X, 
		(constrainedRect.Min.Y + anchorOffset.Y) / viewportSize.Y
	)
end

local function wrapDragger(viewSelector: any)
	local container = viewSelector:GetContainer()
	local dragger = Dragger.new(container)
	local offset = Vector2.new(0, 0)

	local dragStarted = dragger:GetDragStartedSignal():Connect(function(input: InputObject)
		offset = Vector2.new(input.Position.X, input.Position.Y) - container.AbsolutePosition
	end)

	local dragChanged = dragger:GetDragChangedSignal():Connect(function(input: InputObject)
		local minX = input.Position.X - offset.X
		local minY = input.Position.Y - offset.Y + GuiService.TopbarInset.Height

		local absMin = Vector2.new(minX, minY)
		local absMax = absMin + container.AbsoluteSize
		local containerRect = Rect.new(absMin, absMax)

		local position = getViewportConstrainedPosition(container, containerRect)

		container.Position = position
		state.position = position
	end)

	local dragEnded = dragger:GetDragEndedSignal():Connect(function(_input: InputObject)
		for _isLegacy, selector: any in state.selectors do
			selector:GetContainer().Position = state.position
		end
	end)

	viewSelector.trove:Add(function()
		dragStarted:Disconnect()
		dragChanged:Disconnect()
		dragEnded:Disconnect()
		dragger:Destroy()
	end)
end

local function waitForCamera()
	while not workspace.CurrentCamera do
		workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
	end

	local vps = workspace.CurrentCamera.ViewportSize
	while vps:Dot(vps) <= 0 do
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Wait()
		vps = workspace.CurrentCamera.ViewportSize
	end
end

-- Public

type SetupOptions = {
	anchor: Vector2,
	position: UDim2,

	getSelectedCFrame: () -> CFrame?,

	useLegacy: () -> boolean,
	useLegacyChanged: RBXScriptSignal,

	useLocalSpace: () -> boolean,
	useLocalSpaceChanged: RBXScriptSignal,
}

function module.setup(parent: ScreenGui, options: SetupOptions)
	waitForCamera()

	state.trove:Clean()
	state.position = options.position

	for _isLegacy, viewSelector: any in state.selectors do
		wrapDragger(viewSelector)

		local container = viewSelector:GetContainer()
		container.AnchorPoint = options.anchor
		container.Position = options.position
		container.Parent = parent
	end

	local isWorldSpaceEnabled = true
	local function setWorldSpaceEnabled(enabled: boolean)
		isWorldSpaceEnabled = not not enabled
	end

	local function render()
		if not options then
			return
		end

		local useLegacy = options.useLegacy()
		local useLocalSpace = options.useLocalSpace()

		local objectSpaceCF: CFrame?
		if useLocalSpace then
			objectSpaceCF = options.getSelectedCFrame()
		end

		for isLegacy, viewSelector: any in state.selectors do
			local isWorldSpace = not objectSpaceCF
			local isVisible = (isLegacy == useLegacy) and (isWorldSpaceEnabled or not isWorldSpace)

			if isVisible then
				viewSelector:SetAxisColor(isWorldSpace)
				viewSelector:Render(objectSpaceCF or CFrame.identity)
			end

			viewSelector:SetVisible(isVisible)
		end
	end

	state.trove:Add(options.useLegacyChanged:Connect(render))
	state.trove:Add(options.useLocalSpaceChanged:Connect(render))

	state.trove:Add(function()
		for _isLegacy, viewSelector: any in state.selectors do
			viewSelector:SetVisible(false)
		end
	end)

	render()

	return {
		render = render,
		setWorldSpaceEnabled = setWorldSpaceEnabled,

		save = function()
			return {
				version = 1,
				anchor = options.anchor,
				position = state.position,
			}
		end,
	}
end

return module
