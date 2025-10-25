
-- GamesenseUI/Button.lua
local Gamesense = require(script.Parent)
local TweenService = game:GetService("TweenService")

local Button = {}
Button.__index = Button

function Button:new(config, parent)
	config = config or {}
	
	local self = setmetatable({}, Button)
	
	self.Title = config.Title or "Button"
	self.Description = config.Description
	self.Callback = config.Callback or function() end
	
	self:CreateUI(parent)
	
	return self
end

function Button:CreateUI(parent)
	self.Frame = Gamesense.Create("Frame", {
		Name = "ButtonFrame",
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = Gamesense.Theme.Background,
		BorderSizePixel = 0,
		Parent = parent
	})
	
	Gamesense.Create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = self.Frame
	})
	
	self.Button = Gamesense.Create("TextButton", {
		Name = "Button",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Gamesense.Theme.Background,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = self.Frame
	})
	
	self.TitleLabel = Gamesense.Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -24, 0, 24),
		Position = UDim2.new(0, 12, 0, 8),
		BackgroundTransparency = 1,
		Text = self.Title,
		TextColor3 = Gamesense.Theme.Text,
		TextSize = 16,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Frame
	})
	
	if self.Description then
		self.DescLabel = Gamesense.Create("TextLabel", {
			Name = "Description",
			Size = UDim2.new(1, -24, 0, 20),
			Position = UDim2.new(0, 12, 0, 32),
			BackgroundTransparency = 1,
			Text = self.Description,
			TextColor3 = Gamesense.Theme.TextSecondary,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.Frame
		})
	end
	
	-- Click event
	self.Button.MouseButton1Click:Connect(function()
		self.Callback()
	end)
	
	-- Hover effects
	self:SetupHoverEffects()
end

function Button:SetupHoverEffects()
	self.Button.MouseEnter:Connect(function()
		TweenService:Create(self.Frame, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		}):Play()
	end)
	
	self.Button.MouseLeave:Connect(function()
		TweenService:Create(self.Frame, TweenInfo.new(0.2), {
			BackgroundColor3 = Gamesense.Theme.Background
		}):Play()
	end)
	
	self.Button.MouseButton1Down:Connect(function()
		TweenService:Create(self.Frame, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(50, 50, 55)
		}):Play()
	end)
	
	self.Button.MouseButton1Up:Connect(function()
		TweenService:Create(self.Frame, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		}):Play()
	end)
end

return Button
