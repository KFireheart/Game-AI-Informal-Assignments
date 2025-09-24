local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local Janitor = require(Constants.PACKAGE_PATHS.JANITOR)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local MazeUIController = Knit.CreateController({
    Name = Constants.CONTROLLERS.UI_CONTROLLER,
})

function MazeUIController:KnitInit()
    self.mazeController = Knit.GetController(Constants.CONTROLLERS.MAZE_CONTROLLER)

    self.janitor = Janitor.new()
    self.tweenMaid = Janitor.new()


    --GUI
    self.mainGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MazeControls")
    self.mainFrame = self.mainGui:WaitForChild("ControlsMainFrame")
    self.controlsButton = self.mainGui:WaitForChild("ControlsButton")
    self.closeButton = self.mainFrame:WaitForChild("CloseButton")

    --Plus Buttons
    self.mazeSizePlusButton = self.mainFrame:WaitForChild("MazeSizePlus")
    self.wallHeightPlusButton = self.mainFrame:WaitForChild("MazeHeightPlus")
    self.wallThicknessPlusButton = self.mainFrame:WaitForChild("MazeWallsPlus")

    --Minus Buttons
    self.mazeSizeMinusButton = self.mainFrame:WaitForChild("MazeSizeMinus")
    self.wallHeightMinusButton = self.mainFrame:WaitForChild("MazeHeightMinus")
    self.wallThicknessMinusButton = self.mainFrame:WaitForChild("MazeWallsMinus")
    

    self.isControlsOpen = false
    self.mainFrameOriginalPosition = self.mainFrame.Position

    self.janitor:Add(self.controlsButton.Activated:Connect(function()
        print("Opening controls")
        self:OpenControls()
    end))

    self.janitor:Add(self.closeButton.Activated:Connect(function()
        self:CloseControls()
    end))

    self.janitor:Add(self.mazeSizePlusButton.Activated:Connect(function()
        self.mazeController:SetMazeSize(self.mazeController:GetMazeSize() + 1)
    end))
    self.janitor:Add(self.mazeSizeMinusButton.Activated:Connect(function()
        self.mazeController:SetMazeSize(self.mazeController:GetMazeSize() - 1)
    end))
    
    self.janitor:Add(self.wallHeightPlusButton.Activated:Connect(function()
        self.mazeController:SetWallHeight(self.mazeController:GetWallHeight() + 1)
    end))
    self.janitor:Add(self.wallHeightMinusButton.Activated:Connect(function()
        self.mazeController:SetWallHeight(self.mazeController:GetWallHeight() - 1)
    end))
    
    self.janitor:Add(self.wallThicknessPlusButton.Activated:Connect(function()
        self.mazeController:SetWallThickness(self.mazeController:GetWallThickness() + 1)
    end))
    self.janitor:Add(self.wallThicknessMinusButton.Activated:Connect(function()
        self.mazeController:SetWallThickness(self.mazeController:GetWallThickness() - 1)
    end))
    
end

function MazeUIController:KnitStart()
    self.mainFrame.Visible = false
end


function MazeUIController:OpenControls()
    
    -- Start off-screen at the left (slide sideways animation)
    self.mainFrame.Position = UDim2.new(-1, 0, 0.5, 0)
    self.mainFrame.Visible = true
    
    -- Slide up from bottom to center
    self:SlideOpenControlsMenu(1, self.mainFrame.Position, self.mainFrameOriginalPosition)
    self.isControlsOpen = true
    self.tweenMaid:Cleanup()

end

function MazeUIController:CloseControls()
    -- Start off-screen at the left (slide sideways animation)
    local offScreenPosition = UDim2.new(-1, 0, 0.5, 0)
    self:SlideOpenControlsMenu(1, self.mainFrame.Position, offScreenPosition, true)
    self.isControlsOpen = false
    self.tweenMaid:Cleanup()
end

function MazeUIController:SlideOpenControlsMenu(duration: number, startPosition: UDim2, endPosition: UDim2, hideOnComplete: boolean?)
    self.mainFrame.Position = startPosition
    local tween_info = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
    local tween_service = game:GetService("TweenService")
    local tween = tween_service:Create(self.mainFrame, tween_info, {Position = endPosition})

    if hideOnComplete then
        self.tweenMaid:Add(tween.Completed:Connect(function()
            self.mainFrame.Visible = false
        end),"Disconnect")
    end

    tween:Play()
end


return MazeUIController