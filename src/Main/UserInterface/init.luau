--!strict
local RunService = game:GetService("RunService")

local StudioService = game:GetService("StudioService") :: StudioService
local SelectionService = game:GetService("Selection") :: Selection

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local ReactRoblox = require(pluginRoot.Packages.ReactRoblox)
local React = require(pluginRoot.Packages.React)

local LegacyViewSelector = require(script.Components.Viewers.LegacyViewSelector)
local Hooks = require(script.Hooks)

local UserInterface = {}

local WORLD_SPACE_COLOR_MAP = {
	[Enum.Axis.X] = Color3.new(1, 0, 0),
	[Enum.Axis.Y] = Color3.new(0, 1, 0),
	[Enum.Axis.Z] = Color3.new(0, 0, 1),
}

local OBJECT_SPACE_COLOR_MAP = {
	[Enum.Axis.X] = Color3.new(1, 0, 1),
	[Enum.Axis.Y] = Color3.new(1, 1, 0),
	[Enum.Axis.Z] = Color3.new(0, 1, 1),
}

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

local function getRenderCFrame()
	local isWorldSpace = true
	local worldCF = CFrame.identity
	if StudioService.UseLocalSpace then
		local selection = SelectionService:Get()
		local selectedCF = if #selection == 1 then tryGetCFrame(selection[1]) else nil
		if selectedCF then
			worldCF = selectedCF
			isWorldSpace = false
		end
	end

	local cameraCF = (workspace.CurrentCamera :: Camera).CFrame
	return cameraCF:ToObjectSpace(worldCF), isWorldSpace
end

local function App()
	local initialRenderCF, initialIsWorldSpace = Hooks.useConstant(function()
		return getRenderCFrame()
	end)

	local renderCF, setRenderCF = React.useState(initialRenderCF)
	local isWorldSpace, setIsWorldSpace = React.useState(initialIsWorldSpace)

	React.useEffect(function()
		local connection = RunService.PreRender:Connect(function()
			local renderCF, isWorldSpace = getRenderCFrame()
			setRenderCF(renderCF)
			setIsWorldSpace(isWorldSpace)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement(LegacyViewSelector, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.6, 0.6),
		ZIndex = -1,

		Rotation = renderCF,
		ColorMap = if isWorldSpace then WORLD_SPACE_COLOR_MAP else OBJECT_SPACE_COLOR_MAP,
	})
end

function UserInterface.mountAsync()
	local viewSelector = game:GetService("CoreGui"):WaitForChild("ViewSelectorScreenGui") :: ScreenGui
	local defaultZIndexBehavior = viewSelector.ZIndexBehavior

	local panel = viewSelector:WaitForChild("Panel")
	local viewport = panel:WaitForChild("Viewport") :: ViewportFrame
	local arrowButtons = panel:WaitForChild("ArrowButtons") :: Frame
	local xLabel = panel:WaitForChild("X") :: TextLabel
	local yLabel = panel:WaitForChild("Y") :: TextLabel
	local zLabel = panel:WaitForChild("Z") :: TextLabel

	local function setBuiltInViewSelectorVisible(visible: boolean)
		local transparency = if visible then 0 else 1
		viewSelector.ZIndexBehavior = if visible then defaultZIndexBehavior else Enum.ZIndexBehavior.Sibling
		viewport.ImageTransparency = transparency
		xLabel.TextTransparency = transparency
		yLabel.TextTransparency = transparency
		zLabel.TextTransparency = transparency
		for _, arrow in arrowButtons:QueryDescendants(">ImageButton") do
			arrow.Visible = visible
		end
	end

	local folder = Instance.new("Folder")
	folder.Name = "BetterViewSelector"
	folder.Parent = panel

	setBuiltInViewSelectorVisible(false)
	local root = ReactRoblox.createRoot(folder)
	root:render(React.createElement(App))

	return function()
		setBuiltInViewSelectorVisible(true)
		root:unmount()
		folder:Destroy()
	end
end

return UserInterface
