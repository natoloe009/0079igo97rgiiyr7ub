local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Dark = {
			Main = Color3.fromRGB(20, 20, 20),
			Second = Color3.fromRGB(30, 30, 30),
			Third = Color3.fromRGB(40, 40, 40),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(70, 70, 70),
			Text = Color3.fromRGB(240,240,240),
			TextDark = Color3.fromRGB(150, 150, 150),
			Accent = Color3.fromRGB(0, 120, 215),
			Success = Color3.fromRGB(76, 175, 80),
			Warning = Color3.fromRGB(255, 152, 0),
			Error = Color3.fromRGB(244, 67, 54)
		},
		Light = {
			Main = Color3.fromRGB(240, 240, 240),
			Second = Color3.fromRGB(220, 220, 220),
			Third = Color3.fromRGB(200, 200, 200),
			Stroke = Color3.fromRGB(180, 180, 180),
			Divider = Color3.fromRGB(160, 160, 160),
			Text = Color3.fromRGB(30, 30, 30),
			TextDark = Color3.fromRGB(100, 100, 100),
			Accent = Color3.fromRGB(0, 120, 215),
			Success = Color3.fromRGB(76, 175, 80),
			Warning = Color3.fromRGB(255, 152, 0),
			Error = Color3.fromRGB(244, 67, 54)
		}
	},
	SelectedTheme = "Dark",
	Folder = nil,
	SaveCfg = false
}

--Feather Icons https://github.com/evoincorp/lucideblox/tree/master/src/modules/util - Created by 7kayoh
local Icons = {}

local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/natoloe009/TEST-ANYTHING-/refs/heads/main/icons.json")).icons
end)

if not Success then
	warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end	

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
end   

local Orion = Instance.new("ScreenGui")
guiRH = Instance.new("ScreenGui",Orion)
nextb = Instance.new("ImageButton", guiRH)
gui = Instance.new("UICorner", nextb)

Orion.Name = "KaGa HUB <Orion Lib>"

guiRH.Name = "Minimize"
nextb.Position = UDim2.new(0,100,0,60)
nextb.Size = UDim2.new(0,40,0,40)
nextb.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
nextb.Image = "rbxassetid://7072720870"
nextb.Visible = false
nextb.Active = true
nextb.Draggable = true

nextb.MouseButton1Down:connect(function()
  nextb.Image = (Orion.Frame1.Visible and "rbxassetid://7072720870") or "rbxassetid://7072719338"
  Orion.Frame1.Visible = not Orion.Frame1.Visible
end)

if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function OrionLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end
end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do
		wait()
	end

	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				Main.Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			end
		end)
	end)
end    

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = OrionLib.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end    
	table.insert(OrionLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
	return Object
end    

local function SetTheme(ThemeName)
	if OrionLib.Themes[ThemeName] then
		OrionLib.SelectedTheme = ThemeName
		for Name, Type in pairs(OrionLib.ThemeObjects) do
			for _, Object in pairs(Type) do
				Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
			end    
		end    
	end
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if OrionLib.Flags[a] then
			spawn(function() 
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end    
			end)
		else
			warn("Orion Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(OrionLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})

	if GetIcon(ImageID) ~= nil then
		ImageNew.Image = GetIcon(ImageID)
	end	

	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "No content provided."
		NotificationConfig.Image = NotificationConfig.Image or "info"
		NotificationConfig.Time = NotificationConfig.Time or 5
		
		local Notification = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
			SetProps(MakeElement("Stroke", nil, 1), {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}),
			SetProps(MakeElement("Padding", 8, 8, 8, 8), {
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12)
			}),
			SetProps(MakeElement("TFrame"), {
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				SetChildren(MakeElement("TFrame"), {
					SetProps(MakeElement("List"), {
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal
					}),
					SetChildren(MakeElement("TFrame"), {
						SetProps(MakeElement("Image", NotificationConfig.Image), {
							Size = UDim2.new(0, 18, 0, 18)
						}),
						SetProps(MakeElement("Label", NotificationConfig.Name, 14), {
							Size = UDim2.new(1, -18, 0, 18),
							TextXAlignment = Enum.TextXAlignment.Left
						})
					}, {
						LayoutOrder = 1
					}),
					SetProps(MakeElement("Label", NotificationConfig.Content, 12), {
						TextWrapped = true,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y
					}, {
						LayoutOrder = 2
					})
				}, {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y
				})
			}, {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y
			})
		}), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = #NotificationHolder:GetChildren() - 1,
			Parent = NotificationHolder
		})
		
		AddThemeObject(Notification, "Second")
		AddThemeObject(Notification.UIStroke, "Stroke")
		AddThemeObject(Notification.Frame.Frame.Frame.ImageLabel, "Text")
		AddThemeObject(Notification.Frame.Frame.Frame.TextLabel, "Text")
		AddThemeObject(Notification.Frame.Frame.TextLabel, "Text")
		
		task.wait(NotificationConfig.Time)
		
		local Tween = TweenService:Create(Notification, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
		Tween:Play()
		Tween.Completed:Wait()
		Notification:Destroy()
	end)
