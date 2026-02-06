repeat task.wait() until game:IsLoaded()

-- [[ CONFIGURATION ]]
local FIREBASE_BASE_URL = "https://robbery-tracker-d43c5-default-rtdb.firebaseio.com/robberies/"
local OCCUPIED_URL = "https://robbery-tracker-d43c5-default-rtdb.firebaseio.com/OccupiedServers/"
local MY_WEBSITE_URL = "https://daproboi.github.io/Robbery-Tracker-Website/"
local STATUS_WEBHOOK = "https://discord.com/api/webhooks/1469084809031843875/wmbotGFMyQaQUG6wl8yz7DwxMnZ4MM9QzeFT-buJfVKBmotkYZPPvVDpS1g3FFtY7S_B"
local HOP_DELAY = 8 
local MAX_PLAYERS = 22
local STALE_TIME = 600 
local BOUNTY_THRESHOLD = 40000 

-- [[ YOUR WEBHOOK LINKS ]]
local Webhooks = {
	["Bounty Alerts"] = "https://discord.com/api/webhooks/1469384993364246792/Jjvn_rTtdah-cGhnWnzW7A_zrl3xC9EBA6Cpd1o1PBmv2k92cwUscTStUxT3zHL0SBgM",
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

-- [[ FRIEND'S WEBHOOK LINKS ]]
local FriendWebhooks = {
	["Bounty Alerts"] = "https://discord.com/api/webhooks/1469386353354608832/ruKjvd206Kke00L_4WMm3qRlaiDA_APZjAiFeVzhjuxvUUNuLtOyYjse64lEl-orC3K2",
    ["Rising Bank"] = "https://discord.com/api/webhooks/1469088176751509610/dd1a4r97kx1dKDhXzm0oiTluAIf165ihkf4rwhkrhS-ZIgentEl-ldldX_LA-hWzRAmf",
    ["Crater Bank"] = "https://discord.com/api/webhooks/1469088176751509610/dd1a4r97kx1dKDhXzm0oiTluAIf165ihkf4rwhkrhS-ZIgentEl-ldldX_LA-hWzRAmf",
    ["Jewelry Store"] = "https://discord.com/api/webhooks/1469088053678309397/MkapcDFJoCNv6CjhMytjt8SLkWWLsHZc2XoBblEPkpyZbSLcdBSCKeffIyuR3D2y0TDC",
    ["Museum"] = "https://discord.com/api/webhooks/1469087765768437911/aS6ewt9vsHomv5968zN-23NYtOaCkrDZqQQgM17jB4KSOkU7diAtZsccB6C3Ma1SQTRU",
    ["Casino"] = "https://discord.com/api/webhooks/1469089230767522029/bPG6k_kLduh6KUEd-XQ2MdYnrrPGRhVVJBaVsWm3GTyNW6G2pqI8opDALSD87SKpUbOZ",
    ["Cargo Train"] = "https://discord.com/api/webhooks/1469094771367870500/2MQ9ynmoT_cFvvqLqgifSgE3qWwqEPwGajCBlyuDvc2D8RlWdZfHBNhxQJ3UwMcmcFIf",
    ["Mansion"] = "https://discord.com/api/webhooks/1469088402270982326/bzrvAciscLKkRQji8AJ4X2GXUprrC2wtI1J-qzN0srq3DK7KWM9YUXi0M-AgoboYhkKO",
    ["Tomb"] = "https://discord.com/api/webhooks/1469088954329469142/kEylUS5fMeJf31u_MDVFniLLAVOmpH94o-ocAXPqNjtS8hYRjkrpw-IA2FwIy8BcC4C5",
    ["Airdrop"] = "https://discord.com/api/webhooks/1469089100207358163/i1J_frXKzYmHWBDzlNrx8MdJp0XFh54ymrXRG6O0YthfSmW2jqpvTGe_uRsz0w3fQpDW",
    ["Power Plant"] = "https://discord.com/api/webhooks/1469088764654784645/yvhR9e6WwYtHy502QZZFY9N72SRcCcWylVbTIYJqBNE9d3j9SXW_MOQ8YN_LVqEESTcw",
    ["Bank Truck"] = "https://discord.com/api/webhooks/1469088593409740932/mk6IYGMK9mKzkmFn88FEIslGO6jnlBW8b9K7xRJWPdwE_5CrdOGKTeAazGAPWZTSJepV"
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
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players:GetService("Players").LocalPlayer
local Camera = Workspace.CurrentCamera

local alreadyNotified = {}
if not _G.ServerBlacklist then _G.ServerBlacklist = {} end

local function getGameTime()
    local decimalTime = Workspace:FindFirstChild("Time") and Workspace.Time.Value or 0
    local hours = math.floor(decimalTime)
    local minutes = math.floor((decimalTime - hours) * 60)
    local period = (hours >= 12) and "PM" or "AM"
    hours = (hours > 12) and hours - 12 or (hours == 0 and 12 or hours)
    return string.format("%d:%02d %s", hours, minutes, period)
end

-----------------------------------------------------------
-- [[ BOUNTY SNIPER LOGIC ]]
-----------------------------------------------------------
local function SendBountyAlert(totalBounty, crims, police)
    local JobId = game.JobId
    local payload = {
        ["content"] = "💰 **LARGE BOUNTY FOUND!**",
        ["embeds"] = {{
            ["title"] = "🎯 Bounty Target Located",
            ["description"] = "🚀 [Join Server via Tracker](" .. MY_WEBSITE_URL .. "?jobid=" .. JobId .. ")",
            ["color"] = 16766720,
            ["fields"] = {
                {["name"] = "Total Bounty", ["value"] = "**$" .. totalBounty .. "**", ["inline"] = false},
                {["name"] = "Criminals", ["value"] = "**" .. crims .. "**", ["inline"] = true},
                {["name"] = "Police", ["value"] = "**" .. police .. "**", ["inline"] = true}
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    pcall(function()
        local req = (http_request or request or syn.request)
        if req then
            local encodedPayload = HttpService:JSONEncode(payload)
            
            -- Send to your Bounty Webhook
            req({
                Url = Webhooks["Bounty Alerts"],
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = encodedPayload
            })
            
            -- Send to friend's Bounty Webhook
            req({
                Url = FriendWebhooks["Bounty Alerts"],
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = encodedPayload
            })
        end
    end)
end

local function CheckServerBounties()
    local totalBounty = 0
    local bountyDataObj = ReplicatedStorage:FindFirstChild("BountyData")
    
    if bountyDataObj and bountyDataObj:IsA("StringValue") then
        local success, bountyTable = pcall(function() return HttpService:JSONDecode(bountyDataObj.Value) end)
        if success and type(bountyTable) == "table" then
            for _, data in pairs(bountyTable) do totalBounty = totalBounty + (data.Bounty or 0) end
        end
    end

    local crimCount, policeCount = 0, 0
    for _, player in pairs(Players:GetPlayers()) do
        if player.Team then
            local teamName = player.Team.Name:lower()
            if teamName:find("crim") or teamName:find("villain") then crimCount = crimCount + 1
            elseif teamName:find("police") or teamName:find("cop") or teamName:find("officer") then policeCount = policeCount + 1 end
        end
    end

    if totalBounty >= BOUNTY_THRESHOLD then
        SendBountyAlert(totalBounty, crimCount, policeCount)
    end
end

-----------------------------------------------------------
-- [[ BOT STATUS / HEARTBEAT LOGIC ]]
-----------------------------------------------------------
local function SendBotHeartbeat()
    local botName = LocalPlayer.Name
    local jobId = game.JobId
    local playerCount = #Players:GetPlayers()
    
    local discordPayload = {
        ["username"] = "Bot Monitor",
        ["avatar_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png",
        ["embeds"] = {{
            ["title"] = "🟢 Bot Active: " .. botName,
            ["color"] = 3066993,
            ["fields"] = {
                {["name"] = "Server JobId", ["value"] = "```" .. jobId .. "```", ["inline"] = false},
                {["name"] = "Players", ["value"] = playerCount .. " / 30", ["inline"] = true},
                {["name"] = "Avg Hop Time", ["value"] = HOP_DELAY .. "s", ["inline"] = true}
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local firebaseData = {
        ["AverageLogTime"] = HOP_DELAY,
        ["LatestJobId"] = jobId,
        ["LastUpdated"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    pcall(function()
        local req = (http_request or request or syn.request)
        if req then
            if STATUS_WEBHOOK ~= "YOUR_STATUS_WEBHOOK_HERE" then
                req({
                    Url = STATUS_WEBHOOK,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(discordPayload)
                })
            end
            
            req({
                Url = "https://robbery-tracker-d43c5-default-rtdb.firebaseio.com/Statuses/" .. botName .. ".json",
                Method = "PATCH",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(firebaseData)
            })
        end
    end)
end

-----------------------------------------------------------
-- [[ ALERT LOGIC ]]
-----------------------------------------------------------
local function sendAlert(name, status, isDouble, customRegion, extraDetails)
    local alertKey = isDouble and "DoubleBank" or (name .. status .. (customRegion or ""))
    if alreadyNotified[alertKey] then return end
    alreadyNotified[alertKey] = true

    local myUrl = Webhooks[name] or Webhooks["Airdrop"]
    local friendUrl = FriendWebhooks[name] or FriendWebhooks["Airdrop"]
    
    local currentIcon = Icons[name] or "🚨"
    local timeStr = getGameTime()
    local JobId = game.JobId
    
    local fields = {
        {["name"] = "Status", ["value"] = "**" .. status .. "**", ["inline"] = true},
        {["name"] = "Players", ["value"] = "**" .. #Players:GetPlayers() .. " / 30**", ["inline"] = true},
        {["name"] = "Game Time", ["value"] = "**" .. timeStr .. "**", ["inline"] = false}
    }

    if customRegion and customRegion ~= "" then
        table.insert(fields, {["name"] = "Location", ["value"] = "**" .. customRegion .. "**", ["inline"] = true})
    end

    if extraDetails then
        for _, detail in pairs(extraDetails) do table.insert(fields, detail) end
    end

    local payload = {
        ["content"] = isDouble and "🚨 💰💰 **DOUBLE BANK ALERT**" or (currentIcon .. " **" .. name:upper() .. "**"),
        ["embeds"] = {{
            ["title"] = isDouble and "Both Banks are Active!" or (currentIcon .. " " .. name .. " is " .. status .. "!"),
            ["description"] = "🚀 [Join Server via Tracker](" .. MY_WEBSITE_URL .. "?jobid=" .. JobId .. ")",
            ["color"] = isDouble and 16776960 or (status == "Open" and 65280 or 16744192),
            ["fields"] = fields
        }}
    }

    local firebaseData = {
        ["name"] = name,
        ["status"] = status,
        ["isDouble"] = isDouble or false,
        ["jobId"] = JobId,
        ["players"] = #Players:GetPlayers(),
        ["lastUpdated"] = os.time(),
        ["region"] = customRegion or ""
    }

    pcall(function()
        local req = (http_request or request or syn.request)
        if req then
            local encodedPayload = HttpService:JSONEncode(payload)
            req({Url = myUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = encodedPayload})
            if friendUrl and friendUrl ~= "FRIEND_LINK_HERE" then
                req({Url = friendUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = encodedPayload})
            end
            local uniqueKey = JobId .. "_" .. name:gsub("%s+", "")
            req({
                Url = FIREBASE_BASE_URL .. uniqueKey .. ".json",
                Method = "PATCH",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(firebaseData)
            })
        end
    end)
end

-- [[ ROBBERY DETECTION ]]
task.spawn(function()
    local RobberyState = ReplicatedStorage:WaitForChild("RobberyState")
    CheckServerBounties() -- Run bounty check immediately on join
    
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
                if status == "Open" or status == "In Robbery" then sendAlert(name, status, false) end
            end
        end
        task.wait(0.3)
    end
end)

-- [[ DRONE AIRDROP SCANNER ]]
task.spawn(function()
    local HOVER_HEIGHT, WIDE_RADIUS = 120, 1200 
    local MISSIONS = {
        {Name = "Dunes", Start = Vector3.new(649, HOVER_HEIGHT, 740), End = Vector3.new(492, HOVER_HEIGHT, -905), HoverTime = 2.0},
        {Name = "Cactus Valley", Start = Vector3.new(2103, HOVER_HEIGHT, -4081), End = Vector3.new(-1469, HOVER_HEIGHT, -4337), HoverTime = 3.0}
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
                sendAlert(colorName .. " Airdrop", "FOUND!", false, region)
                alreadyNotified[drop] = true
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
                task.wait(0.5)
            end
        end
    end
end)

-- [[ GLOBAL BLACKLIST CHECKER ]]
local function IsServerOccupied(jobId)
    local req = (http_request or request or syn.request)
    if not req then return false end
    
    local success, response = pcall(function()
        return req({Url = OCCUPIED_URL .. jobId .. ".json", Method = "GET"})
    end)
    
    if success and response.Body ~= "null" then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.Timestamp then
            if (os.time() - data.Timestamp) < STALE_TIME then
                return true
            end
        end
    end
    return false
end

local function ClaimServer(jobId)
    local req = (http_request or request or syn.request)
    if not req then return false end
    
    local myClaim = {["Bot"] = LocalPlayer.Name, ["Timestamp"] = os.time()}
    
    pcall(function()
        req({
            Url = OCCUPIED_URL .. jobId .. ".json",
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(myClaim)
        })
    end)
    
    task.wait(1.2) 
    
    local success, response = pcall(function()
        return req({Url = OCCUPIED_URL .. jobId .. ".json", Method = "GET"})
    end)
    
    if success then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.Bot == LocalPlayer.Name then
            return true 
        end
    end
    return false
end

-- [[ SERVER HOPPER ]]
local function ServerHop()
    print("⏳ Logging status and waiting to hop...")
    SendBotHeartbeat()
    task.wait(HOP_DELAY + math.random(1, 4)) 
    
    while true do
        local success, response = pcall(function() 
            return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100") 
        end)
        
        if success then
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                for _, s in pairs(data.data) do
                    if s.id ~= game.JobId and s.playing > 0 and s.playing <= MAX_PLAYERS and not _G.ServerBlacklist[s.id] then
                        if not IsServerOccupied(s.id) then
                            print("🛰️ Attempting to claim: " .. s.id)
                            
                            if ClaimServer(s.id) then
                                print("🚀 Claim Successful! Teleporting...")
                                _G.ServerBlacklist[s.id] = true 
                                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer) end)
                                task.wait(5) 
                            else
                                print("❌ Claim failed (Race lost), trying next server...")
                            end
                        end
                    end
                end
            end
        end
        task.wait(2) 
    end
end

print("✅ SCRIPT UPDATED: Bounty Sniper & Heartbeat Active")
ServerHop()
