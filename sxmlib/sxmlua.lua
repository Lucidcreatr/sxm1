-- SXMLIB.lua (Çalışan Sürüm)
local SXMLIB = {}
SXMLIB.__index = SXMLIB

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Temalar
SXMLIB.Themes = {
    Blue = {Background=Color3.fromRGB(20,20,50), Primary=Color3.fromRGB(0,120,255), Text=Color3.fromRGB(255,255,255)},
    Gray = {Background=Color3.fromRGB(30,30,30), Primary=Color3.fromRGB(100,100,100), Text=Color3.fromRGB(255,255,255)},
}

function SXMLIB:MergeTheme(custom)
    local base = self.Themes.Gray
    if custom then
        for k,v in pairs(custom) do base[k]=v end
    end
    return base
end

function SXMLIB.new(opts)
    opts = opts or {}
    local self = setmetatable({}, SXMLIB)
    self.Theme = self:MergeTheme(opts.Theme)
    self.Windows = {}
    return self
end

function SXMLIB:Notify(text, duration)
    duration = duration or 2
    local sg = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
    sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0.5, -100, 0, 50)
    frame.BackgroundColor3 = self.Theme.Primary
    frame.AnchorPoint = Vector2.new(0.5,0)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.Text
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    task.delay(duration, function() sg:Destroy() end)
end

function SXMLIB:CreateWindow(opts)
    opts = opts or {}
    local win = {}
    win.Sections = {}
    
    local sg = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
    sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 400, 0, 300)
    main.Position = UDim2.new(0.5, -200, 0.5, -150)
    main.BackgroundColor3 = self.Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true

    -- Drag
    local dragging = false
    local dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)

    -- Title
    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundTransparency = 1
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Text = opts.Title or "SXMLIB"
    titleLabel.Size = UDim2.new(1,0,1,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = self.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16

    win._gui = {ScreenGui=sg, Main=main, Content=main}

    -- Section ekleme
    function win:Section(title)
        local sec = {}
        sec.Elements = {}
        local frame = Instance.new("Frame", main)
        frame.Size = UDim2.new(1,-20,0,30)
        frame.Position = UDim2.new(0,10,0,40 + #self.Sections*70)
        frame.BackgroundTransparency = 0
        frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        local label = Instance.new("TextLabel", frame)
        label.Text = title
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.TextColor3 = self.Theme.Text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14

        -- Toggle
        function sec:Toggle(opts)
            local btn = Instance.new("TextButton", frame)
            btn.Text = opts.label.." (Off)"
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,20 + #sec.Elements*30)
            btn.BackgroundColor3 = SXMLIB.Themes.Gray.Primary
            btn.TextColor3 = self.Theme.Text
            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = opts.label.." ("..(state and "On" or "Off")..")"
                if opts.callback then opts.callback(state) end
            end)
            table.insert(sec.Elements, btn)
            return btn
        end

        -- Button
        function sec:Button(opts)
            local btn = Instance.new("TextButton", frame)
            btn.Text = opts.label
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,20 + #sec.Elements*30)
            btn.BackgroundColor3 = self.Theme.Primary
            btn.TextColor3 = self.Theme.Text
            btn.MouseButton1Click:Connect(function() if opts.callback then opts.callback() end end)
            table.insert(sec.Elements, btn)
            return btn
        end

        table.insert(self.Sections, sec)
        return sec
    end

    table.insert(self.Windows, win)
    return win
end

return SXMLIB
