-- GamesenseUI/init.lua
local Gamesense = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Cache for components
Gamesense.Components = {}
Gamesense.Windows = {}

-- Component definitions (instead of trying to load from folder)
local ComponentDefinitions = {}

ComponentDefinitions.Window = [[
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
        self.ScreenGui = Gamesense.Create("ScreenGui", {
            Name = "GamesenseUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        
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
        
        self.TabContainer = Gamesense.Create("Frame", {
            Name = "TabContainer",
            Size = UDim2.new(0, 120, 1, -32),
            Position = UDim2.new(0, 0, 0, 32),
            BackgroundColor3 = self.Theme.Secondary,
            BorderSizePixel = 0,
            Parent = self.MainFrame
        })
        
        self.ContentFrame = Gamesense.Create("Frame", {
            Name = "ContentFrame",
            Size = UDim2.new(1, -120, 1, -32),
            Position = UDim2.new(0, 120, 0, 32),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            BorderSizePixel = 0,
            Parent = self.MainFrame
        })
        
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
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
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
]]

ComponentDefinitions.Tab = [[
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
        
        self.Button.MouseButton1Click:Connect(function()
            self.Window:SelectTab(self)
        end)
        
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
]]

ComponentDefinitions.Button = [[
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
        
        self.Button.MouseButton1Click:Connect(function()
            self.Callback()
        end)
        
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
]]

ComponentDefinitions.Toggle = [[
    local Gamesense = require(script.Parent)
    local TweenService = game:GetService("TweenService")

    local Toggle = {}
    Toggle.__index = Toggle

    function Toggle:new(config, parent)
        config = config or {}
        
        local self = setmetatable({}, Toggle)
        
        self.Title = config.Title or "Toggle"
        self.Description = config.Description
        self.Default = config.Default or false
        self.Callback = config.Callback or function() end
        self.Value = self.Default
        
        self:CreateUI(parent)
        self:UpdateToggle()
        
        return self
    end

    function Toggle:CreateUI(parent)
        self.Frame = Gamesense.Create("Frame", {
            Name = "ToggleFrame",
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Gamesense.Theme.Background,
            BorderSizePixel = 0,
            Parent = parent
        })
        
        Gamesense.Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = self.Frame
        })
        
        self.Button = Gamesense.Create("TextButton", {
            Name = "ToggleButton",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Gamesense.Theme.Background,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = self.Frame
        })
        
        self.TitleLabel = Gamesense.Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Title,
            TextColor3 = Gamesense.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Frame
        })
        
        self.ToggleSwitch = Gamesense.Create("Frame", {
            Name = "ToggleSwitch",
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, -44, 0.5, -10),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(60, 60, 65),
            BorderSizePixel = 0,
            Parent = self.Frame
        })
        
        Gamesense.Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
            Parent = self.ToggleSwitch
        })
        
        self.ToggleKnob = Gamesense.Create("Frame", {
            Name = "ToggleKnob",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = self.ToggleSwitch
        })
        
        Gamesense.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = self.ToggleKnob
        })
        
        self.Button.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
        
        self:SetupHoverEffects()
    end

    function Toggle:Toggle()
        self.Value = not self.Value
        self:UpdateToggle()
        self.Callback(self.Value)
    end

    function Toggle:UpdateToggle()
        if self.Value then
            TweenService:Create(self.ToggleKnob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -18, 0.5, -8),
                BackgroundColor3 = Gamesense.Theme.Primary
            }):Play()
            
            TweenService:Create(self.ToggleSwitch, TweenInfo.new(0.2), {
                BackgroundColor3 = Gamesense.Theme.Primary
            }):Play()
        else
            TweenService:Create(self.ToggleKnob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            
            TweenService:Create(self.ToggleSwitch, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            }):Play()
        end
    end

    function Toggle:SetupHoverEffects()
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
    end

    function Toggle:Set(value)
        self.Value = value
        self:UpdateToggle()
    end

    function Toggle:Get()
        return self.Value
    end

    return Toggle
]]

