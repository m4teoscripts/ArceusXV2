--[[
    ArceusUI V2
    Custom UI Library
    Designed for Arceus X / Roblox client environments

    Features:
        Window
        Tabs
        Sections
        Buttons
        Toggles
        Sliders
        Dropdowns
        Textboxes
        Keybinds
        ColorPickers
        Labels
        Paragraphs
        Notifications
        RGB borders
        Minimize
        Destroy
        Dragging
        Animations
        Mobile friendly
        Scrolling
        Theme support
]]

local ArceusUI = {}
ArceusUI.__index = ArceusUI

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Environment
local Parent

pcall(function()
    if gethui then
        Parent = gethui()
    end
end)

Parent = Parent or CoreGui

--// Settings
local Settings = {
    Theme = {
        Background = Color3.fromRGB(20, 20, 23),
        Secondary = Color3.fromRGB(27, 27, 31),
        Tertiary = Color3.fromRGB(34, 34, 39),
        Text = Color3.fromRGB(245, 245, 245),
        SubText = Color3.fromRGB(165, 165, 170),
        Accent = Color3.fromRGB(95, 120, 255),
        AccentDark = Color3.fromRGB(65, 85, 200),
        Stroke = Color3.fromRGB(55, 55, 62)
    },

    AnimationSpeed = 0.18,
    RGBSpeed = 1.5,
    SoundEnabled = true
}

local function Tween(object, properties, duration, style, direction)
    duration = duration or Settings.AnimationSpeed

    local info = TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(object, info, properties)
    tween:Play()

    return tween
end

local function Corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = object
    return c
end

