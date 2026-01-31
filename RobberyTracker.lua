repeat task.wait() until game:IsLoaded()

-- FIREBASE CONFIGURATION
local FIREBASE_BASE_URL = "https://robbery-tracker-d43c5-default-rtdb.firebaseio.com/robberies/"

local Webhooks = {
    ["Rising City Bank"] = "https://discord.com/api/webhooks/1464670766841860126/PpoBgXPlGA4J9pdLCRJEUr9PAAkLxvi5SPbArARwlol_Vu9Dkmu6hLAfrf0mlEAvMGJH",
    ["Crater City Bank"] = "https://discord.com/api/webhooks/1464671245822857468/ycNERxxt8CiLcwnLZEJOpx_9veXGaKCHPtFXgc7EabBn506Hs8Boh2hdeJW7cycAX3TA",
    ["Jewelry Store"] = "https://discord.com/api/webhooks/1464670195896549457/-g95aDBEu9u3pn2M9ow7ChXxRTNyj847ahfWMLdXbnnYVNOVLOiUV5IvfVhWETjDKKFE",
    ["Museum"] = "https://discord.com/api/webhooks/1464671504435515454/G5DlXxy_u9IofQ_iyfCKlQGB_Q1SqG18Gi1XJlZppB_e4eqwXePUmbS8palWk1utsAgT",
    ["Casino"] = "https://discord.com/api/webhooks/1464671652343316542/4rbjQ-ckC-N-lR29ScuXO-mas98ZH_6R-hBlv_mVhSAS0nZrvocxMM2LyptaxXzL5PxT",
    ["Cargo Train"] = "https://discord.com/api/webhooks/1464671819499044930/dOp2Riuc9u_4KviKFAGITitz5Zs3sbVSkHoY8CUzSoeOaLJZ-8GTvACExqKGmKrlKmwN",
    ["Mansion"] = "https://discord.com/api/webhooks/1464672060159561885/dIXoAqZzJal-MhsM2KgmKTOvvTMI50IT4bv8elLSrfPlSE1ovHQrRm3xk4MbInTqf0BV",
    ["Tomb"] = "https://discord.com/api/webhooks/1464672202933796987/091LsMHRz2GUL7ymQ_RDU0jV4Xi87k6YnDT0heXmpAUMh5g0Su15ZCgbdObZRxucmX3b",
    ["Airdrop"] = "https://discord.com/api/webhooks/1464672331291955305/Kc_1Q8qxIIb8qVvn_8bmBj1vjjYa9IpNX2ZWXdLnKXoN4ibxxIlwyeF0GPs3MI0jotwD",
    ["PowerPlant"] = "https://discord.com/api/webhooks/1464711922191695913/sZSMxS9pE58uwCvidx3MkEoTzJ73O3c0AatUSG8WsVrfxYkB44bm42zNHXxvJ4s9oYS9"
}

-- CONFIGURATION
local HOP_DELAY = 20 
local MAX_PLAYERS = 22 

local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

if not _G.ServerBlacklist then _G.ServerBlacklist = {} end
math.randomseed(tick() + LocalPlayer.UserId)

local alreadyNotified = {} 
local Icons = {
    ["Jewelry Store"]="💎", ["PowerPlant"]="⚡", ["Museum"]="🏛️", ["Rising City Bank"]="💰", 
    ["Crater City Bank"]="🏦", ["Casino"]="🎰", ["Mansion"]="🏰", ["Tomb"]="⚰️", 
    ["Cargo Train"]="🚂", ["Red Airdrop"]="🎁", ["Blue Airdrop"]="📦", ["Brown Airdrop"]="💼"
}

local function formatGameTime(decimalTime)
    local hours = math.floor(decimalTime)
    local minutes = math.floor((decimalTime - hours) * 60)
    local period = "AM"
    if hours >= 12 then period = "PM" if hours > 12 then hours = hours - 12 end
    elseif hours == 0 then hours = 12 end
    return string.format("%d:%02d %s", hours, minutes, period)
end

-- CLEANUP FUNCTION: Removes data older than 5 minutes from Firebase
local function cleanupDatabase()
    local success, response = pcall(function()
        return (http_request or request)({
            Url = FIREBASE_BASE_URL .. ".json",
            Method = "GET"
        })
    end)

    if success and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        if not data then return end
        
        local currentTime = os.time()
        for key, info in pairs(data) do
            if info.lastUpdated and (currentTime - info.lastUpdated > 300) then
                pcall(function()
                    (http_request or request)({
                        Url = FIREBASE_BASE_URL .. key .. ".json",
                        Method = "DELETE"
                    })
                end)
            end
        end
    end
