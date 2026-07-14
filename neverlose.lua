-- =================================================================
-- NEVERLOSE v3 - FIXED & OPTIMIZED (READY FOR SALE)
-- =================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TargetGuiParent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Твоя ссылка на список ключей и контакт для покупки
local KeysURL = "https://pastebin.com/raw/sLFHFhyG" -- ЗАМЕНИ НА СВОЮ RAW ССЫЛКУ
local BuyContact = "Telegram: @nl_soufiw"      -- Твой контакт для связи вместо Дискорда

local function StartCheat()
    -- ========== КОД ЧИТА (НАЧАЛО) ==========
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local Settings = {
        Enabled = true,
        SilentAim = true,
        VisibleCheck = false,
        Triggerbot = false,
        ESP = true,
        ESP_Boxes = true,
        ESP_Tracers = true,
        ESP_Names = true,
        ESP_HP = true,
        ESP_Chams = true,
        ESP_Skeleton = true,
        ESP_ColorR = 255,
        ESP_ColorG = 255,
        ESP_ColorB = 255,
        Bhop = true,
        GodMode = false,
        Noclip = false,
        Fly = false,
        NoRecoil = true,
        InfAmmo = true,
        RapidFire = true,
        Wallshot = false,
        AutoReload = true,
        SpeedHack = false,
        SpeedValue = 32,
        BhopSpeed = 30,
        FlySpeed = 25,
        FOV = 150,
        ThirdPerson = false,
        ThirdPersonDist = 10,
        WalkOnAir = false,
        ChatSpam = false
    }
    getgenv().Digla = Settings

    local hasDrawing = pcall(function() return Drawing.new("Line") end)
    local UI_Sync_Registry = {}

    -- ========== УТИЛИТЫ ==========
    local function GetESPColor()
        return Color3.fromRGB(Settings.ESP_ColorR, Settings.ESP_ColorG, Settings.ESP_ColorB)
    end

    local function IsEnemy(player)
        if player == LocalPlayer then return false end
        if player.Team and LocalPlayer.Team then
            return player.Team ~= LocalPlayer.Team
        end
        return true
    end

    local function IsVisible(part)
        if not Settings.VisibleCheck then return true end
        local char = LocalPlayer.Character
        if not char then return false end
        
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char, part.Parent}
        params.IgnoreWater = true
        
        local origin = Camera.CFrame.Position
        local direction = part.Position - origin
        local result = workspace:Raycast(origin, direction, params)
        
        return result == nil
    end

    local function GetTarget()
        local closest = nil
        local closestDist = Settings.FOV
        local center = Camera.ViewportSize / 2
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsEnemy(player) then
                local char = player.Character
                local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
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
        return closest
    end

    -- Стабильный Аимбот (Идеально работает в 1-м и 3-м лице)
    RunService.RenderStepped:Connect(function()
        if Settings.Enabled then
            local target = GetTarget()
            if target and target.Character then
                local aimPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                if aimPart then
                    -- Наведение через вычисление углов (не ломает камеру в 3-м лице)
                    local lookVector = (aimPart.Position - Camera.CFrame.Position).Unit
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.25)
                end
            end
        end
    end)

    -- Безопасный Silent Aim
    local PlayerMouse = LocalPlayer:GetMouse()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if self == PlayerMouse and (key == "Hit" or key == "Target") and Settings.SilentAim then
            local target = GetTarget()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    if key == "Hit" then
                        return head.CFrame
                    elseif key == "Target" then
                        return head
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)

    -- Triggerbot
    task.spawn(function()
        while true do
            task.wait(0.05)
            if Settings.Triggerbot then
                local target = GetTarget()
                if target and target.Character then
                    local mouseTarget = PlayerMouse.Target
                    if mouseTarget and mouseTarget:IsDescendantOf(target.Character) then
                        mouse1click()
                        task.wait(0.1)
                    end
                end
            end
        end
    end)

    -- Chat Spammer
    task.spawn(function()
        local phrases = {
            "NeverLose.cc - get good, get neversense!",
            "Get tapped by NL v3 Paste."
        }
        while true do
            task.wait(4)
            if Settings.ChatSpam then
                local say = phrases[math.random(1, #phrases)]
                local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                    chatEvents.SayMessageRequest:FireServer(say, "All")
                else
                    local tcs = game:GetService("TextChatService")
                    if tcs and tcs.TextChannels and tcs.TextChannels:FindFirstChild("RBXGeneral") then
                        tcs.TextChannels.RBXGeneral:SendAsync(say)
                    end
                end
            end
        end
    end)

    -- Third Person (Оптимизированный)
    RunService.RenderStepped:Connect(function()
        if Settings.ThirdPerson then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = Settings.ThirdPersonDist
            LocalPlayer.CameraMinZoomDistance = Settings.ThirdPersonDist
        else
            LocalPlayer.CameraMaxZoomDistance = 400
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end)

    -- Walk on Air
    local airPlatform = nil
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if Settings.WalkOnAir then
            if not airPlatform or not airPlatform.Parent then
                airPlatform = Instance.new("Part")
                airPlatform.Size = Vector3.new(15, 1, 15)
                airPlatform.Transparency = 1
                airPlatform.Anchored = true
                airPlatform.Parent = workspace
            end
            airPlatform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
        else
            if airPlatform then airPlatform:Destroy() airPlatform = nil end
        end
    end)

    -- Оружие
    local function TweakWeapons(tool)
        if not tool:IsA("Tool") then return end
        task.spawn(function()
            while tool.Parent == LocalPlayer.Character or tool.Parent == LocalPlayer:FindFirstChildOfClass("Backpack") do
                task.wait(0.5)
                
                if Settings.Wallshot then
                    for _, part in pairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end

                for _, child in pairs(tool:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        local name = child.Name:lower()
                        if Settings.RapidFire and (name:find("cooldown") or name:find("firerate") or name:find("delay") or name:find("rate")) then
                            child.Value = 0.01
                        end
                        if Settings.NoRecoil and (name:find("recoil") or name:find("spread") or name:find("kick")) then
                            child.Value = 0
                        end
                        if Settings.InfAmmo and (name:find("ammo") or name:find("clip") or name:find("stored")) then
                            child.Value = 999
                        end
                    end
                end
            end
        end)
    end
    LocalPlayer:FindFirstChildOfClass("Backpack").ChildAdded:Connect(TweakWeapons)
    if LocalPlayer.Character then LocalPlayer.Character.ChildAdded:Connect(TweakWeapons) end

    -- Движение
    local flyVelocity = nil
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if hum then
            if Settings.SpeedHack then hum.WalkSpeed = Settings.SpeedValue end
            if Settings.GodMode then hum.Health = 99999 end
        end
        
        if Settings.Noclip then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        
        if Settings.Fly and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if hum then hum.PlatformStand = true end
            if not flyVelocity then
                flyVelocity = Instance.new("BodyVelocity", hrp)
                flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            end
            flyVelocity.Velocity = Camera.CFrame.LookVector * Settings.FlySpeed
        else
            if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
        end
    end)

    -- Bhop
    RunService.RenderStepped:Connect(function()
        if not Settings.Bhop or not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        
        if hum.FloorMaterial ~= Enum.Material.Air then
            if hrp.Velocity.Magnitude > 1 then hum.Jump = true end
        else
            if not Settings.SpeedHack then hum.WalkSpeed = Settings.BhopSpeed end
        end
    end)

    -- Синхронизация КФГ
    local function SyncUIElements()
        for key, element in pairs(UI_Sync_Registry) do
            local value = Settings[key]
            if element.Type == "Toggle" then
                element.Circle:TweenPosition(
                    value and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
                    Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true
                )
                element.Bg.BackgroundColor3 = value and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(20, 24, 35)
                element.Stroke.Color = value and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(35, 42, 58)
            elseif element.Type == "Slider" then
                local pct = math.clamp((value - element.Min) / (element.Max - element.Min), 0, 1)
                element.Fill.Size = UDim2.new(pct, 0, 1, 0)
                element.Label.Text = element.Text .. " (" .. tostring(value) .. ")"
            end
        end
    end

    local function SaveConfig()
        pcall(function() writefile("NeverLose_V3_Safe.txt", HttpService:JSONEncode(Settings)) end)
    end

    local function LoadConfig()
        pcall(function()
            if isfile and isfile("NeverLose_V3_Safe.txt") then
                local loaded = HttpService:JSONDecode(readfile("NeverLose_V3_Safe.txt"))
                for k, v in pairs(loaded) do Settings[k] = v end
                SyncUIElements()
            end
        end)
    end

    -- ESP + SKELETON
    local ESPContainer = TargetGuiParent:FindFirstChild("NL_ESP_Hold")
    if ESPContainer then ESPContainer:Destroy() end
    ESPContainer = Instance.new("ScreenGui", TargetGuiParent)
    ESPContainer.Name = "NL_ESP_Hold"
    ESPContainer.ResetOnSpawn = false

    local function CreateESP(player)
        if player == LocalPlayer then return end
        
        local function SetupChar(char)
            local hrp = char:WaitForChild("HumanoidRootPart", 10)
            local hum = char:WaitForChild("Humanoid", 10)
            if not hrp or not hum then return end
            
            local oldESP = ESPContainer:FindFirstChild(player.Name .. "_ESP")
            if oldESP then oldESP:Destroy() end
            
            local esp = Instance.new("BillboardGui", ESPContainer)
            esp.Name = player.Name .. "_ESP"
            esp.Size = UDim2.new(3.5, 0, 5.8, 0)
            esp.AlwaysOnTop = true
            esp.Adornee = hrp
            
            local box = Instance.new("Frame", esp)
            box.Size = UDim2.new(1, 0, 1, 0)
            box.BackgroundTransparency = 1
            local outline = Instance.new("UIStroke", box)
            outline.Thickness = 0.5
            
            local nameLabel = Instance.new("TextLabel", esp)
            nameLabel.Size = UDim2.new(1, 0, 0, 14)
            nameLabel.Position = UDim2.new(0, 0, 0, -16)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextSize = 8
            nameLabel.Font = Enum.Font.GothamBold
            
            local hpBg = Instance.new("Frame", esp)
            hpBg.Size = UDim2.new(0, 2, 1, 0)
            hpBg.Position = UDim2.new(1.03, 0, 0, 0)
            hpBg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            hpBg.BorderSizePixel = 0
            local hpBar = Instance.new("Frame", hpBg)
            hpBar.Size = UDim2.new(1, 0, 1, 0)
            hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
            hpBar.BorderSizePixel = 0

            local chams = char:FindFirstChild("NL_Cham") or Instance.new("Highlight", char)
            chams.Name = "NL_Cham"
            chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            
            local skeletonLines = {}
            local bones = {
                {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
                {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
                {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
                {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
            }
            
            if hasDrawing then
                for i = 1, #bones do
                    local line = Drawing.new("Line")
                    line.Thickness = 1
                    line.Transparency = 0.8
                    table.insert(skeletonLines, line)
                end
            end
            
            local tracerLine = hasDrawing and Drawing.new("Line") or nil
            if tracerLine then tracerLine.Thickness = 0.4 tracerLine.Transparency = 0.6 end
            
            local conn
            conn = RunService.RenderStepped:Connect(function()
                if not player.Parent or not char.Parent or not esp.Parent then
                    if conn then conn:Disconnect() end
                    if tracerLine then tracerLine:Destroy() end
                    if chams then chams:Destroy() end
                    for _, line in pairs(skeletonLines) do line:Destroy() end
                    return
                end
                
                local active = Settings.ESP
                esp.Enabled = active
                chams.Enabled = active and Settings.ESP_Chams
                
                if active then
                    box.Visible = Settings.ESP_Boxes
                    nameLabel.Visible = Settings.ESP_Names
                    hpBg.Visible = Settings.ESP_HP
                    
                    local c = GetESPColor()
                    outline.Color = c
                    nameLabel.TextColor3 = c
                    chams.FillColor = c
                    chams.OutlineColor = Color3.fromRGB(255, 255, 255)
                    chams.FillTransparency = 0.5
                    
                    if hum.Parent then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        hpBar.Size = UDim2.new(1, 0, pct, 0)
                        hpBar.Position = UDim2.new(0, 0, 1 - pct, 0)
                    end
                    
                    if Settings.ESP_Skeleton then
                        for idx, joint in pairs(bones) do
                            local partA = char:FindFirstChild(joint[1])
                            local partB = char:FindFirstChild(joint[2])
                            local line = skeletonLines[idx]
                            if partA and partB and line then
                                local posA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
                                local posB, onScreenB = Camera:WorldToViewportPoint(partB.Position)
                                if onScreenA and onScreenB then
                                    line.From = Vector2.new(posA.X, posA.Y)
                                    line.To = Vector2.new(posB.X, posB.Y)
                                    line.Color = c
                                    line.Visible = true
                                else line.Visible = false end
                            elseif line then line.Visible = false end
                        end
                    else
                        for _, line in pairs(skeletonLines) do line.Visible = false end
                    end
                    
                    if tracerLine and Settings.ESP_Tracers then
                        local vec, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            tracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            tracerLine.To = Vector2.new(vec.X, vec.Y)
                            tracerLine.Color = c
                            tracerLine.Visible = true
                        else tracerLine.Visible = false end
                    elseif tracerLine then tracerLine.Visible = false end
                else
                    if tracerLine then tracerLine.Visible = false end
                    for _, line in pairs(skeletonLines) do line.Visible = false end
                end
            end)
        end
        if player.Character then SetupChar(player.Character) end
        player.CharacterAdded:Connect(SetupChar)
    end
    for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
    Players.PlayerAdded:Connect(CreateESP)

    -- Идеально центрированный FOV Circle (Починено)
    local FOVScreen = TargetGuiParent:FindFirstChild("FOV_Hold")
    if FOVScreen then FOVScreen:Destroy() end
    FOVScreen = Instance.new("ScreenGui", TargetGuiParent)
    FOVScreen.Name = "FOV_Hold"
    FOVScreen.ResetOnSpawn = false
    
    local circleFrame = Instance.new("Frame", FOVScreen)
    circleFrame.BackgroundTransparency = 1
    circleFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Привязка к абсолютному центру
    Instance.new("UICorner", circleFrame).CornerRadius = UDim.new(1, 0)
    local fovStroke = Instance.new("UIStroke", circleFrame)
    fovStroke.Thickness = 0.4
    
    RunService.RenderStepped:Connect(function()
        fovStroke.Color = GetESPColor()
        circleFrame.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        -- Позиционирование строго по центру Viewport, игнорируя Topbar лаги
        circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    end)

    -- ========== ИНТЕРФЕЙС МЕНЮ ==========
    local OldMenu = TargetGuiParent:FindFirstChild("NeverLose_Menu_Hold")
    if OldMenu then OldMenu:Destroy() end

    local MainGui = Instance.new("ScreenGui", TargetGuiParent)
    MainGui.Name = "NeverLose_Menu_Hold"
    MainGui.ResetOnSpawn = false -- Меню не пропадет при спавне!

    local FloatButton = Instance.new("TextButton", MainGui)
    FloatButton.Size = UDim2.new(0, 42, 0, 42)
    FloatButton.Position = UDim2.new(0, 15, 0.4, 0)
    FloatButton.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    FloatButton.Text = "NL"
    FloatButton.TextColor3 = Color3.fromRGB(0, 240, 255)
    FloatButton.Font = Enum.Font.GothamBold
    FloatButton.TextSize = 14
    Instance.new("UICorner", FloatButton).CornerRadius = UDim.new(1, 0)
    local fStroke = Instance.new("UIStroke", FloatButton)
    fStroke.Thickness = 1.2
    fStroke.Color = Color3.fromRGB(0, 240, 255)

    local function HandleAndroidDrag(gui, hitarea)
        local dragInput, dragStart, startPos
        hitarea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragStart = input.Position startPos = gui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragInput = nil end
                end)
            end
        end)
        hitarea.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput then
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    HandleAndroidDrag(FloatButton, FloatButton)

    local MenuFrame = Instance.new("Frame", MainGui)
    MenuFrame.Size = UDim2.new(0, 450, 0, 290)
    MenuFrame.Position = UDim2.new(0.5, -225, 0.5, -145)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    MenuFrame.BorderSizePixel = 0
    MenuFrame.Visible = false
    Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 6)
    local mStroke = Instance.new("UIStroke", MenuFrame)
    mStroke.Thickness = 1
    mStroke.Color = Color3.fromRGB(14, 19, 30)

    local Header = Instance.new("Frame", MenuFrame)
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.BackgroundTransparency = 1
    Header.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Header)
    Title.Text = "  NEVERLOSE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    local TitleDot = Instance.new("TextLabel", Header)
    TitleDot.Text = "." TitleDot.TextColor3 = Color3.fromRGB(0, 240, 255)
    TitleDot.Font = Enum.Font.GothamBold TitleDot.TextSize = 18
    TitleDot.Position = UDim2.new(0, 92, 0, -1) TitleDot.Size = UDim2.new(1, 0, 1, 0)
    TitleDot.TextXAlignment = Enum.TextXAlignment.Left
    TitleDot.BackgroundTransparency = 1

    HandleAndroidDrag(MenuFrame, Header)
    FloatButton.MouseButton1Click:Connect(function() MenuFrame.Visible = not MenuFrame.Visible end)

    local Sidebar = Instance.new("Frame", MenuFrame)
    Sidebar.Size = UDim2.new(0, 110, 1, -36)
    Sidebar.Position = UDim2.new(0, 0, 0, 36)
    Sidebar.BackgroundColor3 = Color3.fromRGB(5, 7, 10)
    Sidebar.BorderSizePixel = 0

    local ContentFrame = Instance.new("Frame", MenuFrame)
    ContentFrame.Size = UDim2.new(1, -118, 1, -44)
    ContentFrame.Position = UDim2.new(0, 114, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ClipsDescendants = true

    local Tabs = {}
    local TabButtons = {}

    local function CreateTab(name)
        local page = Instance.new("ScrollingFrame", ContentFrame)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(0, 240, 255)
        page.Visible = false
        local lay = Instance.new("UIListLayout", page)
        lay.Padding = UDim.new(0, 8)
        Tabs[name] = page
        return page
    end

    local aimbotTab = CreateTab("Aimbot")
    local visualsTab = CreateTab("Visuals")
    local miscTab = CreateTab("Misc")
    local cfgTab = CreateTab("Configs")

    local function ShowTab(tabName)
        for name, p in pairs(Tabs) do p.Visible = (name == tabName) end
        for name, b in pairs(TabButtons) do
            if name == tabName then
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
                b.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
            else
                b.TextColor3 = Color3.fromRGB(120, 125, 135)
                b.BackgroundColor3 = Color3.fromRGB(5, 7, 10)
            end
        end
    end

    local tabList = {"Aimbot", "Visuals", "Misc", "Configs"}
    for i, name in ipairs(tabList) do
        local b = Instance.new("TextButton", Sidebar)
        b.Size = UDim2.new(1, 0, 0, 32)
        b.Position = UDim2.new(0, 0, 0, (i-1)*32 + 6)
        b.BorderSizePixel = 0
        b.Text = "  " .. name:upper()
        b.TextColor3 = Color3.fromRGB(120, 125, 135)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 9
        b.TextXAlignment = Enum.TextXAlignment.Left
        TabButtons[name] = b
        b.MouseButton1Click:Connect(function() ShowTab(name) end)
    end
    ShowTab("Aimbot")

    -- ========== СТРУКТУРА ЭЛЕМЕНТОВ ==========
    local function CreateGroupBox(parent)
        local box = Instance.new("Frame", parent)
        box.Size = UDim2.new(1, -4, 0, 10)
        box.BackgroundColor3 = Color3.fromRGB(11, 14, 22)
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local bStr = Instance.new("UIStroke", box)
        bStr.Color = Color3.fromRGB(16, 22, 34)
        
        local lay = Instance.new("UIListLayout", box)
        lay.Padding = UDim.new(0, 6)
        Instance.new("UIPadding", box).PaddingTop = UDim.new(0, 8)
        box.UIPadding.PaddingBottom = UDim.new(0, 8)
        box.UIPadding.PaddingLeft = UDim.new(0, 8)
        box.UIPadding.PaddingRight = UDim.new(0, 8)
        
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            box.Size = UDim2.new(1, -4, 0, lay.AbsoluteContentSize.Y + 16)
        end)
        return box
    end

    local function CreateToggle(parent, text, key)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 20)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        
        local l = Instance.new("TextLabel", f)
        l.Text = text l.TextColor3 = Color3.fromRGB(200, 205, 215)
        l.Font = Enum.Font.GothamSemibold l.TextSize = 10
        l.Size = UDim2.new(0.75, 0, 1, 0) l.TextXAlignment = Enum.TextXAlignment.Left l.BackgroundTransparency = 1
        
        local toggleBg = Instance.new("TextButton", f)
        toggleBg.Size = UDim2.new(0, 28, 0, 14)
        toggleBg.Position = UDim2.new(1, -30, 0.5, -7)
        toggleBg.Text = ""
        toggleBg.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(20, 24, 35)
        toggleBg.BorderSizePixel = 0
        Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
        
        local circle = Instance.new("Frame", toggleBg)
        circle.Size = UDim2.new(0, 10, 0, 10)
        circle.Position = Settings[key] and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        
        local tStroke = Instance.new("UIStroke", toggleBg)
        tStroke.Color = Settings[key] and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(35, 42, 58)
        tStroke.Thickness = 0.8
        
        UI_Sync_Registry[key] = {
            Type = "Toggle",
            Bg = toggleBg,
            Circle = circle,
            Stroke = tStroke
        }
        
        toggleBg.MouseButton1Click:Connect(function()
            Settings[key] = not Settings[key]
            circle:TweenPosition(
                Settings[key] and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
                Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true
            )
            toggleBg.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(20, 24, 35)
            tStroke.Color = Settings[key] and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(35, 42, 58)
        end)
    end

    local function CreateSlider(parent, text, min, max, key)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, 30)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        
        local l = Instance.new("TextLabel", f)
        l.Text = text .. " (" .. tostring(Settings[key]) .. ")"
        l.TextColor3 = Color3.fromRGB(170, 175, 185) l.Font = Enum.Font.GothamSemibold l.TextSize = 9.5
        l.Size = UDim2.new(1, 0, 0, 12) l.TextXAlignment = Enum.TextXAlignment.Left l.BackgroundTransparency = 1
        
        local bg = Instance.new("Frame", f)
        bg.Size = UDim2.new(1, 0, 0, 4)
        bg.Position = UDim2.new(0, 0, 0, 18)
        bg.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
        bg.BorderSizePixel = 0
        Instance.new("UICorner", bg)
        
        local fill = Instance.new("Frame", bg)
        fill.Size = UDim2.new((Settings[key]-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill)
        
        local sliderKnob = Instance.new("Frame", fill)
        sliderKnob.Size = UDim2.new(0, 8, 0, 8)
        sliderKnob.Position = UDim2.new(1, -4, 0.5, -4)
        sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderKnob.BorderSizePixel = 0
        Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
        
        local trigger = Instance.new("TextButton", bg)
        trigger.Size = UDim2.new(1, 0, 4, 0) trigger.Position = UDim2.new(0, 0, -1.5, 0) 
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        
        UI_Sync_Registry[key] = {
            Type = "Slider",
            Fill = fill,
            Label = l,
            Text = text,
            Min = min,
            Max = max
        }
        
        local sliding = false
        local function update(inputPos)
            local pct = math.clamp((inputPos.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            local val = math.floor(min + (pct * (max - min)))
            Settings[key] = val
            l.Text = text .. " (" .. tostring(val) .. ")"
        end
        trigger.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true update(i.Position) end
        end)
        trigger.InputEnded:Connect(function() sliding = false end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i.Position) end
        end)
    end

    -- Наполнение меню
    local gAim = CreateGroupBox(aimbotTab)
    CreateToggle(gAim, "Active Camera Aimbot", "Enabled")
    CreateToggle(gAim, "Silent Aim (Bullet Hit Override)", "SilentAim")
    CreateToggle(gAim, "Wall Check (Visible Match)", "VisibleCheck")
    CreateToggle(gAim, "Triggerbot (Auto click)", "Triggerbot")
    CreateSlider(gAim, "Aim FOV Radius", 10, 800, "FOV")

    local gVis = CreateGroupBox(visualsTab)
    CreateToggle(gVis, "Global Overlay Active", "ESP")
    CreateToggle(gVis, "Player 2D Boxes", "ESP_Boxes")
    CreateToggle(gVis, "Snap Tracers Lines", "ESP_Tracers")
    CreateToggle(gVis, "Name Identification", "ESP_Names")
    CreateToggle(gVis, "Dynamic HP Bar", "ESP_HP")
    CreateToggle(gVis, "3D Player Chams", "ESP_Chams")
    CreateToggle(gVis, "Player Skeleton Model", "ESP_Skeleton")

    local gCol = CreateGroupBox(visualsTab)
    CreateSlider(gCol, "Theme Color: Red", 0, 255, "ESP_ColorR")
    CreateSlider(gCol, "Theme Color: Green", 0, 255, "ESP_ColorG")
    CreateSlider(gCol, "Theme Color: Blue", 0, 255, "ESP_ColorB")

    local gMisc = CreateGroupBox(miscTab)
    CreateToggle(gMisc, "Wallshot Pro (Inject Bullet)", "Wallshot")
    CreateToggle(gMisc, "Rapid Fire (Cooldown Bypass)", "RapidFire")
    CreateToggle(gMisc, "Walk on Air Mode", "WalkOnAir")
    CreateToggle(gMisc, "Global Spammer Chat", "ChatSpam")
    CreateToggle(gMisc, "Force Third Person Mode", "ThirdPerson")
    CreateSlider(gMisc, "Third Person Distance", 5, 50, "ThirdPersonDist")
    CreateToggle(gMisc, "SpeedHack Modifier", "SpeedHack")
    CreateSlider(gMisc, "Speed Multiplier Value", 16, 250, "SpeedValue")
    CreateToggle(gMisc, "Noclip Matrix Pass", "Noclip")
    CreateToggle(gMisc, "Fly Frame Camera", "Fly")
    CreateSlider(gMisc, "Fly Speed Multiplier", 10, 150, "FlySpeed")
    CreateToggle(gMisc, "Infinite Tool Magazine", "InfAmmo")
    CreateToggle(gMisc, "Auto Reload Gun Hack", "AutoReload")
    CreateToggle(gMisc, "Perfect Anti-Recoil Vector", "NoRecoil")
    CreateToggle(gMisc, "Undetected GodMode", "GodMode")
    CreateToggle(gMisc, "BunnyHop Engine Hack", "Bhop")
    CreateSlider(gMisc, "Bhop Speed Value Force", 16, 120, "BhopSpeed")

    local gCfg = CreateGroupBox(cfgTab)
    local sBtn = Instance.new("TextButton", gCfg)
    sBtn.Size = UDim2.new(1, 0, 0, 26) sBtn.Text = "SAVE NEVERLOSE CONFIG" sBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
    sBtn.Font = Enum.Font.GothamBold sBtn.TextColor3 = Color3.fromRGB(255,255,255) sBtn.TextSize = 10
    Instance.new("UICorner", sBtn)
    sBtn.MouseButton1Click:Connect(SaveConfig)

    local lBtn = Instance.new("TextButton", gCfg)
    lBtn.Size = UDim2.new(1, 0, 0, 26) lBtn.Text = "LOAD SAVED CONFIG" lBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
    lBtn.Font = Enum.Font.GothamBold lBtn.TextColor3 = Color3.fromRGB(255,255,255) lBtn.TextSize = 10
    Instance.new("UICorner", lBtn)
    local lStroke = Instance.new("UIStroke", lBtn) lStroke.Color = Color3.fromRGB(0, 240, 255)
    lBtn.MouseButton1Click:Connect(LoadConfig)
    -- ========== КОД ЧИТА (КОНЕЦ) ==========
end

-- ========== ИНТЕРФЕЙС СИСТЕМЫ КЛЮЧЕЙ ==========
local KeyGui = Instance.new("ScreenGui", TargetGuiParent)
KeyGui.Name = "NL_KeySystem_Hold"
KeyGui.ResetOnSpawn = false -- Защита от удаления при смерти до ввода ключа

local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.new(0, 320, 0, 190)
KeyFrame.Position = UDim2.new(0.5, -160, 0.5, -95)
KeyFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 8)
local kStroke = Instance.new("UIStroke", KeyFrame)
kStroke.Thickness = 1.2
kStroke.Color = Color3.fromRGB(16, 22, 34)