local function Stroke(object, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Settings.Theme.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = object
    return s
end

local function Padding(object, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = object
    return p
end

local function MakeText(parent, text, size, color, font)
    local label = Instance.new("TextLabel")

    label.BackgroundTransparency = 1
    label.Text = tostring(text or "")
    label.TextSize = size or 14
    label.TextColor3 = color or Settings.Theme.Text
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent

    return label
end

local function SafeCallback(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end

    task.spawn(function()
        local success, err = pcall(callback, ...)
        if not success then
            warn("[ArceusUI Callback Error]:", err)
        end
    end)
end

--// Sound
local function ClickSound()
    if not Settings.SoundEnabled then
        return
    end

    local sound

    pcall(function()
        sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6895079853"
        sound.Volume = 0.25
        sound.Parent = Parent
        sound:Play()

        task.delay(1, function()
            if sound then
                sound:Destroy()
            end
        end)
    end)
end

--// RGB
local function StartRGB(stroke)
    local connection

    connection = RunService.RenderStepped:Connect(function()
        if not stroke or not stroke.Parent then
            if connection then
                connection:Disconnect()
            end
            return
        end

        local hue = (tick() * Settings.RGBSpeed % 5) / 5
        stroke.Color = Color3.fromHSV(hue, 0.9, 1)
    end)

    return connection
end

--// Destroy old GUI
pcall(function()
    local old = Parent:FindFirstChild("ArceusUI")
    if old then
        old:Destroy()
    end
end)

--// Window
function ArceusUI:CreateWindow(config)
    config = config or {}

    local WindowObject = {}
    WindowObject.__index = WindowObject

    WindowObject.Name = config.Name or config.Title or "ArceusUI"
    WindowObject.Subtitle = config.Subtitle or "Arceus X"
    WindowObject.RGB = config.RGB == true
    WindowObject.Destroyed = false
    WindowObject.Tabs = {}
    WindowObject.CurrentTab = nil

    --// ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ArceusUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = Parent

    WindowObject.ScreenGui = ScreenGui

    --// Main
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.fromOffset(
        config.Width or 570,
        config.Height or 390
    )
    Main.Position = UDim2.new(0.5, -(config.Width or 570) / 2, 0.5, -(config.Height or 390) / 2)
    Main.BackgroundColor3 = Settings.Theme.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    Corner(Main, 12)

    local MainStroke = Stroke(
        Main,
        Settings.Theme.Stroke,
        1
    )

    WindowObject.Main = Main
    WindowObject.MainStroke = MainStroke

    if WindowObject.RGB then
        StartRGB(MainStroke)
    end

    --// Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 5)
    Shadow.Size = UDim2.new(1, 45, 1, 45)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageTransparency = 0.55
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex = -1
    Shadow.Parent = Main

    --// Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 58)
    Topbar.BackgroundColor3 = Settings.Theme.Secondary
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    --// Title
    local Title = MakeText(
        Topbar,
        WindowObject.Name,
        15,
        Settings.Theme.Text,
        Enum.Font.GothamBold
    )

    Title.Position = UDim2.fromOffset(18, 7)
    Title.Size = UDim2.new(1, -125, 0, 23)

    local Subtitle = MakeText(
        Topbar,
        WindowObject.Subtitle,
        11,
        Settings.Theme.SubText,
        Enum.Font.Gotham
    )

    Subtitle.Position = UDim2.fromOffset(18, 30)
    Subtitle.Size = UDim2.new(1, -125, 0, 18)

    --// Minimize
    local Minimize = Instance.new("TextButton")
    Minimize.Name = "Minimize"
    Minimize.Size = UDim2.fromOffset(32, 32)
    Minimize.Position = UDim2.new(1, -76, 0, 13)
    Minimize.BackgroundColor3 = Settings.Theme.Tertiary
    Minimize.Text = "—"
    Minimize.TextSize = 16
    Minimize.TextColor3 = Settings.Theme.Text
    Minimize.Font = Enum.Font.GothamBold
    Minimize.AutoButtonColor = false
    Minimize.Parent = Topbar

    Corner(Minimize, 8)

    --// Close
    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Size = UDim2.fromOffset(32, 32)
    Close.Position = UDim2.new(1, -38, 0, 13)
    Close.BackgroundColor3 = Settings.Theme.Tertiary
    Close.Text = "×"
    Close.TextSize = 18
    Close.TextColor3 = Settings.Theme.Text
    Close.Font = Enum.Font.GothamBold
    Close.AutoButtonColor = false
    Close.Parent = Topbar

    Corner(Close, 8)

    --// Tab bar
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "Tabs"
    TabBar.Size = UDim2.new(1, 0, 0, 43)
    TabBar.Position = UDim2.fromOffset(0, 58)
    TabBar.BackgroundColor3 = Settings.Theme.Background
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 0
    TabBar.ScrollingDirection = Enum.ScrollingDirection.X
    TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabBar.CanvasSize = UDim2.new()
    TabBar.Parent = Main

    Padding(TabBar, 10, 10, 5, 5)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabBar

    --// Content
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 1, -111)
    Content.Position = UDim2.fromOffset(10, 101)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    WindowObject.Content = Content
    WindowObject.TabBar = TabBar

    --// Minimized button
    local MiniButton = Instance.new("TextButton")
    MiniButton.Name = "ArceusUI_Minimized"
    MiniButton.Size = UDim2.fromOffset(48, 48)
    MiniButton.Position = UDim2.new(0, 18, 0.5, -24)
    MiniButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MiniButton.Text = "UI"
    MiniButton.TextSize = 13
    MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniButton.Font = Enum.Font.GothamBold
    MiniButton.Visible = false
    MiniButton.AutoButtonColor = false
    MiniButton.Parent = ScreenGui

    Corner(MiniButton, 15)

    local MiniStroke = Stroke(
        MiniButton,
        Settings.Theme.Accent,
        2
    )

    if WindowObject.RGB then
        StartRGB(MiniStroke)
    end

    WindowObject.MiniButton = MiniButton

    --// Dragging
    local dragging = false
    local dragStart
    local startPos

    local function UpdateDrag(input)
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            UpdateDrag(input)
        end
    end)

    --// Minimize
    local minimized = false

    local function MinimizeWindow()
        if minimized then
            return
        end

        minimized = true

        Tween(
            Main,
            {
                Size = UDim2.fromOffset(0, 0),
                BackgroundTransparency = 1
            },
            0.22
        )

        task.delay(0.2, function()
            if Main then
                Main.Visible = false
            end

            MiniButton.Visible = true
            MiniButton.Size = UDim2.fromOffset(0, 0)

            Tween(
                MiniButton,
                {
                    Size = UDim2.fromOffset(48, 48)
                },
                0.22,
                Enum.EasingStyle.Back
            )
        end)
    end

    local function RestoreWindow()
        if not minimized then
            return
        end

        minimized = false

        Tween(
            MiniButton,
            {
                Size = UDim2.fromOffset(0, 0)
            },
            0.16
        )

        task.delay(0.16, function()
            MiniButton.Visible = false
            Main.Visible = true

            Main.Size = UDim2.fromOffset(0, 0)
            Main.BackgroundTransparency = 1

            Tween(
                Main,
                {
                    Size = UDim2.fromOffset(
                        config.Width or 570,
                        config.Height or 390
                    ),
                    BackgroundTransparency = 0
                },
                0.25,
                Enum.EasingStyle.Back
            )
        end)
    end

    Minimize.MouseButton1Click:Connect(function()
        ClickSound()
        MinimizeWindow()
    end)

    MiniButton.MouseButton1Click:Connect(function()
        ClickSound()
        RestoreWindow()
    end)

    --// Close
    Close.MouseButton1Click:Connect(function()
        ClickSound()

        Tween(
            Main,
            {
                Size = UDim2.fromOffset(0, 0),
                BackgroundTransparency = 1
            },
            0.2
        )

        task.delay(0.2, function()
            if ScreenGui then
                ScreenGui:Destroy()
            end

            WindowObject.Destroyed = true
        end)
    end)

    --// Hover effects
    local function Hover(button)
        local original = button.BackgroundColor3

        button.MouseEnter:Connect(function()
            Tween(button, {
                BackgroundColor3 = Settings.Theme.Stroke
            }, 0.12)
        end)

        button.MouseLeave:Connect(function()
            Tween(button, {
                BackgroundColor3 = original
            }, 0.12)
        end)
    end

    Hover(Minimize)
    Hover(Close)

    --// Notification
    function WindowObject:Notify(data)
        data = data or {}

        local notification = Instance.new("Frame")
        notification.Size = UDim2.fromOffset(280, 75)
        notification.Position = UDim2.new(1, 20, 1, -95)
        notification.BackgroundColor3 = Settings.Theme.Secondary
        notification.BorderSizePixel = 0
        notification.Parent = ScreenGui

        Corner(notification, 10)

        local ns = Stroke(
            notification,
            Settings.Theme.Stroke,
            1
        )

        local nt = MakeText(
            notification,
            data.Title or "Notification",
            14,
            Settings.Theme.Text,
            Enum.Font.GothamBold
        )

        nt.Position = UDim2.fromOffset(14, 9)
        nt.Size = UDim2.new(1, -28, 0, 22)

        local nd = MakeText(
            notification,
            data.Content or "",
            11,
            Settings.Theme.SubText,
            Enum.Font.Gotham
        )

        nd.Position = UDim2.fromOffset(14, 31)
        nd.Size = UDim2.new(1, -28, 0, 34)
        nd.TextWrapped = true

        if WindowObject.RGB then
            StartRGB(ns)
        end

        Tween(
            notification,
            {
                Position = UDim2.new(1, -295, 1, -95)
            },
            0.25,
            Enum.EasingStyle.Back
        )

        task.delay(data.Duration or 3, function()
            if notification and notification.Parent then
                Tween(
                    notification,
                    {
                        Position = UDim2.new(1, 20, 1, -95)
                    },
                    0.2
                )

                task.delay(0.2, function()
                    if notification then
                        notification:Destroy()
                    end
                end)
            end
        end)
    end

    --// Destroy
    function WindowObject:Destroy()
        if WindowObject.Destroyed then
            return
        end

        WindowObject.Destroyed = true

        if ScreenGui then
            ScreenGui:Destroy()
        end
    end

    --// Toggle UI
    function WindowObject:SetVisibility(value)
        if value then
            RestoreWindow()
        else
            MinimizeWindow()
        end
    end

    --// Tab
    function WindowObject:CreateTab(name, icon)
        local Tab = {}
        Tab.__index = Tab

        Tab.Name = name or "Tab"
        Tab.Elements = {}

        -- Tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Tab.Name
        TabButton.Size = UDim2.fromOffset(105, 32)
        TabButton.BackgroundColor3 = Settings.Theme.Background
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabBar

        Corner(TabButton, 8)

        local Icon = MakeText(
            TabButton,
            icon and tostring(icon) or "",
            13,
            Settings.Theme.SubText,
            Enum.Font.GothamBold
        )

        Icon.Position = UDim2.fromOffset(8, 0)
        Icon.Size = UDim2.fromOffset(20, 32)
        Icon.TextXAlignment = Enum.TextXAlignment.Center

        local TabText = MakeText(
            TabButton,
            Tab.Name,
            11,
            Settings.Theme.SubText,
            Enum.Font.GothamMedium
        )

        TabText.Position = UDim2.fromOffset(
            icon and 30 or 10,
            0
        )

        TabText.Size = UDim2.new(
            1,
            icon and -35 or -15,
            1,
            0
        )

        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Tab.Name .. "_Page"
        Page.Size = UDim2.fromScale(1, 1)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Settings.Theme.Accent
        Page.CanvasSize = UDim2.new()
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Page.Visible = false
        Page.Parent = Content

        Padding(Page, 4, 4, 4, 10)

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 7)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Page

        Tab.Button = TabButton
        Tab.Page = Page
        Tab.Layout = Layout

        function Tab:Select()
            for _, other in pairs(WindowObject.Tabs) do
                if other ~= Tab then
                    other.Page.Visible = false

                    Tween(
                        other.Button,
                        {
                            BackgroundColor3 = Settings.Theme.Background
                        },
                        0.12
                    )

                    other.TabText.TextColor3 = Settings.Theme.SubText
                    other.Icon.TextColor3 = Settings.Theme.SubText
                end
            end

            Page.Visible = true

            Tween(
                TabButton,
                {
                    BackgroundColor3 = Settings.Theme.Tertiary
                },
                0.12
            )

            TabText.TextColor3 = Settings.Theme.Text
            Icon.TextColor3 = Settings.Theme.Accent

            WindowObject.CurrentTab = Tab
        end

        TabButton.MouseButton1Click:Connect(function()
            ClickSound()
            Tab:Select()
        end)

        TabButton.MouseEnter:Connect(function()
            if WindowObject.CurrentTab ~= Tab then
                Tween(TabButton, {
                    BackgroundColor3 = Settings.Theme.Secondary
                }, 0.1)
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if WindowObject.CurrentTab ~= Tab then
                Tween(TabButton, {
                    BackgroundColor3 = Settings.Theme.Background
                }, 0.1)
            end
        end)

        --// Section
        function Tab:CreateSection(text)
            local Section = Instance.new("TextLabel")
            Section.Name = "Section"
            Section.Size = UDim2.new(1, -8, 0, 27)
            Section.BackgroundTransparency = 1
            Section.Text = tostring(text or "Section")
            Section.TextColor3 = Settings.Theme.Accent
            Section.TextSize = 12
            Section.Font = Enum.Font.GothamBold
            Section.TextXAlignment = Enum.TextXAlignment.Left
            Section.Parent = Page

            return Section
        end

        --// Label
        function Tab:CreateLabel(text)
            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -8, 0, 35)
            Holder.BackgroundColor3 = Settings.Theme.Secondary
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, 8)

            local Label = MakeText(
                Holder,
                text,
                12,
                Settings.Theme.SubText
            )

            Label.Position = UDim2.fromOffset(12, 0)
            Label.Size = UDim2.new(1, -24, 1, 0)

            local Object = {}

            function Object:Set(value)
                Label.Text = tostring(value)
            end

            return Object
        end

        --// Paragraph
        function Tab:CreateParagraph(data)
            data = data or {}

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -8, 0, 65)
            Holder.BackgroundColor3 = Settings.Theme.Secondary
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, 8)

            local PT = MakeText(
                Holder,
                data.Title or "Paragraph",
                12,
                Settings.Theme.Text,
                Enum.Font.GothamBold
            )

            PT.Position = UDim2.fromOffset(12, 7)
            PT.Size = UDim2.new(1, -24, 0, 20)

            local PC = MakeText(
                Holder,
                data.Content or "",
                11,
                Settings.Theme.SubText
            )

            PC.Position = UDim2.fromOffset(12, 28)
            PC.Size = UDim2.new(1, -24, 0, 30)
            PC.TextWrapped = true

            local Object = {}

            function Object:Set(data2)
                data2 = data2 or {}

                if data2.Title then
                    PT.Text = tostring(data2.Title)
                end

                if data2.Content then
                    PC.Text = tostring(data2.Content)
                end
            end

            return Object
        end

        --// Button
        function Tab:CreateButton(data)
            data = data or {}

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -8, 0, 40)
            Button.BackgroundColor3 = Settings.Theme.Secondary
            Button.BorderSizePixel = 0
            Button.Text = ""
            Button.AutoButtonColor = false
            Button.Parent = Page

            Corner(Button, 8)

            local BS = Stroke(
                Button,
                Settings.Theme.Stroke,
                1
            )

            local BT = MakeText(
                Button,
                data.Name or "Button",
                12,
                Settings.Theme.Text,
                Enum.Font.GothamMedium
            )

            BT.Position = UDim2.fromOffset(13, 0)
            BT.Size = UDim2.new(1, -26, 1, 0)

            Button.MouseEnter:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Settings.Theme.Tertiary
                }, 0.1)
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Settings.Theme.Secondary
                }, 0.1)
            end)

            Button.MouseButton1Click:Connect(function()
                ClickSound()

                Tween(Button, {
                    Size = UDim2.new(1, -12, 0, 38)
                }, 0.06)

                task.delay(0.06, function()
                    Tween(Button, {
                        Size = UDim2.new(1, -8, 0, 40)
                    }, 0.08)
                end)

                SafeCallback(data.Callback)
            end)

            local Object = {}

            function Object:SetText(value)
                BT.Text = tostring(value)
            end

            return Object
        end

        --// Toggle
        function Tab:CreateToggle(data)
            data = data or {}

            local Value = data.CurrentValue == true

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -8, 0, 48)
            Holder.BackgroundColor3 = Settings.Theme.Secondary
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, 8)

            local Label = MakeText(
                Holder,
                data.Name or "Toggle",
                12,
                Settings.Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(13, 0)
            Label.Size = UDim2.new(1, -75, 1, 0)

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.fromOffset(40, 22)
            Switch.Position = UDim2.new(1, -53, 0.5, -11)
            Switch.BackgroundColor3 = Value
                and Settings.Theme.Accent
                or Settings.Theme.Tertiary
            Switch.BorderSizePixel = 0
            Switch.Parent = Holder

            Corner(Switch, 12)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.fromOffset(16, 16)
            Knob.Position = Value
                and UDim2.new(1, -19, 0.5, -8)
                or UDim2.fromOffset(3, 3)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.Parent = Switch

            Corner(Knob, 10)

            local Click = Instance.new("TextButton")
            Click.BackgroundTransparency = 1
            Click.Size = UDim2.fromScale(1, 1)
            Click.Text = ""
            Click.Parent = Holder

            local function SetValue(newValue, callback)
                Value = newValue == true

                Tween(
                    Switch,
                    {
                        BackgroundColor3 = Value
                            and Settings.Theme.Accent
                            or Settings.Theme.Tertiary
                    },
                    0.15
                )

                Tween(
                    Knob,
                    {
                        Position = Value
                            and UDim2.new(1, -19, 0.5, -8)
                            or UDim2.fromOffset(3, 3)
                    },
                    0.15
                )

                if callback ~= false then
                    SafeCallback(data.Callback, Value)
                end
            end

            Click.MouseButton1Click:Connect(function()
                ClickSound()
                SetValue(not Value)
            end)

            local Object = {}

            function Object:Set(value)
                SetValue(value)
            end

            function Object:Get()
                return Value
            end

            return Object
        end

        --// Slider
        function Tab:CreateSlider(data)
            data = data or {}

            local Range = data.Range or {0, 100}
            local Min = tonumber(Range[1]) or 0
            local Max = tonumber(Range[2]) or 100
            local Increment = tonumber(data.Increment) or 1
            local Value = tonumber(data.CurrentValue) or Min

            Value = math.clamp(Value, Min, Max)

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -8, 0, 62)
            Holder.BackgroundColor3 = Settings.Theme.Secondary
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, 8)

            local Label = MakeText(
                Holder,
                data.Name or "Slider",
                12,
                Settings.Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(13, 4)
            Label.Size = UDim2.new(1, -80, 0, 23)

            local ValueLabel = MakeText(
                Holder,
                tostring(Value),
                11,
                Settings.Theme.Accent,
                Enum.Font.GothamBold
            )

            ValueLabel.Position = UDim2.new(1, -65, 0, 4)
            ValueLabel.Size = UDim2.fromOffset(52, 23)
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -26, 0, 6)
            Bar.Position = UDim2.fromOffset(13, 40)
            Bar.BackgroundColor3 = Settings.Theme.Tertiary
            Bar.BorderSizePixel = 0
            Bar.Parent = Holder

            Corner(Bar, 6)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(
                (Value - Min) / (Max - Min),
                0,
                1,
                0
            )
            Fill.BackgroundColor3 = Settings.Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar

            Corner(Fill, 6)

            local draggingSlider = false

            local function SetValue(NewValue, callback)
                NewValue = math.clamp(NewValue, Min, Max)

                if Increment > 0 then
                    NewValue =
                        math.floor(
                            ((NewValue - Min) / Increment) + 0.5
                        ) * Increment + Min
                end

                NewValue = math.clamp(NewValue, Min, Max)

                Value = NewValue

                local percent =
                    (Value - Min) /
                    math.max(Max - Min, 0.0001)

                Tween(
                    Fill,
                    {
                        Size = UDim2.new(percent, 0, 1, 0)
                    },
                    0.08
                )

                ValueLabel.Text = tostring(Value)

                if callback ~= false then
                    SafeCallback(data.Callback, Value)
                end
            end

            local function UpdateSlider(input)
                local percent =
                    (input.Position.X - Bar.AbsolutePosition.X) /
                    Bar.AbsoluteSize.X

                percent = math.clamp(percent, 0, 1)

                local newValue =
                    Min + (Max - Min) * percent

                SetValue(newValue)
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    draggingSlider = true
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                ) then
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            local Object = {}

            function Object:Set(value)
                SetValue(tonumber(value) or Min)
            end

            function Object:Get()
                return Value
            end

            return Object
        end

        --// Dropdown
        function Tab:CreateDropdown(data)
            data = data or {}

            local Options = data.Options or {}
            local Current = data.CurrentOption or Options[1]

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -8, 0, 45)
            Holder.BackgroundColor3 = Settings.Theme.Secondary
            Holder.BorderSizePixel = 0
            Holder.ClipsDescendants = true
            Holder.Parent = Page

            Corner(Holder, 8)

            local MainButton = Instance.new("TextButton")
            MainButton.Size = UDim2.new(1, 0, 0, 45)
            MainButton.BackgroundTransparency = 1
            MainButton.Text = ""
            MainButton.Parent = Holder

            local Label = MakeText(
                MainButton,
                data.Name or "Dropdown",
                12,
                Settings.Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(13, 0)
            Label.Size = UDim2.new(0.5, 0, 1, 0)

            local Selected = MakeText(
                MainButton,
                tostring(Current or ""),
                11,
                Settings.Theme.Accent,
                Enum.Font.GothamMedium
            )

            Selected.Position = UDim2.new(0.5, 0, 0, 0)
            Selected.Size = UDim2.new(0.43, -10, 1, 0)
            Selected.TextXAlignment = Enum.TextXAlignment.Right

            local Arrow = MakeText(
                MainButton,
                "▼",
                10,
                Settings.Theme.SubText,
                Enum.Font.GothamBold
            )

            Arrow.Position = UDim2.new(1, -27, 0, 0)
            Arrow.Size = UDim2.fromOffset(18, 45)
            Arrow.TextXAlignment = Enum.TextXAlignment.Center

            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Position = UDim2.fromOffset(8, 45)
            OptionsFrame.Size = UDim2.new(1, -16, 0, 0)
            OptionsFrame.BackgroundColor3 = Settings.Theme.Tertiary
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.Parent = Holder

            Corner(OptionsFrame, 7)

            local OptionLayout = Instance.new("UIListLayout")
            OptionLayout.Padding = UDim.new(0, 3)
            OptionLayout.Parent = OptionsFrame

            local open = false

            local function Refresh()
                for _, child in pairs(OptionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                for _, option in ipairs(Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Size = UDim2.new(1, 0, 0, 31)
                    OptionButton.BackgroundColor3 = Settings.Theme.Tertiary
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Text = tostring(option)
                    OptionButton.TextColor3 = Settings.Theme.Text
                    OptionButton.TextSize = 11
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.AutoButtonColor = false
                    OptionButton.Parent = OptionsFrame

                    OptionButton.MouseEnter:Connect(function()
                        Tween(
                            OptionButton,
                            {
                                BackgroundColor3 = Settings.Theme.Stroke
                            },
                            0.1
                        )
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        Tween(
                            OptionButton,
                            {
                                BackgroundColor3 = Settings.Theme.Tertiary
                            },
                            0.1
                        )
                    end)

                    OptionButton.MouseButton1Click:Connect(function()
                        Current = option
                        Selected.Text = tostring(option)

                        SafeCallback(
                            data.Callback,
                            option
                        )

                        ClickSound()

                        open = false

                        Tween(
                            Holder,
                            {
                                Size = UDim2.new(1, -8, 0, 45)
                            },
                            0.16
                        )

                        Tween(
                            OptionsFrame,
                            {
                                Size = UDim2.new(1, -16, 0, 0)
                            },
                            0.16
                        )

                        Arrow.Text = "▼"
                    end)
                end
            end

            Refresh()

            MainButton.MouseButton1Click:Connect(function()
                ClickSound()

                open = not open

                local height =
                    math.min(#Options * 34 + 6, 150)

                if open then
                    Arrow.Text = "▲"

                    Tween(
                        Holder,
                        {
                            Size = UDim2.new(
                                1,
                                -8,
                                0,
                                45 + height
                            )
                        },
                        0.18
                    )

                    Tween(
                        OptionsFrame,
                        {
                            Size = UDim2.new(
                                1,
                                -16,
                                0,
                                height
                            )
                        },
                        0.18
                    )
                else
                    Arrow.Text = "▼"

                    Tween(
                        Holder,
                        {
                            Size = UDim2.new(1, -8, 0, 45)
                        },
                        0.18
                    )

                    Tween(
                        OptionsFrame,
                        {
                            Size = UDim2.new(1, -16, 0, 0)
                        },
                        0.18
                    )
                end
            end)

            local Object = {}

            function Object:Set(option)
                if table.find(Options, option) then
                    Current = option
                    Selected.Text = tostring(option)
                    SafeCallback(data.Callback, option)
                end
            end

            function Object:SetOptions(newOptions)
                Options = newOptions or {}
                Refresh()
            end

            function Object:Get()
                return Current
            end

            return Object
        end

        --// Input
        function Tab:CreateInput(data)
            data = data or {}

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -8, 0, 48)
            Holder.BackgroundColor3 = Settings.Theme.Secondary
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, 8)

            local Label = MakeText(
                Holder,
                data.Name or "Input",
                12,
                Settings.Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(13, 0)
            Label.Size = UDim2.new(0.45, 0, 1, 0)

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(0.48, 0, 0, 32)
            Box.Position = UDim2.new(0.5, 0, 0.5, -16)
            Box.BackgroundColor3 = Settings.Theme.Tertiary
            Box.BorderSizePixel = 0
            Box.Text = data.CurrentValue or ""
            Box.PlaceholderText = data.PlaceholderText or "Enter text..."
            Box.PlaceholderColor3 = Settings.Theme.SubText
            Box.TextColor3 = Settings.Theme.Text
            Box.TextSize = 11
            Box.Font = Enum.Font.Gotham
            Box.ClearTextOnFocus = data.ClearTextOnFocus == true
            Box.Parent = Holder

            Corner(Box, 7)

            Padding(Box, 9, 9, 0, 0)

            Box.FocusLost:Connect(function()
                SafeCallback(
                    data.Callback,
                    Box.Text
                )
            end)

            local Object = {}

            function Object:Set(value)
                Box.Text = tostring(value)
            end

            function Object:Get()
                return Box.Text
            end

            return Object
        end

        --// Keybind
        function Tab:CreateKeybind(data)
            data = data or {}

            local CurrentKey = data.CurrentKeybind or Enum.KeyCode.RightShift
            local Listening = false

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -8, 0, 48)
            Holder.BackgroundColor3 = Settings.Theme.Secondary
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, 8)

            local Label = MakeText(
                Holder,
                data.Name or "Keybind",
                12,
                Settings.Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(13, 0)
            Label.Size = UDim2.new(1, -125, 1, 0)

            local KeyButton = Instance.new("TextButton")
            KeyButton.Size = UDim2.fromOffset(95, 31)
            KeyButton.Position = UDim2.new(1, -107, 0.5, -15)
            KeyButton.BackgroundColor3 = Settings.Theme.Tertiary
            KeyButton.BorderSizePixel = 0
            KeyButton.Text = CurrentKey.Name
            KeyButton.TextColor3 = Settings.Theme.Text
            KeyButton.TextSize = 11
            KeyButton.Font = Enum.Font.GothamBold
            KeyButton.AutoButtonColor = false
            KeyButton.Parent = Holder

            Corner(KeyButton, 7)

            KeyButton.MouseButton1Click:Connect(function()
                if Listening then
                    return
                end

                Listening = true
                KeyButton.Text = "Press key..."

                ClickSound()
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        CurrentKey = input.KeyCode
                        KeyButton.Text = CurrentKey.Name
                        Listening = false

                        SafeCallback(
                            data.Callback,
                            CurrentKey
                        )
                    end

                    return
                end

                if processed then
                    return
                end

                if input.KeyCode == CurrentKey then
                    SafeCallback(data.Callback, CurrentKey)
                end
            end)

            local Object = {}

            function Object:Set(key)
                if typeof(key) == "EnumItem" then
                    CurrentKey = key
                    KeyButton.Text = key.Name
                end
            end

            function Object:Get()
                return CurrentKey
            end

            return Object
        end

        --// Color Picker
        function Tab:CreateColorPicker(data)
            data = data or {}

            local Color = data.Color or Color3.fromRGB(255, 255, 255)
            local Open = false

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -8, 0, 45)
            Holder.BackgroundColor3 = Settings.Theme.Secondary
            Holder.BorderSizePixel = 0
            Holder.ClipsDescendants = true
            Holder.Parent = Page

            Corner(Holder, 8)

            local Label = MakeText(
                Holder,
                data.Name or "Color",
                12,
                Settings.Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(13, 0)
            Label.Size = UDim2.new(1, -75, 0, 45)

            local Preview = Instance.new("TextButton")
            Preview.Size = UDim2.fromOffset(30, 30)
            Preview.Position = UDim2.new(1, -43, 0.5, -15)
            Preview.BackgroundColor3 = Color
            Preview.BorderSizePixel = 0
            Preview.Text = ""
            Preview.AutoButtonColor = false
            Preview.Parent = Holder

            Corner(Preview, 9)

            local PreviewStroke = Stroke(
                Preview,
                Color3.fromRGB(255, 255, 255),
                1,
                0.65
            )

            local Picker = Instance.new("Frame")
            Picker.Size = UDim2.new(1, -16, 0, 150)
            Picker.Position = UDim2.fromOffset(8, 45)
            Picker.BackgroundColor3 = Settings.Theme.Tertiary
            Picker.BorderSizePixel = 0
            Picker.Parent = Holder

            Corner(Picker, 9)

            -- Hue
            local HueBar = Instance.new("Frame")
            HueBar.Size = UDim2.new(1, -24, 0, 18)
            HueBar.Position = UDim2.fromOffset(12, 12)
            HueBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            HueBar.BorderSizePixel = 0
            HueBar.Parent = Picker

            Corner(HueBar, 8)

            local HueGradient = Instance.new("UIGradient")
            HueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            HueGradient.Parent = HueBar

            local HueKnob = Instance.new("Frame")
            HueKnob.Size = UDim2.fromOffset(6, 24)
            HueKnob.Position = UDim2.new(0, -3, 0.5, -12)
            HueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueKnob.BorderSizePixel = 0
            HueKnob.Parent = HueBar

            Corner(HueKnob, 4)

            -- Saturation
            local Sat = Instance.new("Frame")
            Sat.Size = UDim2.new(1, -24, 0, 72)
            Sat.Position = UDim2.fromOffset(12, 39)
            Sat.BackgroundColor3 = Color
            Sat.BorderSizePixel = 0
            Sat.Parent = Picker

            Corner(Sat, 8)

            local WhiteGradient = Instance.new("UIGradient")
            WhiteGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
            })

            WhiteGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })

            WhiteGradient.Parent = Sat

            local BlackGradient = Instance.new("UIGradient")
            BlackGradient.Rotation = 90
            BlackGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
            })

            BlackGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            })

            BlackGradient.Parent = Sat

            local SatKnob = Instance.new("Frame")
            SatKnob.Size = UDim2.fromOffset(10, 10)
            SatKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SatKnob.BorderSizePixel = 0
            SatKnob.Parent = Sat

            Corner(SatKnob, 8)

            -- Buttons
            local Cancel = Instance.new("TextButton")
            Cancel.Size = UDim2.fromOffset(80, 27)
            Cancel.Position = UDim2.new(0, 12, 1, -36)
            Cancel.BackgroundColor3 = Settings.Theme.Secondary
            Cancel.BorderSizePixel = 0
            Cancel.Text = "Cancelar"
            Cancel.TextColor3 = Settings.Theme.SubText
            Cancel.TextSize = 10
            Cancel.Font = Enum.Font.GothamBold
            Cancel.AutoButtonColor = false
            Cancel.Parent = Picker

            Corner(Cancel, 7)

            local Accept = Instance.new("TextButton")
            Accept.Size = UDim2.fromOffset(80, 27)
            Accept.Position = UDim2.new(1, -92, 1, -36)
            Accept.BackgroundColor3 = Settings.Theme.Accent
            Accept.BorderSizePixel = 0
            Accept.Text = "Aceptar"
            Accept.TextColor3 = Color3.fromRGB(255, 255, 255)
            Accept.TextSize = 10
            Accept.Font = Enum.Font.GothamBold
            Accept.AutoButtonColor = false
            Accept.Parent = Picker

            Corner(Accept, 7)

            local H, S, V = Color:ToHSV()
            local OriginalColor = Color

            local function UpdateColor()
                Color = Color3.fromHSV(H, S, V)

                Sat.BackgroundColor3 =
                    Color3.fromHSV(H, 1, 1)

                Preview.BackgroundColor3 = Color

                local hueX = H * HueBar.AbsoluteSize.X
                HueKnob.Position =
                    UDim2.fromOffset(hueX - 3, -3)

                SatKnob.Position =
                    UDim2.new(S, -5, 1 - V, -5)
            end

            local hueDragging = false
            local satDragging = false

            local function UpdateHue(input)
                local x =
                    (input.Position.X - HueBar.AbsolutePosition.X) /
                    HueBar.AbsoluteSize.X

                H = math.clamp(x, 0, 1)
                UpdateColor()
            end

            local function UpdateSat(input)
                local x =
                    (input.Position.X - Sat.AbsolutePosition.X) /
                    Sat.AbsoluteSize.X

                local y =
                    (input.Position.Y - Sat.AbsolutePosition.Y) /
                    Sat.AbsoluteSize.Y

                S = math.clamp(x, 0, 1)
                V = 1 - math.clamp(y, 0, 1)

                UpdateColor()
            end

            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    hueDragging = true
                    UpdateHue(input)
                end
            end)

            Sat.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    satDragging = true
                    UpdateSat(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch then

                    if hueDragging then
                        UpdateHue(input)
                    elseif satDragging then
                        UpdateSat(input)
                    end
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    hueDragging = false
                    satDragging = false
                end
            end)

            local function ClosePicker()
                Open = false

                Tween(
                    Holder,
                    {
                        Size = UDim2.new(1, -8, 0, 45)
                    },
                    0.18
                )
            end

            Preview.MouseButton1Click:Connect(function()
                Open = not Open
                ClickSound()

                if Open then
                    OriginalColor = Color

                    Tween(
                        Holder,
                        {
                            Size = UDim2.new(1, -8, 0, 205)
                        },
                        0.2
                    )
                else
                    ClosePicker()
                end
            end)

            Accept.MouseButton1Click:Connect(function()
                ClickSound()

                OriginalColor = Color

                SafeCallback(
                    data.Callback,
                    Color
                )

                ClosePicker()
            end)

            Cancel.MouseButton1Click:Connect(function()
                ClickSound()

                Color = OriginalColor
                H, S, V = Color:ToHSV()
                UpdateColor()

                ClosePicker()
            end)

            UpdateColor()

            local Object = {}

            function Object:Set(color)
                if typeof(color) == "Color3" then
                    Color = color
                    OriginalColor = color
                    H, S, V = color:ToHSV()
                    UpdateColor()

                    SafeCallback(
                        data.Callback,
                        Color
                    )
                end
            end

            function Object:Get()
                return Color
            end

            return Object
        end

        WindowObject.Tabs[#WindowObject.Tabs + 1] = Tab

        if not WindowObject.CurrentTab then
            Tab:Select()
        end

        return Tab
    end

    --// Initial animation
    Main.Size = UDim2.fromOffset(0, 0)
    Main.BackgroundTransparency = 1

    Tween(
        Main,
        {
            Size = UDim2.fromOffset(
                config.Width or 570,
                config.Height or 390
            ),
            BackgroundTransparency = 0
        },
        0.35,
        Enum.EasingStyle.Back
    )

    return WindowObject
end

--// Global functions
function ArceusUI:SetTheme(theme)
    if typeof(theme) ~= "table" then
        return
    end

    for key, value in pairs(theme) do
        if Settings.Theme[key] ~= nil then
            Settings.Theme[key] = value
        end
    end
end

function ArceusUI:SetSoundEnabled(value)
    Settings.SoundEnabled = value == true
end

function ArceusUI:SetRGBSpeed(value)
    Settings.RGBSpeed = tonumber(value) or 1.5
end

return ArceusUI
