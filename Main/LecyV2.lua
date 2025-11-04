-- Lecy UI Hub (versi sederhana)
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Active = true
Frame.Draggable = true

TextLabel.Parent = Frame
TextLabel.Text = "🌟 Lecy UI Hub Loaded 🌟"
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.TextScaled = true

print("✅ Lecy UI Hub berhasil dimuat!")
