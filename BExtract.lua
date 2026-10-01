local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer

-- Environment and GUI parenting
local env = (getgenv and getgenv()) or _G

local ParentGui
if gethui then
    ParentGui = gethui()
else
    local success = pcall(function()
        local test = Instance.new("ScreenGui")
        test.Parent = CoreGui
        test:Destroy()
    end)
    if success then
        ParentGui = CoreGui
    else
        ParentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- Cleanup old instances
if env.BExtractUnload then
    pcall(env.BExtractUnload)
end

local BExtractGui = Instance.new("ScreenGui")
BExtractGui.Name = "BExtract"
BExtractGui.ResetOnSpawn = false
BExtractGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
BExtractGui.IgnoreGuiInset = true
BExtractGui.Parent = ParentGui

local BlackoutFrame = Instance.new("Frame")
BlackoutFrame.Name = "BlackoutFrame"
BlackoutFrame.Size = UDim2.new(1, 0, 1, 0)
BlackoutFrame.BackgroundColor3 = Color3.new(0, 0, 0)
BlackoutFrame.BorderSizePixel = 0
BlackoutFrame.ZIndex = -999
BlackoutFrame.Visible = false
BlackoutFrame.Parent = BExtractGui

env.BExtractUnload = function()
    if BExtractGui then
        BExtractGui:Destroy()
    end
    if env.BExtractCleanup then
        pcall(env.BExtractCleanup)
    end
end

-- Refined Colors
local Colors = {
    Background = Color3.fromRGB(22, 18, 30),
    Sidebar = Color3.fromRGB(22, 18, 30),
    SectionBackground = Color3.fromRGB(42, 35, 54),
    SidebarActive = Color3.fromRGB(42, 35, 54),
    SidebarHover = Color3.fromRGB(32, 26, 42),
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(170, 165, 180),
    Accent = Color3.fromRGB(205, 155, 255), 
    ToggleOn = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(255, 255, 255),
    ToggleBgOn = Color3.fromRGB(150, 100, 200),
    ToggleBgOff = Color3.fromRGB(80, 75, 95),
    Border = Color3.fromRGB(35, 30, 45)
}

-- Fonts
local FontPrimary = Enum.Font.GothamBold
local FontSecondary = Enum.Font.GothamMedium

-- Helper function to create rounded corners
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

-- Main Frame
local OriginalSize = UDim2.new(0, 580, 0, 380)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = OriginalSize
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = BExtractGui
addCorner(MainFrame, 16)

local DropShadow = Instance.new("UIStroke")
DropShadow.Color = Color3.fromRGB(0, 0, 0)
DropShadow.Transparency = 0.8
DropShadow.Thickness = 2
DropShadow.Parent = MainFrame

-- Make draggable
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 135, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
addCorner(Sidebar, 16)

-- Header in Sidebar
local HeaderIcon = Instance.new("TextLabel")
HeaderIcon.Size = UDim2.new(0, 24, 0, 24)
HeaderIcon.Position = UDim2.new(0, 15, 0, 15)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.Text = "🪄"
HeaderIcon.TextColor3 = Colors.Accent
HeaderIcon.Font = FontPrimary
HeaderIcon.TextSize = 20
HeaderIcon.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 100, 0, 18)
Title.Position = UDim2.new(0, 48, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "BExtract"
Title.TextColor3 = Colors.TextPrimary
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = FontPrimary
Title.TextSize = 15
Title.Parent = Sidebar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 100, 0, 12)
Subtitle.Position = UDim2.new(0, 48, 0, 32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "@f4t4l1ty_err404"
Subtitle.TextColor3 = Colors.TextSecondary
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Font = FontSecondary
Subtitle.TextSize = 10
Subtitle.Parent = Sidebar

-- Tab Container in Sidebar
local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 5)
TabList.Parent = Sidebar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -70)
TabContainer.Position = UDim2.new(0, 10, 0, 65)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar
TabList.Parent = TabContainer

-- Content Area
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Top Bar Controls
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -135, 0, 50)
TopBar.Position = UDim2.new(0, 135, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local VersionTag = Instance.new("TextLabel")
VersionTag.Size = UDim2.new(0, 72, 0, 20)
VersionTag.Position = UDim2.new(0, 5, 0.5, -10)
VersionTag.BackgroundColor3 = Colors.Accent
VersionTag.Text = "0.1beta"
VersionTag.TextColor3 = Color3.fromRGB(20, 15, 25)
VersionTag.Font = FontPrimary
VersionTag.TextSize = 11
VersionTag.Parent = TopBar
local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(1, 0) 
VersionCorner.Parent = VersionTag

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.SortOrder = Enum.SortOrder.LayoutOrder
ControlLayout.FillDirection = Enum.FillDirection.Horizontal
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlLayout.Padding = UDim.new(0, 8)
ControlLayout.Parent = TopBar

local ControlContainer = Instance.new("Frame")
ControlContainer.Size = UDim2.new(1, -15, 1, 0)
ControlContainer.BackgroundTransparency = 1
ControlContainer.Parent = TopBar
ControlLayout.Parent = ControlContainer

local function CreateControlButton(text, size)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 24, 0, 24)
    Btn.BackgroundTransparency = 1
    Btn.Text = text
    Btn.TextColor3 = Colors.TextSecondary
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = size
    Btn.Parent = ControlContainer
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Colors.TextPrimary}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
    end)
    return Btn
end

local MinBtn = CreateControlButton("—", 14)
local MaxBtn = CreateControlButton("□", 16)
local CloseBtn = CreateControlButton("✕", 14)

-- Closed Pill
local ClosedPill = Instance.new("Frame")
ClosedPill.Name = "ClosedPill"
ClosedPill.Size = UDim2.new(0, 160, 0, 36)
ClosedPill.Position = UDim2.new(0.5, -80, 0, 20)
ClosedPill.BackgroundColor3 = Colors.Background
ClosedPill.BackgroundTransparency = 0.3
ClosedPill.Visible = false
ClosedPill.Parent = BExtractGui
addCorner(ClosedPill, 18)

local UIStrokePill = Instance.new("UIStroke")
UIStrokePill.Color = Colors.Accent
UIStrokePill.Transparency = 0.5
UIStrokePill.Thickness = 1
UIStrokePill.Parent = ClosedPill

