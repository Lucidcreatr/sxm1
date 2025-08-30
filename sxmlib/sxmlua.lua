-- SXMLIB.lua

local SXMLIB = {}
SXMLIB.__index = SXMLIB

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Temalar
SXMLIB.Themes = {
    Red = {Background=Color3.fromRGB(30,0,0),Primary=Color3.fromRGB(255,0,0),Text=Color3.fromRGB(255,255,255)},
    Maroon = {Background=Color3.fromRGB(60,0,0),Primary=Color3.fromRGB(128,0,0),Text=Color3.fromRGB(255,255,255)},
    Black = {Background=Color3.fromRGB(10,10,10),Primary=Color3.fromRGB(50,50,50),Text=Color3.fromRGB(255,255,255)},
    Blue = {Background=Color3.fromRGB(0,0,50),Primary=Color3.fromRGB(0,0,255),Text=Color3.fromRGB(255,255,255)},
    White = {Background=Color3.fromRGB(230,230,230),Primary=Color3.fromRGB(255,255,255),Text=Color3.fromRGB(0,0,0)},
    Grey = {Background=Color3.fromRGB(50,50,50),Primary=Color3.fromRGB(100,100,100),Text=Color3.fromRGB(255,255,255)},
    Green = {Background=Color3.fromRGB(0,30,0),Primary=Color3.fromRGB(0,255,0),Text=Color3.fromRGB(255,255,255)},
    Purple = {Background=Color3.fromRGB(40,0,40),Primary=Color3.fromRGB(128,0,128),Text=Color3.fromRGB(255,255,255)},
    Orange = {Background=Color3.fromRGB(50,25,0),Primary=Color3.fromRGB(255,165,0),Text=Color3.fromRGB(0,0,0)},
    Yellow = {Background=Color3.fromRGB(60,60,0),Primary=Color3.fromRGB(255,255,0),Text=Color3.fromRGB(0,0,0)}
}

-- Tema birleştirme
function SXMLIB:MergeTheme(custom)
    local base = self.Themes.Black
    if custom then
        for k,v in pairs(custom) do base[k] = v end
    end
    return base
end

-- GUI başlat
function SXMLIB.new(opts)
    opts = opts or {}
    local self = setmetatable({}, SXMLIB)
    self.Theme = self:MergeTheme(opts.theme)
    self.Windows = {}
    return self
end

-- Notification
function SXMLIB:Notify(text,duration)
    duration = duration or 3
    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame",screenGui)
    frame.Size = UDim2.new(0,200,0,50)
    frame.Position = UDim2.new(0.5,-100,0,100)
    frame.BackgroundColor3 = self.Theme.Primary
    
    local label = Instance.new("TextLabel",frame)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.Text
    label.Text = text
    
    TweenService:Create(frame,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-100,0,120)}):Play()
    task.delay(duration,function() frame:Destroy() screenGui:Destroy() end)
end

-- Window oluştur
function SXMLIB:CreateWindow(opts)
    opts = opts or {}
    local win = {}
    win.Sections = {}
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = opts.Name or "SXMLIB"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame",screenGui)
    main.Size = UDim2.new(0,420,0,300)
    main.Position = UDim2.new(0.5,-210,0.5,-150)
    main.BackgroundColor3 = self.Theme.Background
    main.Name = "MainWindow"
    
    -- TitleBar
    local titleBar = Instance.new("Frame",main)
    titleBar.Size = UDim2.new(1,0,0,32)
    titleBar.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel",titleBar)
    titleLabel.Size = UDim2.new(1,-8,1,0)
    titleLabel.Position = UDim2.new(0,4,0,0)
    titleLabel.Text = opts.Title or "SXMLIB"
    titleLabel.TextColor3 = self.Theme.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    
    local closeBtn = Instance.new("TextButton",titleBar)
    closeBtn.Text = "X"
    closeBtn.AnchorPoint = Vector2.new(1,0)
    closeBtn.Position = UDim2.new(1,-4,0,0)
    closeBtn.Size = UDim2.new(0,28,1,0)
    closeBtn.BackgroundColor3 = self.Theme.Primary
    closeBtn.TextColor3 = self.Theme.Text
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local content = Instance.new("Frame",main)
    content.Size = UDim2.new(1,0,1,-32)
    content.Position = UDim2.new(0,0,0,32)
    content.BackgroundTransparency = 1
    
    -- Drag mekanizması
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
                                      startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    
    win._gui = {ScreenGui=screenGui, Main=main, Content=content}
    
    -- Section ekleme
    function win:CreateSection(title)
        local sec = {}
        sec.Elements = {}
        
        local frame = Instance.new("Frame",content)
        frame.Size = UDim2.new(1,-8,0,120)
        frame.Position = UDim2.new(0,4,0,#content:GetChildren()*126)
        frame.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel",frame)
        label.Text = title or "Section"
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.TextColor3 = self.Theme.Text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        
        sec._gui = frame
        
        -- Toggle
        function sec:Toggle(opts)
            local btn = Instance.new("TextButton",frame)
            btn.Text = opts.label or "Toggle"
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,#sec.Elements*32)
            btn.BackgroundColor3 = self.Theme.Primary
            btn.TextColor3 = self.Theme.Text
            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = (state and "On" or "Off").." - "..(opts.label or "Toggle")
                if opts.callback then opts.callback(state) end
            end)
            table.insert(sec.Elements,btn)
            return btn
        end
        
        -- Slider
        function sec:Slider(opts)
            local sld = Instance.new("Frame",frame)
            sld.Size = UDim2.new(0,200,0,28)
            sld.Position = UDim2.new(0,0,0,#sec.Elements*32)
            sld.BackgroundColor3 = self.Theme.Primary
            local fill = Instance.new("Frame",sld)
            fill.Size = UDim2.new(0,0,1,0)
            fill.BackgroundColor3 = self.Theme.Text
            local dragging = false
            sld.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            sld.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp(input.Position.X - sld.AbsolutePosition.X,0,sld.AbsoluteSize.X)
                    fill.Size = UDim2.new(0,rel,1,0)
                    if opts.callback then opts.callback(rel/sld.AbsoluteSize.X) end
                end
            end)
            table.insert(sec.Elements,sld)
            return sld
        end
        
        -- Button
        function sec:Button(opts)
            local btn = Instance.new("TextButton",frame)
            btn.Text = opts.label or "Button"
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,#sec.Elements*32)
            btn.BackgroundColor3 = self.Theme.Primary
            btn.TextColor3 = self.Theme.Text
            btn.MouseButton1Click:Connect(function()
                if opts.callback then opts.callback() end
            end)
            table.insert(sec.Elements,btn)
            return btn
        end
        
        -- Keybind
        function sec:Keybind(opts)
            local btn = Instance.new("TextButton",frame)
            btn.Text = "Key: "..tostring(opts.default or Enum.KeyCode.Unknown)
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,#sec.Elements*32)
            local key = opts.default or Enum.KeyCode.Unknown
            btn.MouseButton1Click:Connect(function()
                btn.Text = "Press a key..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        btn.Text = "Key: "..tostring(key)
                        if opts.callback then opts.callback(key) end
                        conn:Disconnect()
                    end
                end)
            end)
            table.insert(sec.Elements,btn)
            return btn
        end
        
        table.insert(win.Sections,sec)
        return sec
    end
    
    table.insert(self.Windows,win)
    return win
end

return SXMLIB
