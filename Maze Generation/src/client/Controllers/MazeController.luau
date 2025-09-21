local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local Janitor = require(Constants.PACKAGE_PATHS.JANITOR)
local RunService = game:GetService("RunService")

local MazeController = Knit.CreateController({
    Name = Constants.CONTROLLERS.MAZE_CONTROLLER,
})

function MazeController:KnitInit()
    self.janitor = Janitor.new()

end

function MazeController:KnitStart()
    print("MazeController started")
end

return MazeController