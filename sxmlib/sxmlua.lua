-- SXMLIB.lua (Full Geliştirilmiş, Animasyonlu & Efektli)

local SXMLIB = {}
SXMLIB.__index = SXMLIB

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Temalar
SXMLIB.Themes = {
    Red = {Background=Color3.fromRGB(30,0,0),Primary=Color3.fromRGB(255,0,0),Text=Color3.fromRGB(255,255,255)},
    Blue = {Background=Color3.fromRGB(0,0,50),Primary=Color3.fromRGB(0,0,255),Text=Color3.fromRGB(255,255,255)},
    Black = {Background=Color3.fromRGB(10,10,10),Primary=Color3.fromRGB(50,50,50),Text=Color3.fromRGB(255,255,255)},
}

function SXMLIB:MergeTheme(custom)
    local base = self.Themes.Black
    if custom then
        for k,v in pairs(custom) do base[k] = v end
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

-- Bildirim
function SXMLIB:Notify(text,duration)
    duration = duration or 3
    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame",screenGui)
    frame.Size = UDim2.new(0,200,0,50)
    frame.Position = UDim2.new(0.5,-100,0,0)
    frame.AnchorPoint = Vector2.new(0.5,0)
    frame.BackgroundColor3 = self.Theme.Primary
    frame.BackgroundTransparency = 0.2
    
    local label = Instance.new("TextLabel",frame)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.Text
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

    TweenService:Create(frame,TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-100,0,50)}):Play()
    
    task.delay(duration,function()
        TweenService:Create(frame,TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),{Position=UDim2.new(0.5,-100,0,0),BackgroundTransparency=1}):Play()
        task.wait(0.35)
        screenGui:Destroy()
    end)
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
    main.Size = UDim2.new(0,0,0,0)
    main.Position = UDim2.new(0.5,-210,0.5,-150)
    main.BackgroundColor3 = self.Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    TweenService:Create(main,TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),{Size=UDim2.new(0,420,0,300)}):Play()
    
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
    closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0) end)
    closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = self.Theme.Primary end)
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(main,TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0)}):Play()
        task.wait(0.4)
        screenGui:Destroy()
    end)
    
    local content = Instance.new("Frame",main)
    content.Size = UDim2.new(1,0,1,-32)
    content.Position = UDim2.new(0,0,0,32)
    content.BackgroundTransparency = 1
    
    -- Drag
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    
    win._gui = {ScreenGui=screenGui, Main=main, Content=content}
    
    -- Section ekleme
    function win:CreateSection(title)
        local sec = {}
        sec.Elements = {}
        sec.ElementsRegistry = {}
        
        local frame = Instance.new("Frame",content)
        frame.Size = UDim2.new(1,-8,0,28)
        frame.Position = UDim2.new(0,4,0,#content:GetChildren()*32)
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
                TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundTransparency = state and 0.3 or 0}):Play()
                if opts.callback then opts.callback(state) end
            end)
            table.insert(sec.Elements,btn)
            sec.ElementsRegistry[opts.label] = btn
            return btn
        end
        
        -- Button
        function sec:Button(opts)
            local btn = Instance.new("TextButton",frame)
            btn.Text = opts.label or "Button"
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,#sec.Elements*32)
            btn.BackgroundColor3 = self.Theme.Primary
            btn.TextColor3 = self.Theme.Text
            btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundTransparency=0.3}):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundTransparency=0}):Play() end)
            btn.MouseButton1Click:Connect(function() if opts.callback then opts.callback() end end)
            table.insert(sec.Elements,btn)
            sec.ElementsRegistry[opts.label] = btn
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
            sec.ElementsRegistry[opts.label] = sld
            return sld
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
            sec.ElementsRegistry[opts.label] = btn
            return btn
        end
        
        -- Dropdown
        function sec:Dropdown(opts)
            local drop = Instance.new("TextButton",frame)
            drop.Text = opts.label or "Dropdown"
            drop.Size = UDim2.new(0,150,0,28)
            drop.Position = UDim2.new(0,0,0,#sec.Elements*32)
            drop.BackgroundColor3 = self.Theme.Primary
            drop.TextColor3 = self.Theme.Text
            
            local open = false
            local listFrame = Instance.new("Frame",frame)
            listFrame.Size = UDim2.new(1,0,0,#opts.options*28)
            listFrame.Position = UDim2.new(0,0,1,0)
            listFrame.BackgroundColor3 = self.Theme.Background
            listFrame.Visible = false
            
            for i,opt in ipairs(opts.options) do
                local b = Instance.new("TextButton",listFrame)
                b.Text = opt
                b.Size = UDim2.new(1,0,0,28)
                b.Position = UDim2.new(0,0,0,(i-1)*28)
                b.BackgroundColor3 = self.Theme.Primary
                b.TextColor3 = self.Theme.Text
                b.MouseButton1Click:Connect(function()
                    drop.Text = opt
                    listFrame.Visible = false
                    open = false
                    if opts.callback then opts.callback(opt) end
                end)
            end
            
            drop.MouseButton1Click:Connect(function()
                open = not open
                listFrame.Visible = open
            end)
            
            table.insert(sec.Elements,drop)
            sec.ElementsRegistry[opts.label] = drop
            return drop
        end
        
        table.insert(win.Sections,sec)
        return sec
    end

    -- Global element çağırma
    function win:GetElement(sectionTitle, elementLabel)
        for _,sec in ipairs(self.Sections) do
            if sec._gui:FindFirstChildWhichIsA("TextLabel") and sec._gui:FindFirstChildWhichIsA("TextLabel").Text == sectionTitle then
                return sec.ElementsRegistry[elementLabel]
            end
        end
        return nil
    end
    
    table.insert(self.Windows,win)
    return win
end

return SXMLIB
