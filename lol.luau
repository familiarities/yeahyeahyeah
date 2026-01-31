--[[ 
    Hood Customs Services
]]


local sethiddenproperty = function() end -- Codex is sooooo good
local cloneref = cloneref or function(o) return o end

if not game:IsLoaded() then game.Loaded:Wait() end
if game.CreatorId ~= 15018995 then return end

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local NetworkClient = cloneref(game:GetService("NetworkClient"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local HttpService = cloneref(game:GetService("HttpService"))

local local_player = Players.LocalPlayer
local data_folder = local_player:WaitForChild("DataFolder")
local main_event = ReplicatedStorage:WaitForChild("MainEvent")
local main_function = ReplicatedStorage:WaitForChild("MainFunction")
local is_ffa = ReplicatedStorage:WaitForChild("SERVER_IS_FFA", 3).Value

if not is_ffa then end

local godmode_animation = Instance.new("Animation")
godmode_animation.AnimationId = "rbxassetid://70883871260184"

local crying_animation = Instance.new("Animation")
crying_animation.AnimationId = "rbxassetid://125617560053537"

setfpscap(30)
RunService:Set3dRenderingEnabled(false)
workspace.FallenPartsDestroyHeight = 0/0
main_event:FireServer("ResetCharacter")

main_event:FireServer("ChangeHideStatsSetting", "True")
main_event:FireServer("ChangeMuscleInformation", 0)

local status = Instance.new("StringValue")
status.Value = "initialising bot"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BotStatus"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.DisplayOrder = 999999

local textLabel = Instance.new("TextLabel")
textLabel.Parent = screenGui
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.Position = UDim2.fromScale(0.5, 0.5)
textLabel.Size = UDim2.fromOffset(750, 28)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
textLabel.TextStrokeTransparency = 0
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SourceSansBold
textLabel.ZIndex = 10

status.Changed:Connect(function()
    textLabel.Text = status.Value
end)

textLabel.Text = status.Value

local bot = {
    url = "https://raw.githubusercontent.com/familiarities/yeahyeahyeah/refs/heads/main/",
    targets = {},
    target_players = {},
    bots = {},
}

local combat = {
    target_player = nil,
    target_hit_part = nil,
    target_root_part = nil,
    target_hit_cframe = nil
}

local backend = {}

do
    function backend.update_targets()
        pcall(function()
            status.Value = "updating target list"

            bot.targets = loadstring(game:HttpGet(bot.url .. "/targets.luau"))()
            bot.target_players = {}
            for i, player in Players:GetPlayers() do
                if table.find(bot.targets, player.UserId) then
                    table.insert(bot.target_players, player)
                end
            end
        end)
    end

    function backend.update_bots()
        pcall(function()
            status.Value = "updating target list"
            bot.bots = loadstring(game:HttpGet(bot.url .. "/bots.luau"))()
        end)
    end
end

local utilities = {}

function utilities.has_character(player)
    if not player then return false end
    local character = player.Character
    if not character then return false end
    if not character:FindFirstChildOfClass("Humanoid") then return false end
    if not character:FindFirstChild("UpperTorso") then return false end
    if not character:FindFirstChild("BodyEffects") then return false end
    if not character:FindFirstChild("FULLY_LOADED_CHAR") then return false end
    return true
end

function utilities.is_knocked(player)
    return player.Character.BodyEffects["K.O"].Value
end

function utilities.has_forcefield(player)
    return player.Character:FindFirstChild("ForceField") ~= nil
end

function utilities.is_dead(player)
    return player.Character.BodyEffects["Dead"].Value
end

function utilities.is_grabbed(player)
    return player.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
end

function utilities.hide_in_void()
    local_player.Character.HumanoidRootPart.CFrame = CFrame.new(
        math.random(-100000, 100000),
        math.random(0, 100000),
        math.random(-100000, 100000)
    )
    --sethiddenproperty(local_player.character.HumanoidRootPart, "PhysicsRepRootPart", nil)
end

function utilities.stomp(player)
    status.Value = "stomping target"
    local_player.Character.HumanoidRootPart.CFrame =
        CFrame.new(player.Character.UpperTorso.Position + Vector3.new(0,2.25,0))
    --sethiddenproperty(local_player.Character.HumanoidRootPart, "PhysicsRepRootPart", player.Character.UpperTorso)
    main_event:FireServer("Stomp")
end

NetworkClient.ChildRemoved:Connect(function()
    status.Value = "connection lost — rejoining"
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, local_player)
end)

local_player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    local head = character:WaitForChild("Head")

    local godmode_track = humanoid:LoadAnimation(godmode_animation)
    godmode_track.Priority = Enum.AnimationPriority.Action3
    godmode_track:Play()
    godmode_track:AdjustSpeed(0)
    godmode_track.TimePosition = 0.005
    godmode_track.Looped = true

    local crying_track = humanoid:LoadAnimation(crying_animation)
    crying_track.Priority = Enum.AnimationPriority.Action4
    crying_track:Play()
    crying_track:AdjustSpeed(0)
    crying_track.Looped = true
end)