local DragIcon = Instance.new("TextLabel")
DragIcon.Size = UDim2.new(0, 18, 0, 18)
DragIcon.Position = UDim2.new(0, 10, 0.5, -9)
DragIcon.BackgroundTransparency = 1
DragIcon.Text = "✥"
DragIcon.TextColor3 = Colors.TextSecondary
DragIcon.Font = FontPrimary
DragIcon.TextSize = 14
DragIcon.Parent = ClosedPill

local PillIcon = Instance.new("TextLabel")
PillIcon.Size = UDim2.new(0, 18, 0, 18)
PillIcon.Position = UDim2.new(0, 32, 0.5, -9)
PillIcon.BackgroundTransparency = 1
PillIcon.Text = "🪄"
PillIcon.TextColor3 = Colors.TextPrimary
PillIcon.Font = FontPrimary
PillIcon.TextSize = 14
PillIcon.Parent = ClosedPill

local PillText = Instance.new("TextLabel")
PillText.Size = UDim2.new(1, -64, 1, 0)
PillText.Position = UDim2.new(0, 56, 0, 0)
PillText.BackgroundTransparency = 1
PillText.Text = "BExtract"
PillText.TextColor3 = Colors.TextPrimary
PillText.Font = FontPrimary
PillText.TextSize = 13
PillText.TextXAlignment = Enum.TextXAlignment.Left
PillText.Parent = ClosedPill

local ClickButton = Instance.new("TextButton")
ClickButton.Size = UDim2.new(1, 0, 1, 0)
ClickButton.BackgroundTransparency = 1
ClickButton.Text = ""
ClickButton.Parent = ClosedPill

local isMaximized = false
local storedSize, storedPos, pillStartPos

local function OpenGUI()
    if MainFrame.Visible then return end
    ClosedPill.Visible = false
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Visible = true
    
    local targetSize = isMaximized and UDim2.new(1, -40, 1, -40) or OriginalSize
    local targetPos = isMaximized and UDim2.new(0, 20, 0, 20) or (storedPos or UDim2.new(0.5, -290, 0.5, -190))
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = targetSize,
        Position = targetPos
    }):Play()
end

local function CloseGUI()
    if not MainFrame.Visible then return end
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tw:Play()
    task.spawn(function()
        tw.Completed:Wait()
        MainFrame.Visible = false
        ClosedPill.Visible = true
        
        local originalPillPos = pillStartPos or UDim2.new(0.5, -80, 0, 20)
        ClosedPill.Position = UDim2.new(originalPillPos.X.Scale, originalPillPos.X.Offset, 0, -50)
        TweenService:Create(ClosedPill, TweenInfo.new(0.4, Enum.EasingStyle.Bounce), {
            Position = originalPillPos
        }):Play()
    end)
end

ClickButton.MouseButton1Click:Connect(OpenGUI)

local pillDragging, pillDragInput, pillDragStart
ClosedPill.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        pillDragging = true
        pillDragStart = input.Position
        pillStartPos = ClosedPill.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                pillDragging = false
            end
        end)
    end
end)
ClosedPill.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        pillDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == pillDragInput and pillDragging then
        local delta = input.Position - pillDragStart
        ClosedPill.Position = UDim2.new(pillStartPos.X.Scale, pillStartPos.X.Offset + delta.X, pillStartPos.Y.Scale, pillStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        if MainFrame.Visible then
            CloseGUI()
        else
            OpenGUI()
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(CloseGUI)

MaxBtn.MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        storedSize = MainFrame.Size
        storedPos = MainFrame.Position
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, -40, 1, -40),
            Position = UDim2.new(0, 20, 0, 20)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = storedSize or OriginalSize,
            Position = storedPos or UDim2.new(0.5, -290, 0.5, -190)
        }):Play()
    end
end)

local MinimizedSize = UDim2.new(0, 580, 0, 50)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = MinimizedSize}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = isMaximized and UDim2.new(0, 800, 0, 500) or OriginalSize}):Play()
    end
end)

local Tabs = {}
local Pages = {}
local CurrentTab = nil

local function CreateTab(name, iconText)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Colors.SidebarActive
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.Parent = TabContainer
    addCorner(TabBtn, 8)

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 20, 0, 20)
    Icon.Position = UDim2.new(0, 10, 0.5, -10)
    Icon.BackgroundTransparency = 1
    Icon.Text = iconText or ""
    Icon.TextColor3 = Colors.TextSecondary
    Icon.Font = FontPrimary
    Icon.TextSize = 13
    Icon.Parent = TabBtn

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Colors.TextSecondary
    Label.Font = FontSecondary
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Colors.TextSecondary
    Page.Visible = false
    Page.Parent = ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page
    
    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingRight = UDim.new(0, 10)
    PagePadding.Parent = Page
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    Tabs[name] = {Btn = TabBtn, Icon = Icon, Label = Label, Page = Page}
    table.insert(Pages, Page)

    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, BackgroundColor3 = Colors.SidebarHover}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {TextColor3 = Colors.TextPrimary}):Play()
            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Colors.TextPrimary}):Play()
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
        end
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(Tabs) do
            if tName == name then
                CurrentTab = name
                tData.Page.Visible = true
                TweenService:Create(tData.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Colors.SidebarActive}):Play()
                TweenService:Create(tData.Icon, TweenInfo.new(0.2), {TextColor3 = Colors.TextPrimary}):Play()
                TweenService:Create(tData.Label, TweenInfo.new(0.2), {TextColor3 = Colors.TextPrimary}):Play()
            else
                tData.Page.Visible = false
                TweenService:Create(tData.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(tData.Icon, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
                TweenService:Create(tData.Label, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
            end
        end
    end)

    return Page
end

local function CreateToggle(parent, title, desc, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 60)
    Container.BackgroundColor3 = Colors.SectionBackground
    Container.Parent = parent
    addCorner(Container, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 0, 18)
    Label.Position = UDim2.new(0, 16, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Colors.TextPrimary
    Label.Font = FontPrimary
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -70, 0, 16)
    DescLabel.Position = UDim2.new(0, 16, 0, 32)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc
    DescLabel.TextColor3 = Colors.TextSecondary
    DescLabel.Font = FontSecondary
    DescLabel.TextSize = 11
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = Container

    local ToggleBg = Instance.new("TextButton")
    ToggleBg.Size = UDim2.new(0, 36, 0, 20)
    ToggleBg.Position = UDim2.new(1, -52, 0.5, -10)
    ToggleBg.BackgroundColor3 = Colors.ToggleBgOff
    ToggleBg.Text = ""
    ToggleBg.AutoButtonColor = false
    ToggleBg.Parent = Container
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = ToggleBg

    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    ToggleCircle.Position = UDim2.new(0, 3, 0.5, -7)
    ToggleCircle.BackgroundColor3 = Colors.ToggleOff
    ToggleCircle.Parent = ToggleBg
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = ToggleCircle

    local toggled = false
    ToggleBg.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Colors.ToggleOn}):Play()
            TweenService:Create(ToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundColor3 = Colors.ToggleBgOn}):Play()
        else
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Colors.ToggleOff}):Play()
            TweenService:Create(ToggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundColor3 = Colors.ToggleBgOff}):Play()
        end
        if callback then callback(toggled) end
    end)
    return {
        SetState = function(state)
            toggled = state
            if toggled then
                ToggleCircle.Position = UDim2.new(1, -17, 0.5, -7)
                ToggleBg.BackgroundColor3 = Colors.ToggleBgOn
            else
                ToggleCircle.Position = UDim2.new(0, 3, 0.5, -7)
                ToggleBg.BackgroundColor3 = Colors.ToggleBgOff
            end
        end
    }
