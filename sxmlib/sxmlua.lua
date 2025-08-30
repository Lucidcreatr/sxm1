-- MinimalSXMLIB.lua
local SXMLIB = {}
SXMLIB.__index = SXMLIB

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Temalar
SXMLIB.Themes = {
    Blue = {Background=Color3.fromRGB(30,30,60), Primary=Color3.fromRGB(0,120,255), Text=Color3.fromRGB(255,255,255)}
}

function SXMLIB.new(opts)
    local self = setmetatable({}, SXMLIB)
    self.Theme = opts.Theme or SXMLIB.Themes.Blue
    self.Windows = {}
    return self
end

function SXMLIB:CreateWindow(title)
    local win = {}
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = title or "SXMLIB_Window"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,400,0,300)
    main.Position = UDim2.new(0.5,-200,0.5,-150)
    main.BackgroundColor3 = self.Theme.Background
    main.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,0,0,30)
    titleLabel.Text = title or "Window"
    titleLabel.TextColor3 = self.Theme.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = main

    win._gui = {ScreenGui=screenGui, Main=main, Content=main}
    win.Sections = {}

    function win:Section(name)
        local sec = {}
        sec.Elements = {}
        local yOffset = 40 + #self.Sections*60
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,-20,0,50)
        frame.Position = UDim2.new(0,10,0,yOffset)
        frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        frame.Parent = main

        local label = Instance.new("TextLabel")
        label.Text = name
        label.Size = UDim2.new(1,0,0,20)
        label.TextColor3 = self._gui.Main.BackgroundColor3
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = frame

        function sec:Button(opts)
            local btn = Instance.new("TextButton")
            btn.Text = opts.label or "Button"
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,0,0,20 + #sec.Elements*30)
            btn.BackgroundColor3 = self._gui.Main.BackgroundColor3
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Parent = frame
            btn.MouseButton1Click:Connect(function()
                if opts.callback then opts.callback() end
            end)
            table.insert(sec.Elements, btn)
            return btn
        end

        function sec:Toggle(opts)
            local btn = Instance.new("TextButton")
            btn.Text = opts.label.." (Off)"
            btn.Size = UDim2.new(0,150,0,28)
            btn.Position = UDim2.new(0,160,0,20 + #sec.Elements*30)
            btn.BackgroundColor3 = self._gui.Main.BackgroundColor3
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Parent = frame
            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = opts.label.." ("..(state and "On" or "Off")..")"
                if opts.callback then opts.callback(state) end
            end)
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
