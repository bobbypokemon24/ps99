-- AERO PS99 v8.2.84 P24.4 | Delta Android startup-safe build.
-- Self-contained: embedded PS99 automation, AERO Portable GUI, and ZHub console.
-- Startup UI is created BEFORE compiling the large PS99 body, so a compilation
-- or initialization error can be reported even when the main GUI never mounts.
-- No remote code or external UI library is downloaded.
local BOOT_VERSION="AERO PS99 v8.2.84"
local bootGui,bootStatusLabel,bootErrorLabel
local bootReady,bootFailed=false,false
local bootFailure=""
local function startScreen()
    local ok,err=pcall(function()
        local players=game:GetService("Players")
        local lp=players.LocalPlayer
        local target=lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui",8))
        if not target then
            local success,result=pcall(function() return (type(gethui)=="function" and gethui()) or game:GetService("CoreGui") end)
            if success then target=result end
        end
        if not target then error("No visible GUI parent yet") end
        local previous=target:FindFirstChild("AERO_PS99_Startup")
        if previous then previous:Destroy() end
        local function add(class,props,parent)
            local obj=Instance.new(class)
            for k,v in pairs(props) do obj[k]=v end
            obj.Parent=parent
            return obj
        end
        bootGui=add("ScreenGui",{Name="AERO_PS99_Startup",ResetOnSpawn=false,IgnoreGuiInset=true,
            DisplayOrder=9999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},target)
        local frame=add("Frame",{Name="StatusPanel",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
            Size=UDim2.new(1,-24,0,280),BackgroundColor3=Color3.fromRGB(16,23,34),BorderSizePixel=0},bootGui)
        add("UISizeConstraint",{MaxSize=Vector2.new(530,280)},frame)
        add("UICorner",{CornerRadius=UDim.new(0,12)},frame)
        add("UIStroke",{Color=Color3.fromRGB(44,152,168),Thickness=1,Transparency=0.35},frame)
        add("TextLabel",{Text=BOOT_VERSION.." • Startup",Size=UDim2.new(1,-30,0,33),Position=UDim2.fromOffset(15,12),
            BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=18,
            TextColor3=Color3.fromRGB(231,242,255),TextXAlignment=Enum.TextXAlignment.Left},frame)
        bootStatusLabel=add("TextLabel",{Text="Bootloader started",Size=UDim2.new(1,-30,0,41),Position=UDim2.fromOffset(15,53),
            BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=14,TextWrapped=true,
            TextColor3=Color3.fromRGB(146,213,221),TextXAlignment=Enum.TextXAlignment.Left},frame)
        local scroll=add("ScrollingFrame",{Size=UDim2.new(1,-30,0,105),Position=UDim2.fromOffset(15,99),
            BackgroundColor3=Color3.fromRGB(10,15,23),BorderSizePixel=0,
            ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,420)},frame)
        add("UICorner",{CornerRadius=UDim.new(0,6)},scroll)
        bootErrorLabel=add("TextLabel",{Text="If startup fails, the error will appear here.",
            Size=UDim2.new(1,-12,0,412),Position=UDim2.fromOffset(6,6),
            BackgroundTransparency=1,Font=Enum.Font.Code,TextSize=12,TextWrapped=true,
            TextYAlignment=Enum.TextYAlignment.Top,TextXAlignment=Enum.TextXAlignment.Left,
            TextColor3=Color3.fromRGB(184,199,220)},scroll)
        local copy=add("TextButton",{Name="CopyError",Text="Copy error",Size=UDim2.new(0.48,-20,0,39),Position=UDim2.new(0,15,1,-55),
            BackgroundColor3=Color3.fromRGB(24,78,90),Font=Enum.Font.GothamBold,
            TextColor3=Color3.fromRGB(240,249,255),TextSize=14},frame)
        add("UICorner",{CornerRadius=UDim.new(0,6)},copy)
        local dismiss=add("TextButton",{Name="Dismiss",Text="Dismiss",Size=UDim2.new(0.48,-20,0,39),
            Position=UDim2.new(0.52,5,1,-55),BackgroundColor3=Color3.fromRGB(51,60,74),
            Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(240,249,255),TextSize=14},frame)
        add("UICorner",{CornerRadius=UDim.new(0,6)},dismiss)
        copy.Activated:Connect(function()
            if type(setclipboard)=="function" then
                local success=pcall(setclipboard,bootFailure~="" and bootFailure or bootStatusLabel.Text)
                if success then copy.Text="Copied" else copy.Text="Clipboard error" end
            else copy.Text="No clipboard" end
        end)
        dismiss.Activated:Connect(function() if bootGui then bootGui.Enabled=false end end)
    end)
    if not ok then warn("[AERO BOOT] Startup panel unavailable: "..tostring(err)) end
end
local function setStatus(message)
    print("[AERO BOOT] "..tostring(message))
    if bootGui and bootGui.Parent then bootGui.Enabled=true end
    if bootStatusLabel then bootStatusLabel.Text=tostring(message) end
end
local function fail(message)
    bootFailed=true
    bootFailure=tostring(message)
    warn("[AERO BOOT] "..bootFailure)
    if bootGui and bootGui.Parent then bootGui.Enabled=true end
    if bootStatusLabel then
        bootStatusLabel.Text="Startup stopped. Copy the error below or check Delta's console."
        bootStatusLabel.TextColor3=Color3.fromRGB(255,163,153)
    end
    if bootErrorLabel then
        bootErrorLabel.Text=bootFailure:sub(1,3800)
        bootErrorLabel.TextColor3=Color3.fromRGB(255,174,159)
    end
end
local function errorTrace(err)
    local s=tostring(err)
    if type(debug)=="table" and type(debug.traceback)=="function" then
        local ok,result=pcall(debug.traceback,s,2)
        if ok and type(result)=="string" then return result end
    end
    return s
end
startScreen()
_G.AERO_PS99_BOOT_STATUS=setStatus
_G.AERO_PS99_BOOT_FAIL=fail
_G.AERO_PS99_BOOT_READY=function()
    bootReady=true
    setStatus("AERO Portable GUI and ZHub Console initialized")
end
setStatus("Compiling embedded PS99 engine...")
local source=[========[
print("[AERO BOOT] v8.2.84 P24.4 execution started")
-- v8.2.57: optional Smart Pet Assignment V1.3 (default off); Fast Tap untested; collection unfinished.
-- AERO PS99 v8.2.57: stable GUI baseline for the next feature.
-- Enchants: highest owned tier, duplicate copies, account-scoped automatic list saving.
-- Auto-equip starts off, replaces current enchants, and checks each server state change.
-- Paid-slot calculation remains unverified.

-- AERO_PS99 v8.2.57: lifecycle, initialization, animation and spy repairs.
-- Static validation only; PS99/Delta runtime behavior requires in-game testing.
repeat task.wait() until game:IsLoaded()
if type(_G.AERO_PS99_BOOT_STATUS)=="function" then
    _G.AERO_PS99_BOOT_STATUS("Game loaded; checking PS99 dependencies")
end

local cloneref = cloneref or function(x) return x end
local Players = cloneref(game:GetService("Players"))
local RS = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local Workspace = cloneref(game:GetService("Workspace"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local RunService = cloneref(game:GetService("RunService"))
local GuiService = cloneref(game:GetService("GuiService"))
-- Recover a disabled renderer left by v8.2.67/v8.2.68 before startup waits.
pcall(function() RunService:Set3dRenderingEnabled(true) end)
local UIS = cloneref(game:GetService("UserInputService"))

if type(_G.PS99Cleanup) == "function" then
    pcall(_G.PS99Cleanup)
end
_G.PS99Generation = (_G.PS99Generation or 0) + 1
local myGeneration = _G.PS99Generation
local _cleaned = false
local function isRunning()
    return _G.PS99Generation == myGeneration and not _cleaned
end

-- All spawned work belongs to this execution, including UI and module reads.
local sessionTasks=setmetatable({},{__mode="k"})
local function spawnTask(fn,...)
    if not isRunning() then return nil end
    local thread=task.spawn(function(...)
        local current=coroutine.running()
        if not isRunning() then return end
        local result=table.pack(pcall(fn,...))
        sessionTasks[current]=nil
        if not result[1] then error(result[2],0) end
    end,...)
    if coroutine.status(thread)~="dead" then
        if isRunning() then sessionTasks[thread]=true
        else pcall(task.cancel,thread) end
    end
    return thread
end

-- declared before cleanup(): it was declared further down, so cleanup() saw a nil global and
-- the old UI never got removed on re-execute
local LocalPlayer = Players.LocalPlayer

local _connections = {}
local _cleanupCallbacks = {}
local function trackConnection(conn)
    if conn then _connections[#_connections + 1] = conn end
    return conn
end
local function onCleanup(fn)
    _cleanupCallbacks[#_cleanupCallbacks + 1] = fn
end
local function cleanup()
    if _cleaned then return end
    _cleaned = true
    for i = #_connections, 1, -1 do
        pcall(function() _connections[i]:Disconnect() end)
    end
    for i = #_cleanupCallbacks, 1, -1 do pcall(_cleanupCallbacks[i]) end
    pcall(function()
        local root = LocalPlayer:FindFirstChild("PlayerGui") or ((gethui and gethui()) or game:GetService("CoreGui"))
        local old = root:FindFirstChild("PS99UI")
        if old then old:Destroy() end
    end)
    for thread in pairs(sessionTasks) do
        if thread~=coroutine.running() and coroutine.status(thread)~="dead" then
            pcall(task.cancel,thread)
        end
        sessionTasks[thread]=nil
    end
    if _G.PS99Cleanup == cleanup then _G.PS99Cleanup = nil end
end
_G.PS99Cleanup = cleanup

do -- isolate temporary place allowlist; not needed after this check
local KNOWN_PLACES = { [8737899170] = true, [16498369169] = true, [17503543197] = true, [140403681187145] = true }
if not KNOWN_PLACES[game.PlaceId] then
    warn("[PS99] unknown PlaceId " .. game.PlaceId)
end
end

local Network = RS:WaitForChild("Network", 30)
local Things = Workspace:WaitForChild("__THINGS", 30)
if not Network or not Things then
    local missing="Network or __THINGS missing after 30-second bounded waits"
    warn("[PS99] Startup stopped: "..missing)
    if type(_G.AERO_PS99_BOOT_FAIL)=="function" then _G.AERO_PS99_BOOT_FAIL(missing) end
    cleanup()
    return
end
if type(_G.AERO_PS99_BOOT_STATUS)=="function" then
    _G.AERO_PS99_BOOT_STATUS("Dependencies ready; initializing automation and GUI")
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart", 10)
if not HRP then
    spawnTask(function()
        while isRunning() and LocalPlayer.Character == Character and not Character:FindFirstChild("HumanoidRootPart") do
            task.wait(1)
        end
        if isRunning() and LocalPlayer.Character == Character then
            HRP = Character:FindFirstChild("HumanoidRootPart")
        end
    end)
end
trackConnection(LocalPlayer.CharacterAdded:Connect(function(c)
    Character = c
    HRP = nil
    local root = c:WaitForChild("HumanoidRootPart", 10)
    if LocalPlayer.Character == c then
        HRP = root
        if not HRP then
            spawnTask(function()
                while isRunning() and LocalPlayer.Character == c and not c:FindFirstChild("HumanoidRootPart") do
                    task.wait(1)
                end
                if isRunning() and LocalPlayer.Character == c then
                    HRP = c:FindFirstChild("HumanoidRootPart")
                end
            end)
        end
    end
end))
local debugLog = function() end -- real version is assigned once Flags exists (below)
local REQUEST_STATUS={sent=0,errors=0,missing=0,overlap=0,stale=0,inflight={}}
-- Feature evidence is separate from task liveness. No remote acceptance is
-- promoted to observed gameplay success by these counters.
-- Notifications must not turn a completed button action into a callback error.
function REQUEST_STATUS.notify(message)
    local text=tostring(message or "Done")
    print("[AERO UI] "..text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="AERO PS99",Text=text,Duration=5})
    end)
end
REQUEST_STATUS.evidence={}
function REQUEST_STATUS.observe(feature,event,detail)
    local row=REQUEST_STATUS.evidence[feature]
    if not row then row={requests=0,accepted=0,rejected=0,errors=0,observed=0} REQUEST_STATUS.evidence[feature]=row end
    row[event]=(row[event] or 0)+1
    row.lastEvent=event row.lastAt=os.time()
    if detail then row.detail=tostring(detail):sub(1,240) end
    return row
end

-- Shared scheduler for inventory-changing upgrade and key batches.
-- A yielding server call keeps its slot: a timeout must never launch duplicates.
REQUEST_STATUS.automation=(function()
    local E={active=nil,rows={},nextAt=0,gap=0.5,recoveries=0}
    function E.note(owner,reason,state)
        local r=E.rows[owner]
        if not r then r={state="idle",completed=0,failures=0,nextAt=0,sent=0} E.rows[owner]=r end
        r.reason=tostring(reason) r.touched=os.clock()
        if state and not (E.active and E.active.owner==owner) then r.state=state end
    end
    function E.poll()
        if not isRunning() or not E.active then return end
        local token=E.active
        if token.invoking then
            if os.clock()-(token.started or os.clock())>=20 and not token.warned then
                token.warned=true
                E.note(token.owner,"Server response delayed; holding request slot to prevent duplicate actions")
                warn("[AERO ENGINE] "..token.owner..": server response delayed; request remains locked")
            end
        elseif os.clock()>=token.deadline then
            E.recoveries+=1
            E.finish(token,"unconfirmed")
            E.note(token.owner,"Verification expired; released scheduler slot and applied retry cooldown","recovering")
            warn("[AERO ENGINE] Recovered expired verification: "..token.owner)
        end
    end
    function E.finish(token,outcome,quantity)
        if E.active~=token then return end
        local r=E.rows[token.owner]
        r.state=outcome
        if outcome=="verified" or outcome=="reconciled" then
            if outcome=="verified" then r.completed+=(quantity or 0)
            else r.reconciled=(r.reconciled or 0)+(quantity or 0) end
            r.failures=0 r.nextAt=os.clock()+E.gap
        else
            r.failures+=1
            r.nextAt=os.clock()+math.min(120,15*2^math.min(r.failures-1,3))
        end
        E.active=nil E.nextAt=os.clock()+E.gap
    end
    function E.acquire(owner)
        if not isRunning() then return nil end
        local now=os.clock()
        E.poll()
        if E.active or now<E.nextAt then return nil end
        local r=E.rows[owner]
        if not r then r={state="idle",completed=0,failures=0,nextAt=0,sent=0} E.rows[owner]=r end
        if now<r.nextAt then return nil end
        local token={owner=owner,deadline=now+15,invoking=false}
        E.active=token r.state="preparing"
        return token
    end
    function E.invoke(token,fn,...)
        if E.active~=token or not isRunning() then return false,false,"Stopped" end
        token.invoking=true token.started=os.clock()
        local r=E.rows[token.owner] r.state="requesting" r.sent+=1
        local values=table.pack(pcall(fn,...))
        token.invoking=false token.deadline=os.clock()+15
        E.gap=math.clamp((os.clock()-token.started)*1.5,0.5,2)
        if values[1] and values[2]==true then r.state="verifying"
        else E.finish(token,"deferred") end
        return table.unpack(values,1,values.n)
    end
    function E.summary()
        local parts={"Batch scheduler: "..(E.active and (E.active.owner.." / "..(E.active.invoking and "awaiting server" or "verifying inventory")) or "idle")}
        for _,owner in ipairs({"upgrades","keys","pet-crafting","best-area","best-world","fast-farm"}) do
            local r=E.rows[owner]
            if r then parts[#parts+1]=owner..": "..r.state..", verified items="..r.completed..", requests="..r.sent..", consecutive failures="..r.failures..", retry in="..math.ceil(math.max(0,r.nextAt-os.clock())).."s" end
        end
        for _,owner in ipairs({"upgrades","keys","pet-crafting","best-area","best-world","fast-farm"}) do
            local r=E.rows[owner]
            if r and r.reason then parts[#parts+1]=owner.." detail: "..r.reason end
        end
        parts[#parts+1]="Automatic verification recoveries: "..E.recoveries
        return table.concat(parts,"\n")
    end
    onCleanup(function() E.active=nil table.clear(E.rows) end)
    return E
end)()

local function requestKey(name,args)
    if args.n>8 then return nil end
    local parts={tostring(#name)..":"..name}
    for i=1,args.n do
        local value=args[i]
        local kind=type(value)
        if kind~="string" and kind~="number" and kind~="boolean" and kind~="nil" then return nil end
        local text=tostring(value)
        if #text>256 then return nil end
        parts[#parts+1]=kind..":"..#text..":"..text
    end
    return table.concat(parts,"|")
end
local function fire(name, ...)
    if not isRunning() then REQUEST_STATUS.stale+=1 return false,nil end
    local r=Network:FindFirstChild(name)
    if not r then REQUEST_STATUS.missing+=1 debugLog("fire",name.." missing") return false,nil end
    REQUEST_STATUS.sent+=1
    local ok,res=pcall(r.FireServer,r,...)
    if not ok then REQUEST_STATUS.errors+=1 end
    debugLog("fire",name.." ok="..tostring(ok))
    return ok,res
end
local function invoke(name, ...)
    if not isRunning() then REQUEST_STATUS.stale+=1 return false,nil end
    local r=Network:FindFirstChild(name)
    if not r then REQUEST_STATUS.missing+=1 debugLog("invoke",name.." missing") return false,nil end
    local args=table.pack(...)
    local key=requestKey(name,args)
    if key and REQUEST_STATUS.inflight[key] then
        REQUEST_STATUS.overlap+=1 return false,nil
    end
    if key then REQUEST_STATUS.inflight[key]=true end
    REQUEST_STATUS.sent+=1
    local ok,res=pcall(r.InvokeServer,r,table.unpack(args,1,args.n))
    if key then REQUEST_STATUS.inflight[key]=nil end
    if not ok then REQUEST_STATUS.errors+=1 end
    -- A response from the previous execution must not trigger follow-up work.
    if not isRunning() then REQUEST_STATUS.stale+=1 return false,nil end
    debugLog("invoke",name.." ok="..tostring(ok).." res="..(type(res)=="table" and "table" or tostring(res)))
    return ok,res
end
onCleanup(function() table.clear(REQUEST_STATUS.inflight) end)

local Flags -- forward declaration required by animation callbacks
local eggPatch
local eggAnimationStatus="pending"
local function restoreEggAnim()
    if eggPatch then
        pcall(function()
            if eggPatch.env.PlayEggAnimation == eggPatch.replacement then
                eggPatch.env.PlayEggAnimation = eggPatch.original
            end
        end)
        eggPatch=nil
    end
end
local function applyEggAnim()
    if not isRunning() then return false,"unloaded" end
    if type(getsenv) ~= "function" then return false, "getsenv unavailable" end
    local ok,err=pcall(function()
        local scripts=LocalPlayer:FindFirstChild("PlayerScripts")
        local folder=scripts and scripts:FindFirstChild("Scripts")
        local gameFolder=folder and folder:FindFirstChild("Game")
        local eggs=gameFolder and gameFolder:FindFirstChild("Egg Opening Frontend")
        if not eggs then error("Egg Opening Frontend unavailable") end
        local context=getsenv(eggs)
        if eggPatch and eggPatch.env==context and context.PlayEggAnimation==eggPatch.replacement then return end
        restoreEggAnim()
        if type(context.PlayEggAnimation)~="function" then error("PlayEggAnimation unavailable") end
        local replacement=function(...) return nil end
        eggPatch={env=context,original=context.PlayEggAnimation,replacement=replacement}
        context.PlayEggAnimation=replacement
        if context.PlayEggAnimation~=replacement then error("Animation replacement did not persist") end
    end)
    return ok,err
end
onCleanup(restoreEggAnim)

local FALLBACK_EGGS = {"Cracked Egg","Spotted Egg","Paw Egg","Grass Egg","Wood Egg","Pumpkin Egg"}
local EggLabels, EggByLabel = {}, {}
local function apiGet(path)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://ps99.biggamesapi.io/api/collection/" .. path))
    end)
    if ok and type(data) == "table" and data.status == "ok" and type(data.data) == "table" then
        return data.data
    end
end
local function loadEggsFromApi()
    local rows = apiGet("Eggs")
    if not rows then return false end
    local list = {}
    for _, e in ipairs(rows) do
        local c = e.configData
        if type(c) == "table" and type(c.eggNumber) == "number" and type(c.name) == "string" then
            list[#list + 1] = { n = c.eggNumber, name = c.name }
        end
    end
    if #list == 0 then return false end
    table.sort(list, function(a, b) return a.n < b.n end)
    EggLabels, EggByLabel = {}, {}
    for _, e in ipairs(list) do
        local label = string.format("%d | %s", e.n, e.name)
        EggLabels[#EggLabels + 1] = label
        EggByLabel[label] = e.name
    end
    return true
end
if not loadEggsFromApi() then
    for _, n in ipairs(FALLBACK_EGGS) do
        EggLabels[#EggLabels + 1] = n
        EggByLabel[n] = n
    end
end
local DefaultEgg = EggByLabel[EggLabels[1]] or "Cracked Egg"
for _, l in ipairs(EggLabels) do
    if EggByLabel[l] == "Cracked Egg" then DefaultEgg = EggByLabel[l] break end
end

local ZoneNames = {}
do
    local rows = apiGet("Zones")
    if rows then
        local list = {}
        for _, z in ipairs(rows) do
            local c = z.configData
            if type(c) == "table" and type(c.ZoneName) == "string" and type(c.ZoneNumber) == "number" then
                list[#list + 1] = { n = c.ZoneNumber, name = c.ZoneName }
            end
        end
        table.sort(list, function(a, b) return a.n < b.n end)
        for _, z in ipairs(list) do ZoneNames[#ZoneNames + 1] = z.name end
    end
end

Flags = {
    Collect = false, CollectLootbags = false, Breakables = false, AutoHatch = false, AntiAFK = false,
    FreeGifts = false, Spinner = false, BuyZones = false, FPSBoost = false,
    AutoRejoin = false, Tap = false, BuySlots = false, RareAlerts = false,
    OptBreak = false, OptPets = false, OptPart = false, OptGame = false,
    RareTitanic = true, RareHuge = true, RareExclusive = true,
    NearestEgg = false, BuyEquipSlots = false, AutoRebirth = false, Spy = false, AutoQuest = false,
    HalloweenZone = false, HalloweenHatch = false, HalloweenForge = false, HalloweenUpgrade = false, HUD = false, Debug = false, RecordConsole = false,
    AutoJoinHalloween = false, AutoPlayHalloween = false, AutoUseTricks = false,
    HalloweenDestroyDecor = false, HalloweenAutoTeleport = false,
    InfPetSpeed = false, FastFarm = false, NativeAutoTap = false, SmartPets = false, AutoUltimate = false, AutoBestArea = false,
    AutoNextArea = false, AutoBestWorld = false, AutoUseMisc = false, AutoUseFlag = false,
    AutoUseSprinkler = false, AutoUseTNT = false, AutoUseTNTCrate = false,
    AutoBuyUpgrades = false, AutoBuyEggBundle = false,
    DisableEggAnim = true, AutoMakeGold = false, AutoMakeRainbow = false,
    AutoFuse = false, AutoAttachCharm = false,
    AutoClaimRank = false, AutoClaimForever = false, AutoShinyRelics = false,
    AutoPopBalloons = false, AutoLeaveStairway = false, AutoAdminAbuse = false,
    AutoTreehouse = false, AutoCompleteRank = false, AutoCrystalCastle = false,
    AutoEatFruits = false, AutoUseBuffs = false, AutoUsePotions = false, AutoEquipEnchants = false,
    AutoOpenGifts = false, AutoOpenLootboxes = false, AutoCombineKeys = false,
    AutoOpenCrystalChest = false, AutoSpinWheel = false, AutoRainbowFruits = false,
    AutoShinyFruits = false, AutoUpgradePotions = false, AutoUpgradeEnchants = false,
    WalkSpeedEnable = false, JumpPowerEnable = false, InfiniteJump = false, NoClip = false,
    WhiteScreen = false,
}
local State = {
    EggSelection = "Best Zone Egg", CustomEgg = "", SlotNumber = 1, RebirthNum = 1, CollectDelay = 1,
    TapInterval = 0.03, TapTargets = 4, TapRadius = 90, SmartPetCount = 5,
    BreakDelay = 0.2, Radius = 70, Targets = 1, Egg = DefaultEgg,
    Amount = 1, HatchDelay = 0.3, RewardEvery = 30, Keywords = "", SummaryMins = 0,
    WebhookUrl = "",
    EggSlotMax = 20, EquipSlotMax = 20, RebirthMax = 100, SpyFilter = "",
    MinArea = 1, ForgeChance = 50, ForgeShards = 0, Picks = {},
    TNTDelay = 3.5, TNTCrateDelay = 15, FusePetName = "", CraftPetSearch = "", CraftPetMode = "All owned", CraftPetSort = "Most owned", FusePetAmount = 3,
    PriorityWait = 5, MaxRank = 40,
    EventUpgradeSelection = "All event upgrades", EventUpgradeSessionLimit = 5,
    CharmSelection = "Select charm", CharmPetUID = "", CharmSessionLimit = 1,
    BalloonMode = "Observe only",
    KeySelection = "", FlagSelection = "Strength Flag",
    UpgradePotionSelection="Lucky", UpgradeEnchantSelection="Strong Pets", UpgradeInterval=3, UpgradeSessionLimit=25,
    PotionRefillSeconds = 300, FruitSelection = "All", PotionSelection = "All", BuffSelection = "All", GiftSelection = "All", LootboxSelection = "All", WalkSpeed = 16, JumpPower = 50, RejoinMins = 5,
}
local Stats = { Orbs = 0, Bags = 0, Hatches = 0, Start = tick() }

-- console recorder: 4000-line ring buffer of print/warn while RecordConsole is on (ported from kaitun)
local CONSOLE = { buf = {}, max = 4000, head = 1, count = 0, t0 = tick() }
local rawPrint, rawWarn = print, warn
local function consolePush(kind, ...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring((select(i, ...))) end
    local line = string.format("[%7.1f] %s %s", tick() - CONSOLE.t0, kind, table.concat(parts, " "))
    local index
    if CONSOLE.count < CONSOLE.max then
        index = ((CONSOLE.head + CONSOLE.count - 1) % CONSOLE.max) + 1
        CONSOLE.count += 1
    else
        index = CONSOLE.head
        CONSOLE.head = (CONSOLE.head % CONSOLE.max) + 1
    end
    CONSOLE.buf[index] = line
end
CONSOLE.printWrap = function(...)
    if Flags.RecordConsole then consolePush("INFO", ...) end
    return rawPrint(...)
end
CONSOLE.warnWrap = function(...)
    if Flags.RecordConsole then consolePush("WARN", ...) end
    return rawWarn(...)
end
print = CONSOLE.printWrap
warn = CONSOLE.warnWrap
onCleanup(function()
    if print == CONSOLE.printWrap then print = rawPrint end
    if warn == CONSOLE.warnWrap then warn = rawWarn end
end)

-- debug logs: only when Debug is on (F8 or the MISC toggle). the remote helpers log every call result
debugLog = function(tag, msg)
    if not Flags.Debug then return end
    print(string.format("[ps99] %-8s %s", tag, tostring(msg)))
end


-- Lightweight performance telemetry. Counters are bounded and never retain Instances.
local PERFORMANCE = {
    startedAt = tick(), samples = {}, maxSamples = 30,
    inventoryScans = 0, inventoryCacheHits = 0, inventoryLastDuration = 0,
    inventoryLastItems = 0, inventoryCachedAt = 0,
}
local function recordPerf(name, duration)
    local bucket = PERFORMANCE.samples[name] or { count = 0, total = 0, max = 0, last = 0 }
    bucket.count += 1
    bucket.total += duration
    bucket.last = duration
    if duration > bucket.max then bucket.max = duration end
    PERFORMANCE.samples[name] = bucket
end
local function performanceSummary()
    local elapsed = math.max(1, tick() - PERFORMANCE.startedAt)
    local inv = PERFORMANCE.samples.inventory or { count = 0, total = 0, max = 0, last = 0 }
    local egg = PERFORMANCE.samples.egg_scan or { count = 0, total = 0, max = 0, last = 0 }
    return string.format(
        "Uptime %.0fs | inventory scans %d (cache hits %d, last %.3f s) | egg scans %d (last %.3f s) | avg scan %.3f s",
        elapsed, PERFORMANCE.inventoryScans, PERFORMANCE.inventoryCacheHits,
        PERFORMANCE.inventoryLastDuration, egg.count, egg.last,
        inv.count > 0 and inv.total / inv.count or 0)
end

-- Runtime worker diagnostics. A failed background task is reported with its traceback
-- instead of disappearing as an unhandled task.spawn exception.
local WORKER_DIAGNOSTICS = { errors = {}, maxErrors = 40, total = 0, last = nil }
local WORKER_STATUS = {}
local function reportWorkerError(name, err)
    local entry = { at = os.date("%H:%M:%S"), worker = tostring(name), error = tostring(err) }
    WORKER_DIAGNOSTICS.total += 1
    WORKER_DIAGNOSTICS.last = entry
    table.insert(WORKER_DIAGNOSTICS.errors, entry)
    if #WORKER_DIAGNOSTICS.errors > WORKER_DIAGNOSTICS.maxErrors then table.remove(WORKER_DIAGNOSTICS.errors, 1) end
    rawWarn(string.format("[PS99][worker:%s] %s", entry.worker, entry.error))
end

-- Supervise long-running loops. Transient errors retry with bounded exponential
-- backoff; five consecutive failures mark a worker failed instead of spinning forever.
local WORKER_REGISTRY={}
local function guardedSpawn(name, fn, ...)
    local key=tostring(name)
    local existing=WORKER_STATUS[key]
    if existing and (existing.state=="running" or existing.state=="starting" or existing.state=="backoff") then
        return existing.thread
    end
    if not isRunning() then return nil end
    local args=table.pack(...)
    WORKER_REGISTRY[key]={fn=fn,args=args}
    local status={state="starting",restarts=existing and existing.restarts or 0,failures=0,since=tick()}
    WORKER_STATUS[key]=status
    status.thread=spawnTask(function()
        while isRunning() and status.failures<5 do
            status.state="running"
            local started=tick()
            local ok,err=xpcall(function() fn(table.unpack(args,1,args.n)) end,debug.traceback)
            if not isRunning() then break end
            if ok then status.state="stopped" status.lastExit=os.date("%H:%M:%S") break end
            reportWorkerError(key,err)
            if tick()-started>=30 then status.failures=0 end
            status.failures+=1 status.restarts+=1
            status.state=status.failures>=5 and "failed" or "backoff"
            status.lastError=tostring(err):sub(1,240)
            if status.failures<5 then task.wait(math.min(15,2^(status.failures-1))) end
        end
        if not isRunning() then status.state="unloaded" end
    end)
    return status.thread
end
local function retryFailedWorkers()
    local count=0
    if not isRunning() then return count end
    for key,spec in pairs(WORKER_REGISTRY) do
        local status=WORKER_STATUS[key]
        if status and status.state=="failed" then
            guardedSpawn(key,spec.fn,table.unpack(spec.args,1,spec.args.n))
            count+=1
        end
    end
    return count
end
onCleanup(function()
    for _,status in pairs(WORKER_STATUS) do
        local thread=status.thread
        if thread and thread~=coroutine.running() and coroutine.status(thread)~="dead" then
            pcall(task.cancel,thread)
        end
        status.state="unloaded"
    end
end)

local function workerDiagnosticSummary()
    local running, failed, backoff, total = 0, 0, 0, 0
    for _, st in pairs(WORKER_STATUS) do
        total += 1
        if st.state == "running" then running += 1
        elseif st.state == "failed" then failed += 1
        elseif st.state == "backoff" then backoff += 1 end
    end
    return string.format("Workers: %d tracked | %d active | %d retrying | %d failed | %d total errors",
        total, running, backoff, failed, WORKER_DIAGNOSTICS.total)..
        string.format(" | Shared requests: %d sent, %d errors, %d overlaps blocked, %d stale blocked",
            REQUEST_STATUS.sent,REQUEST_STATUS.errors,REQUEST_STATUS.overlap,REQUEST_STATUS.stale)
end

-- Feature dependency snapshot: report missing expected remotes without assuming that
-- an endpoint exists or invoking it. This is diagnostic only and never fires requests.
local FEATURE_DEPENDENCIES = {
    AutoHatch = { "Eggs_RequestPurchase" },
    NearestEgg = { "Eggs_RequestPurchase", "CustomEggs_Hatch" },
    AutoRebirth = { "Rebirth_Request" },
    BuyZones = { "Zones_RequestPurchase" },
    Collect = { "Orbs: Collect" },
    CollectLootbags = { "Orbs: Collect" },
    Breakables = { "Breakables_PlayerDealDamage" },
    HalloweenHatch = { "Eggs_RequestPurchase", "CustomEggs_Hatch" },
}
local function dependencyLines()
    local lines = { "Feature dependency checks (presence only; not proof of server acceptance):" }
    local names = {}
    for name in pairs(FEATURE_DEPENDENCIES) do names[#names + 1] = name end
    table.sort(names)
    for _, feature in ipairs(names) do
        local missing = {}
        for _, remoteName in ipairs(FEATURE_DEPENDENCIES[feature]) do
            if not Network:FindFirstChild(remoteName) then missing[#missing + 1] = remoteName end
        end
        lines[#lines + 1] = feature .. ": " .. (#missing == 0 and "dependencies present" or ("missing " .. table.concat(missing, ", ")))
    end
    return lines
end

local function workerDiagnosticDetails()
    local lines, names = { workerDiagnosticSummary(), performanceSummary(), REQUEST_STATUS.automation.summary() }, {}
    for _, line in ipairs(dependencyLines()) do lines[#lines + 1] = line end
    for name in pairs(WORKER_STATUS) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
        local st = WORKER_STATUS[name]
        lines[#lines + 1] = string.format("%s: %s (restarts=%d, consecutive failures=%d)%s", name, st.state,
            st.restarts or 0, st.failures or 0, st.lastError and (" - " .. st.lastError) or "")
    end
    for i = math.max(1, #WORKER_DIAGNOSTICS.errors - 9), #WORKER_DIAGNOSTICS.errors do
        local e = WORKER_DIAGNOSTICS.errors[i]
        lines[#lines + 1] = string.format("[%s] %s: %s", e.at, e.worker, e.error)
    end
    return lines
end

-- Preserve legacy console helpers in a private scope; the live ZHub tab uses
-- independent controls. They were otherwise consuming two main-chunk locals.
do
-- returns a status line for the toast; clipboard first, then a file when the executor has writefile
local function copyConsoleLog()
    if CONSOLE.count == 0 then return "console log empty (turn RecordConsole on)" end
    local ordered = {}
    for i = 1, CONSOLE.count do
        ordered[i] = CONSOLE.buf[((CONSOLE.head + i - 2) % CONSOLE.max) + 1]
    end
    local text = table.concat(ordered, "\n")
    if type(setclipboard) == "function" and pcall(setclipboard, text) then
        return "copied " .. CONSOLE.count .. " log lines"
    end
    if type(writefile) == "function" then
        local name = "ps99_console_" .. tostring(os.time()) .. ".txt"
        if pcall(writefile, name, text) then return "no clipboard; saved " .. name end
    end
    return "copy failed: no clipboard or writefile"
end
local function clearConsoleLog()
    CONSOLE.buf, CONSOLE.head, CONSOLE.count = {}, 1, 0
end
end

local FILE = "PS99_UI_config.json"
local SAVE_FLAGS = {
    Collect = true, CollectLootbags = true, Breakables = true, AutoHatch = true, AntiAFK = true,
    FreeGifts = true, Spinner = true, BuyZones = true, FPSBoost = true,
    AutoRejoin = true, Tap = true, BuySlots = true, RareAlerts = true,
    OptBreak = true, OptPets = true, OptPart = true, OptGame = true,
    RareTitanic = true, RareHuge = true, RareExclusive = true,
    NearestEgg = true, BuyEquipSlots = true, AutoRebirth = true,
    AutoQuest = true, HalloweenZone = true, HalloweenHatch = true,
    HalloweenForge = true, HalloweenUpgrade = true, HUD = true,
    Debug = true, RecordConsole = true,
    InfPetSpeed = true, FastFarm = true, NativeAutoTap = true, SmartPets = true, AutoUltimate = true, AutoBestArea = true,
    AutoNextArea = true, AutoBestWorld = true, AutoUseMisc = true, AutoUseFlag = true,
    AutoUseSprinkler = true, AutoUseTNT = true, AutoUseTNTCrate = true,
    AutoBuyUpgrades = true, AutoBuyEggBundle = true,
    DisableEggAnim = true, AutoMakeGold = true, AutoMakeRainbow = true,
    AutoFuse = true, AutoAttachCharm = true,
    AutoClaimRank = true, AutoClaimForever = true, AutoShinyRelics = true,
    AutoPopBalloons = true, AutoLeaveStairway = true, AutoAdminAbuse = true,
    AutoTreehouse = true, AutoCompleteRank = true, AutoCrystalCastle = true,
    AutoEatFruits = true, AutoUseBuffs = true, AutoUsePotions = true, AutoEquipEnchants = true,
    AutoOpenGifts = true, AutoOpenLootboxes = true, AutoCombineKeys = true,
    AutoOpenCrystalChest = true, AutoSpinWheel = true, AutoRainbowFruits = true,
    AutoShinyFruits = true, AutoUpgradePotions = true, AutoUpgradeEnchants = true,
    WalkSpeedEnable = true, JumpPowerEnable = true, InfiniteJump = true, NoClip = true,
    WhiteScreen = true,
}
local NUMBER_BOUNDS = {
    UpgradeInterval={1,60}, UpgradeSessionLimit={1,1000},
    EventUpgradeSessionLimit={1,50}, CharmSessionLimit={1,10},
    PotionRefillSeconds = {0, 6000},
    SlotNumber = {1, 20}, RebirthNum = {1, 999}, CollectDelay = {1, 5},
    EggSlotMax = {1, 100}, EquipSlotMax = {1, 100}, RebirthMax = {1, 999},
    BreakDelay = {0.05, 1}, Radius = {10, 200}, Targets = {1, 10},
    Amount = {1, 99}, HatchDelay = {0.1, 2}, RewardEvery = {10, 300},
    SummaryMins = {0, 120},
    MinArea = {1, 10}, ForgeChance = {0, 100}, ForgeShards = {0, 50},
    TNTDelay = {0.5, 30}, TNTCrateDelay = {1, 60}, FusePetAmount = {2, 10},
    PriorityWait = {1, 60}, MaxRank = {1, 40},
    WalkSpeed = {16, 200}, JumpPower = {50, 300}, RejoinMins = {1, 60},
    TapInterval = {0.01, 0.5}, TapTargets = {1, 10}, TapRadius = {20, 200}, SmartPetCount = {1, 20},
}
local InterfaceSettings={scale=1,compact=false,collapsed=false,tab="FARM"}
local CONFIG_VERSION = 4
local function saveCfg()
    if not writefile then return false end
    local f, st = {}, {}
    for k, v in pairs(Flags) do if SAVE_FLAGS[k] then f[k] = v end end
    -- webhook URL is intentionally excluded from disk persistence.
    for k, v in pairs(State) do if k ~= "WebhookUrl" then st[k] = v end end
    local ok = pcall(function()
        writefile(FILE,HttpService:JSONEncode({Version=CONFIG_VERSION,Flags=f,State=st,Interface=InterfaceSettings}))
    end)
    return ok
end
local function migrateConfig(data)
    if type(data) ~= "table" then return nil, "configuration root is not an object" end
    local version = tonumber(data.Version) or 0
    if version > CONFIG_VERSION then return nil, "configuration was created by a newer version" end
    -- v0/v1 files had no version. Their Flags/State maps are already compatible;
    -- normalize known legacy aliases here so future migrations have one entry point.
    if type(data.Flags) ~= "table" then data.Flags = {} end
    if type(data.State) ~= "table" then data.State = {} end
    if version < 2 and data.State.SpyFilter == nil and data.State.RemoteFilter ~= nil then
        data.State.SpyFilter = data.State.RemoteFilter
    end
    if version < 3 and data.State.CustomEgg == nil then data.State.CustomEgg = "" end
    data.Version = CONFIG_VERSION
    return data
end
local function loadCfg()
    if type(isfile)~="function" or type(readfile)~="function" then return false,"file APIs unavailable" end
    local existsOk,exists=pcall(isfile,FILE)
    if not existsOk or not exists then return false,"no accessible config" end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE)) end)
    if not ok then return false, "config JSON could not be decoded" end
    local data, why = migrateConfig(decoded)
    if not data then return false, why end
    if type(data.Interface)=="table" then
        local ui=data.Interface
        if type(ui.scale)=="number" and ui.scale==ui.scale then InterfaceSettings.scale=math.clamp(ui.scale,.65,1.5) end
        for _,key in ipairs({"compact","collapsed"}) do if type(ui[key])=="boolean" then InterfaceSettings[key]=ui[key] end end
        if type(ui.tab)=="string" and ({FARM=true,HATCH=true,REWARDS=true,MISC=true,INTERFACE=true})[ui.tab] then InterfaceSettings.tab=ui.tab end
    end
    local applied, skipped = 0, 0

    for k, v in pairs(data.Flags) do
        if SAVE_FLAGS[k] and type(v) == "boolean" and Flags[k] ~= nil then Flags[k] = v; applied += 1
        else skipped += 1; print("[AERO CONFIG] Skipped Flags."..tostring(k).." (unknown, unsaved, or wrong type)") end
    end
    for k, v in pairs(data.State) do
        local skippedBefore=skipped
        if k == "WebhookUrl" then skipped += 1
        elseif State[k] == nil then skipped += 1
        elseif type(State[k]) == "number" and type(v) == "number" and v == v then
            local b = NUMBER_BOUNDS[k]
            if b then
                v = math.clamp(v, b[1], b[2])
                if k == "SlotNumber" or k == "RebirthNum" or k == "Targets" or k == "Amount" or k == "RewardEvery" or k == "SummaryMins" then v = math.floor(v + 0.5) end
                State[k] = v; applied += 1
            else skipped += 1 end
        elseif type(State[k]) == "string" and type(v) == "string" then
            local limits = { KeySelection=2000, UpgradePotionSelection=2000, UpgradeEnchantSelection=2000, FlagSelection=200, FruitSelection=2000, PotionSelection=2000, BuffSelection=2000, GiftSelection=4000, LootboxSelection=4000, EventUpgradeSelection=140, CharmSelection=140, CharmPetUID=120, BalloonMode=40, FusePetName=200, CraftPetSearch=200, CraftPetMode=40, CraftPetSort=40, EggSelection = 100, Egg = 100, CustomEgg = 100, Keywords = 500, SpyFilter = 100 }
            local limit = limits[k]
            if limit then State[k] = string.sub(v, 1, limit); applied += 1 else skipped += 1 end
        elseif k == "Picks" and type(v) == "table" then
            State.Picks = State.Picks or {}
            for pk, pv in pairs(v) do
                if type(pv) == "table" then
                    State.Picks[pk] = State.Picks[pk] or {}
                    for ik, iv in pairs(pv) do
                        if type(iv) == "boolean" then State.Picks[pk][ik] = iv end
                    end
                end
            end
            applied += 1
        else skipped += 1 end
        if skipped>skippedBefore then print("[AERO CONFIG] Skipped State."..tostring(k).." (excluded, unknown, unbounded, or wrong type)") end
    end
    return true, string.format("config v%d loaded: %d applied, %d skipped", CONFIG_VERSION, applied, skipped)
end
local cfgLoaded, cfgMessage = loadCfg()
-- P24.4: unsafe and consumption-changing toggles must be explicitly enabled each launch.
Flags.AutoBuyUpgrades=false Flags.AutoAttachCharm=false
Flags.AutoCompleteRank=false Flags.AutoPopBalloons=false
-- Always enabled regardless of a saved toggle value. Polling also covers script replacement.
Flags.DisableEggAnim=true
guardedSpawn("egg-animation-maintenance",function()
    while isRunning() do
        local ok,err=applyEggAnim()
        local status=ok and "active" or ("unavailable: "..tostring(err))
        if status~=eggAnimationStatus then
            eggAnimationStatus=status
            if ok then print("[PS99] Egg animation skip active")
            else warn("[PS99] Egg animation skip "..status) end
        end
        task.wait(2)
    end
end)

local function getOrbs() return Things:FindFirstChild("Orbs") end
do local function getLootbags() return Things:FindFirstChild("Lootbags") end end -- legacy unused reader
local function getBreakables() return Things:FindFirstChild("Breakables") or Things:FindFirstChild("Breakable") end

-- orbs still on the map + distance of the nearest one. used by the stats line and the dump.
-- spy + dump so far: the server ignores an orb while it is ~50 studs away (dump: sent=true, still there).
local function orbLeft()
    local f = getOrbs()
    if not f then return 0, nil end
    local hp = HRP and HRP.Parent and HRP.Position or nil
    local n, near = 0, nil
    for _, o in ipairs(f:GetChildren()) do
        n += 1
        if hp then
            pcall(function()
                local d = (o:GetPivot().Position - hp).Magnitude
                if not near or d < near then near = d end
            end)
        end
    end
    return n, near
end

local visualCache = setmetatable({}, { __mode = "k" })
local function cacheProp(inst, prop)
    if not visualCache[inst] then visualCache[inst] = {} end
    if visualCache[inst][prop] == nil then
        pcall(function() visualCache[inst][prop] = inst[prop] end)
    end
end
local function restoreAll()
    for inst, props in pairs(visualCache) do
        for prop, val in pairs(props) do
            pcall(function() inst[prop] = val end)
        end
    end
end
onCleanup(restoreAll)

local origQuality, origShadows, origDeco, orig3d
local function captureRender()
    if origQuality == nil then pcall(function() origQuality = settings().Rendering.QualityLevel end) end
    if origShadows == nil then pcall(function() origShadows = game:GetService("Lighting").GlobalShadows end) end
    if origDeco == nil then pcall(function() origDeco = Workspace.Terrain.Decoration end) end
    if orig3d == nil then orig3d = true end
end
local function applyRender()
    captureRender()
    local q = (Flags.FPSBoost or Flags.OptGame) and Enum.QualityLevel.Level01
        or (origQuality or Enum.QualityLevel.Level10)
    pcall(function() settings().Rendering.QualityLevel = q end)
    -- FPSBoost lowers quality without blanking the world.
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    pcall(function() game:GetService("Lighting").GlobalShadows = not Flags.OptGame and (origShadows ~= false) end)
    pcall(function() Workspace.Terrain.Decoration = not Flags.OptGame and (origDeco ~= false) end)
end
onCleanup(function()
    if origQuality then pcall(function() settings().Rendering.QualityLevel = origQuality end) end
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    if origShadows ~= nil then pcall(function() game:GetService("Lighting").GlobalShadows = origShadows end) end
    if origDeco ~= nil then pcall(function() Workspace.Terrain.Decoration = origDeco end) end
end)

-- Native unified collector below owns both reward types.
local sentOrbs, sentBags = {}, {} -- retained for read-only legacy diagnostics

local function hitboxOf(b)
    if b:IsA("BasePart") then return b end
    return b:FindFirstChild("Hitbox", true) or b:FindFirstChildWhichIsA("BasePart", true)
end

-- Breakables and Tap are compatibility controls for the single native tap worker.
-- The obsolete Ray/Click worker has been removed.

-- nearest egg: no teleporting (the game logs Send Position). finds egg models near you by matching
-- model names against the BIG egg list ("12 | Spike Egg" prefix is stripped), then hatches that one.
-- the server still needs you standing at the egg. the model layout is NOT verified, use
-- MISC > Dump Eggs if it never picks anything.
local EggNameSet = {}
for _, n in pairs(EggByLabel) do EggNameSet[string.lower(n)] = n end
-- halloween zone eggs (UPD 100). the egg list from the api may not have them, so the scan missed them
for _, n in ipairs({ "Straw Egg", "Marble Egg", "Poltergeist Egg", "Carousel Egg", "Masquerade Egg" }) do
    EggNameSet[string.lower(n)] = n
end
local EGG_SKIP = { Orbs = true, Lootbags = true, Breakables = true, Breakable = true, Pets = true }
local eggCache, eggCacheAt = {}, 0
local eggCacheDirty, eggLastScanDuration = true, 0

local function eggModelName(inst)
    if not inst or not inst:IsA("Model") then return nil end
    local base = inst.Name:gsub("^%d+%s*|%s*", "")
    return EggNameSet[string.lower(base)]
end

-- Initial/full scans happen only when the hierarchy changes or as a slow safety refresh.
local function scanEggs()
    local started, found, seen = tick(), {}, {}
    local function consider(d)
        local real = eggModelName(d)
        if real and not seen[d] then
            seen[d] = true
            found[#found + 1] = { d, real }
        end
    end
    for _, folder in ipairs(Things:GetChildren()) do
        if not EGG_SKIP[folder.Name] then
            consider(folder)
            for _, d in ipairs(folder:GetDescendants()) do consider(d) end
        end
    end
    eggLastScanDuration = tick() - started
    recordPerf("egg_scan", eggLastScanDuration)
    eggCacheDirty, eggCacheAt = false, tick()
    return found
end

local function markEggCacheDirty(inst)
    if not inst then eggCacheDirty = true; return end
    if inst:IsA("Model") and eggModelName(inst) then eggCacheDirty = true end
    if inst:IsA("Folder") or inst:IsA("Model") then eggCacheDirty = true end
end
trackConnection(Things.DescendantAdded:Connect(markEggCacheDirty))
trackConnection(Things.DescendantRemoving:Connect(function(inst)
    if inst:IsA("Model") and eggModelName(inst) then eggCacheDirty = true end
end))
trackConnection(Things.ChildAdded:Connect(markEggCacheDirty))
trackConnection(Things.ChildRemoved:Connect(function() eggCacheDirty = true end))

-- the game's own custom-egg hatch takes an egg uid (spy: CustomEggs_Hatch(uid, amount) -> true).
-- the uid is read from an attribute, a 32-hex name, or a 32-hex StringValue under the egg
local function eggUid(inst)
    for _, attr in ipairs({ "uid", "UID", "Uid", "EggUid" }) do
        local a = inst:GetAttribute(attr)
        if type(a) == "string" and #a == 32 then return a end
    end
    -- custom eggs sit at __THINGS.CustomEggs.<uid>.Egg, so the uid is on a parent (spy + dump)
    local node = inst
    for _ = 1, 3 do
        if not node or node == Workspace then break end
        if #node.Name == 32 and node.Name:match("^%x+$") then return node.Name end
        node = node.Parent
    end
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("StringValue") and #d.Value == 32 and d.Value:match("^%x+$") then return d.Value end
    end
    return nil
end

-- nearest custom egg by its uid folder (__THINGS.CustomEggs.<uid>.Egg), within 100 studs
local function nearestCustomEggUid()
    local ce = Things:FindFirstChild("CustomEggs")
    if not (ce and HRP and HRP.Parent) then return nil end
    local hp = HRP.Position
    local best, bd
    for _, f in ipairs(ce:GetChildren()) do
        if #f.Name == 32 and f.Name:match("^%x+$") then
            local p = f:FindFirstChild("Egg", true)
            if p and p:IsA("BasePart") then
                local d = (p.Position - hp).Magnitude
                if not bd or d < bd then best, bd = f.Name, d end
            end
        end
    end
    if best and bd <= 100 then return best, bd end
    return nil
end

-- returns the egg name, distance and instance of the egg nearest you (within 100 studs)
local function nearestEggName()
    if not (HRP and HRP.Parent) then return nil end
    if eggCacheDirty or tick() - eggCacheAt > 120 then
        eggCache = scanEggs()
    end
    local hp = HRP.Position
    local best, bd, bestInst
    for _, e in ipairs(eggCache) do
        if e[1].Parent then
            local ok, pv = pcall(function() return e[1]:GetPivot().Position end)
            if ok then
                local d = (pv - hp).Magnitude
                if not bd or d < bd then best, bd, bestInst = e[2], d, e[1] end
            end
        end
    end
    if best and bd <= 100 then return best, bd, bestInst end
    return nil
end

local function skipAnimationIfAny()
    local t0 = tick()
    while isRunning() and Flags.AutoHatch and tick() - t0 < 3 do
        local cam = Workspace.CurrentCamera
        if not cam or not cam:FindFirstChild("Eggs") then break end
        pcall(function()
            VirtualUser:Button1Down(Vector2.new(math.huge, math.huge))
            VirtualUser:Button1Up(Vector2.new(math.huge, math.huge))
        end)
        task.wait()
    end
end

-- Directory fields verified by the user's PS99 diagnostics; purchase arguments still need live testing.
local EggSelector={rows={},zones={},worlds={},world=nil,message="Loading local egg directory",revision=0,sample={},zoneCmds=nil,ownedAt=-math.huge,ownedName=nil,ownedError=nil,eggCmds=nil,eggsUtil=nil,positions={},positionWorld=nil,positionAt=0}
function EggSelector.currentWorld()
    for _,world in pairs(EggSelector.worlds) do
        if type(world)=="table" and tonumber(world.PlaceId)==game.PlaceId then return tonumber(world.WorldNumber) end
    end
end
function EggSelector.available()
    local world=EggSelector.currentWorld()
    EggSelector.world=world
    local result={}
    if not world then EggSelector.message="Current place is not mapped by the Worlds directory" return result end
    for _,row in ipairs(EggSelector.rows) do if row.world==world then result[#result+1]=row end end
    EggSelector.message=string.format("World %d • %d normal eggs",world,#result)
    return result
end
function EggSelector.unlockedZone(force)
    if force or os.clock()-EggSelector.ownedAt>=2 then
        EggSelector.ownedAt=os.clock()
        EggSelector.ownedName=nil EggSelector.ownedError=nil
        local cmds=EggSelector.zoneCmds
        if type(cmds)~="table" or type(cmds.GetMaxOwnedZone)~="function" then
            EggSelector.ownedError="ZoneCmds.GetMaxOwnedZone unavailable"
        else
            local ok,name=pcall(cmds.GetMaxOwnedZone)
            if ok and type(name)=="string" then EggSelector.ownedName=name
            else EggSelector.ownedError="Owned-zone query failed: "..tostring(name):sub(1,100) end
        end
    end
    local zone=EggSelector.ownedName and EggSelector.zones[EggSelector.ownedName]
    if type(zone)~="table" then return nil,EggSelector.ownedError or "Owned zone is missing from the directory" end
    if tonumber(zone.WorldNumber)~=EggSelector.currentWorld() then return nil,"Highest owned zone belongs to another world; select an egg explicitly" end
    return zone
end
function EggSelector.maxHatch()
    local cmds=EggSelector.eggCmds
    if type(cmds)~="table" or type(cmds.GetMaxHatch)~="function" then return nil,"EggCmds.GetMaxHatch unavailable" end
    local ok,count=pcall(cmds.GetMaxHatch)
    if not ok or type(count)~="number" or count~=count or count==math.huge or count<1 then
        return nil,"Hatch capacity unavailable: "..tostring(count):sub(1,80)
    end
    return math.floor(count)
end
function EggSelector.nearest(options)
    local root=HRP
    if not root or not root.Parent then return nil,"Waiting for character position" end
    if EggSelector.positionWorld~=EggSelector.currentWorld() or os.clock()-EggSelector.positionAt>10 then
        return nil,"Waiting for current-world egg positions"
    end
    local best,distance
    for _,row in ipairs(options) do
        local position=EggSelector.positions[row.id]
        if position then
            local d=(root.Position-position).Magnitude
            if not distance or d<distance then best=row distance=d end
        end
    end
    if not best then return nil,"No current-world egg positions returned by EggsUtil" end
    return best.id,nil,best,distance
end
function EggSelector.resolve()
    local options=EggSelector.available()
    if #options==0 then return nil,EggSelector.message end
    local selection=State.EggSelection or "Best Zone Egg"
    if selection=="Nearest Egg" then return EggSelector.nearest(options) end
    if selection=="Best Zone Egg" then
        local zone,err=EggSelector.unlockedZone()
        if not zone then return nil,err end
        local cap=tonumber(zone.MaximumAvailableEgg)
        if not cap then return nil,"Owned zone has no MaximumAvailableEgg" end
        -- Exact cap match, rather than guessing from zoneNumber or choosing an unrelated egg.
        for _,row in ipairs(options) do
            if row.number==cap then return row.id,nil,row end
        end
        return nil,"Egg #"..cap.." is absent from this world's normal egg directory"
    elseif selection=="Best Egg" then
        local best=options[#options]
        return best.id,nil,best
    end
    for _,row in ipairs(options) do
        if row.id==selection or row.name==selection then return row.id,nil,row end
    end
    return nil,"Selected egg does not belong to the current world; choose from Select Egg"
end
function EggSelector.load()
    REQUEST_STATUS.observe("catalog","loads","Directory load started")
    local library=RS:FindFirstChild("Library")
    local directory=library and library:FindFirstChild("Directory")
    local function readModule(parent,name)
        local module=parent and parent:FindFirstChild(name)
        if not module or not module:IsA("ModuleScript") then error("Missing local module: "..name) end
        local result=require(module)
        if type(result)~="table" then error(name.." did not return a table") end
        return result
    end
    local ok,err=pcall(function()
        local eggs=readModule(directory,"Eggs")
        local zones=readModule(directory,"Zones")
        local worlds=readModule(directory,"Worlds")
        local client=library and library:FindFirstChild("Client")
        local cmds=readModule(client,"ZoneCmds")
        local eggOk,eggCmds=pcall(readModule,client,"EggCmds")
        local util=library and library:FindFirstChild("Util")
        local utilOk,eggsUtil=pcall(readModule,util,"EggsUtil")
        local rows,seen={},{}
        for key,data in pairs(eggs) do
            if type(data)=="table" then
                local number,world,zone=tonumber(data.eggNumber),tonumber(data.worldNumber),tonumber(data.zoneNumber)
                local id=type(data._id)=="string" and data._id or (type(key)=="string" and key)
                if id and number and world and zone and not seen[id] then
                    rows[#rows+1]={id=id,name=type(data.name)=="string" and data.name or id,number=number,world=world,zone=zone}
                    seen[id]=true
                end
            end
        end
        table.sort(rows,function(a,b) if a.number==b.number then return a.id<b.id end return a.number<b.number end)
        if not isRunning() then return end
        EggSelector.rows=rows EggSelector.zones=zones EggSelector.worlds=worlds EggSelector.zoneCmds=cmds
        EggSelector.eggCmds=eggOk and eggCmds or nil
        EggSelector.eggsUtil=utilOk and eggsUtil or nil
        EggSelector.positions={} EggSelector.positionWorld=nil EggSelector.positionAt=0
        EggSelector.ownedAt=-math.huge EggSelector.revision+=1
        EggSelector.available()
        REQUEST_STATUS.observe("catalog","observed","Loaded "..#rows.." normal egg definitions")
        REQUEST_STATUS.evidence.catalog.count=#rows
        EggSelector.sample={"Source: ReplicatedStorage.Library.Directory.{Eggs,Zones,Worlds}","Normal eggs loaded: "..#rows}
    end)
    if not ok then REQUEST_STATUS.observe("catalog","errors",err) end
    if not ok then EggSelector.message="Egg directory load failed: "..tostring(err):sub(1,180) warn("[PS99] "..EggSelector.message) end
end
guardedSpawn("egg-catalog",EggSelector.load)
-- Position queries run separately so a slow utility cannot block GUI or purchase resolution.
guardedSpawn("egg-position-index",function()
    while isRunning() do
        local util=EggSelector.eggsUtil
        if type(util)=="table" and type(util.GetEggPosition)=="function" then
            local options=EggSelector.available()
            local world=EggSelector.currentWorld()
            local revision=EggSelector.revision
            local positions={}
            for index,row in ipairs(options) do
                if not isRunning() then return end
                local ok,position=pcall(util.GetEggPosition,row.number)
                if ok and typeof(position)=="Vector3" and position.X==position.X and position.Y==position.Y and position.Z==position.Z and math.abs(position.X)<math.huge and math.abs(position.Y)<math.huge and math.abs(position.Z)<math.huge then positions[row.id]=position end
                if index%12==0 then task.wait() end
            end
            if isRunning() and revision==EggSelector.revision and world==EggSelector.currentWorld() then
                EggSelector.positions=positions EggSelector.positionWorld=world EggSelector.positionAt=os.clock()
            end
        end
        task.wait(2)
    end
end)



local HatchStatus={text="Idle",attempts=0,accepted=0}
-- Adaptive retry backoff: successful hatch cadence stays unchanged, but
-- rejected or unavailable purchases do not hammer the remote every frame.
local hatchFailures=0
local function hatchRetryDelay()
    hatchFailures=math.min(hatchFailures+1,6)
    return math.min(12,0.75*(2^(hatchFailures-1)))
end

guardedSpawn("worker-6", function()
    while isRunning() do
        if Flags.AutoHatch then
            local egg,selectionError,eggRow=EggSelector.resolve()
            if not egg then
                HatchStatus.text=selectionError or EggSelector.message
                REQUEST_STATUS.observe("hatch","blocked",HatchStatus.text)
                task.wait(math.max(2,hatchRetryDelay()))
                continue
            end
            -- Capture request settings before yielding; counters describe the request sent.
            local amount,capacityError=EggSelector.maxHatch()
            if not amount then
                HatchStatus.text=capacityError
                REQUEST_STATUS.observe("hatch","blocked",HatchStatus.text)
                task.wait(math.max(2,hatchRetryDelay()))
                continue
            end
            if not isRunning() or not Flags.AutoHatch then continue end
            HatchStatus.attempts+=1
            REQUEST_STATUS.observe("hatch","requests","Selected egg "..tostring(egg).."; amount="..amount)
            HatchStatus.text="Requesting "..tostring(eggRow.name).." (#"..eggRow.number..") ×"..amount
            local ok, res = invoke("Eggs_RequestPurchase", egg, amount)
            REQUEST_STATUS.observe("hatch",ok and (res==true and "accepted" or "rejected") or "errors","Remote response="..tostring(res):sub(1,100).."; pet acquisition not independently measured")
            if ok and res == true then
                hatchFailures=0
                Stats.Hatches += amount
                HatchStatus.accepted+=1
                REQUEST_STATUS.lastHatchAccepted=os.clock()
                HatchStatus.text="Accepted request: "..tostring(egg).." ×"..amount.." (inventory not independently counted)"
                debugLog("hatch", "success " .. egg .. " x" .. amount)
            else
                HatchStatus.text="Not confirmed: "..tostring(egg).." | "..tostring(res):sub(1,100)
                debugLog("hatch", "failed " .. egg .. " res=" .. tostring(res))
            end
            skipAnimationIfAny()
            if ok and res == true then
                task.wait(math.max(0.1,tonumber(State.HatchDelay) or 0.3))
            else
                task.wait(math.max(tonumber(State.HatchDelay) or 0.3,hatchRetryDelay()))
            end
        else
            hatchFailures=0
            task.wait(0.25)
        end
    end
end)

-- Phase 22: bounded rewards and zone-request scheduling.
-- A false response means "not confirmed", not necessarily a transport error.
-- No speculative game-specific eligibility API is assumed.
do
    local gifts = { attempts=0, confirmed=0, rejected=0, errors=0, skipped=0, nextAt={}, failures={}, cursor=1, nextRequest=0, last={}, records={}, restored=0, eligibility="unknown; no verified eligibility source" }
    local zones = { attempts=0, confirmed=0, rejected=0, errors=0, skipped=0, nextAt={}, failures={}, cursor=1 }
    local function backoff(failures, base, cap)
        return math.min(cap, base * (2 ^ math.min(6, math.max(0, failures-1))))
    end
    -- Recover only validated local diagnostic state. Clock deadlines from another
    -- execution are never reused; convert bounded Unix deadlines to this clock.
    local function restoreFreeGifts()
        if type(readfile)~="function" then return end
        local best=nil
        for _,slot in ipairs({"A","B"}) do
            local ok,data=pcall(function()
                return HttpService:JSONDecode(readfile("AERO_PS99_P224_Diagnostics_"..slot..".json"))
            end)
            if ok and type(data)=="table" and data.schema==2
                and data.userId==LocalPlayer.UserId and data.placeId==game.PlaceId
                and type(data.savedAt)=="number" and data.savedAt==data.savedAt
                and data.savedAt<=os.time()+60 and os.time()-data.savedAt<=86400
                and type(data.sequence)=="number" and data.sequence==data.sequence
                and data.sequence>=0 and data.sequence<math.huge
                and type(data.rewards)=="table" and type(data.rewards.freeGifts)=="table"
                and type(data.rewards.freeGifts.records)=="table" then
                if not best or data.savedAt>best.savedAt or
                    (data.savedAt==best.savedAt and data.sequence>best.sequence) then best=data end
            end
        end
        if not best then return end
        local sameServer=type(game.JobId)=="string" and game.JobId~="" and best.jobId==game.JobId
        for i=1,12 do
            local record=best.rewards.freeGifts.records[tostring(i)]
            if type(record)=="table" then
                local failures=tonumber(record.failures)
                local deadline=tonumber(record.retryAtUnix)
                if failures and failures==failures and failures>=0 and failures<=7
                    and deadline and deadline==deadline and math.abs(deadline)<math.huge then
                    local reason=type(record.last)=="string" and record.last:sub(1,120) or "restored observation"
                    gifts.records[tostring(i)]={failures=math.floor(failures),retryAtUnix=deadline,last=reason,
                        eligibility="unknown",previousServer=not sameServer}
                    gifts.restored+=1
                    if sameServer then
                        gifts.failures[i]=math.floor(failures)
                        gifts.nextAt[i]=os.clock()+math.clamp(deadline-os.time(),0,1800)
                        gifts.last[i]=reason
                    end
                end
            end
        end
        print("[AERO P22.5] Restored reward records: "..gifts.restored.." | same-server cooldowns="..tostring(sameServer))
    end
    restoreFreeGifts()
    local function phase22Report(quiet)
        if quiet then return {freeGifts=gifts,zones=zones} end
        print(string.format("[AERO P22] GIFTS attempts=%d confirmed=%d rejected=%d errors=%d skipped=%d",
            gifts.attempts,gifts.confirmed,gifts.rejected,gifts.errors,gifts.skipped))
        print(string.format("[AERO P22] ZONES attempts=%d confirmed=%d rejected=%d errors=%d skipped=%d cursor=%d total=%d",
            zones.attempts,zones.confirmed,zones.rejected,zones.errors,zones.skipped,zones.cursor,#ZoneNames))
        print("[AERO P22] NOTE | confirmed means remote returned true; ownership/inventory is not independently verified")
        for i=1,12 do
            print(string.format("[AERO P22.5] REWARD %d | retry-in=%.1fs | failures=%d | last=%s",i,
                math.max(0,(gifts.nextAt[i] or 0)-os.clock()),gifts.failures[i] or 0,gifts.last[i] or "unobserved"))
        end
        print("[AERO P22.5] Eligibility unknown; false responses do not establish the rejection reason.")
        return {freeGifts=gifts,zones=zones}
    end
    _G.AERO_PS99_P22_Report=phase22Report
    onCleanup(function()
        if _G.AERO_PS99_P22_Report==phase22Report then _G.AERO_PS99_P22_Report=nil end
    end)

    -- One eligible slot per tick; preserve cooldowns across UI toggle changes.
    -- No eligibility API is established: false has no inferred cooldown reason.
    local function freeGiftTick()
        if not isRunning() or not Flags.FreeGifts then return end
        local now=os.clock()
        if now<gifts.nextRequest then return end
        for offset=0,11 do
            local i=(gifts.cursor+offset-1)%12+1
            if now>=(gifts.nextAt[i] or 0) then
                gifts.cursor=i%12+1
                gifts.nextRequest=now+2
                gifts.attempts+=1
                local ok,res=invoke("Redeem Free Gift",i)
                if not isRunning() then return end
                local finished=os.clock()
                if ok and res==true then
                    gifts.confirmed+=1
                    gifts.failures[i]=0
                    gifts.last[i]="remote returned true; inventory not verified"
                    gifts.nextAt[i]=finished+math.max(300,tonumber(State.RewardEvery) or 30)
                    debugLog("gifts","accepted slot "..i)
                else
                    if ok then gifts.rejected+=1 else gifts.errors+=1 end
                    gifts.failures[i]=math.min(7,(gifts.failures[i] or 0)+1)
                    gifts.last[i]=ok and "remote returned non-true; eligibility unknown" or "invocation error"
                    gifts.nextAt[i]=finished+backoff(gifts.failures[i],ok and 120 or 30,1800)
                end
                gifts.records[tostring(i)]={failures=gifts.failures[i] or 0,
                    retryAtUnix=os.time()+math.max(0,gifts.nextAt[i]-finished),
                    last=gifts.last[i],observedAt=os.time(),eligibility="unknown"}
                -- Rate limit from completion too, even if the invocation yielded.
                gifts.nextRequest=finished+2
                return
            end
            gifts.skipped+=1
        end
    end
    guardedSpawn("worker-7", function()
        while isRunning() do
            local ok,err=pcall(freeGiftTick)
            if not ok then
                gifts.errors+=1
                gifts.nextRequest=os.clock()+15
                warn("[AERO P22.5] Free gift worker recovered: "..tostring(err):sub(1,200))
            end
            task.wait(0.5)
        end
    end)

    guardedSpawn("worker-8", function()
        while isRunning() do
            if Flags.Spinner then fire("Spinny Wheel: Request Ticket", "StarterWheel") end
            task.wait(State.RewardEvery)
        end
    end)

    guardedSpawn("worker-9", function()
        while isRunning() do
            if Flags.BuyZones and #ZoneNames>0 then
                -- Bounded batches avoid repeatedly requesting the entire directory.
                local checked=0
                local sent=0
                while checked<#ZoneNames and sent<3 and isRunning() and Flags.BuyZones do
                    local index=zones.cursor
                    zones.cursor=(zones.cursor % #ZoneNames)+1
                    checked+=1
                    local name=ZoneNames[index]
                    if os.clock()<(zones.nextAt[name] or 0) then
                        zones.skipped+=1
                    else
                        sent+=1
                        zones.attempts+=1
                        local ok,res=invoke("Zones_RequestPurchase",name)
                        if ok and res==true then
                            zones.confirmed+=1
                            zones.failures[name]=0
                            zones.nextAt[name]=os.clock()+300
                        else
                            if ok then zones.rejected+=1 else zones.errors+=1 end
                            zones.failures[name]=math.min(7,(zones.failures[name] or 0)+1)
                            zones.nextAt[name]=os.clock()+backoff(zones.failures[name],ok and 15 or 5,180)
                        end
                        task.wait(0.12)
                    end
                end
            end
            task.wait(4)
        end
    end)
    print("[AERO P22] READY | rewards and zone request scheduling | no teleport")
end

-- UPD 100 halloween (31 oct 2026). haunted farm zones, halloween eggs, forge and treat upgrades.
-- every remote name below is a GUESS, not spy-captured. run the spy (SPY on) during one real action
-- of each kind, copy the log, and fix the matching name. until then the loop is a harmless no-op.
local HALLOWEEN = {
    ZoneRemote    = "HalloweenGames_ZonePurchase",   -- UNVERIFIED
    HatchRemote   = "Eggs_RequestPurchase",          -- same remote Auto Hatch uses (spy-confirmed)
    ForgeRemote   = "Forge_RequestBrew",             -- UNVERIFIED
    UpgradeRemote = "HalloweenGames_UpgradeRequest", -- UNVERIFIED
    ZoneCount     = 5,                               -- haunted farm has 5 zones
    HatchEgg      = "Straw Egg",                     -- zone 1 egg, change for later zones
    UidRemote     = "CustomEggs_Hatch",              -- spy-confirmed: game's call is (uid, amount)
    Upgrades = {
        "HalloweenGamesCoinFinder", "HalloweenGamesEggLuck", "HalloweenGamesGolden",
        "HalloweenGamesHugeLuck", "HalloweenGamesRainbow", "HalloweenGamesShiny",
    },
}

guardedSpawn("worker-10", function()
    while isRunning() do
        if Flags.HalloweenZone then
            if not Network:FindFirstChild(HALLOWEEN.ZoneRemote) then
                debugLog("event", "ZoneRemote missing (unverified)")
            else
                for z = 1, HALLOWEEN.ZoneCount do
                    if not (isRunning() and Flags.HalloweenZone) then break end
                    invoke(HALLOWEEN.ZoneRemote, z)
                    task.wait(0.12)
                end
            end
        end
        if Flags.HalloweenUpgrade then
            if not Network:FindFirstChild(HALLOWEEN.UpgradeRemote) then
                debugLog("event", "UpgradeRemote missing (unverified)")
            else
                for _, id in ipairs(HALLOWEEN.Upgrades) do
                    if not (isRunning() and Flags.HalloweenUpgrade) then break end
                    invoke(HALLOWEEN.UpgradeRemote, id)
                    task.wait(0.12)
                end
            end
        end
        if Flags.HalloweenForge then
            if not Network:FindFirstChild(HALLOWEEN.ForgeRemote) then
                debugLog("event", "ForgeRemote missing (unverified)")
            else
                invoke(HALLOWEEN.ForgeRemote)
            end
        end
        task.wait(3)
    end
end)

-- halloween hatch runs on its own loop so it keeps HatchDelay's pace instead of the 3s farm pass
guardedSpawn("worker-11", function()
    while isRunning() do
        if Flags.HalloweenHatch then
            -- pcall: an error here used to kill the loop silently (task.spawn errors skip our print wrapper)
            local okL, errL = pcall(function()
                local egg = nearestEggName() or HALLOWEEN.HatchEgg
                local uid = nearestCustomEggUid()
                local ok, res
                if uid then
                    ok, res = invoke(HALLOWEEN.UidRemote, uid, State.Amount)
                else
                    ok, res = invoke(HALLOWEEN.HatchRemote, egg, State.Amount)
                end
                debugLog("halloween", (uid and ("uid " .. uid) or ("name " .. egg)) .. " ok=" .. tostring(ok) .. " res=" .. (type(res) == "table" and "table" or tostring(res)))
                if ok and res == true then Stats.Hatches += State.Amount end
                skipAnimationIfAny()
            end)
            if not okL then debugLog("halloween", "error: " .. tostring(errL)) end
            task.wait(State.HatchDelay)
        else
            task.wait(0.25)
        end
    end
end)

-- slot machines: sweep slot 1..max every pass, the server rejects owned / unaffordable ones (same
-- idea as the zone sweep). remote names are from the reference pack / memory, NOT spy-verified:
-- if a name is missing from Network the sweep silently does nothing. capture it with the spy.
local function sweepSlots(remote, upTo, flagKey)
    for i = 1, upTo do
        if not (isRunning() and Flags[flagKey]) then return end
        invoke(remote, i)
        task.wait(0.12)
    end
end

guardedSpawn("worker-12", function()
    while isRunning() do
        if Flags.BuySlots then sweepSlots("EggHatchSlotsMachine_RequestPurchase", State.EggSlotMax, "BuySlots") end
        if Flags.BuyEquipSlots then sweepSlots("EquipSlotsMachine_RequestPurchase", State.EquipSlotMax, "BuyEquipSlots") end
        task.wait(5)
    end
end)

-- Auto Ultimate: client API and argument semantics verified from UltimateCmds.
-- Uses only the equipped item; never equips or swaps ultimates.
local AutoUltimate=(function()
    local U={commands=nil,failures=0,nextAttempt=0,pending=nil,status="Off"}
    local function running() return isRunning() and Flags.AutoUltimate end
    local function status(text)
        if U.status~=text then U.status=text debugLog("ultimate",text) end
    end
    function U.failed(message)
        U.failures=math.min(U.failures+1,5)
        local delay=math.min(5*2^(U.failures-1),60)
        U.nextAttempt=os.clock()+delay
        status("Waiting "..delay.."s: "..tostring(message))
    end
    function U.tick()
        if not running() then
            U.pending=nil U.failures=0 U.nextAttempt=0 status("Off") return
        end
        if os.clock()<U.nextAttempt then return end
        if not U.commands then
            local library=RS:FindFirstChild("Library")
            local client=library and library:FindFirstChild("Client")
            local object=client and client:FindFirstChild("UltimateCmds")
            if not object then U.failed("UltimateCmds unavailable") return end
            local commands=require(object)
            for _,key in ipairs({"UltimatesUnlocked","GetEquippedItem","IsActive","IsCharged","Activate"}) do
                assert(type(commands)=="table" and type(commands[key])=="function","Missing UltimateCmds."..key)
            end
            U.commands=commands
        end
        local cmds=U.commands
        if not running() then return end
        if not cmds.UltimatesUnlocked() then status("Ultimates locked - requires 4 rebirths") return end
        local item=cmds.GetEquippedItem()
        if not item then U.pending=nil status("No ultimate equipped") return end
        local id=item:GetId()
        if type(id)~="string" or id=="" then U.failed("Equipped ultimate ID unavailable") return end
        if U.pending and U.pending~=id then U.pending=nil end
        local charged=cmds.IsCharged(id)
        if not charged then U.pending=nil U.failures=0 status(id..": charging") return end
        -- No-argument IsActive checks for any currently active ultimate.
        if cmds.IsActive() then status(id..": ultimate already active") return end
        if U.pending==id then status(id..": waiting for charge reset after activation") return end
        -- A module call can yield: verify the toggle and equipped item again.
        if not running() then return end
        local current=cmds.GetEquippedItem()
        if not running() or not current or current:GetId()~=id then return end
        U.nextAttempt=os.clock()+2
        local accepted=cmds.Activate(id)
        if not running() then return end
        if accepted==true then
            U.pending=id U.failures=0
            status(id..": activated")
            print("[AERO ULTIMATE] Activated "..id)
        else
            U.failed(id..": activation rejected")
        end
    end
    onCleanup(function() U.pending=nil U.commands=nil end)
    return U
end)()
guardedSpawn("auto-ultimate",function()
    while isRunning() do
        local ok,err=pcall(AutoUltimate.tick)
        if not ok and isRunning() then AutoUltimate.failed(err) end
        task.wait(1)
    end
end)

-- rebirth: the arg is the rebirth number you are going TO (current + 1). current is read from
-- Get Stats (top-level key containing "rebirth", NOT the nested Gym one); if no such key exists the
-- manual Rebirth # is used and bumps itself after each success. tries a string arg first, then a
-- number if the string was refused. Rebirth_Request itself was never spy-captured.
local lastRebirthMsg = ""
REQUEST_STATUS.rebirthPending=nil

-- the client keeps its data in memory. getgc walks ~390k tables, so the data root is found once and
-- cached. a failed scan waits 30s before it tries again.
local MEM = { root = nil, nextScan = 0 }
local function memRoot()
    if MEM.root and rawget(MEM.root, "Economy") ~= nil then return MEM.root end
    MEM.root = nil
    if not getgc or tick() < MEM.nextScan then return nil end
    MEM.nextScan = tick() + 30
    for _, o in ipairs(getgc(true)) do
        if type(o) == "table" and type(rawget(o, "Economy")) == "table" and type(rawget(o, "Pets")) == "table" then
            MEM.root = o
            MEM.nextScan = 0
            return o
        end
    end
    return nil
end

-- inventory: a table keyed by 32-hex stack uids (100+ of them). each entry has _data.id (item name)
-- and _data._am (amount). found by getgc once, re-checked every 60s.
local function isUid(k)
    return type(k) == "string" and #k == 32 and string.match(k, "^%x+$") ~= nil
end

local INV = { tbl = nil, at = 0, totals = nil, totalsAt = 0 }
local function findInventory()
    if INV.tbl and tick() - INV.at < 60 then return INV.tbl end
    if not getgc then return INV.tbl end
    INV.at = tick()
    for _, o in ipairs(getgc(true)) do
        if type(o) == "table" then
            local n = 0
            for k in pairs(o) do
                if isUid(k) then n += 1 end
                if n >= 100 then break end
            end
            if n >= 100 then INV.tbl = o; return o end
        end
    end
    return INV.tbl
end

-- Inventory totals are a short-lived snapshot: repeated UI/dump reads reuse it rather
-- than traversing every stack each time. The 2-second TTL bounds staleness without hooks.
local function inventoryTotals(forceRefresh)
    if not forceRefresh and INV.totals and tick() - INV.totalsAt < 2 then
        PERFORMANCE.inventoryCacheHits += 1
        return INV.totals
    end
    local started = tick()
    local inv = findInventory()
    if not inv then return nil end
    local totals, itemCount = {}, 0
    for uid, e in pairs(inv) do
        if isUid(uid) and type(e) == "table" then
            local d = rawget(e, "_data")
            if type(d) == "table" and type(d.id) == "string" then
                totals[d.id] = (totals[d.id] or 0) + (tonumber(d._am) or 0)
                itemCount += 1
            end
        end
    end
    local duration = tick() - started
    PERFORMANCE.inventoryScans += 1
    PERFORMANCE.inventoryLastDuration = duration
    PERFORMANCE.inventoryLastItems = itemCount
    INV.totals, INV.totalsAt = totals, tick()
    recordPerf("inventory", duration)
    return totals
end
local function inventoryIds()
    local totals = inventoryTotals()
    if not totals then return {} end
    local ids = {}
    for id in pairs(totals) do ids[#ids + 1] = id end
    table.sort(ids)
    return ids
end

-- the stats table holds Rebirths, Rank, Zones and the quest counters (Pets Opened, Orbs Claimed...).
-- found by getgc the same way as the data root, cached, rescanned after 30s if missing.
local STATS = { tbl = nil, nextScan = 0 }
local function memStats()
    if STATS.tbl and rawget(STATS.tbl, "Rebirths") ~= nil then return STATS.tbl end
    STATS.tbl = nil
    if not getgc or tick() < STATS.nextScan then return nil end
    STATS.nextScan = tick() + 30
    for _, o in ipairs(getgc(true)) do
        if type(o) == "table" and rawget(o, "Rebirths") ~= nil and rawget(o, "Rank") ~= nil then
            STATS.tbl = o
            STATS.nextScan = 0
            return o
        end
    end
    return nil
end

-- active rank goals: two small tables (up to 4 slots each, same entries) hold the goals with Stars + UID.
-- found by getgc, cached, rescanned after 30s if missing. each entry: Type, Amount, Progress, Stars, UID.
local GOALS = { tbl = nil, nextScan = 0 }
local function isActiveGoalHolder(o)
    local n = 0
    for _, e in pairs(o) do
        n += 1
        if n > 8 or type(e) ~= "table" or rawget(e, "Stars") == nil or rawget(e, "UID") == nil then
            return false
        end
    end
    return n > 0
end

local function memActiveGoals()
    if GOALS.tbl and isActiveGoalHolder(GOALS.tbl) then return GOALS.tbl end
    GOALS.tbl = nil
    if not getgc or tick() < GOALS.nextScan then return nil end
    GOALS.nextScan = tick() + 30
    for _, o in ipairs(getgc(true)) do
        if type(o) == "table" then
            local e1 = rawget(o, 1)
            if type(e1) == "table" and rawget(e1, "Stars") ~= nil and isActiveGoalHolder(o) then
                GOALS.tbl = o
                GOALS.nextScan = 0
                return o
            end
        end
    end
    return nil
end

local function activeGoals()
    local h = memActiveGoals()
    local out = {}
    if not h then return out end
    for _, e in pairs(h) do
        out[#out + 1] = {
            Type = rawget(e, "Type"), Amount = rawget(e, "Amount"), Progress = rawget(e, "Progress"),
            Stars = rawget(e, "Stars"), UID = rawget(e, "UID"),
        }
    end
    return out
end

-- rebirth count: a leaderstats stat with "rebirth" in its name, else the stats table, else a root scalar. not found
-- in memory yet, so this returns nil and the manual Rebirth # is used.
local function getRebirthCount()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if string.find(string.lower(v.Name), "rebirth", 1, true) and type(v.Value) == "number" then
                return v.Value, "leaderstats." .. v.Name
            end
        end
    end
    local st = memStats()
    if st and type(rawget(st, "Rebirths")) == "number" then
        return rawget(st, "Rebirths"), "stats.Rebirths"
    end
    local root = memRoot()
    if root then
        for k, v in pairs(root) do
            if type(k) == "string" and type(v) == "number" and string.find(string.lower(k), "rebirth", 1, true) then
                return v, "root." .. k
            end
        end
    end
    return nil, nil
end

local function rebirth()
    local cur, key = getRebirthCount()
    local target = cur and (cur + 1) or State.RebirthNum
    REQUEST_STATUS.observe("rebirth","requests","String target="..target)
    local ok, res = invoke("Rebirth_Request", tostring(target))
    REQUEST_STATUS.observe("rebirth",ok and (res==true and "accepted" or "rejected") or "errors")
    local msg = string.format("rebirth %d (%s): str=%s", target, key and ("stats." .. key) or "manual #", tostring(res))
    if ok and res==false then
        REQUEST_STATUS.observe("rebirth","requests","Numeric target="..target)
        local ok2, res2 = invoke("Rebirth_Request", target)
        REQUEST_STATUS.observe("rebirth",ok2 and (res2==true and "accepted" or "rejected") or "errors")
        msg = msg .. " num=" .. tostring(res2)
        ok, res = ok2, res2
    end
    if ok and res == true and not cur then
        State.RebirthNum = math.clamp(target + 1, 1, 999)
        saveCfg()
    end
    if (ok and res==true) or not ok or res==nil then
        REQUEST_STATUS.rebirthPending={before=cur,target=target,deadline=os.clock()+20}
        REQUEST_STATUS.observe("rebirth","pending",ok and res==true and "Accepted response; waiting for independently readable rebirth count" or "Invocation outcome uncertain; checking count before another request")
    end
    lastRebirthMsg = msg
    return ok and res == true
end

guardedSpawn("worker-13", function()
    while isRunning() do
        local pending=REQUEST_STATUS.rebirthPending
        if pending then
            local ok,count=pcall(getRebirthCount)
            if ok and type(count)=="number" and type(pending.before)=="number" and count>pending.before and count>=pending.target then
                REQUEST_STATUS.observe("rebirth","observed","Rebirth count increased from "..pending.before.." to "..count.."; concurrent actions can affect attribution")
                REQUEST_STATUS.rebirthPending=nil
            elseif os.clock()>=pending.deadline then
                REQUEST_STATUS.observe("rebirth","unconfirmed","Accepted response; rebirth-count increase not confirmed")
                REQUEST_STATUS.rebirthPending=nil
            end
        end
        if Flags.AutoRebirth and not REQUEST_STATUS.rebirthPending then
            local cur = getRebirthCount()
            local effective = cur or (State.RebirthNum - 1)
            if effective < State.RebirthMax then
                rebirth()
            else
                debugLog("rebirth", "stopped at " .. effective .. " (max " .. State.RebirthMax .. ")")
            end
        end
        task.wait(6)
    end
end)

-- auto quest: reads the active rank goals and switches on what each open goal needs.
-- it only switches back off what it switched on itself, once those goals are done.
-- comets (type 38) have no automation yet; claiming rank rewards has no verified remote yet.
local QUEST = { on = {}, paint = {}, status = "quest: off", label = nil }
local QUEST_NEED = {
    [20] = { flag = "AutoHatch", name = "hatch" },
    [21] = { flag = "Breakables", name = "breaks in area" },
    [9] = { flag = "Breakables", name = "diamond breakables" },
    [38] = { flag = nil, name = "comets (manual)" },
}

local function setQuestFlag(flag, on)
    if Flags[flag] == on then return end
    Flags[flag] = on
    if QUEST.paint[flag] then QUEST.paint[flag]() end
end

local function questTick()
    if not Flags.AutoQuest then
        for flag in pairs(QUEST.on) do setQuestFlag(flag, false) end
        QUEST.on = {}
        QUEST.status = "quest: off"
        return
    end
    local goals = activeGoals()
    local want, parts = {}, {}
    for _, g in ipairs(goals) do
        local done = (g.Progress or 0) >= (g.Amount or 0)
        local need = QUEST_NEED[g.Type]
        local label = need and need.name or ("type " .. tostring(g.Type))
        parts[#parts + 1] = string.format("%s %s/%s%s", label, tostring(g.Progress), tostring(g.Amount), done and " done" or "")
        if not done and need and need.flag then want[need.flag] = true end
    end
    for flag in pairs(want) do
        if not Flags[flag] then
            setQuestFlag(flag, true)
            QUEST.on[flag] = true
        end
    end
    for flag in pairs(QUEST.on) do
        if not want[flag] then
            setQuestFlag(flag, false)
            QUEST.on[flag] = nil
        end
    end
    QUEST.status = #goals == 0 and "quest: no active goals found" or table.concat(parts, " | ")
end

guardedSpawn("worker-14", function()
    while isRunning() do
        pcall(questTick)
        if QUEST.label then
            pcall(function() QUEST.label.Text = QUEST.status end)
        end
        task.wait(2)
    end
end)

trackConnection(LocalPlayer.Idled:Connect(function()
    if not Flags.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end))

local function setFPSBoost(on)
    Flags.FPSBoost = on
    applyRender()
end
local function optimizeGame(on)
    Flags.OptGame = on
    applyRender()
end

local function rejoin()
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end

local function serverHop()
    local ok, body = pcall(function()
        return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
    end)
    if ok then
        local okj, data = pcall(function() return HttpService:JSONDecode(body) end)
        if okj and type(data) == "table" and type(data.data) == "table" then
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
                    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer) end)
                    return
                end
            end
        end
    end
    rejoin()
end

local rejoinBusy = false
trackConnection(GuiService.ErrorMessageChanged:Connect(function()
    if Flags.AutoRejoin and not rejoinBusy then
        rejoinBusy = true
        task.wait(2)
        rejoin()
        task.wait(5)
        rejoinBusy = false
    end
end))

local function statsLine()
    local t = math.floor(tick() - Stats.Start)
    local left, near = orbLeft()
    return string.format("orb req %d (left %d, nearest %s) | bag req %d | hatch resp %d | %02d:%02d:%02d",
        Stats.Orbs, left, near and string.format("%.0fst", near) or "-",
        Stats.Bags, Stats.Hatches, t // 3600, (t % 3600) // 60, t % 60)
end

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
local lastSummary = tick()
local function webhookUrlOk(url)
    if type(url) ~= "string" or #url < 40 or #url > 200 then return false end
    -- Lua patterns are intentional here; do not pass plain=true to string.find.
    return url:match("^https://discord%.com/api/webhooks/%d+/[%w%-_]+$") ~= nil
        or url:match("^https://discordapp%.com/api/webhooks/%d+/[%w%-_]+$") ~= nil
end
local function sendWebhook(title, text)
    local url = State.WebhookUrl
    if not httpRequest or not webhookUrlOk(url) then return false end
    local body = HttpService:JSONEncode({
        username = "PS99",
        embeds = { { title = title, description = text, color = 0xF1C40F } },
    })
    local ok, res = pcall(httpRequest, {
        Url = url, Method = "POST",
        Headers = { ["Content-Type"] = "application/json" }, Body = body,
    })
    if not ok or type(res) ~= "table" then return false end
    local code = res.StatusCode or res.Status
    return type(code) == "number" and code >= 200 and code < 300
end

guardedSpawn("worker-15", function()
    while isRunning() do
        task.wait(12)
        if State.SummaryMins > 0 and tick() - lastSummary >= State.SummaryMins * 60 then
            lastSummary = tick()
            sendWebhook("Session", statsLine())
        end
    end
end)

local Rare = { Last = nil, Every = 3 }
local PetInfo = {}
do
    local rows = apiGet("Pets")
    if rows then
        for _, p in ipairs(rows) do
            local c = p.configData
            if type(c) == "table" and type(c.name) == "string" then
                local r = type(c.rarity) == "table" and (c.rarity.DisplayName or c.rarity._id) or nil
                PetInfo[c.name] = { rarity = r and string.lower(tostring(r)) or "", huge = c.huge == true }
            end
        end
    end
end
local function classify(name)
    local l = name:lower()
    local info = PetInfo[name]
    local rar = info and info.rarity or ""
    if Flags.RareTitanic and (l:sub(1, 8) == "titanic " or rar == "titanic") then return "Titanic" end
    if Flags.RareTitanic and l:sub(1, 11) == "gargantuan " then return "Gargantuan" end
    if Flags.RareHuge and (l:sub(1, 5) == "huge " or (info and info.huge)) then return "Huge" end
    if Flags.RareExclusive and rar == "exclusive" then return "Exclusive" end
    for w in string.gmatch(string.lower(State.Keywords or ""), "[^,]+") do
        w = w:match("^%s*(.-)%s*$")
        if w ~= "" and l:find(w, 1, true) then return "Keyword" end
    end
    return nil
end
local function getHatchCounts()
    local r = Network:FindFirstChild("Index: Request Hatch Count")
    if not r then return nil end
    local ok, res = pcall(r.InvokeServer, r)
    if ok and type(res) == "table" then return res end
    return nil
end

guardedSpawn("worker-16", function()
    while isRunning() do
        task.wait(Rare.Every)
        if Flags.RareAlerts then
            local now = getHatchCounts()
            if now then
                if Rare.Last then
                    for name, c in pairs(now) do
                        if type(name) == "string" and type(c) == "number" then
                            local d = c - (type(Rare.Last[name]) == "number" and Rare.Last[name] or 0)
                            local cat = d > 0 and classify(name)
                            if cat then
                                local msg = string.format("%s x%d (total %d)", name, d, c)
                                spawnTask(sendWebhook, "New " .. cat, msg .. "\n" .. statsLine())
                            end
                        end
                    end
                end
                Rare.Last = now
            end
        else
            Rare.Last = nil
        end
    end
end)

local function hideIn(folder, on)
    if not folder then return end
    for _, d in ipairs(folder:GetDescendants()) do
        if d:IsA("BasePart") then
            cacheProp(d, "LocalTransparencyModifier")
            if on then
                d.LocalTransparencyModifier = 1
            else
                local cached = visualCache[d]
                if cached and cached.LocalTransparencyModifier ~= nil then
                    d.LocalTransparencyModifier = cached.LocalTransparencyModifier
                end
            end
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then
            cacheProp(d, "Enabled")
            if on then
                d.Enabled = false
            else
                local cached = visualCache[d]
                if cached and cached.Enabled ~= nil then
                    d.Enabled = cached.Enabled
                end
            end
        end
    end
end
local function petsFolder() return Things:FindFirstChild("Pets") end

local function restoreParticles()
    for inst, props in pairs(visualCache) do
        if inst and inst.Parent and (inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")) then
            local enabled = props.Enabled
            if enabled ~= nil then pcall(function() inst.Enabled = enabled end) end
        end
    end
end


local particleAddedConn
local function suppressParticle(inst)
    if not (inst and (inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam"))) then return end
    cacheProp(inst, "Enabled")
    pcall(function() inst.Enabled = false end)
end
local function startParticleOptimization()
    if particleAddedConn then particleAddedConn:Disconnect(); particleAddedConn = nil end
    for _, d in ipairs(Workspace:GetDescendants()) do suppressParticle(d) end
    particleAddedConn = Workspace.DescendantAdded:Connect(suppressParticle)
end
local function stopParticleOptimization()
    if particleAddedConn then particleAddedConn:Disconnect(); particleAddedConn = nil end
    restoreParticles()
end
onCleanup(stopParticleOptimization)

guardedSpawn("visual-optimization", function()
    local lastBreakFolder, lastPetsFolder = nil, nil
    local lastBreakOn, lastPetsOn = nil, nil
    while isRunning() do
        local breakFolder, petFolder = getBreakables(), petsFolder()
        if breakFolder ~= lastBreakFolder or Flags.OptBreak ~= lastBreakOn then
            if lastBreakFolder and lastBreakOn and lastBreakFolder ~= breakFolder then
                pcall(hideIn, lastBreakFolder, false)
            end
            if breakFolder then pcall(hideIn, breakFolder, Flags.OptBreak) end
            lastBreakFolder, lastBreakOn = breakFolder, Flags.OptBreak
        end
        if petFolder ~= lastPetsFolder or Flags.OptPets ~= lastPetsOn then
            if lastPetsFolder and lastPetsOn and lastPetsFolder ~= petFolder then
                pcall(hideIn, lastPetsFolder, false)
            end
            if petFolder then pcall(hideIn, petFolder, Flags.OptPets) end
            lastPetsFolder, lastPetsOn = petFolder, Flags.OptPets
        end
        task.wait(1)
    end
end)

-- ─── REMOTE SPY + DUMPS ──────────────────────────────────────────────────────
-- logs the game's own Network calls (args + invoke returns) so shapes come from real traffic.
-- one hook per session (kept in _G so re-executing doesn't stack hooks); it is a passthrough when off.
local Spy = _G.PS99Spy
if not Spy then
    Spy = { On = false, Installed = false, Filter = "", Counts = {}, Entries = {}, PerRemote = 6 }
    _G.PS99Spy = Spy
end
Spy.On = false
Spy.Filter = State.SpyFilter or ""
Spy.Counts = {}
Spy.Entries = {}
Spy.Total = 0
Spy.MaxTotal = 300
onCleanup(function() Spy.On = false end)

-- no Instance method calls in here: a nested namecall inside the hook clobbers the pending method
local function ser(v, d)
    d = d or 0
    local t = typeof(v)
    if t == "string" then
        return string.format("%q", v)
    elseif t == "number" or t == "boolean" or t == "nil" then
        return tostring(v)
    elseif t == "table" then
        if d >= 3 then return "{...}" end
        local parts, n = {}, 0
        for k, x in pairs(v) do
            n += 1
            if n > 20 then
                parts[#parts + 1] = "..."
                break
            end
            local key = type(k) == "number" and ("[" .. k .. "]") or tostring(k)
            parts[#parts + 1] = key .. "=" .. ser(x, d + 1)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif t == "Instance" then
        return "<" .. v.ClassName .. " " .. v.Name .. ">"
    end
    return t .. "(" .. tostring(v) .. ")"
end

local function spyRecord(name, kind, args, res)
    if Spy.Filter ~= "" and not string.find(string.lower(name), string.lower(Spy.Filter), 1, true) then
        return
    end
    if not Spy.Entries[name] and Spy.Total >= Spy.MaxTotal then return end
    Spy.Counts[name] = (Spy.Counts[name] or 0) + 1
    local list = Spy.Entries[name]
    if not list then
        list = {}
        Spy.Entries[name] = list
    end
    if #list >= Spy.PerRemote or Spy.Total >= Spy.MaxTotal then return end
    local a = {}
    for i = 1, args.n do a[#a + 1] = ser(args[i]) end
    local line = kind .. " " .. name .. "(" .. table.concat(a, ", ") .. ")"
    if res then
        local r = {}
        for i = 1, res.n do r[#r + 1] = ser(res[i]) end
        line = line .. " -> " .. table.concat(r, ", ")
    end
    list[#list + 1] = line
    Spy.Total += 1
end

local function installSpy()
    if Spy.Installed then return true end
    if not (hookmetamethod and getnamecallmethod and newcclosure) then return false end
    local old
    local ok,err=pcall(function()
        old=hookmetamethod(game,"__namecall",newcclosure(function(self,...)
            local method=getnamecallmethod()
            if Spy.On and (method=="FireServer" or method=="InvokeServer")
                and typeof(self)=="Instance" and self.Parent==Network
                and not (checkcaller and checkcaller()) then
                local args=table.pack(...)
                local results=table.pack(old(self,...))
                if Spy.On then pcall(spyRecord,self.Name,method,args,method=="InvokeServer" and results or nil) end
                return table.unpack(results,1,results.n)
            end
            return old(self,...)
        end))
    end)
    if not ok then warn("[PS99] Spy installation failed: "..tostring(err)) return false end
    Spy.Installed = true
    return true
end

local function syncSpy()
    Spy.Filter=State.SpyFilter or ""
    if not Flags.Spy then Spy.On=false return end
    Spy.On=installSpy()
    if not Spy.On then Flags.Spy=false warn("[PS99] Spy disabled: required hook APIs unavailable or failed") end
end
syncSpy()

local function copyLines(lines)
    local text = table.concat(lines, "\n")
    print("[PS99] dump (" .. #lines .. " lines)\n" .. text)
    local okc = pcall(function() setclipboard(text) end)
    return okc, #lines
end

local function spyLines()
    local names = {}
    for name in pairs(Spy.Entries) do names[#names + 1] = name end
    table.sort(names)
    local lines = {}
    for _, name in ipairs(names) do
        lines[#lines + 1] = string.format("-- %s x%d", name, Spy.Counts[name] or 0)
        for _, l in ipairs(Spy.Entries[name]) do lines[#lines + 1] = l end
    end
    return lines
end

local function dumpThings()
    local lines = workerDiagnosticDetails()
    if HRP and HRP.Parent then
        local p = HRP.Position
        lines[#lines + 1] = string.format("player at %.0f,%.0f,%.0f", p.X, p.Y, p.Z)
    end
    for _, c in ipairs(Things:GetChildren()) do
        lines[#lines + 1] = string.format("%s [%s] children=%d", c.Name, c.ClassName, #c:GetChildren())
    end
    for _, fname in ipairs({ "Orbs", "Lootbags" }) do
        local f = Things:FindFirstChild(fname)
        if f then
            lines[#lines + 1] = "-- " .. fname .. " sample (first 8 still on the map)"
            local sent = (fname == "Orbs") and sentOrbs or sentBags
            for i, o in ipairs(f:GetChildren()) do
                if i > 8 then break end
                local pos, at, dist = "?", {}, "?"
                pcall(function()
                    local p = o:GetPivot().Position
                    pos = string.format("%.0f,%.0f,%.0f", p.X, p.Y, p.Z)
                    if HRP and HRP.Parent then dist = string.format("%.0fst", (p - HRP.Position).Magnitude) end
                end)
                pcall(function()
                    for k, v in pairs(o:GetAttributes()) do at[#at + 1] = k .. "=" .. tostring(v) end
                end)
                local key = (fname == "Orbs") and tonumber(o.Name) or o.Name
                lines[#lines + 1] = string.format("%s [%s] pos=%s dist=%s attrs=%s sent=%s",
                    o.Name, o.ClassName, pos, dist, table.concat(at, ";"), tostring(key ~= nil and sent[key] ~= nil))
            end
        end
    end
    return lines
end

local function dumpEggs()
    local lines = {}
    for _, e in ipairs(scanEggs()) do
        lines[#lines + 1] = "match " .. e[2] .. " -> " .. e[1]:GetFullName()
    end
    local n = 0
    for _, d in ipairs(Things:GetDescendants()) do
        if (d:IsA("Model") or d:IsA("BasePart")) and d.Name:lower():find("egg", 1, true) then
            lines[#lines + 1] = "egg-like " .. d:GetFullName()
            n += 1
            if n >= 80 then break end
        end
    end
    return lines
end

local function dumpRankGoals()
    local goals = activeGoals()
    if #goals == 0 then return { "active rank goals not found in memory" } end
    local lines = { "active rank goals: " .. #goals }
    for _, g in ipairs(goals) do
        lines[#lines + 1] = string.format("type=%s amount=%s progress=%s stars=%s uid=%s",
            tostring(g.Type), tostring(g.Amount), tostring(g.Progress), tostring(g.Stars), tostring(g.UID))
    end
    return lines
end

local function dumpInventory()
    local totals = inventoryTotals()
    if not totals then return { "inventory table not found in memory" } end
    local rows = {}
    for id, n in pairs(totals) do rows[#rows + 1] = { id, n } end
    table.sort(rows, function(a, b) return a[2] > b[2] end)
    local lines = { "items: " .. #rows }
    for i, r in ipairs(rows) do
        if i > 80 then break end
        lines[#lines + 1] = r[1] .. " x" .. tostring(r[2])
    end
    return lines
end

local function dumpStats()
    local lines = {}
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            lines[#lines + 1] = "leaderstats." .. v.Name .. " = " .. tostring(v.Value)
        end
    end
    local st = memStats()
    if st then
        local ks = {}
        for k, v in pairs(st) do
            if type(v) ~= "table" then ks[#ks + 1] = tostring(k) .. " = " .. tostring(v) end
        end
        table.sort(ks)
        for _, s in ipairs(ks) do lines[#lines + 1] = "stats." .. s end
    else
        lines[#lines + 1] = "stats table not found in memory"
    end
    local root = memRoot()
    if not root then
        lines[#lines + 1] = "client data root not found in memory"
        return lines
    end
    local keys = {}
    for k, v in pairs(root) do
        keys[#keys + 1] = type(v) == "table" and (tostring(k) .. " {table}") or (tostring(k) .. " = " .. tostring(v))
    end
    table.sort(keys)
    for _, line in ipairs(keys) do lines[#lines + 1] = "root." .. line end
    return lines
end


-- Mobile GUI: persistent row objects, tab filtering and responsive sizing.
-- v8.2.56: inventory-aware, rate-limited consumable replenishment.
local ConsumableStatus={text="Fruits and potions idle. Buff activation not verified."}
local function consumableModules()
    local rs=game:GetService("ReplicatedStorage")
    local lib=rs:FindFirstChild("Library")
    local client=lib and lib:FindFirstChild("Client")
    if not client then return nil end
    local okSave,save=pcall(require,client:WaitForChild("Save",3))
    local okFruit,fruit=pcall(require,client:WaitForChild("FruitCmds",3))
    local okPotion,potion=pcall(require,client:WaitForChild("PotionCmds",3))
    if not (okSave and okFruit and okPotion) then return nil end
    local net=rs:FindFirstChild("Network")
    return save,fruit,potion,net
end
local function chooseInventoryItem(inventory,id,tier)
    local bestUid,bestTier,bestCount
    for uid,item in pairs(inventory or {}) do
        if type(item)=="table" and item.id==id and (item._am==nil and 1 or (tonumber(item._am) or 0))>0 then
            local t=tonumber(item.tn) or 0
            if (not tier or t==tier) and (not bestUid or t>bestTier) then
                bestUid,bestTier,bestCount=uid,t,item._am==nil and 1 or tonumber(item._am)
            end
        end
    end
    return bestUid,bestTier,bestCount
end
local function selectedName(selection,name)
    if selection=="All" then return true end
    for part in tostring(selection or ""):gmatch("[^,]+") do
        if part:lower()==tostring(name):lower() then return true end
    end
    return false
end
local function fruitQueueCount(active,name)
    local data=active[name]
    return type(data)=="table" and type(data.Normal)=="table" and #data.Normal or 0
end
local ConsumableScheduler={fruitNext=0,potionNext=0,turn="Fruit",pending=nil,fruitCursor=0,potionCursor=0}
local function availablePotionNames()
    local save=select(1,consumableModules())
    local ok,data=pcall(function() return save and save.Get() end)
    local names,seen={},{}
    if ok and type(data)=="table" and type(data.Inventory)=="table" then
        for _,item in pairs(data.Inventory.Potion or {}) do
            if type(item)=="table" and type(item.id)=="string" and not seen[item.id] then
                seen[item.id]=true; names[#names+1]=item.id
            end
        end
    end
    table.sort(names)
    return names
end
local function checkPending(inv,activeFruit,activePotion)
    local p=ConsumableScheduler.pending
    if not p then return end
    local item=inv[p.category] and inv[p.category][p.uid]
    local amount=type(item)=="table" and (tonumber(item._am) or 0) or 0
    local changed=amount<p.before
    if not changed and p.category=="Fruit" and type(activeFruit)=="table" then
        changed=fruitQueueCount(activeFruit,p.name)>p.beforeQueue
    end
    if not changed and p.category=="Potion" and type(activePotion)=="table" then
        local t=activePotion[p.name]
        local now=type(t)=="table" and tonumber(t[p.tier]) or 0
        changed=now>p.beforeDuration+5
    end
    if changed then
        ConsumableStatus.text=p.category.." confirmed: "..p.name
        ConsumableScheduler.pending=nil
    elseif os.clock()-p.sent>2.5 then
        ConsumableStatus.text=p.category.." not confirmed: "..p.name.." (retry later)"
        ConsumableScheduler.pending=nil
        ConsumableScheduler[p.category=="Fruit" and "fruitNext" or "potionNext"]=os.clock()+3
    end
end
local function consumableTick()
    if not Flags.AutoEatFruits then
        ConsumableScheduler.pending=nil
        ConsumableStatus.text="Fruits and potions idle. Buff activation not verified."
        return
    end
    local save,fruit,potion,network=consumableModules()
    if not save or not network then ConsumableStatus.text="Consumable modules unavailable" return end
    local ok,data=pcall(save.Get)
    if not ok or type(data)~="table" or type(data.Inventory)~="table" then
        ConsumableStatus.text="Inventory unavailable" return
    end
    local inv=data.Inventory
    local okFruit,activeFruit=pcall(fruit.GetActiveFruits)
    local okPotion,activePotion=pcall(potion.GetActivePotions)
    if not okFruit then activeFruit=nil end
    if not okPotion then activePotion=nil end
    checkPending(inv,activeFruit,activePotion)
    if ConsumableScheduler.pending then return end
    local now=os.clock()
    local function tryFruit()
        if not Flags.AutoEatFruits or now<ConsumableScheduler.fruitNext or type(activeFruit)~="table" then return false end
        local remote=network:FindFirstChild("Fruits: Consume")
        if not remote or not remote:IsA("RemoteEvent") then return false end
        local names={"Apple","Banana","Orange","Pineapple","Watermelon","Rainbow"}
        local okLimit, computedLimit = pcall(fruit.ComputeFruitQueueLimit)
        local target = okLimit and tonumber(computedLimit) or nil
        if not target or target < 1 then
            ConsumableStatus.text="Fruit queue capacity unavailable; waiting"
            return false
        end
        target = math.floor(target) -- account-specific, refreshed every cycle
        for step=1,#names do
            local i=(ConsumableScheduler.fruitCursor+step-1)%#names+1
            local name=names[i]
            if selectedName(State.FruitSelection,name) then
                local queue=fruitQueueCount(activeFruit,name)
                if queue<target then
                    local uid,_,amount=chooseInventoryItem(inv.Fruit,name)
                    if uid and amount>0 then
                        local quantity=math.min(target-queue,amount)
                        local success=quantity>0 and pcall(function() remote:FireServer(uid,quantity) end)
                        if success then
                            ConsumableScheduler.fruitCursor=i
                            ConsumableScheduler.fruitNext=now+0.45
                            ConsumableScheduler.pending={category="Fruit",name=name,uid=uid,before=amount,beforeQueue=queue,sent=now}
                            ConsumableStatus.text="Fruit requested: "..name.." x"..quantity.." ("..queue.."/"..target..")"
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    -- Potion requests are owned exclusively by the verified auto-potions worker.
    local sent=tryFruit()
    if not sent then ConsumableStatus.text="No eligible fruit items" end
end
guardedSpawn("consumable-worker",function()
    while isRunning() do
        if Flags.AutoEatFruits then
            local ok,err=pcall(consumableTick)
            if not ok then ConsumableStatus.text="Consumable error: "..tostring(err) end
        end
        task.wait(0.35)
    end
end)

-- Auto Potions: one native request, then inventory AND duration confirmation.
local AutoPotions=(function()
    local U={nextAttempt=0,pending=nil,cursor=0,lastLog=nil}
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    local function enabled() return isRunning() and Flags.AutoUsePotions end
    function U.log(s) if U.lastLog~=s then U.lastLog=s print("[AERO POTIONS] "..s) end end
    function U.inventory()
        U.save=U.save or require(RS.Library.Client.Save)
        local data=U.save.Get()
        return data and data.Inventory and data.Inventory.Potion
    end
    function U.count(items,uid)
        local item=items and items[uid]
        if type(item)~="table" then return 0 end
        local n=item._am==nil and 1 or tonumber(item._am)
        return finite(n) and math.max(0,math.floor(n)) or 0
    end
    function U.tick()
        if not enabled() then U.pending=nil return end
        local now=os.clock()
        if now<U.nextAttempt and not U.pending then return end
        U.cmd=U.cmd or require(RS.Library.Client.PotionCmds)
        local items=U.inventory()
        local active=U.cmd.GetActivePotions()
        if type(items)~="table" or type(active)~="table" then U.nextAttempt=now+30 return end
        if U.pending then
            local p=U.pending
            local tiers=active[p.name]
            local duration=type(tiers)=="table" and tonumber(tiers[p.tier]) or 0
            if U.count(items,p.uid)<p.amount and finite(duration) and duration>p.duration then
                U.log("Refill verified: "..p.name.." tier "..p.tier) U.pending=nil
            elseif now>=p.deadline then
                U.log("Request unconfirmed; waiting before retry") U.pending=nil U.nextAttempt=now+60
            end
            return
        end
        U.mastery=U.mastery or require(RS.Library.Client.MasteryCmds)
        if type(U.mastery.CanUsePotion)~="function" then
            U.log("Tier eligibility unavailable; consumption paused") U.nextAttempt=now+30 return
        end
        local best,names={},{}
        for uid,item in pairs(items) do
            if type(uid)=="string" and type(item)=="table" and type(item.id)=="string" and selectedName(State.PotionSelection,item.id) and U.count(items,uid)>0 then
                local tier=item.tn==nil and 1 or tonumber(item.tn)
                if finite(tier) and tier>=1 and tier==math.floor(tier) then
                    local ok,can=pcall(U.mastery.CanUsePotion,tier)
                    if ok and can==true and (not best[item.id] or tier>best[item.id].tier) then
                        best[item.id]={uid=uid,tier=tier}
                    end
                end
            end
        end
        for name in pairs(best) do names[#names+1]=name end
        table.sort(names)
        local threshold=tonumber(State.PotionRefillSeconds)
        threshold=finite(threshold) and math.clamp(threshold,0,6000) or 300
        for step=1,#names do
            local i=(U.cursor+step-1)%#names+1
            local name=names[i]
            local choice=best[name]
            local tiers=active[name] or {}
            local blocked=false
            local duration=tonumber(tiers[choice.tier]) or 0
            if not finite(duration) then blocked=true end
            for tier,remaining in pairs(tiers) do
                tier=tonumber(tier) remaining=tonumber(remaining)
                if not finite(tier) or not finite(remaining) then blocked=true
                elseif tier>choice.tier and remaining>0 then blocked=true end
            end
            if not blocked and duration<=threshold then
                if not enabled() or not selectedName(State.PotionSelection,name) then return end
                local before=U.count(U.inventory(),choice.uid)
                if before<1 then return end
                local ok,can=pcall(U.mastery.CanUsePotion,choice.tier)
                if not ok or can~=true or not enabled() then return end
                U.nextAttempt=os.clock()+30 U.cursor=i
                U.pending={uid=choice.uid,name=name,tier=choice.tier,amount=before,duration=duration,deadline=os.clock()+8}
                U.log("Requesting one "..name.." tier "..choice.tier)
                U.cmd.Consume(choice.uid,1)
                return
            end
        end
        U.nextAttempt=now+5
    end
    onCleanup(function() U.pending=nil end)
    return U
end)()
do
    local env=type(getgenv)=="function" and getgenv() or _G
    local old=env.AERO_PotionsV6
    if type(old)=="table" then old.Enabled=false old.Running=false end
end
guardedSpawn("auto-potions",function()
    while isRunning() do
        local ok,err=pcall(AutoPotions.tick)
        if not ok then AutoPotions.pending=nil AutoPotions.nextAttempt=os.clock()+60 AutoPotions.log("Waiting after error: "..tostring(err)) end
        task.wait(1)
    end
end)

-- v8.2.56: verified toy buff activation, expiry-aware and inventory-safe.
local BuffStatus={text="Toy buffs idle"}
local toyBuffs={
    {name="Squeaky Toy",remote="SqueakyToy_Consume"},
    {name="Toy Ball",remote="ToyBall_Consume"},
    {name="Toy Bone",remote="ToyBone_Consume"},
}
local buffRetry={}
local function toyInventoryAmount(inv,name)
    local total=0
    for _,item in pairs(inv or {}) do
        if type(item)=="table" and item.id==name then
            total=total+(tonumber(item._am) or 1)
        end
    end
    return total
end
local function buffTick()
    if not Flags.AutoUseBuffs then BuffStatus.text="Toy buffs idle" return end
    local rs=game:GetService("ReplicatedStorage")
    local lib=rs:FindFirstChild("Library")
    local client=lib and lib:FindFirstChild("Client")
    local network=rs:FindFirstChild("Network")
    if not client or not network then BuffStatus.text="Buff modules/network unavailable" return end
    local okBuff,buffs=pcall(require,client:FindFirstChild("BuffCmds"))
    local okSave,save=pcall(require,client:FindFirstChild("Save"))
    if not (okBuff and okSave and type(buffs)=="table") then BuffStatus.text="Buff modules unavailable" return end
    local okData,data=pcall(function() return save.Get() end)
    if not okData or type(data)~="table" then BuffStatus.text="Buff inventory unavailable" return end
    local misc=type(data.Inventory)=="table" and data.Inventory.Misc or nil
    for _,toy in ipairs(toyBuffs) do
        if selectedName(State.BuffSelection,toy.name) then
            local okActive,active=pcall(buffs.IsActive,toy.name)
            local okTimer,remaining=pcall(buffs.GetTimer,toy.name)
            if not okActive or not okTimer or type(remaining)~="number" then
                BuffStatus.text="Cannot verify buff timer: "..toy.name
            elseif active and remaining>0 then
                BuffStatus.text=toy.name.." active ("..math.floor(remaining).."s)"
            elseif os.clock()>=(buffRetry[toy.name] or 0) then
                if toyInventoryAmount(misc,toy.name)<1 then
                    buffRetry[toy.name]=os.clock()+30
                    BuffStatus.text="Out of "..toy.name
                else
                    local remote=network:FindFirstChild(toy.remote)
                    if not remote or not remote:IsA("RemoteFunction") then
                        BuffStatus.text="Missing remote: "..toy.remote
                        buffRetry[toy.name]=os.clock()+30
                    else
                        buffRetry[toy.name]=os.clock()+12
                        local ok,err=pcall(function() return remote:InvokeServer() end)
                        BuffStatus.text=ok and ("Requested "..toy.name.."; checking effect") or ("Toy use failed: "..tostring(err))
                        -- One invocation per tick; never spam on missing server confirmation.
                        return
                    end
                end
            end
        end
    end
end
guardedSpawn("toy-buff-worker",function()
    while isRunning() do
        if Flags.AutoUseBuffs then
            local ok,err=pcall(buffTick)
            if not ok then BuffStatus.text="Buff error: "..tostring(err) end
        end
        task.wait(2)
    end
end)

-- v8.2.56: Lootbox_RequestOpen confirmed by live client tests for four IDs.
-- Keep GiftBag_Open for misc gifts and bundles; use Signal for lootbox inventory.
local GiftStatus={text="Auto gifts idle"}
local giftSpecs={
    {id="Gift Bag", method="bag", quantity=true},
    {id="Large Gift Bag", method="bag", quantity=true},
    {id="Toy Bundle", method="bag"},
    {id="Potion Bundle", method="bag"},
    {id="Fruit Bundle", method="bag"},
    {id="Flag Bundle", method="bag"},
    {id="Charm Stone", method="bag"},
    {id="Wooden Gift", method="lootbox"},
    {id="Hype Egg 3", method="lootbox"},
    {id="Small Fantasy Present", method="lootbox"},
    {id="World Cup Gift", method="lootbox"},
}
-- Inventory-driven picker. Only confirmed GiftBag_Open items are sent to the server.
-- Other gift-like inventory items are listed for visibility, but require their
-- own verified opening signatures before automation can support them.
local function availableGiftNames()
    local names,seen={},{}
    local rs=game:GetService("ReplicatedStorage")
    local ok,save=pcall(function() return require(rs.Library.Client.Save).Get() end)
    if not ok or type(save)~="table" or type(save.Inventory)~="table" then return names end
    for category,stacks in pairs(save.Inventory) do
        if type(stacks)=="table" then
            for _,item in pairs(stacks) do
                if type(item)=="table" and type(item.id)=="string" then
                    local name=item.id
                    local lower=name:lower()
                    local categoryName=tostring(category):lower()
                    local eligible=categoryName:find("gift",1,true) or categoryName:find("lootbox",1,true)
                        or lower:find("gift",1,true) or lower:find("bundle",1,true)
                        or lower:find("present",1,true) or lower:find("charm stone",1,true)
                    if eligible and (tonumber(item._am) or 1)>0 and not seen[name] then
                        seen[name]=true
                        names[#names+1]=name
                    end
                end
            end
        end
    end
    table.sort(names)
    return names
end
-- Snapshot the owned gift names before GUI construction, exactly like the
-- working static Fruit/Potion/Buff dropdown option arrays. Avoid passing a
-- function as row[4] on mobile; the UI can rebuild it repeatedly.
local giftPickerOptions=availableGiftNames()
print("[AERO GIFTS] Picker inventory options:",#giftPickerOptions,table.concat(giftPickerOptions," | "))
if #giftPickerOptions==0 then
    giftPickerOptions={"Gift Bag","Large Gift Bag","Toy Bundle","Potion Bundle","Fruit Bundle","Flag Bundle","Charm Stone","Wooden Gift","Hype Egg 3","Small Fantasy Present","World Cup Gift"}
end
print("[AERO P22.3] READY | reconciled requests, conservative recovery | cap=100 | no teleport")
-- Phase 22.1: adaptive verified batching. Start at one; increase only after
-- observing the inventory decrease by the entire requested amount.
-- A 100-item ceiling is a safety cap, NOT a claimed server maximum.
local giftNext=0
local giftCursor=0
local giftLastLog=""
GiftStatus.batchState={}
GiftStatus.metrics={requests=0,verified=0,items=0,short=0,rejected=0,timeouts=0,delayed=0,backoffs=0,errors=0,started=os.clock()}
local function giftLog(message)
    if message~=giftLastLog then
        giftLastLog=message
        print("[AERO GIFTS] "..message)
    end
end
local giftPending=nil
local function giftAmount(inventory,id)
    local count=0
    if type(inventory)~="table" then return 0 end
    for _,category in pairs(inventory) do
        if type(category)=="table" then
            for _,entry in pairs(category) do
                if type(entry)=="table" and entry.id==id then
                    local n=entry._am==nil and 1 or tonumber(entry._am)
                    if n and n==n and n<math.huge then count+=math.max(0,math.floor(n)) end
                end
            end
        end
    end
    return count
end
_G.AERO_PS99_P223_GiftReport=function(quiet)
    if quiet then return {metrics=GiftStatus.metrics,batches=GiftStatus.batchState,pending=giftPending,status=GiftStatus.text} end
    local m=GiftStatus.metrics
    print(string.format("[AERO P22.3] elapsed=%.1fs observed-items/min=%.1f verified/request=%.1f%% errors=%d",os.clock()-m.started,m.items*60/math.max(1,os.clock()-m.started),100*m.verified/math.max(1,m.requests),m.errors))
    print(string.format("[AERO P22.3] GIFTS requests=%d verified=%d observed-items=%d short=%d rejected=%d timeouts=%d delayed=%d backoffs=%d pending=%s",
        GiftStatus.metrics.requests,GiftStatus.metrics.verified,GiftStatus.metrics.items,GiftStatus.metrics.short,GiftStatus.metrics.rejected,GiftStatus.metrics.timeouts,GiftStatus.metrics.delayed,GiftStatus.metrics.backoffs,tostring(giftPending~=nil)))
    print("[AERO P22.3] Inventory deltas are observations; external gains/consumption can affect attribution.")
    for id,state in pairs(GiftStatus.batchState) do
        print(string.format("[AERO P22.3] BATCH %s | next=%d | max-verified=%d | failures=%d | retry-in=%.1fs",id,state.next,state.maxVerified,state.failures or 0,math.max(0,(state.retryAt or 0)-os.clock())))
        print(string.format("[AERO P22.3] %s | ceiling=%d | cooldown=%.2fs | last=%s",id,state.ceiling or 100,state.interval or 0.3,state.lastReason or "none"))
    end
    return {metrics=GiftStatus.metrics,batches=GiftStatus.batchState,pending=giftPending,status=GiftStatus.text}
end
_G.AERO_PS99_P222_GiftReport=_G.AERO_PS99_P223_GiftReport
_G.AERO_PS99_P221_GiftReport=_G.AERO_PS99_P223_GiftReport
onCleanup(function()
    for _,key in ipairs({"AERO_PS99_P221_GiftReport","AERO_PS99_P222_GiftReport","AERO_PS99_P223_GiftReport"}) do
        if _G[key]==_G.AERO_PS99_P223_GiftReport then _G[key]=nil end
    end
    _G.AERO_PS99_P223_GiftReport=nil
end)
-- Read-only gift diagnostics. No unverified remote is invoked.
local function giftDiagnostic()
    local rs=game:GetService("ReplicatedStorage")
    local ok,data=pcall(function()return require(rs.Library.Client.Save).Get()end)
    if not ok or type(data)~="table" or type(data.Inventory)~="table" then
        warn("[AERO GIFTS] Diagnostic: inventory unavailable")
        return
    end
    local supported={}
    for _,spec in ipairs(giftSpecs) do supported[spec.id]=spec.method end
    local lines={"AERO PS99 v8.2.84 P24.4 gift diagnostic (read-only)","Item | Category | Quantity | Support"}
    local found=0
    for category,stacks in pairs(data.Inventory) do
        if type(stacks)=="table" then
            for _,entry in pairs(stacks) do
                if type(entry)=="table" and type(entry.id)=="string" then
                    local id=entry.id
                    local lower=id:lower()
                    local cat=tostring(category):lower()
                    if cat:find("gift",1,true) or cat:find("lootbox",1,true)
                        or lower:find("gift",1,true) or lower:find("bundle",1,true)
                        or lower:find("present",1,true) or lower:find("charm stone",1,true)
                        or lower:find("hype egg",1,true) then
                        local qty=tonumber(entry._am) or 1
                        if qty>0 then
                            found+=1
                            lines[#lines+1]=string.format("%s | %s | %s | %s",id,tostring(category),tostring(qty),supported[id] == "lootbox" and "Lootbox_RequestOpen" or (supported[id] == "bag" and "GiftBag_Open" or "Unverified (not auto-opened)"))
                        end
                    end
                end
            end
        end
    end
    lines[#lines+1]="Total matching stacks: "..found
    local report=table.concat(lines,"\n")
    print("[AERO GIFTS]\n"..report)
    if type(writefile)=="function" then
        local saved,err=pcall(writefile,"AERO_PS99_gift_diagnostic.txt",report)
        if saved then print("[AERO GIFTS] Saved AERO_PS99_gift_diagnostic.txt")
        else warn("[AERO GIFTS] File save failed: "..tostring(err)) end
    end
end

-- v8.2.84: inventory-category lootboxes use the existing, tested client Signal.
-- One unit per request, serialized with giftTick; inventory deltas are observations.
REQUEST_STATUS.lootboxes=(function()
    local L={status="Off",requests=0,verified=0,items=0,unconfirmed=0,errors=0,rejected=0,
        nextAt=0,cursor="",blocked={},pending=nil}
    function L.inventory()
        local ok,data=pcall(function()return require(RS.Library.Client.Save).Get()end)
        if not ok or type(data)~="table" or type(data.Inventory)~="table" then return nil end
        -- A missing category is not proof a pending item was consumed.
        if type(data.Inventory.Lootbox)~="table" then return nil end
        local totals,excluded={},{}
        for _,entry in pairs(data.Inventory.Lootbox) do
            if type(entry)=="table" and type(entry.id)=="string" then
                local n=entry._am==nil and 1 or tonumber(entry._am)
                if not n or n~=n or n<0 or n%1~=0 or n>9007199254740991 then
                    excluded[entry.id]=true
                elseif entry.locked or entry._locked or entry._lk then
                    excluded[entry.id]=true
                else
                    local sum=(totals[entry.id] or 0)+n
                    if sum>9007199254740991 then excluded[entry.id]=true else totals[entry.id]=sum end
                end
            end
        end
        return totals,excluded
    end
    function L.options()
        local totals=L.inventory()
        local names={}
        for id,n in pairs(totals or {}) do if n>0 then names[#names+1]=id end end
        table.sort(names)
        return names
    end
    function L.summary()
        return string.format("%s | requests=%d observed-openings=%d observed-items=%d unconfirmed=%d rejected=%d errors=%d",L.status,L.requests,L.verified,L.items,L.unconfirmed,L.rejected,L.errors)
    end
    function L.tick()
        local now=os.clock()
        if not Flags.AutoOpenLootboxes and not L.pending then L.status="Off" return end
        if now<L.nextAt then return end
        local totals,excluded=L.inventory()
        if L.pending then
            local p=L.pending
            if totals and not excluded[p.id] and p.before-(totals[p.id] or 0)>=1 then
                L.verified=L.verified+1 L.items=L.items+(p.before-(totals[p.id] or 0))
                L.status="Inventory decrease observed: "..p.id L.pending=nil L.nextAt=now+1
            elseif now>=p.deadline then
                L.unconfirmed=L.unconfirmed+1 L.blocked[p.id]="Unconfirmed opening; blocked for this execution"
                L.status=p.id..": outcome unconfirmed; no automatic retry" L.pending=nil L.nextAt=now+1
            else L.status="Verifying "..p.id end
            return
        end
        if not totals then L.status="Waiting for readable Lootbox inventory" L.nextAt=now+3 return end
        if giftPending then L.status="Waiting for gift opening" return end
        local names={}
        for id,n in pairs(totals) do
            if n>0 and not excluded[id] and not L.blocked[id] and selectedName(State.LootboxSelection or "All",id) then names[#names+1]=id end
        end
        table.sort(names)
        if #names==0 then L.status="No selected lootbox ready (empty, excluded, or blocked)" L.nextAt=now+3 return end
        local id=names[1]
        for _,name in ipairs(names) do if name>L.cursor then id=name break end end
        if not isRunning() or not Flags.AutoOpenLootboxes or giftPending then return end
        -- Set the shared ownership before requiring/invoking anything that may yield.
        L.pending={id=id,before=totals[id],deadline=now+15} L.cursor=id
        local loaded,signal=pcall(function()return require(RS.Library.Signal)end)
        if not loaded or type(signal.Invoke)~="function" then
            L.pending=nil L.status="Lootbox opening Signal unavailable" L.nextAt=os.clock()+10 return
        end
        if not isRunning() or not Flags.AutoOpenLootboxes then L.pending=nil return end
        L.requests=L.requests+1
        local ok,result=pcall(signal.Invoke,"Lootbox_RequestOpen",id,1)
        if not ok then L.errors=L.errors+1 elseif result==false then L.rejected=L.rejected+1 end
        L.status="Requested 1 x "..id.."; checking inventory"
        L.nextAt=os.clock()+0.5
        -- Reconcile false/error responses too; they can follow server side effects.
    end
    return L
end)()
guardedSpawn("auto-lootbox-worker",function()
    while isRunning() do
        local ok,err=pcall(REQUEST_STATUS.lootboxes.tick)
        if not ok then
            local l=REQUEST_STATUS.lootboxes
            l.errors=l.errors+1 l.status="Lootbox worker error: "..tostring(err):sub(1,150) l.nextAt=os.clock()+2
        end
        task.wait(0.5)
    end
end)

-- P24.4: Conservative ticket-only spin support. The StarterWheel invoke
-- signature is supported by public client examples, NOT by our read-only PS99
-- source capture; a server response alone does not prove the spin occurred.
-- Each ambiguous request is blocked until a fresh execution rather than retried.
do
    local S={status="Off",requests=0,accepted=0,verified=0,rejected=0,errors=0,
        unconfirmed=0,nextAt=0,pending=nil,blocked=false,lastTicketTotal=nil}
    REQUEST_STATUS.spin=S
    local function ticketSnapshot()
        local ok,save=pcall(function() return require(RS.Library.Client.Save).Get() end)
        if not ok or type(save)~="table" or type(save.Inventory)~="table" then
            return nil,"Inventory not ready"
        end
        local total=0
        local matches={}
        for category,items in pairs(save.Inventory) do
            if type(items)=="table" then
                for _,entry in pairs(items) do
                    if type(entry)=="table" and type(entry.id)=="string" then
                        local id=entry.id:lower()
                        if id:find("wheel",1,true) and id:find("ticket",1,true) then
                            local n=entry._am==nil and 1 or tonumber(entry._am)
                            if not n or n~=n or n<0 or n%1~=0 or n>1000000000 then
                                return nil,"Unsafe ticket amount (refusing spin)"
                            end
                            if entry.locked or entry._locked or entry._lk then
                                return nil,"Locked ticket found (refusing spin)"
                            end
                            total=total+n
                            matches[entry.id]=true
                        end
                    end
                end
            end
        end
        local names={}
        for id in pairs(matches) do names[#names+1]=id end
        table.sort(names)
        return total,#names>0 and table.concat(names,", ") or "No wheel ticket in inventory"
    end
    function S.summary()
        return string.format("%s | requests=%d accepted-responses=%d ticket-decreases=%d unconfirmed=%d rejected=%d errors=%d",
            S.status,S.requests,S.accepted,S.verified,S.unconfirmed,S.rejected,S.errors)
    end
    function S.tick()
        if not isRunning() then return end
        local now=os.clock()
        if not Flags.AutoSpinWheel and not S.pending then S.status="Off" return end
        if S.blocked then S.status="Previous outcome unknown; automatic retries blocked until re-execute" return end
        if now<S.nextAt then return end
        local total,detail=ticketSnapshot()
        if S.pending then
            local before=S.pending.before
            if total and total<before then
                S.verified=S.verified+1
                S.pending=nil
                S.status="Wheel ticket decrease observed (spin outcome not independently confirmed)"
                S.nextAt=now+12
            elseif now>=S.pending.deadline then
                S.unconfirmed=S.unconfirmed+1
                S.pending=nil
                S.blocked=true
                S.status="Spin outcome unconfirmed; blocked until re-execute"
            else
                S.status="Checking wheel ticket after spin request"
            end
            return
        end
        if not Flags.AutoSpinWheel then S.status="Off (last request reconciled)" return end
        if not total then S.status="Waiting for safe wheel ticket snapshot: "..tostring(detail) S.nextAt=now+10 return end
        S.lastTicketTotal=total
        if total<=0 then S.status="No owned wheel ticket found; no spin sent" S.nextAt=now+15 return end
        local remote=Network:FindFirstChild("Spinny Wheel: Request Spin")
        if not remote or not remote:IsA("RemoteFunction") then
            S.status="Spinny Wheel: Request Spin RemoteFunction not found"
            S.nextAt=now+30
            return
        end
        if not Flags.AutoSpinWheel or not isRunning() then return end
        -- Establish pending ownership before yielding during invoke.
        S.pending={before=total,deadline=os.clock()+12}
        S.requests=S.requests+1
        local ok,result=pcall(function() return remote:InvokeServer("StarterWheel") end)
        if not isRunning() then return end
        if ok and result==true then S.accepted=S.accepted+1 end
        if not ok then S.errors=S.errors+1
        elseif result==false then S.rejected=S.rejected+1 end
        S.status="StarterWheel request sent; awaiting ticket change (response="..(ok and tostring(result) or "error")..")"
        S.nextAt=os.clock()+0.5
        -- Even a false response or throw can occur after server-side effects.
        -- Never blindly retry; reconcile the ticket inventory first.
    end
    guardedSpawn("spin-wheel",function()
        while isRunning() do
            local ok,err=pcall(S.tick)
            if not ok then
                S.errors=S.errors+1 S.blocked=true
                S.status="Wheel worker error (blocked): "..tostring(err):sub(1,160)
            end
            task.wait(1)
        end
    end)
end

-- P24.4: Actions below derive from the user's read-only mechanic capture.
-- UpgradeCmds and balloon hit payload were NOT captured, so ordinary upgrades
-- remain unsupported; balloon ID hit is a separate experimental opt-in.
-- Server acceptance, inventory/currency deltas, and causal success are tracked separately.
-- Never auto-enable new actions from saved settings.
do -- Verified event-upgrade API: EventUpgradeCmds.GetTier/ Purchase(id), cost:FindExact()
    local U={status="Off",requests=0,verified=0,unconfirmed=0,rejected=0,errors=0,
        completed=0,pending=nil,blocked={},nextAt=0,cursor=""}
    REQUEST_STATUS.eventUpgrades=U
    local function deps()
        local lib=RS:FindFirstChild("Library")
        if not lib then return nil end
        local ok,cmds,dir=pcall(function()
            return require(lib.Client.EventUpgradeCmds),require(lib.Directory.EventUpgrades)
        end)
        if ok and type(cmds)=="table" and type(cmds.Purchase)=="function" and
            type(cmds.GetTier)=="function" and type(dir)=="table" then return cmds,dir end
    end
    function U.options()
        local list={"All event upgrades"}
        local cmds,dir=deps()
        if dir then
            for key,item in pairs(dir) do
                if type(key)=="string" and type(item)=="table" and type(item.TierCosts)=="table" then
                    list[#list+1]=key
                end
            end
        end
        table.sort(list,function(a,b)
            if a=="All event upgrades" then return true end
            if b=="All event upgrades" then return false end
            return a<b
        end)
        return list
    end
    function U.summary()
        return string.format("%s | sent=%d tier-increases=%d unconfirmed=%d rejected=%d errors=%d | session=%d/%d",
            U.status,U.requests,U.verified,U.unconfirmed,U.rejected,U.errors,U.completed,
            tonumber(State.EventUpgradeSessionLimit) or 5)
    end
    function U.tick()
        local now=os.clock()
        if not Flags.AutoBuyUpgrades and not U.pending then U.status="Off" return end
        if now<U.nextAt then return end
        local cmds,dir=deps()
        if not cmds then U.status="EventUpgradeCmds or directory missing" U.nextAt=now+15 return end
        if U.pending then
            local p=U.pending
            local ok,tier=pcall(cmds.GetTier,p.id)
            if ok and type(tier)=="number" and tier>p.tier then
                U.verified+=1 U.completed+=1 U.pending=nil
                U.status="Observed event-upgrade tier increase: "..p.id.." "..p.tier.." to "..tier
                U.nextAt=now+2
            elseif now>=p.deadline then
                U.unconfirmed+=1 U.blocked[p.id]=true U.pending=nil
                U.status="Unconfirmed purchase for "..p.id.."; blocked this session"
                U.nextAt=now+3
            else U.status="Waiting for tier acknowledgement: "..p.id end
            return
        end
        if not Flags.AutoBuyUpgrades then U.status="Off (pending reconciled)" return end
        local limit=math.clamp(math.floor(tonumber(State.EventUpgradeSessionLimit) or 5),1,50)
        if U.completed>=limit then U.status="Session purchase limit reached" Flags.AutoBuyUpgrades=false return end
        local choice=tostring(State.EventUpgradeSelection or "All event upgrades")
        local names={}
        for id,item in pairs(dir) do
            if type(id)=="string" and (choice=="All event upgrades" or choice==id) and
                type(item)=="table" and type(item.TierCosts)=="table" and not U.blocked[id] then
                names[#names+1]=id
            end
        end
        table.sort(names)
        if #names==0 then U.status="No selected event upgrades available" U.nextAt=now+10 return end
        local candidates={}
        for _,id in ipairs(names) do
            local item=dir[id]
            local ok,tier=pcall(cmds.GetTier,id)
            if ok and type(tier)=="number" and tier>=0 and tier==math.floor(tier) and tier<#item.TierCosts then
                local cost=item.TierCosts[tier+1]
                local afford,can=pcall(function() return cost and cost:FindExact() end)
                if afford and can==true then candidates[#candidates+1]={id=id,tier=tier} end
            end
        end
        if #candidates==0 then U.status="No affordable, non-maxed event upgrades" U.nextAt=now+10 return end
        local pick=candidates[1]
        for _,item in ipairs(candidates) do if item.id>U.cursor then pick=item break end end
        if not isRunning() or not Flags.AutoBuyUpgrades then return end
        -- Re-evaluate eligibility after module calls that may yield.
        local entry=dir[pick.id]
        local ok,tier=pcall(cmds.GetTier,pick.id)
        local affordable,yes=pcall(function()
            return entry and entry.TierCosts and entry.TierCosts[(tonumber(tier) or -1)+1]
                and entry.TierCosts[tier+1]:FindExact()
        end)
        if not ok or tier~=pick.tier or not affordable or yes~=true then
            U.nextAt=now+3 return
        end
        U.pending={id=pick.id,tier=pick.tier,deadline=os.clock()+12}
        U.cursor=pick.id U.requests+=1
        -- Game client uses Purchase(id), never invoke guessed Upgrades_Purchase arguments.
        local sent,result=pcall(cmds.Purchase,pick.id)
        if not isRunning() then return end
        if not sent then U.errors+=1 elseif result==false then U.rejected+=1 end
        U.status="Event upgrade purchase sent: "..pick.id.." | response="..(sent and tostring(result) or "error")
        U.nextAt=os.clock()+1
        -- Even a false/throw may follow a server-side change. Reconcile first.
    end
    guardedSpawn("event-upgrade-purchases",function()
        while isRunning() do
            local ok,err=pcall(U.tick)
            if not ok then
                U.errors+=1 U.status="Event upgrade worker error: "..tostring(err):sub(1,140)
                U.nextAt=os.clock()+15
            end
            task.wait(1)
        end
    end)
end

do -- Source-confirmed: Charms_AttachToPet(charmUID, {petUID}).
    local C={status="Off",requests=0,verified=0,unconfirmed=0,errors=0,rejected=0,
        pending=nil,blocked=false,completed=0,nextAt=0}
    REQUEST_STATUS.charmAttach=C
    local function snapshot()
        local ok,data=pcall(function() return require(RS.Library.Client.Save).Get() end)
        if ok and type(data)=="table" and type(data.Inventory)=="table" then return data.Inventory end
    end
    local function count(inv,uid)
        local item=type(inv)=="table" and inv[uid]
        if type(item)~="table" then return 0 end
        local n=item._am==nil and 1 or tonumber(item._am)
        if type(n)~="number" or n~=n or n<0 or n%1~=0 then return nil end
        return n
    end
    local function pet(uid)
        local ok,entry=pcall(function() return require(RS.Library.Items.PetItem):Get(uid) end)
        if ok and entry and type(entry.GetCharmSlots)=="function" and type(entry.GetCharms)=="function" then return entry end
    end
    function C.options()
        local result={"Select charm"}
        local inv=snapshot()
        for uid,item in pairs(inv and inv.Charm or {}) do
            if type(uid)=="string" and type(item)=="table" and type(item.id)=="string" and
                count(inv.Charm,uid) and count(inv.Charm,uid)>0 then result[#result+1]=item.id end
        end
        table.sort(result)
        local unique={"Select charm"} local seen={}
        for _,name in ipairs(result) do
            if name~="Select charm" and not seen[name] then seen[name]=true unique[#unique+1]=name end
        end
        return unique
    end
    function C.eligibleReport()
        local inv=snapshot()
        if not inv or type(inv.Pet)~="table" then return "Pet inventory unavailable" end
        local ids={}
        for uid,entry in pairs(inv.Pet) do
            if type(uid)=="string" and type(entry)=="table" then ids[#ids+1]=uid end
        end
        table.sort(ids)
        local eligible=0
        for _,uid in ipairs(ids) do
            local obj=pet(uid)
            if obj then
                local ok,open=pcall(function()
                    local exotic=obj:IsHuge() or obj:IsTitanic() or obj:IsGargantuan()
                    return exotic and not obj:IsLocked() and obj:GetCharmSlots()>#obj:GetCharms()
                end)
                if ok and open then
                    eligible+=1
                    if eligible<=20 then print("[AERO CHARM] Eligible pet UID="..uid.." | id="..tostring(inv.Pet[uid].id)) end
                end
            end
        end
        return "Eligible Huge/Titanic/Gargantuan pets: "..eligible.."; first 20 UIDs printed to Console"
    end
    function C.summary()
        return string.format("%s | requests=%d confirmed=%d unconfirmed=%d errors=%d | session=%d/%d",
            C.status,C.requests,C.verified,C.unconfirmed,C.errors,C.completed,
            tonumber(State.CharmSessionLimit) or 1)
    end
    function C.tick()
        local now=os.clock()
        if not Flags.AutoAttachCharm and not C.pending then C.status="Off" return end
        if now<C.nextAt then return end
        if C.blocked then C.status="Outcome uncertain; no further attachments this session" return end
        local inv=snapshot()
        if C.pending then
            local p=C.pending
            local current=inv and count(inv.Charm,p.charmUID)
            local obj=pet(p.petUID)
            local ok,charms=pcall(function() return obj and #obj:GetCharms() end)
            if current and current<p.before and ok and type(charms)=="number" and charms>p.petCharms then
                C.verified+=1 C.completed+=1 C.pending=nil
                C.status="Observed charm consumed and pet charm count increased"
                C.nextAt=now+4
            elseif now>=p.deadline then
                C.unconfirmed+=1 C.pending=nil C.blocked=true Flags.AutoAttachCharm=false
                C.status="Attach result unconfirmed; stopped to avoid duplicate consumption"
            else C.status="Checking charm inventory and selected pet" end
            return
        end
        if not Flags.AutoAttachCharm then C.status="Off" return end
        local limit=math.clamp(math.floor(tonumber(State.CharmSessionLimit) or 1),1,10)
        if C.completed>=limit then Flags.AutoAttachCharm=false C.status="Session attachment limit reached" return end
        local chosen=State.CharmSelection
        local petUID=tostring(State.CharmPetUID or ""):match("^%s*(.-)%s*$")
        if not chosen or chosen=="Select charm" or not petUID or petUID=="" then
            C.status="Select a charm and enter a specific eligible pet UID" C.nextAt=now+5 return
        end
        if not inv or type(inv.Charm)~="table" or type(inv.Pet)~="table" then C.status="Inventory unavailable" C.nextAt=now+10 return end
        local raw=inv.Pet[petUID]
        if type(raw)~="table" then C.status="Target UID not found in owned pet inventory" C.nextAt=now+10 return end
        local obj=pet(petUID)
        local ok,eligible,slots,used=pcall(function()
            if not obj then return false end
            local slots=obj:GetCharmSlots() local charms=obj:GetCharms()
            local supported=obj:IsHuge() or obj:IsTitanic() or obj:IsGargantuan()
            return supported and not obj:IsLocked() and slots>#charms,slots,#charms
        end)
        if not ok or not eligible then C.status="Target pet is locked, unsupported or has no free charm slots" C.nextAt=now+10 return end
        local charms={}
        for uid,entry in pairs(inv.Charm) do
            if type(uid)=="string" and type(entry)=="table" and entry.id==chosen then
                local n=count(inv.Charm,uid)
                if n and n>0 then charms[#charms+1]=uid end
            end
        end
        table.sort(charms)
        if #charms==0 then C.status="Selected charm is not owned or has zero quantity" C.nextAt=now+10 return end
        local charmUID=charms[1]
        local before=count(inv.Charm,charmUID)
        if not before or before<1 or not isRunning() or not Flags.AutoAttachCharm then return end
        -- Protect against a stale user selection / a yielding inventory read.
        local fresh=snapshot() local current=pet(petUID)
        local okSlots,eligibleNow,newUsed=pcall(function()
            return current and not current:IsLocked() and current:GetCharmSlots()>#current:GetCharms(),
                current and #current:GetCharms()
        end)
        if not fresh or not fresh.Pet or not fresh.Pet[petUID] or
            count(fresh.Charm,charmUID)~=before or not okSlots or not eligibleNow or used~=newUsed then
            C.nextAt=now+3 return
        end
        local remote=Network:FindFirstChild("Charms_AttachToPet")
        if not remote or not remote:IsA("RemoteFunction") then
            C.status="Charms_AttachToPet unavailable" C.nextAt=now+15 return
        end
        C.pending={petUID=petUID,charmUID=charmUID,petCharms=used,before=before,deadline=os.clock()+14}
        C.requests+=1
        local sent,result=pcall(function() return remote:InvokeServer(charmUID,{petUID}) end)
        if not isRunning() then return end
        if not sent then C.errors+=1 elseif result==false then C.rejected+=1 end
        C.status="Requested selected charm attach; checking pet and inventory"
        C.nextAt=os.clock()+1
    end
    guardedSpawn("charm-attachments",function()
        while isRunning() do
            local ok,err=pcall(C.tick)
            if not ok then
                C.errors+=1 C.blocked=true Flags.AutoAttachCharm=false
                C.status="Charm worker error (stopped): "..tostring(err):sub(1,150)
            end
            task.wait(1)
        end
    end)
end

do -- Rank coordinator: captured Save.Goals + existing AutoQuest mappings, no rank-up exploit.
    local R={status="Off",ranksObserved=0,lastRank=nil,owns={},nextAt=0,unsupported={}}
    REQUEST_STATUS.rankComplete=R
    local function restore()
        for key in pairs(R.owns) do
            Flags[key]=false
        end
        R.owns={}
    end
    function R.summary()
        return R.status.." | observed rank increases="..R.ranksObserved.." | unsupported goals="..table.concat(R.unsupported,",")
    end
    function R.tick()
        local now=os.clock()
        if not Flags.AutoCompleteRank then
            if next(R.owns) then restore() end
            R.status="Off" return
        end
        if now<R.nextAt then return end
        R.nextAt=now+3
        local ok,data=pcall(function()return require(RS.Library.Client.Save).Get()end)
        if not ok or type(data)~="table" then R.status="Rank save unavailable" return end
        local rank=tonumber(data.Rank)
        if not rank then R.status="Rank unavailable" return end
        if R.lastRank and rank>R.lastRank then R.ranksObserved+=rank-R.lastRank end
        R.lastRank=rank
        local cap=math.clamp(math.floor(tonumber(State.MaxRank) or 40),1,100)
        if rank>=cap then
            Flags.AutoCompleteRank=false restore()
            R.status="Rank target reached: "..rank.." >= "..cap return
        end
        local goals=type(data.Goals)=="table" and data.Goals or activeGoals()
        local missing={}
        for _,goal in pairs(goals) do
            if type(goal)=="table" and tonumber(goal.Progress) and tonumber(goal.Amount) and
                goal.Progress<goal.Amount and not QUEST_NEED[goal.Type] then
                missing[tostring(goal.Type)]=true
            end
        end
        R.unsupported={}
        for id in pairs(missing) do R.unsupported[#R.unsupported+1]=id end
        table.sort(R.unsupported)
        if not Flags.AutoQuest then Flags.AutoQuest=true R.owns.AutoQuest=true end
        if not Flags.AutoClaimRank then Flags.AutoClaimRank=true R.owns.AutoClaimRank=true end
        R.status="Rank "..rank.." / target "..cap.."; quest worker and verified reward claims enabled"
        if #R.unsupported>0 then R.status=R.status.." | unmapped goal types: "..table.concat(R.unsupported,",") end
    end
    guardedSpawn("rank-completion",function()
        while isRunning() do
            local ok,err=pcall(R.tick)
            if not ok then R.status="Rank coordinator error: "..tostring(err):sub(1,140) R.nextAt=os.clock()+8 end
            task.wait(2)
        end
    end)
    onCleanup(restore)
end

do -- Balloon list and pop events verified; hit payload NOT confirmed in source.
    local B={status="Off",polls=0,active=0,requests=0,observedPops=0,errors=0,
        pending=nil,attempted={},nextAt=0,blocked=false}
    REQUEST_STATUS.balloons=B
    function B.summary()
        return string.format("%s | nearby=%d requests=%d observed-world-pops=%d errors=%d | mode=%s",
            B.status,B.active,B.requests,B.observedPops,B.errors,tostring(State.BalloonMode))
    end
    local okNetwork,network=pcall(function()return require(RS.Library.Client.Network)end)
    if okNetwork and network and type(network.Fired)=="function" then
        local okSignal,signal=pcall(network.Fired,"BalloonGifts_BalloonPopped")
        if okSignal and signal and type(signal.Connect)=="function" then
            trackConnection(signal:Connect(function(id)
                B.observedPops+=1
                if B.pending and tostring(B.pending.id)==tostring(id) then
                    B.status="Balloon popped event observed after ID request (causation not proven)"
                    B.pending=nil B.nextAt=os.clock()+3
                end
            end))
        end
    end
    function B.tick()
        local now=os.clock()
        if not Flags.AutoPopBalloons and not B.pending then B.status="Off" return end
        if now<B.nextAt then return end
        if B.pending then
            if now>=B.pending.deadline then
                B.status="No pop acknowledgement for ID; will not repeat this ID"
                B.pending=nil
            else B.status="Waiting for balloon pop event" end
            return
        end
        if not Flags.AutoPopBalloons then B.status="Off" return end
        local root=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then B.status="Waiting for character" B.nextAt=now+5 return end
        local remote=Network:FindFirstChild("BalloonGifts_GetActiveBalloons")
        if not remote or not remote:IsA("RemoteFunction") then B.status="Balloon query unavailable" B.nextAt=now+15 return end
        B.polls+=1
        local ok,result=pcall(function() return remote:InvokeServer() end)
        if not ok or type(result)~="table" then
            B.errors+=1 B.status="Active balloon query failed" B.nextAt=os.clock()+12 return
        end
        local candidates={}
        for _,rec in pairs(result) do
            if type(rec)=="table" and (type(rec.Id)=="string" or type(rec.Id)=="number") and
                typeof(rec.Position)=="Vector3" then
                local dist=(rec.Position-root.Position).Magnitude
                if dist<=130 and not B.attempted[tostring(rec.Id)] then
                    candidates[#candidates+1]={id=rec.Id,distance=dist}
                end
            end
        end
        B.active=#candidates
        if State.BalloonMode~="Experimental ID hit" then
            B.status="Observe only: "..#candidates.." nearby balloons (no hits sent)"
            B.nextAt=os.clock()+6 return
        end
        table.sort(candidates,function(a,b)return a.distance<b.distance end)
        if #candidates==0 then B.status="No nearby unattempted balloon IDs" B.nextAt=os.clock()+6 return end
        local hit=Network:FindFirstChild("BalloonGifts_BalloonHit")
        if not hit or not hit:IsA("RemoteEvent") then B.status="Balloon hit event missing" B.nextAt=now+15 return end
        if not isRunning() or not Flags.AutoPopBalloons then return end
        local chosen=candidates[1]
        B.attempted[tostring(chosen.id)]=true
        B.pending={id=chosen.id,deadline=os.clock()+10}
        B.requests+=1
        -- Experimental request: source confirms event existence but not arg signature.
        -- One request per ID per script execution, and no teleports or spam loops.
        local sent,err=pcall(function() hit:FireServer(chosen.id) end)
        if not sent then B.errors+=1 B.status="Experimental balloon hit error: "..tostring(err):sub(1,120) end
        B.nextAt=os.clock()+1
    end
    guardedSpawn("balloon-gifts",function()
        while isRunning() do
            local ok,err=pcall(B.tick)
            if not ok then B.errors+=1 B.status="Balloon observer error: "..tostring(err):sub(1,140) B.nextAt=os.clock()+10 end
            task.wait(1)
        end
    end)
end

-- P24.4: Bounded read-only source acquisition for missing PS99 mechanics.
-- Never invokes a remote, auto-equips charms, makes purchases, or executes
-- downloaded code. The user can export captured client source for a later build.
do
    local C={status="Not started",running=false,found=0,decompiled=0,failed=0,bytes=0,
        filename="AERO_PS99_Mechanic_Sources_v8_2_81.txt"}
    REQUEST_STATUS.mechCapture=C
    local terms={"spin","wheel","upgrad","charm","balloon","rank","quest","goal"}
    function C.capture()
        if C.running then return false,"Source capture already running" end
        if not isRunning() then return false,"Script unloaded" end
        C.running=true C.status="Collecting client module names (read-only)"
        spawnTask(function()
            local ok,err=xpcall(function()
                local lines={"AERO PS99 v8.2.84 — Read-only mechanic source capture",
                    "Features: wheel / upgrades / charms / rank goals / balloons",
                    "No remotes invoked; no upgrades or charms consumed.",
                    "Date: "..os.date("!%Y-%m-%dT%H:%M:%SZ"),""}
                local net=RS:FindFirstChild("Network")
                lines[#lines+1]="=== Relevant remote names (existence only) ==="
                if net then
                    for _,remote in ipairs(net:GetChildren()) do
                        local lower=remote.Name:lower()
                        for _,term in ipairs(terms) do
                            if lower:find(term,1,true) then
                                lines[#lines+1]=remote.Name.." | "..remote.ClassName
                                break
                            end
                        end
                    end
                else lines[#lines+1]="ReplicatedStorage.Network not available" end
                lines[#lines+1]="\n=== Relevant ModuleScripts and LocalScripts ==="
                local matches={}
                local roots={RS:FindFirstChild("Library"),LocalPlayer:FindFirstChild("PlayerScripts")}
                local scanned=0
                for _,root in ipairs(roots) do
                    if root then
                        for _,obj in ipairs(root:GetDescendants()) do
                            if not isRunning() then return end
                            scanned=scanned+1
                            if (obj:IsA("ModuleScript") or obj:IsA("LocalScript")) then
                                local lower=(obj.Name.." "..obj:GetFullName()):lower()
                                for _,term in ipairs(terms) do
                                    if lower:find(term,1,true) then matches[#matches+1]=obj break end
                                end
                            end
                            if scanned%180==0 then task.wait() end
                            if scanned>=15000 then break end
                        end
                    end
                    if scanned>=15000 then break end
                end
                table.sort(matches,function(a,b)return a:GetFullName()<b:GetFullName()end)
                C.found=#matches
                C.status="Capturing source for up to 28 relevant scripts"
                local method=type(decompile)=="function" and decompile or nil
                -- Balance candidates across mechanics; avoid letting dozens of
                -- similarly named rank modules crowd out balloons or charms.
                local selected,seen={},{}
                for _,term in ipairs(terms) do
                    local count=0
                    for _,candidate in ipairs(matches) do
                        local name=candidate:GetFullName():lower()
                        if not seen[candidate] and name:find(term,1,true) then
                            seen[candidate]=true
                            selected[#selected+1]=candidate
                            count=count+1
                        end
                        if count>=3 then break end
                    end
                end
                local limit=math.min(#selected,28)
                for i=1,limit do
                    if not isRunning() then return end
                    local obj=selected[i]
                    lines[#lines+1]="\n--- "..obj:GetFullName().." ["..obj.ClassName.."] ---"
                    if method then
                        local success,result=pcall(method,obj)
                        if success and type(result)=="string" then
                            local clipped=result:sub(1,18000)
                            lines[#lines+1]=clipped
                            if #clipped<#result then lines[#lines+1]="[Source truncated for mobile]" end
                            C.decompiled=C.decompiled+1
                        else
                            C.failed=C.failed+1
                            lines[#lines+1]="[Decompiler unavailable for this script: "..tostring(result):sub(1,140).."]"
                        end
                    else
                        lines[#lines+1]="[decompile API unavailable; path and remote names only]"
                    end
                    if i%2==0 then task.wait() end
                end
                if #matches>limit then lines[#lines+1]="\n[Additional matching scripts not dumped: "..(#matches-limit).."; capture is bounded]" end
                local report=table.concat(lines,"\n")
                C.bytes=#report
                local exported=false
                if type(writefile)=="function" then exported=pcall(writefile,C.filename,report) end
                if not exported and type(setclipboard)=="function" then
                    exported=pcall(setclipboard,report:sub(1,100000))
                    if exported then C.status="Copied report (first 100 KB) to clipboard" end
                end
                if not exported then
                    C.status="Capture completed; no file or clipboard API"
                    print("[AERO SOURCE] "..report:sub(1,12000))
                elseif C.status:find("Copied",1,true)==nil then
                    C.status="Saved "..C.filename
                end
                print(string.format("[AERO SOURCE] %s | matches=%d decompiled=%d errors=%d bytes=%d",
                    C.status,C.found,C.decompiled,C.failed,C.bytes))
            end,debug.traceback)
            if not ok then C.failed=C.failed+1 C.status="Capture error: "..tostring(err):sub(1,170) warn("[AERO SOURCE] "..C.status) end
            C.running=false
        end)
        return true,"Read-only feature-source capture started; check the Diagnostics tab"
    end
end

local function giftTick()
    if REQUEST_STATUS.lootboxes and REQUEST_STATUS.lootboxes.pending then
        GiftStatus.text="Waiting for lootbox opening" return
    end
    if not Flags.AutoOpenGifts and not giftPending then
        GiftStatus.text="Auto gifts idle"
        return
    end
    if State.GiftSelection=="" then State.GiftSelection="All" end
    local rs=game:GetService("ReplicatedStorage")
    local network=rs:FindFirstChild("Network")
    local remote=network and network:FindFirstChild("GiftBag_Open")
    local client=rs:FindFirstChild("Library") and rs.Library:FindFirstChild("Client")
    local saveModule=client and client:FindFirstChild("Save")
    if not saveModule then GiftStatus.text="Save unavailable" return end
    local okSave,save=pcall(require,saveModule)
    if not okSave or type(save)~="table" then GiftStatus.text="Save unavailable" return end
    local okData,data=pcall(save.Get)
    if not okData or type(data)~="table" or type(data.Inventory)~="table" then
        GiftStatus.text="Inventory unavailable" return
    end
    local inv=data.Inventory
    local now=os.clock()
    if giftPending then
        local pending=giftPending
        local amount=giftAmount(inv,pending.id)
        local decrease=math.max(0,pending.before-amount)
        local state=GiftStatus.batchState[pending.id]
        -- Give client inventory replication a short settling window. A partial
        -- observation must not be mistaken for the remote's maximum batch size.
        if decrease>=pending.requested or (decrease>0 and now-pending.sent>=0.9) then
            GiftStatus.metrics.verified+=1
            GiftStatus.metrics.items+=decrease -- observed delta only
            state.failures=0
            state.streak=(state.streak or 0)+1
            state.lastReason=decrease>=pending.requested and "inventory decrease observed" or "partial inventory decrease"
            if decrease>=pending.requested then
                state.maxVerified=math.max(state.maxVerified,pending.requested)
                state.next=math.min(state.ceiling or 100,math.max(1,pending.requested))
                if state.streak>=2 then
                    state.next=math.min(state.ceiling or 100,math.max(1,pending.requested*2))
                    state.streak=0
                end
            else
                GiftStatus.metrics.short+=1
                state.streak=0
                state.next=math.max(1,math.min(decrease,state.maxVerified>0 and state.maxVerified or decrease))
            end
            state.interval=math.max(0.3,(state.interval or 0.3)*0.95)
            state.retryAt=now+state.interval
            GiftStatus.text="Opened "..pending.id.."; observed "..decrease.." / requested "..pending.requested.."; remaining "..amount
            giftLog(GiftStatus.text)
            giftPending=nil
            giftNext=now+0.15
        elseif now-pending.sent<4 then
            GiftStatus.text="Checking opening: "..pending.id
            return
        else
            GiftStatus.metrics.timeouts+=1
            state.failures=(state.failures or 0)+1
            state.streak=0
            state.lastReason="inventory confirmation timed out (outcome unknown)"
            state.next=math.max(1,math.floor(pending.requested/2))
            state.retryAt=now+math.min(60,8*2^(math.min(state.failures-1,3)))
            GiftStatus.metrics.backoffs+=1
            GiftStatus.text="No opening confirmed: "..pending.id.." (cooldown)"
            giftLog(GiftStatus.text)
            giftPending=nil
            giftNext=now+0.15
        end
    end
    if not isRunning() or not Flags.AutoOpenGifts then return end
    if now<giftNext then return end
    for offset=1,#giftSpecs do
        local i=(giftCursor+offset-1)%#giftSpecs+1
        local spec=giftSpecs[i]
        if selectedName(State.GiftSelection,spec.id)
            and not (spec.method=="lootbox" and REQUEST_STATUS.lootboxes and REQUEST_STATUS.lootboxes.blocked[spec.id]) then
            local amount=giftAmount(inv,spec.id)
            if amount>0 then
                giftCursor=i
                local state=GiftStatus.batchState[spec.id]
                if not state then
                    state={next=1,maxVerified=0,retryAt=0,failures=0,ceiling=100,streak=0,interval=0.3}
                    GiftStatus.batchState[spec.id]=state
                end
                if now<(state.retryAt or 0) then
                    GiftStatus.metrics.delayed+=1
                    -- A failed gift type must not block other ready gift types.
                    continue
                end
                -- GiftBag_Open only receives quantity for known quantity-aware specs.
                local quantityAware=spec.method=="lootbox" or spec.quantity==true
                local requested=quantityAware and math.min(amount,state.next,state.ceiling or 100,100) or 1
                -- Save/module reads above may yield: recheck ownership at dispatch.
                if REQUEST_STATUS.lootboxes and REQUEST_STATUS.lootboxes.pending then return end
                giftNext=now+0.3
                GiftStatus.metrics.requests+=1
                -- Record before yielding so disable/re-enable cannot discard attribution.
                giftPending={id=spec.id,before=amount,requested=requested,sent=os.clock()}
                local ok,result=pcall(function()
                    if spec.method=="lootbox" then
                        local signal=require(rs.Library.Signal)
                        return signal.Invoke("Lootbox_RequestOpen",spec.id,requested)
                    end
                    if not remote or not remote:IsA("RemoteFunction") then
                        error("GiftBag_Open unavailable")
                    end
                    if spec.quantity then return remote:InvokeServer(spec.id,requested) end
                    return remote:InvokeServer(spec.id)
                end)
                if not isRunning() then return end
                if ok and result~=false then
                    GiftStatus.text="Requested "..requested.." x "..spec.id.."; verifying inventory"
                    giftLog(GiftStatus.text)
                else
                    if ok then GiftStatus.metrics.rejected+=1 else GiftStatus.metrics.errors+=1 end
                    state.lastReason=ok and "remote returned false (reason unavailable)" or ("invocation error: "..tostring(result):sub(1,240))
                    -- Even a false response/error may follow a side effect. Reconcile
                    -- the pre-call snapshot before allowing another request.
                    state.streak=0
                    state.interval=math.min(5,(state.interval or 0.3)*1.5)
                    if ok and requested>1 then state.ceiling=math.min(state.ceiling or 100,math.max(1,math.floor(requested/2))) end
                    state.failures=(state.failures or 0)+1
                    state.next=math.max(1,math.floor(requested/2))
                    state.retryAt=os.clock()+math.min(30,2^(math.min(state.failures,4)))
                    GiftStatus.metrics.backoffs+=1
                    GiftStatus.text="Open response: "..spec.id.." | "..state.lastReason.."; checking inventory before retry"
                    giftLog(GiftStatus.text)
                    giftNext=os.clock()+0.15
                end
                return
            end
        end
    end
    GiftStatus.text="No gift ready (empty, unsupported, or cooling down)"
    -- Poll cooldowns without making network requests.
    giftNext=now+1
end
guardedSpawn("auto-gift-worker",function()
    while isRunning() do
        local ok,err=pcall(giftTick)
        if not ok then GiftStatus.text="Gift worker error: "..tostring(err) giftLog(GiftStatus.text) end
        -- Check pending inventory confirmations frequently, but keep the
        -- existing giftNext/retry gates for actual remote invocations.
        task.wait(Flags.AutoOpenGifts and 0.2 or 2)
    end
end)

-- P22.4 local diagnostic snapshots: alternate slots preserve the previous
-- snapshot if a write is interrupted. Forced app termination cannot run cleanup.
do
    local sequence=0
    local warned=false
    local session=tostring(os.time()).."-"..tostring(myGeneration)
    local function saveDiagnostics(reason)
        if type(writefile)~="function" then
            if not warned then warned=true; warn("[AERO P22.5] Automatic diagnostics unavailable: writefile missing") end
            return false,"writefile unavailable"
        end
        local nextSequence=sequence+1
        local snapshot={schema=2,build="v8.2.84 P24.4",session=session,sequence=nextSequence,
            userId=LocalPlayer.UserId,placeId=game.PlaceId,jobId=game.JobId,
            savedAt=os.time(),reason=reason or "manual",clock=os.clock()}
        local ok,err=pcall(function()
            local rewards=_G.AERO_PS99_P22_Report
            local opening=_G.AERO_PS99_P223_GiftReport
            if type(rewards)=="function" then snapshot.rewards=rewards(true) end
            if type(opening)=="function" then snapshot.opening=opening(true) end
            if REQUEST_STATUS.verification then
                snapshot.features=REQUEST_STATUS.verification.health()
                snapshot.fullReport=REQUEST_STATUS.verification.lines()
            end
            if REQUEST_STATUS.crafting then
                local c=REQUEST_STATUS.crafting
                snapshot.crafting={requests=c.requests,verified=c.verified,netReconciled=c.netReconciled or 0,
                    errors=c.errors,status=c.status,lastFusion=c.lastFusion,lastFusionError=c.lastFusionError}
            end
            snapshot.rewardClaims={}
            for _,key in ipairs({"rankClaims","foreverClaims"}) do
                local c=REQUEST_STATUS[key] or {}
                snapshot.rewardClaims[key]={requests=c.requests or 0,verified=c.verified or 0,unconfirmed=c.unconfirmed or 0,status=c.status}
            end
            local l=REQUEST_STATUS.lootboxes
            snapshot.spinWheel={status=REQUEST_STATUS.spin.status,requests=REQUEST_STATUS.spin.requests,
                accepted=REQUEST_STATUS.spin.accepted,verified=REQUEST_STATUS.spin.verified,
                unconfirmed=REQUEST_STATUS.spin.unconfirmed,blocked=REQUEST_STATUS.spin.blocked}
            snapshot.sourceCapture={status=REQUEST_STATUS.mechCapture.status,found=REQUEST_STATUS.mechCapture.found,
                decompiled=REQUEST_STATUS.mechCapture.decompiled,failed=REQUEST_STATUS.mechCapture.failed}
            snapshot.lootboxes={status=l.status,requests=l.requests,verified=l.verified,items=l.items,
                unconfirmed=l.unconfirmed,rejected=l.rejected,errors=l.errors,blocked=l.blocked,pending=l.pending}
            snapshot.evidence=REQUEST_STATUS.evidence
            snapshot.health={workers=workerDiagnosticSummary(),errors=WORKER_DIAGNOSTICS.errors,
                travel=REQUEST_STATUS.travelStatus or "idle",worldTravelBusy=REQUEST_STATUS.worldTravelBusy==true,
                batch=REQUEST_STATUS.automation.summary()}
            local encoded=HttpService:JSONEncode(snapshot)
            local slot=nextSequence%2==1 and "A" or "B"
            writefile("AERO_PS99_P224_Diagnostics_"..slot..".json",encoded)
            sequence=nextSequence
        end)
        if not ok then
            if not warned then warned=true; warn("[AERO P22.5] Diagnostic save failed: "..tostring(err):sub(1,180)) end
            return false,tostring(err)
        end
        warned=false
        return true,"saved sequence "..sequence
    end
    local function report()
        _G.AERO_PS99_P22_Report()
        _G.AERO_PS99_P223_GiftReport()
        local ok,message=saveDiagnostics("manual report")
        print("[AERO P22.5] Diagnostic export: "..tostring(ok).." | "..message)
        return ok,message
    end
    _G.AERO_PS99_P225_Report=report
    _G.AERO_PS99_P224_Report=report
    onCleanup(function()
        saveDiagnostics("cleanup")
        if _G.AERO_PS99_P224_Report==report then _G.AERO_PS99_P224_Report=nil end
        if _G.AERO_PS99_P225_Report==report then _G.AERO_PS99_P225_Report=nil end
    end)
    guardedSpawn("p224-diagnostic-save",function()
        while isRunning() do
            saveDiagnostics("periodic")
            task.wait(30)
        end
    end)
    print("[AERO P22.5] READY | spaced free-gift checks | diagnostic snapshots every 30s")
end

-- Auto Flags: verified FlexibleFlagCmds.Consume(name, inventoryUID, amount).
-- Follows the player's normal zone. Instances require separate context validation.
local AutoFlags=(function()
    local U={names={},catalogVersion=0,nextCatalog=0,context=nil,since=0,nextAttempt=0,pending=nil,lastLog=nil}
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    local function enabled() return isRunning() and Flags.AutoUseFlag end
    function U.log(message)
        if U.lastLog~=message then U.lastLog=message print("[AERO FLAGS] "..tostring(message)) end
    end
    function U.misc()
        local client=RS.Library.Client
        U.save=U.save or require(client.Save)
        local data=U.save.Get()
        local misc=data and data.Inventory and data.Inventory.Misc
        return type(misc)=="table" and misc or nil
    end
    function U.inventory(name,misc)
        local chosen,largest,total=nil,0,0
        for uid,item in pairs(misc or {}) do
            if type(uid)=="string" and type(item)=="table" and item.id==name then
                local amount=item._am==nil and 1 or tonumber(item._am)
                if finite(amount) and amount>=1 then
                    amount=math.floor(amount) total+=amount
                    if amount>largest then chosen,largest=uid,amount end
                end
            end
        end
        return chosen,largest,total
    end
    function U.refreshCatalog()
        local misc=U.misc()
        if not misc then return nil end
        local names,seen={},{}
        for _,item in pairs(misc) do
            if type(item)=="table" and type(item.id)=="string" and item.id:sub(-5)==" Flag" then
                local amount=item._am==nil and 1 or tonumber(item._am)
                if finite(amount) and amount>0 and not seen[item.id] then
                    seen[item.id]=true names[#names+1]=item.id
                end
            end
        end
        table.sort(names)
        if table.concat(names,"\0")~=table.concat(U.names,"\0") then U.names=names U.catalogVersion+=1 end
        U.nextCatalog=os.clock()+10
        return misc
    end
    function U.options() return table.clone(U.names) end
    function U.getContext()
        U.map=U.map or require(RS.Library.Client.MapCmds)
        if U.map.GetCurrentInstanceInfo() then return nil,"Waiting outside instances" end
        local zone=U.map.GetCurrentZone()
        if type(zone)~="string" or zone=="" then return nil,"Waiting for a farming zone" end
        return zone
    end
    function U.capacity(name)
        U.flags=U.flags or require(RS.Library.Client.FlexibleFlagCmds)
        local n=U.flags.GetMaxPlaceAutomaticContext(name)
        if not finite(n) then return nil end
        return math.max(0,math.floor(n))
    end
    function U.tick()
        local now=os.clock()
        local misc
        if now>=U.nextCatalog then misc=U.refreshCatalog() end
        if not enabled() then U.context=nil U.pending=nil return end
        local name=State.FlagSelection
        local zone,reason=U.getContext()
        if not zone then U.context=nil U.pending=nil U.log(reason) return end
        local context=zone.."\0"..tostring(name)
        if context~=U.context then
            U.context=context U.since=now U.nextAttempt=now+3 U.pending=nil
            U.log("Zone: "..zone.." | Selected: "..tostring(name)) return
        end
        if not enabled() then return end
        if U.pending then
            local p=U.pending
            local _,_,amount=U.inventory(name,misc or U.misc())
            local after=U.capacity(name)
            if not enabled() or U.getContext()~=zone then return end
            if amount<=p.before-p.quantity or (after and after<=p.capacity-p.quantity) then
                U.log("Refill verified: "..p.quantity.." "..name.." | Zone: "..zone)
                U.pending=nil
            elseif now>=p.deadline then
                U.log("Placement accepted; update not confirmed - waiting before retry")
                U.pending=nil U.nextAttempt=now+60
            end
            return
        end
        if now<U.nextAttempt or now-U.since<3 then return end
        if type(name)~="string" or name=="" or name=="All" then U.log("Select one owned flag type") return end
        local capacity=U.capacity(name)
        if not capacity then U.nextAttempt=now+15 U.log("Placement capacity unavailable") return end
        -- Native capacity returns zero for a different active flag type too.
        if capacity<1 then U.nextAttempt=now+15 U.log("No available capacity in "..zone.."; waiting") return end
        local uid,stack,total=U.inventory(name,misc or U.misc())
        if not uid then U.nextAttempt=now+15 U.log("No "..name.." in inventory") return end
        local quantity=math.min(capacity,stack)
        if not enabled() or State.FlagSelection~=name or U.getContext()~=zone then return end
        -- Consume enforces the game's actual placement restrictions. Do not infer
        -- its configuration source from Save.Get().config (not established).
        U.nextAttempt=os.clock()+30
        local accepted,message=U.flags.Consume(name,uid,quantity)
        if not enabled() or State.FlagSelection~=name then return end
        if accepted==true then
            U.pending={before=total,quantity=quantity,capacity=capacity,deadline=os.clock()+6}
            U.log("Placement accepted: "..quantity.." "..name.." | Zone: "..zone)
        else
            U.nextAttempt=os.clock()+30
            U.log("Placement deferred: "..tostring(message or accepted).."; retrying after cooldown")
        end
    end
    onCleanup(function() U.pending=nil U.context=nil end)
    return U
end)()

-- Shut down known standalone flag tests so they do not place alongside AERO.
do
    local env=type(getgenv)=="function" and getgenv() or _G
    for version=6,12 do
        local test=env["AERO_FlagsV"..version]
        if type(test)=="table" then test.Running=false end
    end
end
guardedSpawn("auto-flags",function()
    while isRunning() do
        local ok,err=pcall(AutoFlags.tick)
        if not ok then AutoFlags.nextAttempt=os.clock()+30 AutoFlags.nextCatalog=os.clock()+10 AutoFlags.log("Waiting after error: "..tostring(err)) end
        task.wait(1)
    end
end)

-- Auto Sprinklers: native, live-verified Consume(name, inventoryUID, quantity).
local AutoSprinklers=(function()
    local U={context=nil,since=0,nextAttempt=0,pending=nil,lastLog=nil}
    local NAME="Breakable Sprinkler"
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    local function enabled() return isRunning() and Flags.AutoUseSprinkler end
    function U.log(message)
        if U.lastLog~=message then U.lastLog=message print("[AERO SPRINKLER] "..message) end
    end
    function U.contextNow()
        local client=RS.Library.Client
        U.map=U.map or require(client.MapCmds)
        U.instances=U.instances or require(client.InstancingCmds)
        U.ff=U.ff or require(client.FFlags)
        if U.instances.IsInInstance() then return nil,"Waiting outside instances" end
        if not U.ff.Get(U.ff.Keys.Item_Sprinklers) then return nil,"Sprinklers disabled by game" end
        local zone=U.map.GetCurrentZone()
        if type(zone)~="string" or zone=="" then return nil,"Waiting for a zone" end
        if not U.map.IsInDottedBox() then return nil,"Waiting inside the dotted placement area" end
        return zone
    end
    function U.capacity(zone)
        U.cmd=U.cmd or require(RS.Library.Client.SprinklerCmds)
        local n=U.cmd.GetMaxPlace(NAME,zone)
        return finite(n) and math.max(0,math.floor(n)) or nil
    end
    function U.inventory()
        U.save=U.save or require(RS.Library.Client.Save)
        local data=U.save.Get()
        local misc=data and data.Inventory and data.Inventory.Misc
        local chosen,largest,total=nil,0,0
        for uid,item in pairs(type(misc)=="table" and misc or {}) do
            if type(uid)=="string" and type(item)=="table" and item.id==NAME then
                local count=item._am==nil and 1 or tonumber(item._am)
                if finite(count) and count>=1 then
                    count=math.floor(count) total+=count
                    if count>largest then chosen,largest=uid,count end
                end
            end
        end
        return chosen,largest,total
    end
    function U.tick()
        if not enabled() then U.context=nil U.pending=nil return end
        local now=os.clock()
        if now<U.nextAttempt and not U.pending then return end
        local zone,reason=U.contextNow()
        if not zone then U.context=nil U.pending=nil U.log(reason) return end
        if zone~=U.context then
            U.context=zone U.since=now U.pending=nil
            U.log("Zone: "..zone) return
        end
        if U.pending then
            local p=U.pending
            local _,_,total=U.inventory()
            local after=U.capacity(zone)
            if not enabled() or U.contextNow()~=zone then U.pending=nil U.context=nil return end
            if total<=p.total-p.quantity or (after and after<=p.capacity-p.quantity) then
                U.pending=nil U.log("Refill verified: "..p.quantity.." | Zone: "..zone)
            elseif now>=p.deadline then
                U.pending=nil U.nextAttempt=now+60
                U.log("Accepted; update unconfirmed - waiting before retry")
            end
            return
        end
        if now-U.since<3 then return end
        local capacity=U.capacity(zone)
        if not capacity or capacity<1 then U.nextAttempt=now+15 U.log("No available capacity; waiting") return end
        local uid,stack,total=U.inventory()
        if not uid then U.nextAttempt=now+30 U.log("No Breakable Sprinklers remaining") return end
        local quantity=math.min(capacity,stack)
        if not enabled() or U.contextNow()~=zone then U.context=nil return end
        U.nextAttempt=os.clock()+30
        local accepted,message=U.cmd.Consume(NAME,uid,quantity)
        if not enabled() then return end
        if accepted==true then
            U.log("Server accepted: "..quantity.." | Zone: "..zone)
            if U.contextNow()==zone then
                U.pending={total=total,quantity=quantity,capacity=capacity,deadline=os.clock()+6}
            else U.context=nil end
        else
            U.log("Placement deferred: "..tostring(message or accepted))
        end
    end
    onCleanup(function() U.context=nil U.pending=nil end)
    return U
end)()
do
    local env=type(getgenv)=="function" and getgenv() or _G
    local old=env.AERO_SprinklerV4
    if type(old)=="table" then old.Enabled=false old.Running=false end
end
guardedSpawn("auto-sprinklers",function()
    while isRunning() do
        local ok,err=pcall(AutoSprinklers.tick)
        if not ok then AutoSprinklers.nextAttempt=os.clock()+30 AutoSprinklers.pending=nil AutoSprinklers.log("Waiting after error: "..tostring(err)) end
        task.wait(1)
    end
end)

-- Native TNT requests verified live; only Misc inventory is counted.
local AutoTNT=(function()
    local U={cursor=0,globalNext=0,pending=nil,context=nil,since=0,lastLog=nil}
    local specs={
        {id="TNT",remote="TNT_Consume",flag="AutoUseTNT",delay="TNTDelay",nextAttempt=0},
        {id="TNT Crate",remote="TNT_Crate_Consume",flag="AutoUseTNTCrate",delay="TNTCrateDelay",nextAttempt=0},
    }
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    function U.log(s) if U.lastLog~=s then U.lastLog=s print("[AERO TNT] "..s) end end
    function U.count(id)
        U.save=U.save or require(RS.Library.Client.Save)
        local data=U.save.Get()
        local items=data and data.Inventory and data.Inventory.Misc
        if type(items)~="table" then return nil end
        local total=0
        for _,item in pairs(items) do
            if type(item)=="table" and item.id==id then
                local n=item._am==nil and 1 or tonumber(item._am)
                if finite(n) and n>=1 then total+=math.floor(n) end
            end
        end
        return total
    end
    function U.zone()
        U.map=U.map or require(RS.Library.Client.MapCmds)
        U.instances=U.instances or require(RS.Library.Client.InstancingCmds)
        if U.instances.IsInInstance() or not U.map.IsInDottedBox() then return nil end
        local zone=U.map.GetCurrentZone()
        return type(zone)=="string" and zone~="" and zone or nil
    end
    function U.tick()
        if not isRunning() then return end
        local now=os.clock()
        -- Resolve an outstanding request even if its toggle was disabled.
        if U.pending then
            local p=U.pending
            local after=U.count(p.spec.id)
            if after and after<p.before then
                U.log("Consumption verified: "..p.spec.id.." | "..p.before.." -> "..after)
                U.pending=nil
            elseif now>=p.deadline then
                p.spec.nextAttempt=now+60 U.pending=nil
                U.log("Consumption unconfirmed: "..p.spec.id.."; waiting before retry")
            end
            return
        end
        if not (Flags.AutoUseTNT or Flags.AutoUseTNTCrate) then U.context=nil return end
        if now<U.globalNext then return end
        local zone=U.zone()
        if not zone then U.context=nil U.log("Waiting inside a valid dotted farming area") return end
        if zone~=U.context then U.context=zone U.since=now return end
        if now-U.since<3 then return end
        for step=1,#specs do
            local index=(U.cursor+step-1)%#specs+1
            local spec=specs[index]
            if Flags[spec.flag] and now>=spec.nextAttempt then
                local before=U.count(spec.id)
                if not before or before<1 then
                    spec.nextAttempt=now+30 U.log("No available "..spec.id)
                else
                    local delay=tonumber(State[spec.delay])
                    delay=finite(delay) and math.clamp(delay,0.5,60) or 5
                    U.network=U.network or require(RS.Library.Client.Network)
                    if not isRunning() or not Flags[spec.flag] or U.zone()~=zone then U.context=nil return end
                    U.cursor=index U.globalNext=os.clock()+0.5
                    -- Set cooldown before the yielding invocation, including errors.
                    spec.nextAttempt=os.clock()+30
                    local ok,accepted,message=pcall(U.network.Invoke,spec.remote)
                    if not isRunning() then return end
                    U.globalNext=os.clock()+0.5
                    if ok and accepted==true then
                        spec.nextAttempt=os.clock()+delay
                        U.pending={spec=spec,before=before,deadline=os.clock()+8}
                        U.log("Server accepted: "..spec.id.." | Zone: "..zone)
                    else
                        spec.nextAttempt=os.clock()+30
                        U.log("Placement deferred: "..spec.id.." | "..tostring(message or accepted))
                    end
                    return
                end
            end
        end
    end
    onCleanup(function() U.pending=nil U.context=nil end)
    return U
end)()
do
    local env=type(getgenv)=="function" and getgenv() or _G
    local old=env.AERO_TNT_V5
    if type(old)=="table" then old.AutoTNT=false old.AutoCrate=false old.Running=false end
end
guardedSpawn("auto-tnt",function()
    while isRunning() do
        local ok,err=pcall(AutoTNT.tick)
        if not ok then AutoTNT.globalNext=os.clock()+30 AutoTNT.log("Waiting after error: "..tostring(err)) end
        task.wait(0.5)
    end
end)

-- Native batch crafting; source AND complete higher-tier output verified.
local AutoUpgrades=(function()
    local U={nextAttempt=0,pending=nil,cursor=0,completed=0,lastLog=nil,reason=nil}
    local specs={
        {kind="Potion",flag="AutoUpgradePotions",required="CalcPotionsPerTierRequired",cost="CalcPotionUpgradeCost",remote="UpgradePotionsMachine_Activate"},
        {kind="Enchant",flag="AutoUpgradeEnchants",required="CalcEnchantsPerTierRequired",cost="CalcEnchantUpgradeCost",remote="UpgradeEnchantsMachine_Activate"},
    }
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    local function setting(key,default,lo,hi)
        local n=tonumber(State[key]) return finite(n) and math.clamp(n,lo,hi) or default
    end
    function U.log(s) REQUEST_STATUS.automation.note("upgrades",s) if U.lastLog~=s then U.lastLog=s print("[AERO UPGRADES] "..s) end end
    function U.count(items,uid)
        local entry=items and items[uid]
        if type(entry)~="table" then return 0 end
        local n=entry._am==nil and 1 or tonumber(entry._am)
        return finite(n) and math.max(0,math.floor(n)) or 0
    end
    function U.results(items,id,tier)
        local total=0
        for uid,entry in pairs(items or {}) do
            if type(entry)=="table" and entry.id==id and (tonumber(entry.tn) or 1)>tier then total+=U.count(items,uid) end
        end
        return total
    end
    function U.modules()
        local lib=RS.Library
        U.save=U.save or require(lib.Client.Save)
        U.currency=U.currency or require(lib.Client.CurrencyCmds)
        U.balance=U.balance or require(lib.Balancing)
        U.network=U.network or require(lib.Client.Network)
        U.classes=U.classes or {Potion=require(lib.Items.PotionItem),Enchant=require(lib.Items.EnchantItem)}
    end
    function U.afford(cost)
        if not finite(cost) or cost<0 then return false end
        local balance=U.currency.Get("Diamonds")
        return finite(balance) and balance>=cost
            and U.currency.CanAfford("Diamonds",cost)==true
    end
    function U.candidate(spec,data)
        local items=data.Inventory and data.Inventory[spec.kind]
        if type(items)~="table" then return nil end
        local protected={}
        if spec.kind=="Enchant" then
            for _,uid in pairs(data.EquippedEnchants or {}) do protected[uid]=true end
        end
        U.reason=nil
        local selection=spec.kind=="Enchant" and State.UpgradeEnchantSelection or State.UpgradePotionSelection
        local signature={tostring(selection),tostring(U.currency.Get("Diamonds"))}
        local candidates={}
        for uid,entry in pairs(items) do
            if type(uid)=="string" and type(entry)=="table" and type(entry.id)=="string"
                and selectedName(selection,entry.id) then
                signature[#signature+1]=uid..":"..entry.id..":"..tostring(entry.tn)..":"..tostring(entry._am)..":"..tostring(protected[uid])
                if not protected[uid] and U.count(items,uid)>0 then
                    local tier=tonumber(entry.tn) or 1
                    if finite(tier) and tier>=1 and tier==math.floor(tier) then candidates[#candidates+1]={uid=uid,tier=tier,id=entry.id} end
                end
            end
        end
        table.sort(signature)
        signature=table.concat(signature,"|")
        U.idle=U.idle or {}
        local cached=U.idle[spec.kind]
        if cached and cached.signature==signature and os.clock()<cached.untilAt then U.reason=cached.reason return nil end
        table.sort(candidates,function(a,b)
            if a.tier~=b.tier then return a.tier<b.tier end
            if a.id~=b.id then return a.id<b.id end
            return a.uid<b.uid
        end)
        -- Return immediately after the first valid craft instead of validating
        -- and querying currency for every inventory stack on every cycle.
        for _,raw in ipairs(candidates) do
            local uid=raw.uid
            local ok,c=pcall(function()
                local required=U.balance[spec.required](raw.tier)
                if not finite(required) or required<1 or required~=math.floor(required) or U.count(items,uid)<required then return end
                local item=U.classes[spec.kind]:Get(uid)
                if not item or item:GetId()~=raw.id or item:GetTier()~=raw.tier then return end
                local result=item:Clone():SetTier(raw.tier+1):SetAmount(1)
                local cost=U.balance[spec.cost](result:GetRarity().RarityNumber)
                if not finite(cost) or cost<0 then return end
                if not U.afford(cost) then U.reason="Not enough diamonds for this upgrade" return end
                return {uid=uid,id=raw.id,tier=raw.tier,required=required,cost=cost}
            end)
            if ok and c then return c end
            if not ok then U.reason="Item calculation failed: "..tostring(c) end
        end
        U.idle[spec.kind]={signature=signature,untilAt=os.clock()+15,reason=U.reason}
    end
    function U.tick()
        if not isRunning() then return end
        local now=os.clock()
        if now<U.nextAttempt and not U.pending then return end
        if not U.pending and not (Flags.AutoUpgradePotions or Flags.AutoUpgradeEnchants) then REQUEST_STATUS.automation.note("upgrades","Upgrade toggles are off","disabled") return end
        U.modules()
        if U.pending then
            local p=U.pending
            -- Missing/throwing save reads must still reach the verification deadline.
            local readOK,data=pcall(U.save.Get)
            local items=readOK and type(data)=="table" and type(data.Inventory)=="table" and data.Inventory[p.spec.kind]
            if type(items)=="table" and U.count(items,p.uid)<=p.before-p.required*p.quantity and U.results(items,p.id,p.tier)>=p.resultBefore+p.quantity then
                REQUEST_STATUS.automation.finish(p.token,"verified",p.quantity)
                U.completed+=p.quantity U.pending=nil
                U.log("Batch verified: "..p.spec.kind.." "..p.id.." x"..p.quantity.." | Crafted: "..U.completed)
            elseif now>=p.deadline then
                REQUEST_STATUS.automation.finish(p.token,"unconfirmed")
                U.pending=nil U.nextAttempt=now+60 U.log("Craft unconfirmed; waiting before retry")
            end
            return
        end
        local data=U.save.Get()
        if type(data)~="table" or type(data.Inventory)~="table" then U.nextAttempt=now+30 return end
        -- Continuous operation while enabled; no hidden session quota.
        for step=1,#specs do
            local index=(U.cursor+step-1)%#specs+1 local spec=specs[index]
            if Flags[spec.flag] then
                local c=U.candidate(spec,data)
                if c then
                    -- Re-read and revalidate after potentially yielding module calls.
                    local fresh=U.save.Get()
                    if not fresh or not fresh.Inventory then return end
                    if spec.kind=="Enchant" then
                        for _,uid in pairs(fresh.EquippedEnchants or {}) do if uid==c.uid then return end end
                    end
                    local items=fresh.Inventory[spec.kind]
                    local entry=type(items)=="table" and items[c.uid]
                    if type(entry)~="table" or entry.id~=c.id or (tonumber(entry.tn) or 1)~=c.tier then return end
                    local before=U.count(items,c.uid)
                    local diamonds=U.currency.Get("Diamonds")
                    if not finite(diamonds) or diamonds<0 then return end
                    local quantity=math.min(25,math.floor(before/c.required))
                    if c.cost>0 then quantity=math.min(quantity,math.floor(diamonds/c.cost)) end
                    if quantity<1 or not U.afford(c.cost*quantity) or not isRunning() or not Flags[spec.flag] then return end
                    local selection=spec.kind=="Enchant" and State.UpgradeEnchantSelection or State.UpgradePotionSelection
                    if not selectedName(selection,c.id) then return end
                    local resultBefore=U.results(items,c.id,c.tier)
                    local token=REQUEST_STATUS.automation.acquire("upgrades")
                    if not token then return end
                    U.cursor=index U.nextAttempt=os.clock()+30
                    local ok,accepted,detail=REQUEST_STATUS.automation.invoke(token,U.network.Invoke,spec.remote,c.uid,quantity)
                    if not isRunning() then return end
                    if ok and accepted==true then
                        U.nextAttempt=os.clock()+1
                        c.token=token c.spec=spec c.quantity=quantity c.before=before c.resultBefore=resultBefore c.deadline=os.clock()+10
                        U.pending=c
                        U.log("Server accepted: "..spec.kind.." "..c.id.." tier "..c.tier.." x"..quantity.." | Cost: "..(c.cost*quantity))
                    else
                        U.nextAttempt=os.clock()+30 U.log("Upgrade deferred: "..tostring(detail or accepted))
                    end
                    return
                end
            end
        end
        U.nextAttempt=now+5 U.log(U.reason or "Waiting: check selected types, materials, game tier limits, and equipped enchant stacks")
    end
    onCleanup(function() U.pending=nil end)
    return U
end)()
-- Upgrade switches require enabling anew each execution.
Flags.AutoUpgradePotions=false Flags.AutoUpgradeEnchants=false
do
    local env=type(getgenv)=="function" and getgenv() or _G
    if type(env.AERO_UPGRADES_V113_STOP)=="function" then pcall(env.AERO_UPGRADES_V113_STOP) end
end
guardedSpawn("auto-upgrades",function()
    while isRunning() do
        local ok,err=pcall(AutoUpgrades.tick)
        if not ok then AutoUpgrades.nextAttempt=os.clock()+60 AutoUpgrades.log("Waiting after error: "..tostring(err)) end
        task.wait(0.25)
    end
end)

-- P24.4 machine signatures and recipes from the captured game UI.
REQUEST_STATUS.crafting=(function()
    local C={pending=nil,nextAt=0,cursor=0,status="Choose a pet name; crafting is off",verified=0,requests=0,errors=0}
    local specs={{flag="AutoMakeGold",machine="GoldMachine",perk="GoldReduction",method="CanGoldMachine",from="IsNormal",to="IsGolden"},
        {flag="AutoMakeRainbow",machine="RainbowMachine",perk="RainbowReduction",method="CanRainbowMachine",from="IsGolden",to="IsRainbow"},
        {flag="AutoFuse",machine="FuseMachine",method="CanFuseMachine"}}
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    function C.note(s) if C.status~=s then C.status=s print("[AERO CRAFT] "..s) end end
    function C.modules()
        local l=RS.Library
        C.save=C.save or require(l.Client.Save); C.items=C.items or require(l.Items)
        C.mastery=C.mastery or require(l.Client.MasteryCmds); C.ff=C.ff or require(l.Client.FFlags)
        C.instances=C.instances or require(l.Client.InstancingCmds); C.network=C.network or require(l.Client.Network)
    end
    function C.snapshot()
        local d=C.save.Get()
        assert(type(d)=="table" and type(d.Inventory)=="table" and type(d.Inventory.Pet)=="table","Pet inventory unavailable")
        return d.Inventory.Pet
    end
    function C.amount(e)
        local n=type(e)=="table" and (e._am==nil and 1 or tonumber(e._am)) or 0
        return finite(n) and n>=0 and n%1==0 and n<=9007199254740991 and n or 0
    end
    function C.item(uid) return C.items.Pet:Get(uid) end
    function C.safe(item,spec)
        if not item or item:IsHuge() or item:IsTitanic() or item:IsGargantuan() or item:GetExclusiveLevel()~=0 then return false end
        if type(item.IsLocked)~="function" or type(item.IsShiny)~="function" then C.blockReason="Pet lock/shiny inspection API unavailable; no pets submitted" return false end
        if item:IsLocked() or item:IsShiny() then return false end
        if type(item.IsEquipped)=="function" and item:IsEquipped() then return false end
        return item[spec.method](item)==true and (not spec.from or item[spec.from](item)==true)
    end
    function C.outputs(inv,id,method)
        local total=0
        for uid,e in pairs(inv) do
            if type(e)=="table" and e.id==id then local item=C.item(uid)
                if item and item[method](item) then total=total+C.amount(e) end
            end
        end
        return total
    end
    function C.signature(item)
        return table.concat({item:GetId(),tostring(item:IsGolden()),tostring(item:IsRainbow()),tostring(item:IsShiny())},"|")
    end
    function C.totals(inv)
        local totals={}
        for uid,entry in pairs(inv) do
            local item=C.item(uid)
            if item then local key=C.signature(item) totals[key]=(totals[key] or 0)+C.amount(entry) end
        end
        return totals
    end
    function C.checkFusion(p,inv)
        local totals=C.totals(inv)
        local source=totals[p.sourceSignature] or 0
        local observed={inputBefore=p.sourceTotal,inputAfter=source,consume=p.consume,
            outputSignature=p.outputSignature,outputQuantity=p.outputQuantity,accepted=p.accepted,
            responseType=p.responseType,selected=p.id,sourceUID=p.uid,at=os.time()}
        if not p.outputSignature or not p.outputQuantity then
            observed.result="Output response could not be decoded"
            return false,observed
        end
        local before=p.totalsBefore[p.outputSignature] or 0
        local after=totals[p.outputSignature] or 0
        observed.outputBefore=before observed.outputAfter=after
        if p.outputSignature==p.sourceSignature then
            observed.expectedNet=p.sourceTotal-p.consume+p.outputQuantity
            observed.inputConsumed=nil observed.outputArrived=nil
            observed.result="Same-type result: input and output are not independently observable"
            observed.netReconciled=p.accepted and source==observed.expectedNet and p.consume>p.outputQuantity
            return observed.netReconciled,observed
        end
        observed.inputConsumed=source<=p.sourceTotal-p.consume
        observed.outputArrived=after>=before+p.outputQuantity
        observed.result=observed.inputConsumed and observed.outputArrived and "Source consumption and returned output observed"
            or (observed.inputConsumed and "Input consumed; output not yet observed" or (observed.outputArrived and "Output observed; input consumption not yet observed" or "Waiting for inventory changes"))
        return observed.inputConsumed and observed.outputArrived,observed
    end
    function C.plan(spec,uid,inv)
        local e=inv[uid]; local item=C.item(uid)
        if not e or not C.safe(item,spec) then return nil end
        local amount=C.amount(e); local id=item:GetId()
        if id~=State.FusePetName or item:GetUID()~=uid then return nil end
        if spec.to then
            local reduction=0
            if C.mastery.HasPerk("Pets",spec.perk) then reduction=C.mastery.GetPerkPower("Pets",spec.perk) end
            if not finite(reduction) then return nil end
            local required=math.max(1,10-reduction)
            if required%1~=0 or amount<required then return nil end
            return {uid=uid,id=id,before=amount,consume=required,quantity=1,outputBefore=C.outputs(inv,id,spec.to),spec=spec}
        end
        C.fuse=C.fuse or require(RS.Library.Util.FuseUtil); C.currency=C.currency or require(RS.Library.Client.CurrencyCmds)
        local cfg=C.fuse.config
        local minimum=C.mastery.HasPerk("Fuse","FuseLessPetsNeeded") and 2 or cfg.MinimumSelectedPets
        local q=tonumber(State.FusePetAmount)
        if not finite(q) or q%1~=0 or q<minimum or q>cfg.MaximumSelectedPets or q>amount then return nil end
        local chosen={item:Clone():SetAmount(q)}
        local possible=C.fuse.CalculatePossiblePets(chosen,minimum)
        if type(possible)~="table" or #possible<cfg.MinimumSampleSize then return nil end
        local cost=C.fuse.CalculateFuseCost(chosen)
        if not finite(cost) or cost<0 or C.currency.CanAfford("Diamonds",cost)~=true then return nil end
        local beforeCounts={}
        for key,value in pairs(inv) do beforeCounts[key]=C.amount(value) end
        local totals=C.totals(inv); local signature=C.signature(item)
        return {uid=uid,id=id,before=amount,consume=q,quantity=q,spec=spec,beforeCounts=beforeCounts,
            totalsBefore=totals,sourceSignature=signature,sourceTotal=totals[signature]}
    end
    C.catalogRows={} C.idByLabel={} C.labelById={} C.catalogVersion=0 C.catalogMessage="Loading owned pets"
    function C.refreshCatalog()
        C.save=C.save or require(RS.Library.Client.Save)
        C.items=C.items or require(RS.Library.Items)
        C.mastery=C.mastery or require(RS.Library.Client.MasteryCmds)
        C.recipe={}
        for i=1,2 do
            local spec=specs[i]
            local reduction=C.mastery.HasPerk("Pets",spec.perk) and C.mastery.GetPerkPower("Pets",spec.perk) or 0
            C.recipe[i]=finite(reduction) and math.max(1,10-reduction) or nil
        end
        local inv=C.snapshot()
        local rows={}
        for uid,entry in pairs(inv) do
            if type(uid)=="string" and type(entry)=="table" and type(entry.id)=="string" and C.amount(entry)>0 then
                local id=entry.id
                local row=rows[id] or {id=id,normal=0,gold=0,rainbow=0,other=0,total=0,eligible={0,0,0},largest={0,0,0},checksFailed=0}
                rows[id]=row
                local n=C.amount(entry) row.total=row.total+n
                local ok,variant=pcall(function()
                    local pet=C.item(uid)
                    if pet:IsRainbow() then return "rainbow" elseif pet:IsGolden() then return "gold" elseif pet:IsNormal() then return "normal" end
                    return "other"
                end)
                variant=ok and variant or "other"
                row[variant]=row[variant]+n
                for i,spec in ipairs(specs) do
                    local previousReason=C.blockReason
                    local valid,allowed=pcall(function() return C.safe(C.item(uid),spec) end)
                    C.blockReason=previousReason
                    if valid and allowed then row.eligible[i]=row.eligible[i]+n row.largest[i]=math.max(row.largest[i],n)
                    elseif not valid then row.checksFailed=row.checksFailed+1 end
                end
            end
        end
        C.catalogRows=rows C.catalogVersion=C.catalogVersion+1
        C.catalogMessage="Owned pet types: "
        local count=0 for _ in pairs(rows) do count=count+1 end
        C.catalogMessage=C.catalogMessage..count
    end
    function C.inputIndex()
        return ({["Gold inputs"]=1,["Rainbow inputs"]=2,["Fuse inputs"]=3})[State.CraftPetMode]
    end
    function C.matches(row)
        local index=C.inputIndex()
        if not index then return true end
        local needed=index==3 and (tonumber(State.FusePetAmount) or 3) or (C.recipe and C.recipe[index])
        return type(needed)=="number" and row.largest[index]>=needed
    end
    function C.options()
        local options={"Select a pet"}; local byLabel,byId={},{}
        local ids={};local filter=tostring(State.CraftPetSearch or ""):lower()
        for id,row in pairs(C.catalogRows) do
            if (id:lower():find(filter,1,true) and C.matches(row)) or id==State.FusePetName then ids[#ids+1]=id end
        end
        local index=C.inputIndex()
        table.sort(ids,function(a,b)
            local x,y=C.catalogRows[a],C.catalogRows[b]
            if State.CraftPetSort=="Most owned" and x.total~=y.total then return x.total>y.total end
            if State.CraftPetSort=="Most eligible" then
                local nx=index and x.eligible[index] or (x.eligible[1]+x.eligible[2]+x.eligible[3])
                local ny=index and y.eligible[index] or (y.eligible[1]+y.eligible[2]+y.eligible[3])
                if nx~=ny then return nx>ny end
            end
            return a<b
        end)
        for _,id in ipairs(ids) do
            local row=C.catalogRows[id]
            local tag=not C.matches(row) and "[Selected] " or ""
            local label=string.format("%s%s | N:%s G:%s R:%s",tag,id,tostring(row.normal),tostring(row.gold),tostring(row.rainbow))
            byLabel[label]=id byId[id]=label options[#options+1]=label
        end
        if State.FusePetName~="" and not byId[State.FusePetName] then
            local label=State.FusePetName.." | Not currently owned"
            byLabel[label]=State.FusePetName byId[State.FusePetName]=label options[#options+1]=label
        end
        local signature=table.concat(options,"\0")
        if signature~=C.optionSignature then C.previousLabels=C.idByLabel C.optionSignature=signature end
        C.idByLabel=byLabel C.labelById=byId
        return options
    end
    function C.selectionStatus()
        local row=C.catalogRows[State.FusePetName]
        if not row then return C.catalogMessage.." | Select an owned pet. N=Normal, G=Gold, R=Rainbow." end
        local lines={"Selected: "..row.id.." | Owned "..row.total,"Normal "..row.normal.." / Gold "..row.gold.." / Rainbow "..row.rainbow}
        for i,name in ipairs({"Gold","Rainbow","Fuse"}) do
            local needed=i==3 and (tonumber(State.FusePetAmount) or 3) or (C.recipe and C.recipe[i])
            lines[#lines+1]=name..": input-eligible "..row.eligible[i].." | largest stack "..row.largest[i].." | "..(needed and ("needed "..needed.." | short "..math.max(0,needed-row.largest[i])) or "recipe unavailable")
        end
        if row.checksFailed>0 then lines[#lines+1]="Some native eligibility checks failed; counts may be incomplete." end
        lines[#lines+1]="Input checks only; fuse recipe, cost and game restrictions are rechecked before a request."
        return table.concat(lines,"\n")
    end
    guardedSpawn("craft-pet-catalog",function()
        while isRunning() do
            local ok,err=pcall(C.refreshCatalog)
            if not ok then C.catalogMessage="Pet inventory unavailable: "..tostring(err):sub(1,160) end
            task.wait(10)
        end
    end)
    function C.tick()
        if not isRunning() then return end
        local now=os.clock()
        if C.pending then
            local p=C.pending
            local readOK,verified=pcall(function()
                local inv=C.snapshot()
                if not p.spec.to then
                    local matched,observation=C.checkFusion(p,inv)
                    C.lastFusion=observation
                    return matched
                end
                local consumed=C.amount(inv[p.uid])<=p.before-p.consume
                local output=false
                if p.spec.to then output=C.outputs(inv,p.id,p.spec.to)>=p.outputBefore+p.quantity
                elseif p.resultItem then
                    for uid,e in pairs(inv) do
                        if C.amount(e)>(p.beforeCounts[uid] or 0) then
                            local item=C.item(uid); local result=p.resultItem
                            if item and item:GetId()==result:GetId() and item:IsGolden()==result:IsGolden()
                                and item:IsRainbow()==result:IsRainbow() and item:IsShiny()==result:IsShiny() then output=true break end
                        end
                    end
                end
                return consumed and output
            end)
            if readOK and verified then
                REQUEST_STATUS.automation.finish(p.token,(not p.spec.to and C.lastFusion and C.lastFusion.netReconciled) and "reconciled" or "verified",1)
                if C.lastFusion and not p.spec.to and C.lastFusion.netReconciled then
                    C.netReconciled=(C.netReconciled or 0)+1
                    C.note("FuseMachine: net inventory change matches returned same-type result (not independent output verification)")
                else
                    C.verified=C.verified+1
                    C.note(p.spec.machine..": source decrease and output observed")
                end
                C.pending=nil C.nextAt=now+3
                return
            end
            if not readOK then
                C.lastFusionError=tostring(verified):sub(1,200)
            elseif not p.spec.to and C.lastFusion then
                C.note("FuseMachine: "..C.lastFusion.result.." | waiting without resending")
            end
            if now>=p.deadline then
                REQUEST_STATUS.automation.finish(p.token,"unconfirmed")
                Flags[p.spec.flag]=false C.pending=nil C.nextAt=now+60
                C.note(p.spec.machine..": inventory outcome unconfirmed; toggle switched off")
            end
            return
        end
        if not (Flags.AutoMakeGold or Flags.AutoMakeRainbow or Flags.AutoFuse) or now<C.nextAt then return end
        if type(State.FusePetName)~="string" or State.FusePetName=="" or State.FusePetName=="All" then C.nextAt=now+5 C.note("Select an owned pet before enabling crafting") return end
        C.modules()
        if C.instances.IsInInstance() or REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.areaTravelBusy or Flags.AutoHatch then C.nextAt=now+3 C.note("Paused during hatching, travel or instances") return end
        for step=1,#specs do
            local index=(C.cursor+step-1)%#specs+1; local spec=specs[index]
            if Flags[spec.flag] then
                local key=C.ff.Keys[spec.machine]
                if key and C.ff.Get(key)==true then
                    local inv=C.snapshot(); local ids={} C.blockReason=nil
                    for uid,e in pairs(inv) do if type(uid)=="string" and type(e)=="table" and e.id==State.FusePetName then ids[#ids+1]=uid end end
                    table.sort(ids)
                    for _,uid in ipairs(ids) do
                        local p=C.plan(spec,uid,inv)
                        if p then
                            p=C.plan(spec,uid,C.snapshot())
                            if not p or not isRunning() or not Flags[spec.flag] or Flags.AutoHatch or C.instances.IsInInstance() or REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.areaTravelBusy then return end
                            local token=REQUEST_STATUS.automation.acquire("pet-crafting")
                            if not token then return end
                            C.cursor=index C.nextAt=os.clock()+30 C.requests=C.requests+1
                            local ok,accepted,message,resultUID
                            if spec.to then ok,accepted,message,resultUID=REQUEST_STATUS.automation.invoke(token,C.network.Invoke,spec.machine.."_Activate",p.uid,p.quantity)
                            else ok,accepted,message,resultUID=REQUEST_STATUS.automation.invoke(token,C.network.Invoke,"FuseMachine_Activate",{[p.uid]=p.quantity}) end
                            if not isRunning() then return end
                            if ok and accepted==true then
                                p.token=token p.deadline=os.clock()+(spec.to and 10 or 30)
                                token.deadline=p.deadline+5
                                p.accepted=true p.responseType=type(resultUID)
                                if not spec.to then C.lastFusionError=nil C.lastFusion=nil end
                                if not spec.to and type(resultUID)=="table" and type(resultUID.data)=="table" then
                                    local decoded,item=pcall(function() return C.items.Pet:From(resultUID.data) end)
                                    if decoded then
                                        p.resultItem=item
                                        local valid,key=pcall(C.signature,item)
                                        local quantity=C.amount(resultUID.data)
                                        if valid and quantity>=1 then p.outputSignature=key p.outputQuantity=quantity end
                                    end
                                end
                                C.pending=p
                                C.note(spec.machine..": accepted; verifying inventory")
                            else
                                Flags[spec.flag]=false C.note(spec.machine..": rejected or uncertain; toggle off | "..tostring(message or accepted))
                            end
                            return
                        end
                    end
                end
            end
        end
        C.nextAt=now+5 C.note(C.blockReason or "No eligible selected stack: check name, materials, locks, shiny/special status, mastery and machine availability")
    end
    onCleanup(function() C.pending=nil end)
    guardedSpawn("pet-crafting",function()
        while isRunning() do
            local ok,err=pcall(C.tick)
            if not ok then C.errors=C.errors+1 C.nextAt=os.clock()+30 C.note("Paused after error: "..tostring(err)) end
            task.wait(0.5)
        end
    end)
    return C
end)()

-- Enchant Manager: compact saved list and verified ordered auto-equip.
local EnchantManager=(function()
    local M={draft={},entries={},byUID={},selected=nil,closed=false,mounted=false,enabled=false,revision=0}
    local path="AERO_PS99_Enchants_"..tostring(game.GameId).."_"..tostring(LocalPlayer.UserId)..".json"
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    function M.normalize(inventory)
        local entries={}
        for uid,item in pairs(inventory or {}) do
            if type(uid)=="string" and type(item)=="table" and type(item.id)=="string" and item.id~="" then
                local count=item._am==nil and 1 or tonumber(item._am)
                local tier=item.tn==nil and 1 or tonumber(item.tn)
                if finite(count) and finite(tier) and count>=1 and tier>=1 then
                    entries[#entries+1]={uid=uid,name=item.id,tier=math.floor(tier),amount=math.floor(count)}
                end
            end
        end
        table.sort(entries,function(a,b)
            if a.name~=b.name then return a.name<b.name end
            if a.tier~=b.tier then return a.tier>b.tier end
            return a.uid<b.uid
        end)
        local used={}
        for _,entry in ipairs(entries) do
            local base=string.format("%s | Tier %d | x%d",entry.name,entry.tier,entry.amount)
            entry.label=used[base] and (base.." | "..entry.uid) or base
            used[entry.label]=true
        end
        return entries
    end
    local function readInventory()
        -- Inventory is independent of EnchantCmds: slot/module failures must
        -- never prevent owned names from reaching the selector.
        local client=RS:FindFirstChild("Library") and RS.Library:FindFirstChild("Client")
        local saveModule=client and client:FindFirstChild("Save")
        if not saveModule then return nil,"Save module unavailable" end
        local ok,data=pcall(function() return require(saveModule).Get() end)
        if not ok or type(data)~="table" or type(data.Inventory)~="table" then
            return nil,"Inventory unavailable: "..tostring(data)
        end
        if type(data.Inventory.Enchant)~="table" then return nil,"Enchant inventory is not ready; it will refresh automatically" end
        local slots=tonumber(data.MaxEnchantsEquipped)
        if not finite(slots) or slots<1 then slots=nil end
        local equipped={}
        for slot,uid in pairs(type(data.EquippedEnchants)=="table" and data.EquippedEnchants or {}) do
            equipped[slot]=uid
        end
        return {entries=M.normalize(data.Inventory.Enchant),slots=slots and math.floor(slots),
            paidSlots=data.MaxPaidEnchantsEquipped,equipped=equipped}
    end
    -- Game module code runs only in a separate task. Requiring a client module
    -- must not change the UI constructor/callback thread's execution context.
    -- No thread identity or capability is raised or changed here.
    function M.read()
        local completed,result,message=false,nil,nil
        local worker=spawnTask(function()
            local ok,data,err=pcall(readInventory)
            if ok then result,message=data,err
            else message="Inventory read failed: "..tostring(data) end
            completed=true
        end)
        local deadline=os.clock()+10
        while not completed and not M.closed and os.clock()<deadline do
            task.wait()
        end
        if not completed then
            pcall(task.cancel,worker)
            return nil,M.closed and "Interface closed" or "Inventory read timed out; try selecting again"
        end
        return result,message
    end
    function M.index(entries)
        M.entries=entries M.byUID={} M.byLabel={} M.best={}
        local options={}
        for _,entry in ipairs(entries) do
            M.byUID[entry.uid]=entry
            local best=M.best[entry.name]
            if not best or entry.tier>best.tier then
                M.best[entry.name]={tier=entry.tier,stacks={entry}}
            elseif entry.tier==best.tier then
                best.stacks[#best.stacks+1]=entry
            end
        end
        for name in pairs(M.best) do
            options[#options+1]=name M.byLabel[name]=name
        end
        table.sort(options)
        return options
    end
    function M.validate(draft,byUID,slots)
        if type(draft)~="table" then return false,"Invalid loadout" end
        if not finite(slots) or slots<1 then return false,"Account slot limit unavailable" end
        if #draft>slots then return false,"Loadout exceeds this account's detected slots" end
        local counts={}
        for i,entry in ipairs(draft) do
            local owned=type(entry)=="table" and byUID[entry.uid]
            if not owned or owned.name~=entry.name or owned.tier~=entry.tier then return false,"Entry "..i.." is no longer in inventory; remove or replace it" end
            counts[entry.uid]=(counts[entry.uid] or 0)+1
            if counts[entry.uid]>owned.amount then return false,"Not enough copies of "..owned.name end
        end
        return true
    end
    local function copyEntry(entry) return {uid=entry.uid,name=entry.name,tier=entry.tier} end
    local function say(text)
        M.message=tostring(text)
        print("[AERO ENCHANT] "..M.message)
        M.render()
    end
    local function clean(s) return tostring(s):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;") end
    function M.render()
        if M.closed then return end
        local lines={"Slots: "..tostring(M.slots or "unavailable").." | selected: "..#M.draft}
        for i,entry in ipairs(M.draft) do
            lines[#lines+1]=string.format("%d. %s | Tier %d%s",i,clean(entry.name),entry.tier,M.byUID[entry.uid] and "" or " [missing]")
        end
        if #M.draft==0 then lines[#lines+1]="Select an enchant and save it into the list. Repeat for multiple copies." end
        if M.message then lines[#lines+1]=M.message end
        local text=table.concat(lines,"\n")
        if M.preview and text~=M.lastPreview then M.preview:Set(text) M.lastPreview=text end
    end
    function M.refresh()
        local data,err=M.read()
        if M.closed then return end
        if not data then say(err) return false end
        M.slots=data.slots M.equipped=data.equipped
        local options=M.index(data.entries)
        if M.picker then
            M.syncing=true
            local signature=table.concat(options,"\0")
            if signature~=M.optionsSignature then
                M.picker:Refresh(options) M.optionsSignature=signature
            end
            if not M.best[M.selected] then M.selected=options[1] end
            M.picker:Set(M.selected or {},true)
            M.syncing=false
        end
        M.render()
        return true
    end
    function M.add()
        if not M.refresh() then return end
        local best=M.selected and M.best[M.selected]
        if not best then say("Select an owned enchant first") return end
        local counts={}
        for _,item in ipairs(M.draft) do counts[item.uid]=(counts[item.uid] or 0)+1 end
        local entry
        for _,owned in ipairs(best.stacks) do
            if (counts[owned.uid] or 0)<owned.amount then entry=owned break end
        end
        if not entry then say("No more copies of the highest tier of "..M.selected) return end
        local proposed=table.clone(M.draft)
        proposed[#proposed+1]=copyEntry(entry)
        local valid,err=M.validate(proposed,M.byUID,M.slots)
        if not valid then say(err) return end
        M.draft=proposed M.revision+=1
        local saved,why=M.persist()
        say("Added "..entry.name.." Tier "..entry.tier..(saved and " - saved" or (" - session only: "..tostring(why))))
    end
    function M.persist()
        if type(writefile)~="function" then return false,"file saving unavailable" end
        return pcall(function() writefile(path,HttpService:JSONEncode({schema=1,gameId=game.GameId,userId=LocalPlayer.UserId,entries=M.draft})) end)
    end
    function M.load()
        if type(readfile)~="function" then say("File reading is unavailable") return end
        local ok,decoded=pcall(function()
            local raw=readfile(path)
            assert(type(raw)=="string" and #raw<=64000,"Loadout file is too large or invalid")
            return HttpService:JSONDecode(raw)
        end)
        if not ok or type(decoded)~="table" or decoded.schema~=1 or decoded.gameId~=game.GameId or decoded.userId~=LocalPlayer.UserId or type(decoded.entries)~="table" or #decoded.entries>100 then say("No valid saved loadout for this account") return end
        local nextDraft={}
        for i,entry in ipairs(decoded.entries) do
            if type(entry)~="table" or type(entry.uid)~="string" or #entry.uid>200 or type(entry.name)~="string" or #entry.name>200 or not finite(entry.tier) or entry.tier<1 then say("Saved entry "..i.." is invalid") return end
            nextDraft[#nextDraft+1]=copyEntry(entry)
        end
        M.draft=nextDraft M.refresh()
        local valid,err=M.validate(M.draft,M.byUID,M.slots)
        say(valid and "Saved enchant list loaded; auto-equip is off" or ("Saved list needs editing: "..err))
    end
    -- Resolve every requested name to its highest tier before changing equipment.
    -- Duplicate copies can span multiple stacks of that same highest tier.
    function M.resolve()
        local plan,used={},{}
        for _,requested in ipairs(M.draft) do
            local best=M.best[requested.name]
            local chosen
            for _,entry in ipairs(best and best.stacks or {}) do
                if (used[entry.uid] or 0)<entry.amount then chosen=entry break end
            end
            if not chosen then return nil,"Not enough highest-tier copies of "..requested.name end
            used[chosen.uid]=(used[chosen.uid] or 0)+1
            plan[#plan+1]=copyEntry(chosen)
        end
        local valid,err=M.validate(plan,M.byUID,M.slots)
        return valid and plan or nil,err
    end
    function M.command(method,value,revision)
        -- Keep all game module execution off the UI/worker caller's thread.
        local done,success,message=false,false,nil
        local worker=spawnTask(function()
            success,message=pcall(function()
                local cmds=require(RS.Library.Client.EnchantCmds)
                assert(type(cmds[method])=="function","Enchant method unavailable")
                if not M.active(revision) then error("Auto-equip request cancelled") end
                cmds[method](value)
            end)
            done=true
        end)
        local deadline=os.clock()+5
        while not done and not M.closed and os.clock()<deadline do task.wait() end
        if not done then pcall(task.cancel,worker) return false,"Enchant command timed out" end
        return success,message
    end
    function M.active(revision)
        return M.enabled and not M.closed and M.revision==revision
    end
    function M.confirm(revision,predicate)
        local deadline=os.clock()+4
        repeat
            if not M.active(revision) then return false,"Selection changed or auto-equip stopped" end
            local data,err=M.read()
            if not data then return false,err end
            if not M.active(revision) then return false,"Auto-equip request cancelled" end
            if predicate(data.equipped) then return true end
            task.wait(0.15)
        until os.clock()>=deadline
        return false,"Server did not confirm enchant change"
    end
    function M.apply()
        local revision=M.revision
        if not M.refresh() then return false,"Inventory unavailable" end
        if #M.draft==0 then return false,"Add enchants to the list first" end
        local plan,err=M.resolve()
        if not plan then return false,err end
        if not M.active(revision) then return false,"Auto-equip request cancelled" end
        local function uidAt(equipped,slot) return equipped[slot] or equipped[tostring(slot)] end
        -- Keep the correctly equipped prefix. With the observed Equip(uid)
        -- API, only the tail after the first mismatch needs rebuilding.
        local prefix=0
        for slot,entry in ipairs(plan) do
            if uidAt(M.equipped,slot)~=entry.uid then break end
            prefix=slot
        end
        local occupied={}
        for slot,uid in pairs(M.equipped) do
            local n=tonumber(slot)
            if n and n>prefix and n%1==0 and uid then occupied[#occupied+1]=n end
        end
        if prefix==#plan and #occupied==0 then
            return true,"Selected enchants equipped"
        end
        table.sort(occupied,function(a,b) return a>b end)
        for _,slot in ipairs(occupied) do
            if not M.active(revision) then return false,"Auto-equip stopped" end
            local ok,why=M.command("Unequip",slot,revision)
            if not ok then return false,why end
            ok,why=M.confirm(revision,function(e) return uidAt(e,slot)==nil end)
            if not ok then return false,why end
        end
        for slot=prefix+1,#plan do
            local entry=plan[slot]
            if not M.active(revision) then return false,"Auto-equip stopped" end
            local ok,why=M.command("Equip",entry.uid,revision)
            if not ok then return false,why end
            ok,why=M.confirm(revision,function(e)
                for i=1,slot do if uidAt(e,i)~=plan[i].uid then return false end end
                return true
            end)
            if not ok then return false,why end
        end
        return true,"Selected enchants equipped in order"
    end
    function M.waitForRetry(revision,seconds)
        local deadline=os.clock()+seconds
        while M.active(revision) and os.clock()<deadline do
            task.wait(math.min(0.25,deadline-os.clock()))
        end
    end
    function M.setEnabled(value)
        local enabled=value==true
        if M.enabled~=enabled then M.revision+=1 end
        M.enabled=enabled Flags.AutoEquipEnchants=enabled
        if not enabled then say("Auto-equip off") return end
        if M.workerRunning then return end
        M.workerRunning=true
        spawnTask(function()
            local failures=0
            while M.enabled and not M.closed do
                local revision=M.revision
                local callOK,ok,message=pcall(M.apply)
                if not callOK then message=ok ok=false end
                if M.active(revision) then
                    if ok then
                        failures=0
                        if M.message~=message then say(message) end
                        M.waitForRetry(revision,3)
                    else
                        failures=math.min(failures+1,5)
                        local delay=math.min(5*2^(failures-1),60)
                        local text="Paused: "..tostring(message)..". Retrying in "..delay.."s."
                        if M.message~=text then say(text) end
                        M.waitForRetry(revision,delay)
                    end
                else
                    failures=0
                end
            end
            M.workerRunning=false
        end)
    end
    function M.mount(tab)
        if M.mounted or M.closed then return end
        M.mounted=true
        tab:CreateSection({name="Equip Enchants"})
        local initial,initialError=M.read()
        local options=M.index(initial and initial.entries or {})
        if initial then M.slots=initial.slots M.equipped=initial.equipped end
        M.selected=options[1]
        M.preview=tab:CreateText({name="Current Enchant List",text="No enchants selected"})
        M.picker=tab:CreateDropdown({name="Select an Enchant",flag="AERO_ENCHANT_PICKER",options=options,value=options[1],forgetState=true,callback=function(value)
            if M.closed or M.syncing then return end
            if type(value)=="table" then value=value[1] or value.Value end
            M.selected=M.byLabel[value]
        end})
        tab:CreateButton({name="Save Selected Enchant into Enchant List",callback=M.add})
        tab:CreateButton({name="Clear Enchant List",callback=function()
            M.setEnabled(false) M.revision+=1 M.draft={}
            if M.toggle then M.toggle:Set(false,true) end
            local saved,err=M.persist()
            say(saved and "Enchant list cleared and saved" or ("List cleared for this session: "..tostring(err)))
        end})
        M.toggle=tab:CreateToggle({name="Auto Equip Selected Enchants (in order)",flag="AERO_ENCHANT_AUTO",value=false,forgetState=true,callback=M.setEnabled})
        if type(isfile)=="function" and isfile(path) then M.load() else
            M.message=initialError or "Highest owned tiers; auto-equip off" M.render()
        end
        -- Inventory refresh adds newly acquired names without another button.
        spawnTask(function()
            while not M.closed do
                task.wait(10)
                if not M.closed and not M.enabled then
                    local ok,err=pcall(M.refresh)
                    if not ok then warn("[AERO ENCHANT] Inventory refresh: "..tostring(err)) end
                end
            end
        end)
        print("[AERO ENCHANT] Compact list initialized: "..#options.." names")
    end
    onCleanup(function() M.closed=true M.enabled=false M.revision+=1 M.picker=nil M.toggle=nil M.preview=nil end)
    return M
end)()

Flags.AutoEquipEnchants=false -- enable only through the enchant toggle each session

-- P24.4: Native, embedded AERO Universal-style GUI (no Rayfield or network loader).
-- Extracted from the user-supplied AERO_GUI_Portable_v1_0_Complete.zip.
-- Includes the original portable GUI's MIT-licensed Flipper spring source.
local GuiLib={}
GuiLib.portable=(function()
-- AERO GUI Portable v1.0 | Reusable GUI extracted and adapted from AERO Universal v2.4.4
-- Roblox Luau | Works with LocalScripts and compatible executor runtimes.
-- Does not contain AERO Universal game-scanning, automation, or decompilation features.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local COLORS = {
    bg=Color3.fromRGB(12,17,25),panel=Color3.fromRGB(20,27,39),surface=Color3.fromRGB(31,42,58),
    text=Color3.fromRGB(237,244,252),muted=Color3.fromRGB(153,174,196),accent=Color3.fromRGB(32,174,186),
    selected=Color3.fromRGB(18,99,120),danger=Color3.fromRGB(139,56,62)
}
-- Embedded Flipper Spring.lua; MIT license retained below.
--[[
Copyright (c) 2020 Reselim
Copyright 2018 Parker Stebbins (parker@fractality.io)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]
local Spring = (function()
local VELOCITY_THRESHOLD = 0.001
local POSITION_THRESHOLD = 0.001

local EPS = 0.0001

--[=[
	@interface SpringOptions
	@within Spring
	@field frequency number | nil -- Oscillation rate (in hz) when dampingRatio is 1. Default: 4
	@field dampingRatio number | nil -- How rapidly the oscillations decay from one bounce to the next. Default: 1
]=]

--[=[
	@class Spring

	Represents a spring-type Goal. Based on [Fraktality's spring solver](https://github.com/Fraktality/Spring).
]=]
local Spring = {}
Spring.__index = Spring

--[=[
	Creates a new Spring.

	@param targetValue number
	@param options SpringOptions
	@return Spring
]=]
function Spring.new(targetValue, options)
	assert(targetValue, "Missing argument #1: targetValue")
	options = options or {}

	return setmetatable({
		_targetValue = targetValue,
		_frequency = options.frequency or 4,
		_dampingRatio = options.dampingRatio or 1,
	}, Spring)
end

--[=[
	Advances the specified MotorState by `deltaTime` using the spring solver and returns a new MotorState.

	@param state MotorState
	@param deltaTime number
	@return MotorState
]=]
function Spring:step(state, dt)
	-- Copyright 2018 Parker Stebbins (parker@fractality.io)
	-- github.com/Fraktality/Spring
	-- Distributed under the MIT license

	local d = self._dampingRatio
	local f = self._frequency*2*math.pi
	local g = self._targetValue
	local p0 = state.value
	local v0 = state.velocity or 0

	local offset = p0 - g
	local decay = math.exp(-d*f*dt)

	local p1, v1

	if d == 1 then -- Critically damped
		p1 = (offset*(1 + f*dt) + v0*dt)*decay + g
		v1 = (v0*(1 - f*dt) - offset*(f*f*dt))*decay
	elseif d < 1 then -- Underdamped
		local c = math.sqrt(1 - d*d)

		local i = math.cos(f*c*dt)
		local j = math.sin(f*c*dt)

		-- Damping ratios approaching 1 can cause division by small numbers.
		-- To fix that, group terms around z=j/c and find an approximation for z.
		-- Start with the definition of z:
		--    z = sin(dt*f*c)/c
		-- Substitute a=dt*f:
		--    z = sin(a*c)/c
		-- Take the Maclaurin expansion of z with respect to c:
		--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
		--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120
		-- Rewrite in Horner form:
		--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

		local z
		if c > EPS then
			z = j/c
		else
			local a = dt*f
			z = a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6
		end

		-- Frequencies approaching 0 present a similar problem.
		-- We want an approximation for y as f approaches 0, where:
		--    y = sin(dt*f*c)/(f*c)
		-- Substitute b=dt*c:
		--    y = sin(b*c)/b
		-- Now reapply the process from z.

		local y
		if f*c > EPS then
			y = j/(f*c)
		else
			local b = f*c
			y = dt + ((dt*dt)*(b*b)*(b*b)/20 - b*b)*(dt*dt*dt)/6
		end

		p1 = (offset*(i + d*z) + v0*y)*decay + g
		v1 = (v0*(i - z*d) - offset*(z*f))*decay

	else -- Overdamped
		local c = math.sqrt(d*d - 1)

		local r1 = -f*(d - c)
		local r2 = -f*(d + c)

		local co2 = (v0 - offset*r1)/(2*f*c)
		local co1 = offset - co2

		local e1 = co1*math.exp(r1*dt)
		local e2 = co2*math.exp(r2*dt)

		p1 = e1 + e2 + g
		v1 = e1*r1 + e2*r2
	end

	local complete = math.abs(v1) < VELOCITY_THRESHOLD and math.abs(p1 - g) < POSITION_THRESHOLD
	
	return {
		complete = complete,
		value = complete and g or p1,
		velocity = v1,
	}
end

return Spring

end)()

local Library = {Version="1.0.0", Source="AERO Universal v2.4.4", Colors=COLORS}
local env=_G
if type(getgenv)=="function" then
    local ok,global=pcall(getgenv)
    if ok and type(global)=="table" then env=global end
end
local activeWindows=env.AERO_GUI_PORTABLE_WINDOWS
if type(activeWindows)~="table" then
    activeWindows={}
    env.AERO_GUI_PORTABLE_WINDOWS=activeWindows
end
local function create(class, properties, parent)
    local object = Instance.new(class)
    for k,v in pairs(properties or {}) do object[k]=v end
    object.Parent = parent
    return object
end
local function corner(parent, radius)
    return create("UICorner",{CornerRadius=UDim.new(0,radius or 8)},parent)
end
local function button(parent, text, size)
    local b=create("TextButton",{Name="Button",Size=size or UDim2.new(1,0,0,46),BackgroundColor3=COLORS.surface,
        Text=tostring(text or ""),TextColor3=COLORS.text,TextSize=14,TextWrapped=true,
        Font=Enum.Font.GothamMedium,AutoButtonColor=true,BorderSizePixel=0},parent)
    corner(b,8)
    create("UIStroke",{Color=COLORS.surface,Thickness=1,Transparency=0.45},b)
    return b
end
local function label(parent, text, size, color)
    return create("TextLabel",{Name="Label",Size=size or UDim2.new(1,0,0,30),BackgroundTransparency=1,
        Text=tostring(text or ""),TextColor3=color or COLORS.text,Font=Enum.Font.Gotham,
        TextSize=13,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},parent)
end
local function inputBox(parent, hint, size)
    local box=create("TextBox",{Name="Input",Size=size or UDim2.new(1,0,0,44),BackgroundColor3=COLORS.surface,
        BorderSizePixel=0,Text="",PlaceholderText=hint or "",ClearTextOnFocus=false,
        TextColor3=COLORS.text,PlaceholderColor3=COLORS.muted,Font=Enum.Font.Gotham,TextSize=13},parent)
    corner(box,8)
    return box
end
local function geometry(vw,vh,width,height,preferred,fullscreen,adaptive)
    if vw<=32 or vh<=32 then return nil end
    preferred=math.clamp(preferred or 1,0.65,1.5)
    if fullscreen then return (vw-16)/preferred,(vh-16)/preferred,preferred,8,8 end
    if adaptive then return math.min(900,vw-24)/preferred,math.min(760,vh-24)/preferred,preferred,nil,nil end
    return width,height,math.min(preferred,(vw-24)/width,(vh-24)/height),nil,nil
end
local function frameModel(width)
    local wide=width>=680
    return {wide=wide,pageX=wide and 196 or 12,pageY=60,pageRight=12,pageBottom=wide and 12 or 78,
        drawerWidth=wide and 172 or math.min(360,width-24),columns=wide and 1 or 2,rowHeight=48}
end
local function getExecutorFunction(key)
    local fn=nil
    pcall(function()
        if type(getgenv)=="function" then
            local ok,env=pcall(getgenv)
            if ok and type(env)=="table" and type(env[key])=="function" then fn=env[key] end
        end
    end)
    if not fn and type(_G[key])=="function" then fn=_G[key] end
    return fn
end
local function prefsPath(id)
    return "AERO_GUI_"..tostring(id or "default"):gsub("[^%w_%-]","_"):sub(1,52)..".json"
end
local function loadPrefs(id)
    local read=getExecutorFunction("readfile")
    if not read then return nil end
    local ok,data=pcall(function() return HttpService:JSONDecode(read(prefsPath(id))) end)
    return ok and type(data)=="table" and data or nil
end
local function savePrefs(id,data)
    local write=getExecutorFunction("writefile")
    if not write then return false,"writefile unavailable" end
    local ok,err=pcall(function() write(prefsPath(id),HttpService:JSONEncode(data)) end)
    return ok,err
end
local function callback(window,fn,...)
    if type(fn)~="function" then return end
    local ok,err=pcall(fn,...)
    if not ok and window.Alive then
        window.ErrorCount=window.ErrorCount+1
        warn("[AERO GUI] Callback: "..tostring(err))
        window:Notify("Control error",tostring(err),4)
    end
end
local function connect(window,signal,fn)
    local c=signal:Connect(function(...)
        if window.Alive then callback(window,fn,...) end
    end)
    table.insert(window.Connections,c)
    return c
end
local function control(tab,object)
    local handle={Instance=object}
    function handle:Destroy() if self.Instance then self.Instance:Destroy();self.Instance=nil end end
    return handle
end
local Tab = {}
Tab.__index=Tab
function Tab:AddSection(text)
    local name=label(self.Page,text,UDim2.new(1,0,0,30),COLORS.accent)
    name.Name="Section";name.TextSize=16;name.Font=Enum.Font.GothamBold
    return control(self,name)
end
function Tab:AddParagraph(title,body)
    local container=create("Frame",{BackgroundColor3=COLORS.surface,BorderSizePixel=0,Size=UDim2.new(1,0,0,76)},self.Page)
    corner(container,8)
    local titleLabel=label(container,title,UDim2.new(1,-20,0,25));titleLabel.Position=UDim2.fromOffset(10,6)
    titleLabel.Font=Enum.Font.GothamBold
    local bodyLabel=label(container,body,UDim2.new(1,-20,1,-34),COLORS.muted);bodyLabel.Position=UDim2.fromOffset(10,30)
    local h=control(self,container)
    function h:Set(t,b) titleLabel.Text=tostring(t or "");bodyLabel.Text=tostring(b or "") end
    return h
end
function Tab:AddLabel(text)
    local l=label(self.Page,text,UDim2.new(1,0,0,40),COLORS.muted)
    l.TextYAlignment=Enum.TextYAlignment.Top
    local h=control(self,l)
    function h:Set(t)
        local value=tostring(t or "")
        l.Text=value
        -- Show longer diagnostics on portrait phones without unbounded rows.
        local lines=1
        for _ in value:gmatch("\n") do lines=lines+1 end
        local estimate=math.ceil(#value/46)
        l.Size=UDim2.new(1,0,0,math.clamp(20*math.max(lines,estimate),40,160))
    end
    h:Set(text)
    return h
end
function Tab:AddButton(options,fn)
    if type(options)=="string" then options={Name=options,Callback=fn} end
    options=options or {}
    local b=button(self.Page,options.Name or "Button")
    local h=control(self,b)
    function h:SetText(text) b.Text=tostring(text or "") end
    connect(self.Window,b.Activated,function() callback(self.Window,options.Callback) end)
    return h
end
function Tab:AddToggle(options)
    options=options or {}
    local value=options.Default==true
    local b=button(self.Page,"")
    local h=control(self,b)
    local function repaint() b.Text=(value and "● ON   " or "○ OFF   ")..tostring(options.Name or "Toggle");b.BackgroundColor3=value and COLORS.selected or COLORS.surface end
    function h:Get() return value end
    function h:Set(nextValue,fire)
        value=nextValue==true;repaint()
        if fire then callback(self.Window,options.Callback,value) end
    end
    connect(self.Window,b.Activated,function() h:Set(not value,true) end)
    repaint()
    return h
end
function Tab:AddInput(options)
    options=options or {}
    local title=label(self.Page,options.Name or "Input",UDim2.new(1,0,0,24),COLORS.muted)
    local box=inputBox(self.Page,options.Placeholder or "Enter text")
    box.Text=tostring(options.Default or "")
    local h=control(self,box)
    h.Title=title
    function h:Get() return box.Text end
    function h:Set(text,fire)
        box.Text=tostring(text or "")
        if fire then callback(self.Window,options.Callback,box.Text) end
    end
    connect(self.Window,box.FocusLost,function(enterPressed)
        if enterPressed or options.SubmitOnFocusLost~=false then callback(self.Window,options.Callback,box.Text,enterPressed) end
    end)
    return h
end
function Tab:AddSlider(options)
    options=options or {}
    local min=tonumber(options.Min) or 0
    local max=tonumber(options.Max) or 100
    if max<min then min,max=max,min end
    if max==min then max=min+1 end
    local step=math.max(0.00001,tonumber(options.Increment) or 1)
    local value=min
    local wrap=create("Frame",{Name="Slider",Size=UDim2.new(1,0,0,80),BackgroundTransparency=1},self.Page)
    local heading=label(wrap,"",UDim2.new(1,0,0,28))
    local track=create("Frame",{Position=UDim2.fromOffset(2,44),Size=UDim2.new(1,-4,0,12),BackgroundColor3=COLORS.surface,BorderSizePixel=0,Active=true},wrap)
    corner(track,6)
    local fill=create("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COLORS.accent,BorderSizePixel=0},track);corner(fill,6)
    local h=control(self,wrap)
    local function set(v,fire)
        local n=math.clamp(tonumber(v) or min,min,max)
        value=math.clamp(min+math.floor((n-min)/step+0.5)*step,min,max)
        fill.Size=UDim2.fromScale((value-min)/(max-min),1)
        heading.Text=tostring(options.Name or "Slider").."  •  "..string.format("%g",value)
        if fire then callback(self.Window,options.Callback,value) end
    end
    function h:Get() return value end
    function h:Set(v,fire) set(v,fire) end
    local dragging=false;local touchInput=nil
    local function fromPosition(x)
        if track.AbsoluteSize.X<=0 then return end
        set(min+(max-min)*math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1),true)
    end
    connect(self.Window,track.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true;touchInput=input.UserInputType==Enum.UserInputType.Touch and input or nil
            fromPosition(input.Position.X)
        end
    end)
    connect(self.Window,UIS.InputChanged,function(input)
        if dragging and ((touchInput and input==touchInput) or (not touchInput and input.UserInputType==Enum.UserInputType.MouseMovement)) then fromPosition(input.Position.X) end
    end)
    connect(self.Window,UIS.InputEnded,function(input)
        if dragging and ((touchInput and input==touchInput) or (not touchInput and input.UserInputType==Enum.UserInputType.MouseButton1)) then
            dragging=false;touchInput=nil
        end
    end)
    set(options.Default or min,false)
    return h
end
function Tab:AddDropdown(options)
    options=options or {}
    local values=options.Options or {}
    local selection=options.Default
    local root=create("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1,ClipsDescendants=false},self.Page)
    local trigger=button(root,"")
    local popup=create("ScrollingFrame",{Name="Options",Position=UDim2.new(0,0,1,4),Size=UDim2.new(1,0,0,0),
        BackgroundColor3=COLORS.panel,BorderSizePixel=0,ScrollBarThickness=3,
        CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=25},root)
    corner(popup,8)
    local layout=create("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},popup)
    local h=control(self,root)
    local optionListeners={}
    local opened=false
    local function repaint() trigger.Text=tostring(options.Name or "Dropdown")..": "..tostring(selection or "Select")..(opened and "  ▲" or "  ▼") end
    local function close()
        opened=false;popup.Visible=false;popup.Size=UDim2.new(1,0,0,0)
        root.Size=UDim2.new(1,0,0,46);repaint()
    end
    function h:Set(v,fire)
        selection=v;close()
        if fire then callback(self.Window,options.Callback,v) end
    end
    function h:Get() return selection end
    function h:SetOptions(list)
        values=list or {}
        for _,conn in ipairs(optionListeners) do pcall(function() conn:Disconnect() end) end
        table.clear(optionListeners)
        for _,child in ipairs(popup:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for i,v in ipairs(values) do
            local item=button(popup,tostring(v),UDim2.new(1,-6,0,35));item.LayoutOrder=i;item.ZIndex=26;item.TextSize=12
            -- Dynamic entries own their connection; do not grow Window.Connections on refresh.
            optionListeners[#optionListeners+1]=item.Activated:Connect(function()
                if self.Window.Alive then callback(self.Window,function() h:Set(v,true) end) end
            end)
        end
        close()
    end
    connect(self.Window,trigger.Activated,function()
        opened=not opened
        if opened then
            local height=math.min(180,math.max(42,#values*39+8))
            -- Open inline to avoid the parent scrolling frame clipping the options.
            root.Size=UDim2.new(1,0,0,46+height+4)
            popup.Visible=true;popup.Size=UDim2.new(1,0,0,height)
        else close() end
        repaint()
    end)
    h:SetOptions(values);repaint()
    return h
end
function Tab:AddKeybind(options)
    options=options or {}
    local key=options.Default or Enum.KeyCode.Unknown
    local armed=false
    local b=button(self.Page,"")
    local h=control(self,b)
    local function repaint() b.Text=tostring(options.Name or "Keybind")..": "..(armed and "Press any key..." or key.Name) end
    function h:Set(value) if typeof(value)=="EnumItem" and value.EnumType==Enum.KeyCode then key=value;armed=false;repaint() end end
    function h:Get() return key end
    connect(self.Window,b.Activated,function() armed=not armed;repaint() end)
    connect(self.Window,UIS.InputBegan,function(input,processed)
        if armed and input.KeyCode~=Enum.KeyCode.Unknown then h:Set(input.KeyCode)
        elseif not processed and not UIS:GetFocusedTextBox() and input.KeyCode==key then callback(self.Window,options.Callback) end
    end)
    repaint()
    return h
end

local Window = {}
Window.__index=Window
function Library.new(opts)
    opts=opts or {}
    local id=tostring(opts.Id or "default")
    local previous=activeWindows[id]
    if previous and previous.Alive then previous:Destroy() end
    local player=Players.LocalPlayer
    if not player then error("[AERO GUI] LocalPlayer is unavailable") end
    local pg=player:WaitForChild("PlayerGui",10)
    if not pg then error("[AERO GUI] PlayerGui is unavailable") end
    local saved=opts.SavePreferences~=false and loadPrefs(id) or nil
    local oldGui=pg:FindFirstChild("AERO_GUI_"..id:gsub("[^%w_]","_"))
    if oldGui then pcall(function() oldGui:Destroy() end) end
    local gui=create("ScreenGui",{Name="AERO_GUI_"..id:gsub("[^%w_]","_"),ResetOnSpawn=false,
        IgnoreGuiInset=false,DisplayOrder=tonumber(opts.DisplayOrder) or 500,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
    local root=create("Frame",{Name="Viewport",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0},gui)
    local self=setmetatable({Id=id,Alive=true,Gui=gui,Root=root,Connections={},Tabs={},TabList={},History={},Recent={},
        Favorites={},Errors={},ErrorCount=0,CurrentTab=nil,PreferredScale=math.clamp(tonumber(opts.Scale) or 1,0.65,1.5),
        Width=tonumber(opts.Width) or 380,Height=tonumber(opts.Height) or 620,Fullscreen=false,Adaptive=opts.Adaptive~=false,
        MenuOpen=false,Wide=false,Group=1,ReducedMotion=false,Minimized=false,
        Stats={filters=0,animations=0,layout=0},ConfigVersion=1,DisableSave=opts.SavePreferences==false,OnClose=opts.OnClose,InitialLayout=true},Window)
    activeWindows[id]=self
    if saved then
        self.PreferredScale=math.clamp(tonumber(saved.scale) or self.PreferredScale,0.65,1.5)
        self.Width=math.clamp(tonumber(saved.width) or self.Width,280,1200)
        self.Height=math.clamp(tonumber(saved.height) or self.Height,300,1200)
        self.Fullscreen=saved.fullscreen==true
        self.Adaptive=saved.adaptive~=false
        self.Group=math.clamp(tonumber(saved.group) or 1,1,8)
        self.ReducedMotion=saved.reducedMotion==true
        if type(saved.favorites)=="table" then self.Favorites=saved.favorites end
        if type(saved.recent)=="table" then self.Recent=saved.recent end
        self.RestoreTab=type(saved.lastTab)=="string" and saved.lastTab or nil
    end
    local main=create("Frame",{Name="Main",Visible=true,Size=UDim2.fromOffset(self.Width,self.Height),
        Position=UDim2.new(.5,-self.Width/2,.5,-self.Height/2),BackgroundColor3=COLORS.bg,
        BorderSizePixel=0,Active=true},root)
    self.Main=main;corner(main,13);create("UIStroke",{Color=COLORS.surface,Thickness=1},main)
    local scale=create("UIScale",{Scale=1},main);self.Scale=scale
    local header=create("Frame",{Name="Header",Size=UDim2.new(1,0,0,52),BackgroundColor3=COLORS.bg,
        BorderSizePixel=0,Active=true},main)
    corner(header,13)
    local title=label(header,"   "..tostring(opts.Title or "AERO  /  UNIVERSAL"),UDim2.new(1,-102,1,0))
    title.Font=Enum.Font.GothamBold;self.Title=title
    local minimize=button(header,"−",UDim2.fromOffset(38,40));minimize.Position=UDim2.new(1,-83,0,8)
    local close=button(header,"×",UDim2.fromOffset(38,40));close.Position=UDim2.new(1,-42,0,8)
    local content=create("Frame",{Name="Content",Position=UDim2.fromOffset(0,52),Size=UDim2.new(1,0,1,-52),BackgroundTransparency=1},main)
    local nav=create("Frame",{Name="Navigation",Size=UDim2.new(1,0,0,48),BackgroundTransparency=1},content)
    local back=button(nav,"<",UDim2.fromOffset(40,40));back.Position=UDim2.fromOffset(12,4)
    local currentTitle=label(nav,"Home",UDim2.new(1,-164,1,0));currentTitle.Position=UDim2.fromOffset(64,0)
    currentTitle.Font=Enum.Font.GothamBold;currentTitle.TextSize=17;self.CurrentTitle=currentTitle
    local tools=button(nav,"Tools",UDim2.fromOffset(72,40));tools.Position=UDim2.new(1,-84,0,4)
    local pages=create("Frame",{Name="Pages",Position=UDim2.fromOffset(12,60),Size=UDim2.new(1,-24,1,-138),BackgroundTransparency=1},content)
    self.Pages=pages
    local bottom=create("Frame",{Name="BottomNav",Position=UDim2.new(0,12,1,-66),Size=UDim2.new(1,-24,0,54),BackgroundColor3=COLORS.panel,BorderSizePixel=0},content)
    corner(bottom,10)
    create("UIGridLayout",{CellSize=UDim2.new(1/6,-5,1,0),CellPadding=UDim2.fromOffset(6,0),SortOrder=Enum.SortOrder.LayoutOrder},bottom)
    self.BottomNav=bottom
    local quick={}
    for i,entry in ipairs({{"Home","Home"},{"Farm","Farm"},{"Gifts","Gifts"},{"Boxes","Lootboxes"},{"Rewards","Rewards"},{"Tools",false}}) do
        local b=button(bottom,entry[1]);b.TextSize=11;b.LayoutOrder=i;quick[entry[2] or "Tools"]=b
        connect(self,b.Activated,function()
            if entry[2] and self.Tabs[entry[2]] then self:SelectTab(entry[2]) else self:ToggleMenu() end
        end)
    end
    self.QuickNav=quick
    local shade=create("TextButton",{Name="Shade",Size=UDim2.fromScale(1,1),Text="",BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=.45,BorderSizePixel=0,Visible=false,ZIndex=80},content)
    local drawer=create("Frame",{Name="ToolDrawer",Position=UDim2.fromOffset(12,60),Size=UDim2.new(0,340,1,-138),
        BackgroundColor3=COLORS.panel,BorderSizePixel=0,ClipsDescendants=true,ZIndex=90},content)
    corner(drawer,12);create("UIStroke",{Color=COLORS.surface,Thickness=1},drawer)
    local search=inputBox(drawer,"Search all tools...",UDim2.new(1,-24,0,42))
    search.Position=UDim2.fromOffset(12,12);search.ZIndex=91
    local category=button(drawer,"All  /  change",UDim2.new(1,-80,0,36));category.Position=UDim2.fromOffset(12,62);category.ZIndex=91
    local pin=button(drawer,"Pin",UDim2.fromOffset(48,36));pin.Position=UDim2.new(1,-60,0,62);pin.ZIndex=91
    local list=create("ScrollingFrame",{Name="MenuList",Position=UDim2.fromOffset(12,106),Size=UDim2.new(1,-24,1,-146),
        BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollingDirection=Enum.ScrollingDirection.Y,ZIndex=91},drawer)
    local menuGrid=create("UIGridLayout",{CellSize=UDim2.new(.5,-4,0,48),CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},list)
    local status=label(drawer,"",UDim2.new(1,-24,0,28),COLORS.muted)
    status.Position=UDim2.new(0,12,1,-34);status.TextSize=11;status.ZIndex=91
    self.Drawer=drawer;self.Shade=shade;self.Search=search;self.Category=category;self.Pin=pin
    self.MenuList=list;self.MenuGrid=menuGrid;self.MenuStatus=status
    self.Groups={"All","Favorites","Recent","Inspect","Record","Analyze","Develop","Manage"}
    local launcher=button(root,"AERO",UDim2.fromOffset(70,42));launcher.Position=UDim2.new(0,12,.5,-21)
    launcher.BackgroundColor3=COLORS.accent;launcher.Visible=false;self.Launcher=launcher
    self.ToastHolder=create("Frame",{Name="Toasts",Position=UDim2.new(1,-320,0,12),Size=UDim2.fromOffset(300,270),BackgroundTransparency=1,ZIndex=120},root)
    create("UIListLayout",{Padding=UDim.new(0,6),VerticalAlignment=Enum.VerticalAlignment.Top},self.ToastHolder)

    -- AERO Universal's mobile drag behavior, with screen-size clamping and scaled dimensions.
    local dragging,startInput,startXY,startPos=false,nil,nil,nil
    connect(self,header.InputBegan,function(input)
        if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        dragging=true;startInput=input;startXY=input.Position;startPos=main.AbsolutePosition
    end)
    connect(self,UIS.InputChanged,function(input)
        if not dragging or not startXY then return end
        if startInput.UserInputType==Enum.UserInputType.Touch then
            if input~=startInput then return end
        elseif input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local delta=input.Position-startXY
        local screen=root.AbsoluteSize
        local width=main.Size.X.Offset*scale.Scale;local height=main.Size.Y.Offset*scale.Scale
        main.Position=UDim2.fromOffset(math.clamp(startPos.X+delta.X-root.AbsolutePosition.X,0,math.max(0,screen.X-width)),
            math.clamp(startPos.Y+delta.Y-root.AbsolutePosition.Y,0,math.max(0,screen.Y-height)))
    end)
    connect(self,UIS.InputEnded,function(input)
        if startInput and (input==startInput or (startInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)) then
            dragging=false;startInput=nil
        end
    end)
    connect(self,minimize.Activated,function() self:SetMinimized(true) end)
    connect(self,launcher.Activated,function() self:SetMinimized(false) end)
    connect(self,close.Activated,function() self:Destroy() end)
    connect(self,tools.Activated,function() self:ToggleMenu() end)
    connect(self,shade.Activated,function() self:SetMenuOpen(false) end)
    connect(self,back.Activated,function()
        local prior=table.remove(self.History)
        if prior then self.Backtracking=true;self:SelectTab(prior);self.Backtracking=false end
    end)
    connect(self,search:GetPropertyChangedSignal("Text"),function() self:RefreshMenu() end)
    connect(self,search.Focused,function()
        if not self.Wide then list.Size=UDim2.new(1,-24,0,math.max(72,math.min(180,drawer.AbsoluteSize.Y-190))) end
    end)
    connect(self,search.FocusLost,function() list.Size=UDim2.new(1,-24,1,-146) end)
    connect(self,category.Activated,function()
        self.Group=self.Group%#self.Groups+1;list.CanvasPosition=Vector2.new(0,0);self:RefreshMenu();self:QueueSave()
    end)
    connect(self,pin.Activated,function()
        local tab=self.CurrentTab
        if not tab then return end
        for i,name in ipairs(self.Favorites) do if name==tab then table.remove(self.Favorites,i);self:RefreshMenu();self:QueueSave();return end end
        if #self.Favorites<12 then table.insert(self.Favorites,tab) end
        self:RefreshMenu();self:QueueSave()
    end)
    connect(self,root:GetPropertyChangedSignal("AbsoluteSize"),function() self:ApplyLayout(false) end)
    connect(self,gui.Destroying,function()
        if self.Alive then self:Destroy() end
    end)
    self:ApplyLayout(true)
    self:SetMenuOpen(false,true)
    return self
end

function Window:QueueSave()
    if not self.Alive or self.DisableSave then return end
    self.SaveSerial=(self.SaveSerial or 0)+1
    local n=self.SaveSerial
    task.delay(.7,function() if self.Alive and self.SaveSerial==n then self:SavePreferences() end end)
end
function Window:SavePreferences()
    return savePrefs(self.Id,{version=1,width=self.Width,height=self.Height,scale=self.PreferredScale,
        fullscreen=self.Fullscreen,adaptive=self.Adaptive,group=self.Group,reducedMotion=self.ReducedMotion,
        lastTab=self.CurrentTab,favorites=self.Favorites,recent=self.Recent})
end
function Window:SetMinimized(value)
    self.Minimized=value==true
    self.Main.Visible=not self.Minimized;self.Launcher.Visible=self.Minimized
    if not self.Minimized then self:ApplyLayout(false) end
end
function Window:SetMenuOpen(value,instant)
    if not self.Alive then return end
    if self.Wide then value=true end
    self.MenuOpen=value==true
    if self.MenuConn then self.MenuConn:Disconnect();self.MenuConn=nil end
    self.Shade.Visible=self.MenuOpen and not self.Wide
    local target=self.MenuOpen and 0 or -(self.DrawerWidth or 340)-24
    local current=self.Drawer.Position.X.Offset-12
    if instant or self.ReducedMotion or self.Wide or not self.Main.Visible then
        self.Drawer.Position=UDim2.fromOffset(12+target,60)
        self.Drawer.Visible=self.MenuOpen
        return
    end
    self.Drawer.Visible=true
    local spring=Spring.new(target,{frequency=7,dampingRatio=1})
    local state={value=current,velocity=0}
    self.Stats.animations=self.Stats.animations+1
    self.MenuConn=RunService.Heartbeat:Connect(function(dt)
        if not self.Alive then if self.MenuConn then self.MenuConn:Disconnect();self.MenuConn=nil end;return end
        state=spring:step(state,math.min(dt,.1))
        self.Drawer.Position=UDim2.fromOffset(12+state.value,60)
        if state.complete then
            self.MenuConn:Disconnect();self.MenuConn=nil
            self.Drawer.Visible=self.MenuOpen
        end
    end)
end
function Window:ToggleMenu() self:SetMenuOpen(not self.MenuOpen) end
function Window:RefreshMenu()
    if not self.Alive then return end
    self.Stats.filters=self.Stats.filters+1
    local count=0
    local query=self.Search.Text:lower():sub(1,120)
    local group=self.Groups[self.Group] or "All"
    for i,tab in ipairs(self.TabList) do
        local b=tab.MenuButton
        local matches=true
        if query~="" then
            local searchText=(tab.Name.." "..tab.Group.." "..tostring(tab.SearchTerms or "")):lower()
            for word in query:gmatch("%S+") do if not searchText:find(word,1,true) then matches=false;break end end
        elseif group~="All" then
            if group=="Favorites" or group=="Recent" then
                matches=false
                for _,name in ipairs(group=="Favorites" and self.Favorites or self.Recent) do if name==tab.Name then matches=true;break end end
            else matches=tab.Group==group end
        end
        b.Visible=matches;b.LayoutOrder=i;b.BackgroundColor3=tab.Name==self.CurrentTab and COLORS.selected or COLORS.surface
        if matches then count=count+1 end
    end
    self.Category.Text=group.."  /  change"
    local pinned=false
    for _,name in ipairs(self.Favorites) do if name==self.CurrentTab then pinned=true end end
    self.Pin.Text=pinned and "Unpin" or "Pin"
    self.MenuStatus.Text=count==0 and "No matching tools. Try another search." or (count.." tools  |  tap to open")
end
function Window:SelectTab(name)
    if not self.Tabs[name] then return false end
    local previous=self.CurrentTab
    if previous and previous~=name and not self.Backtracking then
        table.insert(self.History,previous)
        while #self.History>20 do table.remove(self.History,1) end
    end
    self.CurrentTab=name
    for _,tab in ipairs(self.TabList) do tab.Page.Visible=tab.Name==name end
    for i=#self.Recent,1,-1 do if self.Recent[i]==name then table.remove(self.Recent,i) end end
    table.insert(self.Recent,1,name)
    while #self.Recent>8 do table.remove(self.Recent) end
    self.CurrentTitle.Text=name
    for tab,b in pairs(self.QuickNav) do b.BackgroundColor3=tab==name and COLORS.selected or COLORS.surface end
    if not self.Wide then self:SetMenuOpen(false,true) end
    self:RefreshMenu();self:QueueSave()
    return true
end
function Window:AddTab(name,group)
    assert(self.Alive,"Window has been destroyed")
    assert(type(name)=="string" and name~="","Tab needs a name")
    if self.Tabs[name] then return self.Tabs[name] end
    local page=create("ScrollingFrame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundColor3=COLORS.panel,BorderSizePixel=0,
        ScrollBarThickness=3,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},self.Pages)
    corner(page,9)
    create("UIPadding",{PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},page)
    create("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},page)
    local tab=setmetatable({Name=name,Group=group or "Manage",Page=page,Window=self},Tab)
    self.Tabs[name]=tab;table.insert(self.TabList,tab)
    local b=button(self.MenuList,name,UDim2.fromOffset(83,38));b.ZIndex=92;b.TextSize=13
    tab.MenuButton=b
    connect(self,b.Activated,function() self:SelectTab(name) end)
    if #self.TabList==1 or self.RestoreTab==name then self:SelectTab(name) end
    self:RefreshMenu()
    return tab
end
function Window:ApplyLayout(center)
    if not self.Alive then return end
    local view=self.Root.AbsoluteSize
    local w,h,s,x,y=geometry(view.X,view.Y,self.Width,self.Height,self.PreferredScale,self.Fullscreen,self.Adaptive)
    if not w then return end
    self.Main.Size=UDim2.fromOffset(w,h);self.Scale.Scale=s
    if x==nil then
        x=self.Main.Position.X.Scale*view.X+self.Main.Position.X.Offset
        y=self.Main.Position.Y.Scale*view.Y+self.Main.Position.Y.Offset
        if center or self.InitialLayout then x=(view.X-w*s)/2;y=(view.Y-h*s)/2 end
    end
    x=math.clamp(x,0,math.max(0,view.X-w*s));y=math.clamp(y,0,math.max(0,view.Y-h*s))
    self.Main.Position=UDim2.fromOffset(x,y)
    self.InitialLayout=false
    local layout=frameModel(math.min(w,w*s))
    self.Wide=layout.wide;self.DrawerWidth=math.min(layout.drawerWidth,math.max(180,w-24))
    self.BottomNav.Visible=not layout.wide
    self.Pages.Position=UDim2.fromOffset(layout.pageX,layout.pageY)
    self.Pages.Size=UDim2.new(1,-layout.pageX-layout.pageRight,1,-layout.pageY-layout.pageBottom)
    self.Drawer.Size=UDim2.new(0,self.DrawerWidth,1,layout.wide and -72 or -138)
    self.MenuGrid.CellSize=UDim2.new(1/(w<310 and 1 or layout.columns),-4,0,48)
    if layout.wide then self:SetMenuOpen(true,true) else self:SetMenuOpen(false,true) end
    self.Stats.layout=self.Stats.layout+1
    self.ToastHolder.Position=UDim2.new(1,-math.min(320,view.X),0,12)
end
function Window:SetScale(percent)
    local n=tonumber(percent)
    if not n then return false end
    if n>2 then n=n/100 end
    self.PreferredScale=math.clamp(n,.65,1.5)
    self:ApplyLayout(true);self:QueueSave();return true
end
function Window:SetSize(width,height)
    local w=tonumber(width);local h=tonumber(height)
    if not w or not h or w<280 or w>1200 or h<300 or h>1200 then return false end
    self.Width=math.floor(w);self.Height=math.floor(h);self.Adaptive=false;self.Fullscreen=false
    self:ApplyLayout(true);self:QueueSave();return true
end
function Window:SetAdaptive(value)
    self.Adaptive=value~=false;self.Fullscreen=false;self:ApplyLayout(true);self:QueueSave()
end
function Window:SetFullscreen(value)
    self.Fullscreen=value==true;self:ApplyLayout(true);self:QueueSave()
end
function Window:SetTitle(value) self.Title.Text="   "..tostring(value or "AERO") end
function Window:Notify(title,body,seconds)
    if not self.Alive then return end
    local toast=create("Frame",{Name="Toast",Size=UDim2.new(1,0,0,70),BackgroundColor3=COLORS.panel,BorderSizePixel=0,ZIndex=121},self.ToastHolder)
    corner(toast,8);create("UIStroke",{Color=COLORS.accent,Thickness=1},toast)
    local t=label(toast,title,UDim2.new(1,-16,0,24));t.Position=UDim2.fromOffset(8,6);t.ZIndex=122;t.Font=Enum.Font.GothamBold
    local b=label(toast,body,UDim2.new(1,-16,0,32),COLORS.muted);b.Position=UDim2.fromOffset(8,30);b.ZIndex=122
    task.delay(math.clamp(tonumber(seconds) or 3,1,15),function() if toast.Parent then toast:Destroy() end end)
end
function Window:GetDiagnostics()
    local active=0
    for _,conn in ipairs(self.Connections) do if conn.Connected then active=active+1 end end
    return {alive=self.Alive,tabs=#self.TabList,connections=active,errors=self.ErrorCount,
        menuFilters=self.Stats.filters,animations=self.Stats.animations,layoutChanges=self.Stats.layout,
        page=self.CurrentTab,wide=self.Wide,scale=self.Scale.Scale}
end
function Window:SetGroups(groups)
    assert(type(groups)=="table" and #groups>=1,"Expected a list of group names")
    self.Groups={"All","Favorites","Recent"}
    for _,name in ipairs(groups) do
        if type(name)=="string" and name~="All" and name~="Favorites" and name~="Recent" then
            table.insert(self.Groups,name)
        end
    end
    self.Group=1
    self:RefreshMenu()
end
function Window:AddSettingsTab(name)
    name=name or "Settings"
    if self.Tabs[name] then return self.Tabs[name] end
    local tab=self:AddTab(name,"Manage")
    tab:AddSection("Display & navigation")
    local status=tab:AddLabel("Adaptive fit keeps the GUI visible on mobile.")
    tab:AddButton({Name="Adaptive fit (recommended)",Callback=function()
        self:SetAdaptive(true);status:Set("Adaptive layout enabled")
    end})
    tab:AddButton({Name="Toggle full screen",Callback=function()
        self:SetFullscreen(not self.Fullscreen);status:Set(self.Fullscreen and "Full screen" or "Windowed")
    end})
    tab:AddToggle({Name="Reduced motion",Default=self.ReducedMotion,Callback=function(v)
        self.ReducedMotion=v;self:QueueSave()
    end})
    local w=tab:AddInput({Name="Custom width (280–1200)",Default=self.Width})
    local h=tab:AddInput({Name="Custom height (300–1200)",Default=self.Height})
    local sc=tab:AddInput({Name="Interface scale (65–150%)",Default=math.floor(self.PreferredScale*100)})
    tab:AddButton({Name="Apply custom size",Callback=function()
        local width,height,percent=tonumber(w:Get()),tonumber(h:Get()),tonumber(sc:Get())
        if not width or not height or not percent or percent<65 or percent>150 then
            status:Set("Width 280–1200, height 300–1200, scale 65–150 required")
            return
        end
        if not self:SetSize(width,height) then status:Set("Invalid width or height");return end
        self:SetScale(percent);status:Set("Custom size applied")
    end})
    tab:AddButton({Name="Phone preset: 380 × 620",Callback=function()
        self:SetSize(380,620);w:Set(380);h:Set(620);status:Set("Phone size applied")
    end})
    tab:AddButton({Name="Wide preset: 860 × 560",Callback=function()
        self:SetSize(860,560);w:Set(860);h:Set(560);status:Set("Wide size applied")
    end})
    tab:AddButton({Name="Center window",Callback=function() self:ApplyLayout(true) end})
    tab:AddButton({Name="Save GUI preferences",Callback=function()
        local ok,reason=self:SavePreferences()
        status:Set(ok and "Preferences saved" or "Save unavailable: "..tostring(reason))
    end})
    tab:AddButton({Name="Reset navigation preferences",Callback=function()
        self.Favorites={};self.Recent={};self.Group=1;self.Search.Text=""
        self:RefreshMenu();self:QueueSave();status:Set("Navigation preferences reset")
    end})
    local diagnostics=tab:AddLabel("GUI diagnostics available")
    tab:AddButton({Name="Refresh GUI diagnostics",Callback=function()
        local report=self:GetDiagnostics()
        diagnostics:Set(string.format("Tabs: %d  |  Listeners: %d  |  Errors: %d  |  Layouts: %d",report.tabs,report.connections,report.errors,report.layoutChanges))
    end})
    return tab
end

function Window:Destroy()
    if not self.Alive then return end
    if not self.DisableSave then pcall(function() self:SavePreferences() end) end
    self.Alive=false
    -- A close button on a game-specific window unloads the game script too.
    -- Alive=false is set first to prevent recursive unload during cleanup.
    if type(self.OnClose)=="function" then
        local closeCallback=self.OnClose
        self.OnClose=nil
        local ok,err=pcall(closeCallback)
        if not ok then warn("[AERO GUI] Close callback: "..tostring(err)) end
    end
    if self.MenuConn then self.MenuConn:Disconnect();self.MenuConn=nil end
    for _,c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    self.Connections={}
    pcall(function() self.Gui:Destroy() end)
    if activeWindows[self.Id]==self then activeWindows[self.Id]=nil end
end
Library.CreateWindow=Library.new
Library.GetActive=function(id) return activeWindows[id or "default"] end
return Library

end)()

-- P24.4: Embedded ZHub exact-extraction console (custom responsive viewport).
-- The UI below is copied from the user's ZHub_Console_Exact_Extraction.lua.
-- It is hosted in AERO's existing Console tab, not an independent ScreenGui.
-- The recovered empty LocalScript placeholders are intentionally omitted.
local function mountZHubConsole(tab)
    local window=tab.Window
    local heading=tab:AddSection("ZHub Console • Live Output")
    heading.Instance.LayoutOrder=-300
    local statusHandle=tab:AddLabel("Connecting to LogService…")
    statusHandle.Instance.LayoutOrder=-299
    local host=Instance.new("Frame")
    host.Name="ZHubConsoleHost"
    host.LayoutOrder=-298
    host.Size=UDim2.new(1,0,0,380)
    host.BackgroundColor3=Color3.fromRGB(20,20,20)
    host.BorderSizePixel=0
    host.ClipsDescendants=true
    host.Parent=tab.Page
    Instance.new("UICorner",host).CornerRadius=UDim.new(0,10)
    local G2L={}
    -- StarterGui.zerohub.interface.main.tabs.console
    G2L["107"] = Instance.new("Frame", host);
    G2L["107"]["Visible"] = false;
    G2L["107"]["BorderSizePixel"] = 0;
    G2L["107"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["107"]["Size"] = UDim2.new(0, 480, 0, 276);
    G2L["107"]["Position"] = UDim2.new(-0, 0, 0.1068, 0);
    G2L["107"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["107"]["Name"] = [[console]];
    G2L["107"]["BackgroundTransparency"] = 1;


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder
    G2L["108"] = Instance.new("Frame", G2L["107"]);
    G2L["108"]["BorderSizePixel"] = 0;
    G2L["108"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["108"]["Size"] = UDim2.new(0, 341, 0, 37);
    G2L["108"]["Position"] = UDim2.new(0.27026, 0, 0.87333, 0);
    G2L["108"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["108"]["Name"] = [[buttonsholder]];
    G2L["108"]["BackgroundTransparency"] = 1;


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.clear
    G2L["109"] = Instance.new("TextButton", G2L["108"]);
    G2L["109"]["BorderSizePixel"] = 0;
    G2L["109"]["TextXAlignment"] = Enum.TextXAlignment.Right;
    G2L["109"]["TextSize"] = 14;
    G2L["109"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["109"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
    G2L["109"]["FontFace"] = Font.new([[rbxassetid://16658237174]],
    Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    G2L["109"]["Size"] = UDim2.new(0, 62, 0, 24);
    G2L["109"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["109"]["Text"] = [[Clear ]];
    G2L["109"]["Name"] = [[clear]];
    G2L["109"]["Position"] = UDim2.new(0.41935, 0, 0.17568, 0);
    -- Attributes
    G2L["109"]:SetAttribute([[OriginalColor]], Color3.fromRGB(31, 31, 31));


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.clear.anim


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.clear.LocalScript
    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.clear.UICorner
    G2L["10c"] = Instance.new("UICorner", G2L["109"]);



    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.clear.ImageLabel
    G2L["10d"] = Instance.new("ImageLabel", G2L["109"]);
    G2L["10d"]["BorderSizePixel"] = 0;
    G2L["10d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["10d"]["ImageColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["10d"]["Image"] = [[rbxassetid://10709819059]];
    G2L["10d"]["Size"] = UDim2.new(0, 15, 0, 15);
    G2L["10d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["10d"]["BackgroundTransparency"] = 1;
    G2L["10d"]["Position"] = UDim2.new(0.085, 0, 0.22, 0);


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.UIListLayout
    G2L["10e"] = Instance.new("UIListLayout", G2L["108"]);
    G2L["10e"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Right;
    G2L["10e"]["Padding"] = UDim.new(0, 5);
    G2L["10e"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
    G2L["10e"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
    G2L["10e"]["FillDirection"] = Enum.FillDirection.Horizontal;


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.save
    G2L["10f"] = Instance.new("TextButton", G2L["108"]);
    G2L["10f"]["BorderSizePixel"] = 0;
    G2L["10f"]["TextXAlignment"] = Enum.TextXAlignment.Right;
    G2L["10f"]["TextSize"] = 14;
    G2L["10f"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["10f"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
    G2L["10f"]["FontFace"] = Font.new([[rbxassetid://16658237174]],
    Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    G2L["10f"]["Size"] = UDim2.new(0, 62, 0, 24);
    G2L["10f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["10f"]["Text"] = [[Save ]];
    G2L["10f"]["Name"] = [[save]];
    G2L["10f"]["Position"] = UDim2.new(0.60704, 0, 0.17568, 0);
    -- Attributes
    G2L["10f"]:SetAttribute([[OriginalColor]], Color3.fromRGB(31, 31, 31));


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.save.anim


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.save.LocalScript
    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.save.UICorner
    G2L["112"] = Instance.new("UICorner", G2L["10f"]);

    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.save.ImageLabel
    G2L["113"] = Instance.new("ImageLabel", G2L["10f"]);
    G2L["113"]["BorderSizePixel"] = 0;
    G2L["113"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["113"]["ImageColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["113"]["Image"] = [[rbxassetid://10734941499]];
    G2L["113"]["Size"] = UDim2.new(0, 15, 0, 15);
    G2L["113"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["113"]["BackgroundTransparency"] = 1;
    G2L["113"]["Position"] = UDim2.new(0.085, 0, 0.22, 0);


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.copy
    G2L["114"] = Instance.new("TextButton", G2L["108"]);
    G2L["114"]["BorderSizePixel"] = 0;
    G2L["114"]["TextXAlignment"] = Enum.TextXAlignment.Right;
    G2L["114"]["TextSize"] = 14;
    G2L["114"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["114"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
    G2L["114"]["FontFace"] = Font.new([[rbxassetid://16658237174]],
    Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    G2L["114"]["Size"] = UDim2.new(0, 64, 0, 24);
    G2L["114"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["114"]["Text"] = [[Copy ]];
    G2L["114"]["Name"] = [[copy]];
    G2L["114"]["Position"] = UDim2.new(0.81232, 0, 0.17568, 0);
    -- Attributes
    G2L["114"]:SetAttribute([[OriginalColor]], Color3.fromRGB(31, 31, 31));


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.copy.anim


    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.copy.LocalScript
    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.copy.UICorner
    G2L["117"] = Instance.new("UICorner", G2L["114"]);



    -- StarterGui.zerohub.interface.main.tabs.console.buttonsholder.copy.ImageLabel
    G2L["118"] = Instance.new("ImageLabel", G2L["114"]);
    G2L["118"]["BorderSizePixel"] = 0;
    G2L["118"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["118"]["ImageColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["118"]["Image"] = [[rbxassetid://10709812159]];
    G2L["118"]["Size"] = UDim2.new(0, 15, 0, 15);
    G2L["118"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["118"]["BackgroundTransparency"] = 1;
    G2L["118"]["Position"] = UDim2.new(0.085, 0, 0.22, 0);


    -- StarterGui.zerohub.interface.main.tabs.console.consoleholder
    G2L["119"] = Instance.new("Frame", G2L["107"]);
    G2L["119"]["BorderSizePixel"] = 0;

    G2L["119"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
    G2L["119"]["Size"] = UDim2.new(0, 461, 0, 241);
    G2L["119"]["Position"] = UDim2.new(0.02083, 0, 0.00181, 0);
    G2L["119"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["119"]["Name"] = [[consoleholder]];
    -- Attributes
    G2L["119"]:SetAttribute([[OriginalColor]], Color3.fromRGB(31, 31, 31));


    -- StarterGui.zerohub.interface.main.tabs.console.consoleholder.UICorner
    G2L["11a"] = Instance.new("UICorner", G2L["119"]);



    -- StarterGui.zerohub.interface.main.tabs.console.consoleholder.c
    G2L["11b"] = Instance.new("ScrollingFrame", G2L["119"]);
    G2L["11b"]["Active"] = true;
    G2L["11b"]["BorderSizePixel"] = 0;
    G2L["11b"]["CanvasSize"] = UDim2.new(0, 0, 0, 1300);
    G2L["11b"]["Name"] = [[c]];
    G2L["11b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["11b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
    G2L["11b"]["Size"] = UDim2.new(0.97121, 0, 0.93, 0);
    G2L["11b"]["Position"] = UDim2.new(0.50108, 0, 0.5, 0);
    G2L["11b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["11b"]["ScrollBarThickness"] = 0;
    G2L["11b"]["BackgroundTransparency"] = 1;


    -- StarterGui.zerohub.interface.main.tabs.console.consoleholder.c.yesc
    G2L["11c"] = Instance.new("TextBox", G2L["11b"]);
    G2L["11c"]["Name"] = [[yesc]];
    G2L["11c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
    G2L["11c"]["PlaceholderColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["11c"]["BorderSizePixel"] = 0;
    G2L["11c"]["TextEditable"] = false;
    G2L["11c"]["TextWrapped"] = true;
    G2L["11c"]["TextSize"] = 13;
    G2L["11c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["11c"]["TextYAlignment"] = Enum.TextYAlignment.Top;
    G2L["11c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["11c"]["RichText"] = true;
    G2L["11c"]["FontFace"] = Font.new([[rbxassetid://16658246179]],
    Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    G2L["11c"]["MultiLine"] = true;
    G2L["11c"]["ClearTextOnFocus"] = false;
    G2L["11c"]["PlaceholderText"] = [[No console logs yet.]];
    G2L["11c"]["Size"] = UDim2.new(1, 0, 0, 1300);
    G2L["11c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["11c"]["Text"] = [[]];
    G2L["11c"]["BackgroundTransparency"] = 1;


    -- StarterGui.zerohub.interface.main.tabs.console.consoleholder.c.yesc.LocalScript
    -- StarterGui.zerohub.interface.main.tabs.console.savedialog
    G2L["11e"] = Instance.new("Frame", G2L["107"]);
    G2L["11e"]["Visible"] = false;
    G2L["11e"]["BorderSizePixel"] = 0;
    G2L["11e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["11e"]["Size"] = UDim2.new(1, 0, 1, 0);
    G2L["11e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["11e"]["Name"] = [[savedialog]];
    G2L["11e"]["BackgroundTransparency"] = 0.2;


    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main
    G2L["11f"] = Instance.new("Frame", G2L["11e"]);
    G2L["11f"]["BorderSizePixel"] = 0;
    G2L["11f"]["BackgroundColor3"] = Color3.fromRGB(20, 20, 20);
    G2L["11f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
    G2L["11f"]["Size"] = UDim2.new(0, 274, 0, 126);
    G2L["11f"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
    G2L["11f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["11f"]["Name"] = [[main]];
    -- Attributes
    G2L["11f"]:SetAttribute([[OriginalColor]], Color3.fromRGB(21, 21, 21));


    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.UICorner
    G2L["120"] = Instance.new("UICorner", G2L["11f"]);



    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.tit(s)
    G2L["121"] = Instance.new("TextLabel", G2L["11f"]);
    G2L["121"]["BorderSizePixel"] = 0;

    G2L["121"]["TextSize"] = 20;
    G2L["121"]["TextXAlignment"] = Enum.TextXAlignment.Left;
    G2L["121"]["TextYAlignment"] = Enum.TextYAlignment.Top;
    G2L["121"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["121"]["FontFace"] = Font.new([[rbxassetid://16658237174]],
    Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    G2L["121"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["121"]["BackgroundTransparency"] = 1;
    G2L["121"]["Size"] = UDim2.new(0, 200, 0, 30);
    G2L["121"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["121"]["Text"] = [[Save in workspace]];
    G2L["121"]["Name"] = [[tit(s)]];
    G2L["121"]["Position"] = UDim2.new(0.03285, 0, 0.07143, 0);


    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.desc
    G2L["122"] = Instance.new("TextLabel", G2L["11f"]);
    G2L["122"]["TextWrapped"] = true;
    G2L["122"]["BorderSizePixel"] = 0;
    G2L["122"]["TextSize"] = 14;
    G2L["122"]["TextXAlignment"] = Enum.TextXAlignment.Left;
    G2L["122"]["TextYAlignment"] = Enum.TextYAlignment.Top;
    G2L["122"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["122"]["FontFace"] = Font.new([[rbxassetid://16658237174]],
    Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    G2L["122"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["122"]["BackgroundTransparency"] = 1;
    G2L["122"]["Size"] = UDim2.new(0, 258, 0, 30);
    G2L["122"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["122"]["Text"] = [[This will save a file in your exploit workspace folder.]];
    G2L["122"]["Name"] = [[desc]];
    G2L["122"]["Position"] = UDim2.new(0.03285, 0, 0.21429, 0);


    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.close
    G2L["123"] = Instance.new("ImageButton", G2L["11f"]);
    G2L["123"]["BorderSizePixel"] = 0;
    G2L["123"]["BackgroundTransparency"] = 1;
    G2L["123"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["123"]["Image"] = [[rbxassetid://10747384394]];
    G2L["123"]["Size"] = UDim2.new(0, 20, 0, 20);
    G2L["123"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["123"]["Name"] = [[close]];
    G2L["123"]["Position"] = UDim2.new(0.88321, 0, 0.11111, 0);


    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.close.LocalScript
    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.TextBox
    G2L["125"] = Instance.new("TextBox", G2L["11f"]);
    G2L["125"]["PlaceholderColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["125"]["BorderSizePixel"] = 0;
    G2L["125"]["TextWrapped"] = true;
    G2L["125"]["TextSize"] = 14;
    G2L["125"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["125"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
    G2L["125"]["FontFace"] = Font.new([[rbxassetid://16658237174]],

    Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    G2L["125"]["AnchorPoint"] = Vector2.new(0.5, 0);
    G2L["125"]["PlaceholderText"] = [[example.txt]];
    G2L["125"]["Size"] = UDim2.new(0, 253, 0, 25);
    G2L["125"]["Position"] = UDim2.new(0.5, 0, 0.51587, 0);
    G2L["125"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["125"]["Text"] = [[]];
    -- Attributes
    G2L["125"]:SetAttribute([[OriginalColor]], Color3.fromRGB(31, 31, 31));


    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.TextBox.UICorner
    G2L["126"] = Instance.new("UICorner", G2L["125"]);



    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.save
    G2L["127"] = Instance.new("TextButton", G2L["11f"]);
    G2L["127"]["BorderSizePixel"] = 0;
    G2L["127"]["TextXAlignment"] = Enum.TextXAlignment.Right;
    G2L["127"]["TextSize"] = 14;
    G2L["127"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["127"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
    G2L["127"]["FontFace"] = Font.new([[rbxassetid://16658237174]],
    Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    G2L["127"]["Size"] = UDim2.new(0, 62, 0, 24);
    G2L["127"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["127"]["Text"] = [[Done ]];
    G2L["127"]["Name"] = [[save]];
    G2L["127"]["Position"] = UDim2.new(0.73091, 0, 0.76, 0);
    -- Attributes
    G2L["127"]:SetAttribute([[OriginalColor]], Color3.fromRGB(31, 31, 31));


    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.save.anim


    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.save.LocalScript
    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.save.UICorner
    G2L["12a"] = Instance.new("UICorner", G2L["127"]);



    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.main.save.ImageLabel
    G2L["12b"] = Instance.new("ImageLabel", G2L["127"]);
    G2L["12b"]["BorderSizePixel"] = 0;
    G2L["12b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["12b"]["ImageColor3"] = Color3.fromRGB(101, 101, 101);
    G2L["12b"]["Image"] = [[rbxassetid://10709790644]];
    G2L["12b"]["Size"] = UDim2.new(0, 15, 0, 15);
    G2L["12b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["12b"]["BackgroundTransparency"] = 1;
    G2L["12b"]["Position"] = UDim2.new(0.085, 0, 0.22, 0);

    -- StarterGui.zerohub.interface.main.tabs.console.savedialog.UICorner
    G2L["12c"] = Instance.new("UICorner", G2L["11e"]);
    G2L["12c"]["CornerRadius"] = UDim.new(0, 0);



    -- Responsive adaptation: original 480x276 ZHub content, controls and icons
    -- are preserved; only its surrounding window and fixed dimensions change.
    local panel=G2L["107"]
    panel.Name="ZHubConsoleTabContent"
    panel.Size=UDim2.fromScale(1,1)
    panel.Position=UDim2.fromOffset(0,0)
    panel.Visible=true
    panel.ClipsDescendants=true
    G2L["108"].Size=UDim2.new(1,-16,0,38)
    G2L["108"].Position=UDim2.new(0,8,1,-42)
    G2L["119"].Size=UDim2.new(1,-16,1,-54)
    G2L["119"].Position=UDim2.fromOffset(8,6)
    G2L["11b"].ScrollBarThickness=3
    G2L["11b"].ScrollingDirection=Enum.ScrollingDirection.Y
    G2L["11c"].TextWrapped=true
    G2L["11c"].TextEditable=false
    G2L["11e"].Visible=false
    G2L["11e"].ZIndex=30
    G2L["11f"].Size=UDim2.new(1,-22,0,126)
    G2L["11f"].ZIndex=31
    G2L["125"].Size=UDim2.new(1,-20,0,25)
    for _,item in ipairs(G2L["11f"]:GetDescendants()) do
        if item:IsA("GuiObject") then item.ZIndex=32 end
    end
    local Log=game:GetService("LogService")
    local Run=game:GetService("RunService")
    local Tween=game:GetService("TweenService")
    local entries,first,last={},1,0
    local MAX_LOGS,MAX_BYTES,MAX_VISIBLE=600,2048,160
    local dirty,resize,follow=true,true,true
    local applyingScroll=false
    local elapsed=0
    local alive=true
    local listeners={}
    local tweens={}
    local output,scroll=G2L["11c"],G2L["11b"]
    local dialog,filename=G2L["11e"],G2L["125"]
    local palette={
        [Enum.MessageType.MessageOutput]="FFFFFF",
        [Enum.MessageType.MessageInfo]="84D6F7",
        [Enum.MessageType.MessageWarning]="FFFF00",
        [Enum.MessageType.MessageError]="FF0000"
    }
    local function connect(signal,fn)
        local c=signal:Connect(function(...)
            if alive and window.Alive then fn(...) end
        end)
        listeners[#listeners+1]=c
        return c
    end
    local function alert(text)
        if window.Alive then window:Notify("AERO Console",tostring(text),3) end
    end
    local function escape(s)
        return tostring(s):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;")
    end
    local function plain()
        local parts={}
        for i=first,last do
            local e=entries[i]
            if e then parts[#parts+1]=e.stamp.." "..e.msg end
        end
        return table.concat(parts,"\n")
    end
    local function truncate(s)
        s=tostring(s)
        if #s<=MAX_BYTES then return s end
        local limit=MAX_BYTES
        -- Do not cut UTF-8 continuation bytes.
        while limit>0 and s:byte(limit+1) and s:byte(limit+1)>=128 and s:byte(limit+1)<192 do
            limit-=1
        end
        return s:sub(1,limit).." [truncated]"
    end
    local function append(msg,kind)
        local t=DateTime.now().UnixTimestampMillis
        last+=1
        entries[last]={msg=truncate(msg),kind=kind,
            stamp=string.format("[%s.%03d]",os.date("%H:%M:%S",math.floor(t/1000)),t%1000)}
        if last-first+1>MAX_LOGS then entries[first]=nil first+=1 end
        if first>MAX_LOGS then
            local compact={}
            for i=first,last do compact[#compact+1]=entries[i] end
            entries=compact first=1 last=#compact
        end
        dirty=true
    end
    local function render()
        local parts={}
        local displayFrom=math.max(first,last-MAX_VISIBLE+1)
        for i=displayFrom,last do
            local e=entries[i]
            if e then
                parts[#parts+1]=string.format('<font color="#%s">%s %s</font>',
                    palette[e.kind] or "FFFFFF",e.stamp,escape(e.msg))
            end
        end
        output.Text=table.concat(parts,"\n")
        statusHandle:Set(string.format("Live PS99 + executor messages • %d stored • showing last %d (export saves all)",
            math.max(0,last-first+1),#parts))
        dirty=false resize=true
    end
    local function layout()
        if not alive or not output.Parent then return end
        local height=math.max(1,output.TextBounds.Y+6)
        applyingScroll=true
        output.Size=UDim2.new(1,0,0,height)
        scroll.CanvasSize=UDim2.fromOffset(0,height)
        if follow then
            scroll.CanvasPosition=Vector2.new(0,math.max(0,height-scroll.AbsoluteWindowSize.Y))
        end
        applyingScroll=false resize=false
    end
    local function stop()
        if not alive then return end
        alive=false
        for _,c in ipairs(listeners) do pcall(function() c:Disconnect() end) end
        table.clear(listeners)
        for _,t in pairs(tweens) do pcall(function() t:Cancel() end) end
        if REQUEST_STATUS.console and REQUEST_STATUS.console.host==host then
            REQUEST_STATUS.console=nil
        end
        if host.Parent then pcall(function() host:Destroy() end) end
    end
    onCleanup(stop)
    connect(host.Destroying,stop)
    local okListen,logErr=pcall(function()
        connect(Log.MessageOut,append)
    end)
    if not okListen then
        statusHandle:Set("LogService unavailable: "..tostring(logErr):sub(1,120))
    end
    -- Capture output emitted before this tab mounted, including bootstrap errors.
    local historyOK,history=pcall(function() return Log:GetLogHistory() end)
    if historyOK and type(history)=="table" then
        for i=math.max(1,#history-119),#history do
            local e=history[i]
            if type(e)=="table" and type(e.message)=="string" then
                append(e.message,e.messageType or Enum.MessageType.MessageOutput)
            end
        end
    end
    connect(output:GetPropertyChangedSignal("TextBounds"),function() resize=true end)
    connect(scroll:GetPropertyChangedSignal("AbsoluteWindowSize"),function() resize=true end)
    connect(scroll:GetPropertyChangedSignal("CanvasPosition"),function()
        if applyingScroll or window.CurrentTab~="Console" then return end
        local maxY=math.max(0,scroll.CanvasSize.Y.Offset-scroll.AbsoluteWindowSize.Y)
        follow=maxY==0 or scroll.CanvasPosition.Y>=maxY-15
    end)
    connect(Run.Heartbeat,function(dt)
        if window.CurrentTab~="Console" then return end
        elapsed+=dt
        if elapsed>=0.1 then
            elapsed=0
            if dirty then render() end
            if resize then layout() end
        end
    end)
    connect(G2L["109"].Activated,function()
        entries={} first=1 last=0 follow=true dirty=true
        render() layout() alert("Cleared live console")
    end)
    connect(G2L["114"].Activated,function()
        if last<first then alert("No console logs to copy") return end
        if type(setclipboard)~="function" then alert("Clipboard unavailable") return end
        local ok,err=pcall(setclipboard,plain())
        alert(ok and "Copied console logs" or ("Copy failed: "..tostring(err)))
    end)
    connect(G2L["10f"].Activated,function()
        dialog.Visible=true
    end)
    connect(G2L["123"].Activated,function()
        dialog.Visible=false
    end)
    local saving=false
    connect(G2L["127"].Activated,function()
        if saving then return end
        local name=filename.Text:match("^%s*(.-)%s*$")
        if name=="" then name="ps99_console_logs.txt" end
        if #name>128 or name=="." or name==".." or not name:match("^[%w_%.%-]+$") or name:sub(-1)=="." then
            alert("Invalid filename. Use letters, numbers, -, _ or dots")
            return
        end
        if type(writefile)~="function" then alert("File saving unavailable") return end
        saving=true
        local ok,err=pcall(writefile,name,plain())
        saving=false
        if not alive then return end
        if ok then
            filename.Text="" dialog.Visible=false alert("Saved "..name)
        else alert("Save failed: "..tostring(err)) end
    end)
    -- ZHub's original button colors, icons and hover transitions.
    for _,b in ipairs({G2L["109"],G2L["10f"],G2L["114"],G2L["127"]}) do
        local function hover(on)
            if tweens[b] then tweens[b]:Cancel() end
            local value=on and 50 or 30
            local textValue=on and 255 or 100
            local t=Tween:Create(b,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                {BackgroundColor3=Color3.fromRGB(value,value,value),
                TextColor3=Color3.fromRGB(textValue,textValue,textValue)})
            tweens[b]=t t:Play()
            local icon=b:FindFirstChildOfClass("ImageLabel")
            if icon then
                if tweens[icon] then tweens[icon]:Cancel() end
                local tween=Tween:Create(icon,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                    {ImageColor3=Color3.fromRGB(textValue,textValue,textValue)})
                tweens[icon]=tween tween:Play()
            end
        end
        connect(b.MouseEnter,function() hover(true) end)
        connect(b.MouseLeave,function() hover(false) end)
    end
    REQUEST_STATUS.console={host=host,show=function() if window.Alive then window:SelectTab("Console") end end,
        text=plain,clear=function() entries={} first=1 last=0 dirty=true end,
        stats=function() return {stored=math.max(0,last-first+1),visible=math.min(MAX_VISIBLE,math.max(0,last-first+1)),active=alive} end}
    render() layout()
    return stop
end

-- Preserve the established game feature definitions; only swap the UI adapter.
GuiLib.unavailable={NearestEgg=true,HUD=true,AutoJoinHalloween=true,AutoPlayHalloween=true,AutoUseTricks=true,HalloweenDestroyDecor=true,HalloweenAutoTeleport=true,InfPetSpeed=true,AutoNextArea=true,AutoUseMisc=true,AutoBuyUpgrades=false,AutoBuyEggBundle=true,AutoAttachCharm=false,AutoClaimRank=false,AutoClaimForever=false,AutoShinyRelics=true,AutoPopBalloons=false,AutoLeaveStairway=true,AutoAdminAbuse=true,AutoTreehouse=true,AutoCompleteRank=false,AutoCrystalCastle=true,AutoOpenLootboxes=false,AutoOpenCrystalChest=true,AutoSpinWheel=false,AutoRainbowFruits=true,AutoShinyFruits=true,WalkSpeedEnable=true,JumpPowerEnable=true,InfiniteJump=true,NoClip=true,WhiteScreen=true}
GuiLib.unusedSettings={BreakDelay=true,Radius=true,Targets=true,MinArea=true,MaxRank=false,ForgeChance=true,ForgeShards=true,PriorityWait=true,WalkSpeed=true,JumpPower=true,RejoinMins=true}

function GuiLib.new(opts)
    local dead=false
    local handles={}
    local dynamicRows={}
    local optionSignatures={}
    local statusRows={}
    local created,failed,skipped=0,0,0
    local errors={}
    local controlsByTab={}
    local statusText="Starting"
    local function get(key)
        if type(opts.getValue)=="function" then return opts.getValue(key) end
        return opts.cfg[key]
    end
    local function change(key,value)
        if dead or value==nil or GuiLib.unavailable[key] or GuiLib.unusedSettings[key] then return end
        if key=="FusePetName" then
            if value=="Select a pet" then value=""
            else
                local id=REQUEST_STATUS.crafting.idByLabel[value] or (REQUEST_STATUS.crafting.previousLabels or {})[value]
                if not id then return end
                value=id
            end
        end
        opts.cfg[key]=value
        if opts.onChange then opts.onChange(opts.cfg,key) end
    end
    local function labelFor(row)
        return type(row[3])=="string" and row[3] or tostring(row[2])
    end
    local function optionsFor(row)
        local key=row[2]
        if row[1]=="e" then
            local out={"Best Zone Egg","Best Egg","Nearest Egg"}
            for _,egg in ipairs(EggSelector.available()) do out[#out+1]=egg.id end
            return out
        end
        local source
        local ok,result=pcall(function()
            if key=="GiftSelection" then return availableGiftNames() end
            if key=="LootboxSelection" then return REQUEST_STATUS.lootboxes.options() end
            return type(row[4])=="function" and row[4]() or row[4]
        end)
        if ok and type(result)=="table" then source=result else
            warn("[AERO UI] Options unavailable for "..tostring(key)..": "..tostring(result))
            source={}
        end
        if key=="FlagSelection" or key=="KeySelection" or key=="FusePetName" or key=="CraftPetMode" or key=="CraftPetSort" then
            -- Large craft catalogs must not construct thousands of GUI objects on mobile.
            if key=="FusePetName" and #source>150 then
                local selected=tostring(get(key) or "")
                local out={"Select a pet"}
                for i=2,math.min(#source,149) do out[#out+1]=source[i] end
                if selected~="" and selected~="Select a pet" then
                    local present=false
                    for _,entry in ipairs(out) do if entry==selected then present=true break end end
                    if not present then out[#out+1]=selected end
                end
                return out
            end
            return source
        end
        local out={"All"}
        local seen={All=true}
        for _,name in ipairs(source) do
            if type(name)=="string" and not seen[name] then
                out[#out+1]=name
                seen[name]=true
            end
        end
        -- Show the saved selected item even after it leaves the inventory.
        local selected=tostring(get(key) or "")
        if selected~="" and not seen[selected] then out[#out+1]=selected end
        return out
    end
    local window=GuiLib.portable.new({
        Id="ps99-embedded",Title="AERO  /  PS99  v8.2.84",
        Adaptive=true,Scale=1,SavePreferences=true,DisplayOrder=700,
        OnClose=function() if not dead and type(opts.onUnload)=="function" then opts.onUnload() end end,
    })
    window:SetGroups({"Farm","Automatic","Rewards","Tools","Events","Manage"})
    local pages={
        {"Home","Manage"},{"Farm","Farm"},{"Hatch","Farm"},
        {"Gifts","Automatic"},{"Lootboxes","Automatic"},
        {"Consumables","Automatic"},{"Tools","Automatic"},
        {"Crafting","Automatic"},{"Enchants","Automatic"},
        {"Rewards","Rewards"},{"Other","Tools"},
        {"Halloween","Events"},{"Misc","Manage"},{"Diagnostics","Manage"},{"Console","Manage"},
    }
    local tabs={}
    -- Create all tabs before expensive inventory-driven dropdowns.
    for _,info in ipairs(pages) do
        tabs[info[1]]=window:AddTab(info[1],info[2])
        controlsByTab[info[1]]={}
    end
    -- Store exact control names for menu search; a search finds a feature even
    -- when it lives inside another panel, instead of searching tab titles alone.
    local routes={}
    local page="Home"
    local section=""
    local headers={FARM="Farm",HATCH="Hatch",AUTOMATIC="Consumables",REWARDS="Rewards",
        ["OTHER AUTOMATION"]="Other",HALLOWEEN="Halloween",MISC="Misc",CONSOLE="Console"}
    for _,row in ipairs(opts.rows) do
        local kind,key=row[1],row[2]
        if kind=="h" then
            page=headers[key] or "Misc"
            section=""
        else
            if kind=="s" then section=key end
            local target=page
            if page=="Misc" and (section=="Session status" or section=="GUI & source verification" or section=="One-click automated feature testing") then target="Diagnostics" end
            if page=="Consumables" or page=="Tools" or page=="Crafting" or page=="Lootboxes" or page=="Gifts" then
                if section=="Gifts" then target="Gifts"
                elseif section=="Fruits" or section=="Potions" or section=="Toy buffs" or section=="Fruit and potion status" then target="Consumables"
                elseif section=="Consumables and tools" then target="Tools"
                elseif section=="Crafting and upgrading" or section=="Charm attachment (manual pet UID; default off)"
                    or section=="Event upgrades (verified client module; not regular upgrades)" then target="Crafting"
                elseif section=="Chests and special items" or section=="Wheel tickets (StarterWheel only)" then target="Lootboxes" end
            end
            if kind=="em" then target="Enchants" end
            routes[#routes+1]={row=row,page=target}
            local names=controlsByTab[target]
            names[#names+1]=tostring(key).." "..labelFor(row)
        end
    end
    for name,terms in pairs(controlsByTab) do tabs[name].SearchTerms=table.concat(terms," ") end
    -- Mount synchronously: logs and console controls exist before other pages
    -- start their asynchronous inventory-driven initialization.
    local consoleMounted,consoleError=pcall(mountZHubConsole,tabs.Console)
    if not consoleMounted then
        warn("[AERO UI] Console mounting failed: "..tostring(consoleError))
        tabs.Console:AddLabel("ZHub console unavailable: "..tostring(consoleError):sub(1,180))
    end
    tabs.Console.SearchTerms=(tabs.Console.SearchTerms or "").." ZHub Console Live Logs Clear Copy Save Output Warnings Errors"
    local home=tabs.Home
    home:AddSection("AERO PS99 • Control Center")
    home:AddParagraph("Welcome", "Gifts and Lootboxes have dedicated pages. Crafting includes Event Upgrades and manual-UID Charm Attachment; Rewards includes Rank and experimental Balloons. Diagnostics contains source capture and status. Tap Tools to search features.")
    home:AddButton({Name="Open Gifts",Callback=function() window:SelectTab("Gifts") end})
    home:AddButton({Name="Open Lootboxes",Callback=function() window:SelectTab("Lootboxes") end})
    home:AddButton({Name="Open Crafting",Callback=function() window:SelectTab("Crafting") end})
    home:AddButton({Name="Open Enchants",Callback=function() window:SelectTab("Enchants") end})
    home:AddButton({Name="Open Live Console",Callback=function() window:SelectTab("Console") end})
    home:AddButton({Name="Open Diagnostics",Callback=function() window:SelectTab("Diagnostics") end})
    home:AddButton({Name="Run Automated Feature Tests",Callback=function()
        if type(opts.actions.RunAutomatedTests)=="function" then opts.actions.RunAutomatedTests() end
        window:SelectTab("Diagnostics")
    end})
    home:AddButton({Name="Capture Mechanic Sources",Callback=function()
        if type(opts.actions.CaptureMechanics)=="function" then opts.actions.CaptureMechanics() end
        window:SelectTab("Diagnostics")
    end})
    home:AddButton({Name="Refresh owned items",Callback=function()
        if type(_G.AERO_PS99_RefreshUI)=="function" then _G.AERO_PS99_RefreshUI() end
    end})
    home:AddButton({Name="Export Full Diagnostics",Callback=function()
        if type(opts.actions.FullDiagnostics)=="function" then opts.actions.FullDiagnostics() end
    end})
    local homeStatus=home:AddLabel("Loading GUI controls…")
    local function makeCompat(tab)
        -- Compatibility shim for the preserved Rayfield-shaped EnchantManager,
        -- so its existing save, verify, and worker code is unchanged.
        local shim={}
        function shim:CreateSection(o) return tab:AddSection(o.name) end
        function shim:CreateText(o) return tab:AddLabel(o.text or o.name) end
        function shim:CreateButton(o) return tab:AddButton({Name=o.name,Callback=o.callback}) end
        function shim:CreateToggle(o)
            return tab:AddToggle({Name=o.name,Default=o.value==true,Callback=o.callback})
        end
        function shim:CreateDropdown(o)
            local h=tab:AddDropdown({Name=o.name,Options=o.options or {},Default=o.value,Callback=o.callback})
            function h:Refresh(values) self:SetOptions(values) end
            return h
        end
        return shim
    end
    local function build(row,tab,pageName)
        local kind,key=row[1],row[2]
        if kind=="em" then
            -- Heavy inventory reads in the enchant manager are separate from
            -- other page initialization; failure cannot hide Gift/Lootbox UI.
            local ok,err=xpcall(function() EnchantManager.mount(makeCompat(tab)) end,debug.traceback)
            if not ok then error("EnchantManager: "..tostring(err)) end
            return
        end
        if kind=="s" then
            tab:AddSection(key)
            if key=="Gifts" or key=="Chests and special items" then
                tab:AddButton({Name="Refresh owned "..(key=="Gifts" and "gifts" or "lootboxes"),Callback=function()
                    if type(_G.AERO_PS99_RefreshUI)=="function" then _G.AERO_PS99_RefreshUI() end
                end})
            end
            created=created+1
            return
        end
        if GuiLib.unavailable[key] or GuiLib.unusedSettings[key] then
            skipped=skipped+1
            local why=GuiLib.unavailable[key] and "Not implemented" or "Not connected"
            tab:AddButton({Name=labelFor(row).."  ["..why.."]",Callback=function()
                window:Notify("AERO PS99",labelFor(row).." — "..why,3)
            end})
            return
        end
        if kind=="l" then
            local handle=tab:AddLabel(labelFor(row)..": loading…")
            statusRows[key]={handle=handle,page=pageName,last=nil}
            created=created+1
        elseif kind=="b" then
            handles[key]=tab:AddToggle({Name=labelFor(row),Default=get(key)==true,
                Callback=function(value) change(key,value) end})
            created=created+1
        elseif kind=="a" then
            handles[key]=tab:AddButton({Name=labelFor(row),Callback=function()
                local action=opts.actions[key]
                if type(action)=="function" then action()
                else window:Notify("AERO PS99",key.." is not available",3) end
            end})
            created=created+1
        elseif kind=="n" then
            local min,max=tonumber(row[4]) or 0,tonumber(row[5]) or 100
            if max<min then max=min end
            handles[key]=tab:AddSlider({Name=labelFor(row),Min=min,Max=max,
                Increment=tonumber(row[3]) or 1,Default=tonumber(get(key)) or min,
                Callback=function(value) change(key,value) end})
            created=created+1
        elseif kind=="t" then
            handles[key]=tab:AddInput({Name=labelFor(row),Default=tostring(get(key) or ""),
                Callback=function(value) change(key,tostring(value)) end})
            created=created+1
        elseif kind=="d" or kind=="e" then
            local values=optionsFor(row)
            local current=tostring(get(key) or "")
            local exists=false
            for _,name in ipairs(values) do if name==current then exists=true break end end
            if not exists then current=values[1] end
            handles[key]=tab:AddDropdown({Name=labelFor(row),Options=values,Default=current,
                Callback=function(value)
                    if type(value)=="string" and value~="" then change(key,value) end
                end})
            dynamicRows[key]=row
            optionSignatures[key]=table.concat(values,"\0")
            created=created+1
        else
            error("Unsupported UI control kind: "..tostring(kind))
        end
    end
    local total=0
    for _,entry in ipairs(routes) do
        if entry.row[1]~="em" then total=total+1 end
    end
    -- Separate page workers; a slow craft selector cannot prevent all the
    -- remaining controls (or entire tabs) from being available.
    local pendingPages={}
    for _,info in ipairs(pages) do
        local pageName=info[1]
        if pageName~="Home" then
            local pageRows={}
            for _,entry in ipairs(routes) do
                if entry.page==pageName then pageRows[#pageRows+1]=entry.row end
            end
            if #pageRows>0 then
                pendingPages[pageName]=true
                spawnTask(function()
                    local tab=tabs[pageName]
                    for _,row in ipairs(pageRows) do
                        if dead or not isRunning() then break end
                        local ok,err=xpcall(function() build(row,tab,pageName) end,debug.traceback)
                        if not ok then
                            failed=failed+1
                            errors[#errors+1]=tostring(row[2])..": "..tostring(err):sub(1,240)
                            warn("[AERO UI] "..tostring(pageName).."/"..tostring(row[2])..": "..tostring(err))
                        end
                        -- Do not monopolize Android's UI/render thread during construction.
                        task.wait()
                    end
                    pendingPages[pageName]=nil
                    print("[AERO UI] Built "..pageName.." ("..#pageRows.." definitions)")
                end)
            end
        end
    end
    local obj={}
    function obj:refresh()
        if dead then return end
        for key,row in pairs(dynamicRows) do
            local handle=handles[key]
            if handle and handle.SetOptions then
                local ok,err=pcall(function()
                    local values=optionsFor(row)
                    local signature=table.concat(values,"\0")
                    if optionSignatures[key]~=signature then
                        optionSignatures[key]=signature
                        handle:SetOptions(values)
                    end
                    local current=tostring(get(key) or "")
                    -- Preserve selection; never call change from a list refresh.
                    local found=false
                    for _,name in ipairs(values) do if name==current then found=true break end end
                    local selected=found and current or values[1]
                    if handle:Get()~=selected then handle:Set(selected,false) end
                end)
                if not ok then warn("[AERO UI] Selector refresh "..key..": "..tostring(err)) end
            end
        end
    end
    function obj:setStatus(text)
        if dead then return end
        statusText=tostring(text)
        for key,handle in pairs(handles) do
            if type(get(key))=="boolean" and type(handle.Set)=="function" then
                local value=get(key)
                if handle:Get()~=value then pcall(function()handle:Set(value,false)end) end
            end
        end
    end
    function obj:diagnostics()
        local live={}
        for name in pairs(pendingPages) do live[#live+1]=name end
        table.sort(live)
        local failures={}
        for i=1,math.min(#errors,8) do failures[#failures+1]=errors[i] end
        return string.format("AERO Portable | tabs=%d registered=%d/%d active=%d placeholders=%d failed=%d pending=%s | Gifts=%s Lootboxes=%s",
            #window.TabList,created+skipped,total,created,skipped,failed,table.concat(live,","),
            tostring(handles.AutoOpenGifts~=nil and handles.GiftSelection~=nil),
            tostring(handles.AutoOpenLootboxes~=nil and handles.LootboxSelection~=nil)).." | Console="..tostring(REQUEST_STATUS.console~=nil)
            .." | errors="..table.concat(failures," || ")
    end
    function obj:destroy()
        if dead then return end
        dead=true
        if window and window.Alive then window:Destroy() end
    end
    function obj:go(name) return window:SelectTab(name) end
    _G.AERO_PS99_GUI_Audit=function() return obj:diagnostics() end
    onCleanup(function()
        if type(_G.AERO_PS99_GUI_Audit)=="function" then _G.AERO_PS99_GUI_Audit=nil end
        obj:destroy()
    end)
    -- Refresh lightweight visible statuses without yielding UI constructors.
    spawnTask(function()
        local lastRefresh=0
        while not dead and isRunning() do
            if window.Alive then
                for key,record in pairs(statusRows) do
                    if window.CurrentTab==record.page then
                        local ok,value=pcall(function()
                            return type(opts.describe)=="function" and opts.describe(key) or statusText
                        end)
                        if ok then
                            local formatted=tostring(value)
                            if record.last~=formatted then
                                record.handle:Set(formatted)
                                record.last=formatted
                            end
                        end
                    end
                end
                if os.clock()-lastRefresh>2 then
                    homeStatus:Set(obj:diagnostics())
                    lastRefresh=os.clock()
                end
            end
            task.wait(1.5)
        end
    end)
    -- Inventory selectors refresh at a slower cadence; avoid constructing
    -- hundreds of option buttons repeatedly on every status tick.
    spawnTask(function()
        while not dead and isRunning() do
            task.wait(7)
            for _,key in ipairs({"GiftSelection","LootboxSelection","FlagSelection","FusePetName","EggSelection"}) do
                local row=dynamicRows[key]
                local handle=handles[key]
                if row and handle and window.CurrentTab==({GiftSelection="Gifts",LootboxSelection="Lootboxes",
                    FlagSelection="Tools",FusePetName="Crafting",EggSelection="Hatch"})[key] then
                    local ok,values=pcall(optionsFor,row)
                    if ok and type(values)=="table" then
                        local signature=table.concat(values,"\0")
                        if optionSignatures[key]~=signature then
                            optionSignatures[key]=signature
                            pcall(function()
                                handle:SetOptions(values)
                                local current=tostring(get(key) or "")
                                local exists=false
                                for _,value in ipairs(values) do if value==current then exists=true break end end
                                handle:Set(exists and current or values[1],false)
                            end)
                        end
                    end
                end
            end
        end
    end)
    window:AddSettingsTab("Settings")
    if window.RestoreTab and window.Tabs[window.RestoreTab] then
        window:SelectTab(window.RestoreTab)
    else
        window:SelectTab("Home")
    end
    print("[AERO UI] Embedded AERO Portable ready | "..obj:diagnostics())
    return obj
end

-- P24.4 feature health and bounded, read-only verification probes.
REQUEST_STATUS.verification=(function()
    local V={inventory={state="Unverified",detail="Not sampled"},busy=false,sequence=0,lastExport="Not exported"}
    function V.observePets(snapshot)
        local evidence=REQUEST_STATUS.evidence.hatch
        local accepted=evidence and evidence.accepted or 0
        if not snapshot then V.petSnapshot=nil V.petAccepted=accepted return end
        local previous=V.petSnapshot
        if previous and os.clock()-(V.petSampleAt or -math.huge)<=5 and accepted>0 and (Flags.AutoHatch or os.clock()-(REQUEST_STATUS.lastHatchAccepted or -math.huge)<8) then
            local gained=0
            for uid,entry in pairs(snapshot) do
                local old=previous[uid]
                local before=old and old.id==entry.id and old.quantity or 0
                gained=gained+math.max(0,entry.quantity-before)
            end
            if gained>0 then
                local row=REQUEST_STATUS.observe("hatch","inventorySamplesWithGains","Pet quantities increased during/after hatching; trades, gifts and other sources are not excluded")
                row.petGains=(row.petGains or 0)+gained
            end
        end
        V.petSnapshot=snapshot V.petAccepted=accepted V.petSampleAt=os.clock()
    end
    function V.probe()
        if V.busy or not isRunning() then return false,"Read-only probe already running or script unloaded" end
        V.busy=true
        local done=false
        local thread=spawnTask(function()
            local ok,result=pcall(function()
                local save=require(RS.Library.Client.Save)
                local data=save.Get()
                assert(type(data)=="table" and type(data.Inventory)=="table","Inventory unavailable")
                local categories,stacks,items,currencyStacks,excluded=0,0,0,0,0
                local quantities,petSnapshot={},{}
                for category,entries in pairs(data.Inventory) do
                    if type(entries)=="table" then
                        categories=categories+1
                        local total,valid=0,true
                        for uid,entry in pairs(entries) do
                            if type(entry)=="table" and type(entry.id)=="string" then
                                stacks=stacks+1
                                local n=entry._am==nil and 1 or tonumber(entry._am)
                                if category=="Currency" then
                                    currencyStacks=currencyStacks+1
                                elseif n and n==n and n>=0 and n<=9007199254740991 and n%1==0 and total+n<=9007199254740991 then
                                    total=total+n
                                    if category=="Pet" then petSnapshot[tostring(uid)]={id=entry.id,quantity=n} end
                                else valid=false excluded=excluded+1 end
                            end
                        end
                        if category~="Currency" then
                            quantities[tostring(category)]={quantity=total,complete=valid}
                            if items+total<=9007199254740991 then items=items+total else excluded=excluded+1 end
                        end
                    end
                end
                V.observePets(type(data.Inventory.Pet)=="table" and petSnapshot or nil)
                return {state="Working",detail="Readable snapshot; item quantity excludes Currency and invalid/unsafe counts",categories=categories,stacks=stacks,items=items,
                    quantities=quantities,currencyStacks=currencyStacks,excludedCounts=excluded,at=os.time()}

            end)
            if not isRunning() then return end
            V.inventory=ok and result or {state="Unavailable",detail=tostring(result):sub(1,200),at=os.time()}
            V.busy=false done=true
        end)
        spawnTask(function()
            local deadline=os.clock()+5
            while isRunning() and not done and os.clock()<deadline do task.wait(0.1) end
            if not done and isRunning() then
                if thread then pcall(task.cancel,thread) end
                V.busy=false V.inventory={state="Unavailable",detail="Inventory probe timed out after 5s",at=os.time()}
            end
        end)
        return true,"Read-only inventory probe started"
    end
    function V.health()
        local rows={}
        local catalog=REQUEST_STATUS.evidence.catalog or {}
        rows[#rows+1]={feature="EggCatalog",state=#EggSelector.rows>0 and "Working" or "Unavailable",
            detail=EggSelector.message.." | normal eggs="..#EggSelector.rows.." | revision="..EggSelector.revision.." | load errors="..(catalog.errors or 0).." | one-shot worker completion is normal"}
        rows[#rows+1]={feature="InventoryRead",state=V.inventory.state,detail=V.inventory.detail,
            at=V.inventory.at,categories=V.inventory.categories,stacks=V.inventory.stacks,items=V.inventory.items}
        local names={}
        for key in pairs(Flags) do names[#names+1]=key end
        table.sort(names)
        for _,key in ipairs(names) do
            local state,detail="Unverified","Enabled setting; gameplay outcome not independently verified"
            if GuiLib.unavailable[key] then
                state="Unavailable"
                detail="Not implemented"
            elseif not Flags[key] then state="Disabled" detail="Toggle is off"
            elseif key=="AutoBuyUpgrades" then
                state=REQUEST_STATUS.eventUpgrades.verified>0 and "Working" or "Unverified"
                detail=REQUEST_STATUS.eventUpgrades.summary().." | EVENT upgrades only; tier change observed, not independent attribution"
            elseif key=="AutoAttachCharm" then
                state=REQUEST_STATUS.charmAttach.verified>0 and "Working" or "Unverified"
                detail=REQUEST_STATUS.charmAttach.summary().." | manual pet UID only"
            elseif key=="AutoPopBalloons" then
                state="Unverified" detail=REQUEST_STATUS.balloons.summary().." | hit payload inferred; pop attribution unverified"
            elseif key=="AutoCompleteRank" then
                state=REQUEST_STATUS.rankComplete.ranksObserved>0 and "Working" or "Unverified"
                detail=REQUEST_STATUS.rankComplete.summary().." | uses known quest types; no bypass"
            elseif key=="AutoSpinWheel" then
                local spin=REQUEST_STATUS.spin
                state=spin.verified>0 and "Working" or "Unverified"
                detail=spin.summary().."; only ticket delta is measured, not prize delivery"
            elseif key=="AutoOpenLootboxes" then
                local l=REQUEST_STATUS.lootboxes
                state=l.unconfirmed>0 and "Unverified" or (l.verified>0 and "Working" or "Unverified")
                detail=l.summary().."; inventory decreases do not prove reward delivery or exclusive attribution"
            elseif key=="AutoOpenGifts" and GiftStatus.metrics.verified>0 then
                state="Working" detail="Inventory decrease observed for gift opening; external changes can affect attribution"
            elseif key=="AutoRebirth" and (REQUEST_STATUS.evidence.rebirth or {}).observed and REQUEST_STATUS.evidence.rebirth.observed>0 then
                state="Working" detail="Readable rebirth count increase observed in this execution"
            end
            local worker=({AutoHatch="worker-6",AutoRebirth="worker-13",Breakables="native-auto-tap",Tap="native-auto-tap",NativeAutoTap="native-auto-tap",FastFarm="native-auto-tap"})[key]
            local status=worker and WORKER_STATUS[worker]
            if Flags[key] and not GuiLib.unavailable[key] and status and status.state=="failed" then state="Failed" detail="Worker failed: "..tostring(status.lastError) end
            rows[#rows+1]={feature=key,state=state,detail=detail}
        end
        return rows
    end
    function V.lines()
        local lines={"AERO PS99 v8.2.84 P24.4 — Full Diagnostics", "Working = observed evidence in this execution; it is not a general compatibility guarantee.",
            "Worker liveness, endpoint presence, accepted responses and gameplay outcomes are separate signals.",
            "Legacy inventory/egg scan counters measure legacy helper calls; they do not measure every Save.Get or directory read."}
        for _,text in ipairs(workerDiagnosticDetails()) do lines[#lines+1]=text end
        for _,key in ipairs({"rankClaims","foreverClaims"}) do
            local c=REQUEST_STATUS[key] or {}
            lines[#lines+1]=string.format("%s | requests=%d verified=%d unconfirmed=%d | %s",key,c.requests or 0,c.verified or 0,c.unconfirmed or 0,c.status or "Starting")
        end
        if type(_G.AERO_PS99_GUI_Audit)=="function" then
            local ok,audit=pcall(_G.AERO_PS99_GUI_Audit)
            lines[#lines+1]="GUI: "..(ok and tostring(audit) or "audit unavailable")
        end
        if REQUEST_STATUS.autoTest then
            lines[#lines+1]="One-click Auto Test: "..REQUEST_STATUS.autoTest.summary()
        end
        lines[#lines+1]="Lootboxes: "..REQUEST_STATUS.lootboxes.summary()
        lines[#lines+1]=string.format("Gifts: requests=%d verified-opening-batches=%d observed-items=%d pending=%s | %s",
            GiftStatus.metrics.requests,GiftStatus.metrics.verified,GiftStatus.metrics.items,
            tostring(giftPending~=nil),tostring(GiftStatus.text))
        lines[#lines+1]="Spin wheel: "..REQUEST_STATUS.spin.summary()
        lines[#lines+1]="Event upgrades: "..REQUEST_STATUS.eventUpgrades.summary()
        lines[#lines+1]="Charm attachment: "..REQUEST_STATUS.charmAttach.summary()
        lines[#lines+1]="Rank coordinator: "..REQUEST_STATUS.rankComplete.summary()
        lines[#lines+1]="Balloon gifts: "..REQUEST_STATUS.balloons.summary()
        lines[#lines+1]="Source capture: "..REQUEST_STATUS.mechCapture.status.." | matches="..REQUEST_STATUS.mechCapture.found.." sourceModules="..REQUEST_STATUS.mechCapture.decompiled
        if REQUEST_STATUS.console then
            local ok,stats=pcall(REQUEST_STATUS.console.stats)
            if ok and type(stats)=="table" then
                lines[#lines+1]=string.format("Console: active=%s stored=%s visible=%s",tostring(stats.active),tostring(stats.stored),tostring(stats.visible))
            end
        end
        lines[#lines+1]="Lootbox selection: "..tostring(State.LootboxSelection).." | One unit per request; shared gift lock; unconfirmed IDs blocked until next execution"
        for id,reason in pairs(REQUEST_STATUS.lootboxes.blocked) do lines[#lines+1]="Lootbox blocked: "..id.." | "..reason end
        lines[#lines+1]="Travel: "..tostring(REQUEST_STATUS.travelStatus or "idle")
        lines[#lines+1]="Feature health:"
        for _,row in ipairs(V.health()) do lines[#lines+1]=row.feature.." | "..row.state.." | "..row.detail end
        local inventory=V.inventory
        lines[#lines+1]=string.format("Inventory probe: categories=%s stacks=%s non-currency-item-quantity=%s sampledAt=%s",tostring(inventory.categories),tostring(inventory.stacks),tostring(inventory.items),tostring(inventory.at))
        lines[#lines+1]="Inventory currency stacks="..tostring(inventory.currencyStacks or 0).."; invalid/unsafe quantity counts excluded="..tostring(inventory.excludedCounts or 0)
        local categories={}
        for name in pairs(inventory.quantities or {}) do categories[#categories+1]=name end
        table.sort(categories)
        for _,name in ipairs(categories) do
            local row=inventory.quantities[name]
            lines[#lines+1]="Inventory category "..name.." | quantity="..row.quantity.." | complete="..tostring(row.complete)
        end
        for _,key in ipairs({"hatch","rebirth","tap"}) do
            local e=REQUEST_STATUS.evidence[key] or {}
            lines[#lines+1]=string.format("%s | requests=%d accepted-responses=%d rejected=%d errors=%d observed=%d | %s",key,e.requests or 0,e.accepted or 0,e.rejected or 0,e.errors or 0,e.observed or 0,e.detail or "No feature activity recorded")
            if key=="hatch" then lines[#lines+1]="Observed pet quantity gains="..(e.petGains or 0).." across "..(e.inventorySamplesWithGains or 0).." sample intervals; attribution to individual hatch requests is unverified" end
            if key=="tap" then lines[#lines+1]="Observed target removals="..(e.targetRemoved or 0).."; removals do not prove our damage caused a break" end
            if key=="tap" then lines[#lines+1]="Tap scans="..(e.scans or 0).." eligible-targets="..(e.targets or 0).."; actual damage and break completion are NOT measured" end
        end
        lines[#lines+1]="Egg selected: "..tostring(State.EggSelection).." | catalog entries="..#EggSelector.rows.." | directory refresh revision="..EggSelector.revision
        lines[#lines+1]="Hatch: "..HatchStatus.text
        lines[#lines+1]="Rebirth: "..lastRebirthMsg
        if REQUEST_STATUS.crafting then lines[#lines+1]="Crafting: "..REQUEST_STATUS.crafting.status.." | requests="..REQUEST_STATUS.crafting.requests.." | verified="..REQUEST_STATUS.crafting.verified.." | errors="..REQUEST_STATUS.crafting.errors end
        if REQUEST_STATUS.crafting and REQUEST_STATUS.crafting.lastFusion then
            lines[#lines+1]="Fusion net reconciliations (not independently verified): "..tostring(REQUEST_STATUS.crafting.netReconciled or 0)
            local f=REQUEST_STATUS.crafting.lastFusion
            for _,key in ipairs({"selected","sourceUID","consume","responseType","accepted","inputBefore","inputAfter","inputConsumed","outputBefore","outputAfter","outputQuantity","outputArrived","expectedNet","netReconciled","result"}) do
                lines[#lines+1]="Fusion "..key..": "..tostring(f[key])
            end
            if REQUEST_STATUS.crafting.lastFusionError then lines[#lines+1]="Fusion read error: "..REQUEST_STATUS.crafting.lastFusionError end
        end
        lines[#lines+1]="Last export: "..V.lastExport
        return lines
    end
    function V.export()
        if not isRunning() then return false,"Script unloaded" end
        local text=table.concat(V.lines(),"\n")
        local copied=false
        if type(setclipboard)=="function" then copied=pcall(setclipboard,text) end
        local saved=false
        local path="ps99_diagnostics_"..tostring(LocalPlayer.UserId).."_"..tostring(game.PlaceId)..".txt"
        if type(writefile)=="function" then saved=pcall(writefile,path,text) end
        V.lastExport=saved and path or (copied and "Clipboard only" or "No file or clipboard export succeeded")
        print("[AERO P24.4] Full report | lines="..#V.lines().." | saved="..tostring(saved).." | copied="..tostring(copied).." | "..V.lastExport)
        if not saved and not copied then
            -- Bounded console chunks are a fallback, never the only copy when
            -- executor file or clipboard APIs are available.
            local lines=V.lines()
            for i=1,#lines,10 do
                local part={}
                for j=i,math.min(#lines,i+9) do part[#part+1]=lines[j] end
                print("[AERO P24.4] PART "..math.floor((i-1)/10+1).."\n"..table.concat(part,"\n"))
            end
        end
        return saved or copied,V.lastExport
    end
    _G.AERO_PS99_P232_Report=V.export
    onCleanup(function() if _G.AERO_PS99_P232_Report==V.export then _G.AERO_PS99_P232_Report=nil end end)
    guardedSpawn("feature-verification",function()
        local nextProbe=0
        while isRunning() do
            local active=Flags.AutoHatch or os.clock()-(REQUEST_STATUS.lastHatchAccepted or -math.huge)<8
            if not V.busy and (active or os.clock()>=nextProbe) then
                V.probe() nextProbe=os.clock()+30
            end
            task.wait(2)
        end
    end)
    return V
end)()

applyRender()
if Flags.OptPart then startParticleOptimization() end
for key in pairs(GuiLib.unavailable) do Flags[key]=false end
Flags.AutoMakeGold=false Flags.AutoMakeRainbow=false Flags.AutoFuse=false
Flags.Collect=false -- Opt in to loaded-world collection each execution.
Flags.CollectLootbags=false
Flags.FastFarm=false
Flags.NativeAutoTap=false -- Opt in each execution until live-tested.
Flags.SmartPets=false -- Experimental: opt in every execution; never auto-start from saved config.
Flags.AutoBestWorld=false
Flags.AutoBestArea=false -- Enable best-area travel explicitly each execution.
Flags.AutoCombineKeys=false
Flags.AutoSpinWheel=false -- Explicit opt-in; never auto-resume wheel requests from a saved config.
Flags.AutoBuyUpgrades=false Flags.AutoAttachCharm=false Flags.AutoCompleteRank=false Flags.AutoPopBalloons=false
-- New resource-changing actions and experimental balloon requests are never resumed from disk.

-- GUI using embedded robust module
local combined = {}
for k, v in pairs(Flags) do combined[k] = v end
for k, v in pairs(State) do if type(v) ~= "table" then combined[k] = v end end
-- P24.4: independent, read-only preflight checks with evidence and fail-safe reporting.
-- No request dispatch, purchase, claim, equipment change, flag toggle or teleport.
-- Results describe availability/prerequisites, NOT a live demonstration of feature success.
do
    local T={status="Not run",running=false,completed=false,ready=0,attention=0,
        blocked=0,rows={},started=0,finished=0,runs=0,ticket=0,
        file="Not saved",lastText="",exportError="",checksDone=0,checksPlanned=12}
    REQUEST_STATUS.autoTest=T
    function T.summary()
        local stage=T.running and "Running" or (T.completed and "Finished" or "Not run")
        return string.format("%s %d/%d checks | READY=%d ATTENTION=%d BLOCKED=%d | %s | %s",
            stage,T.checksDone,T.checksPlanned,T.ready,T.attention,T.blocked,
            tostring(T.status),tostring(T.file))
    end
    local MAX_SAFE=9007199254740991
    local function positiveAmount(entry)
        if type(entry)~="table" then return nil end
        local n=entry._am==nil and 1 or tonumber(entry._am)
        if not n or n~=n or n<0 or n>MAX_SAFE or n%1~=0 then return nil end
        return n
    end
    local function countCategory(inv,name)
        if type(inv)~="table" or type(inv[name])~="table" then return nil,0,0 end
        local sum,stacks,invalid=0,0,0
        for _,entry in pairs(inv[name]) do
            if type(entry)=="table" and type(entry.id)=="string" then
                local n=positiveAmount(entry)
                if not n or sum+n>MAX_SAFE then invalid+=1
                else sum+=n stacks+=1 end
            end
        end
        return invalid>0 and nil or sum,stacks,invalid
    end
    local function copySettings()
        return {
            Flags.AutoOpenGifts,Flags.AutoOpenLootboxes,Flags.AutoSpinWheel,
            Flags.AutoBuyUpgrades,Flags.AutoAttachCharm,Flags.AutoCompleteRank,
            Flags.AutoPopBalloons,State.LootboxSelection,State.CharmSelection,
            State.CharmPetUID,State.EventUpgradeSessionLimit,State.CharmSessionLimit,
            State.BalloonMode
        }
    end
    function T.run()
        if T.running then return false,"Automated test is already running" end
        if not isRunning() then return false,"Script already unloaded" end
        T.ticket+=1
        local ticket=T.ticket
        T.runs+=1
        T.running=true T.completed=false T.ready=0 T.attention=0 T.blocked=0
        T.checksDone=0 T.started=os.clock() T.finished=0 T.rows={}
        T.file="Not saved" T.exportError="" T.lastText="" T.status="Starting read-only checks"
        local lines={
            "AERO PS99 v8.2.84 P24.4 - Automated Read-Only Preflight",
            "Run: "..tostring(T.runs).." | Place: "..tostring(game.PlaceId),
            "Evidence: current client modules, GUI, workers, saved inventory and settings.",
            "NO GAMEPLAY ACTIONS: no remotes invoked, item consumed, currency spent, flags toggled or purchases prompted by the TEST.",
            "READY = prerequisites present only. NOT evidence of server acceptance or successful gameplay.",
            "Existing enabled automation may still act independently while this test runs.",
            ""
        }
        local before=copySettings()
        local function active() return T.running and isRunning() and T.ticket==ticket end
        local function record(name,level,detail)
            if not active() then return end
            if level~="READY" and level~="ATTENTION" and level~="BLOCKED" then
                level="BLOCKED" detail="Invalid test result: "..tostring(detail)
            end
            local result=tostring(detail or "")
            if #result>900 then result=result:sub(1,900).." [truncated]" end
            T.checksDone+=1
            if level=="READY" then T.ready+=1
            elseif level=="BLOCKED" then T.blocked+=1
            else T.attention+=1 end
            T.rows[#T.rows+1]={name=name,result=level,detail=result,proof="client-side preflight"}
            T.status=name..": "..level
            local line=string.format("[%s] %s | %s",level,name,result)
            lines[#lines+1]=line
            print("[AERO AUTO TEST] "..line)
        end
        local function checked(name,fn)
            if not active() then return end
            T.status="Checking "..name
            local ok,level,detail=xpcall(fn,debug.traceback)
            if not active() then return end
            if ok then record(name,level,detail)
            else record(name,"BLOCKED","Check raised an error (other tests continue): "..tostring(level):sub(1,360)) end
        end
        local function finish(reason)
            if not active() then return end
            if reason then record("Test runner","BLOCKED",reason) end
            T.running=false T.completed=true T.finished=os.clock()
            local elapsed=math.max(0,T.finished-T.started)
            lines[#lines+1]=""
            lines[#lines+1]=string.format("Preflight summary: READY=%d ATTENTION=%d BLOCKED=%d | checks=%d/%d | %.1fs",
                T.ready,T.attention,T.blocked,T.checksDone,T.checksPlanned,elapsed)
            lines[#lines+1]="Gameplay validation: NOT PERFORMED. Zero deliberate game action requests by this suite."
            lines[#lines+1]="Preflight cannot prove individual features work: use controlled live observations for outcome claims."
            local report=table.concat(lines,"\n")
            T.lastText=report
            local filename="AERO_PS99_AutoTest_v8_2_84_"..tostring(game.PlaceId).."_"..tostring(T.runs)..".txt"
            local written,writeProblem=false,"writefile not available"
            if type(writefile)=="function" then
                written,writeProblem=pcall(writefile,filename,report)
            end
            local copied,copyProblem=false,"setclipboard not available"
            if type(setclipboard)=="function" then
                copied,copyProblem=pcall(setclipboard,report)
            end
            T.file=written and filename or (copied and "Clipboard (file not saved)" or "Console only")
            if not written then T.exportError="File: "..tostring(writeProblem):sub(1,180) end
            if not written and not copied then
                T.exportError=T.exportError.."; Clipboard: "..tostring(copyProblem):sub(1,180)
            end
            T.status=string.format("%d ready, %d attention, %d blocked",T.ready,T.attention,T.blocked)
            print("[AERO AUTO TEST] "..T.status.." | report="..T.file)
            if T.exportError~="" then warn("[AERO AUTO TEST] Export: "..T.exportError) end
            pcall(REQUEST_STATUS.notify,"Auto test: "..T.status..". "..T.file)
        end
        local started=spawnTask(function()
            local ok,err=xpcall(function()
                local guiAudit="GUI diagnostics unavailable"
                local consoleStats=nil
                local inv,save=nil,nil
                checked("GUI controls and routes",function()
                    for i=1,9 do
                        local got,val=pcall(function()
                            return type(_G.AERO_PS99_GUI_Audit)=="function" and _G.AERO_PS99_GUI_Audit() end)
                        if got and type(val)=="string" then guiAudit=val end
                        local pending=guiAudit:match("pending=([^|]*)")
                        if pending and pending:match("^%s*$") then break end
                        if i<9 then task.wait(0.2) end
                    end
                    local r,t=guiAudit:match("registered=(%d+)/(%d+)")
                    local registered,total=tonumber(r),tonumber(t)
                    local created=tonumber(guiAudit:match("active=(%d+)")) or 0
                    local failed=tonumber(guiAudit:match("failed=(%d+)"))
                    local pending=(guiAudit:match("pending=([^|]*)") or ""):match("^%s*(.-)%s*$")
                    local tabs=tonumber(guiAudit:match("tabs=(%d+)")) or 0
                    local good=registered and total and total>=10 and registered==total and
                        created>0 and failed==0 and pending=="" and tabs>0 and
                        guiAudit:find("Gifts=true",1,true) and guiAudit:find("Lootboxes=true",1,true) and
                        guiAudit:find("Console=true",1,true)
                    local note=guiAudit.." | registered includes placeholders; active="..created.." are constructed"
                    return good and "READY" or "BLOCKED",note
                end)
                checked("ZHub console listener",function()
                    local console=REQUEST_STATUS.console
                    local ok,stats=pcall(function()return console and console.stats and console.stats()end)
                    if ok and type(stats)=="table" then consoleStats=stats end
                    return ok and type(stats)=="table" and stats.active and "READY" or "BLOCKED",
                        "Listener active="..tostring(stats and stats.active).."; buffered="..tostring(stats and stats.stored)
                end)
                checked("Inventory snapshot",function()
                    local ok,result=pcall(function() return require(RS.Library.Client.Save).Get() end)
                    if ok and type(result)=="table" then save=result end
                    if save and type(save.Inventory)=="table" then inv=save.Inventory end
                    local loot,stacks,invalid=countCategory(inv,"Lootbox")
                    return inv and "READY" or "BLOCKED",
                        "Save readable="..tostring(inv~=nil).."; Lootbox count="..tostring(loot)..
                        "; stacks="..stacks.."; invalid stacks="..invalid
                end)
                checked("Worker lifecycle",function()
                    local wanted={"auto-gift-worker","auto-lootbox-worker","spin-wheel",
                        "event-upgrade-purchases","charm-attachments","rank-completion",
                        "balloon-gifts","rank-rewards","forever-free-rewards"}
                    local issues={}
                    local critical=false
                    for _,name in ipairs(wanted) do
                        local item=WORKER_STATUS[name]
                        if not item then issues[#issues+1]=name..": missing"
                        elseif item.state~="running" then
                            issues[#issues+1]=name..": "..tostring(item.state)
                            if item.state=="failed" or item.state=="unloaded" then critical=true end
                        end
                    end
                    return critical and "BLOCKED" or (#issues>0 and "ATTENTION" or "READY"),
                        #issues>0 and table.concat(issues,"; ") or (#wanted.." workers running (not proof of successful actions)")
                end)
                checked("Auto Open Lootboxes",function()
                    local ok,signal=pcall(function()return require(RS.Library.Signal)end)
                    local lb=REQUEST_STATUS.lootboxes
                    if not ok or type(signal)~="table" or type(signal.Invoke)~="function" or type(lb)~="table" then
                        return "BLOCKED","Lootbox_RequestOpen dispatcher or worker unavailable" end
                    local n,stacks,invalid=countCategory(inv,"Lootbox")
                    if not n then return "ATTENTION","Lootbox inventory unavailable/invalid ("..invalid.." invalid stacks)" end
                    local chosen=tostring(State.LootboxSelection or "All")
                    local chosenCount=0
                    for _,entry in pairs(inv.Lootbox) do
                        if type(entry)=="table" and entry.id==chosen then chosenCount+=(positiveAmount(entry) or 0) end
                    end
                    local unconfirmed=tonumber(lb.unconfirmed) or 0
                    return (n>0 and unconfirmed==0 and (chosen=="All" or chosenCount>0)) and "READY" or "ATTENTION",
                        "Owned="..n.." in "..stacks.." stacks; selection="..chosen.." (owned="..chosenCount..")"..
                        "; unconfirmed="..unconfirmed.."; opening NOT attempted"
                end)
                checked("Auto Spin Wheel",function()
                    local endpoint=Network and Network:FindFirstChild("Spinny Wheel: Request Spin")
                    if not endpoint or not endpoint:IsA("RemoteFunction") then
                        return "BLOCKED","Spin endpoint not present" end
                    if not inv then return "ATTENTION","Inventory unavailable; tickets not measurable" end
                    local count,ticketNames=0,{}
                    for _,category in pairs(inv) do
                        if type(category)=="table" then
                            for _,entry in pairs(category) do
                                if type(entry)=="table" and type(entry.id)=="string" then
                                    local id=entry.id:lower()
                                    if id:find("wheel",1,true) and id:find("ticket",1,true) then
                                        local amount=positiveAmount(entry)
                                        if amount then count+=amount ticketNames[entry.id]=true end
                                    end
                                end
                            end
                        end
                    end
                    local titles={}
                    for name in pairs(ticketNames) do titles[#titles+1]=name end
                    table.sort(titles)
                    local ok,known=pcall(function()
                        return require(RS.Library.Directory.SpinnyWheels).StarterWheel~=nil end)
                    return count>0 and ok and known and "READY" or "ATTENTION",
                        "Wheel tickets="..count.." ("..table.concat(titles,", ")..")"..
                        "; StarterWheel defined="..tostring(ok and known or false).."; no spin sent"
                end)
                checked("Auto Buy Event Upgrades",function()
                    local ok,cmds,dir=pcall(function()
                        return require(RS.Library.Client.EventUpgradeCmds),require(RS.Library.Directory.EventUpgrades) end)
                    if not ok or type(cmds)~="table" or type(cmds.GetTier)~="function" or
                        type(cmds.Purchase)~="function" or type(dir)~="table" or
                        type(REQUEST_STATUS.eventUpgrades)~="table" then
                        return "BLOCKED","Event upgrade module/worker unavailable; standard upgrades unsupported" end
                    local definitions=0
                    for _,entry in pairs(dir) do
                        if type(entry)=="table" and type(entry.TierCosts)=="table" then definitions+=1 end
                    end
                    return definitions>0 and "READY" or "ATTENTION",
                        "Event upgrade definitions="..definitions.."; session cap="..
                        tostring(State.EventUpgradeSessionLimit).."; affordability and tier outcomes NOT tested"
                end)
                checked("Auto Attach Charm",function()
                    local endpoint=Network and Network:FindFirstChild("Charms_AttachToPet")
                    if not endpoint or not endpoint:IsA("RemoteFunction") or type(REQUEST_STATUS.charmAttach)~="table" then
                        return "BLOCKED","Charm attach endpoint or worker missing" end
                    local n,stacks=countCategory(inv,"Charm")
                    if not n or n<=0 then return "ATTENTION","No readable owned charms" end
                    local uid=tostring(State.CharmPetUID or ""):match("^%s*(.-)%s*$")
                    local selection=tostring(State.CharmSelection or "Select charm")
                    local valid=uid~="" and type(inv.Pet)=="table" and inv.Pet[uid]~=nil
                    return valid and selection~="Select charm" and "READY" or "ATTENTION",
                        "Owned charms="..n.." in "..stacks.." stacks; selected="..selection..
                        "; pet UID present="..tostring(valid).."; free charm slots NOT validated; no attachment"
                end)
                checked("Auto Complete Rank",function()
                    local goals=activeGoals()
                    local missing,unfinished={},0
                    for _,goal in ipairs(goals) do
                        if type(goal)=="table" and tonumber(goal.Progress) and tonumber(goal.Amount) and goal.Progress<goal.Amount then
                            unfinished+=1
                            if not QUEST_NEED[goal.Type] then missing[tostring(goal.Type)]=true end
                        end
                    end
                    local unsupported={}
                    for key in pairs(missing) do unsupported[#unsupported+1]=key end
                    table.sort(unsupported)
                    local supported= #unsupported==0 and type(REQUEST_STATUS.rankComplete)=="table"
                    return supported and save and tonumber(save.Rank) and "READY" or "ATTENTION",
                        "Rank="..tostring(save and save.Rank or "unavailable").."; unfinished="..unfinished..
                        "; unsupported types="..(#unsupported>0 and table.concat(unsupported,",") or "none")..
                        "; coordinator not enabled by test"
                end)
                checked("Auto Pop Balloons",function()
                    local listRemote=Network and Network:FindFirstChild("BalloonGifts_GetActiveBalloons")
                    local hitRemote=Network and Network:FindFirstChild("BalloonGifts_BalloonHit")
                    local balloons=REQUEST_STATUS.balloons
                    if not listRemote or not listRemote:IsA("RemoteFunction") or not hitRemote or
                        not hitRemote:IsA("RemoteEvent") or not balloons then
                        return "BLOCKED","Discovery or hit event missing" end
                    return "ATTENTION","Observe only; nearby="..tostring(balloons.active or 0)..
                        "; hit payload unverified; no hit sent"
                end)
                checked("Preserved reward claim workers",function()
                    local rank=REQUEST_STATUS.rankClaims or {}
                    local forever=REQUEST_STATUS.foreverClaims or {}
                    if not REQUEST_STATUS.rankClaims or not REQUEST_STATUS.foreverClaims then
                        return "BLOCKED","Rank and/or Forever Pack worker status missing" end
                    return "READY","Session counters only: rank confirmed="..tostring(rank.verified or 0)..
                        "; Forever Pack confirmed="..tostring(forever.verified or 0).."; no claim sent"
                end)
                checked("Non-destructive settings check",function()
                    local after=copySettings()
                    local changed={}
                    for i=1,13 do
                        if before[i]~=after[i] then changed[#changed+1]=tostring(i) end
                    end
                    return #changed==0 and "READY" or "ATTENTION",
                        #changed==0 and "13 observed toggles/selections unchanged by preflight" or
                        ("Settings changed during preflight at indices "..table.concat(changed,",")..
                        " (may be concurrent user/worker activity)")
                end)
            end,debug.traceback)
            if not ok and active() then finish("Unexpected runner failure: "..tostring(err):sub(1,360))
            elseif active() then finish(nil) end
        end)
        if not started then
            if T.running and T.ticket==ticket then T.running=false T.status="Unable to schedule test" end
            return false,"Unable to start automated test"
        end
        -- Fail safely if a client-module read yields indefinitely. Late findings
        -- are ignored after the result is finalized; no pending gameplay request exists.
        task.delay(18,function()
            if active() then finish("Preflight exceeded 18s; remaining checks not completed") end
        end)
        return true,"Read-only preflight started; results in Diagnostics and ZHub Console"
    end
end

local rows = {
    {"h", "FARM"},
    {"b", "Collect", "Auto Collect Orbs (Unfinished)"},
    {"b", "CollectLootbags", "Auto Collect Lootbags (Unfinished)"},
    {"n", "CollectDelay", 1, 1, 5},
    {"b", "Breakables", "Breakables (Nearest Tap)"},
    {"b", "BuyZones"},
    {"s", "Collection and breakables"},
    {"b", "Tap", "Tap (Nearest Tap)"},
    {"b", "FastFarm", "Fast Tap Farm (Max / Smart)"},
    {"b", "NativeAutoTap", "Auto Tap - Nearest (Experimental)"},
    {"s", "Smart pet targeting (Experimental)"},
    {"b", "SmartPets", "Smart Pet Assignment V1.3 (Default Off)"},
    {"n", "SmartPetCount", 1, 1, 20},
    {"a", "SmartPetStats", "Print Smart Pet Statistics"},
    {"b", "OptBreak"},
    {"b", "OptPets"},
    {"b", "OptPart"},
    {"b", "OptGame"},
    {"n", "BreakDelay", 0.05, 0.05, 3},
    {"n", "Radius", 1, 10, 300},
    {"n", "Targets", 1, 1, 15},
    {"s", "Area progression"},
    {"b", "AutoBestArea", "Auto Teleport to Best Area"},
    {"b", "AutoNextArea"},
    {"b", "AutoBestWorld", "Auto Teleport to Best World"},
    {"b", "AutoUltimate"},
    {"n", "MinArea", 1, 1, 500},
    {"h", "HATCH"},
    {"s", "Buy eggs"},
    {"e", "EggSelection", "Select Egg"},
    {"b", "AutoHatch", "Auto Buy Selected Egg"},
    {"n", "HatchDelay", 0.05, 0.15, 3},
    {"s", "Hatch status"},
    {"l", "HatchStatus"},
    {"s", "Rare pet alerts"},
    {"b", "RareAlerts"},
    {"b", "RareTitanic"},
    {"b", "RareHuge"},
    {"b", "RareExclusive"},
    {"t", "Keywords", "Alert keywords"},
    {"t", "WebhookUrl", "Webhook URL"},
    {"n", "SummaryMins", 1, 0, 120},
    {"h", "AUTOMATIC"},
    {"s", "Gifts"},
    -- Place immediately below the Automatic heading so the control is visible
    -- without scrolling past the other automation settings.
    {"d", "GiftSelection", "Select Gifts (owned)", giftPickerOptions},
    {"b", "AutoOpenGifts", "Auto Open Selected Gifts"},
    {"l", "GiftStatus"},
    {"s", "Fruits"},
    {"d", "FruitSelection", "Select Fruits", {"Apple","Banana","Orange","Pineapple","Watermelon","Rainbow"}},
    {"b", "AutoEatFruits", "Auto Eat Selected Fruits"},
    {"s", "Potions"},
    {"d", "PotionSelection", "Select Potions", {"Coins","Damage","Diamonds","Lucky","Treasure Hunter","Walkspeed"}},
    {"b", "AutoUsePotions", "Auto Use Selected Potions"},
    {"n", "PotionRefillSeconds", 30, 0, 6000},
    {"s", "Toy buffs"},
    {"d", "BuffSelection", "Select Buffs", {"Squeaky Toy","Toy Ball","Toy Bone"}},
    {"b", "AutoUseBuffs", "Auto Use Selected Buffs"},
    {"l", "BuffStatus"},
    {"s", "Fruit and potion status"},
    {"l", "ConsumableStatus"},
    -- Gift controls belong to AUTOMATIC; do not create a separate tab here.
    {"s", "Consumables and tools"},
    {"b", "AutoUseMisc"},
    {"d", "FlagSelection", "Flag Type (owned)", AutoFlags.options},
    {"b", "AutoUseFlag", "Auto Flags (current zone)"},
    {"b", "AutoUseSprinkler", "Auto Sprinklers (current zone)"},
    {"b", "AutoUseTNT"},
    {"n", "TNTDelay", 0.5, 0.5, 60},
    {"b", "AutoUseTNTCrate"},
    {"n", "TNTCrateDelay", 1, 1, 120},
    {"b", "AutoRainbowFruits"},
    {"b", "AutoShinyFruits"},
    {"s", "Crafting and upgrading"},
    {"b", "AutoMakeGold"},
    {"b", "AutoMakeRainbow"},
    {"b", "AutoFuse"},
    {"t", "CraftPetSearch", "Search pet name"},
    {"d", "CraftPetMode", "Show pets for", {"All owned","Gold inputs","Rainbow inputs","Fuse inputs"}},
    {"d", "CraftPetSort", "Sort pets", {"Most owned","Name A-Z","Most eligible"}},
    {"a", "RefreshCraftPets", "Refresh owned pets now"},
    {"a", "ClearCraftFilter", "Clear pet search"},
    {"d", "FusePetName", "Select Pet (owned quantities)", REQUEST_STATUS.crafting.options},
    {"l", "CraftPetSelection"},
    {"n", "FusePetAmount", 1, 2, 10},
    {"l", "CraftingStatus"},
    {"s", "Charm attachment (manual pet UID; default off)"},
    {"d", "CharmSelection", "Select Owned Charm", function() return REQUEST_STATUS.charmAttach.options() end},
    {"t", "CharmPetUID", "Target Pet UID (from Eligible Pets report)"},
    {"n", "CharmSessionLimit", 1, 1, 10},
    {"a", "CharmEligibleReport", "Print Eligible Pet UIDs (read only)"},
    {"b", "AutoAttachCharm", "Auto Attach Selected Charm to Selected Pet"},
    {"l", "CharmStatus"},
    {"d", "UpgradePotionSelection", "Potions to upgrade", {"Coins","Damage","Diamonds","Lucky","Treasure Hunter","Walkspeed","Huge","The Cocktail"}},
    {"b", "AutoUpgradePotions", "Upgrade Selected Potions"},
    {"d", "UpgradeEnchantSelection", "Enchants to upgrade", {"Strong Pets","Coins","Criticals","Diamonds","Lucky Eggs","Treasure Hunter","Tap Power","Walkspeed","Magnet"}},
    {"b", "AutoUpgradeEnchants", "Upgrade Selected Enchants"},
    {"s", "Event upgrades (verified client module; not regular upgrades)"},
    {"d", "EventUpgradeSelection", "Choose Event Upgrade", function() return REQUEST_STATUS.eventUpgrades.options() end},
    {"n", "EventUpgradeSessionLimit", 1, 1, 50},
    {"b", "AutoBuyUpgrades", "Auto Buy Affordable Event Upgrades"},
    {"l", "EventUpgradeStatus"},
    {"b", "AutoBuyEggBundle"},
    {"s", "Chests and special items"},
    {"d", "LootboxSelection", "Select Lootboxes (owned)", function()return REQUEST_STATUS.lootboxes.options()end},
    {"b", "AutoOpenLootboxes", "Auto Open Selected Lootboxes"},
    {"l", "LootboxStatus"},
    {"d", "KeySelection", "Keys to combine", {"Crystal Key","Tech Key","MVP Key","Fantasy Key","Void Key","Secret Key","Treasure Hideout Key"}},
    {"b", "AutoCombineKeys", "Auto Combine Selected Keys"},
    {"b", "AutoOpenCrystalChest"},
    {"s", "Wheel tickets (StarterWheel only)"},
    {"b", "AutoSpinWheel", "Auto Spin StarterWheel (owned tickets only)"},
    {"l", "SpinStatus"},
    {"em", "EnchantManager"},
    {"h", "REWARDS"},
    {"s", "Free rewards"},
    {"b", "FreeGifts"},
    {"b", "Spinner"},
    {"n", "RewardEvery", 10, 10, 300},
    {"s", "Slot purchases"},
    {"b", "BuySlots"},
    {"n", "EggSlotMax", 1, 1, 100},
    {"b", "BuyEquipSlots"},
    {"n", "EquipSlotMax", 1, 1, 100},
    {"s", "Progression"},
    {"b", "AutoRebirth"},
    {"n", "RebirthMax", 1, 1, 999},
    {"b", "AutoQuest"},
    {"s", "Claims and collectibles"},
    {"b", "AutoClaimRank"},
    {"b", "AutoClaimForever"},
    {"l", "RewardClaimStatus"},
    {"b", "AutoShinyRelics"},
    {"s", "Balloon gifts (experimental requests)"},
    {"d", "BalloonMode", "Balloon interaction mode", {"Observe only", "Experimental ID hit"}},
    {"b", "AutoPopBalloons", "Track Balloons / Experimental Auto Hit"},
    {"l", "BalloonStatus"},
    {"s", "Rank completion (mapped goals only)"},
    {"b", "AutoCompleteRank", "Auto Rank Quest & Reward Coordinator"},
    {"l", "RankCompleteStatus"},
    {"n", "MaxRank", 1, 1, 100},
    {"s", "World activities"},
    {"b", "AutoLeaveStairway"},
    {"b", "AutoAdminAbuse"},
    {"b", "AutoTreehouse"},
    {"b", "AutoCrystalCastle"},
    {"h", "OTHER AUTOMATION"},
    {"b", "InfPetSpeed"},
    {"h", "HALLOWEEN"},
    {"s", "Halloween activities"},
    {"b", "HalloweenZone"},
    {"b", "HalloweenHatch"},
    {"b", "HalloweenForge"},
    {"b", "HalloweenUpgrade"},
    {"b", "AutoJoinHalloween"},
    {"b", "AutoPlayHalloween"},
    {"b", "AutoUseTricks"},
    {"b", "HalloweenDestroyDecor"},
    {"b", "HalloweenAutoTeleport"},
    {"n", "ForgeChance", 1, 0, 100},
    {"n", "ForgeShards", 1, 0, 1000},
    {"n", "PriorityWait", 1, 1, 120},
    {"h", "MISC"},
    {"s", "Client settings"},
    {"b", "AntiAFK"},
    {"b", "FPSBoost"},
    {"b", "AutoRejoin"},
    {"b", "Debug"},
    {"b", "Spy"},
    {"b", "HUD"},
    {"s", "Session and configuration"},
    {"a", "Rejoin", "Rejoin"},
    {"a", "ServerHop", "Server Hop"},
    {"a", "SaveConfig", "Save Config"},
    {"a", "RefreshLists", "Refresh Egg and Gift Lists"},
    {"a", "GiftDiagnostic", "Diagnose Owned Gifts (no opening)"},
    {"a", "Unload", "Unload"},    {"s", "Movement"},
    {"b", "WalkSpeedEnable"},
    {"n", "WalkSpeed", 1, 16, 200},
    {"b", "JumpPowerEnable"},
    {"n", "JumpPower", 1, 50, 250},
    {"b", "InfiniteJump"},
    {"b", "NoClip"},
    {"s", "Display and diagnostics"},
    {"b", "WhiteScreen"},
    {"b", "RecordConsole"},
    {"t", "SpyFilter", "Remote spy filter"},
    {"n", "RejoinMins", 1, 1, 120},
    {"s", "One-click automated feature testing"},
    {"a", "RunAutomatedTests", "Run All Feature Tests (Safe • No Spending)"},
    {"l", "AutomatedTestStatus"},
    {"s", "Session status"},
    {"a", "AutomationStatus", "Automation Status"},
    {"a", "FullDiagnostics", "Full Diagnostics (print and copy)"},
    {"a", "RetryWorkers", "Retry Failed Workers"},
    {"a", "RecoverTravel", "Check / Recover World Travel"},
    {"l", "TravelStatus"},
    {"l", "FeatureHealth"},
    {"a", "VerifyFeatures", "Run Read-Only Inventory Check"},
    {"a", "ReloadEggCatalog", "Reload Local Egg Catalog"},
    {"l", "PerformanceStatus"},
    {"l", "WorkerStatus"},
    {"s", "GUI & source verification"},
    {"a", "GuiAudit", "Audit All GUI Controls"},
    {"a", "ConsoleSelfTest", "Test Live Console (info + warning)"},
    {"a", "CaptureMechanics", "Capture Missing Feature Sources (read-only)"},
    {"a", "RankGoalReport", "Print Active Rank Goals (read-only)"},
    {"l", "CaptureStatus"},
    {"l", "GuiStatus"},

    {"h", "CONSOLE"},
    {"a", "OpenConsole", "Open Console"},

}

local actions = {
    SmartPetStats = function()
        if _G.AERO_PS99_SmartPetStats then _G.AERO_PS99_SmartPetStats() else REQUEST_STATUS.notify("Smart pet worker not ready") end
    end,
    OpenConsole = function()
        if REQUEST_STATUS.console then REQUEST_STATUS.console.show() else REQUEST_STATUS.notify("Console is initializing") end
    end,
    Rejoin = rejoin,
    ServerHop = serverHop,
    SaveConfig = function() REQUEST_STATUS.notify(saveCfg() and "config saved" or "config save failed") end,
    RefreshLists = function() if _G.AERO_PS99_RefreshUI then _G.AERO_PS99_RefreshUI() end end,
    AutomationStatus = function()
        print("[AERO ENGINE] "..REQUEST_STATUS.automation.summary())
        REQUEST_STATUS.notify(REQUEST_STATUS.automation.summary())
    end,
    GuiAudit = function()
        if type(_G.AERO_PS99_GUI_Audit)=="function" then
            local ok,msg=pcall(_G.AERO_PS99_GUI_Audit)
            print("[AERO UI AUDIT] "..tostring(msg))
            REQUEST_STATUS.notify(ok and "GUI audit printed to Console" or "GUI audit failed")
        else REQUEST_STATUS.notify("GUI not ready") end
    end,
    ConsoleSelfTest = function()
        print("[AERO CONSOLE TEST] INFO - live-message test v8.2.84")
        warn("[AERO CONSOLE TEST] WARNING - this is a deliberate test, not an error")
        local c=REQUEST_STATUS.console
        local ok,stats=pcall(function() return c and c.stats() end)
        print("[AERO CONSOLE TEST] state="..tostring(ok and stats and stats.active).." stored="..tostring(ok and stats and stats.stored))
        REQUEST_STATUS.notify("Console info/warning test printed")
    end,
    CaptureMechanics = function()
        local ok,message=REQUEST_STATUS.mechCapture.capture()
        REQUEST_STATUS.notify(message)
    end,
    RankGoalReport = function()
        local goals=activeGoals()
        print("[AERO RANK GOALS] Active entries="..#goals)
        for i,g in ipairs(goals) do
            print(string.format("[AERO RANK GOALS] #%d Type=%s Progress=%s/%s Stars=%s UID=%s",i,
                tostring(g.Type),tostring(g.Progress),tostring(g.Amount),tostring(g.Stars),tostring(g.UID)))
        end
        REQUEST_STATUS.notify("Rank goals printed; read-only")
    end,
    RunAutomatedTests = function()
        local fn=REQUEST_STATUS.autoTest and REQUEST_STATUS.autoTest.run
        if type(fn)=="function" then
            local ok,why=fn()
            REQUEST_STATUS.notify(why)
        else REQUEST_STATUS.notify("Automated test system unavailable") end
    end,
    FullDiagnostics = function()
        local ok,message=REQUEST_STATUS.verification.export()
        REQUEST_STATUS.notify(message)
    end,
    RetryWorkers = function() REQUEST_STATUS.notify("Restarted failed workers: "..retryFailedWorkers()) end,
    RecoverTravel = function()
        if type(REQUEST_STATUS.recoverTravel)=="function" then
            local ok,message=REQUEST_STATUS.recoverTravel()
            REQUEST_STATUS.notify(message)
        else REQUEST_STATUS.notify("World travel worker is initializing") end
    end,
    RefreshCraftPets = function()
        spawnTask(function()
            local ok,err=pcall(REQUEST_STATUS.crafting.refreshCatalog)
            if not ok then REQUEST_STATUS.notify("Pet refresh failed: "..tostring(err)) end
            if type(_G.AERO_PS99_RefreshUI)=="function" then _G.AERO_PS99_RefreshUI() end
        end)
    end,
    ClearCraftFilter = function()
        State.CraftPetSearch="" saveCfg()
        if type(_G.AERO_PS99_RefreshUI)=="function" then _G.AERO_PS99_RefreshUI() end
        REQUEST_STATUS.notify("Pet search cleared")
    end,
    VerifyFeatures = function() local ok,message=REQUEST_STATUS.verification.probe() REQUEST_STATUS.notify(message) end,
    ReloadEggCatalog = function() spawnTask(function() EggSelector.load() if type(_G.AERO_PS99_RefreshUI)=="function" then _G.AERO_PS99_RefreshUI() end end) end,
    GiftDiagnostic = giftDiagnostic,
    CharmEligibleReport = function()
        local fn=REQUEST_STATUS.charmAttach and REQUEST_STATUS.charmAttach.eligibleReport
        if type(fn)=="function" then
            local ok,message=pcall(fn)
            REQUEST_STATUS.notify(ok and tostring(message) or "Eligible-pet report failed: "..tostring(message))
        end
    end,
    Unload = cleanup,
}

local guiOptions = {
    cfg = combined,
    interface=InterfaceSettings,
    onInterfaceChange=saveCfg,
    rows = rows,
    actions = actions,
    title = "AERO_PS99 v8.2.84",
    name = "AERO_PS99",
    toggleKey = Enum.KeyCode.Insert,
    getValue=function(key)
        if key=="FusePetName" then
            REQUEST_STATUS.crafting.options()
            return REQUEST_STATUS.crafting.labelById[State.FusePetName] or "Select a pet"
        end
        if Flags[key]~=nil then return Flags[key] end
        return State[key]
    end,
    describe=function(key)
        if key=="AutomatedTestStatus" then return REQUEST_STATUS.autoTest and REQUEST_STATUS.autoTest.summary() or "Not initialized" end
        if key=="LootboxStatus" then return REQUEST_STATUS.lootboxes.summary() end
        if key=="SpinStatus" then return REQUEST_STATUS.spin.summary() end
        if key=="EventUpgradeStatus" then return REQUEST_STATUS.eventUpgrades.summary() end
        if key=="CharmStatus" then return REQUEST_STATUS.charmAttach.summary() end
        if key=="BalloonStatus" then return REQUEST_STATUS.balloons.summary() end
        if key=="RankCompleteStatus" then return REQUEST_STATUS.rankComplete.summary() end
        if key=="CaptureStatus" then return REQUEST_STATUS.mechCapture.status end
        if key=="GuiStatus" then
            local fn=_G.AERO_PS99_GUI_Audit
            return type(fn)=="function" and fn() or "GUI audit is initializing"
        end
        if key=="RewardClaimStatus" then return "Rank: "..tostring(REQUEST_STATUS.rankClaims and REQUEST_STATUS.rankClaims.status or "Starting").." | Forever Pack (free only): "..tostring(REQUEST_STATUS.foreverClaims and REQUEST_STATUS.foreverClaims.status or "Starting") end
        if key=="EnchantPaused" then return "Enchant auto-equip is paused pending verified equip-slot behavior; it has not been enabled." end
        if key=="PerformanceStatus" then return performanceSummary() end
        if key=="FeatureHealth" then
            local lines={}
            for _,row in ipairs(REQUEST_STATUS.verification.health()) do
                if row.feature=="EggCatalog" or row.feature=="InventoryRead" or row.feature=="AutoHatch" or row.feature=="AutoRebirth" or row.feature=="Breakables" or row.feature=="AutoOpenGifts" then
                    lines[#lines+1]=row.feature..": "..row.state
                end
            end
            return table.concat(lines,"\n")
        end
        if key=="CraftPetSelection" then return REQUEST_STATUS.crafting.selectionStatus() end
        if key=="CraftingStatus" then return REQUEST_STATUS.crafting.status end
        if key=="TravelStatus" then return REQUEST_STATUS.travelStatus or "World travel idle" end
        if key=="WorkerStatus" then return workerDiagnosticSummary().." | Worker errors: "..tostring(WORKER_DIAGNOSTICS.total).." | "..tostring(WORKER_DIAGNOSTICS.last and WORKER_DIAGNOSTICS.last.error or "None") end
        if key=="ConsumableStatus" then return ConsumableStatus.text end
        if key=="BuffStatus" then return BuffStatus.text end
        if key=="GiftStatus" then return GiftStatus.text end
        if key=="HatchStatus" then
            local id,err,row,distance=EggSelector.resolve()
            local resolved=row and string.format("Selected: #%d • %s",row.number,row.name) or (err or "Waiting for egg data")
            local maxCount,capacityError=EggSelector.maxHatch()
            local capacity=maxCount and ("Max hatch: "..maxCount) or capacityError
            if distance then resolved=resolved..string.format(" (%.1f studs)",distance) end
            return resolved.."\n"..capacity.."\n"..HatchStatus.text
        end
        return key
    end,
    onChange = function(c,key)
        -- Apply only the edited control; quest workers may have changed other flags.
        if Flags[key]~=nil then Flags[key]=c[key]
        elseif State[key]~=nil then State[key]=c[key] end
        Flags.DisableEggAnim=true
        if key=="FPSBoost" or key=="OptGame" then applyRender() end
        if key=="OptPart" then
            if Flags.OptPart then startParticleOptimization() else stopParticleOptimization() end
        end
        if key=="CraftPetSearch" or key=="FusePetName" or key=="CraftPetMode" or key=="CraftPetSort" or key=="FusePetAmount" then
            if type(_G.AERO_PS99_RefreshUI)=="function" then _G.AERO_PS99_RefreshUI() end
        end
        syncSpy()
        saveCfg()
    end,
    onUnload = cleanup,
}
local okGui,gui=xpcall(function() return GuiLib.new(guiOptions) end,debug.traceback)
if not okGui then
    rawWarn("[AERO UI] Initialization failed; cleaning up: "..tostring(gui))
    if type(_G.AERO_PS99_BOOT_FAIL)=="function" then _G.AERO_PS99_BOOT_FAIL("GUI initialization: "..tostring(gui)) end
    cleanup()
    return
end
if type(_G.AERO_PS99_BOOT_READY)=="function" then _G.AERO_PS99_BOOT_READY() end

_G.AERO_PS99_RefreshUI=function() if gui then gui:refresh() end end
-- P15 benchmark bridge: no additional top-level local declarations.
_G.__AERO_PS99_FAST_BENCH_BRIDGE = {version=2, rateOverride=nil}
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:IsAlive()
    return isRunning() and _G.__AERO_PS99_FAST_BENCH_BRIDGE == self
end
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:GetFastFarm()
    if not self:IsAlive() then return nil end
    return Flags.FastFarm == true
end
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:SetFastFarm(value)
    if not self:IsAlive() or type(value) ~= "boolean" then return false, "inactive or invalid value" end
    Flags.FastFarm = value
    return true
end
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:GetTapRateOverride()
    if not self:IsAlive() then return nil end
    return self.rateOverride
end
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:SetTapRateOverride(value)
    if not self:IsAlive() or (value ~= nil and value ~= 4 and value ~= 8) then return false, "inactive or invalid rate" end
    self.rateOverride = value
    return true
end
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:GetSmartPetEnabled()
    if not self:IsAlive() then return nil end
    return Flags.SmartPets == true
end
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:SetSmartPetEnabled(value)
    if not self:IsAlive() or type(value) ~= "boolean" then return false, "inactive or invalid value" end
    Flags.SmartPets = value
    return Flags.SmartPets == value
end
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:GetSmartPetCount()
    if not self:IsAlive() then return nil end
    return math.clamp(math.floor(tonumber(State.SmartPetCount) or 5), 1, 20)
end
function _G.__AERO_PS99_FAST_BENCH_BRIDGE:SetSmartPetCount(value)
    if not self:IsAlive() or type(value) ~= "number" or value ~= math.floor(value)
        or value < 1 or value > 20 then return false, "inactive or invalid cohort size" end
    State.SmartPetCount = value
    return self:GetSmartPetCount() == value
end
onCleanup(function()
    _G.__AERO_PS99_FAST_BENCH_BRIDGE = nil
end)
print("[AERO P17 BRIDGE] Ready | version=2 | SmartPets and cohort control=yes")
onCleanup(function() if gui then gui:destroy() end _G.AERO_PS99_RefreshUI=nil end)

-- keep the stats update pointing at the new status
guardedSpawn("worker-18", function()
    while isRunning() do
        pcall(function() if gui and gui.setStatus then gui:setStatus(statsLine().." | Egg skip: "..eggAnimationStatus) end end)
        task.wait(1)
    end
end)


guardedSpawn("egg-api-refresh", function()
    while isRunning() do
        task.wait(300)
        if loadEggsFromApi() then
            debugLog("eggs", "API refreshed, " .. #EggLabels .. " eggs")
            if gui then pcall(function()gui:refresh()end) end
        end
    end
end)

print("[AERO_PS99] v8.2.84 P24.4 loaded — Insert to toggle | " .. tostring(cfgMessage))

spawnTask(function()
    local ok,err=xpcall(function()
-- Key combination endpoints taken from the game's action-menu source.
local AutoKeys=(function()
    local U={pending=nil,nextAttempt=0,cursor=0,lastLog=nil}
    local specs={
        {id="Crystal Key",endpoint="CrystalKey_Combine"},
        {id="Tech Key",endpoint="TechKey_Combine"},
        {id="MVP Key",endpoint="MVPKey_Combine",subscription=true},
        {id="Fantasy Key",endpoint="FantasyKey_Combine"},
        {id="Void Key",endpoint="VoidKey_Combine"},
        {id="Secret Key",endpoint="SecretKey_Combine",flag="SecretKeyCombine"},
        {id="Treasure Hideout Key",endpoint="TreasureHideout_Combine",flag="TreasureKeyCombine"},
    }
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    local function enabled() return isRunning() and Flags.AutoCombineKeys end
    function U.log(s) REQUEST_STATUS.automation.note("keys",s) if U.lastLog~=s then U.lastLog=s print("[AERO KEYS] "..s) end end
    function U.selected(id)
        -- No implicit All selection: only explicitly named key types.
        return State.KeySelection~="All" and selectedName(State.KeySelection,id)
    end
    function U.snapshot(id,fresh)
        -- One Misc traversal per tick; refresh explicitly after yielding preflight calls.
        if fresh or not U.inventoryIndex then
            U.save=U.save or require(RS.Library.Client.Save)
            local data=U.save.Get()
            local misc=data and data.Inventory and data.Inventory.Misc
            if type(misc)~="table" then return nil end
            local totals={}
            for _,entry in pairs(misc) do
                if type(entry)=="table" and type(entry.id)=="string" then
                    local n=entry._am==nil and 1 or tonumber(entry._am)
                    if finite(n) and n>0 then totals[entry.id]=(totals[entry.id] or 0)+math.floor(n) end
                end
            end
            U.inventoryIndex=totals
        end
        local index=U.inventoryIndex
        return {upper=index[id.." Upper Half"] or 0,lower=index[id.." Lower Half"] or 0,full=index[id] or 0}
    end
    function U.allowed(spec)
        local client=RS.Library.Client
        if spec.subscription then
            U.sub=U.sub or require(client.SubscriptionCmds)
            if U.sub.HasMainSubscription()~=true then return false end
        end
        if spec.flag then
            U.ff=U.ff or require(client.FFlags)
            local key=U.ff.Keys[spec.flag]
            if not key or U.ff.Get(key)~=true then return false end
        end
        return true
    end
    function U.plan(spec)
        -- Read account perks again each batch, including after mastery changes.
        U.mastery=U.mastery or require(RS.Library.Client.MasteryCmds)
        local limit=U.mastery.HasPerk("Keys","CombineAll")==true and 100 or 10
        local stock=U.snapshot(spec.id,true)
        if not stock then return nil end
        local pairsAvailable=math.min(stock.upper,stock.lower)
        return stock,math.min(pairsAvailable,limit),limit,pairsAvailable
    end
    function U.tick()
        U.inventoryIndex=nil
        if not isRunning() then return end
        local now=os.clock()
        if now<U.nextAttempt and not U.pending then return end
        if U.pending then
            local p=U.pending
            local readOK,after=pcall(U.snapshot,p.spec.id)
            if readOK and after and after.upper<=p.before.upper-p.quantity and after.lower<=p.before.lower-p.quantity and after.full>=p.before.full+p.quantity then
                REQUEST_STATUS.automation.finish(p.token,"verified",p.quantity)
                U.pending=nil
                local remaining=math.min(after.upper,after.lower)
                U.log("Combine verified: "..p.spec.id.." x"..p.quantity.." | Pairs left: "..remaining)
                -- Finish this type's remaining batches before moving to the next selection.
                if remaining>0 and enabled() and U.selected(p.spec.id) then U.cursor=p.index-1 end
            elseif now>=p.deadline then
                REQUEST_STATUS.automation.finish(p.token,"unconfirmed")
                U.pending=nil p.spec.nextAttempt=now+60 U.log("Combine accepted; inventory unconfirmed - waiting")
            end
            return
        end
        if not enabled() then REQUEST_STATUS.automation.note("keys","Key combining toggle is off","disabled") return end
        for step=1,#specs do
            local i=(U.cursor+step-1)%#specs+1 local spec=specs[i]
            if U.selected(spec.id) and now>=(spec.nextAttempt or 0) then
                if not U.allowed(spec) then
                    spec.nextAttempt=now+30 U.log("Unavailable under current game restrictions: "..spec.id)
                else
                    local before=U.snapshot(spec.id)
                    if before and before.upper>0 and before.lower>0 then
                        U.network=U.network or require(RS.Library.Client.Network)
                        local quantity,limit,pairsAvailable
                        before,quantity,limit,pairsAvailable=U.plan(spec)
                        if not before or quantity<1 then return end
                        U.log("Batch plan: "..spec.id.." | Account limit: "..limit.." | Upper: "..before.upper.." | Lower: "..before.lower.." | Combining: "..quantity.." | Remaining after: "..(pairsAvailable-quantity))
                        if not enabled() or not U.selected(spec.id) then return end
                        -- Server remains authoritative for all per-key restrictions.
                        local token=REQUEST_STATUS.automation.acquire("keys")
                        if not token then return end
                        spec.nextAttempt=os.clock()+30 U.nextAttempt=os.clock()+1 U.cursor=i
                        local ok,accepted,message=REQUEST_STATUS.automation.invoke(token,U.network.Invoke,spec.endpoint,quantity)
                        if not isRunning() then return end
                        if ok and accepted==true then
                            spec.nextAttempt=os.clock()+1
                            U.pending={token=token,spec=spec,index=i,before=before,quantity=quantity,deadline=os.clock()+8}
                            U.log("Server accepted: "..spec.id.." x"..quantity)
                        else U.log("Combine deferred: "..spec.id.." | "..tostring(message or accepted)) end
                        return
                    end
                end
            end
        end
        REQUEST_STATUS.automation.note("keys","Waiting for selected matching halves or key restrictions to clear","waiting")
        U.nextAttempt=now+5
    end
    onCleanup(function() U.pending=nil U.inventoryIndex=nil end)
    return U
end)()
Flags.AutoCombineKeys=false
-- Toggle must be explicitly enabled for the selected key types each execution.
guardedSpawn("auto-keys",function()
    while isRunning() do
        local ok,err=pcall(AutoKeys.tick)
        if not ok then AutoKeys.nextAttempt=os.clock()+30 AutoKeys.log("Waiting after error: "..tostring(err)) end
        task.wait(0.5)
    end
end)


    end,debug.traceback)
    if not ok then warn("[AERO KEYS] Initialization failed: "..tostring(err)) end
end)

-- Independent watchdog runs even if neither batch worker is requesting new work.
guardedSpawn("automation-health",function()
    while isRunning() do
        REQUEST_STATUS.automation.poll()
        task.wait(2)
    end
end)

spawnTask(function()
-- Native area teleport verified in the user's V7 live test.
local BestArea=(function()
    local U={pending=nil,nextAt=0,target=nil,since=0,last=nil}
    function U.note(reason)
        REQUEST_STATUS.automation.note("best-area",reason)
        if U.last~=reason then U.last=reason print("[AERO AREA] "..reason) end
    end
    function U.tick()
        if not isRunning() then return end
        if not U.pending and not Flags.AutoBestArea then U.target=nil return end
        if REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.farmMoveBusy then U.target=nil U.note("Paused during world transition") return end
        local now=os.clock()
        if not U.pending and now<U.nextAt then return end
        local lib=RS.Library
        U.map=U.map or require(lib.Client.MapCmds)
        U.zones=U.zones or require(lib.Client.ZoneCmds)
        U.instances=U.instances or require(lib.Client.InstancingCmds)
        U.teleport=U.teleport or require(lib.Client.TeleportMapCmds)
        local current=U.map.GetCurrentZone()
        if U.pending then
            if current==U.pending.target then
                U.note("Arrival verified: "..current) REQUEST_STATUS.areaTravelBusy=false U.pending=nil U.nextAt=now+15
            elseif now>=U.pending.deadline then
                U.note("Arrival unconfirmed; waiting before retry") REQUEST_STATUS.areaTravelBusy=false U.pending=nil U.nextAt=now+60
            end
            return
        end
        if U.instances.IsInInstance() or U.map.GetCurrentInstanceInfo()~=nil then U.target=nil U.nextAt=now+5 U.note("Paused inside an instance") return end
        if Flags.AutoHatch then U.target=nil U.nextAt=now+5 U.note("Paused while auto hatch is enabled") return end
        if not HRP or not HRP.Parent or type(current)~="string" then U.target=nil U.nextAt=now+3 return end
        local best=U.zones.GetMaximumZone()
        local target=type(best)=="table" and (best.ZoneName or best._id)
        if type(target)~="string" or target=="" or not U.zones.Owns(target) then U.target=nil U.nextAt=now+10 U.note("Waiting for an owned destination") return end
        if current==target then U.target=nil U.nextAt=now+5 U.note("Already at best area: "..target) return end
        U.directory=U.directory or require(lib.Directory)
        local here=U.directory.Zones[current]
        if type(here)~="table" or type(here.WorldNumber)~="number" or type(best.WorldNumber)~="number" or here.WorldNumber~=best.WorldNumber then
            U.target=nil U.nextAt=now+15 U.note("Best area is in another or unknown world; area teleport waiting") return
        end
        if U.target~=target then U.target=target U.since=now return end
        if now-U.since<3 then return end
        U.ff=U.ff or require(lib.Client.FFlags)
        if not U.ff.Keys.Teleporting or U.ff.Get(U.ff.Keys.Teleporting)~=true or U.teleport.UnlockedTeleport()~=true then U.nextAt=now+15 U.note("Teleport unavailable under account or game restrictions") return end
        local allowed,reason=U.teleport.CanTeleportTo(target)
        if allowed~=true then U.nextAt=now+10 U.note("Teleport blocked: "..tostring(reason or "busy")) return end
        -- Recheck after potentially yielding client calls; never act on a stale destination.
        if not isRunning() or not Flags.AutoBestArea or Flags.AutoHatch or U.instances.IsInInstance() or REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.farmMoveBusy then return end
        local fresh=U.zones.GetMaximumZone()
        if type(fresh)~="table" or (fresh.ZoneName or fresh._id)~=target or U.map.GetCurrentZone()==target then U.target=nil return end
        U.nextAt=os.clock()+30
        REQUEST_STATUS.areaTravelBusy=true
        local ok,result=pcall(U.teleport.TeleportZones,target)
        if not isRunning() then return end
        if ok and result==true then
            U.pending={target=target,deadline=os.clock()+12}
            U.note("Teleport accepted: "..target.."; checking arrival")
        else REQUEST_STATUS.areaTravelBusy=false U.nextAt=os.clock()+30 U.note("Teleport deferred: "..tostring(result)) end
    end
    onCleanup(function() U.pending=nil U.target=nil REQUEST_STATUS.areaTravelBusy=false end)
    return U
end)()
guardedSpawn("best-area",function()
    while isRunning() do
        local ok,err=pcall(BestArea.tick)
        if not ok then
            if BestArea.pending and os.clock()>=BestArea.pending.deadline then BestArea.pending=nil REQUEST_STATUS.areaTravelBusy=false end
            BestArea.nextAt=os.clock()+30 BestArea.note("Waiting after error: "..tostring(err))
        end
        task.wait(0.5)
    end
end)

end)

spawnTask(function()
local BestWorld=(function()
    local U={nextAt=0,target=nil,since=0,pending=nil,last=nil}
    function U.note(s)
        REQUEST_STATUS.automation.note("best-world",s)
        REQUEST_STATUS.travelStatus=s
        if U.last~=s then U.last=s print("[AERO WORLD] "..s) end
    end
    function U.detect()
        if not HRP or not HRP.Parent then return nil end
        local current=U.map.GetCurrentZone()
        if type(current)~="string" then return nil end
        local world,map,count=nil,nil,0
        for _,obj in ipairs(Workspace:GetChildren()) do
            local n=obj.Name=="Map" and 1 or tonumber(obj.Name:match("^Map(%d+)$"))
            if n then count+=1 world=n map=obj end
        end
        if count~=1 then return nil end
        local zone=nil
        for _,obj in ipairs(map:GetChildren()) do
            if obj.Name:gsub("^%d+%s*|%s*","")==current then
                if zone then return nil end
                zone=obj
            end
        end
        if not zone then return nil end
        -- Only inspect the current zone, not every part in every loaded map.
        for _,part in ipairs(zone:GetDescendants()) do
            if part:IsA("BasePart") and (part.Position-HRP.Position).Magnitude<=256 then return world end
        end
        return nil
    end
    function U.resolvePending(now)
        local p=U.pending
        if not p then return true,"No world travel pending" end
        if p.invoking then
            U.note("World travel response pending; holding lock to prevent overlap")
            return false,"Still awaiting the world travel call; no duplicate request sent"
        end
        local ok,current=pcall(U.detect)
        if ok and current then
            if current==p.world then
                U.pending=nil REQUEST_STATUS.worldTravelBusy=false U.nextAt=now+15
                U.note("World arrival verified: "..current)
                return true,"World arrival verified"
            end
            if p.observedWorld==current then p.stableCount=(p.stableCount or 0)+1
            else p.observedWorld=current p.stableCount=1 p.stableSince=now end
            if now>=p.deadline and p.stableCount>=3 and now-(p.stableSince or now)>=8 then
                -- The call returned and the old/another world is consistently
                -- detected. Stop auto travel; do not silently resend the request.
                U.pending=nil U.target=nil Flags.AutoBestWorld=false
                REQUEST_STATUS.worldTravelBusy=false U.nextAt=now+60
                U.note("Recovered unconfirmed world travel in world "..current.."; auto world travel off")
                return true,"Travel lock recovered; AutoBestWorld switched off"
            end
        else p.observedWorld=nil p.stableCount=0 p.stableSince=nil end
        U.note("World arrival unconfirmed; checking stable world context (no resend)")
        return false,"Waiting for a stable world context; retry this check after a few seconds"
    end
    REQUEST_STATUS.recoverTravel=function()
        if not isRunning() then return false,"Script unloaded" end
        if U.pending and os.clock()<(U.recoveryCheckAt or 0) then return false,"Wait a few seconds before checking again" end
        U.recoveryCheckAt=os.clock()+4
        return U.resolvePending(os.clock())
    end
    function U.tick()
        if not isRunning() then return end
        if U.pending then
            if os.clock()<(U.pending.pollAt or 0) then return end
            U.pending.pollAt=os.clock()+5
            U.resolvePending(os.clock())
            return
        end
        if not Flags.AutoBestWorld then U.target=nil return end
        local now=os.clock()
        if now<U.nextAt then return end
        U.nextAt=now+5
        local c=RS.Library.Client
        U.map=U.map or require(c.MapCmds)
        U.zones=U.zones or require(c.ZoneCmds)
        U.instances=U.instances or require(c.InstancingCmds)
        U.teleport=U.teleport or require(c.TeleportMapCmds)
        if U.instances.IsInInstance() or U.map.GetCurrentInstanceInfo()~=nil then U.target=nil U.note("Paused inside an instance") return end
        local current=U.detect()
        if not current then U.target=nil U.note("Active world uncertain; waiting for one matching map near the character") return end
        if Flags.AutoHatch or REQUEST_STATUS.areaTravelBusy or REQUEST_STATUS.farmMoveBusy then U.target=nil U.note("Paused for hatching or area travel") return end
        local best=U.zones.GetMaximumZone()
        local target=type(best)=="table" and best.WorldNumber
        if type(target)~="number" or target<1 or target~=math.floor(target) then U.target=nil U.note("Best world unavailable") return end
        if current==target then U.target=nil U.note("Already in best world: "..current) return end
        if U.teleport.CanTeleportToWorldRaw(target)~=true then U.target=nil U.note("Best world is not unlocked") return end
        if U.target~=target then U.target=target U.since=now return end
        if now-U.since<5 then return end
        if not isRunning() or not Flags.AutoBestWorld or Flags.AutoHatch or U.instances.IsInInstance() or REQUEST_STATUS.areaTravelBusy or REQUEST_STATUS.farmMoveBusy then return end
        local fresh=U.zones.GetMaximumZone()
        if type(fresh)~="table" or fresh.WorldNumber~=target then U.target=nil return end
        if not isRunning() or not Flags.AutoBestWorld or Flags.AutoHatch or U.instances.IsInInstance() or REQUEST_STATUS.areaTravelBusy or REQUEST_STATUS.farmMoveBusy then return end
        U.pending={world=target,deadline=os.clock()+45,invoking=true}
        REQUEST_STATUS.worldTravelBusy=true
        U.note("Requesting world travel: "..target)
        local pending=U.pending
        spawnTask(function()
            local ok,result=pcall(U.teleport.TeleportWorlds,target)
            if not isRunning() or U.pending~=pending then return end
            pending.invoking=false
            if not ok or result==false then
                U.pending=nil REQUEST_STATUS.worldTravelBusy=false U.nextAt=os.clock()+60
                U.note("World travel call failed: "..tostring(result))
            end
            -- nil is expected for this transition API; it is not proof of arrival.
        end)
    end
    onCleanup(function() U.pending=nil REQUEST_STATUS.worldTravelBusy=false end)
    return U
end)()
guardedSpawn("best-world",function()
    while isRunning() do
        local ok,err=pcall(BestWorld.tick)
        if not ok then BestWorld.nextAt=os.clock()+30 BestWorld.note("Waiting after error: "..tostring(err)) end
        task.wait(1)
    end
end)

end)

-- Smart Pet Assignment V1.4: internal diagnostics; assignment behavior retained.
-- Does not interfere with existing valid pet targets or change other workers.
guardedSpawn("smart-pet-assignment", function()
    local S={attempts=0,accepted=0,errors=0,active=0,invalid=0,refreshes=0,paused=0,
        missingTarget=0,staleTarget=0,heldPet=0,foreignPet=0,rateLimited=0,petCooldown=0,
        noChoice=0,occupancyFull=0,recheckActive=0,duplicateTarget=0,
        workerRuns=0,workerMs=0,workerMaxMs=0,refreshMs=0,refreshRuns=0,
        activeRechecks=0,activeTransitions=0,lastPetTargets={},workerIntervals=0,workerIntervalMs=0,lastWorkerAt=nil,
        workerSamples={},workerSampleLimit=256,
        selectionMs=0,selectionRuns=0,assignmentMs=0,assignmentRuns=0,
        lastLog=0,zone=nil,character=nil,controlled={},cooldowns={},lastAssign=-math.huge,
        lastRefresh=-math.huge,valid={},choices={}}
    local function note(message)
        print("[AERO SMART V1.3] "..message)
    end
    local function stats()
        note(string.format("Enabled=%s | cohort=%d | attempts=%d | accepted=%d | errors=%d | active-skips=%d | invalid-samples=%d | scans=%d | paused=%d",
            tostring(Flags.SmartPets),#S.controlled,S.attempts,S.accepted,S.errors,S.active,S.invalid,S.refreshes,S.paused))
    end
    local function detail()
        local average=S.workerRuns>0 and S.workerMs/S.workerRuns or 0
        note(string.format("V1.4 DETAIL | no-target=%d stale-target=%d held=%d foreign=%d rate-limit=%d pet-cooldown=%d no-choice=%d occupancy-full=%d recheck-active=%d duplicate-target=%d",
            S.missingTarget,S.staleTarget,S.heldPet,S.foreignPet,S.rateLimited,S.petCooldown,S.noChoice,S.occupancyFull,S.recheckActive,S.duplicateTarget))
        note(string.format("V1.4 TIMING | worker avg=%.3fms max=%.3fms runs=%d | refresh avg=%.3fms runs=%d | selection avg=%.3fms runs=%d | assignment avg=%.3fms runs=%d",
            average,S.workerMaxMs,S.workerRuns,S.refreshRuns>0 and S.refreshMs/S.refreshRuns or 0,S.refreshRuns,
            S.selectionRuns>0 and S.selectionMs/S.selectionRuns or 0,S.selectionRuns,
            S.assignmentRuns>0 and S.assignmentMs/S.assignmentRuns or 0,S.assignmentRuns))
    end
    -- P21.2: bounded timing distribution and observational recheck metrics.
    -- No changes to assignment selection, rate limits, or pet targeting.
    local function timingPercentile(p)
        if #S.workerSamples==0 then return 0 end
        local sorted={}
        for i,v in ipairs(S.workerSamples) do sorted[i]=v end
        table.sort(sorted)
        return sorted[math.max(1,math.min(#sorted,math.ceil(#sorted*p)))]
    end
    local function detailV142()
        note(string.format("V1.4.2 RECHECK | active-rechecks=%d target-transitions=%d monitored-pets=%d | cycle-interval avg=%.1fms samples=%d",
            S.activeRechecks,S.activeTransitions,#S.controlled,
            S.workerIntervals>0 and S.workerIntervalMs/S.workerIntervals or 0,S.workerIntervals))
        note(string.format("V1.4.2 DISTRIBUTION | worker p50=%.3fms p90=%.3fms p95=%.3fms p99=%.3fms | retained=%d/%d",
            timingPercentile(0.50),timingPercentile(0.90),timingPercentile(0.95),timingPercentile(0.99),
            #S.workerSamples,S.workerSampleLimit))
        note("V1.4.2 NOTE | cycle interval includes scheduling/wait; rechecks count repeated valid-target reads, not necessarily wasted work")
    end
    local function snapshot()
        local copy={}
        for k,v in pairs(S) do if type(v)=="number" then copy[k]=v end end
        copy.cohort=#S.controlled
        return copy
    end
    -- Phase 21.1: uniquely named entry point to detect stale scripts or globals.
    -- Keep the legacy entry point for existing GUI and benchmark integrations.
    local function reportV141()
        note("V1.4.2 REPORT | build=P21.2 | enabled="..tostring(Flags.SmartPets))
        stats()
        detail()
        detailV142()
        return snapshot()
    end
    _G.AERO_PS99_SmartPetStats=reportV141
    _G.AERO_PS99_SmartPetDiagnostics=snapshot
    _G.AERO_PS99_P211_Report=reportV141
    _G.AERO_PS99_P212_Report=reportV141
    local environmentOK,environment=pcall(function() return getgenv and getgenv() end)
    if environmentOK and type(environment)=="table" then
        environment.AERO_PS99_P211_Report=reportV141
        environment.AERO_PS99_P212_Report=reportV141
    end
    note("V1.4.2 READY | build=P21.2 | report=_G.AERO_PS99_P212_Report")
    onCleanup(function()
        Flags.SmartPets=false
        S.controlled={} S.cooldowns={} S.valid={} S.choices={}
        if _G.AERO_PS99_SmartPetStats==reportV141 then _G.AERO_PS99_SmartPetStats=nil end
        if _G.AERO_PS99_P211_Report==reportV141 then _G.AERO_PS99_P211_Report=nil end
        if _G.AERO_PS99_P212_Report==reportV141 then _G.AERO_PS99_P212_Report=nil end
        if environmentOK and type(environment)=="table" and environment.AERO_PS99_P211_Report==reportV141 then
            environment.AERO_PS99_P211_Report=nil
        end
        if environmentOK and type(environment)=="table" and environment.AERO_PS99_P212_Report==reportV141 then
            environment.AERO_PS99_P212_Report=nil
        end
        if _G.AERO_PS99_SmartPetDiagnostics==snapshot then _G.AERO_PS99_SmartPetDiagnostics=nil end
    end)
    local module, map, frontend
    local function safe(fn,default)
        local ok,result=pcall(fn)
        if ok then return result end
        return default
    end
    local function target(pet)
        return safe(function() return pet:GetTarget() end,nil)
    end
    local function reset()
        S.zone=nil S.character=nil S.requestedCount=nil S.controlled={} S.cooldowns={}
        S.valid={} S.choices={} S.lastPetTargets={} S.lastRefresh=-math.huge S.lastAssign=-math.huge
    end
    local function ready()
        if not isRunning() or not Flags.SmartPets then return false end
        if Flags.AutoHatch or REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.areaTravelBusy
            or REQUEST_STATUS.farmMoveBusy then return false end
        local character=LocalPlayer.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health<=0 then return false end
        if not safe(function() return map.IsInDottedBox() end,false) then return false end
        local zone=safe(function() return map.GetCurrentZone() end,nil)
        if not zone then return false end
        return true,character,root,zone
    end
    local function selectPets(character,zone)
        local t0=os.clock()
        local list={}
        for _,pet in pairs(safe(function() return module.GetByPlayer(LocalPlayer) end,{}) or {}) do
            if pet and safe(function() return pet:BelongsToLocalPlayer() end,false) and not pet.AIHold then
                list[#list+1]=pet
            end
        end
        table.sort(list,function(a,b) return tostring(a.euid)<tostring(b.euid) end)
        S.controlled={}
        local limit=math.clamp(math.floor(tonumber(State.SmartPetCount) or 5),1,20)
        for i=1,math.min(limit,#list) do S.controlled[i]=list[i] end
        S.character=character S.zone=zone S.requestedCount=limit S.cooldowns={} S.lastPetTargets={}
        S.lastRefresh=-math.huge
        S.selectionRuns+=1 S.selectionMs+=(os.clock()-t0)*1000
        note("Cohort ready: "..#S.controlled.." pets | zone="..tostring(zone))
    end
    local function refresh(root,zone)
        local t0=os.clock()
        local valid,choices={},{}
        local breakZone=safe(function() return map.GetCurrentBreakZonePart() end,nil)
        local records=safe(function() return frontend.AllByZoneAndClass(zone,"Normal") end,{})
        for _,record in pairs(records or {}) do
            if type(record)=="table" and typeof(record.model)=="Instance" and record.model.Parent
                and record.parentID==zone and not record.disableDamage then
                local model=record.model
                valid[model]=true
                if not (record.dir and record.dir.NoTapping) then
                    local position=safe(function() return model:GetPivot().Position end,nil)
                    if position then
                        local distance=(position-root.Position).Magnitude
                        local allowed=distance<=100
                        if allowed and breakZone then
                            allowed=safe(function() return map.IsPositionInBreakZone(breakZone,position) end,false)
                        end
                        if allowed then choices[#choices+1]={model=model,distance=distance} end
                    end
                end
            end
        end
        S.valid=valid S.choices=choices S.lastRefresh=os.clock() S.refreshes+=1
        S.refreshRuns+=1 S.refreshMs+=(os.clock()-t0)*1000
    end
    local wasEnabled=false
    while isRunning() do
        if not Flags.SmartPets then
            if wasEnabled then note("Disabled") reset() end
            wasEnabled=false
            task.wait(0.5)
        else
            local runStart=os.clock()
            if S.lastWorkerAt then
                S.workerIntervals+=1
                S.workerIntervalMs+=(runStart-S.lastWorkerAt)*1000
            end
            S.lastWorkerAt=runStart
            local ok,err=pcall(function()
                if not module then
                    local client=RS:WaitForChild("Library"):WaitForChild("Client")
                    module=require(client.PlayerPet)
                    map=require(client.MapCmds)
                    frontend=require(client.BreakableFrontend)
                end
                local allowed,character,root,zone=ready()
                if not allowed then
                    S.paused+=1
                    reset()
                    return
                end
                if not wasEnabled or S.character~=character or S.zone~=zone
                    or S.requestedCount~=math.clamp(math.floor(tonumber(State.SmartPetCount) or 5),1,20) then
                    selectPets(character,zone)
                end
                wasEnabled=true
                local now=os.clock()
                if now-S.lastRefresh>=1.5 then refresh(root,zone) end
                local counts={}
                -- Only five-to-twenty controlled pets are read on ordinary ticks.
                -- Full occupancy is intentionally not claimed; this is a lightweight estimate.
                for _,pet in ipairs(S.controlled) do
                    local current=target(pet)
                    if current and S.valid[current] then counts[current]=(counts[current] or 0)+1 end
                end
                for _,pet in ipairs(S.controlled) do
                    if not isRunning() or not Flags.SmartPets then break end
                    if pet.AIHold then S.heldPet+=1 continue end
                    if not safe(function() return pet:BelongsToLocalPlayer() end,false) then S.foreignPet+=1 continue end
                    local current=target(pet)
                    if current and S.valid[current] then
                        S.active+=1
                        S.activeRechecks+=1
                        if S.lastPetTargets[pet]~=nil and S.lastPetTargets[pet]~=current then S.activeTransitions+=1 end
                        S.lastPetTargets[pet]=current
                    else
                        S.invalid+=1
                        if current==nil then S.missingTarget+=1 else S.staleTarget+=1 end
                        now=os.clock()
                        if now-S.lastAssign<0.75 then S.rateLimited+=1
                        elseif now-(S.cooldowns[pet] or -math.huge)<4 then S.petCooldown+=1
                        else
                            local best,bestScore=nil,math.huge
                            local hadCandidate=false
                            for _,entry in ipairs(S.choices) do
                                if entry.model.Parent then
                                    hadCandidate=true
                                    local occupancy=counts[entry.model] or 0
                                    if occupancy<6 then
                                        local score=occupancy*25+entry.distance
                                        if score<bestScore then bestScore=score best=entry end
                                    end
                                end
                            end
                            if not best then
                                if hadCandidate then S.occupancyFull+=1 else S.noChoice+=1 end
                            end
                            local liveTarget=best and target(pet) or nil
                            if best and liveTarget and S.valid[liveTarget] then S.recheckActive+=1 end
                            if best and ready() and S.zone==zone and S.character==character
                                and not (liveTarget and S.valid[liveTarget]) then
                                if liveTarget==best.model then S.duplicateTarget+=1 end
                                S.attempts+=1
                                local assignStart=os.clock()
                                local assigned=pcall(function() pet:SetTarget(best.model) end)
                                S.assignmentRuns+=1 S.assignmentMs+=(os.clock()-assignStart)*1000
                                S.lastAssign=os.clock() S.cooldowns[pet]=S.lastAssign
                                if assigned and target(pet)==best.model then
                                    S.accepted+=1
                                    counts[best.model]=(counts[best.model] or 0)+1
                                else S.errors+=1 end
                            end
                        end
                    end
                end
                if now-S.lastLog>=30 then S.lastLog=now stats() detail() detailV142() end
            end)
            local elapsed=(os.clock()-runStart)*1000
            S.workerRuns+=1 S.workerMs+=elapsed
            if #S.workerSamples>=S.workerSampleLimit then table.remove(S.workerSamples,1) end
            S.workerSamples[#S.workerSamples+1]=elapsed
            if elapsed>S.workerMaxMs then S.workerMaxMs=elapsed end
            if not ok then
                S.errors+=1
                note("Worker error: "..tostring(err))
                task.wait(2)
            else task.wait(0.5) end
        end
    end
end)

spawnTask(function()
-- One native tap worker serves Fast Tap Farm and the existing tap controls.
local AutoTap=(function()
    local A={last=nil,nextLog=0,nextAt=0,scanAt=0,urgentAt=0,powerAt=0,rate=8,candidates={},zone=nil,character=nil,target=nil,fast=false,sent=0,reportAt=0}
    function A.note(message)
        local now=os.clock()
        if A.last~=message and now>=A.nextLog then
            A.last=message A.nextLog=now+5 print("[AERO TAP] "..message)
        end
    end
    function A.enabled()
        return isRunning() and (Flags.FastFarm or Flags.NativeAutoTap or Flags.Breakables or Flags.Tap)
    end
    function A.clear()
        A.candidates={} A.target=nil A.observedTarget=nil A.zone=nil A.character=nil A.scanAt=0
    end
    function A.valid(record,root,zone)
        if type(record)~="table" or record.uid==nil or record.parentID~=zone then return end
        local model=record.model
        if not model or not model.Parent then return end
        local ok,position=pcall(function()return model:GetPivot().Position end)
        if not ok then return end
        local distance=(position-root.Position).Magnitude
        if distance>220 then return end
        local reason=A.policy.rejectionReason({
            exists=true,parentIsZone=true,parentId=record.parentID,
            noTapping=record.dir and record.dir.NoTapping==true,
            disableDamage=record.disableDamage==true,
            manualDamage=model:GetAttribute("ManualDamage")==true,
            canMine=true, -- Same native policy inputs as the working baseline; additional rules stay server-authoritative.
            owner=record.modifier and record.modifier.Owner,distance=distance,
        },{currentZone=zone,localPlayerName=LocalPlayer.Name,maxDistance=220,forAutoTap=true})
        if reason~=nil then return end
        return distance
    end
    function A.scan(root,zone,now)
        A.scanAt=now+(Flags.FastFarm and 0.25 or 0.5)
        A.candidates={}
        for _,record in pairs(A.frontend.AllByZoneAndClass(zone,"Normal") or {}) do
            local distance=A.valid(record,root,zone)
            if distance then A.candidates[#A.candidates+1]={record=record,distance=distance} end
        end
        table.sort(A.candidates,function(a,b)return a.distance<b.distance end)
        local row=REQUEST_STATUS.observe("tap","scans","Eligible targets="..#A.candidates.."; damage progress unmeasured")
        row.targets=#A.candidates
    end
    function A.pick(root,zone)
        -- Smart targeting keeps a valid target instead of spreading taps across objects.
        if Flags.FastFarm and A.target and A.valid(A.target,root,zone) then return A.target end
        for _,entry in ipairs(A.candidates) do
            if A.valid(entry.record,root,zone) then return entry.record end
        end
    end
    function A.tick()
        if not A.enabled() then A.clear() A.last=nil A.nextAt=0 A.sent=0 A.reportAt=0 return end
        local now=os.clock()
        if now<A.nextAt then return end
        if Flags.AutoHatch or REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.areaTravelBusy or REQUEST_STATUS.farmMoveBusy then
            A.clear() A.nextAt=now+0.25 A.note("Paused during hatching or travel") return
        end
        local character=LocalPlayer.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local hum=character and character:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health<=0 then A.clear() A.nextAt=now+0.25 return end
        local client=RS.Library.Client
        A.map=A.map or require(client.MapCmds)
        A.frontend=A.frontend or require(client.BreakableFrontend)
        A.network=A.network or require(client.Network)
        A.policy=A.policy or require(RS.Library.Util.TapTargetPolicy)
        A.instancing=A.instancing or require(client.InstancingCmds)
        if A.instancing.IsInInstance() or A.map.GetCurrentInstanceInfo()~=nil then
            A.clear() A.nextAt=now+0.5 A.note("Paused: instance tapping rules not verified") return
        end
        if not A.map.IsInDottedBox() or not A.map.GetCurrentBreakZonePart() then
            A.clear() A.nextAt=now+0.25 A.note("Waiting inside farming zone") return
        end
        local zone=A.map.GetCurrentZone()
        if type(zone)~="string" then A.clear() A.nextAt=now+0.25 return end
        if A.character~=character or A.zone~=zone or A.fast~=(Flags.FastFarm==true) then
            A.clear() A.character=character A.zone=zone A.fast=Flags.FastFarm==true A.powerAt=0 A.sent=0 A.reportAt=now+10
        end
        if Flags.FastFarm then
            if now>=A.powerAt then
                A.powerAt=now+2
                local good,power=pcall(function()
                    A.enchants=A.enchants or require(client.EnchantCmds)
                    return A.enchants.GetPower("Swift Taps")
                end)
                if good and type(power)=="number" and power==power and power>0 and power<math.huge then
                    A.rate=math.min(8*(1+power/100),16)
                else A.rate=8 end
            end
        else A.rate=8 end
        if Flags.FastFarm and _G.__AERO_PS99_FAST_BENCH_BRIDGE
            and _G.__AERO_PS99_FAST_BENCH_BRIDGE:IsAlive()
            and _G.__AERO_PS99_FAST_BENCH_BRIDGE.rateOverride then
            A.rate = _G.__AERO_PS99_FAST_BENCH_BRIDGE.rateOverride
        end
        if A.observedTarget and A.observedTarget.parentID==zone and not A.observedTarget.model.Parent then
            REQUEST_STATUS.observe("tap","targetRemoved","A submitted target model left the hierarchy; cause and rewards unverified")
            A.observedTarget=nil
        end
        local scanned=false
        if now>=A.scanAt then A.scan(root,zone,now) scanned=true end
        local target=A.pick(root,zone)
        -- Destroyed/disabled targets can trigger one early refresh, at most ten per second.
        if not target and not scanned and now>=A.urgentAt and now<A.scanAt then
            A.urgentAt=now+0.1 A.scan(root,zone,now) target=A.pick(root,zone)
        end
        A.target=target
        if not target then A.nextAt=now+0.1 A.note("No nearby eligible Normal breakable") return end
        -- No catch-up bursts after lag, UI stalls or module loads.
        if not A.enabled() or LocalPlayer.Character~=character or A.map.GetCurrentZone()~=zone or
            Flags.AutoHatch or REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.areaTravelBusy or not A.valid(target,root,zone) then return end
        A.nextAt=os.clock()+1/A.rate
        REQUEST_STATUS.observe("tap","requests","Submitting target="..tostring(target.uid).."; damage acceptance unmeasured")
        A.network.UnreliableFire("Breakables_PlayerDealDamage",target.uid)
        REQUEST_STATUS.observe("tap","submitted")
        A.observedTarget=target
        A.sent+=1
        if Flags.FastFarm and now>=A.reportAt then
            A.reportAt=now+10
            print(string.format("[AERO FAST TAP] Max/Smart | Client limit %.1f taps/s | Submitted last window: %d | Target: %s | Damage acceptance not measured",A.rate,A.sent,tostring(target.uid)))
            A.sent=0
        end
    end
    onCleanup(function() A.clear() end)
    return A
end)()
guardedSpawn("native-auto-tap",function()
    while isRunning() do
        local ok,err=pcall(AutoTap.tick)
        if not ok then REQUEST_STATUS.observe("tap","errors",err) AutoTap.clear() AutoTap.note("Paused after error: "..tostring(err)) AutoTap.nextAt=os.clock()+5 end
        task.wait(AutoTap.enabled() and 0.01 or 0.25)
    end
end)
end)

-- P24.4: The prior detached console popup was removed. The user's original
-- ZHub console is embedded in the Console tab above (one LogService listener).

spawnTask(function()
-- Unified native-manager collection. Native local visuals are left to the game.
local Collector=(function()
    local C={owner=nil,scanAt=0,nextAt=0,logAt=0,errors=0,calls=0,ids=0,last=nil,snapshot=nil}
    local env=getgenv()
    local sessionKey=tostring(game.PlaceId)..":"..tostring(game.JobId)
    local sessions=env.__AERO_PS99_COLLECTED_IDS_54
    if type(sessions)~="table" then sessions={} env.__AERO_PS99_COLLECTED_IDS_54=sessions end
    local session=sessions[sessionKey]
    if type(session)~="table" or type(session.seen)~="table" then session={seen={},count=0} sessions[sessionKey]=session end
    C.cursors=setmetatable({},{__mode="k"})
    function C.enabled() return isRunning() and (Flags.Collect or Flags.CollectLootbags) end
    function C.note(message)
        if C.last~=message then C.last=message print("[AERO COLLECT] "..message) end
    end
    function C.manager()
        if C.owner then
            local values=debug.getupvalues(C.owner)
            if type(values)=="table" and type(values[8])=="table" then return values[8] end
            C.owner=nil
        end
        if os.clock()<C.scanAt then return end C.scanAt=os.clock()+30
        if type(getgc)~="function" or not debug or type(debug.getinfo)~="function" or type(debug.getupvalues)~="function" then
            C.note("Executor inspection unavailable") return
        end
        local scanned=0
        for _,fn in pairs(getgc(true)) do
            if not C.enabled() then return end
            if type(fn)=="function" then
                local ok,info=pcall(debug.getinfo,fn)
                if ok and type(info)=="table" and info.name=="ProcessCreate" and tostring(info.source):gsub("^=","")=="ReplicatedStorage.Library.Client.OrbCmds" then
                    local good,values=pcall(debug.getupvalues,fn)
                    if good and type(values)=="table" and type(values[8])=="table" then
                        C.owner=fn C.note("Native manager ready | loaded rewards in current world") return values[8]
                    end
                end
            end
            scanned+=1 if scanned%2000==0 then task.wait() end
        end
        C.note("Waiting for native manager; retry in 30 seconds")
    end
    function C.observe()
        local ok,data=pcall(C.save.Get)
        if not ok or type(data)~="table" or type(data.Inventory)~="table" or type(data.Inventory.Currency)~="table" then return end
        local result={currency={},inventory={}}
        for _,r in pairs(data.Inventory.Currency) do
            if type(r)=="table" and type(r.id)=="string" and type(r._am)=="number" then
                result.currency[r.id]=(result.currency[r.id] or 0)+r._am
            end
        end
        for category,records in pairs(data.Inventory) do
            if category~="Currency" and type(records)=="table" then
                local total=0
                for _,r in pairs(records) do if type(r)=="table" and r.id then total+=tonumber(r._am) or 1 end end
                result.inventory[category]=total
            end
        end
        return result
    end
    function C.report()
        local current=C.observe()
        if current and C.snapshot then
            for _,kind in ipairs({"currency","inventory"}) do
                local all={}
                for id in pairs(current[kind]) do all[id]=true end
                for id in pairs(C.snapshot[kind]) do all[id]=true end
                local printed=0
                for id in pairs(all) do
                    local delta=(current[kind][id] or 0)-(C.snapshot[kind][id] or 0)
                    if delta~=0 and printed<12 then
                        printed+=1 print("[AERO COLLECT] Observed "..kind.." change | "..tostring(id).." | "..tostring(delta).." | attribution not verified")
                    end
                end
            end
        end
        if current then C.snapshot=current end
        print(string.format("[AERO COLLECT] Submitted IDs: %d | Calls: %d | Errors: %d | Session attempted IDs: %d | Credit not counted per ID",C.ids,C.calls,C.errors,session.count))
    end
    function C.tick()
        if not C.enabled() then C.snapshot=nil C.last=nil return end
        local now=os.clock()
        if now<C.nextAt then return end
        C.nextAt=now+math.max(1,tonumber(State.CollectDelay) or 1)
        local client=RS.Library.Client
        C.network=C.network or require(client.Network)
        C.save=C.save or require(client.Save)
        C.map=C.map or require(client.MapCmds)
        C.instances=C.instances or require(client.InstancingCmds)
        C.directory=C.directory or require(RS.Library.Directory)
        C.parentTypes=C.parentTypes or require(RS.Library.Types.Breakables).ParentType
        if Flags.AutoHatch or REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.areaTravelBusy or C.instances.IsInInstance() then return end
        local character=LocalPlayer.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health<=0 then return end
        local zone=C.map.GetCurrentZone()
        local zoneData=C.directory.Zones[zone]
        if not zoneData or not zoneData.WorldNumber then C.note("Waiting for current world metadata") return end
        if C.world~=zoneData.WorldNumber then C.world=zoneData.WorldNumber C.snapshot=nil end
        if session.count>=100000 then C.note("Paused: session ID memory limit reached") return end
        local manager=C.manager()
        if not manager or not C.enabled() then return end
        -- Discovery may yield: verify context again before constructing a batch.
        if LocalPlayer.Character~=character or humanoid.Health<=0 or C.map.GetCurrentZone()~=zone or C.instances.IsInInstance() or Flags.AutoHatch or REQUEST_STATUS.worldTravelBusy or REQUEST_STATUS.areaTravelBusy then return end
        if not C.snapshot then C.snapshot=C.observe() end
        local batch,queued,updates={},{},{}
        local serverNow=Workspace:GetServerTimeNow()
        local function add(id,kind)
            if type(id)=="number" and id==id and id>0 and id%1==0 and not session.seen[id] and not queued[id] and #batch<20 then
                queued[id]=kind batch[#batch+1]=id
            end
        end
        for _,record in pairs(manager) do
            if #batch>=20 then break end
            if type(record)=="table" and not record._destroyed and not record._collected and record._parentType==C.parentTypes.Zone and
                ((record._typeNumber==1 and Flags.Collect) or (record._typeNumber==2 and Flags.CollectLootbags)) and
                type(record._timestamp)=="number" and type(record._pickupDelay)=="number" and serverNow-record._timestamp>=record._pickupDelay then
                local parent=C.directory.Zones[record._parentId]
                if parent and parent.WorldNumber==C.world then
                    local kind=record._typeNumber
                    add(record._id,kind)
                    local combined=record._combinedIds
                    local cursor=C.cursors[record] or 1
                    if type(combined)=="table" then
                        -- Progress through large combined records over several batches.
                        if cursor>#combined+1 then cursor=1 end
                        while cursor<=#combined and #batch<20 do
                            add(combined[cursor],kind) cursor+=1
                        end
                    end
                    updates[#updates+1]={record,cursor}
                end
            end
        end
        if #batch>0 then
            if not C.enabled() then return end
            -- Mark attempted first: a thrown fire call may already have transmitted.
            -- Do not automatically replay uncertain requests.
            for _,id in ipairs(batch) do session.seen[id]=true session.count+=1 end
            for _,update in ipairs(updates) do C.cursors[update[1]]=update[2] end
            local ok,err=pcall(C.network.Fire,"Orbs: Collect",batch)
            if not ok then C.errors+=1 C.nextAt=os.clock()+15 C.note("Request error; paused 15 seconds: "..tostring(err)) return end
            C.calls+=1 C.ids+=#batch
            for _,id in ipairs(batch) do if queued[id]==1 then Stats.Orbs+=1 else Stats.Bags+=1 end end
        end
        if now>=C.logAt then C.logAt=now+10 C.report() end
    end
    onCleanup(function() C.owner=nil C.snapshot=nil C.cursors={} end)
    return C
end)()
-- P24.4: rank rewards. Client source confirms Ranks_ClaimReward(index) is a
-- RemoteEvent; eligibility is cumulative StarsRequired and redeemed string keys.
-- Submit one at a time, then require a save-state acknowledgement before proceeding.
local RankClaimStatus={requests=0,verified=0,unconfirmed=0,status="Off",pending=nil,nextAt=0}
REQUEST_STATUS.rankClaims=RankClaimStatus
local RankClaim=(function()
    local R={}
    function R.context()
        local lib=RS:FindFirstChild("Library")
        if not lib then return nil,"Library missing" end
        local ok,save,dir,util,flags,inst,network=pcall(function()
            return require(lib.Client.Save),require(lib.Directory),require(lib.Util.RanksUtil),
                require(lib.Client.FFlags),require(lib.Client.InstancingCmds),require(lib.Client.Network)
        end)
        if not ok then return nil,"Rank modules unavailable: "..tostring(save) end
        if type(save.Get)~="function" or type(util.RankIDFromNumber)~="function" then return nil,"Rank interfaces missing" end
        return {save=save,dir=dir,util=util,flags=flags,inst=inst,network=network}
    end
    function R.tick()
        local S=RankClaimStatus
        if not Flags.AutoClaimRank then S.status="Off" S.pending=nil return end
        local now=os.clock()
        if now<S.nextAt then return end
        local c,err=R.context()
        if not c then S.status=err S.nextAt=now+15 return end
        if c.inst.IsInInstance() then S.status="Paused inside instance" S.nextAt=now+10 return end
        local ok,data=pcall(c.save.Get)
        if not ok or type(data)~="table" then S.status="Waiting for rank save" S.nextAt=now+10 return end
        local rank=tonumber(data.Rank)
        local stars=tonumber(data.RankStars)
        local redeemed=data.RedeemedRankRewards
        if not rank or not stars or type(redeemed)~="table" then S.status="Incomplete rank save" S.nextAt=now+10 return end
        if S.pending then
            local pending=S.pending
            if rank~=pending.rank or redeemed[tostring(pending.index)]~=nil then
                S.verified+=1 S.status="Verified claim #"..pending.index S.pending=nil S.nextAt=now+2
            elseif now>=pending.deadline then
                S.unconfirmed+=1 S.status="Claim #"..pending.index.." unconfirmed; stopped to prevent duplicates"
                S.pending=nil Flags.AutoClaimRank=false S.nextAt=now+60
            else S.status="Waiting for claim #"..pending.index.." acknowledgement" end
            return
        end
        local allowed=false
        local okFlag=pcall(function() allowed=c.flags.Get(c.flags.Keys.RankRewards)==true or c.flags.CanBypass()==true end)
        if not okFlag or not allowed then S.status="RankRewards feature flag unavailable/disabled" S.nextAt=now+15 return end
        local rankId=c.util.RankIDFromNumber(rank)
        local entry=rankId and c.dir.Ranks[rankId]
        if type(entry)~="table" or type(entry.Rewards)~="table" then S.status="Rank reward directory missing" S.nextAt=now+15 return end
        local cumulative=0
        local chosen=nil
        for i,reward in ipairs(entry.Rewards) do
            local required=tonumber(reward.StarsRequired)
            if not required or required<0 then S.status="Invalid reward requirement" S.nextAt=now+30 return end
            cumulative+=required
            if not chosen and cumulative<=stars and redeemed[tostring(i)]==nil then chosen=i end
        end
        if not chosen then S.status="No claimable rank rewards" S.nextAt=now+10 return end
        if not isRunning() or not Flags.AutoClaimRank then return end
        -- Fire is asynchronous; the remote return is not evidence of redemption.
        S.requests+=1 S.nextAt=now+2
        local sent,sendErr=pcall(c.network.Fire,"Ranks_ClaimReward",chosen)
        if sent then
            S.pending={rank=rank,index=chosen,deadline=os.clock()+12}
            S.status="Submitted claim #"..chosen.."; awaiting save verification"
        else
            S.status="Claim request failed: "..tostring(sendErr):sub(1,130)
            S.nextAt=os.clock()+30
        end
    end
    return R
end)()
-- Free-only Forever Pack worker. Never call ForeverPackCmds.Claim: its paid branch prompts purchases.
REQUEST_STATUS.foreverClaims=(function()
    local F={requests=0,verified=0,unconfirmed=0,status="Off",nextAt=0,pack="Default"}
    function F.tick()
        local now=os.clock()
        if not Flags.AutoClaimForever and not F.pending then F.status="Off" return end
        if now<F.nextAt then return end
        local lib=RS:FindFirstChild("Library")
        local ok,cmds,network=pcall(function()
            return require(lib.Client.ForeverPackCmds),require(lib.Client.Network)
        end)
        if not ok or type(cmds.GetState)~="function" then
            F.status="Forever Pack modules unavailable" F.nextAt=now+15 return
        end
        local read,state=pcall(cmds.GetState,F.pack)
        if F.pending then
            local p=F.pending
            if read and type(state)=="table" and state.VersionNumber==p.version and tonumber(state.Slot) and state.Slot>p.slot then
                F.verified=F.verified+1 F.pending=nil F.status="Verified free slot "..(p.slot+1) F.nextAt=now+2
            elseif now>=p.deadline then
                F.unconfirmed=F.unconfirmed+1 F.pending=nil Flags.AutoClaimForever=false
                F.status="Claim unconfirmed; stopped to prevent duplicates" F.nextAt=now+30
            else F.status="Waiting for free claim acknowledgement" end
            return
        end
        if not read or type(state)~="table" or type(state.Slots)~="table" or type(state.Slot)~="number" then
            F.status="Waiting for active Forever Pack state" F.nextAt=now+10 return
        end
        local slot=state.Slots[state.Slot+1]
        if type(slot)~="table" then F.status="No next slot available" F.nextAt=now+10 return end
        if slot.Free~=true and slot.Price~=nil then F.status="Waiting at paid slot; free-only mode" F.nextAt=now+10 return end
        if not isRunning() or not Flags.AutoClaimForever then return end
        F.pending={slot=state.Slot,version=state.VersionNumber,deadline=now+15}
        F.requests=F.requests+1 F.status="Submitting free slot "..(state.Slot+1)
        local sent,result=pcall(network.Invoke,"ForeverPacks: Claim Free",F.pack)
        F.lastResponse=sent and tostring(result) or "Request error"
        -- A return value alone cannot prove the gift arrived. Reconcile even after errors.
        F.nextAt=os.clock()+2
    end
    return F
end)()
guardedSpawn("forever-free-rewards",function()
    while isRunning() do
        local ok,err=pcall(REQUEST_STATUS.foreverClaims.tick)
        if not ok then
            local f=REQUEST_STATUS.foreverClaims
            f.status="Forever Pack error: "..tostring(err):sub(1,130) f.nextAt=os.clock()+5
        end
        task.wait(1)
    end
end)
guardedSpawn("rank-rewards",function()
    while isRunning() do
        local ok,err=pcall(RankClaim.tick)
        if not ok then RankClaimStatus.status="Rank claim error: "..tostring(err):sub(1,160) RankClaimStatus.nextAt=os.clock()+20 end
        task.wait(1)
    end
end)
guardedSpawn("unified-reward-collection",function()
    while isRunning() do
        local ok,err=pcall(Collector.tick)
        if not ok then Collector.nextAt=os.clock()+15 Collector.note("Waiting after error: "..tostring(err)) end
        task.wait(0.25)
    end
end)
end)

]========]
local compileOK,loaded,compileError=pcall(function()
    if type(loadstring)~="function" then return nil,"Delta loadstring is unavailable" end
    return loadstring(source)
end)
if not compileOK or type(loaded)~="function" then
    fail("Source compilation failed: "..tostring(compileError or loaded))
else
    setStatus("Starting PS99 engine...")
    task.spawn(function()
        local ok,err=xpcall(loaded,errorTrace)
        if not ok then
            fail("Runtime startup error: "..tostring(err))
        elseif bootReady and not bootFailed then
            setStatus("Startup complete")
            if bootGui then pcall(function() bootGui:Destroy() end) end
            bootGui,bootStatusLabel,bootErrorLabel=nil,nil,nil
            _G.AERO_PS99_BOOT_STATUS=nil
            _G.AERO_PS99_BOOT_FAIL=nil
            _G.AERO_PS99_BOOT_READY=nil
        elseif not bootFailed then
            fail("PS99 engine returned before GUI startup finished. Check game dependencies.")
        end
    end)
end