end

-- SEND ALERT: Sends to both Discord and Firebase
local function sendAlert(name, status, isSpecial)
    if alreadyNotified[name] then return end 
    alreadyNotified[name] = true 

    local lookupName = name:find("Airdrop") and "Airdrop" or name
    local targetUrl = Webhooks[lookupName]
    local currentIcon = Icons[name] or "🚨"
    local displayTime = formatGameTime(Workspace:FindFirstChild("Time") and Workspace.Time.Value or 0)

    -- 1. SEND TO DISCORD
    if targetUrl and targetUrl ~= "" then
        local embedColor = isSpecial and 3447003 or (status == "Open" and 65280 or (status == "Being Robbed" and 16744192 or 16777215))
        local payload = {
            ["content"] = (isSpecial and "⏳" or currentIcon) .. " **" .. name:upper() .. "**",
            ["embeds"] = {{
                ["title"] = currentIcon .. " " .. name .. " " .. status .. "!",
                ["description"] = "[Click here to join directly](https://www.muffinhook.site/snipers/?jobid=" .. game.JobId .. ")",
                ["color"] = embedColor,
                ["fields"] = {
                    {["name"] = "Status", ["value"] = "**" .. status .. "**", ["inline"] = true},
                    {["name"] = "Players", ["value"] = "**" .. #Players:GetPlayers() .. " / 30**", ["inline"] = true},
                    {["name"] = "Game Time", ["value"] = "**" .. displayTime .. "**", ["inline"] = true}
                }   
            }}
        }
        pcall(function() 
            (http_request or request)({Url = targetUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(payload)}) 
        end)
    end

    -- 2. SEND TO FIREBASE (UNIQUE PER SERVER)
    -- Changed: Using game.JobId so multiple servers don't overwrite each other
    local dbPath = FIREBASE_BASE_URL .. game.JobId .. ".json"
    
    pcall(function()
        (http_request or request)({
            Url = dbPath,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                name = name,
                status = status,
                jobId = game.JobId,
                players = #Players:GetPlayers(), -- Sending just the number for cleaner website display
                lastUpdated = os.time()
            })
        })
    end)
end

-- BACKGROUND CLEANUP LOOP (Runs every 5 minutes)
task.spawn(function()
    while true do
        cleanupDatabase()
        task.wait(300)
    end
end)

-- DETECTION LOOP
task.spawn(function()
    while true do
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.M, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.M, false, game)
        end)
        
        task.wait(0.2) 

        local mansionObj = Workspace:FindFirstChild("MansionRobbery")
        if mansionObj and mansionObj:GetAttribute("RobberyStatus") == 1 then sendAlert("Mansion", "Open") end
        
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local UIs = {
                ["Jewelry Store"]="label_Jewelry", ["PowerPlant"]="label_PowerPlant", 
                ["Museum"]="label_Museum", ["Rising City Bank"]="label_Bank", 
                ["Crater City Bank"]="label_Bank2", ["Casino"]="label_Casino", 
                ["Cargo Train"]="label_TrainCargo", ["Tomb"]="label_Tomb"
            }
            for pretty, labelName in pairs(UIs) do
                local label = pGui:FindFirstChild(labelName, true)
                if label then
                    local isBlinking = false
                    for i = 1, 5 do
                        local color = label.ImageColor3
                        if color.G > 0.7 and (color.R > 0.15 or color.B > 0.15) then
                            isBlinking = true; break
                        end
                        task.wait(0.04)
                    end

                    if isBlinking then
                        if pretty ~= "PowerPlant" then sendAlert(pretty, "Being Robbed") end
                    elseif label.ImageColor3.G > 0.7 then
                        sendAlert(pretty, "Open")
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- SERVER HOPPER
local function ServerHop()
    task.wait(HOP_DELAY)
    while true do
        local success, response = pcall(function() 
            return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100") 
        end)
        
        if success then
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                local possibleServers = {}
                for _, s in pairs(data.data) do
                    if s.id ~= game.JobId and s.playing <= MAX_PLAYERS and not _G.ServerBlacklist[s.id] then
                        table.insert(possibleServers, s)
                    end
                end

                if #possibleServers > 0 then
                    local target = possibleServers[math.random(1, math.min(5, #possibleServers))]
                    pcall(function()
                        _G.ServerBlacklist[target.id] = true 
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
                    end)
                else
                    _G.ServerBlacklist = {}
                end
            end
        end
        task.wait(8) 
    end
end

print("✅ Live Sniper + Website Sync (Multi-Server) Active")
ServerHop()
