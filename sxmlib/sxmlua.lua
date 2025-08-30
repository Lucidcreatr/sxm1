-- SXMLIB.lua (Geliştirilmiş, Tab Destekli, Modern Tema)
local SXMLIB = {}
SXMLIB.__index = SXMLIB

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Temalar
SXMLIB.Themes = {
    Black = {Background=Color3.fromRGB(20,20,20), Primary=Color3.fromRGB(40,40,40), Accent=Color3.fromRGB(80,80,80), Text=Color3.fromRGB(255,255,255)},
    White = {Background=Color3.fromRGB(245,245,245), Primary=Color3.fromRGB(220,220,220), Accent=Color3.fromRGB(180,180,180), Text=Color3.fromRGB(0,0,0)},
}

function SXMLIB:MergeTheme(custom)
    local base = self.Themes.Black
    if custom then
        for k,v in pairs(custom) do base[k] = v end
    end
    return base
end

function SXMLIB.new(opts)
    local self = setmetatable({}, SXMLIB)
    self.Theme = self:MergeTheme(opts.Theme)
    self.Windows = {}
    return self
end

-- Notification
function SXMLIB:Notify(text, duration)
    duration = duration or 3
    local gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 250, 0, 50)
    frame.Position = UDim2.new(0.5, -125, 0, 50)
    frame.BackgroundColor3 = self.Theme.Primary
    frame.BackgroundTransparency = 0.2
    frame.AnchorPoint = Vector2.new(0.5,0)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.Text
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

    TweenService:Create(frame,TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.new(0.5,-125,0,50)}):Play()

    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position=UDim2.new(0.5,-125,0,0), BackgroundTransparency=1}):Play()
        task.wait(0.35)
        gui:Destroy()
    end)
end

-- Window
function SXMLIB:Window(opts)
    opts = opts or {}
    local win = {}
    win.Tabs = {}
    win.Sections = {}

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = opts.Name or "SXMLIB"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    mainFrame.BackgroundColor3 = self.Theme.Background
    mainFrame.ClipsDescendants = true
    mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
    mainFrame.BorderSizePixel = 0
    mainFrame.Rounding = 8

    -- Tab Bar
    local tabBar = Instance.new("Frame", mainFrame)
    tabBar.Size = UDim2.new(1,0,0,30)
    tabBar.Position = UDim2.new(0,0,0,0)
    tabBar.BackgroundColor3 = self.Theme.Primary

    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Size = UDim2.new(1,0,1,-30)
    contentFrame.Position = UDim2.new(0,0,0,30)
    contentFrame.BackgroundTransparency = 1

    win._gui = {Main=mainFrame, TabBar=tabBar, Content=contentFrame}

    -- Create Tab
    function win:Tab(name)
        local tabButton = Instance.new("TextButton", tabBar)
        tabButton.Text = name
        tabButton.BackgroundColor3 = self.Theme.Primary
        tabButton.TextColor3 = self.Theme.Text
        tabButton.Size = UDim2.new(0,100,1,0)
        tabButton.Position = UDim2.new(#self.Tabs * 0, 100, 0, 0)

        local tabContent = Instance.new("Frame", contentFrame)
        tabContent.Size = UDim2.new(1,0,1,0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false

        tabButton.MouseButton1Click:Connect(function()
            for _,t in pairs(self.Tabs) do t.Content.Visible = false end
            tabContent.Visible = true
        end)

        local tabData = {Button=tabButton, Content=tabContent, Sections={}}
        table.insert(self.Tabs, tabData)

        function tabData:Section(title)
            local sec = {}
            sec.Elements = {}

            local secFrame = Instance.new("Frame", tabContent)
            secFrame.Size = UDim2.new(1, -20, 0, 30)
            secFrame.Position = UDim2.new(0,10,0,#tabData.Sections*35)
            secFrame.BackgroundColor3 = self.Theme.Accent

            local label = Instance.new("TextLabel", secFrame)
            label.Text = title
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 1
            label.TextColor3 = self.Theme.Text
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14

            sec._gui = secFrame

            -- Button
            function sec:Button(opts)
                local btn = Instance.new("TextButton", secFrame)
                btn.Text = opts.label or "Button"
                btn.Size = UDim2.new(0,120,0,25)
                btn.Position = UDim2.new(0,0,0,#sec.Elements*30 + 30)
                btn.BackgroundColor3 = self.Theme.Primary
                btn.TextColor3 = self.Theme.Text
                btn.MouseButton1Click:Connect(function()
                    if opts.callback then opts.callback() end
                end)
                table.insert(sec.Elements, btn)
                return btn
            end

            table.insert(tabData.Sections, sec)
            return sec
        end

        return tabData
    end

    table.insert(self.Windows, win)
    return win
end

return SXMLIB
