local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local LocalPlayer = Players.LocalPlayer

-- Получаем ID модели, переданный из меню
local modelId = tonumber(_G.TargetModelId)

if not modelId then
    if _G.Library then _G.Library:Notification("Morph Error", "ID модели не найден!", 3) end
    return
end

local char = LocalPlayer.Character
if not char or not char:FindFirstChild("HumanoidRootPart") then
    if _G.Library then _G.Library:Notification("Ошибка", "Персонаж не найден!", 3) end
    return
end

-- Обход блокировки GetObjects через InsertService специально для мобильных инжекторов
local success, morph = pcall(function()
    return InsertService:LoadAsset(modelId)
end)

if not success or not morph then
    -- Если LoadAsset заблокирован в этом плейсе, пробуем альтернативный метод импорта
    local altSuccess, objs = pcall(function() 
        return game:GetObjects("rbxassetid://" .. tostring(modelId)) 
    end)
    if altSuccess and objs and #objs > 0 then
        morph = objs[1]
    else
        if _G.Library then 
            _G.Library:Notification("Ошибка загрузки", "Инжектор заблокировал загрузку этой модели!", 5) 
        end
        return
    end
end

-- Если модель загрузилась внутри папки/модели, достаем её наружу
if morph:IsA("Model") and #morph:GetChildren() == 1 and morph:GetChildren()[1]:IsA("Model") then
    local realMorph = morph:GetChildren()[1]
    realMorph.Parent = morph
    morph = realMorph
end

-- Удаляем старый морф, если он уже был
if char:FindFirstChild("CustomSkeetMorph") then 
    char.CustomSkeetMorph:Destroy() 
end
morph.Name = "CustomSkeetMorph"

-- Делаем оригинального персонажа невидимым
for _, p in pairs(char:GetDescendants()) do
    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then 
        p.Transparency = 1 
    elseif p:IsA("Decal") or (p:IsA("Accessory") and p:FindFirstChild("Handle")) then 
        if p:IsA("Decal") then p.Transparency = 1 end
        if p:FindFirstChild("Handle") then p.Handle.Transparency = 1 end
    end
end

-- Очищаем скрипты внутри загруженной модели, чтобы игра не кикнула
for _, i in pairs(morph:GetDescendants()) do
    if i:IsA("Script") or i:IsA("LocalScript") then 
        i:Destroy() 
    end
    if i:IsA("BasePart") then 
        i.CanCollide = false 
    end
end

-- Привязываем новую модель к твоему персонажу
morph.Parent = char
local hrp = char:FindFirstChild("HumanoidRootPart")
local morphAnchor = morph.PrimaryPart or morph:FindFirstChild("HumanoidRootPart") or morph:FindFirstChild("Torso") or morph:FindFirstChild("UpperTorso") or morph:FindFirstChildOfClass("BasePart")

if morphAnchor and hrp then
    local w = Instance.new("Weld")
    w.Part0 = hrp
    w.Part1 = morphAnchor
    w.C0 = CFrame.new(0, 0, 0) -- Если модель спавнится криво, тут можно настроить высоту (например CFrame.new(0, -2, 0))
    w.C1 = hrp.CFrame:ToObjectSpace(morphAnchor.CFrame)
    w.Parent = morphAnchor
end

if _G.Library then 
    _G.Library:Notification("Успех", "Морф успешно загружен и надет!", 3) 
end
