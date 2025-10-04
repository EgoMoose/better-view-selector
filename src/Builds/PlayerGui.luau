--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")

local UserInterface = require(pluginRoot.Main.UserInterface)

local PlayerGui = {}

-- Public

function PlayerGui.build(player: Player)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CFrame = CFrame.new(0, 10, 0)
	part.Parent = workspace

	local screen = Instance.new("ScreenGui")
	screen.Name = "BetterViewSelector"
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.Parent = player.PlayerGui

	local _unmount = UserInterface.mount(screen)
end

return PlayerGui
