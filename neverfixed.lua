local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TargetGuiParent = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera

local KeysURL = "https://pastebin.com/raw/sLFHFhyG"
local BuyContact = "Telegram: @nl_soufiw"
local CurrentLanguage = "RU"
local MenuCreated = false

local Translations = {
    RU = {
        title = "NEVERLOSE",
        subtitle = "Введите лицензионный ключ",
        placeholder = "Введите ключ...",
        activate = "АКТИВИРОВАТЬ",
        buy = "КУПИТЬ КЛЮЧ",
        waiting = "Ожидание ввода ключа...",
        copied = "Контакт скопирован!",
        checking = "Проверка ключа...",
        error_connect = "Ошибка подключения!",
        error_empty = "Введите ключ!",
        success = "Ключ подтвержден! Загрузка...",
        error_key = "Неверный ключ!",
        menu_title = "NEVERLOSE",
        settings = "Настройки",
        scripts = "Скрипты",
        configs = "Конфиги",
        language = "Язык",
        rejoin = "ПЕРЕЗАЙТИ",
        status = "Статус: Премиум",
        version = "Версия: 2026",
        config_create = "СОЗДАТЬ КОНФИГ",
        config_load = "ЗАГРУЗИТЬ",
        config_delete = "УДАЛИТЬ",
        script_create = "СОЗДАТЬ СКРИПТ",
        script_run = "ЗАПУСТИТЬ"
    },
    EN = {
        title = "NEVERLOSE",
        subtitle = "Enter license key",
        placeholder = "Enter key...",
        activate = "ACTIVATE",
        buy = "BUY KEY",
        waiting = "Waiting for key...",
        copied = "Contact copied!",
        checking = "Checking key...",
        error_connect = "Connection error!",
        error_empty = "Enter a key!",
        success = "Key confirmed! Loading...",
        error_key = "Invalid key!",
        menu_title = "NEVERLOSE",
        settings = "Settings",
        scripts = "Scripts",
        configs = "Configs",
        language = "Language",
        rejoin = "REJOIN",
        status = "Status: Premium",
        version = "Version: 2026",
        config_create = "CREATE CONFIG",
        config_load = "LOAD",
        config_delete = "DELETE",
        script_create = "CREATE SCRIPT",
        script_run = "RUN"
    }
}

local function T(key)
    return Translations[CurrentLanguage][key] or key
end

local Settings = {
    Enabled = false,
    SilentAim = false,
    VisibleCheck = false,
    Triggerbot = false,
    HitboxSize = 2,
    HitboxExpand = false,
    ESP = false,
    ESP_Boxes = false,
    ESP_Chams = false,
    ESP_Tracers = false,
    ESP_Names = false,
    ESP_Health = false,
    RainbowESP = false,
    ESP_ColorR = 0,
    ESP_ColorG = 110,
    ESP_ColorB = 220,
    Bhop = false,
    AutoStrafe = false,
    AntiAim = false,
    Spinbot = false,
    SpinSpeed = 60,
    YawJitter = false,
    DesyncChams = false,
    BackstabTeleport = false,
    Streamproof = false,
    GodMode = false,
    InvisKill = false,
    Noclip = false,
    PhaseWalk = false,
    NoClipCam = false,
    Fly = false,
    NoRecoil = false,
    InfAmmo = false,
    RapidFire = false,
    Wallshot = false,
    SpeedHack = false,
    SpeedValue = 16,
    JumpHack = false,
    JumpValue = 50,
    SpeedJump = false,
    GravityValue = 196,
    NoFog = false,
    Fullbright = false,
    FPSBoost = false,
    MenuDPI = 1,
    EspDPI = 1,
    FOV = 100,
    ShowFOV = true,
    AimSmoothness = 5,
    ThirdPerson = false,
    ThirdPersonDist = 10,
    BhopSpeed = 25,
    FlySpeed = 50
}

getgenv().Digla = Settings

local RainbowColor = Color3.fromRGB(0, 110, 220)
local UI_Sync_Registry = {}
local SelectedConfigName = ""
local SelectedScriptName = ""
local MenuFrame = nil
local SidebarScroll = nil
local ContentFrame = nil
local ExternalTabs = {}
local TillText = "Lifetime"

local function IsEnemy(player)
    if player == LocalPlayer then return false end
    local pt = player.Team
    local lt = LocalPlayer.Team
    if pt and lt and pt == lt then return false end
    return true
end

local function GetESPColor()
    if Settings.RainbowESP then return RainbowColor end
    return Color3.fromRGB(Settings.ESP_ColorR or 0, Settings.ESP_ColorG or 110, Settings.ESP_ColorB or 220)
end

local function IsVisible(part)
    if not Settings.VisibleCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local parts = Camera:GetPartsObscuringTarget({part.Position}, {char, part.Parent})
    return #parts == 0
end

local function GetTarget()
    local closest = nil
    local closestDist = Settings.FOV or 100
    local center = Camera.ViewportSize / 2
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local char = player.Character
            if char and char.Parent then
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and IsVisible(head) then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < closestDist then
                            closest = player
                            closestDist = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 0.3
    FOVCircle.NumSides = 60
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Filled = false
end

task.spawn(function()
    local h = 0
    while true do
        task.wait(0.03)
        h = (h + 1) % 360
        RainbowColor = Color3.fromHSV(h / 360, 0.7, 0.8)
    end
end)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        local view = not Settings.Streamproof
        if Settings.ShowFOV and view and (Settings.Enabled or Settings.SilentAim) then
            FOVCircle.Visible = true
            FOVCircle.Radius = Settings.FOV or 100
            FOVCircle.Position = Camera.ViewportSize / 2
            FOVCircle.Color = GetESPColor()
        else
            FOVCircle.Visible = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Enabled then
        local target = GetTarget()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if aimPart then
                local lookVector = (aimPart.Position - Camera.CFrame.Position).Unit
                local smooth = Settings.AimSmoothness or 5
                local smoothFactor = math.clamp(1 / smooth, 0.01, 1)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector), smoothFactor)
            end
        end
    end
end)

local PlayerMouse = LocalPlayer:GetMouse()
pcall(function()
    if hookmetamethod then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if self == PlayerMouse and (key == "Hit" or key == "Target") then
                if Settings.SilentAim or Settings.Wallshot then
                    local target = GetTarget()
                    if target and target.Character then
                        local head = target.Character:FindFirstChild("Head")
                        if head then return (key == "Hit" and head.CFrame or head) end
                    end
                end
            end
            return oldIndex(self, key)
        end)
    end
end)

