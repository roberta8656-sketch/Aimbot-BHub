-- BHUB - Aimbot + ESP + Painel (Delta Mobile)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- CONFIGURAÇÕES
local Config = {
    Aimbot = true,
    AimPart = "Head", -- Head / HumanoidRootPart
    ESP = true,
    FOV = 100,
    FOVColor = Color3.fromRGB(255, 255, 255),
    ESPColor = Color3.fromRGB(255, 0, 0),
    ShowFOVCircle = true,
}

-- BOTÃO ABRIR/FECHAR PAINEL
local abrirFechar = Instance.new("TextButton")
abrirFechar.Size = UDim2.new(0, 70, 0, 30)
abrirFechar.Position = UDim2.new(0, 10, 0, 10)
abrirFechar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
abrirFechar.TextColor3 = Color3.new(1, 1, 1)
abrirFechar.Text = "Painel"
abrirFechar.Parent = game.CoreGui

-- CRIAR PAINEL
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 200)
Frame.Position = UDim2.new(0, 100, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Visible = false

local function criarToggle(nome, callback)
    local toggle = Instance.new("TextButton", Frame)
    toggle.Size = UDim2.new(1, 0, 0, 30)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Text = nome
    toggle.MouseButton1Click:Connect(function()
        callback()
    end)
end

-- TOGGLES
criarToggle("Ativar/Desativar Aimbot", function()
    Config.Aimbot = not Config.Aimbot
end)

criarToggle("Ativar/Desativar ESP", function()
    Config.ESP = not Config.ESP
end)

-- FOV CIRCLE
local circle = Drawing.new("Circle")
circle.Color = Config.FOVColor
circle.Radius = Config.FOV
circle.Thickness = 1
circle.Transparency = 0.4
circle.Visible = Config.ShowFOVCircle
circle.Filled = false

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Mouse.X, Mouse.Y)
    circle.Visible = Config.ShowFOVCircle and Config.Aimbot
end)

-- AIMBOT
function getClosest()
    local closest, dist = nil, Config.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.AimPart) then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character[Config.AimPart].Position)
            if onScreen then
                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mag < dist then
                    dist = mag
                    closest = p
                end
            end
        end
    end
    return closest
end

-- TRAVA MIRA
RunService.RenderStepped:Connect(function()
    if Config.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosest()
        if target and target.Character then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character[Config.AimPart].Position)
        end
    end
end)

-- ESP
RunService.RenderStepped:Connect(function()
    if not Config.ESP then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local tag = Drawing.new("Text")
            tag.Text = player.Name
            tag.Size = 13
            tag.Center = true
            tag.Outline = true
            tag.Color = Config.ESPColor
            tag.Visible = true

            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
            tag.Position = Vector2.new(pos.X, pos.Y - 20)
            
            delay(0.1, function()
                tag:Remove()
            end)
        end
    end
end)

-- ABRIR/FECHAR PAINEL
abrirFechar.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)
