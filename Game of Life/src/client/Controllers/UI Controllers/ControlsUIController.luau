local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local StarterPlayer = game:GetService("StarterPlayer")
local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local Janitor = require(Constants.PACKAGE_PATHS.JANITOR)
local Players = game:GetService("Players")


local ControlsUIController = Knit.CreateController({Name = Constants.CONTROLLERS.CONTROLS_UI_CONTROLLER})

function ControlsUIController:KnitInit()
    self.janitor = Janitor.new()
    self.tween_maid = Janitor.new()

    self.controls_gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ControlsGui")
    self.controls_main_frame = self.controls_gui:WaitForChild("ControlsMainFrame")

    self.controls_button = self.controls_gui:WaitForChild("ControlsButton")
    self.close_button = self.controls_main_frame:WaitForChild("CloseButton")

    self.is_controls_open = false

    self.janitor:Add(self.controls_button.Activated:Connect(function()
        print("ControlsButton activated")
        self:OpenControls()
    end),"Disconnect")

    self.janitor:Add(self.close_button.Activated:Connect(function()
        print("CloseButton activated")
        self:CloseControls()
    end),"Disconnect")
end

function ControlsUIController:KnitStart()
    self.controls_main_frame.Visible = false
    self.controls_window_original_position = self.controls_main_frame.Position
end


function ControlsUIController:OpenControls()
    
    -- Start off-screen at the left (slide sideways animation)
    self.controls_main_frame.Position = UDim2.new(-1, 0, 0.5, 0)
    self.controls_main_frame.Visible = true
    
    -- Slide up from bottom to center
    self:SlideOpenControlsMenu(1, self.controls_main_frame.Position, self.controls_window_original_position)
    self.is_controls_open = true
    self.tween_maid:Cleanup()

end

function ControlsUIController:CloseControls()
    -- Start off-screen at the left (slide sideways animation)
    local offScreenPosition = UDim2.new(-1, 0, 0.5, 0)
    self:SlideOpenControlsMenu(1, self.controls_main_frame.Position, offScreenPosition, true)
    self.is_controls_open = false
    self.tween_maid:Cleanup()
end

function ControlsUIController:SlideOpenControlsMenu(duration: number, startPosition: UDim2, endPosition: UDim2, hideOnComplete: boolean?)
    self.controls_main_frame.Position = startPosition
    local tween_info = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
    local tween_service = game:GetService("TweenService")
    local tween = tween_service:Create(self.controls_main_frame, tween_info, {Position = endPosition})

    if hideOnComplete then
        self.tween_maid:Add(tween.Completed:Connect(function()
            self.controls_main_frame.Visible = false
        end),"Disconnect")
    end

    tween:Play()
end

return ControlsUIController