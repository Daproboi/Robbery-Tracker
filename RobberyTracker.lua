repeat task.wait() until game:IsLoaded()

-- [[ CONFIGURATION ]]
local FIREBASE_BASE_URL = "https://robbery-tracker-d43c5-default-rtdb.firebaseio.com/robberies/"
local MY_WEBSITE_URL = "https://daproboi.github.io/Robbery-Tracker-Website/"
local HOP_DELAY = 12
local MAX_PLAYERS = 22 

-- [[ WEBHOOK LINKS ]]
local Webhooks = {
    ["Rising Bank"] = "https://discord.com/api/webhooks/1464670766841860126/PpoBgXPlGA4J9pdLCRJEUr9PAAkLxvi5SPbArARwlol_Vu9Dkmu6hLAfrf0mlEAvMGJH",
    ["Crater Bank"] = "https://discord.com/api/webhooks/1464670766841860126/PpoBgXPlGA4J9pdLCRJEUr9PAAkLxvi5SPbArARwlol_Vu9Dkmu6hLAfrf0mlEAvMGJH",
    ["Jewelry Store"] = "https://discord.com/api/webhooks/1464670195896549457/-g95aDBEu9u3pn2M9ow7ChXxRTNyj847ahfWMLdXbnnYVNOVLOiUV5IvfVhWETjDKKFE",
    ["Museum"] = "https://discord.com/api/webhooks/1464671504435515454/G5DlXxy_u9IofQ_iyfCKlQGB_Q1SqG18Gi1XJlZppB_e4eqwXePUmbS8palWk1utsAgT",
    ["Casino"] = "https://discord.com/api/webhooks/1464671652343316542/4rbjQ-ckC-N-lR29ScuXO-mas98ZH_6R-hBlv_mVhSAS0nZrvocxMM2LyptaxXzL5PxT",
    ["Cargo Train"] = "https://discord.com/api/webhooks/1464671819499044930/dOp2Riuc9u_4KviKFAGITitz5Zs3sbVSkHoY8CUzSoeOaLJZ-8GTvACExqKGmKrlKmwN",
    ["Mansion"] = "https://discord.com/api/webhooks/1464672060159561885/dIXoAqZzJal-MhsM2KgmKTOvvTMI50IT4bv8elLSrfPlSE1ovHQrRm3xk4MbInTqf0BV",
    ["Tomb"] = "https://discord.com/api/webhooks/1464672202933796987/091LsMHRz2GUL7ymQ_RDU0jV4Xi87k6YnDT0heXmpAUMh5g0Su15ZCgbdObZRxucmX3b",
    ["Airdrop"] = "https://discord.com/api/webhooks/1464672331291955305/Kc_1Q8qxIIb8qVvn_8bmBj1vjjYa9IpNX2ZWXdLnKXoN4ibxxIlwyeF0GPs3MI0jotwD",
    ["Power Plant"] = "https://discord.com/api/webhooks/1464711922191695913/sZSMxS9pE58uwCvidx3MkEoTzJ73O3c0AatUSG8WsVrfxYkB44bm42zNHXxvJ4s9oYS9",
    ["Bank Truck"] = "https://discord.com/api/webhooks/1467485604777558194/vQ49xOndXG2_FQd-MEq5YhVwd_ERPvS0RIwe0TcVJP9Cg5_2LO8IX5Qvyqp69KarLAoG"
}

-- [[ MAPPINGS ]]
local ROBBERY_NAMES = {
    ["1"] = "Rising Bank", ["2"] = "Crater Bank", ["3"] = "Jewelry Store",
    ["4"] = "Museum", ["5"] = "Power Plant", ["7"] = "Cargo Train", ["12"] = "Bank Truck",
    ["14"] = "Tomb", ["15"] = "Casino", ["16"] = "Mansion"
}
local STATUS_NAMES = { [1] = "Open", [2] = "In Robbery", [3] = "Closed" }
local Icons = {
    ["Jewelry Store"]="💎", ["Power Plant"]="⚡", ["Museum"]="🏛️", ["Rising Bank"]="💰", 
    ["Crater Bank"]="🏦", ["Casino"]="🎰", ["Mansion"]="🏰", ["Tomb"]="⚰️", 
    ["Cargo Train"]="🚂", ["Airdrop"]="📦", ["Bank Truck"] = "🚛",
    ["Blue Airdrop"]="🔵", ["Brown Airdrop"]="🟤", ["Red Airdrop"]="🔴"
}