RunService.Heartbeat:Connect(function()
    if not utilities.has_character(local_player) then
        status.Value = "waiting for character"
        return
    end

    local character = local_player.Character
    local gun = character:FindFirstChild("[DoubleBarrel]") or local_player.Backpack:FindFirstChild("[DoubleBarrel]")

    if utilities.is_knocked(local_player) then
        status.Value = "player knocked"
        return
    end

    if gun and gun.Parent ~= character then
        character.Humanoid:EquipTool(gun)
    end

    if not gun then
        status.Value = "waiting for gun"
        utilities.hide_in_void()
        return
    end

    if local_player.Character.BodyEffects.Reloading.Value then
        status.Value = "reloading gun"
        utilities.hide_in_void()
        return
    end

    if gun.Script.Ammo.Value == 0 then
        main_event:FireServer("Reload", gun)
        utilities.hide_in_void()
        return
    end

    if #bot.target_players == 0 then
        status.Value = "no targets available"
        utilities.hide_in_void()
        return
    end

    combat.target_player = nil
    status.Value = "searching for valid target"

    for _, player in bot.target_players do
        if not utilities.has_character(player) then continue end
        if utilities.has_forcefield(player) then continue end
        if utilities.is_knocked(player) and (utilities.is_dead(player) or utilities.is_grabbed(player)) then continue end

        combat.target_player = player
        break
    end

    if not combat.target_player then
        status.Value = "no valid targets"
        utilities.hide_in_void()
        return
    end

    combat.target_hit_part = combat.target_player.Character.SpecialParts.UpperTorso
    combat.target_hit_cframe = combat.target_hit_part.CFrame

    if utilities.is_knocked(combat.target_player) then
        utilities.stomp(combat.target_player)
        return
    end

    status.Value = "engaging target: " .. combat.target_player.Name

    character.HumanoidRootPart.CFrame = combat.target_hit_cframe
    --sethiddenproperty(character.HumanoidRootPart, "PhysicsRepRootPart", combat.target_hit_part)
    main_event:FireServer("Shoot", {
        {
            {
                Instance = combat.target_hit_part,
                Normal = combat.target_hit_part.Position,
                Position = combat.target_hit_part.Position
            },
            {
                Instance = combat.target_hit_part,
                Normal = combat.target_hit_part.Position,
                Position = combat.target_hit_part.Position
            },
            {
                Instance = combat.target_hit_part,
                Normal = combat.target_hit_part.Position,
                Position = combat.target_hit_part.Position
            },
            {
                Instance = combat.target_hit_part,
                Normal = combat.target_hit_part.Position,
                Position = combat.target_hit_part.Position
            },
            {
                Instance = combat.target_hit_part,
                Normal = combat.target_hit_part.Position,
                Position = combat.target_hit_part.Position
            },
            {
                Instance = combat.target_hit_part,
                Normal = combat.target_hit_part.Position,
                Position = combat.target_hit_part.Position
            },
        },

        {
            {
                thePart = combat.target_hit_part,
                theOffset = Vector3.zero
            },
            {
                thePart = combat.target_hit_part,
                theOffset = Vector3.zero
            },
            {
                thePart = combat.target_hit_part,
                theOffset = Vector3.zero
            },
            {
                thePart = combat.target_hit_part,
                theOffset = Vector3.zero
            },
            {
                thePart = combat.target_hit_part,
                theOffset = Vector3.zero
            },
            {
                thePart = combat.target_hit_part,
                theOffset = Vector3.zero
            },
        },

        local_player.Character.Head.Position,
        local_player.Character.Head.Position,
        workspace:GetServerTimeNow()
    })
end)


while task.wait(5) do
    backend.update_targets()
    backend.update_bots()

    if not data_folder.InServerQueue.Value and #bot.target_players == 0 then
        local servers = main_function:InvokeServer("GetFFAServerList")
        for _, server in servers do
            local bot_in_server = false
            for i, bot_id in bot.bots do
                if table.find(server.PlayerIDs, bot_id) then
                    bot_in_server = true
                    break
                end
            end

            local target_in_server = false
            for i, target_id in bot.targets do
                if table.find(server.PlayerIDs, target_id) then
                    target_in_server = true
                    break
                end
            end

            if bot_in_server then continue end
            if not target_in_server then continue end

            main_event:FireServer("JOIN_FFA_SERVER", server.JobId)
            break
        end
    end
end
