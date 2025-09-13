local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local ControllersFolder = StarterPlayerScripts:WaitForChild("Client"):WaitForChild("Controllers")
local UIControllersFolder = ControllersFolder:WaitForChild("UI Controllers")

Knit.Shared = SharedFolder
Knit.AddControllers(ControllersFolder)
Knit.AddControllers(UIControllersFolder)

Knit.Start():andThen(function()
    print("--------------------------------")
    print("Loaded Knit Controllers (CLIENT):", Knit.GetControllers())
    print("--------------------------------")

end):catch(function(errorMessage)
    print("Could not load client because", errorMessage)
end)