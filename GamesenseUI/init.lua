-- GamesenseUI/init.lua
local Gamesense = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

Gamesense.Components = {}
Gamesense.Windows = {}

function Gamesense.LoadComponent(name)
	if Gamesense.Components[name] then
		return Gamesense.Components[name]
	end
	
	local component = require(script.Components[name] or script[name])
	Gamesense.Components[name] = component
	return component
end

function Gamesense:Window(config)
	local WindowComponent = self.LoadComponent("Window")
	local window = WindowComponent:new(config)
	
	table.insert(self.Windows, window)
	
	return window
end

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