end

local function CreateLabelArea(parent, title, text, height)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, height or 70)
    Container.BackgroundColor3 = Colors.SectionBackground
    Container.Parent = parent
    addCorner(Container, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -32, 0, 18)
    Label.Position = UDim2.new(0, 16, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Colors.TextPrimary
    Label.Font = FontPrimary
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, -32, 1, -38)
    ContentLabel.Position = UDim2.new(0, 16, 0, 32)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Text = text
    ContentLabel.TextColor3 = Colors.TextSecondary
    ContentLabel.Font = FontSecondary
    ContentLabel.TextSize = 11
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
    ContentLabel.TextWrapped = true
    ContentLabel.Parent = Container
    
    return {
        SetText = function(newText)
            ContentLabel.Text = newText
        end
    }
end

local function CreateSlider(parent, title, desc, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 70)
    Container.BackgroundColor3 = Colors.SectionBackground
    Container.Parent = parent
    addCorner(Container, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -120, 0, 18)
    Label.Position = UDim2.new(0, 16, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Colors.TextPrimary
    Label.Font = FontPrimary
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -120, 0, 32)
    DescLabel.Position = UDim2.new(0, 16, 0, 32)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc
    DescLabel.TextColor3 = Colors.TextSecondary
    DescLabel.Font = FontSecondary
    DescLabel.TextSize = 11
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextYAlignment = Enum.TextYAlignment.Top
    DescLabel.TextWrapped = true
    DescLabel.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 30, 0, 18)
    ValueLabel.Position = UDim2.new(1, -110, 0.5, -9)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Colors.TextSecondary
    ValueLabel.Font = FontSecondary
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container

    local SliderBg = Instance.new("TextButton")
    SliderBg.Size = UDim2.new(0, 60, 0, 4)
    SliderBg.Position = UDim2.new(1, -70, 0.5, -2)
    SliderBg.BackgroundColor3 = Colors.ToggleBgOff
    SliderBg.Text = ""
    SliderBg.AutoButtonColor = false
    SliderBg.Parent = Container
    addCorner(SliderBg, 2)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = Colors.Accent
    SliderFill.Parent = SliderBg
    addCorner(SliderFill, 2)

    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 12, 0, 12)
    SliderKnob.Position = UDim2.new(1, -6, 0.5, -6)
    SliderKnob.BackgroundColor3 = Colors.TextPrimary
    SliderKnob.Parent = SliderFill
    addCorner(SliderKnob, 6)

    local function updateSlider(input)
        local pos = math.clamp(input.Position.X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
        local percentage = pos / SliderBg.AbsoluteSize.X
        local value = math.floor(min + ((max - min) * percentage))
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        if callback then callback(value) end
    end
    
    local draggingSlider = false
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    local defPercent = (default - min) / (max - min)
    SliderFill.Size = UDim2.new(defPercent, 0, 1, 0)

    return {
        SetValue = function(val)
            local p = (val - min) / (max - min)
            SliderFill.Size = UDim2.new(p, 0, 1, 0)
            ValueLabel.Text = tostring(val)
        end
    }
end

local function CreateDropdown(parent, title, options, defaultIndex, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundColor3 = Colors.SectionBackground
    Container.ZIndex = 50
    Container.Parent = parent
    addCorner(Container, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -150, 0, 18)
    Label.Position = UDim2.new(0, 16, 0.5, -9)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Colors.TextPrimary
    Label.Font = FontPrimary
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 170, 0, 30)
    DropBtn.Position = UDim2.new(1, -180, 0.5, -15)
    DropBtn.BackgroundColor3 = Colors.ToggleBgOff
    DropBtn.Text = ""
    DropBtn.AutoButtonColor = false
    DropBtn.Parent = Container
    addCorner(DropBtn, 8)

    local SelectedText = Instance.new("TextLabel")
    SelectedText.Size = UDim2.new(1, -25, 1, 0)
    SelectedText.Position = UDim2.new(0, 10, 0, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.Text = options[defaultIndex] or options[1] or ""
    SelectedText.TextColor3 = Colors.TextPrimary
    SelectedText.Font = FontSecondary
    SelectedText.TextSize = 12
    SelectedText.TextXAlignment = Enum.TextXAlignment.Left
    SelectedText.TextTruncate = Enum.TextTruncate.AtEnd
    SelectedText.Parent = DropBtn

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 20, 1, 0)
    Icon.Position = UDim2.new(1, -20, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "v"
    Icon.TextColor3 = Colors.TextSecondary
    Icon.Font = FontPrimary
    Icon.TextSize = 12
    Icon.Parent = DropBtn
    
    local DropList = Instance.new("Frame")
    DropList.Size = UDim2.new(0, 170, 0, 0)
    DropList.Position = UDim2.new(1, -180, 0, 45)
    DropList.BackgroundColor3 = Colors.ToggleBgOff
    DropList.Visible = false
    DropList.ZIndex = 60
    DropList.ClipsDescendants = true
    DropList.Parent = Container
    addCorner(DropList, 8)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = DropList
    
    local open = false
    DropBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            DropList.Visible = true
            DropList.Size = UDim2.new(0, 170, 0, #options * 30)
        else
            DropList.Visible = false
        end
    end)
    
    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 30)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = "  " .. opt
        OptBtn.TextColor3 = Colors.TextSecondary
        OptBtn.Font = FontSecondary
        OptBtn.TextSize = 12
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.ZIndex = 61
        OptBtn.Parent = DropList
        
        OptBtn.MouseEnter:Connect(function()
            OptBtn.TextColor3 = Colors.TextPrimary
        end)
        OptBtn.MouseLeave:Connect(function()
            OptBtn.TextColor3 = Colors.TextSecondary
        end)
        
        OptBtn.MouseButton1Click:Connect(function()
            SelectedText.Text = opt
            open = false
            DropList.Visible = false
            if callback then callback(opt) end
        end)
    end
end

--------------------------------------------------------------------------------
-- AUTOFARM ENGINE & STATE MANAGEMENT
--------------------------------------------------------------------------------

local SettingsState = {
    AutofarmEnabled = false,
    AutofarmPreset = "Default (Recommended)",
    UpdateInterval = 0.5,
    HealLimit = 2,
    DisableCapsulePickup = false,
    DisableTapePickup = false,
    ResearchMode = false,
    AutoVoteCards = true,
    TwistedESP = false,
    ItemESP = false,
    PlayerESP = false,
    IgnoreLocalCharacter = false,
    DisableRendering = false,
    AntiIdle = false,
    EpilepsyHelper = false
}

local PresetIntervals = {
    ["Default (Recommended)"] = 0.5,
    ["Safe (Slow)"] = 1.0,
    ["Quick"] = 0.15
}

-- ESP Highlight Storage
local TwistedHighlights = {}
local ItemHighlights = {}
local PlayerHighlights = {}
local PlayerConnections = {}

local function UpdateTwistedESP()
    for monster, hl in pairs(TwistedHighlights) do
        if hl then hl:Destroy() end
    end
    table.clear(TwistedHighlights)

    if not SettingsState.TwistedESP then return end

    local currentRoom = workspace:FindFirstChild("CurrentRoom")
    local candidates = CollectionService:GetTagged("Twisted")
    if currentRoom then
        for _, desc in ipairs(currentRoom:GetDescendants()) do
            if desc:IsA("Model") and (desc.Name:find("Monster") or CollectionService:HasTag(desc, "Twisted")) then
                table.insert(candidates, desc)
            end
        end
    end

    for _, monster in ipairs(candidates) do
        if monster:IsA("Model") and not TwistedHighlights[monster] then
            local hl = Instance.new("Highlight")
            hl.Name = "BExtract_TwistedESP"
            hl.FillColor = Color3.fromRGB(255, 75, 75)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.4
            hl.Parent = monster
            TwistedHighlights[monster] = hl
        end
    end
end

local function UpdateItemESP()
    for obj, hl in pairs(ItemHighlights) do
        if hl then hl:Destroy() end
    end
    table.clear(ItemHighlights)

    if not SettingsState.ItemESP then return end

    local items = CollectionService:GetTagged("Item")
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc.Name == "Items" and desc:IsA("Folder") then
            for _, item in ipairs(desc:GetChildren()) do
                table.insert(items, item)
            end
        end
    end

    for _, item in ipairs(items) do
        if (item:IsA("Model") or item:IsA("BasePart")) and not ItemHighlights[item] then
            local hl = Instance.new("Highlight")
            hl.Name = "BExtract_ItemESP"
            hl.FillColor = Color3.fromRGB(180, 80, 255)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.4
            hl.Parent = item
            ItemHighlights[item] = hl
        end
    end
end

local function UpdatePlayerHighlight(player)
    if PlayerHighlights[player] then
        PlayerHighlights[player]:Destroy()
        PlayerHighlights[player] = nil
    end

    if not SettingsState.PlayerESP then return end
    if not player.Character then return end
    if SettingsState.IgnoreLocalCharacter and player == LocalPlayer then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "BExtractESP"
    highlight.FillColor = Colors.Accent
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character
    PlayerHighlights[player] = highlight
end

local function SetupPlayer(player)
    PlayerConnections[player] = player.CharacterAdded:Connect(function()
        UpdatePlayerHighlight(player)
    end)
    UpdatePlayerHighlight(player)
end

local function CleanupPlayer(player)
    if PlayerConnections[player] then
        PlayerConnections[player]:Disconnect()
        PlayerConnections[player] = nil
    end
    if PlayerHighlights[player] then
        PlayerHighlights[player]:Destroy()
        PlayerHighlights[player] = nil
    end
end

local playerAddedConn = Players.PlayerAdded:Connect(SetupPlayer)
local playerRemovingConn = Players.PlayerRemoving:Connect(CleanupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end

local function RefreshAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        UpdatePlayerHighlight(player)
    end
end

-- Disable Rendering Helper
local HiddenGuis = {}
local function SetDisableRendering(state)
    SettingsState.DisableRendering = state
    pcall(function()
        RunService:Set3dRenderingEnabled(not state)
    end)
    BlackoutFrame.Visible = state
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        if state then
            for _, gui in ipairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui ~= BExtractGui and gui.Enabled then
                    HiddenGuis[gui] = true
                    gui.Enabled = false
                end
            end
        else
            for gui, _ in pairs(HiddenGuis) do
                if gui and gui.Parent then
                    gui.Enabled = true
                end
            end
            table.clear(HiddenGuis)
        end
    end
end

-- Anti-Idle Helper
local antiIdleConnection
local function SetAntiIdle(state)
    SettingsState.AntiIdle = state
    if state then
        if not antiIdleConnection then
            local VirtualUser = game:GetService("VirtualUser")
            antiIdleConnection = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end)
        end
    else
        if antiIdleConnection then
            antiIdleConnection:Disconnect()
            antiIdleConnection = nil
        end
    end
end

-- Epilepsy Helper
local epilepsyConnection
local function SetEpilepsyHelper(state)
    SettingsState.EpilepsyHelper = state
    if state then
        if not epilepsyConnection then
            epilepsyConnection = RunService.RenderStepped:Connect(function()
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
                    workspace.CurrentCamera.CFrame = CFrame.new(0, -99999, 0)
                end
            end)
        end
    else
        if epilepsyConnection then
            epilepsyConnection:Disconnect()
            epilepsyConnection = nil
        end
        if workspace.CurrentCamera then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end
end

local skillcheckOrigCB = nil
local arcadeOrigCB = nil

local function ApplyInstantSkillcheck(state)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local events = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage

    -- 1. Generator Skillchecks
    local scEvent = events:FindFirstChild("SkillcheckUpdate")
    if scEvent and scEvent:IsA("RemoteFunction") then
        if state then
            if getcallbackvalue and not skillcheckOrigCB then
                pcall(function() skillcheckOrigCB = getcallbackvalue(scEvent, "OnClientInvoke") end)
            end
            scEvent.OnClientInvoke = function(...)
                task.spawn(function()
                    pcall(function()
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if not playerGui then return end
                        for _, gui in ipairs(playerGui:GetChildren()) do
                            if gui:IsA("ScreenGui") then
                                local menu = gui:FindFirstChild("Menu") or gui
                                local scFrame = menu:FindFirstChild("SkillCheckFrame", true)
                                if scFrame then scFrame.Visible = false end
                                local cal = menu:FindFirstChild("Calibrate", true)
                                if cal then cal.Visible = false end
                                local msg = menu:FindFirstChild("SkillCheckMessage", true)
                                if msg then
                                    msg.Text = "Great Job!"
                                    msg.Visible = true
                                    msg.TextTransparency = 0
                                end
                            end
                        end
                    end)
                end)
                return "supercomplete"
            end
        else
            if skillcheckOrigCB then
                scEvent.OnClientInvoke = skillcheckOrigCB
                skillcheckOrigCB = nil
            else
                scEvent.OnClientInvoke = nil
            end
        end
    end

    -- 2. Arcade Machine Calibrations
    local arcEvent = events:FindFirstChild("ArcadeUpdate") or events:FindFirstChild("ArcadeSkillcheckUpdate") or events:FindFirstChild("CalibrationUpdate")
    if arcEvent and arcEvent:IsA("RemoteFunction") then
        if state then
            if getcallbackvalue and not arcadeOrigCB then
                pcall(function() arcadeOrigCB = getcallbackvalue(arcEvent, "OnClientInvoke") end)
            end
            arcEvent.OnClientInvoke = function(...)
                task.spawn(function()
                    pcall(function()
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if not playerGui then return end
                        for _, gui in ipairs(playerGui:GetChildren()) do
                            if gui:IsA("ScreenGui") then
                                local arcFrame = gui:FindFirstChild("ArcadeFrame", true) or gui:FindFirstChild("MinigameFrame", true)
                                if arcFrame then arcFrame.Visible = false end
                            end
                        end
                    end)
                end)
                return "supercomplete"
            end
        else
            if arcadeOrigCB then
                arcEvent.OnClientInvoke = arcadeOrigCB
                arcadeOrigCB = nil
            else
                arcEvent.OnClientInvoke = nil
            end
        end
    end
end

local function EnableInstantSkillcheck(state)
    ApplyInstantSkillcheck(state)
end

local function GetMapContainer()
    return workspace:FindFirstChild("CurrentRoom")
        or workspace:FindFirstChild("Map")
        or workspace:FindFirstChild("Room")
        or workspace:FindFirstChild("Rooms")
        or workspace
end

local function GetCharacterComponents()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            return char, hrp, hum
        end
    end
    return nil, nil, nil
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt.Enabled then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            if prompt.HoldDuration > 0 then
                task.wait(prompt.HoldDuration)
            end
            prompt:InputHoldEnd()
        end
    end)
