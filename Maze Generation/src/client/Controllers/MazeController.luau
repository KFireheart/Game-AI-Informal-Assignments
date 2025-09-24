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

    -- Use simple 2D arrays for walls between cells
    self.horizontalWalls = {} -- Walls running horizontally (between rows)
    self.verticalWalls = {}   -- Walls running vertically (between columns)
    self.visitedCells = {}
    self.cellStack = {}
    self.currentCell = {x = 1, y = 1}

    self.cellSize = 8
    self.wallHeight = 10
    self.wallThickness = 1
    
    self:InitializeArrays()
end

function MazeController:KnitStart()
    self:GenerateMaze()
end

function MazeController:InitializeArrays()
    local size = Constants.MAZE.MAZE_SIZE
    
    -- Initialize visited cells
    for x = 1, size do
        self.visitedCells[x] = {}
        for y = 1, size do
            self.visitedCells[x][y] = false
        end
    end
    
    -- Initialize walls
    -- Horizontal walls (between rows)
    for x = 1, size do
        self.horizontalWalls[x] = {}
        for y = 1, size - 1 do 
            self.horizontalWalls[x][y] = true
        end
    end
    
    -- Vertical walls (between columns)  
    for x = 1, size - 1 do 
        self.verticalWalls[x] = {}
        for y = 1, size do
            self.verticalWalls[x][y] = true 
        end
    end
end

function MazeController:IsValidCell(cell)
    local size = Constants.MAZE.MAZE_SIZE
    return cell.x >= 1 and cell.x <= size and 
           cell.y >= 1 and cell.y <= size
end

function MazeController:IsCellVisited(cell)
    if not self:IsValidCell(cell) then
        return true
    end
    return self.visitedCells[cell.x][cell.y]
end

function MazeController:GetUnvisitedNeighbors(cell)
    local neighbors = {}
    local directions = {
        {x = 1, y = 0},   -- Right
        {x = -1, y = 0},  -- Left
        {x = 0, y = 1},   -- Down  
        {x = 0, y = -1},  -- Up
    }
    
    for _, direction in pairs(directions) do
        local neighbor = {
            x = cell.x + direction.x,
            y = cell.y + direction.y
        }
        
        if self:IsValidCell(neighbor) and not self:IsCellVisited(neighbor) then
            table.insert(neighbors, neighbor)
        end
    end
    
    return neighbors
end

function MazeController:RemoveWallBetween(cell1, cell2)
    local dx = cell2.x - cell1.x
    local dy = cell2.y - cell1.y
    
    if dx == 1 then
        -- Moving right: remove vertical wall to the right of cell1
        self.verticalWalls[cell1.x][cell1.y] = false
    elseif dx == -1 then
        -- Moving left: remove vertical wall to the left of cell1  
        self.verticalWalls[cell2.x][cell2.y] = false
    elseif dy == 1 then
        -- Moving down: remove horizontal wall below cell1
        self.horizontalWalls[cell1.x][cell1.y] = false
    elseif dy == -1 then
        -- Moving up: remove horizontal wall above cell1
        self.horizontalWalls[cell2.x][cell2.y] = false
    end
end

