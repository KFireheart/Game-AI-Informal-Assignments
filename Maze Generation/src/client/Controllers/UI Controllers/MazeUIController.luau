local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local Janitor = require(Constants.PACKAGE_PATHS.JANITOR)
local RunService = game:GetService("RunService")

local MazeUIController = Knit.CreateController({
    Name = Constants.CONTROLLERS.UI_CONTROLLER,
})

function MazeUIController:KnitInit()
    print("MazeUIController initialized")
end

function MazeUIController:KnitStart()
    print("MazeUIController started")
end

return MazeUIController