end

local function SafeTeleport(hrp, targetCF)
    if not hrp or not targetCF then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = targetCF
        if hrp.Parent then
            hrp.Parent:PivotTo(targetCF)
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function CountHealItemsInInventory()
    local count = 0
    local igp = workspace:FindFirstChild("InGamePlayers")
    local pm = igp and igp:FindFirstChild(LocalPlayer.Name)
    local inv = pm and pm:FindFirstChild("Inventory")
    if inv then
        for _, slot in ipairs(inv:GetChildren()) do
            if slot:IsA("StringValue") and (slot.Value == "Bandage" or slot.Value == "HealthKit") then
                count = count + 1
            end
        end
    end
    return count
end

local function FindElevatorBase()
    local elevs = workspace:FindFirstChild("Elevators")
    if elevs then
        local elev = elevs:FindFirstChild("Elevator")
        if elev then
            local base = elev:FindFirstChild("Base")
            if base and base:IsA("BasePart") then
                return base
            end
        end
    end
    local container = GetMapContainer()
    for _, d in ipairs(container:GetDescendants()) do
        if d:IsA("Model") and (d.Name == "FakeElevator" or d.Name:find("Elevator")) then
            local base = d:FindFirstChild("Base") or d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart", true)
            if base and base:IsA("BasePart") then
                return base
            end
        end
    end
    return nil
