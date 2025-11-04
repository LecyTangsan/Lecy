-- 🌟 Lecy UI Hub v2
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AutoFishButton = Instance.new("TextButton")
local SpeedButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

-- FRAME UTAMA
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

-- JUDUL
Title.Parent = MainFrame
Title.Text = "🌟 Lecy UI Hub v2 🌟"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextScaled = true

-- TOMBOL AUTO FISH
AutoFishButton.Parent = MainFrame
AutoFishButton.Position = UDim2.new(0.1, 0, 0.3, 0)
AutoFishButton.Size = UDim2.new(0.8, 0, 0.2, 0)
AutoFishButton.Text = "🎣 Auto Fish: OFF"
AutoFishButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoFishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFishButton.TextScaled = true

-- TOMBOL SPEED BOOST
SpeedButton.Parent = MainFrame
SpeedButton.Position = UDim2.new(0.1, 0, 0.55, 0)
SpeedButton.Size = UDim2.new(0.8, 0, 0.2, 0)
SpeedButton.Text = "⚡ Speed Boost"
SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.TextScaled = true

-- TOMBOL CLOSE
CloseButton.Parent = MainFrame
CloseButton.Position = UDim2.new(0.1, 0, 0.8, 0)
CloseButton.Size = UDim2.new(0.8, 0, 0.15, 0)
CloseButton.Text = "❌ Close"
CloseButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true

-- VARIABEL STATUS
local autoFishEnabled = false

-- FUNGSI AUTO FISH (simulasi)
AutoFishButton.MouseButton1Click:Connect(function()
	autoFishEnabled = not autoFishEnabled
	if autoFishEnabled then
		AutoFishButton.Text = "🎣 Auto Fish: ON"
		while autoFishEnabled do
			print("Memancing otomatis... 🎣")
			task.wait(2)
		end
	else
		AutoFishButton.Text = "🎣 Auto Fish: OFF"
	end
end)

-- FUNGSI SPEED BOOST
SpeedButton.MouseButton1Click:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 60
		print("⚡ Speed Boost aktif!")
	end
end)

-- FUNGSI CLOSE
CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
	print("❌ Lecy UI Hub ditutup.")
end)

print("✅ Lecy UI Hub v2 berhasil dimuat!")
