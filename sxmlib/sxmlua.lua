-- SXMLIB.lua (Sıfırdan, Minimal & Güvenli)
local SXMLIB = {}
SXMLIB.__index = SXMLIB

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
    local self = setmetatable({}, SXMLIB)
    self.Theme = self:MergeTheme(opts and opts.Theme)
    self.Windows = {}
    return self
end

-- Bildirim
function SXMLIB:Notify(text,duration)
    duration = duration or 3
    local gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,200,0,50)
    frame.Position = UDim2.new(0.5,-100,0,50)
    frame.BackgroundColor3 = self.Theme.Primary
    frame.AnchorPoint = Vector2.new(0.5,0)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.Text
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

    TweenService:Create(frame,TweenInfo.new(0.4),{Position=UDim2.new(0.5,-100,0,50)}):Play()

    task.delay(duration,function()
        TweenService:Create(frame,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-100,0,0),BackgroundTransparency=1}):Play()
        task.wait(0.35)
        gui:Destroy()
    end)
end

-- Window oluştur
function SXMLIB:CreateWindow(opts)
    opts = opts or {}
    local win = {Sections={}, _gui={}}

    local gui = Instance.new("ScreenGui")
    gui.Name = opts.Name or "SXMLIB"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0,420,0,300)
    main.Position = UDim2.new(0.5,-210,0.5,-150)
    main.BackgroundColor3 = self.Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true

    -- Title
    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1,0,0,32)
    titleBar.BackgroundTransparency = 1

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1,-8,1,0)
    titleLabel.Position = UDim2.new(0,4,0,0)
    titleLabel.Text = opts.Title or "SXMLIB"
    titleLabel.TextColor3 = self.Theme.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14

    -- Close
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Text = "X"
    closeBtn.AnchorPoint = Vector2.new(1,0)
    closeBtn.Position = UDim2.new(1,-4,0,0)
    closeBtn.Size = UDim2.new(0,28,1,0)
    closeBtn.BackgroundColor3 = self.Theme.Primary
    closeBtn.TextColor3 = self.Theme.Text
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1,0,1,-32)
    content.Position = UDim2.new(0,0,0,32)
    content.BackgroundTransparency = 1

    win._gui = {ScreenGui=gui, Main=main, Content=content}

    -- Section ekleme
    function win:Section(title)
        local sec = {Elements={}, ElementsRegistry={}}
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1,-8,0,28)
        frame.Position = UDim2.new(0,4,0,#content:GetChildren()*32)
        frame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", frame)
        label.Text = title or "Section"
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.TextColor3 = self.Theme.Text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14

        sec._gui = frame

        -- Button
        function sec:Button(opts)
            local btn = Instance.new("TextButton", frame)
            btn.Text = opts.label or "Button"
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,#sec.Elements*32)
            btn.BackgroundColor3 = self.Theme.Primary
            btn.TextColor3 = self.Theme.Text
            btn.MouseButton1Click:Connect(function() if opts.callback then opts.callback() end end)
            table.insert(sec.Elements,btn)
            sec.ElementsRegistry[opts.label] = btn
            return btn
        end

        -- Toggle
        function sec:Toggle(opts)
            local btn = Instance.new("TextButton", frame)
            btn.Text = (opts.default and "On" or "Off").." - "..(opts.label or "Toggle")
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,#sec.Elements*32)
            btn.BackgroundColor3 = self.Theme.Primary
            btn.TextColor3 = self.Theme.Text
            local state = opts.default or false
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = (state and "On" or "Off").." - "..(opts.label or "Toggle")
                if opts.callback then opts.callback(state) end
            end)
            table.insert(sec.Elements,btn)
            sec.ElementsRegistry[opts.label] = btn
            return btn
        end

        -- Slider
        function sec:Slider(opts)
            local sld = Instance.new("Frame", frame)
            sld.Size = UDim2.new(0,200,0,28)
            sld.Position = UDim2.new(0,0,0,#sec.Elements*32)
            sld.BackgroundColor3 = self.Theme.Primary
            local fill = Instance.new("Frame", sld)
            fill.Size = UDim2.new(0,0,1,0)
            fill.BackgroundColor3 = self.Theme.Text
            local dragging = false
            sld.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
            sld.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
                    local rel = math.clamp(input.Position.X-sld.AbsolutePosition.X,0,sld.AbsoluteSize.X)
                    fill.Size = UDim2.new(0,rel,1,0)
                    if opts.callback then opts.callback(rel/sld.AbsoluteSize.X) end
                end
            end)
            table.insert(sec.Elements,sld)
            sec.ElementsRegistry[opts.label] = sld
            return sld
        end

        table.insert(win.Sections, sec)
        return sec
    end

    table.insert(self.Windows, win)
    return win
end

return SXMLIB
