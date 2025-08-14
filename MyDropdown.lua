
-- MyDropdown.lua (standalone WindUI-like dropdown)
-- Usage:
--   local MyDropdown = require(path.To.MyDropdown)
--   local dd = MyDropdown.new(parent, {
--       Title = "Select Option",
--       Items = {"One","Two","Three"},
--       Default = "One",
--       Size = UDim2.new(1, -20, 0, 40),
--       Corner = 8,
--       Callback = function(value, index) print(value, index) end
--   })
--   dd:SetItems({...})
--   dd:SetValue("New")
--   dd:GetValue()
local TweenService = game:GetService("TweenService")

local MyDropdown = {}
MyDropdown.__index = MyDropdown

local function tween(o, t, props, style, dir)
    local info = TweenInfo.new(t or 0.14, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(o, info, props):Play()
end

local function createItem(parent, text, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.Position = UDim2.new(0, 4, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(235, 235, 240)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = Color3.fromRGB(38,38,44)}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.12, {BackgroundColor3 = Color3.fromRGB(32,32,36)}) end)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

function MyDropdown.new(parent, opt)
    opt = opt or {}
    local self = setmetatable({}, MyDropdown)

    local holder = Instance.new("Frame")
    holder.Name = "Dropdown"
    holder.BackgroundColor3 = Color3.fromRGB(26,26,30)
    holder.Size = opt.Size or UDim2.new(1, -20, 0, 40)
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, opt.Corner or 8)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -120, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = opt.Title or "Dropdown"
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(235,235,240)
    label.Parent = holder

    local valueBtn = Instance.new("TextButton")
    valueBtn.Size = UDim2.new(0, 110, 0, 28)
    valueBtn.Position = UDim2.new(1, -120, 0.5, -14)
    valueBtn.BackgroundColor3 = Color3.fromRGB(46,134,222)
    valueBtn.TextColor3 = Color3.fromRGB(255,255,255)
    valueBtn.Font = Enum.Font.GothamBold
    valueBtn.TextSize = 12
    valueBtn.AutoButtonColor = false
    valueBtn.Text = opt.Default or (opt.Items and opt.Items[1]) or "Select"
    valueBtn.Parent = holder
    Instance.new("UICorner", valueBtn).CornerRadius = UDim.new(0, 8)

    -- Dropdown list container (floating panel)
    local listHolder = Instance.new("Frame")
    listHolder.Visible = false
    listHolder.BackgroundColor3 = Color3.fromRGB(20,20,24)
    listHolder.BorderSizePixel = 0
    listHolder.Size = UDim2.new(0, 220, 0, 0)
    listHolder.Position = UDim2.new(0, holder.AbsolutePosition.X, 0, holder.AbsolutePosition.Y + holder.AbsoluteSize.Y)
    listHolder.Parent = holder

    local lcorner = Instance.new("UICorner", listHolder)
    lcorner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", listHolder)
    stroke.Color = Color3.fromRGB(40,40,46)
    stroke.Thickness = 1

    local listLayout = Instance.new("UIListLayout", listHolder)
    listLayout.Padding = UDim.new(0, 6)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", listHolder)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)

    local items = opt.Items or {}
    local currentIndex = 1
    local function rebuild()
        for _, c in ipairs(listHolder:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, v in ipairs(items) do
            createItem(listHolder, tostring(v), function()
                currentIndex = i
                valueBtn.Text = tostring(v)
                tween(listHolder, 0.14, {Size = UDim2.new(0, 220, 0, 0)})
                listHolder.Visible = false
                if opt.Callback then opt.Callback(v, i) end
            end)
        end
        local h = #items * (28 + 6) + 16
        listHolder.Size = UDim2.new(0, 220, 0, math.clamp(h, 0, 220))
    end

    local function open()
        local absGui = holder.Parent
        -- reparent panel to ScreenGui to float outside clipping
        while absGui and not absGui:IsA("ScreenGui") do absGui = absGui.Parent end
        if absGui then listHolder.Parent = absGui end
        local pos = holder.AbsolutePosition
        listHolder.Position = UDim2.fromOffset(pos.X, pos.Y + holder.AbsoluteSize.Y + 4)
        listHolder.Visible = true
        tween(listHolder, 0.12, {Size = UDim2.new(0, 220, 0, listHolder.Size.Y.Offset)})
    end
    local function close()
        tween(listHolder, 0.12, {Size = UDim2.new(0, 220, 0, 0)})
        task.delay(0.12, function() listHolder.Visible = false end)
    end

    valueBtn.MouseButton1Click:Connect(function()
        if not listHolder.Visible then open() else close() end
    end)

    holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if listHolder.Visible then
            local pos = holder.AbsolutePosition
            listHolder.Position = UDim2.fromOffset(pos.X, pos.Y + holder.AbsoluteSize.Y + 4)
        end
    end)

    self._holder = holder
    self._label = label
    self._valueBtn = valueBtn
    self._listHolder = listHolder
    self._items = items
    self._index = currentIndex

    rebuild()

    function self:SetItems(newItems)
        items = newItems or {}
        self._items = items
        rebuild()
    end

    function self:SetValue(valOrIndex)
        if typeof(valOrIndex) == "number" then
            self._index = math.clamp(valOrIndex, 1, #self._items)
            self._valueBtn.Text = tostring(self._items[self._index])
        else
            for i, v in ipairs(self._items) do
                if v == valOrIndex then
                    self._index = i
                    self._valueBtn.Text = tostring(v)
                    break
                end
            end
        end
    end

    function self:GetValue()
        return self._items[self._index], self._index
    end

    return self
end

return MyDropdown
