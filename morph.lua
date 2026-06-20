local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Берем ID, который передала кнопка из основного меню
local modelId = _G.TargetModelId

if not modelId then
    if _G.Library then _G.Library:Notification("Morph Error", "ID модели не передан!", 3) end
    return
end

local char = LocalPlayer.Character
if not char or not char:FindFirstChild("HumanoidRootPart") then
    if _G.Library then _G.Library:Notification("Ошибка", "Персонаж не найден в мире!", 3) end
    return
end

-- Пробуем загрузить модель из базы Roblox
local success, objs = pcall(function() 
    return game:GetObjects("rbxassetid://" .. modelId) 
end)

if not success or not objs or #objs == 0 then
    if _G.Library then 
        _G.Library:Notification("Ошибка загрузки", "Инжектор не смог получить модель. Ошибка или неверный ID.", 4) 
    end
    warn("Ошибка выполнения GetObjects: " .. tostring(objs))
    return
end

local morph = objs[1]
if not morph:IsA("Model") then 
    if _G.Library then _G.Library:Notification("Ошибка", "Объект не является моделью!", 3) end
    return 
end

-- Если старый морф уже был, удаляем его
if char:FindFirstChild("CustomSkeetMorph") then 
    char.CustomSkeetMorph:Destroy() 
end
morph.Name = "CustomSkeetMorph"

-- Делаем оригинального персонажа невидимым (кроме RootPart)
for _, p in pairs(char:GetDescendants()) do
    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then 
        p.Transparency = 1 
    elseif p:IsA("Decal") or (p:IsA("Accessory") and p:FindFirstChild("Handle")) then 
        p.Transparency = 1 
    end
end

-- Чистим вредоносные или мешающие скрипты внутри самой модели
for _, i in pairs(morph:GetDescendants()) do
    if i:IsA("Script") or i:IsA("LocalScript") then 
        i:Destroy() 
    end
    if i:IsA("BasePart") then 
        i.CanCollide = false 
    end
end

-- Насаживаем морф на персонажа через Weld
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
else
    if _G.Library then _G.Library:Notification("Предупреждение", "Не найден основной Part в модели для привязки!", 4) end
end

if _G.Library then 
    _G.Library:Notification("Успех", "Модель с GitHub успешно загружена и применена!", 4) 
end