-- [[ SERVICES ]]
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local alreadyNotified = {}
if not _G.ServerBlacklist then _G.ServerBlacklist = {} end

-- [[ HELPER: FORMAT GAME TIME ]]
local function getGameTime()
    local decimalTime = Workspace:FindFirstChild("Time") and Workspace.Time.Value or 0
    local hours = math.floor(decimalTime)
    local minutes = math.floor((decimalTime - hours) * 60)
    local period = (hours >= 12) and "PM" or "AM"
    hours = (hours > 12) and hours - 12 or (hours == 0 and 12 or hours)
    return string.format("%d:%02d %s", hours, minutes, period)
end

-----------------------------------------------------------
-- [[ NEW ALERT LOGIC ]]
-----------------------------------------------------------
local function sendAlert(name, status, isDouble, customRegion, extraDetails)
    -- Unique key to prevent spam
    local alertKey = isDouble and "DoubleBank" or (name .. status .. (customRegion or ""))
    if alreadyNotified[alertKey] then return end
    alreadyNotified[alertKey] = true

    local targetUrl = Webhooks[name] or Webhooks["Airdrop"]
    local currentIcon = Icons[name] or "🚨"
    local timeStr = getGameTime()
    
    -- Base fields included in every alert
    local fields = {
        {["name"] = "Status", ["value"] = "**" .. status .. "**", ["inline"] = true},
        {["name"] = "Players", ["value"] = "**" .. #Players:GetPlayers() .. " / 30**", ["inline"] = true},
        {["name"] = "Game Time", ["value"] = "**" .. timeStr .. "**", ["inline"] = false}
    }

    -- Append extra details (like Airdrop timers or specific bank statuses)
    if extraDetails then
        for _, detail in pairs(extraDetails) do 
            table.insert(fields, detail) 
        end
    end

    local payload = {
        ["content"] = isDouble and "🚨 💰💰 **DOUBLE BANK ALERT**" or (currentIcon .. " **" .. name:upper() .. "**"),
        ["embeds"] = {{
            ["title"] = isDouble and "Both Banks are Active!" or (currentIcon .. " " .. name .. " is " .. status .. "!"),
            ["description"] = customRegion or ("🚀 [Join Server via Tracker](" .. MY_WEBSITE_URL .. "?jobid=" .. game.JobId .. ")"),
            ["color"] = isDouble and 16776960 or (status == "Open" and 65280 or (name:find("Airdrop") and 16711680 or 16744192)),
            ["fields"] = fields
        }}
    }
    
    -- Special description formatting for Airdrops
    if name:find("Airdrop") and customRegion then
        payload.embeds[1].description = customRegion .. "\n\n🚀 [Join Server via Tracker](" .. MY_WEBSITE_URL .. "?jobid=" .. game.JobId .. ")"
    end

    -- Send request
    pcall(function()
        local req = (http_request or request or syn.request)
        if req then
            req({
                Url = targetUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end
    end)
end

-- [[ ROBBERY DETECTION ]]
task.spawn(function()
    local RobberyState = ReplicatedStorage:WaitForChild("RobberyState")
    while true do
        local rBankStatus = STATUS_NAMES[RobberyState["1"].Value]
        local cBankStatus = STATUS_NAMES[RobberyState["2"].Value]

        if (rBankStatus == "Open" or rBankStatus == "In Robbery") and (cBankStatus == "Open" or cBankStatus == "In Robbery") then
            sendAlert("Rising Bank", "Double Bank Active", true, nil, {
                {["name"] = "Rising Bank", ["value"] = "**" .. rBankStatus .. "**", ["inline"] = true},
                {["name"] = "Crater Bank", ["value"] = "**" .. cBankStatus .. "**", ["inline"] = true}
            })
        end

        for id, name in pairs(ROBBERY_NAMES) do
            local stateVal = RobberyState:FindFirstChild(id)
            if stateVal then
                local status = STATUS_NAMES[stateVal.Value]
                if name == "Power Plant" or name == "Mansion" then
                    if status == "Open" then sendAlert(name, status, false) end
                else
                    if status == "Open" or status == "In Robbery" then sendAlert(name, status, false) end
                end
            end
        end
        task.wait(1)
    end
end)

-- [[ DRONE AIRDROP SCANNER ]]
task.spawn(function()
    local HOVER_HEIGHT = 120 
    local WIDE_RADIUS = 1200 
    local MISSIONS = {
        {Name = "Dunes", Start = Vector3.new(649, HOVER_HEIGHT, 740), End = Vector3.new(492, HOVER_HEIGHT, -905), HoverTime = 4.0},
        {Name = "Cactus Valley", Start = Vector3.new(2103, HOVER_HEIGHT, -4081), End = Vector3.new(-1469, HOVER_HEIGHT, -4337), HoverTime = 6.0}
    }

    local function droneScan(region)
        pcall(function()
            local drop = Workspace:FindFirstChild("Drop")
            if drop and not alreadyNotified[drop] then
                local colorName = "Unknown"
                local wall = drop:FindFirstChild("Walls") and drop.Walls:FindFirstChild("Wall")
                if wall then
                    local c = wall.Color
                    local r, g, b = c.R*255, c.G*255, c.B*255
                    if r > 40 and r < 60 and b > 140 then colorName = "Blue"
                    elseif r > 140 and g > 90 and g < 110 then colorName = "Brown"
                    elseif r > 140 and g < 60 and b < 60 then colorName = "Red" end
                end
                
                local dropStatus = "Unopened"
                local timerText = ""
                local label = drop:FindFirstChild("Countdown") and drop.Countdown:FindFirstChild("Billboard") and drop.Countdown.Billboard:FindFirstChild("TextLabel")
                
                if label then
                    local currentVal = label.Text
                    if currentVal ~= "30" and currentVal ~= "" then
                        dropStatus = "In Progress"
                        timerText = currentVal .. " seconds"
                    end
                end

                local dropID = colorName .. " Airdrop"
                local extra = {
                    {["name"] = "Airdrop State", ["value"] = "**" .. dropStatus .. "**", ["inline"] = true}
                }
                if dropStatus == "In Progress" then
                    table.insert(extra, {["name"] = "Timer", ["value"] = "**" .. timerText .. "**", ["inline"] = true})
                end

                sendAlert(dropID, "FOUND!", false, colorName .. " Airdrop found in " .. region .. "!", extra)
                alreadyNotified[drop] = true
            elseif not drop then
                for k, v in pairs(alreadyNotified) do
                    if typeof(k) == "Instance" and k.Name == "Drop" then alreadyNotified[k] = nil end
                end
            end
        end)
    end

    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
    Camera.CameraType = Enum.CameraType.Scriptable

    while true do
        for _, mission in pairs(MISSIONS) do
            Camera.CFrame = CFrame.new(mission.Start, mission.End)
            LocalPlayer:RequestStreamAroundAsync(mission.Start, WIDE_RADIUS)
            
            local tweenGoal = {CFrame = CFrame.new(mission.End, mission.End + (mission.End - mission.Start).Unit)}
            local tween = TweenService:Create(Camera, TweenInfo.new(mission.HoverTime, Enum.EasingStyle.Linear), tweenGoal)
            tween:Play()
            
            local start = tick()
            while (tick() - start) < mission.HoverTime do
                LocalPlayer:RequestStreamAroundAsync(Camera.CFrame.Position, WIDE_RADIUS)
                droneScan(mission.Name)
                task.wait(0.2)
            end
        end
    end
end)

-- [[ SERVER HOPPER ]]
local function ServerHop()
    task.wait(HOP_DELAY)
    while true do
        local success, response = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100") end)
        if success then
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                for _, s in pairs(data.data) do
                    if s.id ~= game.JobId and s.playing <= MAX_PLAYERS and not _G.ServerBlacklist[s.id] then
                        _G.ServerBlacklist[s.id] = true 
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    end
                end
            end
        end
        task.wait(5)
    end
end

print("✅ SCRIPT UPDATED: Alert logic replaced and Airdrop status/timers active.")
ServerHop()
