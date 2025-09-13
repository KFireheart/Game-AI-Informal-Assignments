local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local Janitor = require(Constants.PACKAGE_PATHS.JANITOR)

local GridController = Knit.CreateController({Name = Constants.CONTROLLERS.GRID_CONTROLLER})

function GridController:KnitInit()
    self.janitor = Janitor.new()

    self.grid = {}
end

return GridController