local originalSizes = {}
task.spawn(function()
    while true do
        task.wait(0.5)
        for _, player in pairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    if not originalSizes[player.Name] then
                        originalSizes[player.Name] = {Size = head.Size, Trans = head.Transparency}
                    end
                    if Settings.HitboxExpand then
                        local sizeVal = Settings.HitboxSize or 2
                        head.Size = Vector3.new(sizeVal, sizeVal, sizeVal)
                        head.Transparency = 0.7
                        head.Color = GetESPColor()
                        head.CanCollide = false
                    else
                        local backup = originalSizes[player.Name] or {Size = Vector3.new(2, 1, 1), Trans = 0}
                        head.Size = backup.Size
                        head.Transparency = backup.Trans
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    originalSizes[player.Name] = nil
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if Settings.Triggerbot then
            local target = GetTarget()
            if target and target.Character then
                if PlayerMouse.Target and PlayerMouse.Target:IsDescendantOf(target.Character) then
                    if mouse1click then
                        mouse1click()
                    elseif VirtualInputManager then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                    task.wait(0.1)
                end
            end
        end
    end
end)

local flyVelocity = nil
local aaAngle = 0
local spinAngle = 0
local jitterState = false
local defaultFogEnd = Lighting.FogEnd
local defaultAmbient = Lighting.Ambient

RunService.Stepped:Connect(function()
    if Settings.Noclip or Settings.PhaseWalk then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum then
        if Settings.SpeedHack then
            hum.WalkSpeed = Settings.SpeedValue or 16
        elseif not Settings.Bhop then
            hum.WalkSpeed = 16
        end
        if Settings.JumpHack then
            hum.JumpPower = Settings.JumpValue or 50
        else
            hum.JumpPower = 50
        end
        if Settings.GodMode then hum.Health = 99999 end
    end
    workspace.Gravity = Settings.GravityValue or 196
    if Settings.NoFog then Lighting.FogEnd = 999999 else Lighting.FogEnd = defaultFogEnd end
    if Settings.Fullbright then Lighting.Ambient = Color3.fromRGB(255, 255, 255) else Lighting.Ambient = defaultAmbient end
    if Settings.Fly and hrp then
        if hum then hum.PlatformStand = true end
        if not flyVelocity then
            flyVelocity = Instance.new("BodyVelocity", hrp)
            flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        end
        local flySp = Settings.FlySpeed or 50
        flyVelocity.Velocity = Camera.CFrame.LookVector * flySp
    else
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
        if hum and hum.PlatformStand and not Settings.Fly then hum.PlatformStand = false end
    end
    if Settings.InvisKill and hrp then hrp.Velocity = Vector3.new(0, -90, 0) end
    if hrp and not Settings.Fly then
        if Settings.AntiAim then
            aaAngle = (aaAngle + 35) % 360
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(aaAngle), 0)
        elseif Settings.YawJitter then
            jitterState = not jitterState
            local offset = jitterState and 45 or -45
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(offset), 0)
        elseif Settings.Spinbot then
            local spSpeed = Settings.SpinSpeed or 60
            spinAngle = (spinAngle + spSpeed) % 360
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spSpeed), 0)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if Settings.FPSBoost then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("PostEffect") then
                    v.Enabled = false
                end
            end
            Lighting.GlobalShadows = false
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and Settings.SpeedJump and hum.FloorMaterial ~= Enum.Material.Air then
        hrp.Velocity = hrp.Velocity + (hrp.CFrame.LookVector * 65) + Vector3.new(0, 15, 0)
    end
end)

local isFreeCam = false
local freeCamSpeed = 1.5
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.NoClipCam then isFreeCam = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then isFreeCam = false end
end)

RunService.RenderStepped:Connect(function()
    if isFreeCam and Settings.NoClipCam then
        local moveVector = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
        Camera.CFrame = Camera.CFrame + (moveVector * freeCamSpeed)
    end
end)

RunService.RenderStepped:Connect(function()
    if not Settings.Bhop then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local bhSpeed = Settings.BhopSpeed or 25
    if hum.FloorMaterial ~= Enum.Material.Air then
        if hrp.Velocity.Magnitude > 1 then hum.Jump = true end
    else
        if not Settings.SpeedHack then hum.WalkSpeed = bhSpeed end
        if Settings.AutoStrafe and UserInputService:GetFocusedTextBox() == nil then
            local right = Camera.CFrame.RightVector
            local strafeForce = 1.8
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                hrp.Velocity = Vector3.new(right.X * -bhSpeed * strafeForce, hrp.Velocity.Y, right.Z * -bhSpeed * strafeForce)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
                hrp.Velocity = Vector3.new(right.X * bhSpeed * strafeForce, hrp.Velocity.Y, right.Z * bhSpeed * strafeForce)
            end
        end
    end
end)

