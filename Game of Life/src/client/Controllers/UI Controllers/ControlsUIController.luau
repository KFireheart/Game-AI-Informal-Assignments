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

    --Grid Controller
    self.grid_controller = Knit.GetController(Constants.CONTROLLERS.GRID_CONTROLLER)

    self.controls_gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ControlsGui")
    self.controls_main_frame = self.controls_gui:WaitForChild("ControlsMainFrame")

    self.controls_button = self.controls_gui:WaitForChild("ControlsButton")
    self.close_button = self.controls_main_frame:WaitForChild("CloseButton")

    self.is_controls_open = false


    -- Buttons
    self.play_button = self.controls_main_frame:WaitForChild("PlayButton")
    self.stop_button = self.controls_main_frame:WaitForChild("StopButton")
    self.reset_button = self.controls_main_frame:WaitForChild("ResetButton")
    self.angel_button = self.controls_main_frame:WaitForChild("AngelButton")
    self.glider_button = self.controls_main_frame:WaitForChild("GliderButton")
    self.blinker_button = self.controls_main_frame:WaitForChild("BlinkerButton")

    --text box
    self.speed_input = self.controls_main_frame:WaitForChild("SpeedTextBox")

    --labels
    self.current_selection_label = self.controls_main_frame:WaitForChild("CurrentSelection")

    --Current Selection
    self.current_selection = "None"


    
--#region Buttons
    self.janitor:Add(self.controls_button.Activated:Connect(function()
        print("ControlsButton activated")
        self:OpenControls()
    end),"Disconnect")

    self.janitor:Add(self.close_button.Activated:Connect(function()
        print("CloseButton activated")
        self:CloseControls()
    end),"Disconnect")

    self.janitor:Add(self.play_button.Activated:Connect(function()
        print("PlayButton activated")
        self:Play()
    end),"Disconnect")
    
    self.janitor:Add(self.stop_button.Activated:Connect(function()
        print("StopButton activated")
        self:Stop()
    end),"Disconnect")
    
    self.janitor:Add(self.reset_button.Activated:Connect(function()
        print("ResetButton activated")
        self:Reset()
    end),"Disconnect")
    
    self.janitor:Add(self.angel_button.Activated:Connect(function()
        print("AngelButton activated")
        self:Angel()
    end),"Disconnect")
    
    
    self.janitor:Add(self.glider_button.Activated:Connect(function()
        print("GliderButton activated")
        self:Glider()
    end),"Disconnect")
    
    
    self.janitor:Add(self.blinker_button.Activated:Connect(function()
        print("BlinkerButton activated")
        self:Blinker()
    end),"Disconnect")


--#endregion
    
--#region TextBox
    self.janitor:Add(self.speed_input.FocusLost:Connect(function()
        print("SpeedTextBox focus lost")
        self:ChangeSpeed()
    end),"Disconnect")
--#endregion
    
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

function ControlsUIController:Play()
    self.grid_controller:Start()
end

function ControlsUIController:Stop()
    self.grid_controller:Stop()
end

function ControlsUIController:Reset()
    print("Reset")
    self.grid_controller:Reset()
end

function ControlsUIController:Angel()
    print("Angel")
    self.current_selection = "Angel"
    self.current_selection_label.Text = self.current_selection
    self.grid_controller:SetSelection(self.current_selection)
end

function ControlsUIController:Glider()
    print("Glider")
    self.current_selection = "Glider"
    self.current_selection_label.Text = self.current_selection
    self.grid_controller:SetSelection(self.current_selection)
end

function ControlsUIController:Blinker()
    print("Blinker")
    self.current_selection = "Blinker"
    self.current_selection_label.Text = self.current_selection
    self.grid_controller:SetSelection(self.current_selection)
end

function ControlsUIController:ChangeSpeed()
    print("ChangeSpeed")
    self.speed = self.speed_input.Text
    self.grid_controller:ChangeSpeed(self.speed)
end

return ControlsUIController