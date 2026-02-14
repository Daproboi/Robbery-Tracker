repeat task.wait() until game:IsLoaded()

-- [[ 0. POTATO MODE OPTIMIZER ]] --
pcall(function()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then v:Destroy() end
    end
    for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
    game:GetService("Workspace").Terrain.WaterWaveSize = 0
    game:GetService("Workspace").Terrain.WaterWaveSpeed = 0
    game:GetService("Workspace").Terrain.WaterReflectance = 0
    game:GetService("Workspace").Terrain.WaterTransparency = 0
    print("🥔 Potato Mode Enabled: MAX FPS")
end)

-- [[ 1. HIDE TEAM UI ]] --
pcall(function() local pg=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"); for _,g in pairs(pg:GetChildren()) do if g.Name:find("Team") or g.Name:find("Intro") then g:Destroy() end end end)

local FIREBASE_BASE_URL, OCCUPIED_URL = "https://robbery-tracker-d43c5-default-rtdb.firebaseio.com/robberies/", "https://robbery-tracker-d43c5-default-rtdb.firebaseio.com/OccupiedServers/"
local MY_WEBSITE_URL, MAP_IMAGE_BASE = "https://daproboi.github.io/Robbery-Tracker-Website/", "https://daproboi.github.io/Robbery-Tracker-Website/"
local HOP_DELAY, MAX_PLAYERS, STALE_TIME, BOUNTY_THRESHOLD = 8, 22, 600, 40000

local Webhooks = {
    ["Status"] = "https://discord.com/api/webhooks/1469084809031843875/wmbotGFMyQaQUG6wl8yz7DwxMnZ4MM9QzeFT-buJfVKBmotkYZPPvVDpS1g3FFtY7S_B",
    ["High Value Player"] = "https://discord.com/api/webhooks/1471582041173659688/TdhJq-fjU_fEU7k020ddiQHT0xiJOn9CNEnjMq8-qtmK7pa-xYGPV8VY5AtRiZftJ2nI",
    ["Bounty Alerts"] = "https://discord.com/api/webhooks/1469384993364246792/Jjvn_rTtdah-cGhnWnzW7A_zrl3xC9EBA6Cpd1o1PBmv2k92cwUscTStUxT3zHL0SBgM",
    ["Rising Bank"] = "https://discord.com/api/webhooks/1464670766841860126/PpoBgXPlGA4J9pdLCRJEUr9PAAkLxvi5SPbArARwlol_Vu9Dkmu6hLAfrf0mlEAvMGJH",
    ["Crater Bank"] = "https://discord.com/api/webhooks/1464670766841860126/PpoBgXPlGA4J9pdLCRJEUr9PAAkLxvi5SPbArARwlol_Vu9Dkmu6hLAfrf0mlEAvMGJH",
    ["Jewelry Store"] = "https://discord.com/api/webhooks/1464670195896549457/-g95aDBEu9u3pn2M9ow7ChXxRTNyj847ahfWMLdXbnnYVNOVLOiUV5IvfVhWETjDKKFE",
    ["Museum"] = "https://discord.com/api/webhooks/1464671504435515454/G5DlXxy_u9IofQ_iyfCKlQGB_Q1SqG18Gi1XJlZppB_e4eqwXePUmbS8palWk1utsAgT",
    ["Casino"] = "https://discord.com/api/webhooks/1464671652343316542/4rbjQ-ckC-N-lR29ScuXO-mas98ZH_6R-hBlv_mVhSAS0nZrvocxMM2LyptaxXzL5PxT",
    ["Cargo Train"] = "https://discord.com/api/webhooks/1464671819499044930/dOp2Riuc9u_4KviKFAGITitz5Zs3sbVSkHoY8CUzSoeOaLJZ-8GTvACExqKGmKrlKmwN",
    ["Cargo Plane"] = "https://discord.com/api/webhooks/1471959724651188378/wbqr-86dC3XfH8bTZf0Mc481ipGsB3KFllK4jVpr3z6q1U3J4lcWv8qYww8uX3Y49lj1",
    ["Mansion"] = "https://discord.com/api/webhooks/1464672060159561885/dIXoAqZzJal-MhsM2KgmKTOvvTMI50IT4bv8elLSrfPlSE1ovHQrRm3xk4MbInTqf0BV",
    ["Tomb"] = "https://discord.com/api/webhooks/1464672202933796987/091LsMHRz2GUL7ymQ_RDU0jV4Xi87k6YnDT0heXmpAUMh5g0Su15ZCgbdObZRxucmX3b",
    ["Airdrop"] = "https://discord.com/api/webhooks/1464672331291955305/Kc_1Q8qxIIb8qVvn_8bmBj1vjjYa9IpNX2ZWXdLnKXoN4ibxxIlwyeF0GPs3MI0jotwD",
    ["Power Plant"] = "https://discord.com/api/webhooks/1464711922191695913/sZSMxS9pE58uwCvidx3MkEoTzJ73O3c0AatUSG8WsVrfxYkB44bm42zNHXxvJ4s9oYS9",
    ["Bank Truck"] = "https://discord.com/api/webhooks/1467485604777558194/vQ49xOndXG2_FQd-MEq5YhVwd_ERPvS0RIwe0TcVJP9Cg5_2LO8IX5Qvyqp69KarLAoG"
}
local FriendWebhooks = {
    ["Status"] = "https://discord.com/api/webhooks/1471593455279931425/wlVkvakvDBp5jC9SQJphwi8_bqMOuF_SZDS8Hbb1MG_544OLVbwGB54cRRcFEAD5Epn4",
    ["High Value Player"] = "https://discord.com/api/webhooks/1471582198716043389/JdZMohcSOoWbjGdb2GdtGTlOU1gzBR567noxx8JJrE6TQ7V6dFOvJUiyAFcTkzS5DZ8I",
    ["Cargo Plane"] = "https://discord.com/api/webhooks/1471960106257092782/A7MjG25yeenqLBP5UtW2-2wLL7ozGocS11VMeG3RU2B-Q2UK-IKUgdXnWrtKN0Rz4kqn",
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
local ROBBERY_NAMES = {["1"]="Rising Bank", ["2"]="Crater Bank", ["3"]="Jewelry Store", ["4"]="Museum", ["5"]="Power Plant", ["7"]="Cargo Train", ["9"]="Cargo Plane", ["12"]="Bank Truck", ["14"]="Tomb", ["15"]="Casino", ["16"]="Mansion"}
local STATUS_NAMES = {[1]="Open", [2]="In Robbery", [3]="Closed"}
local Icons = {["Jewelry Store"]="💎", ["Power Plant"]="⚡", ["Museum"]="🏛️", ["Rising Bank"]="💰", ["Crater Bank"]="🏦", ["Casino"]="🎰", ["Mansion"]="🏰", ["Tomb"]="⚰️", ["Cargo Train"]="🚂", ["Cargo Plane"]="✈️", ["Airdrop"]="📦", ["Bank Truck"]="🚛", ["Blue Airdrop"]="🔵", ["Brown Airdrop"]="🟤", ["Red Airdrop"]="🔴", ["Bounty"]="💰"}
local HttpService, ReplicatedStorage, Players, TeleportService, Workspace, TweenService = game:GetService("HttpService"), game:GetService("ReplicatedStorage"), game:GetService("Players"), game:GetService("TeleportService"), game:GetService("Workspace"), game:GetService("TweenService")
local LocalPlayer, Camera, alreadyNotified = Players.LocalPlayer, Workspace.CurrentCamera, {}
if not _G.ServerBlacklist then _G.ServerBlacklist = {} end
local function getGameTime() local t = Workspace:FindFirstChild("Time") and Workspace.Time.Value or 0; local h, m = math.floor(t), math.floor((t - math.floor(t)) * 60); return string.format("%d:%02d %s", (h > 12 and h - 12 or (h == 0 and 12 or h)), m, h >= 12 and "PM" or "AM") end
local function getDecimalTime() return Workspace:FindFirstChild("Time") and Workspace.Time.Value or 0 end
local function getGridImage(pos, isTrain, isPlane, planeObj)
    if not pos then return nil end
    local minX, maxX, minZ, maxZ, offsetX, offsetZ = -2665, 3000, -6084, 3264, 0, 0
    if isTrain then offsetX = -500 end
    local adjX, adjZ = pos.X + offsetX, pos.Z + offsetZ
    local normX, normZ = (adjX - minX) / (maxX - minX), (adjZ - minZ) / (maxZ - minZ)
    local col, row = math.clamp(math.ceil(normX * 7), 1, 7), math.clamp(math.ceil(normZ * 8), 1, 8)
    local rowChar, gridID = string.char(64 + row), string.char(64 + row) .. col
    if isTrain then
        if gridID == "B3" then gridID = "B4" elseif gridID == "B6" then gridID = "C5" end
        if not ({["D6"]=1, ["B4"]=1, ["A4"]=1, ["E5"]=1, ["F5"]=1, ["B5"]=1, ["C6"]=1, ["C5"]=1, ["A3"]=1, ["D5"]=1, ["F4"]=1, ["G4"]=1, ["G5"]=1, ["B3"]=1, ["B6"]=1})[gridID] then return nil end
    end
    if isPlane then
        local always = {["E6"]=1, ["F6"]=1, ["F2"]=1, ["F1"]=1, ["G1"]=1}
        local conditional = {["F5"]=1, ["F4"]=1, ["F3"]=1}
        if always[gridID] then
            -- Allow
        elseif conditional[gridID] and planeObj then
            local h1 = pos.Y
            task.wait(0.25)
            local h2 = planeObj:GetPivot().Position.Y
            if h2 >= (h1 - 0.2) then return nil end -- Block if not decreasing
        else return nil end
    end
    return MAP_IMAGE_BASE .. gridID .. ".png"
end
local function getCasinoCode()
    local cf = Workspace:FindFirstChild("Casino") and Workspace.Casino:FindFirstChild("RobberyDoor") and Workspace.Casino.RobberyDoor:FindFirstChild("Codes")
    if not cf then return nil end
    for _, lm in pairs(cf:GetChildren()) do
        local fd = {}
        for _, b in pairs(lm:GetChildren()) do
            local sg = b:FindFirstChild("SurfaceGui") and b.SurfaceGui:FindFirstChild("TextLabel")
            if sg and sg.Text and tonumber(sg.Text) then table.insert(fd, {Digit=sg.Text, Position=b.Position}) end
        end
        if #fd == 4 then
            local minX, maxX, minZ, maxZ = fd[1].Position.X, fd[1].Position.X, fd[1].Position.Z, fd[1].Position.Z
            for i=2,#fd do minX=math.min(minX,fd[i].Position.X);maxX=math.max(maxX,fd[i].Position.X);minZ=math.min(minZ,fd[i].Position.Z);maxZ=math.max(maxZ,fd[i].Position.Z) end
            local sf = function(a,b) return a.Position.X > b.Position.X end
            if (maxZ-minZ) > (maxX-minX) then sf = function(a,b) return a.Position.Z > b.Position.Z end end
            table.sort(fd, sf); local fc = ""; for _, d in ipairs(fd) do fc = fc .. d.Digit end; return fc
        end
    end; return nil
end
local function getCasinoTime()
    local cl = Workspace:FindFirstChild("Casino") and Workspace.Casino:FindFirstChild("Clocks")
    if cl then for _, c in pairs(cl:GetChildren()) do local tl = c:FindFirstChild("SurfaceGui") and c.SurfaceGui:FindFirstChild("TextLabel"); if tl and tl.Text ~= "" then return tl.Text end end end; return nil
end
local function SendServerAlert(totalBounty, crims, police)
    local JobId = game.JobId
    local payload = {["content"]="💰 **HIGH BOUNTY SERVER!**", ["embeds"]={{["title"]="Server Located", ["description"]="🚀 [Join Server]("..MY_WEBSITE_URL.."?jobid="..JobId..")", ["color"]=16766720, ["fields"]={{["name"]="Total Bounty", ["value"]="**$"..totalBounty.."**", ["inline"]=false}, {["name"]="Criminals", ["value"]="**"..crims.."**", ["inline"]=true}, {["name"]="Police", ["value"]="**"..police.."**", ["inline"]=true}}, ["timestamp"]=os.date("!%Y-%m-%dT%H:%M:%SZ")}}}
    local req = (http_request or request or syn.request)
    if req then
        local enc = HttpService:JSONEncode(payload)
        req({Url=Webhooks["Bounty Alerts"], Method="POST", Headers={["Content-Type"]="application/json"}, Body=enc})
        req({Url=FriendWebhooks["Bounty Alerts"], Method="POST", Headers={["Content-Type"]="application/json"}, Body=enc})
        req({Url=FIREBASE_BASE_URL..JobId.."_Bounty.json", Method="PATCH", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode({["name"]="Bounty", ["status"]="HIGH BOUNTY", ["jobId"]=JobId, ["players"]=#Players:GetPlayers(), ["totalBounty"]=totalBounty, ["crims"]=crims, ["police"]=police, ["lastUpdated"]=os.time()})})
    end
end
local function SendPlayerAlert(targetName, targetId, maxBounty, invString, totalBounty, crims, police)
    local JobId, avatarUrl = game.JobId, "https://www.roblox.com/headshot-thumbnail/image?userId="..targetId.."&width=420&height=420&format=png"
    local req = (http_request or request or syn.request)
    if req then pcall(function() local r=req({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..targetId.."&size=420x420&format=Png&isCircular=false", Method="GET"}); local d=HttpService:JSONDecode(r.Body); if d.data and d.data[1] then avatarUrl=d.data[1].imageUrl end end) end
    local payload = {["content"]="🎯 **HIGH VALUE TARGET**", ["embeds"]={{["title"]="[Join Game]", ["url"]=MY_WEBSITE_URL.."?jobid="..JobId, ["color"]=10181046, ["thumbnail"]={["url"]=avatarUrl}, ["fields"]={{["name"]="Player Name:", ["value"]="**"..targetName.."**", ["inline"]=false}, {["name"]="Player Bounty:", ["value"]="**$"..maxBounty.."**", ["inline"]=false}, {["name"]="Total Server Bounty:", ["value"]="**$"..totalBounty.."**", ["inline"]=false}, {["name"]="Inventory:", ["value"]=invString~="" and invString or "None", ["inline"]=false}, {["name"]="Total Crims:", ["value"]=tostring(crims), ["inline"]=false}, {["name"]="Total Police:", ["value"]=tostring(police), ["inline"]=false}}, ["timestamp"]=os.date("!%Y-%m-%dT%H:%M:%SZ")}}}
    if req then local e=HttpService:JSONEncode(payload); req({Url=Webhooks["High Value Player"], Method="POST", Headers={["Content-Type"]="application/json"}, Body=e}); if FriendWebhooks["High Value Player"] and FriendWebhooks["High Value Player"]~="FRIEND_PLAYER_WEBHOOK_HERE" then req({Url=FriendWebhooks["High Value Player"], Method="POST", Headers={["Content-Type"]="application/json"}, Body=e}) end end
end
local function CheckServerBounties()
    local totalBounty, maxBounty, targetName, targetId, bd = 0, 0, nil, 0, ReplicatedStorage:FindFirstChild("BountyData")
    if bd and bd:IsA("StringValue") then
        local s, t = pcall(function() return HttpService:JSONDecode(bd.Value) end)
        if s and type(t) == "table" then for _, d in pairs(t) do local b = d.Bounty or 0; totalBounty = totalBounty + b; if b > maxBounty then maxBounty, targetName, targetId = b, d.Name, d.UserId end end end
    end
    local c, p = 0, 0
    for _, pl in pairs(Players:GetPlayers()) do if pl.Team then local tn = pl.Team.Name:lower(); if tn:find("crim") or tn:find("villain") then c = c + 1 elseif tn:find("police") or tn:find("cop") then p = p + 1 end end end
    if totalBounty >= BOUNTY_THRESHOLD then 
        SendServerAlert(totalBounty, c, p)
        if targetName then
            local invString, targetPlr = "", Players:FindFirstChild(targetName)
            if targetPlr and targetPlr:FindFirstChild("Folder") then local i={}; for _, item in pairs(targetPlr.Folder:GetChildren()) do table.insert(i, item.Name) end; invString=table.concat(i, ", ") end
            SendPlayerAlert(targetName, targetId, maxBounty, invString, totalBounty, c, p)
        end
    end
end
local function SendBotHeartbeat(realTime)
    local botName, jobId, userId = LocalPlayer.Name, game.JobId, LocalPlayer.UserId
    local timeDisplay, avatarUrl = (realTime and realTime > 0) and (realTime.."s") or "Calculating...", "https://www.roblox.com/headshot-thumbnail/image?userId="..userId.."&width=420&height=420&format=png"
    local req = (http_request or request or syn.request)
    if req then pcall(function() local r=req({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..userId.."&size=420x420&format=Png&isCircular=false", Method="GET"}); local d=HttpService:JSONDecode(r.Body); if d.data and d.data[1] then avatarUrl=d.data[1].imageUrl end end) end
    local payload = {["username"]="Bot Monitor", ["embeds"]={{["title"]="🟢 Bot Active: "..botName, ["color"]=3066993, ["thumbnail"]={["url"]=avatarUrl}, ["fields"]={{["name"]="Server JobId", ["value"]="```"..jobId.."```", ["inline"]=false}, {["name"]="Players", ["value"]=#Players:GetPlayers().." / 30", ["inline"]=true}, {["name"]="Actual Hop Time", ["value"]=timeDisplay, ["inline"]=true}}, ["timestamp"]=os.date("!%Y-%m-%dT%H:%M:%SZ")}}}
    if req then 
        local e = HttpService:JSONEncode(payload)
        if Webhooks["Status"] and Webhooks["Status"] ~= "YOUR_STATUS_WEBHOOK_HERE" then req({Url=Webhooks["Status"], Method="POST", Headers={["Content-Type"]="application/json"}, Body=e}) end
        if FriendWebhooks["Status"] and FriendWebhooks["Status"] ~= "FRIEND_STATUS_WEBHOOK_HERE" then req({Url=FriendWebhooks["Status"], Method="POST", Headers={["Content-Type"]="application/json"}, Body=e}) end
        req({Url="https://robbery-tracker-d43c5-default-rtdb.firebaseio.com/Statuses/"..botName..".json", Method="PATCH", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode({["AverageLogTime"]=HOP_DELAY, ["LatestJobId"]=jobId, ["LastUpdated"]=os.date("!%Y-%m-%dT%H:%M:%SZ")})})
    end
end
local function sendAlert(name, status, isDouble, region, extra, mapPos, isTrain, isPlane, planeObj)
    local key = isDouble and "DoubleBank" or (name..status..(region or ""))
    if alreadyNotified[key] then return end
    alreadyNotified[key] = true
    local myUrl, frUrl, icon, JobId = Webhooks[name] or Webhooks["Airdrop"], FriendWebhooks[name] or FriendWebhooks["Airdrop"], Icons[name] or "🚨", game.JobId
    local fields = {{["name"]="Status", ["value"]="**"..status.."**", ["inline"]=true}, {["name"]="Players", ["value"]="**"..#Players:GetPlayers().." / 30**", ["inline"]=true}, {["name"]="Game Time", ["value"]="**"..getGameTime().."**", ["inline"]=false}}
    if region and region ~= "" then table.insert(fields, {["name"]="Location", ["value"]="**"..region.."**", ["inline"]=true}) end
    if extra then for _, d in pairs(extra) do table.insert(fields, d) end end
    local mapUrl = nil; if mapPos then mapUrl = getGridImage(mapPos, isTrain, isPlane, planeObj); if (isTrain or isPlane) and not mapUrl then return end end
    local payload = {["content"]=isDouble and "🚨 💰💰 **DOUBLE BANK ALERT**" or (icon.." **"..name:upper().."**"), ["embeds"]={{["title"]=isDouble and "Both Banks are Active!" or (icon.." "..name.." is "..status.."!"), ["description"]="🚀 [Join Server via Tracker]("..MY_WEBSITE_URL.."?jobid="..JobId..")", ["color"]=isDouble and 16776960 or (status == "Open" and 65280 or 16744192), ["fields"]=fields, ["image"]=mapUrl and {["url"]=mapUrl} or nil}}}
    local req = (http_request or request or syn.request)
    if req then local e=HttpService:JSONEncode(payload); req({Url=myUrl, Method="POST", Headers={["Content-Type"]="application/json"}, Body=e}); if frUrl and frUrl~="FRIEND_LINK_HERE" then req({Url=frUrl, Method="POST", Headers={["Content-Type"]="application/json"}, Body=e}) end; req({Url=FIREBASE_BASE_URL..JobId.."_"..name:gsub("%s+", "")..".json", Method="PATCH", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode({["name"]=name, ["status"]=status, ["isDouble"]=isDouble or false, ["jobId"]=JobId, ["players"]=#Players:GetPlayers(), ["lastUpdated"]=os.time(), ["region"]=region or ""})}) end
end
task.spawn(function()
    local RobberyState = ReplicatedStorage:WaitForChild("RobberyState"); CheckServerBounties()
    task.spawn(function() local sms=false; while true do local dt=getDecimalTime(); if dt>=16.5 and dt<=17.75 then if not sms then sms=true; sendAlert("Mansion", "Closed", false, nil, {{["name"]="Game Time", ["value"]="**"..getGameTime().." (WILL OPEN SOON)**", ["inline"]=false}}) end else sms=false end; task.wait(5) end end)
    while true do
        local r, c = STATUS_NAMES[RobberyState["1"].Value], STATUS_NAMES[RobberyState["2"].Value]
        if r == "Open" and c == "Open" then sendAlert("Rising Bank", "Double Bank Active", true, nil, {{["name"]="Rising Bank", ["value"]="**"..r.."**", ["inline"]=true}, {["name"]="Crater Bank", ["value"]="**"..c.."**", ["inline"]=true}}) end
        for id, name in pairs(ROBBERY_NAMES) do
            local s = RobberyState:FindFirstChild(id)
            if s then
                local st = STATUS_NAMES[s.Value]
                local valid = true
                if st == "In Robbery" and (name=="Mansion" or name=="Rising Bank" or name=="Crater Bank" or name=="Bank Truck") then valid = false end
                if valid and (st == "Open" or st == "In Robbery") then
                    local keyCheck = name..st
                    if not alreadyNotified[keyCheck] then
                        local ex, pos, isTrain, isPlane, planeObj = {}, nil, false, false, nil
                        if name == "Casino" then
                            local tries = 0
                            repeat
                                local c, t = getCasinoCode(), (st=="In Robbery") and getCasinoTime() or nil
                                local ready = false
                                if st == "Open" and c then ready = true end
                                if st == "In Robbery" and c and t then ready = true end
                                if not ready then tries=tries+1; task.wait(0.5) else break end
                            until tries >= 30
                            local fc, ft = getCasinoCode(), getCasinoTime()
                            if fc then table.insert(ex, {["name"]="Casino Code", ["value"]="**"..fc.."**", ["inline"]=true}) end
                            if st == "In Robbery" and ft then table.insert(ex, {["name"]="Time Left", ["value"]="**"..ft.."**", ["inline"]=true}) end
                        elseif name == "Cargo Train" then
                            isTrain = true
                            local tries = 0
                            repeat
                                local tf = Workspace:FindFirstChild("Trains")
                                if tf then for _, car in pairs(tf:GetChildren()) do if car.Name:find("BoxCar") then if car:IsA("Model") then pos=car:GetPivot().Position else pos=car.Position end; break end end end
                                if not pos then tries=tries+1; task.wait(0.5) else break end
                            until tries >= 20
                        elseif name == "Cargo Plane" then
                            isPlane = true
                            if st == "Open" then
                                local tries = 0
                                repeat
                                    planeObj = Workspace:FindFirstChild("Plane")
                                    if planeObj then if planeObj:IsA("Model") then pos=planeObj:GetPivot().Position else pos=planeObj.Position end end
                                    if not pos then tries=tries+1; task.wait(0.5) else break end
                                until tries >= 20
                            else valid = false end
                        end
                        if valid then sendAlert(name, st, false, nil, ex, pos, isTrain, isPlane, planeObj) end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)
task.spawn(function()
    local HH, WR = 120, 1200
    local MISSIONS = {{Name="Dunes", Start=Vector3.new(649,HH,740), End=Vector3.new(492,HH,-905), HoverTime=3.0}, {Name="Cactus Valley", Start=Vector3.new(2103,HH,-4081), End=Vector3.new(-1469,HH,-4337), HoverTime=3.0}}
    local function droneScan(reg)
        pcall(function()
            local drop = Workspace:FindFirstChild("Drop")
            if drop and not alreadyNotified[drop] then
                local cn, wall = "Unknown", drop:FindFirstChild("Walls") and drop.Walls:FindFirstChild("Wall")
                if wall then
                    local c = wall.Color
                    local r, g, b = c.R*255, c.G*255, c.B*255
                    if r>40 and r<60 and b>140 then cn="Blue" elseif r>140 and g>90 and g<110 then cn="Brown" elseif r>140 and g<60 and b<60 then cn="Red" end
                end
                local st, ex = "Unopened", {}
                local tl = drop:FindFirstChild("Countdown") and drop.Countdown:FindFirstChild("Billboard") and drop.Countdown.Billboard:FindFirstChild("TextLabel")
                if tl and tl.Text and tl.Text ~= "30" then st="In Progress"; table.insert(ex, {["name"]="Time Left", ["value"]="**"..tl.Text.." seconds**", ["inline"]=true}) end
                
                local dPos = drop.PrimaryPart and drop.PrimaryPart.Position or drop:GetPivot().Position
                if Camera.CameraType ~= Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Scriptable end
                sendAlert(cn.." Airdrop", st, false, nil, ex, dPos, false, false, nil); alreadyNotified[drop]=true
            end
        end)
    end
    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
    local pg = LocalPlayer:WaitForChild("PlayerGui"); for _, g in pairs(pg:GetChildren()) do if g.Name:find("Team") or g.Name:find("Intro") then g:Destroy() end end
    while true do
        for _, m in pairs(MISSIONS) do
            Camera.CameraType = Enum.CameraType.Scriptable; Camera.CFrame = CFrame.new(m.Start, m.End)
            LocalPlayer:RequestStreamAroundAsync(m.Start, WR)
            TweenService:Create(Camera, TweenInfo.new(m.HoverTime, Enum.EasingStyle.Linear), {CFrame=CFrame.new(m.End, m.End+(m.End-m.Start).Unit)}):Play()
            local s = tick()
            while (tick() - s) < m.HoverTime do 
                if Camera.CameraType ~= Enum.CameraType.Scriptable then Camera.CameraType = Enum.CameraType.Scriptable end
                LocalPlayer:RequestStreamAroundAsync(Camera.CFrame.Position, WR); droneScan(m.Name); task.wait() 
            end
        end
        task.wait(0.1)
    end
end)
local function IsServerOccupied(jobId)
    local req = (http_request or request or syn.request); if not req then return false end
    local s, r = pcall(function() return req({Url=OCCUPIED_URL..jobId..".json", Method="GET"}) end)
    if s and r.Body ~= "null" then local d = HttpService:JSONDecode(r.Body); if d and d.Timestamp and (os.time() - d.Timestamp) < STALE_TIME then return true end end
    return false
end
local function ClaimServer(jobId)
    local req = (http_request or request or syn.request); if not req then return false end
    pcall(function() req({Url=OCCUPIED_URL..jobId..".json", Method="PUT", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode({["Bot"]=LocalPlayer.Name, ["Timestamp"]=os.time()})}) end); task.wait(1.2)
    local s, r = pcall(function() return req({Url=OCCUPIED_URL..jobId..".json", Method="GET"}) end)
    if s then local d = HttpService:JSONDecode(r.Body); if d and d.Bot == LocalPlayer.Name then return true end end
    return false
end
local function ServerHop()
    local searchStart = os.time(); print("⏳ Logging status and waiting to hop..."); task.wait(HOP_DELAY + math.random(1, 4))
    while true do
        local s, r = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100") end)
        if s then
            local d = HttpService:JSONDecode(r)
            if d and d.data then
                for _, srv in pairs(d.data) do
                    local isBlacklisted = false
                    local val = _G.ServerBlacklist[srv.id]
                    if val then
                        if type(val) == "number" then
                            if (os.time() - val) < 600 then isBlacklisted = true else _G.ServerBlacklist[srv.id] = nil end
                        else
                            isBlacklisted = true -- Legacy boolean support
                        end
                    end
                    if srv.id ~= game.JobId and srv.playing > 0 and srv.playing <= MAX_PLAYERS and not isBlacklisted then
                        if not IsServerOccupied(srv.id) then
                            print("🛰️ Attempting to claim: "..srv.id)
                            if ClaimServer(srv.id) then
                                local timeTaken = os.time() - searchStart; print("🚀 Claim Successful! Time taken: " .. timeTaken .. "s"); SendBotHeartbeat(timeTaken); 
                                _G.ServerBlacklist[srv.id] = os.time() -- Save Timestamp
                                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer) end); task.wait(5)
                                return -- Stop looping
                            else print("❌ Claim failed (Race lost), trying next server...") end
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end
print("✅ SCRIPT UPDATED: Bounty Sniper Syncing to Website"); ServerHop()
