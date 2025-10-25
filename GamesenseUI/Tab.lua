-- GamesenseUI/Tab.lua
local Gamesense = require(script.Parent)
local TweenService = game:GetService("TweenService")

local Tab = {}
Tab.__index = Tab

function Tab:new(config, window)
	config = config or {}
	
	local self = setmetatable({}, Tab)
	
	self.Title = config.Title or "Tab"
	self.Window = window
	self.Elements = {}
	
	self:CreateUI()
	
	return self
end

function Tab:CreateUI()
	-- Tab button
	self.Button = Gamesense.Create("TextButton", {
		Name = self.Title .. "Tab",
		Size = UDim2.new(0.9, 0, 0, 36),
		BackgroundColor3 = Gamesense.Theme.Background,
		BorderSizePixel = 0,
		Text = self.Title,
		TextColor3 = Gamesense.Theme.TextSecondary,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold,
		AutoButtonColor = false,
		Parent = self.Window.TabContainer
	})
	
	Gamesense.Create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = self.Button
	})
	
	-- Tab content
	self.Content = Gamesense.Create("Frame", {
		Name = self.Title .. "Content",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.Window.ContentFrame
	})
	
	Gamesense.Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = self.Content
	})
	
	Gamesense.Create("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = self.Content
	})
	
	-- Button click event
	self.Button.MouseButton1Click:Connect(function()
		self.Window:SelectTab(self)
	end)
	
	-- Hover effects
	self:SetupHoverEffects()
end

function Tab:SetupHoverEffects()
	self.Button.MouseEnter:Connect(function()
		if self.Window.CurrentTab ~= self then
			TweenService:Create(self.Button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			}):Play()
		end
	end)
	
	self.Button.MouseLeave:Connect(function()
		if self.Window.CurrentTab ~= self then
			TweenService:Create(self.Button, TweenInfo.new(0.2), {
				BackgroundColor3 = Gamesense.Theme.Background
			}):Play()
		end
	end)
end

function Tab:Select()
	TweenService:Create(self.Button, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(45, 45, 50),
		TextColor3 = Gamesense.Theme.Text
	}):Play()
	
	self.Content.Visible = true
end

function Tab:Deselect()
	TweenService:Create(self.Button, TweenInfo.new(0.2), {
		BackgroundColor3 = Gamesense.Theme.Background,
		TextColor3 = Gamesense.Theme.TextSecondary
	}):Play()
	
	self.Content.Visible = false
end

function Tab:AddButton(buttonConfig)
	local ButtonComponent = Gamesense.LoadComponent("Button")
	local button = ButtonComponent:new(buttonConfig, self.Content)
	
	table.insert(self.Elements, button)
	return button
end

function Tab:AddToggle(toggleConfig)
	local ToggleComponent = Gamesense.LoadComponent("Toggle")
	local toggle = ToggleComponent:new(toggleConfig, self.Content)
	
	table.insert(self.Elements, toggle)
	return toggle
end

return Tab
