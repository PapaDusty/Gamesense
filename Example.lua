local Gamesense = loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Gamesense/refs/heads/main/GamesenseUI/init.lua"))()

local Window = Gamesense:Window({
    Title = "My Custom UI",
    Size = UDim2.new(0, 600, 0, 500)
})

local Tabs = {
    Main = Window:AddTab({Title = "Main"}),
    Settings = Window:AddTab({Title = "Settings"}),
    Combat = Window:AddTab({Title = "Combat"})
}

Tabs.Main:AddButton({
    Title = "Important Button",
    Description = "This button does something important",
    Callback = function()
        Window:Dialog({
            Title = "Confirmation",
            Content = "Are you sure you want to proceed?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        print("Confirmed the dialog.")
                    end
                },
                {
                    Title = "Cancel", 
                    Callback = function()
                        print("Cancelled the dialog.")
                    end
                }
            }
        })
    end
})

Tabs.Settings:AddToggle({
    Title = "Enable Features",
    Description = "Toggle all features on/off",
    Default = true,
    Callback = function(value)
        print("Features toggled:", value)
    end
})