end

local function IsThreatNearby(hrpPosition, detectionRadius)
    local container = GetMapContainer()
    local radius = detectionRadius or 60
    for _, desc in ipairs(container:GetDescendants()) do
        if desc:IsA("Model") then
            local name = desc.Name
            if name:find("Monster") or name:find("BlotHand") or name == "SproutTendril" or CollectionService:HasTag(desc, "Twisted") then
                local monsterHrp = desc.PrimaryPart or desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChildWhichIsA("BasePart", true)
                if monsterHrp then
                    local dist = (hrpPosition - monsterHrp.Position).Magnitude
                    if dist <= radius then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local lastThreatTime = 0
local SEEN_SAFETY_COOLDOWN = 3.5

local function IsArcadeMachine(model)
    if not model or not model:IsA("Model") then return false end
    local name = model.Name
    if name:find("Arcade") or name:find("Gigi") or name:find("GigiHoard") or name:find("ArcadeMachine") then
        return true
    end
    return false
end

local function AllGeneratorsCompleted(container)
    container = container or GetMapContainer()
    local totalGens = 0
    local completedGens = 0
    for _, desc in ipairs(container:GetDescendants()) do
        if desc:IsA("Model") and desc.Name:find("Generator") and not IsArcadeMachine(desc) then
            totalGens = totalGens + 1
            local stats = desc:FindFirstChild("Stats")
            local isCompleted = stats and stats:FindFirstChild("Completed") and stats.Completed.Value == true
            if isCompleted then
                completedGens = completedGens + 1
            end
        end
    end
    return totalGens > 0 and (totalGens == completedGens)
end

local autofarmStartTime = 0

