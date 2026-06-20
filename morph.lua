local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Берем ID, который передало меню
local modelId = _G.TargetModelId

if not modelId then
    if _G.Library then _G.Library:Notification("Morph Error", "ID модели не найден!", 3) end
    return
end

local char = LocalPlayer.Character
if not char or not char:FindFirstChild("HumanoidRootPart") then
    if _G.Library then _G.Library:Notification("Ошибка", "Персонаж еще не спавнился!", 3) end
    return
end

-- Скачиваем модель из Roblox
local success, objs = pcall(function() 
    return game:GetObjects("rbxassetid://" .. modelId) 
end)

if not success or not objs or #objs == 0 then
    if _G.Library then 
        _G.Library:Notification("Ошибка Delta", "Delta API заблокировал GetObjects или неверный ID!", 5) 
    end
    return
end

local morph = objs[1]
if not morph:IsA("Model") then return end

-- Удаляем старый морф, если он был
if char:FindFirstChild("CustomSkeetMorph") then 
    char.CustomSkeetMorph:Destroy() 
end
morph.Name = "CustomSkeetMorph"

-- Скрываем оригинальное тело персонажа
for _, p in pairs(char:GetDescendants()) do
    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then 
        p.Transparency = 1 
    elseif p:IsA("Decal") or (p:IsA("Accessory") and p:FindFirstChild("Handle")) then 
        p.Transparency = 1 
    end
end

-- Очищаем скрипты внутри модели
for _, i in pairs(morph:GetDescendants()) do
    if i:IsA("Script") or i:IsA("LocalScript") then 
        i:Destroy() 
    end
    if i:IsA("BasePart") then 
        i.CanCollide = false 
    end
end

-- Насаживаем новую модель на HumanoidRootPart
morph.Parent = char
local hrp = char:FindFirstChild("HumanoidRootPart")
local morphAnchor = morph.PrimaryPart or morph:FindFirstChild("HumanoidRootPart") or morph:FindFirstChild("Torso") or morph:FindFirstChild("UpperTorso")

if morphAnchor and hrp then
    local w = Instance.new("Weld")
    w.Part0 = hrp
    w.Part1 = morphAnchor
    w.C0 = CFrame.new()
    w.C1 = hrp.CFrame:ToObjectSpace(morphAnchor.CFrame)
    w.Parent = morphAnchor
end

if _G.Library then 
    _G.Library:Notification("Успех", "Морф успешно применен!", 3) 
end
