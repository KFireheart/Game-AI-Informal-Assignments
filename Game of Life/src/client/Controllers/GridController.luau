local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local Janitor = require(Constants.PACKAGE_PATHS.JANITOR)
local RunService = game:GetService("RunService")

local GridController = Knit.CreateController({Name = Constants.CONTROLLERS.GRID_CONTROLLER})

function GridController:KnitInit()
    self.janitor = Janitor.new()

    self.is_running = false
    self.current_selection = "Angel"
    self.speed = 0.2

    self.glider_cells = {}
    self.blinker_cells = {}
    self.angel_cells = {}


    --Center of the grid
    local centerY = math.floor(Constants.GRID_ROWS / 2)
    local centerX = math.floor(Constants.GRID_COLUMNS / 2)

    -- #region Glider pattern
    self.glider_cells[(centerY-1) * Constants.GRID_COLUMNS + centerX] = 1
    self.glider_cells[(centerY) * Constants.GRID_COLUMNS + (centerX+1)] = 1
    self.glider_cells[(centerY+1) * Constants.GRID_COLUMNS + (centerX+2)] = 1
    self.glider_cells[(centerY+2) * Constants.GRID_COLUMNS + (centerX+0)] = 1
    self.glider_cells[(centerY+2) * Constants.GRID_COLUMNS + (centerX+1)] = 1
    -- #endregion


    -- #region Blinker pattern
    self.blinker_cells[(centerY-1) * Constants.GRID_COLUMNS + centerX] = 1
    self.blinker_cells[(centerY) * Constants.GRID_COLUMNS + centerX] = 1
    self.blinker_cells[(centerY+1) * Constants.GRID_COLUMNS + centerX] = 1
    -- #endregion

    
    -- #region Angel pattern
    -- Head (halo)
    self.angel_cells[(centerY-3) * Constants.GRID_COLUMNS + centerX] = 1
    
    -- Wings (spread out)
    self.angel_cells[(centerY-2) * Constants.GRID_COLUMNS + (centerX-2)] = 1  -- Left wing tip
    self.angel_cells[(centerY-2) * Constants.GRID_COLUMNS + (centerX-1)] = 1  -- Left wing
    self.angel_cells[(centerY-2) * Constants.GRID_COLUMNS + (centerX+1)] = 1  -- Right wing
    self.angel_cells[(centerY-2) * Constants.GRID_COLUMNS + (centerX+2)] = 1  -- Right wing tip
    
    -- Body
    self.angel_cells[(centerY-1) * Constants.GRID_COLUMNS + centerX] = 1      -- Upper body
    self.angel_cells[centerY * Constants.GRID_COLUMNS + centerX] = 1          -- Middle body
    self.angel_cells[(centerY+1) * Constants.GRID_COLUMNS + centerX] = 1      -- Lower body
    
    -- Arms
    self.angel_cells[(centerY) * Constants.GRID_COLUMNS + (centerX-1)] = 1    -- Left arm
    self.angel_cells[(centerY) * Constants.GRID_COLUMNS + (centerX+1)] = 1    -- Right arm
    
    -- Dress bottom
    self.angel_cells[(centerY+2) * Constants.GRID_COLUMNS + (centerX-1)] = 1  -- Left dress
    self.angel_cells[(centerY+2) * Constants.GRID_COLUMNS + centerX] = 1      -- Center dress
    self.angel_cells[(centerY+2) * Constants.GRID_COLUMNS + (centerX+1)] = 1  -- Right dress
    -- #endregion

    -- Set the default selection after all patterns are defined
    self.current_selection_cells = self.angel_cells

    self.current_grid = {}
    self.next_grid = {}
    self.cube_instances = {} -- Track cube instances by position
end

function GridController:KnitStart()
    -- Run the grid function    
    self:LifeGrid(Constants.GRID_COLUMNS, Constants.GRID_ROWS, self.angel_cells)
    
    -- Create visual cubes for initial cells
    self:CreateInitialCubes()
end

function GridController:LifeGrid(columns, rows, cells)
    -- Initialize the grid from the cells array
    for index, value in pairs(cells) do
        if value == 1 then
            self.current_grid[index] = true
        end
    end
end

function GridController:CreateInitialCubes()
    -- Create visual cubes for all initial live cells
    print("Creating initial cubes...")
    local cubeCount = 0
    for index, _ in pairs(self.current_grid) do
        local y = math.floor(index / Constants.GRID_COLUMNS)
        local x = index % Constants.GRID_COLUMNS
        print("Creating cube at position:", y, x)
        self:CloneCube(y, x)
        cubeCount = cubeCount + 1
    end
    print("Created", cubeCount, "initial cubes")
end

function GridController:GetCell(y, x)
    if(self.current_grid[y * Constants.GRID_COLUMNS + x]) then
        return true
    else
        return false
    end
end

function GridController:SetCell(y, x, value)
    if(value) then
        self.current_grid[y * Constants.GRID_COLUMNS + x] = true
        self:CloneCube(y, x)
    else
        self.current_grid[y * Constants.GRID_COLUMNS + x] = nil
        self:DeleteCube(y, x)
    end
end


function GridController:SwapGrids()
    self.current_grid = self.next_grid
    self.next_grid = {}
end

