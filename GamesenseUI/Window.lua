-- GamesenseUI/Window.lua
local Gamesense = require(script.Parent)
local TweenService = game:GetService("TweenService")

local Window = {}
Window.__index = Window

function Window:new(config)
	config = config or {}
	
	local self = setmetatable({}, Window)
	
	self.Title = config.Title or "Window"
	self.Size = config.Size or UDim2.new(0, 500, 0, 400)
	self.Position = config.Position or UDim2.new(0.5, -250, 0.5, -200)
	self.Theme = Gamesense.Theme
	self.Tabs = {}
	
	self:CreateUI()
	self:SetupDragging()
	
	return self
end

function Window:CreateUI()
	-- Create main screen GUI
	self.ScreenGui = Gamesense.Create("ScreenGui", {
		Name = "GamesenseUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	
	-- Main window frame
	self.MainFrame = Gamesense.Create("Frame", {
		Name = "MainFrame",
		Size = self.Size,
		Position = self.Position,
		BackgroundColor3 = self.Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self.ScreenGui
	})
	
	Gamesense.Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = self.MainFrame
	})
	
	-- Title bar
	self.TitleBar = Gamesense.Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = self.Theme.Secondary,
		BorderSizePixel = 0,
		Parent = self.MainFrame
	})
	
	Gamesense.Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = self.TitleBar
	})
	
	-- Title label
	self.TitleLabel = Gamesense.Create("TextLabel", {
		Name = "TitleLabel",
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		TextColor3 = self.Theme.Text,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.TitleBar
	})
	
	-- Close button
	self.CloseButton = Gamesense.Create("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -32, 0, 0),
		BackgroundColor3 = self.Theme.Secondary,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = self.Theme.Text,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		Parent = self.TitleBar
	})
	
	-- Tab container
	self.TabContainer = Gamesense.Create("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 120, 1, -32),
		Position = UDim2.new(0, 0, 0, 32),
		BackgroundColor3 = self.Theme.Secondary,
		BorderSizePixel = 0,
		Parent = self.MainFrame
	})
	
	-- Content area
	self.ContentFrame = Gamesense.Create("Frame", {
		Name = "ContentFrame",
		Size = UDim2.new(1, -120, 1, -32),
		Position = UDim2.new(0, 120, 0, 32),
		BackgroundColor3 = Color3.fromRGB(35, 35, 40),
		BorderSizePixel = 0,
		Parent = self.MainFrame
	})
	
	-- Tab layout
	Gamesense.Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = self.TabContainer
	})
	
	Gamesense.Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		Parent = self.TabContainer
	})
	
	-- Close button functionality
	self.CloseButton.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
end

function Window:SetupDragging()
	local Dragging, DragInput, MousePos, FramePos = false
	
	self.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			MousePos = input.Position
			FramePos = self.MainFrame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	
	self.TitleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - MousePos
			self.MainFrame.Position = UDim2.new(
				FramePos.X.Scale, 
				FramePos.X.Offset + delta.X,
				FramePos.Y.Scale, 
				FramePos.Y.Offset + delta.Y
			)
		end
	end)
end

function Window:AddTab(tabConfig)
	local TabComponent = Gamesense.LoadComponent("Tab")
	local tab = TabComponent:new(tabConfig, self)
	
	table.insert(self.Tabs, tab)
	
	-- Select first tab by default
	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end
	
	return tab
end

function Window:SelectTab(tab)
	if self.CurrentTab then
		self.CurrentTab:Deselect()
	end
	
	self.CurrentTab = tab
	tab:Select()
end

function Window:Dialog(dialogConfig)
	local DialogComponent = Gamesense.LoadComponent("Dialog")
	return DialogComponent:new(dialogConfig, self)
end

function Window:Destroy()
	self.ScreenGui:Destroy()
end

return Window
