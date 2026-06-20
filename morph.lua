-- Проверяем, что меню загружено и секции доступны
if not _G.SkinsLeftSection or not _G.SkinsRightSection then 
    warn("Ошибка: Основное меню Skeet не найдено!")
    return 
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция рендера объектов (копия из основного меню, чтобы работало тут)
local function renderObject(className, properties)
    local obj = Instance.new(className)
    if properties then for prop, val in pairs(properties) do obj[prop] = val end end
    return obj
end

-- ФУНКЦИЯ ЗАГРУЗКИ И ПРИМЕНЕНИЯ МОДЕЛИ
local function applyMorph(modelId)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        if _G.Library then _G.Library:Notification("Ошибка", "Персонаж не найден!", 3) end
        return
    end

    if _G.Library then _G.Library:Notification("Skins", "Загрузка модели " .. tostring(modelId) .. "...", 3) end
    
    local success, objs = pcall(function() return game:GetObjects("rbxassetid://" .. modelId) end)
    
    if not success or not objs or #objs == 0 then
        if _G.Library then _G.Library:Notification("Ошибка", "Инжектор не смог получить объект или ID забанен!", 4) end
        return
    end

    local morph = objs[1]
    if not morph:IsA("Model") then return end

    if char:FindFirstChild("CustomSkeetMorph") then char.CustomSkeetMorph:Destroy() end
    morph.Name = "CustomSkeetMorph"

    -- Прячем старое тело
    for _, p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 
        elseif p:IsA("Decal") or (p:IsA("Accessory") and p:FindFirstChild("Handle")) then p.Transparency = 1 end
    end

    -- Чистим скрипты из модели
    for _, i in pairs(morph:GetDescendants()) do
        if i:IsA("Script") or i:IsA("LocalScript") then i:Destroy() end
        if i:IsA("BasePart") then i.CanCollide = false end
    end

    morph.Parent = char
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local morphAnchor = morph.PrimaryPart or morph:FindFirstChild("HumanoidRootPart") or morph:FindFirstChild("Torso") or morph:FindFirstChild("UpperTorso")
    
    if morphAnchor and hrp then
        local w = Instance.new("Weld")
        w.Part0 = hrp; w.Part1 = morphAnchor; w.C0 = CFrame.new()
        w.C1 = hrp.CFrame:ToObjectSpace(morphAnchor.CFrame)
        w.Parent = morphAnchor
    end

    if _G.Library then _G.Library:Notification("Успех", "Морф успешно надет!", 4) end
end

-- ==========================================
-- СОЗДАНИЕ КНОПОК ПРЯМО ИЗ МОРФ.ЛУА
-- ==========================================

-- Кнопка "Загрузить Тянку" в левую секцию
local TyankaBtn = renderObject("TextButton", {
    Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.fromRGB(32, 32, 32),
    BorderColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 1, Font = Enum.Font.Code, 
    Text = "Загрузить Тянку", TextColor3 = Color3.fromRGB(160, 200, 50), TextSize = 12, Parent = _G.SkinsLeftSection
})
TyankaBtn.MouseButton1Click:Connect(function() 
    applyMorph("104751637076024") 
end)

-- Поле ввода ID в правую секцию
local CustomInput = renderObject("TextBox", {
    Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.fromRGB(26, 26, 26),
    BorderColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 1, Font = Enum.Font.Code, 
    PlaceholderText = "Введи Asset ID...", Text = "", TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 12, Parent = _G.SkinsRightSection
})

-- Кнопка "Применить ID" в правую секцию
local CustomBtn = renderObject("TextButton", {
    Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.fromRGB(32, 32, 32),
    BorderColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 1, Font = Enum.Font.Code, 
    Text = "Применить ID", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 12, Parent = _G.SkinsRightSection
})
CustomBtn.MouseButton1Click:Connect(function()
    if tonumber(CustomInput.Text) then 
        applyMorph(CustomInput.Text)
    else 
        if _G.Library then _G.Library:Notification("Ошибка", "ID должен быть из чисел!", 3) end
    end
end)

if _G.Library then _G.Library:Notification("Модуль Skins", "Кнопки успешно загружены с GitHub!", 4) end
