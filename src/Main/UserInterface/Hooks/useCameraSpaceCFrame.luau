--!strict

local RunService = game:GetService("RunService") :: RunService

local pluginRoot = script:FindFirstAncestor("PluginRoot")
local React = require(pluginRoot.Packages.React)

local function useCameraSpaceCFrame(inputCF: CFrame)
	local cframe, setCFrame = React.useState(workspace.CurrentCamera.CFrame:ToObjectSpace(inputCF))

	React.useEffect(function()
		setCFrame(workspace.CurrentCamera.CFrame:ToObjectSpace(inputCF))

		local connection = RunService.PreRender:Connect(function()
			setCFrame(workspace.CurrentCamera.CFrame:ToObjectSpace(inputCF))
		end)

		return function()
			connection:Disconnect()
		end
	end, { inputCF })

	return cframe
end

return useCameraSpaceCFrame