local KTitle = Instance.new("TextLabel", KeyFrame)
KTitle.Size = UDim2.new(1, 0, 0, 40)
KTitle.BackgroundTransparency = 1
KTitle.Text = "NEVERLOSE Key System"
KTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KTitle.Font = Enum.Font.GothamBold
KTitle.TextSize = 14

local TextBoxBg = Instance.new("Frame", KeyFrame)
TextBoxBg.Size = UDim2.new(0.9, 0, 0, 35)
TextBoxBg.Position = UDim2.new(0.05, 0, 0, 45)
TextBoxBg.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
Instance.new("UICorner", TextBoxBg).CornerRadius = UDim.new(0, 5)
local tBoxStroke = Instance.new("UIStroke", TextBoxBg)
tBoxStroke.Color = Color3.fromRGB(20, 28, 42)

local KeyInput = Instance.new("TextBox", TextBoxBg)
KeyInput.Size = UDim2.new(1, -10, 1, 0)
KeyInput.Position = UDim2.new(0, 5, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.PlaceholderText = "Paste License Key Here..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 105, 115)
KeyInput.Font = Enum.Font.GothamSemibold
KeyInput.TextSize = 11

local SubmitBtn = Instance.new("TextButton", KeyFrame)
SubmitBtn.Size = UDim2.new(0.42, 0, 0, 30)
SubmitBtn.Position = UDim2.new(0.05, 0, 0, 95)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
SubmitBtn.Text = "SUBMIT KEY"
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 10
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 4)

