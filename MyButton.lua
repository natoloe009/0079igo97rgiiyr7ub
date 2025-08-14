
-- MyButton.lua (standalone WindUI-like button)
-- Usage:
--   local MyButton = require(path.To.MyButton)
--   local btn = MyButton.new(parent, {
--       Text = "Click Me",
--       Size = UDim2.new(0, 120, 0, 32),
--       Position = UDim2.new(0, 0, 0, 0),
--       Corner = 8,
--       Color = Color3.fromRGB(46, 204, 113),
--       TextColor = Color3.fromRGB(255,255,255),
--       Font = Enum.Font.GothamBold,
--       TextSize = 12,
--       Callback = function() print("clicked") end
--   })
--   btn:SetEnabled(true/false)
--   btn:SetText("New")
local TweenService = game:GetService("TweenService")

local MyButton = {}
MyButton.__index = MyButton

local function tween(o, t, props, style, dir)
    local info = TweenInfo.new(t or 0.12, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(o, info, props):Play()
end

function MyButton.new(parent, opt)
    opt = opt or {}
    local self = setmetatable({}, MyButton)

    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = opt.Size or UDim2.new(0, 140, 0, 40)
    holder.Position = opt.Position or UDim2.new(0, 0, 0, 0)
    holder.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = opt.Color or Color3.fromRGB(46, 134, 222)
    btn.AutoButtonColor = false
    btn.Text = opt.Text or "Button"
    btn.TextColor3 = opt.TextColor or Color3.fromRGB(245,245,245)
    btn.Font = opt.Font or Enum.Font.GothamBold
    btn.TextSize = opt.TextSize or 12
    btn.Parent = holder

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, opt.Corner or 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(30,30,36)

    -- Hover & press animations
    local base = btn.BackgroundColor3
    local hover = Color3.fromRGB(
        math.clamp(base.R*255 + 12, 0, 255),
        math.clamp(base.G*255 + 12, 0, 255),
        math.clamp(base.B*255 + 12, 0, 255)
    )
    local down = Color3.fromRGB(
        math.clamp(base.R*255 - 15, 0, 255),
        math.clamp(base.G*255 - 15, 0, 255),
        math.clamp(base.B*255 - 15, 0, 255)
    )

    btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = hover}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.12, {BackgroundColor3 = base}) end)
    btn.MouseButton1Down:Connect(function() tween(btn, 0.08, {BackgroundColor3 = down, Position = UDim2.new(0,0,0,1)}) end)
    btn.MouseButton1Up:Connect(function() tween(btn, 0.10, {BackgroundColor3 = hover, Position = UDim2.new(0,0,0,0)}) end)
    btn.MouseButton1Click:Connect(function()
        if self.Enabled ~= false and opt.Callback then
            opt.Callback()
        end
    end)

    self._holder = holder
    self._btn = btn
    self.Enabled = true

    return self
end

function MyButton:GetInstance()
    return self._btn
end

function MyButton:SetEnabled(on)
    self.Enabled = on and true or false
    self._btn.AutoButtonColor = false
    self._btn.Active = self.Enabled
    self._btn.TextTransparency = self.Enabled and 0 or 0.4
    self._btn.BackgroundTransparency = self.Enabled and 0 or 0.2
end

function MyButton:SetText(t)
    self._btn.Text = t
end

return MyButton