local function TweakWeapons(tool)
    if not tool:IsA("Tool") then return end
    task.spawn(function()
        while tool.Parent == LocalPlayer.Character or tool.Parent == LocalPlayer:FindFirstChildOfClass("Backpack") do
            task.wait(0.3)
            for _, child in pairs(tool:GetDescendants()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    local name = child.Name:lower()
                    if Settings.RapidFire and (name:find("cooldown") or name:find("firerate") or name:find("delay") or name:find("rate")) then child.Value = 0.01 end
                    if Settings.NoRecoil and (name:find("recoil") or name:find("spread") or name:find("kick")) then child.Value = 0 end
                    if Settings.InfAmmo and (name:find("ammo") or name:find("clip") or name:find("stored")) then child.Value = 999 end
                end
            end
        end
    end)
end
LocalPlayer:FindFirstChildOfClass("Backpack").ChildAdded:Connect(TweakWeapons)

local function SyncUIElements()
    for key, element in pairs(UI_Sync_Registry) do
        local value = Settings[key]
        if value ~= nil then
            if element.Type == "Toggle" then
                element.Circle:TweenPosition(
                    value and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.12,
                    true
                )
                element.Bg.BackgroundColor3 = value and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(15, 17, 20)
                element.Stroke.Color = value and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(30, 34, 40)
            elseif element.Type == "Slider" then
                local min = element.Min or 0
                local max = element.Max or 100
                local pct = math.clamp((value - min) / (max - min), 0, 1)
                element.Fill.Size = UDim2.new(pct, 0, 1, 0)
                element.Label.Text = element.Text .. " (" .. tostring(value) .. ")"
            end
        end
    end
end

local function SaveConfig(name)
    if name == "" then return end
    if writefile then
        writefile("NL_Configs/" .. name .. ".cfg", HttpService:JSONEncode(Settings))
    end
end

local function LoadConfig(name)
    if name == "" then return end
    if readfile then
        local loaded = HttpService:JSONDecode(readfile("NL_Configs/" .. name .. ".cfg"))
        for k, v in pairs(loaded) do
            Settings[k] = v
        end
        SyncUIElements()
    end
end

local function GetConfigs()
    local list = {}
    if isfolder and not isfolder("NL_Configs") then
        makefolder("NL_Configs")
    end
    if listfiles then
        local files = listfiles("NL_Configs")
        for _, f in pairs(files) do
            if f:sub(-4):lower() == ".cfg" then
                local name = f:gsub("NL_Configs\\", ""):gsub("NL_Configs/", ""):gsub("%.cfg", "")
                table.insert(list, name)
            end
        end
    end
    return list
end

local ESPContainer = TargetGuiParent:FindFirstChild("NL_ESP_Hold") or Instance.new("ScreenGui", TargetGuiParent)
ESPContainer.Name = "NL_ESP_Hold"
ESPContainer.ResetOnSpawn = false

local function CreateESP(player)
    if player == LocalPlayer then return end
    if not IsEnemy(player) then return end
    local function SetupChar(char)
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local esp = Instance.new("BillboardGui", ESPContainer)
        esp.AlwaysOnTop = true
        esp.Adornee = char
        esp.Size = UDim2.new(3.5, 0, 5.8, 0)
        esp.Enabled = false
        local box = Instance.new("Frame", esp)
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        local outline = Instance.new("UIStroke", box)
        outline.Thickness = 0.6
        local nameLabel = Instance.new("TextLabel", esp)
        nameLabel.Size = UDim2.new(1, 0, 0, 12)
        nameLabel.Position = UDim2.new(0, 0, 0, -14)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 8
        nameLabel.Visible = false
        local healthBar = Instance.new("Frame", esp)
        healthBar.Size = UDim2.new(0, 2, 1, 0)
        healthBar.Position = UDim2.new(0, -6, 0, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Visible = false
        local healthFill = Instance.new("Frame", healthBar)
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        healthFill.BorderSizePixel = 0
        local chams = Instance.new("Highlight", char)
        chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        chams.Enabled = false
        local desyncHighlight = Instance.new("Highlight", char)
        desyncHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        desyncHighlight.Enabled = false
        local tracerLine = nil
        if Drawing then
            tracerLine = Drawing.new("Line")
            tracerLine.Visible = false
            tracerLine.Thickness = 1
            tracerLine.Transparency = 0.8
        end
        local distLabel = nil
        if Settings.ESP_Health then
            distLabel = Instance.new("TextLabel", esp)
            distLabel.Size = UDim2.new(1, 0, 0, 12)
            distLabel.Position = UDim2.new(0, 0, 0, 12)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = ""
            distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            distLabel.Font = Enum.Font.GothamBold
            distLabel.TextSize = 8
            distLabel.Visible = false
        end
        local lastSettings = {}
        RunService.RenderStepped:Connect(function()
            if not char.Parent or not esp.Parent then
                chams:Destroy()
                desyncHighlight:Destroy()
                if tracerLine then tracerLine:Destroy() end
                return
            end
            if not IsEnemy(player) then
                esp.Enabled = false
                chams.Enabled = false
                desyncHighlight.Enabled = false
                if tracerLine then tracerLine.Visible = false end
                return
            end
            local view = not Settings.Streamproof
            local mult = Settings.EspDPI or 1
            esp.Enabled = Settings.ESP and Settings.ESP_Boxes and view
            chams.Enabled = Settings.ESP and Settings.ESP_Chams and view
            desyncHighlight.Enabled = Settings.ESP and Settings.DesyncChams and view
            nameLabel.Visible = Settings.ESP and Settings.ESP_Names and view
            healthBar.Visible = Settings.ESP and Settings.ESP_Health and view
            if distLabel then
                distLabel.Visible = Settings.ESP and Settings.ESP_Health and view
                if view then
                    local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                    distLabel.Text = dist .. "m"
                end
            end
            esp.Size = UDim2.new(3.5 * mult, 0, 5.8 * mult, 0)
            if hum then
                local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                healthFill.Size = UDim2.new(1, 0, hpPct, 0)
            end
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if tracerLine then
                if Settings.ESP and Settings.ESP_Tracers and view and onScreen then
                    tracerLine.Visible = true
                    tracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    tracerLine.Color = GetESPColor()
                else
                    tracerLine.Visible = false
                end
            end
            if esp.Enabled or chams.Enabled then
                local c = GetESPColor()
                outline.Color = c
                chams.FillColor = c
                chams.FillTransparency = 0.6
                desyncHighlight.FillColor = Color3.fromRGB(220, 0, 220)
                desyncHighlight.FillTransparency = 0.8
            end
        end)
    end
    if player.Character then SetupChar(player.Character) end
    player.CharacterAdded:Connect(SetupChar)
end

for _, p in pairs(Players:GetPlayers()) do
    if IsEnemy(p) then
        CreateESP(p)
    end
end
Players.PlayerAdded:Connect(function(p)
    if IsEnemy(p) then
        CreateESP(p)
    end
end)

local function RemoveHeaders()
    for _, gui in pairs(TargetGuiParent:GetChildren()) do
        if gui.Name == "NeverLose_Menu_Hold" then
            local sidebar = gui:FindFirstChild("Sidebar")
            if sidebar then
                local scroll = sidebar:FindFirstChildOfClass("ScrollingFrame")
                if scroll then
                    for _, child in pairs(scroll:GetChildren()) do
                        if child:IsA("TextLabel") then
                            child:Destroy()
                        end
                    end
                end
            end
            break
        end
    end
end

local function AddExternalTab(name, code)
    if not MenuCreated then
        task.wait(1)
        if not MenuCreated then return end
    end
    if not SidebarScroll or not ContentFrame then return end
    for _, child in pairs(SidebarScroll:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find(name) then
            return
        end
    end
    local btn = Instance.new("TextButton", SidebarScroll)
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(8, 9, 11)
    btn.Text = "    " .. name
    btn.TextColor3 = Color3.fromRGB(0, 110, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local page = Instance.new("ScrollingFrame", ContentFrame)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 110, 220)
    page.Visible = false
    page.Name = name
    ExternalTabs[name] = page
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(0, 110, 220)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    local status = Instance.new("TextLabel", page)
    status.Size = UDim2.new(1, 0, 0, 40)
    status.Position = UDim2.new(0, 0, 0, 35)
    status.BackgroundTransparency = 1
    status.Text = "Скрипт загружен"
    status.TextColor3 = Color3.fromRGB(150, 155, 165)
    status.Font = Enum.Font.GothamSemibold
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Left
    local runBtn = Instance.new("TextButton", page)
    runBtn.Size = UDim2.new(1, 0, 0, 30)
    runBtn.Position = UDim2.new(0, 0, 0, 80)
    runBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    runBtn.Text = "RUN"
    runBtn.Font = Enum.Font.GothamBold
    runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    runBtn.TextSize = 12
    Instance.new("UICorner", runBtn)
    runBtn.MouseButton1Click:Connect(function()
        if code then
            local func, err = loadstring(code)
            if func then
                pcall(func)
                status.Text = "Выполнено"
                status.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                status.Text = "Ошибка: " .. tostring(err)
                status.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end)
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        page.Visible = true
    end)
end

local function CheckKeyExpiry(keyData)
    if keyData:lower() == "lifetime" then
        return true, "Lifetime"
    end
    local success, date = pcall(function()
        local year, month, day = keyData:match("(%d+)-(%d+)-(%d+)")
        return os.time({year=tonumber(year), month=tonumber(month), day=tonumber(day), hour=23, min=59, sec=59})
    end)
    if not success then return false, "Неверный формат даты" end
    local currentTime = os.time()
    if currentTime > date then
        return false, "Ключ истек " .. os.date("%d.%m.%Y", date)
    end
    local daysLeft = math.floor((date - currentTime) / 86400)
    return true, os.date("%d.%m.%Y", date) .. " (" .. daysLeft .. " дн.)"
end

local function CreateMenu()
    if MenuCreated then return end
    local MainGui = Instance.new("ScreenGui", TargetGuiParent)
    MainGui.Name = "NeverLose_Menu_Hold"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true
    local FloatButton = Instance.new("TextButton", MainGui)
    FloatButton.Size = UDim2.new(0, 42, 0, 42)
    FloatButton.Position = UDim2.new(0, 15, 0.4, 0)
    FloatButton.BackgroundColor3 = Color3.fromRGB(11, 12, 14)
    FloatButton.Text = "NL"
    FloatButton.TextColor3 = Color3.fromRGB(0, 110, 220)
    FloatButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", FloatButton).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", FloatButton).Color = Color3.fromRGB(30, 34, 40)
    MenuFrame = Instance.new("Frame", MainGui)
    MenuFrame.Size = UDim2.new(0, 480, 0, 350)
    MenuFrame.Position = UDim2.new(0.5, -240, 0.5, -175)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(11, 12, 14)
    MenuFrame.Visible = false
    Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", MenuFrame).Color = Color3.fromRGB(24, 26, 30)
    local Header = Instance.new("Frame", MenuFrame)
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.BackgroundTransparency = 1
    local Title = Instance.new("TextLabel", Header)
    Title.Text = "    NEVERLOSE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    local GearBtn = Instance.new("TextButton", Header)
    GearBtn.Size = UDim2.new(0, 26, 0, 26)
    GearBtn.Position = UDim2.new(1, -36, 0.5, -13)
    GearBtn.BackgroundTransparency = 1
    GearBtn.Text = "⚙"
    GearBtn.TextColor3 = Color3.fromRGB(150, 155, 165)
    GearBtn.TextSize = 14
    GearBtn.Font = Enum.Font.GothamBold
    local dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = MenuFrame.Position
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput then
            local delta = input.Position - dragStart
            MenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    FloatButton.MouseButton1Click:Connect(function()
        MenuFrame.Visible = not MenuFrame.Visible
    end)
    local Sidebar = Instance.new("Frame", MenuFrame)
    Sidebar.Size = UDim2.new(0, 120, 1, -36)
    Sidebar.Position = UDim2.new(0, 0, 0, 36)
    Sidebar.BackgroundColor3 = Color3.fromRGB(8, 9, 11)
    Sidebar.BorderSizePixel = 0
    SidebarScroll = Instance.new("ScrollingFrame", Sidebar)
    SidebarScroll.Size = UDim2.new(1, 0, 1, -48)
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.BorderSizePixel = 0
    SidebarScroll.ScrollBarThickness = 4
    SidebarScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 110, 220)
    SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    local SidebarLayout = Instance.new("UIListLayout", SidebarScroll)
    SidebarLayout.Padding = UDim.new(0, 2)
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10)
    end)
    ContentFrame = Instance.new("Frame", MenuFrame)
    ContentFrame.Size = UDim2.new(1, -128, 1, -44)
    ContentFrame.Position = UDim2.new(0, 124, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = true
    local UserPanel = Instance.new("Frame", Sidebar)
    UserPanel.Size = UDim2.new(1, -8, 0, 40)
    UserPanel.Position = UDim2.new(0, 4, 1, -44)
    UserPanel.BackgroundColor3 = Color3.fromRGB(12, 14, 17)
    Instance.new("UICorner", UserPanel).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", UserPanel).Color = Color3.fromRGB(24, 26, 30)
    local Avatar = Instance.new("ImageLabel", UserPanel)
    Avatar.Size = UDim2.new(0, 24, 0, 24)
    Avatar.Position = UDim2.new(0, 6, 0.5, -12)
    Avatar.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
    Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
    local UserInfo = Instance.new("Frame", UserPanel)
    UserInfo.Size = UDim2.new(1, -38, 1, -6)
    UserInfo.Position = UDim2.new(0, 34, 0, 3)
    UserInfo.BackgroundTransparency = 1
    local NameLbl = Instance.new("TextLabel", UserInfo)
    NameLbl.Size = UDim2.new(1, 0, 0, 16)
    NameLbl.Text = LocalPlayer.DisplayName
    NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 8.5
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.BackgroundTransparency = 1
    local SubLbl = Instance.new("TextLabel", UserInfo)
    SubLbl.Size = UDim2.new(1, 0, 0, 14)
    SubLbl.Position = UDim2.new(0, 0, 0, 16)
    SubLbl.Text = "Till: " .. TillText
    SubLbl.TextColor3 = Color3.fromRGB(0, 110, 220)
    SubLbl.Font = Enum.Font.GothamBold
    SubLbl.TextSize = 8
    SubLbl.TextXAlignment = Enum.TextXAlignment.Left
    SubLbl.BackgroundTransparency = 1
    local function CreateTab(name)
        local page = Instance.new("ScrollingFrame", ContentFrame)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Color3.fromRGB(0, 110, 220)
        page.Visible = false
        local lay = Instance.new("UIListLayout", page)
        lay.Padding = UDim.new(0, 6)
        return page
    end
    local function ShowTab(tabName)
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") and child.Name == tabName then
                child.Visible = true
            end
        end
        for _, child in pairs(SidebarScroll:GetChildren()) do
            if child:IsA("TextButton") then
                local text = child.Text:gsub("    ", "")
                if text == tabName then
                    child.TextColor3 = Color3.fromRGB(255, 255, 255)
                    child.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
                else
                    child.TextColor3 = Color3.fromRGB(110, 115, 125)
                    child.BackgroundColor3 = Color3.fromRGB(8, 9, 11)
                end
            end
        end
    end
    local function CreateSidebarTab(name)
        local page = CreateTab(name)
        local btn = Instance.new("TextButton", SidebarScroll)
        btn.Size = UDim2.new(1, -4, 0, 24)
        btn.BorderSizePixel = 0
        btn.BackgroundColor3 = Color3.fromRGB(8, 9, 11)
        btn.Text = "    " .. name
        btn.TextColor3 = Color3.fromRGB(110, 115, 125)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 9.5
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function() ShowTab(name) end)
        return page
    end
    local function CreateGroupBox(parent)
        local box = Instance.new("Frame", parent)
        box.Size = UDim2.new(1, -4, 0, 10)
        box.BackgroundColor3 = Color3.fromRGB(13, 15, 18)
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local lay = Instance.new("UIListLayout", box)
        lay.Padding = UDim.new(0, 6)
        local pad = Instance.new("UIPadding", box)
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 6)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            box.Size = UDim2.new(1, -4, 0, lay.AbsoluteContentSize.Y + 14)
        end)
        return box
    end
    local function CreateToggle(parent, text, key)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 20)
        f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f)
        l.Text = text
        l.TextColor3 = Color3.fromRGB(200, 205, 215)
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 10
        l.Size = UDim2.new(0.75, 0, 1, 0)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.BackgroundTransparency = 1
        local toggleBg = Instance.new("TextButton", f)
        toggleBg.Size = UDim2.new(0, 26, 0, 13)
        toggleBg.Position = UDim2.new(1, -28, 0.5, -6)
        toggleBg.Text = ""
        toggleBg.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(15, 17, 20)
        Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
        local circle = Instance.new("Frame", toggleBg)
        circle.Size = UDim2.new(0, 8, 0, 8)
        circle.Position = Settings[key] and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        local tStroke = Instance.new("UIStroke", toggleBg)
        tStroke.Color = Settings[key] and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(28, 31, 36)
        UI_Sync_Registry[key] = { Type = "Toggle", Bg = toggleBg, Circle = circle, Stroke = tStroke }
        toggleBg.MouseButton1Click:Connect(function()
            Settings[key] = not Settings[key]
            circle:TweenPosition(Settings[key] and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
            toggleBg.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(15, 17, 20)
            tStroke.Color = Settings[key] and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(28, 31, 36)
        end)
    end
    local function CreateSlider(parent, text, min, max, key)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 28)
        f.BackgroundTransparency = 1
        if Settings[key] == nil then Settings[key] = min end
        local l = Instance.new("TextLabel", f)
        l.Text = text .. " (" .. tostring(Settings[key]) .. ")"
        l.TextColor3 = Color3.fromRGB(170, 175, 185)
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 9
        l.Size = UDim2.new(1, 0, 0, 12)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.BackgroundTransparency = 1
        local bg = Instance.new("Frame", f)
        bg.Size = UDim2.new(1, 0, 0, 4)
        bg.Position = UDim2.new(0, 0, 0, 16)
        bg.BackgroundColor3 = Color3.fromRGB(15, 17, 20)
        Instance.new("UICorner", bg)
        local fill = Instance.new("Frame", bg)
        local defaultPct = math.clamp((Settings[key] - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(defaultPct, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
        Instance.new("UICorner", fill)
        local trigger = Instance.new("TextButton", bg)
        trigger.Size = UDim2.new(1, 0, 3, 0)
        trigger.Position = UDim2.new(0, 0, -1, 0)
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        UI_Sync_Registry[key] = { Type = "Slider", Fill = fill, Label = l, Text = text, Min = min, Max = max }
        local sliding = false
        local function update(inputPos)
            local relativeX = inputPos.X - bg.AbsolutePosition.X
            local width = bg.AbsoluteSize.X
            local pct = relativeX / width
            if relativeX <= 3 then pct = 0
            elseif relativeX >= (width - 3) then pct = 1 end
            pct = math.clamp(pct, 0, 1)
            local val = math.floor(min + (pct * (max - min)))
            if val ~= val or val == nil then val = min end
            val = math.clamp(val, min, max)
            Settings[key] = val
            fill.Size = UDim2.new(pct, 0, 1, 0)
            l.Text = text .. " (" .. tostring(val) .. ")"
        end
        trigger.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                update(i.Position)
            end
        end)
        trigger.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i.Position)
            end
        end)
    end
    local function CreateCombo(parent, text, options, key, callback)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 34)
        f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f)
        l.Text = text
        l.TextColor3 = Color3.fromRGB(170, 175, 185)
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 9
        l.Size = UDim2.new(1, 0, 0, 12)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.BackgroundTransparency = 1
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(1, 0, 0, 18)
        btn.Position = UDim2.new(0, 0, 0, 14)
        btn.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
        btn.Text = " " .. tostring(options[1])
        btn.TextColor3 = Color3.fromRGB(230, 235, 245)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 9
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        local currentIdx = 1
        btn.MouseButton1Click:Connect(function()
            currentIdx = (currentIdx % #options) + 1
            local chosen = options[currentIdx]
            btn.Text = " " .. tostring(chosen)
            callback(chosen)
        end)
    end
    
    local gRagePage = CreateSidebarTab("RageBot")
    local gRage = CreateGroupBox(gRagePage)
    CreateToggle(gRage, "Включить аимбот", "Enabled")
    CreateToggle(gRage, "Сайлент аим", "SilentAim")
    CreateToggle(gRage, "Проверка видимости", "VisibleCheck")
    CreateToggle(gRage, "Триггер бот", "Triggerbot")
    CreateToggle(gRage, "Показать FOV", "ShowFOV")
    CreateSlider(gRage, "Плавность аима", 1, 30, "AimSmoothness")
    CreateSlider(gRage, "Угол обзора (FOV)", 10, 800, "FOV")
    CreateToggle(gRage, "Увеличить хитбокс", "HitboxExpand")
    CreateSlider(gRage, "Размер хитбокса", 2, 15, "HitboxSize")
    
    local gAAPage = CreateSidebarTab("AntiAim")
    local gAA = CreateGroupBox(gAAPage)
    CreateToggle(gAA, "Анти аим", "AntiAim")
    CreateToggle(gAA, "Йоу джиттер", "YawJitter")
    CreateToggle(gAA, "Спин бот", "Spinbot")
    CreateSlider(gAA, "Скорость спинбота", 10, 180, "SpinSpeed")
    
    local gLegitPage = CreateSidebarTab("LegitBot")
    local gLegit = CreateGroupBox(gLegitPage)
    CreateToggle(gLegit, "Легит аим", "Enabled")
    CreateSlider(gLegit, "Плавность", 5, 50, "AimSmoothness")
    CreateSlider(gLegit, "Угол обзора", 5, 120, "FOV")
    
    local gPlPage = CreateSidebarTab("Players")
    local gPl = CreateGroupBox(gPlPage)
    CreateToggle(gPl, "ESP", "ESP")
    CreateToggle(gPl, "Боксы", "ESP_Boxes")
    CreateToggle(gPl, "Имена", "ESP_Names")
    CreateToggle(gPl, "Здоровье", "ESP_Health")
    CreateToggle(gPl, "Чамы", "ESP_Chams")
    CreateToggle(gPl, "Десинхрон", "DesyncChams")
    CreateToggle(gPl, "Трейсеры", "ESP_Tracers")
    CreateToggle(gPl, "Радужный режим", "RainbowESP")
    CreateToggle(gPl, "Стримпруф", "Streamproof")
    CreateSlider(gPl, "Красный", 0, 255, "ESP_ColorR")
    CreateSlider(gPl, "Зеленый", 0, 255, "ESP_ColorG")
    CreateSlider(gPl, "Синий", 0, 255, "ESP_ColorB")
    
    local gWepPage = CreateSidebarTab("Weapon")
    local gWep = CreateGroupBox(gWepPage)
    CreateToggle(gWep, "Нет отдачи", "NoRecoil")
    CreateToggle(gWep, "Бесконечные патроны", "InfAmmo")
    CreateToggle(gWep, "Быстрая стрельба", "RapidFire")
    CreateToggle(gWep, "Сквозь стены", "Wallshot")
    
    local gWldPage = CreateSidebarTab("World")
    local gWld = CreateGroupBox(gWldPage)
    CreateToggle(gWld, "Убрать туман", "NoFog")
    CreateToggle(gWld, "Полная яркость", "Fullbright")
    CreateToggle(gWld, "FPS Буст", "FPSBoost")
    CreateSlider(gWld, "Гравитация", 0, 400, "GravityValue")
    
    local gViewPage = CreateSidebarTab("View")
    local gView = CreateGroupBox(gViewPage)
    CreateToggle(gView, "Свободная камера", "NoClipCam")
    CreateToggle(gView, "Третье лицо", "ThirdPerson")
    CreateSlider(gView, "Дистанция", 5, 100, "ThirdPersonDist")
    
    local gMainPage = CreateSidebarTab("Main")
    local gMain = CreateGroupBox(gMainPage)
    CreateToggle(gMain, "Телепорт за спину", "BackstabTeleport")
    CreateToggle(gMain, "Невидимый килл", "InvisKill")
    CreateToggle(gMain, "Фазовый проход", "PhaseWalk")
    CreateToggle(gMain, "Спидхак", "SpeedHack")
    CreateSlider(gMain, "Скорость", 16, 200, "SpeedValue")
    CreateToggle(gMain, "Джампхак", "JumpHack")
    CreateSlider(gMain, "Сила прыжка", 50, 300, "JumpValue")
    CreateToggle(gMain, "Спид джамп", "SpeedJump")
    CreateToggle(gMain, "Баннихоп", "Bhop")
    CreateToggle(gMain, "Авто стрейф", "AutoStrafe")
    CreateSlider(gMain, "Скорость баннихопа", 16, 120, "BhopSpeed")
    CreateToggle(gMain, "Полёт", "Fly")
    CreateSlider(gMain, "Скорость полёта", 10, 150, "FlySpeed")
    
    local TpBtn = Instance.new("TextButton", gMain)
    TpBtn.Size = UDim2.new(1, 0, 0, 24)
    TpBtn.Text = "ТЕЛЕПОРТ К ИГРОКУ"
    TpBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
    TpBtn.Font = Enum.Font.GothamBold
    TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TpBtn.TextSize = 9
    Instance.new("UICorner", TpBtn)
    TpBtn.MouseButton1Click:Connect(function()
        local target = GetTarget()
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if target and target.Character and myHrp then
            local enemyHrp = target.Character:FindFirstChild("HumanoidRootPart")
            if enemyHrp then
                myHrp.CFrame = enemyHrp.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end)
    
    local gScriptsPage = CreateSidebarTab("Scripts")
    local gScripts = CreateGroupBox(gScriptsPage)
    if isfolder and not isfolder("NL_Scripts") then makefolder("NL_Scripts") end
    local ScriptNameInput = Instance.new("TextBox", gScripts)
    ScriptNameInput.Size = UDim2.new(1, 0, 0, 24)
    ScriptNameInput.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
    ScriptNameInput.PlaceholderText = "Название скрипта..."
    ScriptNameInput.Text = ""
    ScriptNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptNameInput.Font = Enum.Font.GothamSemibold
    ScriptNameInput.TextSize = 10
    Instance.new("UICorner", ScriptNameInput)
    local ScriptCodeInput = Instance.new("TextBox", gScripts)
    ScriptCodeInput.Size = UDim2.new(1, 0, 0, 60)
    ScriptCodeInput.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
    ScriptCodeInput.PlaceholderText = "Введите Lua код..."
    ScriptCodeInput.Text = ""
    ScriptCodeInput.TextColor3 = Color3.fromRGB(200, 205, 215)
    ScriptCodeInput.Font = Enum.Font.GothamSemibold
    ScriptCodeInput.TextSize = 9
    ScriptCodeInput.TextWrapped = true
    ScriptCodeInput.TextXAlignment = Enum.TextXAlignment.Left
    ScriptCodeInput.TextYAlignment = Enum.TextYAlignment.Top
    Instance.new("UICorner", ScriptCodeInput).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", ScriptCodeInput).Color = Color3.fromRGB(30, 34, 40)
    local CreateScriptBtn = Instance.new("TextButton", gScripts)
    CreateScriptBtn.Size = UDim2.new(0.48, -4, 0, 24)
    CreateScriptBtn.Position = UDim2.new(0, 0, 0, 0)
    CreateScriptBtn.Text = T("script_create")
    CreateScriptBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
    CreateScriptBtn.Font = Enum.Font.GothamBold
    CreateScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CreateScriptBtn.TextSize = 9
    Instance.new("UICorner", CreateScriptBtn)
    local RunScriptBtn = Instance.new("TextButton", gScripts)
    RunScriptBtn.Size = UDim2.new(0.48, -4, 0, 24)
    RunScriptBtn.Position = UDim2.new(0.52, 0, 0, 0)
    RunScriptBtn.Text = T("script_run")
    RunScriptBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
    RunScriptBtn.Font = Enum.Font.GothamBold
    RunScriptBtn.TextColor3 = Color3.fromRGB(0, 200, 100)
    RunScriptBtn.TextSize = 9
    Instance.new("UICorner", RunScriptBtn)
    local ScriptScrollList = Instance.new("ScrollingFrame", gScripts)
    ScriptScrollList.Size = UDim2.new(1, 0, 0, 80)
    ScriptScrollList.Position = UDim2.new(0, 0, 0, 54)
    ScriptScrollList.BackgroundTransparency = 1
    ScriptScrollList.ScrollBarThickness = 2
    ScriptScrollList.ScrollBarImageColor3 = Color3.fromRGB(0, 110, 220)
    local ScriptListLayout = Instance.new("UIListLayout", ScriptScrollList)
    ScriptListLayout.Padding = UDim.new(0, 4)
    local function GetScriptList()
        local list = {}
        if listfiles then
            local files = listfiles("NL_Scripts")
            for _, f in pairs(files) do
                if f:sub(-4):lower() == ".lua" then
                    local cleanName = f:gsub("NL_Scripts\\", ""):gsub("NL_Scripts/", ""):gsub("%.lua", "")
                    table.insert(list, cleanName)
                end
            end
        end
        return list
    end
    local function UpdateScriptList()
        for _, child in pairs(ScriptScrollList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local scripts = GetScriptList()
        for _, name in pairs(scripts) do
            local btn = Instance.new("TextButton", ScriptScrollList)
            btn.Size = UDim2.new(1, -4, 0, 20)
            btn.BackgroundColor3 = (SelectedScriptName == name) and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(15, 17, 20)
            btn.Text = " " .. name
            btn.Font = Enum.Font.GothamSemibold
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 9
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
            btn.MouseButton1Click:Connect(function()
                SelectedScriptName = name
                UpdateScriptList()
                pcall(function()
                    local filePath = "NL_Scripts/" .. name .. ".lua"
                    if isfile(filePath) then
                        ScriptCodeInput.Text = readfile(filePath)
                        ScriptNameInput.Text = name
                    end
                end)
            end)
            local delBtn = Instance.new("TextButton", btn)
            delBtn.Size = UDim2.new(0, 16, 1, 0)
            delBtn.Position = UDim2.new(1, -18, 0, 0)
            delBtn.BackgroundTransparency = 1
            delBtn.Text = "✕"
            delBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            delBtn.TextSize = 10
            delBtn.Font = Enum.Font.GothamBold
            delBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local filePath = "NL_Scripts/" .. name .. ".lua"
                    if isfile(filePath) then
                        delfile(filePath)
                        if SelectedScriptName == name then SelectedScriptName = "" end
                        UpdateScriptList()
                    end
                end)
            end)
        end
    end
    CreateScriptBtn.MouseButton1Click:Connect(function()
        local name = ScriptNameInput.Text:gsub("%s+", "")
        local code = ScriptCodeInput.Text
        if name ~= "" and code ~= "" and writefile then
            pcall(function()
                writefile("NL_Scripts/" .. name .. ".lua", code)
                SelectedScriptName = name
                UpdateScriptList()
                ScriptNameInput.Text = ""
                ScriptCodeInput.Text = ""
                AddExternalTab(name, code)
            end)
        end
    end)
    RunScriptBtn.MouseButton1Click:Connect(function()
        if SelectedScriptName ~= "" and readfile then
            pcall(function()
                local filePath = "NL_Scripts/" .. SelectedScriptName .. ".lua"
                if isfile(filePath) then
                    local scriptCode = readfile(filePath)
                    local func, err = loadstring(scriptCode)
                    if func then
                        pcall(func)
                        AddExternalTab(SelectedScriptName, scriptCode)
                    end
                end
            end)
        end
    end)
    UpdateScriptList()
    
    local gCfgPage = CreateSidebarTab("Configs")
    local gCfg = CreateGroupBox(gCfgPage)
    if isfolder and not isfolder("NL_Configs") then makefolder("NL_Configs") end
    local CfgNameInput = Instance.new("TextBox", gCfg)
    CfgNameInput.Size = UDim2.new(1, 0, 0, 24)
    CfgNameInput.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
    CfgNameInput.PlaceholderText = "Название конфига..."
    CfgNameInput.Text = ""
    CfgNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    CfgNameInput.Font = Enum.Font.GothamSemibold
    CfgNameInput.TextSize = 10
    Instance.new("UICorner", CfgNameInput)
    local CreateBtn = Instance.new("TextButton", gCfg)
    CreateBtn.Size = UDim2.new(1, 0, 0, 24)
    CreateBtn.Text = T("config_create")
    CreateBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
    CreateBtn.Font = Enum.Font.GothamBold
    CreateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CreateBtn.TextSize = 9
    Instance.new("UICorner", CreateBtn)
    local ScrollList = Instance.new("ScrollingFrame", gCfg)
    ScrollList.Size = UDim2.new(1, 0, 0, 90)
    ScrollList.BackgroundTransparency = 1
    ScrollList.ScrollBarThickness = 2
    ScrollList.ScrollBarImageColor3 = Color3.fromRGB(0, 110, 220)
    local ListLayout = Instance.new("UIListLayout", ScrollList)
    ListLayout.Padding = UDim.new(0, 4)
    local LoadBtn = Instance.new("TextButton", gCfg)
    LoadBtn.Size = UDim2.new(1, 0, 0, 24)
    LoadBtn.Text = T("config_load")
    LoadBtn.BackgroundColor3 = Color3.fromRGB(20, 23, 27)
    LoadBtn.Font = Enum.Font.GothamBold
    LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadBtn.TextSize = 9
    Instance.new("UICorner", LoadBtn)
    local DeleteBtn = Instance.new("TextButton", gCfg)
    DeleteBtn.Size = UDim2.new(1, 0, 0, 24)
    DeleteBtn.Text = T("config_delete")
    DeleteBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    DeleteBtn.Font = Enum.Font.GothamBold
    DeleteBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    DeleteBtn.TextSize = 9
    Instance.new("UICorner", DeleteBtn)
    local function UpdateConfigList()
        for _, child in pairs(ScrollList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local configs = GetConfigs()
        for _, name in pairs(configs) do
            local btn = Instance.new("TextButton", ScrollList)
            btn.Size = UDim2.new(1, -4, 0, 20)
            btn.BackgroundColor3 = (SelectedConfigName == name) and Color3.fromRGB(0, 110, 220) or Color3.fromRGB(15, 17, 20)
            btn.Text = " " .. name
            btn.Font = Enum.Font.GothamSemibold
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 9
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
            btn.MouseButton1Click:Connect(function()
                SelectedConfigName = name
                UpdateConfigList()
            end)
        end
    end
    CreateBtn.MouseButton1Click:Connect(function()
        local name = CfgNameInput.Text:gsub("%s+", "")
        if name ~= "" and writefile then
            SaveConfig(name)
            CfgNameInput.Text = ""
            SelectedConfigName = name
            UpdateConfigList()
        end
    end)
    LoadBtn.MouseButton1Click:Connect(function()
        if SelectedConfigName ~= "" then LoadConfig(SelectedConfigName) end
    end)
    DeleteBtn.MouseButton1Click:Connect(function()
        if SelectedConfigName ~= "" and delfile then
            pcall(function()
                delfile("NL_Configs/" .. SelectedConfigName .. ".cfg")
                SelectedConfigName = ""
                UpdateConfigList()
            end)
        end
    end)
    UpdateConfigList()
    
    local gSettingsPage = CreateSidebarTab("Settings")
    local gSettings = CreateGroupBox(gSettingsPage)
    local infoLabel = Instance.new("TextLabel", gSettings)
    infoLabel.Size = UDim2.new(1, 0, 0, 55)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "NEVERLOSE Mobile Alpha\n" .. T("version") .. "\nTill: " .. TillText
    infoLabel.TextColor3 = Color3.fromRGB(150, 155, 165)
    infoLabel.Font = Enum.Font.GothamSemibold
    infoLabel.TextSize = 9
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    local LangBtn = Instance.new("TextButton", gSettings)
    LangBtn.Size = UDim2.new(1, 0, 0, 24)
    LangBtn.Text = T("language") .. ": " .. (CurrentLanguage == "RU" and "Русский" or "English")
    LangBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
    LangBtn.Font = Enum.Font.GothamBold
    LangBtn.TextColor3 = Color3.fromRGB(0, 110, 220)
    LangBtn.TextSize = 9
    Instance.new("UICorner", LangBtn)
    LangBtn.MouseButton1Click:Connect(function()
        if CurrentLanguage == "RU" then CurrentLanguage = "EN"
        else CurrentLanguage = "RU" end
        LangBtn.Text = T("language") .. ": " .. (CurrentLanguage == "RU" and "Русский" or "English")
    end)
    local RejoinBtn = Instance.new("TextButton", gSettings)
    RejoinBtn.Size = UDim2.new(1, 0, 0, 22)
    RejoinBtn.Text = T("rejoin")
    RejoinBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
    RejoinBtn.Font = Enum.Font.GothamBold
    RejoinBtn.TextColor3 = Color3.fromRGB(0, 110, 220)
    RejoinBtn.TextSize = 8
    Instance.new("UICorner", RejoinBtn)
    RejoinBtn.MouseButton1Click:Connect(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    CreateCombo(gSettings, "Menu DPI", {"100%", "125%", "150%", "75%"}, "MenuDPI", function(choice)
        local val = tonumber(choice:gsub("%%", "")) / 100
        Settings.MenuDPI = val
        MenuFrame.Size = UDim2.new(0, 480 * val, 0, 350 * val)
    end)
    CreateCombo(gSettings, "ESP DPI", {"100%", "125%", "150%", "75%"}, "EspDPI", function(choice)
        Settings.EspDPI = tonumber(choice:gsub("%%", "")) / 100
    end)
    
    MenuCreated = true
end

local KeyGui = Instance.new("ScreenGui", TargetGuiParent)
KeyGui.Name = "NL_KeySystem"
KeyGui.ResetOnSpawn = false
local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.new(0, 340, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -170, 0.5, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(11, 12, 14)
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", KeyFrame).Color = Color3.fromRGB(0, 110, 220)
local KTitle = Instance.new("TextLabel", KeyFrame)
KTitle.Size = UDim2.new(1, 0, 0, 50)
KTitle.BackgroundTransparency = 1
KTitle.Text = "NEVERLOSE"
KTitle.TextColor3 = Color3.fromRGB(0, 110, 220)
KTitle.Font = Enum.Font.GothamBold
KTitle.TextSize = 18
local SubTitle = Instance.new("TextLabel", KeyFrame)
SubTitle.Size = UDim2.new(1, 0, 0, 25)
SubTitle.Position = UDim2.new(0, 0, 0, 40)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = T("subtitle")
SubTitle.TextColor3 = Color3.fromRGB(150, 155, 165)
SubTitle.Font = Enum.Font.GothamSemibold
SubTitle.TextSize = 11
local TextBoxBg = Instance.new("Frame", KeyFrame)
TextBoxBg.Size = UDim2.new(0.9, 0, 0, 35)
TextBoxBg.Position = UDim2.new(0.05, 0, 0, 75)
TextBoxBg.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
Instance.new("UICorner", TextBoxBg).CornerRadius = UDim.new(0, 4)
local KeyInput = Instance.new("TextBox", TextBoxBg)
KeyInput.Size = UDim2.new(1, -10, 1, 0)
KeyInput.Position = UDim2.new(0, 5, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.PlaceholderText = T("placeholder")
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.GothamSemibold
KeyInput.TextSize = 12
local SubmitBtn = Instance.new("TextButton", KeyFrame)
SubmitBtn.Size = UDim2.new(0.42, 0, 0, 32)
SubmitBtn.Position = UDim2.new(0.05, 0, 0, 125)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
SubmitBtn.Text = T("activate")
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 11
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 4)
local GetKeyBtn = Instance.new("TextButton", KeyFrame)
GetKeyBtn.Size = UDim2.new(0.42, 0, 0, 32)
GetKeyBtn.Position = UDim2.new(0.53, 0, 0, 125)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
GetKeyBtn.Text = T("buy")
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextColor3 = Color3.fromRGB(0, 110, 220)
GetKeyBtn.TextSize = 11
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 4)
local StatusLabel = Instance.new("TextLabel", KeyFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 170)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = T("waiting")
StatusLabel.TextColor3 = Color3.fromRGB(110, 115, 125)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 10
local dragInputKey, dragStartKey, startPosKey
KeyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStartKey = input.Position
        startPosKey = KeyFrame.Position
    end
end)
KeyFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputKey = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputKey then
        local delta = input.Position - dragStartKey
        KeyFrame.Position = UDim2.new(startPosKey.X.Scale, startPosKey.X.Offset + delta.X, startPosKey.Y.Scale, startPosKey.Y.Offset + delta.Y)
    end
end)
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(BuyContact)
        StatusLabel.Text = T("copied")
        StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
    else
        StatusLabel.Text = "Ошибка: " .. BuyContact
    end