function GridController:CountNeighbors(y, x)
    local neighbors = 0

    -- Check all 8 neighboring cells (including diagonals)
    local offsets = {
        {-1, -1}, {-1, 0}, {-1, 1},  -- Top row
        { 0, -1},          { 0, 1},  -- Middle row (excluding center)
        { 1, -1}, { 1, 0}, { 1, 1}   -- Bottom row
    }

    for _, offset in pairs(offsets) do
        local dy, dx = offset[1], offset[2]
        
        local ny = (y + dy + Constants.GRID_ROWS) % Constants.GRID_ROWS
        local nx = (x + dx + Constants.GRID_COLUMNS) % Constants.GRID_COLUMNS

        local alive = self:GetCell(ny, nx)
        if(alive) then
            neighbors += 1
        end
    end

    return neighbors
end

function GridController:Step()
    --print("Step")
    --Steps:
    -- Any live cell with fewer than two live neighbours dies, as if by underpopulation.
    -- Any live cell with two or three live neighbours lives on to the next generation.
    -- Any live cell with more than three live neighbours dies, as if by overpopulation.
    -- Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

    -- First, calculate the next generation in next_grid
    for rows = 0, Constants.GRID_ROWS - 1 do
        for columns = 0, Constants.GRID_COLUMNS - 1 do
            local alive = self:GetCell(rows, columns)
            local neighbors = self:CountNeighbors(rows, columns)

            if(alive and neighbors < 2) then
                --print("Cell died", rows, columns)
                self.next_grid[rows * Constants.GRID_COLUMNS + columns] = nil

            elseif(alive and neighbors > 3) then
                --print("Cell died", rows, columns)
                self.next_grid[rows * Constants.GRID_COLUMNS + columns] = nil

            elseif(alive and (neighbors == 2 or neighbors == 3)) then
                --print("Cell survived", rows, columns)
                self.next_grid[rows * Constants.GRID_COLUMNS + columns] = true
                
            elseif(not alive and neighbors == 3) then
                --print("Cell born", rows, columns)
                self.next_grid[rows * Constants.GRID_COLUMNS + columns] = true
            else
                -- Cell stays dead
                self.next_grid[rows * Constants.GRID_COLUMNS + columns] = nil
            end
        end
    end

    -- Now update the visual representation
    for rows = 0, Constants.GRID_ROWS - 1 do
        for columns = 0, Constants.GRID_COLUMNS - 1 do
            local current_alive = self:GetCell(rows, columns)
            local next_alive = self.next_grid[rows * Constants.GRID_COLUMNS + columns] ~= nil
            
            if current_alive and not next_alive then
                -- Cell died, remove cube
                self:DeleteCube(rows, columns)
            elseif not current_alive and next_alive then
                -- Cell born, create cube
                self:CloneCube(rows, columns)
            end
        end
    end

    self:SwapGrids()
end

function GridController:Run(number_of_steps)
    for i = 1, number_of_steps do
        self:Step()
    end
end

function GridController:CloneCube(y, x)
    local cube = Constants.CUBES_FOLDER:WaitForChild("Cube")
    local cube_instance = cube:Clone()
    
    -- Scale and center the grid in 3D space
    local scale = 1 -- Adjust this to change spacing between cubes
    local centerOffset = Constants.GRID_COLUMNS * scale / 2
    
    cube_instance.CFrame = CFrame.new(
        x * scale - centerOffset,  -- X position (scaled and centered)
        0,                        -- Y position (height)
        y * scale - centerOffset  -- Z position (scaled and centered)
    )
    
    cube_instance.Parent = game.Workspace
    self.janitor:Add(cube_instance, "Destroy")
    
    -- Track the cube instance by position
    local position_key = y * Constants.GRID_COLUMNS + x
    self.cube_instances[position_key] = cube_instance
    
    return cube_instance
end

function GridController:DeleteCube(y, x)
    local position_key = y * Constants.GRID_COLUMNS + x
    local cube_instance = self.cube_instances[position_key]
    
    if cube_instance then
        cube_instance:Destroy()
        self.janitor:Remove(cube_instance)
        self.cube_instances[position_key] = nil
    end
end

function GridController:ChangeSpeed(speed)
    self.speed = speed
end

function GridController:Start()
    self.is_running = true

    -- Use a proper timer instead of Heartbeat
    local function gameLoop()
        while self.is_running do
            self:Step()
            task.wait(self.speed) -- Wait x seconds between steps
        end
    end
    
    task.spawn(gameLoop)
end

function GridController:Stop()
    self.is_running = false
end

--start the current selection over again
function GridController:Reset()
    self.is_running = false

    -- Clear the grids
    self.current_grid = {}
    self.next_grid = {}

    --clear all cube instances in the workspace
    for _, cube_instance in pairs(game.Workspace:GetChildren()) do
        if(cube_instance.Name == "Cube") then
            cube_instance:Destroy()
        end
    end
    self.cube_instances = {}

    -- Initialize the grid with the current selection cells
    self:LifeGrid(Constants.GRID_COLUMNS, Constants.GRID_ROWS, self.current_selection_cells)
    self:CreateInitialCubes()
end

function GridController:SetSelection(selection)
    self.current_selection = selection
    if(selection == "Angel") then
        self.current_selection_cells = self.angel_cells
    elseif(selection == "Glider") then
        self.current_selection_cells = self.glider_cells
    elseif(selection == "Blinker") then
        self.current_selection_cells = self.blinker_cells
    end
end

return GridController