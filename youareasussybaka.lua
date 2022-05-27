repeat
    task.wait()

until game:IsLoaded()

local System = {}
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local PlaceId = game.PlaceId

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.RemoteEvent
local RemoteFunction = ReplicatedStorage.RemoteFunction

if PlaceId == 3260590327 then
    local Troops = ReplicatedStorage.Assets.Troops
    local Elevators = game:GetService("Workspace").Elevators

    function System:Loadout(...)
        local Arguments = {...}

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Getting loadout",
            Duration = 5
        })

        local PlayerTowers = {}

        for Tower, Stats in pairs(RemoteFunction:InvokeServer("Session", "Search", "Inventory.Troops")) do
            PlayerTowers[Tower] = Stats
            if Stats.Equipped then
                RemoteEvent:FireServer("Inventory", "Execute", "Troops", "Remove", {
                    ["Name"] = Tower
                })
            end
        end

        for _, Tower in pairs(Arguments) do
            local Splitted = Tower:split(" ")
            if #Splitted >= 2 and Splitted[1] == "Golden" then
                table.remove(Splitted, 1)

                RemoteEvent:FireServer("Inventory", "Execute", "Troops", "Skin", {
                    ["Troop"] = table.concat(Splitted, " "),
                    ["Skin"] = "Golden"
                })
            else
                if PlayerTowers[table.concat(Splitted, " ")] then
                    local Stats = PlayerTowers[table.concat(Splitted, " ")]

                    if Stats.Skin == "Golden" then
                        RemoteEvent:FireServer("Inventory", "Execute", "Troops", "Skin", {
                            ["Troop"] = table.concat(Splitted, " "),
                            ["Skin"] = "Default"
                        })
                    end
                end
            end

            RemoteEvent:FireServer("Inventory", "Execute", "Troops", "Add", {
                ["Name"] = table.concat(Splitted, " ")
            })

            OrionLib:MakeNotification({
                Title = "TDS",
                Content = "Equipped " .. Tower,
                Duration = 5
            })
        end
    end

    function System:Map(...)
        local Args = {...}

        local MapName = Args[1]
        local Type = Args[2]

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Searching for " .. MapName,
            Duration = 5
        })

        for _, Elevator in pairs(Elevators:GetChildren()) do
            if Elevator.State.Map.Title.Value == MapName and Elevator.State.Players.Value == 0 and
                require(Elevator.Settings).Type == Type then
                OrionLib:MakeNotification({
                    Title = "TDS",
                    Content = "Teleporting to " .. MapName,
                    Duration = 5
                })

                RemoteEvent:FireServer("Elevators", "Enter", Elevator)

                repeat
                    task.wait()
                until Elevator.State.Players.Value > 1

                RemoteEvent:FireServer("Elevators", "Leave")

                OrionLib:MakeNotification({
                    Title = "TDS",
                    Content = "Player joined, researching map...",
                    Duration = 5
                })
            else
                RemoteEvent:FireServer("Elevators", "Enter", Elevator)
                wait(.25);
                RemoteEvent:FireServer("Elevators", "Leave")

                Elevator.State.Map.Title.Changed:Connect(function()
                    if Elevator.State.Map.Title.Value == MapName and Elevator.State.Players.Value == 0 and
                        require(Elevator.Settings).Type == Type then
                        OrionLib:MakeNotification({
                            Title = "TDS",
                            Content = "Teleporting to " .. MapName,
                            Duration = 5
                        })

                        RemoteEvent:FireServer("Elevators", "Enter", Elevator)

                        repeat
                            task.wait()
                        until Elevator.State.Players.Value > 1

                        RemoteEvent:FireServer("Elevators", "Leave")

                        OrionLib:MakeNotification({
                            Title = "TDS",
                            Content = "Player joined, researching map...",
                            Duration = 5
                        })
                    else
                        RemoteEvent:FireServer("Elevators", "Enter", Elevator)
                        wait(.25);
                        RemoteEvent:FireServer("Elevators", "Leave")
                    end
                end)
            end
        end
    end