local lastItemUseTick = 0
local function AutoUseInventoryItems(isDecoding)
    if tick() - lastItemUseTick < 0.5 then return end
    local char, hrp, hum = GetCharacterComponents()
    if not char or not hum then return end

    local curHp = hum.Health
    local maxHp = hum.MaxHealth

    local igp = workspace:FindFirstChild("InGamePlayers")
    local pm = igp and igp:FindFirstChild(LocalPlayer.Name)
    local inv = pm and pm:FindFirstChild("Inventory")
    if not inv then return end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local itemEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("ItemEvent")

    for i = 1, 4 do
        local slot = inv:FindFirstChild("Slot" .. i)
        if slot and slot:IsA("StringValue") and slot.Value ~= "" and slot.Value ~= "None" then
            local itemName = slot.Value
            local shouldUse = false

            if itemName == "JumperCable" or itemName == "Valve" then
                if isDecoding then shouldUse = true end
            elseif itemName == "HealthKit" then
                if curHp <= 1 then shouldUse = true end
            elseif itemName == "Bandage" then
                if curHp < maxHp then shouldUse = true end
            elseif itemName ~= "Tape" and itemName ~= "ResearchCapsule" then
                shouldUse = true
            end

            if shouldUse then
                lastItemUseTick = tick()

                -- Pop / PopBottle special handling: make character walk/run before using
                if itemName == "Pop" or itemName == "PopBottle" or itemName:find("Pop") then
                    pcall(function()
                        FireSprint(true)
                        if hum then
                            hum:Move(Vector3.new(0, 0, -1), true)
                        end
                    end)
                    task.wait(0.05)
                end

                pcall(function()
                    if itemEvent then
                        itemEvent:InvokeServer(char, slot)
                    else
                        local tool = char:FindFirstChild(itemName) or LocalPlayer.Backpack:FindFirstChild(itemName)
                        if tool then
                            hum:EquipTool(tool)
                            task.wait(0.05)
                            tool:Activate()
                        end
                    end
                end)
                return
            end
        end
    end
end

-- Track seen Twisteds for Research Mode
local SeenTwisteds = {}
local lastMapContainer = nil

local function DoAutoBuy(hrp)
    local elevs = workspace:FindFirstChild("Elevators")
    local elev = elevs and elevs:FindFirstChild("Elevator")
    local dandyStore = elev and elev:FindFirstChild("DandyStore")
    if not dandyStore then return end

    local info = workspace:FindFirstChild("Info")
    local storeOpen = info and info:FindFirstChild("DandyStoreOpen")
    if storeOpen and storeOpen:IsA("BoolValue") and storeOpen.Value == false then return end

    for _, child in ipairs(dandyStore:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local parentModel = child.Parent
            local handle = parentModel:IsA("BasePart") and parentModel or parentModel:FindFirstChildWhichIsA("BasePart", true)
            if handle then
                if (hrp.Position - handle.Position).Magnitude > 4 then
                    SafeTeleport(hrp, handle.CFrame * CFrame.new(0, 3, 0))
                    task.wait(0.08)
                end
                TriggerPrompt(child)
            end
        end
    end
end

local CardPriorities = {
    ["speed"] = 100,
    ["movement"] = 95,
    ["run"] = 95,
    ["extraction"] = 90,
    ["decode"] = 90,
    ["machine"] = 85,
    ["skillcheck"] = 85,
    ["stamina"] = 80,
    ["health"] = 75,
    ["heal"] = 75,
    ["stealth"] = 70,
    ["tape"] = 65,
    ["capsule"] = 60,
    ["item"] = 55
}

local function ClickGuiButton(button)
    if not button then return end
    pcall(function()
        if firesignal and button.MouseButton1Click then
            firesignal(button.MouseButton1Click)
        elseif getconnections then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                conn:Fire()
            end
        end
    end)
    pcall(function()
        if button.Activate then
            button:Activate()
        end
    end)
end

local function AutoVoteBestCard()
    if not SettingsState.AutoVoteCards then return end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local cardGuis = {}
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local name = gui.Name
            if name:find("Card") or name:find("Vote") or name:find("Reward") or name:find("Choice") then
                table.insert(cardGuis, gui)
            end
        end
    end

    for _, cardGui in ipairs(cardGuis) do
        local cardOptions = {}
        for _, child in ipairs(cardGui:GetDescendants()) do
            if child:IsA("GuiObject") and child.Visible then
                local childName = child.Name
                if childName:find("Card") or childName:find("Option") or childName:find("Choice") or childName:find("Button") then
                    local btn = child:IsA("GuiButton") and child or child:FindFirstChildWhichIsA("GuiButton", true)
                    if btn then
                        table.insert(cardOptions, { container = child, button = btn })
                    end
                end
            end
        end

        if #cardOptions > 0 then
            local bestScore = -1
            local bestOption = nil

            for _, opt in ipairs(cardOptions) do
                local textContent = ""
                for _, desc in ipairs(opt.container:GetDescendants()) do
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                        textContent = textContent .. " " .. desc.Text:lower()
                    end
                end

                local score = 10
                for keyword, kwScore in pairs(CardPriorities) do
                    if textContent:find(keyword) then
                        if kwScore > score then
                            score = kwScore
                        end
                    end
                end

                if score > bestScore then
                    bestScore = score
                    bestOption = opt
                end
            end

            if bestOption and bestOption.button then
                ClickGuiButton(bestOption.button)
                local cardRemotes = { "VoteCard", "CardVote", "SelectCard", "ChooseCard", "CardSelected" }
                local rs = game:GetService("ReplicatedStorage")
                for _, rName in ipairs(cardRemotes) do
                    local remote = rs:FindFirstChild(rName, true) or workspace:FindFirstChild(rName, true)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer(bestOption.button.Name) end)
                        pcall(function() remote:FireServer(bestOption.container.Name) end)
                    end
                end
            end
        end
    end
end