ComponentDefinitions.Dialog = [[
    local Gamesense = require(script.Parent)
    local TweenService = game:GetService("TweenService")

    local Dialog = {}
    Dialog.__index = Dialog

    function Dialog:new(config, window)
        config = config or {}
        
        local self = setmetatable({}, Dialog)
        
        self.Title = config.Title or "Dialog"
        self.Content = config.Content or ""
        self.Buttons = config.Buttons or {}
        self.Window = window
        
        self:CreateUI()
        
        return self
    end

    function Dialog:CreateUI()
        self.Overlay = Gamesense.Create("Frame", {
            Name = "DialogOverlay",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = self.Window.ScreenGui
        })
        
        self.MainFrame = Gamesense.Create("Frame", {
            Name = "DialogFrame",
            Size = UDim2.new(0, 300, 0, 200),
            Position = UDim2.new(0.5, -150, 0.5, -100),
            BackgroundColor3 = Gamesense.Theme.Background,
            BorderSizePixel = 0,
            Parent = self.Overlay
        })
        
        Gamesense.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = self.MainFrame
        })
        
        self.TitleLabel = Gamesense.Create("TextLabel", {
            Name = "DialogTitle",
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Gamesense.Theme.Secondary,
            BorderSizePixel = 0,
            Text = self.Title,
            TextColor3 = Gamesense.Theme.Text,
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            Parent = self.MainFrame
        })
        
        Gamesense.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = self.TitleLabel
        })
        
        self.ContentLabel = Gamesense.Create("TextLabel", {
            Name = "DialogContent",
            Size = UDim2.new(1, -24, 1, -100),
            Position = UDim2.new(0, 12, 0, 50),
            BackgroundTransparency = 1,
            Text = self.Content,
            TextColor3 = Gamesense.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = self.MainFrame
        })
        
        self.ButtonContainer = Gamesense.Create("Frame", {
            Name = "ButtonContainer",
            Size = UDim2.new(1, -24, 0, 40),
            Position = UDim2.new(0, 12, 1, -50),
            BackgroundTransparency = 1,
            Parent = self.MainFrame
        })
        
        Gamesense.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = self.ButtonContainer
        })
        
        for i, buttonConfig in ipairs(self.Buttons) do
            self:AddButton(buttonConfig, i)
        end
    end

    function Dialog:AddButton(buttonConfig, index)
        local button = Gamesense.Create("TextButton", {
            Name = "DialogButton" .. index,
            Size = UDim2.new(0, 80, 0, 30),
            BackgroundColor3 = Gamesense.Theme.Secondary,
            BorderSizePixel = 0,
            Text = buttonConfig.Title,
            TextColor3 = Gamesense.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = self.ButtonContainer
        })
        
        Gamesense.Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = button
        })
        
        button.MouseButton1Click:Connect(function()
            if buttonConfig.Callback then
                buttonConfig.Callback()
            end
            self:Close()
        end)
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Gamesense.Theme.Secondary
            }):Play()
        end)
    end

    function Dialog:Close()
        self.Overlay:Destroy()
    end

    return Dialog
]]

-- Load component function (FIXED)
function Gamesense.LoadComponent(name)
	if Gamesense.Components[name] then
		return Gamesense.Components[name]
	end
	
	if ComponentDefinitions[name] then
		-- Create a temporary environment to load the component
		local env = {
			Gamesense = Gamesense,
			game = game,
			TweenService = TweenService,
			UserInputService = UserInputService,
			script = { Parent = Gamesense }
		}
		
		local componentFunc, errorMsg = loadstring(ComponentDefinitions[name])
		if componentFunc then
			setfenv(componentFunc, env)
			local success, component = pcall(componentFunc)
			if success then
				Gamesense.Components[name] = component
				return component
			else
				warn("Error loading component " .. name .. ": " .. tostring(component))
			end
		else
			warn("Error compiling component " .. name .. ": " .. tostring(errorMsg))
		end
	end
	
	error("Component '" .. name .. "' not found")
end

-- Initialize Window component
function Gamesense:Window(config)
	local WindowComponent = self.LoadComponent("Window")
	local window = WindowComponent:new(config)
	
	table.insert(self.Windows, window)
	
	return window
end

-- Export commonly used functions
Gamesense.Theme = {
	Primary = Color3.fromRGB(76, 194, 255),
	Background = Color3.fromRGB(30, 30, 35),
	Secondary = Color3.fromRGB(25, 25, 30),
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(200, 200, 200)
}

Gamesense.Create = function(className, properties)
	local instance = Instance.new(className)
	
	for property, value in pairs(properties) do
		if property == "Parent" then
			instance.Parent = value
		else
			instance[property] = value
		end
	end
	
	return instance
end

return Gamesense