end)
SubmitBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = T("checking")
    task.spawn(function()
        local success, keysList = pcall(function()
            return game:HttpGet(KeysURL)
        end)
        if not success then
            StatusLabel.Text = T("error_connect")
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        local userKey = KeyInput.Text:gsub("%s+", "")
        if userKey == "" then
            StatusLabel.Text = T("error_empty")
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        local keyValid = false
        local expiryInfo = ""
        for line in keysList:gmatch("[^\r\n]+") do
            local parts = {}
            for part in line:gmatch("[^|]+") do
                table.insert(parts, part)
            end
            local key = parts[1] and parts[1]:gsub("%s+", "") or ""
            local expiry = parts[2] and parts[2]:gsub("%s+", "") or "lifetime"
            if key == userKey then
                local valid, info = CheckKeyExpiry(expiry)
                if valid then
                    keyValid = true
                    TillText = info
                    expiryInfo = info
                    break
                else
                    StatusLabel.Text = "❌ " .. info
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    return
                end
            end
        end
        if keyValid then
            StatusLabel.Text = "✅ Ключ подтвержден! Till: " .. expiryInfo
            StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
            task.wait(0.5)
            KeyGui:Destroy()
            CreateMenu()
            task.wait(1)
            RemoveHeaders()
        else
            StatusLabel.Text = T("error_key")
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
end)

local function HookScriptExecution()
    local oldLoadstring = loadstring
    getgenv().loadstring = function(code, chunkname)
        if code and type(code) == "string" and code ~= "" and not code:find("NEVERLOSE") then
            local name = chunkname or "Script_" .. os.time()
            if name:find("=") then
                name = name:gsub("=", "")
            end
            task.spawn(function()
                while not MenuCreated do task.wait(0.5) end
                AddExternalTab(name, code)
            end)
        end
        return oldLoadstring(code, chunkname)
    end
end

task.spawn(HookScriptExecution)
