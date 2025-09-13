local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local Janitor = require(Constants.PACKAGE_PATHS.JANITOR)

local GridController = Knit.CreateController({Name = Constants.CONTROLLERS.GRID_CONTROLLER})

function GridController:KnitInit()
    self.janitor = Janitor.new()


    self.cells = {}

    self.current_grid = {}
    self.next_grid = {}
end

function GridController:KnitStart()
    -- Run the grid function
    self:LifeGrid(Constants.GRID_COLUMNS, Constants.GRID_ROWS, self.cells)
    self:Run(100)
end

function GridController:LifeGrid(columns, rows, cells)
    for row = 0, rows - 1 do
        for column = 0, columns - 1 do
            
            if(cells[rows * columns + column] == 1) then
                self.current_grid.insert(rows * columns + column)
            end
        end
    end
end

function GridController:GetCell(y, x)
    if(self.current_grid.has(y * Constants.GRID_COLUMNS + x)) then
        return true
    else
        return false
    end
end

function GridController:SetCell(y, x, value)
    if(value) then
        self.current_grid.insert(y * Constants.GRID_ROWS + x)
    else
        self.current_grid.remove(y * Constants.GRID_ROWS + x)
    end
end


function GridController:SwapGrids()
    self.current_grid = self.next_grid
    self.next_grid = {}
end

function GridController:CountNeighbors(y, x)
    local neighbors = 0

    local offsets = {
        {0, 1},
        {0, -1},
        {1, 0},
        {-1, 0},
        {1, 1},
    }

    for dy, _ in offsets do
        for dx, _ in offsets do
            if(dy == 0 and dx == 0) then continue end

            local ny = (y + dy + Constants.GRID_COLUMNS) % Constants.GRID_COLUMNS
            local nx = (x + dx + Constants.GRID_ROWS) % Constants.GRID_ROWS

            local alive = self:GetCell(ny, nx)
            if(alive) then
                neighbors += 1
            end
        end
    end

    return neighbors
end

function GridController:Step()

    --Steps:
    -- Any live cell with fewer than two live neighbours dies, as if by underpopulation.
    -- Any live cell with two or three live neighbours lives on to the next generation.
    -- Any live cell with more than three live neighbours dies, as if by overpopulation.
    -- Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

   for rows = 0, Constants.GRID_ROWS - 1 do
        for columns = 0, Constants.GRID_COLUMNS - 1 do

            local alive = self:GetCell(rows, columns)
            local neighbors = self:CountNeighbors(rows, columns)


            if(alive and (neighbors < 2 or neighbors > 3)) then
                self:SetCell(rows, columns, false)
            end

            if(alive and (neighbors == 2 or neighbors == 3)) then
                self:SetCell(rows, columns, true)
            end

            if(not alive and neighbors == 3) then
                self:SetCell(rows, columns, true)
            end
        end
    end

    self:SwapGrids()
end

function GridController:Run(number_of_steps)
    for i = 1, number_of_steps do
        self:Step()
        --task.wait(0.1)
    end
end

function GridController:CloneCube(y, x)
    local cube = ReplicatedStorage.Shared.Cubes:WaitForChild("Cube")
    local cube_instance = cube:Clone()
    cube_instance.CFrame = CFrame.new(x, y, 0)
    cube_instance.Parent = game.Workspace
    self.janitor:Add(cube_instance, "Destroy")
    return cube_instance
end

function GridController:DeleteCube(cube)
    cube:Destroy()
    self.janitor:Remove(cube)
end

return GridController