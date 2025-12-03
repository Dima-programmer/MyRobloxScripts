game.StarterGui:SetCore("SendNotification", {
	Title = "Загрузка...",
	Text = "Скоро загрузится Script Hub",
	Duration = 5
})

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"), true)()
local NebulaIcons = loadstring(game:HttpGetAsync("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

WindUI.Creator.AddIcons("Nebula", NebulaIcons)

local players = game:GetService("Players")  -- Сервис игроков
local runService = game:GetService("RunService")  -- Сервис для обновления
local localPlayer = players.LocalPlayer  -- Локальный игрок
local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()  -- Получение персонажа
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

local playerGui = players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptHub"
screenGui.Parent = playerGui

-- Флаг: открыто ли окно (чтобы не показывать диалог повторно)
local isWindowOpen = false
local version = "v1.4.3"
local FLING_ALL_TELEPORT_DISTANCE = 6

-- Функция открытия основного окна
local function openMainWindow()
    if isWindowOpen then return end  -- Уже открыто, выходим

    isWindowOpen = true

	-- Функция для получения вектора вперед от персонажа
	local function getForwardVector()
		local lookVector = humanoidRootPart.CFrame.LookVector
		return Vector3.new(lookVector.X, 0, lookVector.Z)  -- Игнорируем вертикальную составляющую
	end

	-- Подписываемся на событие добавления нового персонажа
	localPlayer.CharacterAdded:Connect(function(newChar)
		humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
	end)

	-- Основной цикл обновления для fling all
	runService.Stepped:Connect(function()
		if fling_all then
			-- Перебираем всех игроков
			for _, player in pairs(players:GetPlayers()) do
				if player ~= localPlayer and player.Character then  -- Проверяем, что это не мы и у игрока есть персонаж
					local targetChar = player.Character
					local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
					
					if targetRoot then
						-- Вычисляем новую позицию
						local newPosition = humanoidRootPart.Position + getForwardVector() * FLING_ALL_TELEPORT_DISTANCE
						
						-- Создаем CFrame с правильным поворотом (спиной к нам)
						local newCFrame = CFrame.new(newPosition) * 
										CFrame.Angles(0, math.pi, 0)  -- Поворот на 180 градусов вокруг оси Y
						
						-- Сохраняем исходную ориентацию по вертикали
						newCFrame = newCFrame * CFrame.Angles(humanoidRootPart.CFrame.LookVector.Y, 0, 0)
						
						-- Телепортируем игрока
						targetRoot.CFrame = newCFrame
					end
				end
			end
		end
	end)



	local window = WindUI:CreateWindow({
		Title = "Script Hub",
		Size = UDim2.new(0, 600, 0, 500),
		Position = UDim2.new(0.5, -300, 0.5, -250),
		Parent = screenGui,
		Draggable = true,
		HideSearchBar = false,
		Icon = "book",
		Author = "by Дмитрий",
		Folder = "ScriptHub",
		User = {
        	Enabled = true,
			Anonymous = false,
			Callback = function()
				WindUI:Popup({
					Title = "Информация",
					Icon = "info",
					Content = "Это твой аккаунт",
					Buttons = {
						{
							Title = "ОК",
							Callback = function() end,
							Variant = "Primary",
						}
					}
				})
			end,
    	},
	})

	Window:Tag({
		Title = version,
		Color = Color3.fromHex("#FFA500"),
		Radius = 13, -- from 0 to 13
	})

	-- window:SetToggleKey(Enum.KeyCode.LeftAlt)   -- Левый Alt
	local scriptsSection = Window:Section({
		Title = "Скрипты",
		Icon = "code",
		Opened = true,
	})
	local gamesTab = scriptsSection:Tab({
		Title = "Для игр",
		Icon = "joystick"
	})

	local universalTab = scriptsSection:Tab({
		Title = "Универсальные",
		Icon = "globe"
	})

	Window:Divider()

	local configTab = window:Tab({
		Title = "Настройки",
		Icon = "settings"
	})

	local infoTab = window:Tab({
		Title = "О хабе",
		Icon = "info"
	})

	Window:Divider()

	local function loadScript(url, scriptName)
		spawn(function()
			WindUI:Notify({
				Title = "Загрузка",
				Content = "Скачиваю " .. scriptName .. "...",
				Icon = "refresh-cw"
			})
			
			local success, response = pcall(function()
				return game:HttpGet(url, true)
			end)
			
			if not success then
				WindUI:Notify({
					Title = "Ошибка сети",
					Content = "Не удалось подключиться к серверу:\n" .. url,
					Icon = "x"
				})
				return
			end
			
			if not response or response == "" then
				WindUI:Notify({
					Title = "Пустой ответ",
					Content = scriptName .. " не загружен (пустой файл)",
					Icon = "alert-triangle"
				})
				return
			end
			
			local func, compileErr = loadstring(response, scriptName)
			if not func then
				WindUI:Notify({
					Title = "Ошибка компиляции",
					Content = "Не удалось обработать скрипт:\n" .. (compileErr or ""),
					Icon = "x"
				})
				return
			end
			
			pcall(func)
			
			WindUI:Notify({
				Title = "Успешно!",
				Content = scriptName .. " загружен и запущен!",
				Icon = "check"
			})
		end)
	end

	-- Игровые скрипты
	gamesTab:Button({
		Title = "BABFT (Build A Boat For Treasure)",
		Desc = "Автоматизация строительства корабля и добычи сокровищ",
		Icon = "ship",
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/TheRealAsu/BABFT/refs/heads/main/Loader.lua",
				"BABFT (Build A Boat For Treasure)"
			)
		end
	})

	gamesTab:Button({
		Title = "99 Nights in the Forest",
		Desc = "Приключенческий хоррор в лесу",
		Icon = "moon",
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua",
				"99 Nights in the Forest"
			)
		end
	})

	gamesTab:Button({
		Title = "Elemental Powers Tycoon",
		Desc = "Развитие стихийных сил",
		Icon = "flame",
		Callback = function()
			loadScript(
				"https://pastebin.com/raw/9UfgA0Rb",
				"Elemental Powers Tycoon"
			)
		end
	})

	gamesTab:Button({
		Title = "Grow a Garden",
		Desc = "Садоводство и рост растений",
		Icon = "carrot",
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/nootmaus/GrowAAGarden/refs/heads/main/mauscripts",
				"Grow a Garden"
			)
		end
	})

	gamesTab:Button({
		Title = "Lucky Blocks",
		Desc = "Случайные блоки с сюрпризами",
		Icon = "gift",
		Callback = function()
			loadScript(
				"https://pandadevelopment.net/virtual/file/b26d90990ddc4cbb",
				"Lucky Blocks"
			)
		end
	})

	gamesTab:Button({
		Title = "MM2",
		Desc = "Murder Mystery 2",
		Icon = "skull",
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/vertex-peak/vertex/refs/heads/main/loadstring",
				"MM2"
			)
		end
	})

	gamesTab:Button({
		Title = "PVB",
		Desc = "Plants VS Brainrots",
		Callback = function()
			loadScript(
				"https://hackmanhub.pages.dev/loader.txt",
				"PVB"
			)
		end
	})

	gamesTab:Button({
		Title = "SAB",
		Desc = "Steal a brainrot",
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/OverflowBGSI/Overflow/refs/heads/main/loader.txt",
				"SAB"
			)
		end
	})

	gamesTab:Button({
		Title = "Fish It",
		Desc = "Fish It Script",
		Icon = "fish",
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games",
				"Fish It"
			)	
		end
	})

	-- Универсальные скрипты
	universalTab:Button({
		Title = "Infinity Yield",
		Desc = "Мощный админ-инструмент для Roblox",
		Icon = "terminal",
		Color = Color3.fromHex("#ff6b00"),
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
				"Infinity Yield"
			)
		end
	})

	universalTab:Button({
		Title = "Dex",
		Desc = "Позволяет просматривать файлы игры",
		Icon = "folder",
		Color = Color3.fromHex("#F9F871"),
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/infyiff/backup/main/dex.lua",
				"Dex"
			)
		end
	})

	universalTab:Button({
		Title = "Tool Modifer",
		Desc = "Позволяет изменить любой предмет в руке",
		Icon = "wrench",
		Color = Color3.fromRGB(0, 20, 150),
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/Dima-programmer/copy_of_rb_scripts/refs/heads/main/Tool-Modifer.lua",
				"Tool Modifer"
			)
		end
	})

	local giveItemsSection = universalTab:Section({
		Title = "Предметы",
		Icon = "hammer",
		Opened = true,
	})

	giveItemsSection:Button({
		Title = "Speed Coil",
		Desc = "Пружина для скорости",
		Callback = function()
			loadScript(
				"https://raw.githubusercontent.com/Dima-programmer/copy_of_rb_scripts/refs/heads/main/Speed%20Coil.lua",
				"Speed Coil"
			)
		end
	})

	giveItemsSection:Button({
		Title = "Jump Coil",
		Desc = "Пружина для сильного прыжка",
		Callback = function()
			loadScript(
				"https://pastefy.app/xN8DH39z/raw",
				"Jump Coil"
			)
		end
	})

	local builtinScriptsSection = universalTab:Section({
		Title = "Встроенные скрипты",
		Icon = "paperclip",
		Opened = true,
	})

	local flingAllSection = universalTab:Section({
		Title = "Fling all",
		Opened = false,
	})
	
	flingAllSection:Toggle({
		Title = "Активация",
		Callback = function(state)
        	fling_all = state
    	end
	})

	flingAllSection:Slider({
		Title = "Радиус",
		Desc = "Радиус в studs",
		Step = 1,
		Value = {
			Min = 1,
			Max = 20,
			Default = 6,
		},
		Callback = function(value)
			FLING_ALL_TELEPORT_DISTANCE = value
		end
	})


	local ConfigManager = Window.ConfigManager
	
	local KeyBind_open_ui = configTab:Keybind({
		Flag = "KeyBind-open-ui",
        Title = "Открыть окно",
        Desc = "Клавиша для открытия окна",
        Value = "RightAlt",
		Icon = "window",
        Callback = function(v)
            Window:SetToggleKey(Enum.KeyCode[v])
			Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
			Window.CurrentConfig:Save()
			-- print(v)
        end
    })
	Window.CurrentConfig = ConfigManager:CreateConfig("Custom")

	Window.CurrentConfig:Load()
	-- configTab:Space()
	-- configTab:Divider()
	-- configTab:Button({
	-- 	Title = "Сброс",
	-- 	Desc = "Сброс до изначальных настроек",
	-- 	Justify = "Center",
	-- 	Icon = "Trash",
	-- 	Color = Color3.fromRGB(255, 36, 0),
	-- 	Callback = function()
	-- 		Window.CurrentConfig = ConfigManager:CreateConfig("Default")
	-- 		defaultConfig:Load()
	-- 		Window.CurrentConfig = ConfigManager:CreateConfig("Custom")
	-- 		Window.CurrentConfig:Register("KeyBind-open-ui", KeyBind_open_ui)
	-- 		customConfig:Save()
	-- 		-- print('Х')
	-- 	end
	-- })

	-- Раздел "О хабе"
	infoTab:Paragraph({
		Title = "Как использовать:",
		Desc = [[
	1. Выберите скрипт из списка
	2. Нажмите на кнопку
	3. Дождитесь уведомления об успешной загрузки
	4. Скрипт начнёт работать автоматически

	Предупреждение:
	- Используйте только доверенные скрипты
	- Некоторые скрипты могут нарушать правила Roblox
	- Всегда проверяйте источник кода перед запуском
		]],
		TextSize = 12,
		FontWeight = Enum.FontWeight.Medium
	})

	infoTab:Paragraph({
		Title = "Информация о хабе:",
		Desc = [[
	- Версия: ]] .. version .. [[

	- Автор: Дмитрий
	- Назначение: централизованный запуск скриптов
	- Интерфейс: WindUI

	Рекомендации:
	- Обновляйте хаб при изменении URL скриптов
	- Проверяйте работоспособность кнопок после обновлений
	- Закрывайте хаб, когда он не нужен
		]],
		TextSize = 12,
		FontWeight = Enum.FontWeight.Medium
	})

	WindUI:Notify({
        Title = "Хаб активен",
        Content = "Скрипты находяться в разделах Игры и Универсальные",
        Icon = "check"
    })
end

WindUI:Popup({
    Title = "Script Hub",
    Icon = "info",
    Content = "Подтвердите, что хотите загрузть Script Hub",
    Buttons = {
        {
            Title = "Отмена",
            Callback = function()
				    WindUI:Notify({
						Title = "Отменено",
						Content = "Script Hub не открыт",
						Icon = "x"
                })
			end,
            Variant = "Tertiary",
        },
        {
            Title = "Загрузить",
            Icon = "arrow-right",
            Callback = function()
				openMainWindow()
			end,
            Variant = "Primary",
        }
    }
})