end

function OrionLib:MakeWindow(WindowConfig)
	WindowConfig.Name = WindowConfig.Name or "Window"
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or "OrionLib"
	WindowConfig.IntroEnabled = WindowConfig.IntroEnabled or false
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Lib"
	
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig
	
	if WindowConfig.IntroEnabled then
		OrionLib:MakeNotification({
			Name = "Welcome",
			Content = WindowConfig.IntroText,
			Image = "check-circle",
			Time = 6,
		})
	end
	
	local Window = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 10), {
		SetProps(MakeElement("Stroke", nil, 1), {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}),
		SetProps(MakeElement("Padding", 0, 0, 0, 0), {
			PaddingLeft = UDim.new(0, 15),
			PaddingRight = UDim.new(0, 15),
			PaddingTop = UDim.new(0, 15),
			PaddingBottom = UDim.new(0, 15)
		}),
		SetProps(MakeElement("TFrame"), {
			SetProps(MakeElement("List"), {
				Padding = UDim.new(0, 15),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			SetChildren(MakeElement("TFrame"), {
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal
				}),
				SetChildren(MakeElement("TFrame"), {
					SetProps(MakeElement("Label", WindowConfig.Name, 18), {
						Size = UDim2.new(1, 0, 0, 20)
					}),
					SetProps(MakeElement("Button"), {
						Size = UDim2.new(0, 20, 0, 20),
						SetChildren(MakeElement("Image", "x"), {
							Size = UDim2.new(0, 18, 0, 18),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5)
						})
					}, {
						LayoutOrder = 2
					})
				}, {
					Size = UDim2.new(1, 0, 0, 20)
				})
			}, {
				LayoutOrder = 1
			}),
			SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1),
				BorderSizePixel = 0
			}, {
				LayoutOrder = 2
			}),
			SetProps(MakeElement("TFrame"), {
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				SetChildren(MakeElement("TFrame"), {
					SetProps(MakeElement("List"), {
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal
					}),
					SetChildren(MakeElement("Button"), {
						SetProps(MakeElement("Label", "Home", 14), {
							Size = UDim2.new(0, 0, 0, 20),
							AutomaticSize = Enum.AutomaticSize.X
						}),
						SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 2),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 0, 1, 0),
							AnchorPoint = Vector2.new(0, 1)
						})
					}, {
						LayoutOrder = 1
					})
				}, {
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = 1
				}),
				SetProps(MakeElement("ScrollFrame", nil, 3), {
					Size = UDim2.new(1, 0, 1, -25),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
					ScrollBarThickness = 3
				}, {
					LayoutOrder = 2
				})
			}, {
				Size = UDim2.new(1, 0, 1, -40),
				LayoutOrder = 3
			})
		}, {
			Size = UDim2.new(1, 0, 1, 0)
		})
	}), {
		Size = UDim2.new(0, 500, 0, 350),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = Orion
	})
	
	AddThemeObject(Window, "Main")
	AddThemeObject(Window.UIStroke, "Stroke")
	AddThemeObject(Window.Frame.Frame.Frame.Frame.Frame, "Divider")
	AddThemeObject(Window.Frame.Frame.Frame.Frame.Frame.TextLabel, "Text")
	AddThemeObject(Window.Frame.Frame.Frame.Frame.Frame.Frame, "Accent")
	AddThemeObject(Window.Frame.Frame.Frame.Frame.Frame.Frame.TextLabel, "Text")
	AddThemeObject(Window.Frame.Frame.Frame.ScrollingFrame, "ScrollBar")
	
	MakeDraggable(Window.Frame.Frame.Frame, Window)
	
	local Tabs = {}
	local CurrentTab = "Home"
	
	Window.Frame.Frame.Frame.Frame.Frame.Button.MouseButton1Click:Connect(function()
		Window:Destroy()
		OrionLib:Destroy()
	end)
	
	function Tabs:MakeTab(TabConfig)
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or "folder"
		
		local Tab = SetProps(SetChildren(MakeElement("Button"), {
			SetProps(MakeElement("List"), {
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal
			}),
			SetChildren(MakeElement("Image", TabConfig.Icon), {
				Size = UDim2.new(0, 16, 0, 16)
			}),
			SetChildren(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(0, 0, 0, 16),
				AutomaticSize = Enum.AutomaticSize.X
			})
		}), {
			Size = UDim2.new(0, 0, 0, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = #Window.Frame.Frame.Frame.Frame:GetChildren() - 1,
			Parent = Window.Frame.Frame.Frame.Frame
		})
		
		AddThemeObject(Tab.ImageLabel, "Text")
		AddThemeObject(Tab.TextLabel, "Text")
		
		local Container = SetProps(SetChildren(MakeElement("TFrame"), {
			SetProps(MakeElement("List"), {
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		}), {
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
			Parent = Window.Frame.Frame.Frame.ScrollingFrame
		})
		
		if CurrentTab == "Home" then
			CurrentTab = TabConfig.Name
			Container.Visible = true
			Window.Frame.Frame.Frame.Frame.Frame.TextLabel.Text = TabConfig.Name
		end
		
		Tab.MouseButton1Click:Connect(function()
			for _, v in next, Window.Frame.Frame.Frame.ScrollingFrame:GetChildren() do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end
			Container.Visible = true
			CurrentTab = TabConfig.Name
			Window.Frame.Frame.Frame.Frame.Frame.TextLabel.Text = TabConfig.Name
		end)
		
		local TabElements = {}
		
		function TabElements:AddButton(ButtonConfig)
			ButtonConfig.Name = ButtonConfig.Name or "Button"
			ButtonConfig.Callback = ButtonConfig.Callback or function() end
			
			local Button = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
				SetProps(MakeElement("Stroke", nil, 1), {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				SetProps(MakeElement("Button"), {
					SetProps(MakeElement("Label", ButtonConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						TextXAlignment = Enum.TextXAlignment.Center
					})
				})
			}), {
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = #Container:GetChildren(),
				Parent = Container
			})
			
			AddThemeObject(Button, "Second")
			AddThemeObject(Button.UIStroke, "Stroke")
			AddThemeObject(Button.TextButton.TextLabel, "Text")
			
			Button.TextButton.MouseEnter:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Third}):Play()
			end)
			
			Button.TextButton.MouseLeave:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
			end)
			
			Button.TextButton.MouseButton1Click:Connect(function()
				pcall(ButtonConfig.Callback)
			end)
			
			local ButtonFunctions = {}
			
			function ButtonFunctions:Set(NewButtonConfig)
				ButtonConfig = NewButtonConfig
				Button.TextButton.TextLabel.Text = ButtonConfig.Name
			end
			
			return ButtonFunctions
		end
		
		function TabElements:AddToggle(ToggleConfig)
			ToggleConfig.Name = ToggleConfig.Name or "Toggle"
			ToggleConfig.Default = ToggleConfig.Default or false
			ToggleConfig.Callback = ToggleConfig.Callback or function() end
			ToggleConfig.Flag = ToggleConfig.Flag or ToggleConfig.Name
			
			local Toggled = ToggleConfig.Default
			
			local Toggle = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
				SetProps(MakeElement("Stroke", nil, 1), {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal
				}),
				SetChildren(MakeElement("Label", ToggleConfig.Name, 14), {
					Size = UDim2.new(1, -30, 1, 0)
				}),
				SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
					SetProps(MakeElement("Stroke", nil, 1), {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					}),
					SetProps(MakeElement("Button"), {
						SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, -4, 1, -4),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BorderSizePixel = 0
						})
					})
				}, {
					Size = UDim2.new(0, 20, 0, 20),
					LayoutOrder = 2
				})
			}), {
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = #Container:GetChildren(),
				Parent = Container
			})
			
			AddThemeObject(Toggle, "Second")
			AddThemeObject(Toggle.UIStroke, "Stroke")
			AddThemeObject(Toggle.TextLabel, "Text")
			AddThemeObject(Toggle.Frame, "Third")
			AddThemeObject(Toggle.Frame.UIStroke, "Stroke")
			AddThemeObject(Toggle.Frame.TextButton.Frame, "Accent")
			
			local ToggleFunctions = {}
			
			function ToggleFunctions:Set(Bool)
				Toggled = Bool
				Toggle.Frame.TextButton.Frame.Visible = Toggled
				pcall(ToggleConfig.Callback, Toggled)
			end
			
			Toggle.Frame.TextButton.MouseButton1Click:Connect(function()
				Toggled = not Toggled
				Toggle.Frame.TextButton.Frame.Visible = Toggled
				pcall(ToggleConfig.Callback, Toggled)
			end)
			
			ToggleFunctions:Set(ToggleConfig.Default)
			
			if ToggleConfig.Flag then
				OrionLib.Flags[ToggleConfig.Flag] = {
					Type = "Toggle",
					Save = true,
					Value = Toggled,
					Set = ToggleFunctions.Set
				}
			end
			
			return ToggleFunctions
		end
		
		function TabElements:AddSlider(SliderConfig)
			SliderConfig.Name = SliderConfig.Name or "Slider"
			SliderConfig.Min = SliderConfig.Min or 0
			SliderConfig.Max = SliderConfig.Max or 100
			SliderConfig.Increment = SliderConfig.Increment or 1
			SliderConfig.Default = SliderConfig.Default or SliderConfig.Min
			SliderConfig.Callback = SliderConfig.Callback or function() end
			SliderConfig.Flag = SliderConfig.Flag or SliderConfig.Name
			
			local Value = SliderConfig.Default
			
			local Slider = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
				SetProps(MakeElement("Stroke", nil, 1), {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				SetChildren(MakeElement("TFrame"), {
					SetProps(MakeElement("List"), {
						Padding = UDim.new(0, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal
					}),
					SetChildren(MakeElement("Label", SliderConfig.Name, 14), {
						Size = UDim2.new(1, 0, 0, 20)
					}),
					SetChildren(MakeElement("Label", tostring(Value), 14), {
						Size = UDim2.new(0, 0, 0, 20),
						AutomaticSize = Enum.AutomaticSize.X,
						TextXAlignment = Enum.TextXAlignment.Right
					}, {
						LayoutOrder = 2
					})
				}, {
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = 1
				}),
				SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
					SetProps(MakeElement("Stroke", nil, 1), {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					}),
					SetProps(MakeElement("Button"), {
						SetProps(MakeElement("Frame"), {
							Size = UDim2.new((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0),
							BorderSizePixel = 0
						})
					})
				}, {
					Size = UDim2.new(1, 0, 0, 10),
					LayoutOrder = 2
				})
			}), {
				Size = UDim2.new(1, 0, 0, 45),
				LayoutOrder = #Container:GetChildren(),
				Parent = Container
			})
			
			AddThemeObject(Slider, "Second")
			AddThemeObject(Slider.UIStroke, "Stroke")
			AddThemeObject(Slider.Frame.Frame.TextLabel, "Text")
			AddThemeObject(Slider.Frame.Frame.TextLabel, "Text")
			AddThemeObject(Slider.Frame.Frame, "Third")
			AddThemeObject(Slider.Frame.Frame.UIStroke, "Stroke")
			AddThemeObject(Slider.Frame.Frame.TextButton.Frame, "Accent")
			
			local SliderFunctions = {}
			
			function SliderFunctions:Set(NewValue)
				Value = math.clamp(Round(NewValue, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
				Slider.Frame.Frame.TextLabel.Text = tostring(Value)
				Slider.Frame.Frame.TextButton.Frame.Size = UDim2.new((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0)
				pcall(SliderConfig.Callback, Value)
			end
			
			local Dragging = false
			
			Slider.Frame.Frame.TextButton.MouseButton1Down:Connect(function()
				Dragging = true
				local MoveConnection
				local ReleaseConnection
				
				MoveConnection = UserInputService.InputChanged:Connect(function(Input)
					if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
						local Pos = UDim2.new(math.clamp((Input.Position.X - Slider.Frame.Frame.TextButton.AbsolutePosition.X) / Slider.Frame.Frame.TextButton.AbsoluteSize.X, 0, 1), 0, 1, 0)
						local NewValue = math.floor((((Pos.X.Scale * SliderConfig.Max) / SliderConfig.Max) * (SliderConfig.Max - SliderConfig.Min) + SliderConfig.Min) * (1 / SliderConfig.Increment)) / (1 / SliderConfig.Increment)
						SliderFunctions:Set(NewValue)
					end
				end)
				
				ReleaseConnection = UserInputService.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
						MoveConnection:Disconnect()
						ReleaseConnection:Disconnect()
					end
				end)
			end)
			
			SliderFunctions:Set(SliderConfig.Default)
			
			if SliderConfig.Flag then
				OrionLib.Flags[SliderConfig.Flag] = {
					Type = "Slider",
					Save = true,
					Value = Value,
					Set = SliderFunctions.Set
				}
			end
			
			return SliderFunctions
		end
		
		function TabElements:AddDropdown(DropdownConfig)
			DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
			DropdownConfig.Options = DropdownConfig.Options or {}
			DropdownConfig.Default = DropdownConfig.Default or DropdownConfig.Options[1]
			DropdownConfig.Callback = DropdownConfig.Callback or function() end
			DropdownConfig.Flag = DropdownConfig.Flag or DropdownConfig.Name
			
			local Selected = DropdownConfig.Default
			local Opened = false
			
			local Dropdown = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
				SetProps(MakeElement("Stroke", nil, 1), {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				SetChildren(MakeElement("TFrame"), {
					SetProps(MakeElement("List"), {
						Padding = UDim.new(0, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal
					}),
					SetChildren(MakeElement("Label", DropdownConfig.Name, 14), {
						Size = UDim2.new(1, 0, 0, 20)
					}),
					SetChildren(MakeElement("Image", "chevron-down"), {
						Size = UDim2.new(0, 16, 0, 16),
						Position = UDim2.new(1, 0, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),
						Rotation = Opened and 180 or 0
					}, {
						LayoutOrder = 2
					})
				}, {
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = 1
				}),
				SetChildren(MakeElement("Label", Selected, 14), {
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = 2
				}),
				SetChildren(MakeElement("TFrame"), {
					SetProps(MakeElement("List"), {
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder
					}),
					SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
						SetProps(MakeElement("Stroke", nil, 1), {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						}),
						SetProps(MakeElement("Button"), {
							SetProps(MakeElement("Label", "Option", 14), {
								Size = UDim2.new(1, 0, 0, 20),
								TextXAlignment = Enum.TextXAlignment.Center
							})
						})
					}, {
						Size = UDim2.new(1, 0, 0, 25),
						LayoutOrder = 1,
						Visible = false
					})
				}, {
					Size = UDim2.new(1, 0, 0, 0),
					LayoutOrder = 3,
					Visible = false
				})
			}), {
				Size = UDim2.new(1, 0, 0, 45),
				LayoutOrder = #Container:GetChildren(),
				Parent = Container
			})
			
			AddThemeObject(Dropdown, "Second")
			AddThemeObject(Dropdown.UIStroke, "Stroke")
			AddThemeObject(Dropdown.Frame.Frame.TextLabel, "Text")
			AddThemeObject(Dropdown.Frame.Frame.ImageLabel, "Text")
			AddThemeObject(Dropdown.TextLabel, "Text")
			AddThemeObject(Dropdown.Frame.Frame1.Frame, "Third")
			AddThemeObject(Dropdown.Frame.Frame1.Frame.UIStroke, "Stroke")
			AddThemeObject(Dropdown.Frame.Frame1.Frame.TextButton.TextLabel, "Text")
			
			local DropdownFunctions = {}
			
			function DropdownFunctions:Set(Option)
				Selected = Option
				Dropdown.TextLabel.Text = Selected
				pcall(DropdownConfig.Callback, Selected)
			end
			
			function DropdownFunctions:Refresh(Options, Keep)
				DropdownConfig.Options = Options
				if not Keep then
					Selected = Options[1] or ""
					Dropdown.TextLabel.Text = Selected
				end
				for _, v in next, Dropdown.Frame.Frame1:GetChildren() do
					if v:IsA("Frame") and v.LayoutOrder ~= 0 then
						v:Destroy()
					end
				end
				for i, v in next, Options do
					local Option = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
						SetProps(MakeElement("Stroke", nil, 1), {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						}),
						SetProps(MakeElement("Button"), {
							SetProps(MakeElement("Label", v, 14), {
								Size = UDim2.new(1, 0, 0, 20),
								TextXAlignment = Enum.TextXAlignment.Center
							})
						})
					}), {
						Size = UDim2.new(1, 0, 0, 25),
						LayoutOrder = i,
						Parent = Dropdown.Frame.Frame1
					})
					
					AddThemeObject(Option, "Third")
					AddThemeObject(Option.UIStroke, "Stroke")
					AddThemeObject(Option.TextButton.TextLabel, "Text")
					
					Option.TextButton.MouseButton1Click:Connect(function()
						DropdownFunctions:Set(v)
						Dropdown.Frame.Frame1.Visible = false
						Opened = false
						Dropdown.Frame.Frame.ImageLabel.Rotation = 0
						Dropdown.Size = UDim2.new(1, 0, 0, 45)
					end)
				end
			end
			
			Dropdown.Frame.Frame.MouseButton1Click:Connect(function()
				Opened = not Opened
				Dropdown.Frame.Frame1.Visible = Opened
				Dropdown.Frame.Frame.ImageLabel.Rotation = Opened and 180 or 0
				if Opened then
					Dropdown.Size = UDim2.new(1, 0, 0, 45 + (#DropdownConfig.Options * 30) + 5)
				else
					Dropdown.Size = UDim2.new(1, 0, 0, 45)
				end
			end)
			
			DropdownFunctions:Refresh(DropdownConfig.Options, true)
			DropdownFunctions:Set(DropdownConfig.Default)
			
			if DropdownConfig.Flag then
				OrionLib.Flags[DropdownConfig.Flag] = {
					Type = "Dropdown",
					Save = true,
					Value = Selected,
					Set = DropdownFunctions.Set,
					Refresh = DropdownFunctions.Refresh
				}
			end
			
			return DropdownFunctions
		end
		
		function TabElements:AddColorpicker(ColorpickerConfig)
			ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
			ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
			ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
			ColorpickerConfig.Flag = ColorpickerConfig.Flag or ColorpickerConfig.Name
			
			local Color = ColorpickerConfig.Default
			local Hue, Sat, Vib = 0, 0, 0
			Color:ToHSV(Hue, Sat, Vib)
			
			local Colorpicker = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
				SetProps(MakeElement("Stroke", nil, 1), {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal
				}),
				SetChildren(MakeElement("Label", ColorpickerConfig.Name, 14), {
					Size = UDim2.new(1, -30, 1, 0)
				}),
				SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
					SetProps(MakeElement("Stroke", nil, 1), {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					}),
					SetProps(MakeElement("Button"), {
						BackgroundColor3 = Color
					})
				}, {
					Size = UDim2.new(0, 20, 0, 20),
					LayoutOrder = 2
				})
			}), {
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = #Container:GetChildren(),
				Parent = Container
			})
			
			AddThemeObject(Colorpicker, "Second")
			AddThemeObject(Colorpicker.UIStroke, "Stroke")
			AddThemeObject(Colorpicker.TextLabel, "Text")
			AddThemeObject(Colorpicker.Frame.UIStroke, "Stroke")
			
			local ColorpickerFunctions = {}
			
			function ColorpickerFunctions:Set(NewColor)
				Color = NewColor
				Colorpicker.Frame.TextButton.BackgroundColor3 = Color
				pcall(ColorpickerConfig.Callback, Color)
			end
			
			Colorpicker.Frame.TextButton.MouseButton1Click:Connect(function()
				local Picker = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
					SetProps(MakeElement("Stroke", nil, 1), {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					}),
					SetProps(MakeElement("List"), {
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder
					}),
					SetChildren(MakeElement("ImageButton", "http://www.roblox.com/asset/?id=7483876083"), {
						Size = UDim2.new(1, 0, 1, -30),
						BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
					}),
					SetChildren(MakeElement("Frame"), {
						Size = UDim2.new(0, 4, 0, 4),
						Position = UDim2.new(Sat, 0, 1 - Vib, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					}, {
						Create("UICorner", {
							CornerRadius = UDim.new(0, 2)
						}),
						Create("UIStroke", {
							Color = Color3.fromRGB(0, 0, 0),
							Thickness = 1
						})
					}),
					SetChildren(MakeElement("ImageButton", "http://www.roblox.com/asset/?id=7483901555"), {
						Size = UDim2.new(0, 15, 1, -30),
						Position = UDim2.new(1, -20, 0, 0),
						LayoutOrder = 2
					}),
					SetChildren(MakeElement("Frame"), {
						Size = UDim2.new(0, 10, 0, 2),
						Position = UDim2.new(0.5, 0, 1 - Hue, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					}, {
						Create("UICorner", {
							CornerRadius = UDim.new(0, 1)
						}),
						Create("UIStroke", {
							Color = Color3.fromRGB(0, 0, 0),
							Thickness = 1
						})
					}),
					SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
						SetProps(MakeElement("Stroke", nil, 1), {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						}),
						SetProps(MakeElement("Label", "", 14), {
							Size = UDim2.new(1, 0, 0, 20),
							TextXAlignment = Enum.TextXAlignment.Center
						})
					}, {
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = 3
					})
				}), {
					Size = UDim2.new(0, 200, 0, 200),
					Position = UDim2.new(1, 5, 0, 0),
					Parent = Colorpicker
				})
				
				AddThemeObject(Picker, "Main")
				AddThemeObject(Picker.UIStroke, "Stroke")
				AddThemeObject(Picker.Frame, "Text")
				
				local DraggingHue, DraggingPicker = false, false
				
				local function UpdateColor()
					Color = Color3.fromHSV(Hue, Sat, Vib)
					Colorpicker.Frame.TextButton.BackgroundColor3 = Color
					Picker.ImageButton.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
					Picker.Frame.TextLabel.Text = "RGB: " .. math.floor(Color.R * 255) .. ", " .. math.floor(Color.G * 255) .. ", " .. math.floor(Color.B * 255)
					pcall(ColorpickerConfig.Callback, Color)
				end
				
				Picker.ImageButton.MouseButton1Down:Connect(function()
					DraggingPicker = true
					local MoveConnection
					local ReleaseConnection
					
					MoveConnection = UserInputService.InputChanged:Connect(function(Input)
						if DraggingPicker and Input.UserInputType == Enum.UserInputType.MouseMovement then
							local X = math.clamp((Input.Position.X - Picker.ImageButton.AbsolutePosition.X) / Picker.ImageButton.AbsoluteSize.X, 0, 1)
							local Y = math.clamp((Input.Position.Y - Picker.ImageButton.AbsolutePosition.Y) / Picker.ImageButton.AbsoluteSize.Y, 0, 1)
							Sat = X
							Vib = 1 - Y
							Picker.Frame.Position = UDim2.new(X, 0, Y, 0)
							UpdateColor()
						end
					end)
					
					ReleaseConnection = UserInputService.InputEnded:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							DraggingPicker = false
							MoveConnection:Disconnect()
							ReleaseConnection:Disconnect()
						end
					end)
				end)
				
				Picker.Frame.MouseButton1Down:Connect(function()
					DraggingHue = true
					local MoveConnection
					local ReleaseConnection
					
					MoveConnection = UserInputService.InputChanged:Connect(function(Input)
						if DraggingHue and Input.UserInputType == Enum.UserInputType.MouseMovement then
							local Y = math.clamp((Input.Position.Y - Picker.Frame.AbsolutePosition.Y) / Picker.Frame.AbsoluteSize.Y, 0, 1)
							Hue = 1 - Y
							Picker.Frame.Position = UDim2.new(0.5, 0, Y, 0)
							UpdateColor()
						end
					end)
					
					ReleaseConnection = UserInputService.InputEnded:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							DraggingHue = false
							MoveConnection:Disconnect()
							ReleaseConnection:Disconnect()
						end
					end)
				end)
				
				UpdateColor()
				
				local PickerConnection
				PickerConnection = UserInputService.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and not (Picker:IsDescendantOf(Mouse.Target) or Colorpicker:IsDescendantOf(Mouse.Target)) then
						Picker:Destroy()
						PickerConnection:Disconnect()
					end
				end)
			end)
			
			ColorpickerFunctions:Set(ColorpickerConfig.Default)
			
			if ColorpickerConfig.Flag then
				OrionLib.Flags[ColorpickerConfig.Flag] = {
					Type = "Colorpicker",
					Save = true,
					Value = Color,
					Set = ColorpickerFunctions.Set
				}
			end
			
			return ColorpickerFunctions
		end
		
		function TabElements:AddKeybind(KeybindConfig)
			KeybindConfig.Name = KeybindConfig.Name or "Keybind"
			KeybindConfig.Default = KeybindConfig.Default or Enum.KeyCode.Unknown
			KeybindConfig.Callback = KeybindConfig.Callback or function() end
			KeybindConfig.Flag = KeybindConfig.Flag or KeybindConfig.Name
			
			local Key = KeybindConfig.Default
			local Listening = false
			
			local Keybind = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
				SetProps(MakeElement("Stroke", nil, 1), {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal
				}),
				SetChildren(MakeElement("Label", KeybindConfig.Name, 14), {
					Size = UDim2.new(1, -60, 1, 0)
				}),
				SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
					SetProps(MakeElement("Stroke", nil, 1), {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					}),
					SetProps(MakeElement("Button"), {
						SetProps(MakeElement("Label", Key.Name, 14), {
							Size = UDim2.new(1, 0, 1, 0),
							TextXAlignment = Enum.TextXAlignment.Center
						})
					})
				}, {
					Size = UDim2.new(0, 50, 0, 20),
					LayoutOrder = 2
				})
			}), {
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = #Container:GetChildren(),
				Parent = Container
			})
			
			AddThemeObject(Keybind, "Second")
			AddThemeObject(Keybind.UIStroke, "Stroke")
			AddThemeObject(Keybind.TextLabel, "Text")
			AddThemeObject(Keybind.Frame, "Third")
			AddThemeObject(Keybind.Frame.UIStroke, "Stroke")
			AddThemeObject(Keybind.Frame.TextButton.TextLabel, "Text")
			
			local KeybindFunctions = {}
			
			function KeybindFunctions:Set(NewKey)
				Key = NewKey
				Keybind.Frame.TextButton.TextLabel.Text = Key.Name
				pcall(KeybindConfig.Callback, Key)
			end
			
			Keybind.Frame.TextButton.MouseButton1Click:Connect(function()
				Listening = true
				Keybind.Frame.TextButton.TextLabel.Text = "..."
			end)
			
			local Connection
			Connection = UserInputService.InputBegan:Connect(function(Input)
				if Listening then
					local Key = Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
					if not CheckKey(BlacklistedKeys, Key) then
						KeybindFunctions:Set(Key)
						Listening = false
					end
				else
					if Input.KeyCode == Key or Input.UserInputType == Key then
						pcall(KeybindConfig.Callback, Key)
					end
				end
			end)
			
			table.insert(OrionLib.Connections, Connection)
			
			KeybindFunctions:Set(KeybindConfig.Default)
			
			if KeybindConfig.Flag then
				OrionLib.Flags[KeybindConfig.Flag] = {
					Type = "Keybind",
					Save = true,
					Value = Key,
					Set = KeybindFunctions.Set
				}
			end
			
			return KeybindFunctions
		end
		
		function TabElements:AddTextbox(TextboxConfig)
			TextboxConfig.Name = TextboxConfig.Name or "Textbox"
			TextboxConfig.Default = TextboxConfig.Default or ""
			TextboxConfig.Callback = TextboxConfig.Callback or function() end
			TextboxConfig.Flag = TextboxConfig.Flag or TextboxConfig.Name
			
			local Text = TextboxConfig.Default
			
			local Textbox = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
				SetProps(MakeElement("Stroke", nil, 1), {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				SetProps(MakeElement("List"), {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				SetChildren(MakeElement("Label", TextboxConfig.Name, 14), {
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = 1
				}),
				SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
					SetProps(MakeElement("Stroke", nil, 1), {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					}),
					SetProps(MakeElement("TextBox"), {
						Text = Text,
						PlaceholderText = TextboxConfig.Name,
						TextSize = 14,
						Font = Enum.Font.Gotham,
						TextColor3 = Color3.fromRGB(240, 240, 240),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left
					})
				}, {
					Size = UDim2.new(1, 0, 0, 25),
					LayoutOrder = 2
				})
			}), {
				Size = UDim2.new(1, 0, 0, 50),
				LayoutOrder = #Container:GetChildren(),
				Parent = Container
			})
			
			AddThemeObject(Textbox, "Second")
			AddThemeObject(Textbox.UIStroke, "Stroke")
			AddThemeObject(Textbox.TextLabel, "Text")
			AddThemeObject(Textbox.Frame, "Third")
			AddThemeObject(Textbox.Frame.UIStroke, "Stroke")
			AddThemeObject(Textbox.Frame.TextBox, "Text")
			
			local TextboxFunctions = {}
			
			function TextboxFunctions:Set(NewText)
				Text = NewText
				Textbox.Frame.TextBox.Text = Text
				pcall(TextboxConfig.Callback, Text)
			end
			
			Textbox.Frame.TextBox.FocusLost:Connect(function(EnterPressed)
				if EnterPressed then
					TextboxFunctions:Set(Textbox.Frame.TextBox.Text)
				end
			end)
			
			TextboxFunctions:Set(TextboxConfig.Default)
			
			if TextboxConfig.Flag then
				OrionLib.Flags[TextboxConfig.Flag] = {
					Type = "Textbox",
					Save = true,
					Value = Text,
					Set = TextboxFunctions.Set
				}
			end
			
			return TextboxFunctions
		end
		
		function TabElements:AddLabel(LabelConfig)
			LabelConfig.Name = LabelConfig.Name or "Label"
			
			local Label = SetProps(SetChildren(MakeElement("RoundFrame", nil, 0, 5), {
				SetProps(MakeElement("Stroke", nil, 1), {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				SetProps(MakeElement("Label", LabelConfig.Name, 14), {
					Size = UDim2.new(1, 0, 0, 20),
					TextXAlignment = Enum.TextXAlignment.Center
				})
			}), {
				Size = UDim2.new(1, 0, 0, 25),
				LayoutOrder = #Container:GetChildren(),
				Parent = Container
			})
			
			AddThemeObject(Label, "Second")
			AddThemeObject(Label.UIStroke, "Stroke")
			AddThemeObject(Label.TextLabel, "Text")
			
			local LabelFunctions = {}
			
			function LabelFunctions:Set(NewText)
				Label.TextLabel.Text = NewText
			end
			
			return LabelFunctions
		end
		
		return TabElements
	end
	
	return Tabs
end

function OrionLib:Destroy()
	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
	Orion:Destroy()
end

return OrionLib