function MazeController:GenerateMaze()
    
    -- Mark starting cell as visited
    self.visitedCells[self.currentCell.x][self.currentCell.y] = true
    table.insert(self.cellStack, {x = self.currentCell.x, y = self.currentCell.y})
    
    local iterations = 0
    local maxIterations = 50000
    
    while #self.cellStack > 0 and iterations < maxIterations do
        iterations = iterations + 1
        
        local neighbors = self:GetUnvisitedNeighbors(self.currentCell)
        
        if #neighbors > 0 then
            -- Choose random unvisited neighbor
            local nextCell = neighbors[math.random(1, #neighbors)]
            
            -- Remove wall between current cell and chosen neighbor
            self:RemoveWallBetween(self.currentCell, nextCell)
            
            -- Mark neighbor as visited
            self.visitedCells[nextCell.x][nextCell.y] = true
            
            -- Push current cell to stack
            table.insert(self.cellStack, {x = self.currentCell.x, y = self.currentCell.y})
            
            self.currentCell = {x = nextCell.x, y = nextCell.y}
        else
            -- Backtrack: pop from stack
            if #self.cellStack > 0 then
                self.currentCell = table.remove(self.cellStack)
            end
        end
        
        -- Yield occasionally to prevent timeout
        if iterations % 100 == 0 then
            RunService.Heartbeat:Wait()
        end
    end
        
    -- Build the physical walls
    self:BuildWalls()
end

function MazeController:BuildWalls()
    print("Building physical walls...")
    local wallCount = 0
    local size = Constants.MAZE.MAZE_SIZE
    local CELL_SIZE = self.cellSize -- Size of each maze cell
    local WALL_THICKNESS = self.wallThickness -- Thickness of walls
    local WALL_HEIGHT = self.wallHeight
    
    -- Create a folder to organize walls
    local wallFolder = Instance.new("Folder")
    wallFolder.Name = "MazeWalls"
    wallFolder.Parent = workspace
    
    -- Build horizontal walls (walls between rows)
    for x = 1, size do
        for y = 1, size - 1 do
            if self.horizontalWalls[x][y] then
                local wall = Instance.new("Part")
                wall.Name = "HorizontalWall_" .. x .. "_" .. y
                wall.Position = Vector3.new(
                    x * CELL_SIZE,
                    WALL_HEIGHT / 2,
                    (y * CELL_SIZE) + (CELL_SIZE / 2)
                )
                wall.Size = Vector3.new(CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS)
                wall.Anchored = true
                wall.Color = Color3.new({0, 0, 0})
                wall.Parent = wallFolder
                wallCount = wallCount + 1
            end
        end
    end
    
    -- Build vertical walls (walls between columns)
    for x = 1, size - 1 do
        for y = 1, size do
            if self.verticalWalls[x][y] then
                local wall = Instance.new("Part")
                wall.Name = "VerticalWall_" .. x .. "_" .. y
                wall.Position = Vector3.new(
                    (x * CELL_SIZE) + (CELL_SIZE / 2),
                    WALL_HEIGHT / 2,
                    y * CELL_SIZE
                )
                wall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, CELL_SIZE)
                wall.Anchored = true
                wall.Color = Color3.new({0, 0, 0})
                wall.Parent = wallFolder
                wallCount = wallCount + 1
            end
        end
    end
    
    -- Build perimeter walls
    -- Top wall
    local topWall = Instance.new("Part")
    topWall.Name = "TopWall"
    topWall.Position = Vector3.new((size * CELL_SIZE) / 2 + CELL_SIZE/2, WALL_HEIGHT / 2, CELL_SIZE / 2)
    topWall.Size = Vector3.new(size * CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS)
    topWall.Anchored = true
    topWall.Color = Color3.new(0.505882, 0.396078, 1)
    topWall.Parent = wallFolder
    
    -- Bottom wall
    local bottomWall = Instance.new("Part")
    bottomWall.Name = "BottomWall"
    bottomWall.Position = Vector3.new((size * CELL_SIZE) / 2 + CELL_SIZE/2, WALL_HEIGHT / 2, size * CELL_SIZE + CELL_SIZE/2)
    bottomWall.Size = Vector3.new(size * CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS)
    bottomWall.Anchored = true
    bottomWall.Color = Color3.new(0.505882, 0.396078, 1)
    bottomWall.Parent = wallFolder
    
    -- Left wall
    local leftWall = Instance.new("Part")
    leftWall.Name = "LeftWall"
    leftWall.Position = Vector3.new(CELL_SIZE / 2, WALL_HEIGHT / 2, (size * CELL_SIZE) / 2 + CELL_SIZE/2)
    leftWall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, size * CELL_SIZE)
    leftWall.Anchored = true
    leftWall.Color = Color3.new(0.505882, 0.396078, 1)
    leftWall.Parent = wallFolder
    
    -- Right wall
    local rightWall = Instance.new("Part")
    rightWall.Name = "RightWall"
    rightWall.Position = Vector3.new(size * CELL_SIZE + CELL_SIZE/2, WALL_HEIGHT / 2, (size * CELL_SIZE) / 2 + CELL_SIZE/2)
    rightWall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, size * CELL_SIZE)
    rightWall.Anchored = true
    rightWall.Color = Color3.new(0.505882, 0.396078, 1)
    rightWall.Parent = wallFolder
    
    print("Built " .. wallCount .. " internal walls + 4 perimeter walls!")
end

function MazeController:ClearMaze()
    local existingFolder = workspace:FindFirstChild("MazeWalls")
    if existingFolder then
        existingFolder:Destroy()
    end
    
    -- Reset arrays
    self.visitedCells = {}
    self.cellStack = {}
    self.horizontalWalls = {}
    self.verticalWalls = {}
    self.currentCell = {x = 1, y = 1}
    
    self:InitializeArrays()
end

-- #region Getters and Setters

function MazeController:GetMazeSize()
    return self.cellSize
end

function MazeController:GetWallHeight()
    return self.wallHeight
end

function MazeController:GetWallThickness()
    return self.wallThickness
end

function MazeController:SetMazeSize(size)
    self.cellSize = size
    self:ClearMaze()
    self:GenerateMaze()
end

function MazeController:SetWallHeight(height)
    self.wallHeight = height
    self:ClearMaze()
    self:GenerateMaze()
end

function MazeController:SetWallThickness(thickness)
    self.wallThickness = thickness
    self:ClearMaze()
    self:GenerateMaze()
end

return MazeController