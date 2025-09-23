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

    -- lists
    self.horizontalWalls = {} --Formated as {x, y, z}
    self.verticalWalls = {} --Formated as {x, y, z}

    self.visitedCells = {} --Formated as {x, y, z}
    self.currentCell = {x = 0, y = 0, z = 0}
    self.visitedCells[self.currentCell.x][self.currentCell.y][self.currentCell.z] = true
end

function MazeController:KnitStart()
end

function MazeController:GetRandomDirection()
    local directions = {
        {x = 1, y = 0, z = 0},
        {x = -1, y = 0, z = 0},
        {x = 0, y = 1, z = 0},
        {x = 0, y = -1, z = 0},
    }
    return directions[math.random(1, 4)]
end

function MazeController:IsCellVisited(cell)
    return self.visitedCells[cell.x][cell.y][cell.z]
end

function MazeController:GenerateMaze()

    --Code stuff here
    for x = 1, Constants.MAZE.MAZE_SIZE do
        for y = 1, Constants.MAZE.MAZE_SIZE do
            for z = 1, Constants.MAZE.MAZE_SIZE do
                self.horizontalWalls[x][y][z] = false
                self.verticalWalls[x][y][z] = false
                self.visitedCells[x][y][z] = false
                self.currentCell = {x = x, y = y, z = z}
                self.visitedCells[self.currentCell.x][self.currentCell.y][self.currentCell.z] = true

                
            end
        end
    end

    --Build walls in phyiscal space
    self:BuildWalls()
end


function MazeController:BuildWalls()
    --Code stuff here
    for _, wall in pairs(self.horizontalWalls) do
        local wall = Instance.new("Part")
        wall.Position = wall
        wall.Size = Vector3.new(1, 5, 1)
        wall.Anchored = true
        wall.Parent = workspace
    end
    for _, wall in pairs(self.verticalWalls) do
        local wall = Instance.new("Part")
        wall.Position = wall
        wall.Size = Vector3.new(1, 5, 1)
        wall.Anchored = true
        wall.Parent = workspace
    end
end


return MazeController