local GetKeyBtn = Instance.new("TextButton", KeyFrame)
GetKeyBtn.Size = UDim2.new(0.42, 0, 0, 30)
GetKeyBtn.Position = UDim2.new(0.53, 0, 0, 95)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
GetKeyBtn.Text = "COPY CONTACT"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextColor3 = Color3.fromRGB(0, 240, 255)
GetKeyBtn.TextSize = 10
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 4)
local gKeyStroke = Instance.new("UIStroke", GetKeyBtn)
gKeyStroke.Color = Color3.fromRGB(0, 240, 255)
gKeyStroke.Thickness = 0.8

local StatusLabel = Instance.new("TextLabel", KeyFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 145)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Waiting for license verification..."
StatusLabel.TextColor3 = Color3.fromRGB(120, 125, 135)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 9.5

-- Перетаскивание окна ключей
local dragInput, dragStart, startPos
KeyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position startPos = KeyFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragInput = nil end
        end)
    end
end)
KeyFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput then
        local delta = input.Position - dragStart
        KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Копирование контактов продавца
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(BuyContact)
        StatusLabel.Text = "Seller contact copied to clipboard!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
    else
        StatusLabel.Text = "Clipboard not supported. Contact: " .. BuyContact
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Логика верификации
SubmitBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Connecting to auth server..."
    StatusLabel.TextColor3 = Color3.fromRGB(150, 155, 165)
    
    task.spawn(function()
        local success, keysList = pcall(function()
            return game:HttpGet(KeysURL)
        end)
        
        if not success then
            StatusLabel.Text = "Error: Failed to fetch key database!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        local userKey = KeyInput.Text:gsub("%s+", "")
        if userKey == "" then
            StatusLabel.Text = "Please enter a key first."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
            return
        end
        
        local keyValid = false
        for line in keysList:gmatch("[^\r\n]+") do
            if line:gsub("%s+", "") == userKey then
                keyValid = true
                break
            end
        end
        
        if keyValid then
            StatusLabel.Text = "Access Granted! Loading NeverLose v3..."
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
            task.wait(1.2)
            KeyGui:Destroy()
            StartCheat()
        else
            StatusLabel.Text = "Invalid or expired key."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
        end
    end)
end)