local function ExecuteAutofarmStep()
    if not SettingsState.AutofarmEnabled then return end

    -- Actively enforce instant skillcheck / calibration bypass
    ApplyInstantSkillcheck(true)

    -- Auto vote for best cards if card selection screen is open
    pcall(AutoVoteBestCard)

    -- Dynamic ESP update loop
    if SettingsState.TwistedESP then UpdateTwistedESP() end
    if SettingsState.ItemESP then UpdateItemESP() end

    local char, hrp, hum = GetCharacterComponents()
    if not hrp or not hum then return end

    local container = GetMapContainer()
    if container ~= lastMapContainer then
        lastMapContainer = container
        table.clear(SeenTwisteds)
    end

    local safeBase = FindElevatorBase()
    local safePos = safeBase and (safeBase.CFrame * CFrame.new(0, 3, 0)).Position or hrp.Position

    -- Check Dandy Store auto-buy
    pcall(function() DoAutoBuy(hrp) end)

    -- Check if player is currently decoding / working on a machine
    local isDecoding = false
    local igp = workspace:FindFirstChild("InGamePlayers")
    local pm = igp and igp:FindFirstChild(LocalPlayer.Name)
    if pm and pm:FindFirstChild("Decoding") and pm.Decoding.Value ~= nil then
        isDecoding = true
    end

    -- Automatically use inventory items based on health & decoding state
    AutoUseInventoryItems(isDecoding)

    -- 2. Research Mode: Teleport above each unseen Twisted once, wait for sight detection, then teleport to safe elevator base and never visit them again
    if SettingsState.ResearchMode then
        for _, desc in ipairs(container:GetDescendants()) do
            if desc:IsA("Model") and (desc.Name:find("Monster") or CollectionService:HasTag(desc, "Twisted")) then
                -- Ignore Connie as she cannot see the player
                if desc.Name:find("Connie") then continue end

                local monsterId = desc:GetDebugId() or desc.Name
                -- Check both model reference and ID to prevent repeat teleports
                if not SeenTwisteds[desc] and not SeenTwisteds[monsterId] and not SeenTwisteds[desc.Name] then
                    local monsterHrp = desc.PrimaryPart or desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChildWhichIsA("BasePart", true)
                    if monsterHrp and monsterHrp.Parent then
                        -- Instantly mark this monster as visited before starting hover loop to ensure no duplicate attempts
                        SeenTwisteds[desc] = true
                        SeenTwisteds[monsterId] = true
                        SeenTwisteds[desc.Name] = true

                        -- Create invisible temporary hovering platform so gravity doesn't pull the player down
                        local hoverPad = Instance.new("Part")
                        hoverPad.Name = "ResearchHoverPad"
                        hoverPad.Size = Vector3.new(16, 1, 16)
                        hoverPad.Anchored = true
                        hoverPad.CanCollide = true
                        hoverPad.Transparency = 1
                        hoverPad.Parent = workspace

                        -- Position character & platform 18 studs directly above the monster to keep out of Goob/Twisted reach
                        local hoverCF = monsterHrp.CFrame * CFrame.new(0, 18, 0)
                        hoverPad.CFrame = hoverCF * CFrame.new(0, -3.5, 0)
                        SafeTeleport(hrp, hoverCF)
                        FireSprint(true)

                        -- Hold position above until sight detection triggers or max wait timeout (1.5s)
                        local startWait = tick()
                        local spotted = false
                        while tick() - startWait < 1.5 do
                            local mIcon = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MonsterIcon", true)
                            local isSeen = mIcon and mIcon.ImageTransparency < 1
                            if isSeen or IsThreatNearby(hrp.Position, 35) then
                                spotted = true
                                break
                            end
                            if monsterHrp and monsterHrp.Parent then
                                local currentHoverCF = monsterHrp.CFrame * CFrame.new(0, 18, 0)
                                hoverPad.CFrame = currentHoverCF * CFrame.new(0, -3.5, 0)
                                SafeTeleport(hrp, currentHoverCF)
                            end
                            task.wait(0.03)
                        end

                        hoverPad:Destroy()

                        -- Trigger threat safety cooldown so threat check keeps player at safe base
                        lastThreatTime = tick()

                        -- Teleport away immediately to safe elevator base
                        if safeBase then
                            SafeTeleport(hrp, safeBase.CFrame * CFrame.new(0, 3, 0))
                        elseif safePos then
                            SafeTeleport(hrp, CFrame.new(safePos))
                        end

                        task.wait(0.05)
                        return
                    end
                end
            end
        end
    end

    -- Threat Check: Evaluate if any monster is within 45 studs
    local threatActive = IsThreatNearby(hrp.Position, 45) or IsThreatNearby(safePos, 45)
    if threatActive then
        lastThreatTime = tick()
    end

    -- Threat Evacuation & Waiting at Safe Base
    if threatActive or (tick() - lastThreatTime < SEEN_SAFETY_COOLDOWN) then
        if safeBase then
            local safeTargetCF = safeBase.CFrame * CFrame.new(0, 3, 0)
            if (hrp.Position - safeTargetCF.Position).Magnitude > 3 then
                SafeTeleport(hrp, safeTargetCF)
            end
            return
        end
    end

    -- 3. Items, Tapes & Research Capsules Pickup
    local healCount = CountHealItemsInInventory()
    local itemsFolder = container:FindFirstChild("Items", true) or workspace:FindFirstChild("Items") or container
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item.Name
            if itemName:find("GigiHoard") or itemName:find("Gigi") then continue end
            if SettingsState.DisableTapePickup and itemName == "Tape" then continue end
            if SettingsState.DisableCapsulePickup and itemName == "ResearchCapsule" then continue end
            if (itemName == "Bandage" or itemName == "HealthKit") and healCount >= SettingsState.HealLimit then continue end

            local handle = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            if handle and prompt then
                local targetCF = handle.CFrame * CFrame.new(0, 2, 0)
                if (hrp.Position - targetCF.Position).Magnitude > 3 then
                    SafeTeleport(hrp, targetCF)
                    task.wait(0.05)
                end
                TriggerPrompt(prompt)
                return
            end
        end
    end

    -- 4. Generator Extraction (Find safe, uncompleted machine and disconnect if seen)
    for _, desc in ipairs(container:GetDescendants()) do
        if desc:IsA("Model") and desc.Name:find("Generator") and not IsArcadeMachine(desc) then
            local stats = desc:FindFirstChild("Stats")
            local isCompleted = stats and stats:FindFirstChild("Completed") and stats.Completed.Value == true
            if not isCompleted then
                local tpPart = desc:FindFirstChild("TeleportPosition", true) or desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart", true)
                if tpPart then
                    -- Verify if this generator has monsters near it (within 40 studs)
                    local genPos = tpPart.Position
                    if IsThreatNearby(genPos, 40) then
                        -- If player is currently near this threatened machine, cancel interaction
                        if (hrp.Position - genPos).Magnitude <= 8 then
                            local stopEvent = stats and stats:FindFirstChild("StopInteracting")
                            if stopEvent and stopEvent:IsA("RemoteEvent") then
                                pcall(function() stopEvent:FireServer("Stop") end)
                            end
                        end
                        continue -- Skip this generator and check the next available one
                    end

                    local targetCF = tpPart.CFrame * CFrame.new(0, 2, 0)
                    if (hrp.Position - targetCF.Position).Magnitude > 3 then
                        SafeTeleport(hrp, targetCF)
                        task.wait(0.05)
                    end
                    local prompt = desc:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then TriggerPrompt(prompt) end
                    return
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- SETUP CONTENT & PAGES
--------------------------------------------------------------------------------

