--!strict

local pluginRoot = script:FindFirstAncestor("PluginRoot")

local UserInterface = require(pluginRoot.Main.UserInterface)

local PlayerGui = {}

-- Public

function PlayerGui.build(player: Player)
	local screen = Instance.new("ScreenGui")
	screen.Name = "BetterViewSelector"
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.Parent = player.PlayerGui

	local _unmount = UserInterface.mount(screen)
end

return PlayerGui
