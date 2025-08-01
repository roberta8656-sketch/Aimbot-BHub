-- BHub Aimbot + ESP + Painel (Versão Mobile/Delta)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ESP Simples e Leve
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
        local esp = Drawing.new("Text")
        esp.Text = player.Name
        esp.Size = 13
        esp.Center = true
        esp.Outline = true
        esp.Color = Color3.fromRGB(255, 0, 0)
        esp.Visible = true

        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Head") then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
                esp.Position = Vector2.new(pos.X, pos.Y)
                esp.Visible = onScreen
            else
                esp.Visible = false
            end
        end)
    end
end

-- Aimbot Inteligente
getgenv().AimbotSettings = {
    AimPart = "Head",
    FOV = 100,
    TeamCheck = true,
    WallCheck = true,
    Smoothness = 0.08
}

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local FOV = Drawing.new("Circle")
FOV.Color = Color3.fromRGB(0, 255, 0)
FOV.Thickness = 1
FOV.Radius = getgenv().AimbotSettings.FOV
FOV.NumSides = 60
FOV.Transparency = 0.5
FOV.Visible = true
FOV.Filled = false

function GetClosestPlayer()
    local closest = nil
    local shortest = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(getgenv().AimbotSettings.AimPart) then
            if getgenv().AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local part = player.Character[getgenv().AimbotSettings.AimPart]
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if dist < getgenv().AimbotSettings.FOV and dist < shortest then
                shortest = dist
                closest = part
            end
        end
    end

    return closest
end

local aiming = false
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- mira quando segura botão direito
        aiming = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Mouse.X, Mouse.Y)
    if aiming then
        local target = GetClosestPlayer()
        if target then
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(
                CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position),
                getgenv().AimbotSettings.Smoothness
            )
        end
    end
end)

-- Painel simples: botão flutuante para abrir/fechar
local GUI = Instance.new("ScreenGui", game.CoreGui)
local Toggle = Instance.new("TextButton", GUI)
Toggle.Text = "Abrir Painel"
Toggle.Position = UDim2.new(0, 10, 0, 100)
Toggle.Size = UDim2.new(0, 120, 0, 30)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)

local Panel = Instance.new("Frame", GUI)
Panel.Size = UDim2.new(0, 220, 0, 200)
Panel.Position = UDim2.new(0, 10, 0, 140)
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Panel.Visible = false

Toggle.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
end)

local Titulo = Instance.new("TextLabel", Panel)
Titulo.Text = "BHub Painel"
Titulo.Size = UDim2.new(1, 0, 0, 30)
Titulo.BackgroundTransparency = 1
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Botão FOV+
local MaisFOV = Instance.new("TextButton", Panel)
MaisFOV.Position = UDim2.new(0, 10, 0, 50)
MaisFOV.Size = UDim2.new(0, 90, 0, 30)
MaisFOV.Text = "FOV +"
MaisFOV.MouseButton1Click:Connect(function()
    getgenv().AimbotSettings.FOV += 20
    FOV.Radius = getgenv().AimbotSettings.FOV
end)

-- Botão FOV-
local MenosFOV = Instance.new("TextButton", Panel)
MenosFOV.Position = UDim2.new(0, 120, 0, 50)
MenosFOV.Size = UDim2.new(0, 90, 0, 30)
MenosFOV.Text = "FOV -"
MenosFOV.MouseButton1Click:Connect(function()
    getgenv().AimbotSettings.FOV = math.max(20, getgenv().AimbotSettings.FOV - 20)
    FOV.Radius = getgenv().AimbotSettings.FOV
end)