local MainPage = CreateTab("Main", "🏠")
local ExtrasPage = CreateTab("Extras", "⭐")

CurrentTab = "Main"
Tabs["Main"].Page.Visible = true
Tabs["Main"].Btn.BackgroundTransparency = 0
Tabs["Main"].Icon.TextColor3 = Colors.TextPrimary
Tabs["Main"].Label.TextColor3 = Colors.TextPrimary

-- Main Page Content
CreateLabelArea(MainPage, "Notice", "This is a very experimental autofarm for Dandy's World. Please report any bugs you encounter to the developer!", 75)

local function GetStatsText()
    local elapsed = autofarmStartTime > 0 and math.floor(tick() - autofarmStartTime) or 0
    local hours = math.floor(elapsed / 3600)
    local mins = math.floor((elapsed % 3600) / 60)
    local secs = elapsed % 60
    local timeStr = string.format("%dh %dm %ds", hours, mins, secs)

    local toon = LocalPlayer:GetAttribute("SelectedToon") or "None"
    local container = GetMapContainer()
    local floorName = container and (container:GetAttribute("FloorName") or container.Name) or "N/A"

    local twistedsCount = 0
    if container then
        for _, d in ipairs(container:GetDescendants()) do
            if d:IsA("Model") and (d.Name:find("Monster") or CollectionService:HasTag(d, "Twisted")) then
                twistedsCount = twistedsCount + 1
            end
        end
    end

    local tapesCount = 0
    local info = workspace:FindFirstChild("Info")
    local ps = info and info:FindFirstChild("PlayerStats")
    local pFolder = ps and ps:FindFirstChild(LocalPlayer.Name)
    local tapesObj = pFolder and (pFolder:FindFirstChild("Tapes") or pFolder:FindFirstChild("SurvivalPoints"))
    if tapesObj and tapesObj:IsA("NumberValue") then
        tapesCount = tapesObj.Value
    end

    return string.format("Autofarm Time: %s\nToon: %s\nFloor: %s\nTwisteds on Floor: %d\nTapes: %d", timeStr, tostring(toon), tostring(floorName), twistedsCount, tapesCount)
end

local SessionCard

CreateToggle(MainPage, "Autofarm", "Enables the autofarm!", function(state)
    SettingsState.AutofarmEnabled = state
    if state then
        autofarmStartTime = tick()
        SessionCard.SetText(GetStatsText())
    else
        autofarmStartTime = 0
        SessionCard.SetText("Waiting for Autofarm to start...")
    end
end)

SessionCard = CreateLabelArea(MainPage, "Session Information", "Waiting for Autofarm to start...", 110)

task.spawn(function()
    while BExtractGui and BExtractGui.Parent do
        if SettingsState.AutofarmEnabled then
            if SessionCard then
                SessionCard.SetText(GetStatsText())
            end
            pcall(ExecuteAutofarmStep)
        end
        task.wait(SettingsState.UpdateInterval)
    end
end)

CreateToggle(MainPage, "Anti-Idle", "Prevents Roblox from kicking you for being AFK", function(state)
    SetAntiIdle(state)
end)

CreateToggle(MainPage, "Epilepsy Helper", "Fixes the camera onto the void to avoid flickering imagery.", function(state)
    SetEpilepsyHelper(state)
end)

-- Extras Page Content
local function CreateSectionLabel(parent, text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Colors.TextPrimary
    Lbl.Font = FontPrimary
    Lbl.TextSize = 14
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = parent
end

CreateSectionLabel(ExtrasPage, "Miscellaneous")

CreateToggle(ExtrasPage, "Twisted ESP", "", function(state)
    SettingsState.TwistedESP = state
    UpdateTwistedESP()
end)

CreateToggle(ExtrasPage, "Item ESP", "", function(state)
    SettingsState.ItemESP = state
    UpdateItemESP()
end)

CreateToggle(ExtrasPage, "Player ESP", "", function(state)
    SettingsState.PlayerESP = state
    RefreshAllESP()
end)

CreateToggle(ExtrasPage, "Ignore Your Character Model", "Prevents Player ESP from highlighting your own character.", function(state)
    SettingsState.IgnoreLocalCharacter = state
    RefreshAllESP()
end)

CreateToggle(ExtrasPage, "Disable rendering", "", function(state)
    SetDisableRendering(state)
end)

local Spacer = Instance.new("Frame")
Spacer.Size = UDim2.new(1, 0, 0, 5)
Spacer.BackgroundTransparency = 1
Spacer.Parent = ExtrasPage

CreateSectionLabel(ExtrasPage, "Autofarm Customization")

CreateDropdown(ExtrasPage, "Autofarm Preset", {"Default (Recommended)", "Safe (Slow)", "Quick"}, 1, function(selected)
    SettingsState.AutofarmPreset = selected
    SettingsState.UpdateInterval = PresetIntervals[selected] or 0.5
end)

CreateSlider(ExtrasPage, "Heal Limit", "Controls how much inventory slots the autofarm preserves for heals.", 0, 3, 2, function(val)
    SettingsState.HealLimit = val
end)

CreateToggle(ExtrasPage, "Disable Capsule Pick up", "", function(state)
    SettingsState.DisableCapsulePickup = state
end)

CreateToggle(ExtrasPage, "Disable Tape Pick up", "", function(state)
    SettingsState.DisableTapePickup = state
end)

CreateToggle(ExtrasPage, "Research Mode", "Encounters Twisteds before picking up items or extracting.", function(state)
    SettingsState.ResearchMode = state
end)

CreateToggle(ExtrasPage, "Auto Vote Cards", "Automatically votes for the highest priority stat/item card when floor voting opens.", function(state)
    SettingsState.AutoVoteCards = state
end)

-- Cleanup Handler
env.BExtractCleanup = function()
    playerAddedConn:Disconnect()
    playerRemovingConn:Disconnect()
    for _, player in ipairs(Players:GetPlayers()) do
        CleanupPlayer(player)
    end
    for _, hl in pairs(TwistedHighlights) do
        if hl then hl:Destroy() end
    end
    for _, hl in pairs(ItemHighlights) do
        if hl then hl:Destroy() end
    end
    if antiIdleConnection then
        antiIdleConnection:Disconnect()
    end
    if epilepsyConnection then
        epilepsyConnection:Disconnect()
        if workspace.CurrentCamera then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end
    pcall(function()
        RunService:Set3dRenderingEnabled(true)
    end)
end

print("BExtract Loaded successfully.")