else
    local State = ReplicatedStorage.State
    local Towers = workspace.Towers

    local Count = 0

    Towers.ChildAdded:Connect(function(Tower)
        Count = Count + 1

        Tower.Name = Count
    end)

    function System:Loadout()
        return
    end

    function System:Map()
        return
    end

    function System:Vote(...)
        local Args = {...};

        local Mode = Args[1]
        RemoteFunction:InvokeServer("Difficulty", "Vote", Mode)

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Voted for " .. Mode,
            Duration = 5
        })
    end

    function System:Place(...)
        local Args = {...};

        local TowerName = Args[1];
        local Wave = Args[2];
        local Time = Args[3];

        local PositionX = Args[4];
        local PositionY = Args[5];
        local PositionZ = Args[6];

        repeat
            task.wait()
        until State.Wave.Value == Wave and State.Timer.Time.Value == Time or State.Wave.Value == Wave and State.Timer.Time.Value == (Time - 1)

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Placed " .. TowerName,
            Duration = 5
        })

        local RotationX = Args[7];
        local RotationY = Args[8];
        local RotationZ = Args[9];

        RemoteFunction:InvokeServer("Troops", "Place", TowerName, {
            ["Rotation"] = CFrame.new(RotationX, RotationY, RotationZ),
            ["Position"] = Vector3.new(PositionX, PositionY, PositionZ)
        })
    end

    function System:Skip(...)
        local Args = {...}

        local Wave = Args[1]
        local Time = Args[2]

        repeat
            task.wait()
        until State.Wave.Value == Wave and State.Timer.Time.Value == Time or State.Wave.Value == Wave and State.Timer.Time.Value == (Time - 1)

        RemoteFunction:InvokeServer("Waves", "Skip")

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Skipped wave " .. Wave,
            Duration = 5
        })
    end

    function System:Upgrade(...)
        local Args = {...}

        local Index = Args[1]
        local Wave = Args[2]
        local Time = Args[3]

        repeat
            task.wait()
        until State.Wave.Value == Wave and State.Timer.Time.Value == Time or State.Wave.Value == Wave and State.Timer.Time.Value == (Time - 1)

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Upgraded tower with id " .. Index,
            Duration = 5
        })

        RemoteFunction:InvokeServer("Troops", "Upgrade", "Set", {
            ["Troop"] = Towers:FindFirstChild(tostring(Index))
        })
    end

    function System:Ability(...)
        local Args = {...}

        local Index = Args[1]
        local Ability = Args[2]
        local Wave = Args[3]
        local Time = Args[4]

        repeat
            task.wait()
        until State.Wave.Value == Wave and State.Timer.Time.Value == Time or State.Wave.Value == Wave and State.Timer.Time.Value == (Time - 1)

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Used ability " .. Ability .. " on tower with id " .. Index,
            Duration = 5
        })

        RemoteFunction:InvokeServer("Troops", "Abilities", "Activate", {
            ["Troop"] = Towers:FindFirstChild(tostring(Index)),
            ["Name"] = Ability
        })
    end

    function System:Target(...)
        local Args = {...}

        local Index = Args[1]
        local Wave = Args[2]
        local Time = Args[3]

        repeat
            task.wait()
        until State.Wave.Value == Wave and State.Timer.Time.Value == Time or State.Wave.Value == Wave and State.Timer.Time.Value == (Time - 1)

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Targeted tower with id " .. Index,
            Duration = 5
        })

        RemoteFunction:InvokeServer("Troops", "Target", "Set", {
            ["Troop"] = Towers:FindFirstChild(tostring(Index))
        })
    end

    function System:Sell(...)
        local Args = {...}

        local Index = Args[1]
        local Wave = Args[2]
        local Time = Args[3]

        repeat
            task.wait()
        until State.Wave.Value == Wave and State.Timer.Time.Value == Time or State.Wave.Value == Wave and State.Timer.Time.Value == (Time - 1)

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Sold tower with id " .. Index,
            Duration = 5
        })

        RemoteFunction:InvokeServer("Troops", "Sell", {
            ["Troop"] = Towers:FindFirstChild(tostring(Index))
        })
    end

    function System:Vote(...)
        local Args = {...}

        local Mode = Args[1]

        RemoteFunction:InvokeServer("Difficulty", "Vote", Mode)

        OrionLib:MakeNotification({
            Title = "TDS",
            Content = "Voted for " .. Mode,
            Duration = 5
        })
    end
end

return System
