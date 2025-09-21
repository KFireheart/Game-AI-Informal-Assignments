local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Constants)
local Knit = require(Constants.PACKAGE_PATHS.KNIT)
local ServerScriptService = game:GetService("ServerScriptService")

local services_folder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")

Knit.Shared = shared_folder
Knit.AddServices(services_folder)

Knit.Start():andThen(function()
    print("--------------------------------")
    print("Loaded Knit Services (SERVER): ", Knit.GetServices())
    print("--------------------------------")

    -- Knit Setup Logic
    local playerAddedProcesses = {}
    local playerRemovingProcesses = {}
    if(Knit.Services) then
        for _, service in pairs(Knit.Services) do
            local playerAdded = service["PlayerAdded"]
            local playerRemoving = service["PlayerRemoving"]
            if typeof(playerAdded) == "function" then
                table.insert(playerAddedProcesses, playerAdded)
            end
            if typeof(playerRemoving) == "function" then
                table.insert(playerRemovingProcesses, playerRemoving)
            end
        end
    end

    -- For Adding Existing Player
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if(playerAddedProcesses) then
            for _, added_process in pairs(playerAddedProcesses) do
                task.spawn(added_process, player)
            end
        end
    end

    -- For Adding New Players
    game:GetService("Players").PlayerAdded:Connect(function(player)
        if(playerAddedProcesses) then
            for _, added_process in pairs(playerAddedProcesses) do
                task.spawn(added_process, player)
            end
        end
    end)

    -- For Removing Players
    game:GetService("Players").PlayerRemoving:Connect(function(player)
        if(playerRemovingProcesses) then
            for _, removing_process in pairs(playerRemovingProcesses) do
                task.spawn(removing_process, player)
            end
        end
    end)
end):catch(function(errorMessage)
    print("Could not load server because", errorMessage)
end)