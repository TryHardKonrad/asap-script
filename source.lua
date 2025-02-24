local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "A$AP SCRIPT",
   LoadingTitle = "A$AP INTERACTIVE",
   LoadingSubtitle = "by _thkonrad",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "A$AP SCRIPT"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Key | Youtube Hub",
      Subtitle = "Key System",
      Note = "Key In Discord Server",
      FileName = "YoutubeHubKey1", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://pastebin.com/raw/AtgzSPWK"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🏠 Główne", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "Twój skrypt jest executed",
   Content = "Życzymy miłej rozgrywki",
   Duration = 5,
   Image = 13047715178,
   Actions = { -- Notification Buttons
      Ignore = {
         Name = "Ok!",
         Callback = function()
      end
   },
},
})

local Slider = MainTab:CreateSlider({
   Name = "Prędkość postaci",
   Range = {0, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 150,
   Flag = "sliderws", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Value)
   end,
})

local OtherSection = MainTab:CreateSection("ESP")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ESP_Enabled = false -- Domyślnie ESP wyłączone
local ESP_Objects = {} -- Przechowujemy efekty poświaty

-- Funkcja do tworzenia glow (Highlight)
local function CreateESP(player)
    if player ~= LocalPlayer and ESP_Enabled then
        local character = player.Character
        if character then
            -- Sprawdzamy, czy już istnieje efekt
            if not ESP_Objects[player] then
                local highlight = Instance.new("Highlight")
                highlight.Parent = character
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Czerwony kolor
                highlight.FillTransparency = 0.3 -- Lekka przeźroczystość
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Biała obwódka
                highlight.OutlineTransparency = 0 -- Pełna widoczność obramowania
                
                ESP_Objects[player] = highlight -- Zapisujemy efekt
                
                -- Gdy gracz odradza się, dodajemy ponownie highlight
                player.CharacterAdded:Connect(function(newCharacter)
                    task.wait(1) -- Czekamy na załadowanie postaci
                    if ESP_Enabled then
                        highlight.Parent = newCharacter
                    end
                end)
            end
        end
    end
end

-- Funkcja do usuwania ESP
local function RemoveESP(player)
    if ESP_Objects[player] then
        ESP_Objects[player]:Destroy()
        ESP_Objects[player] = nil
    end
end

-- Funkcja do włączania/wyłączania ESP
local function ToggleESP(enabled)
    ESP_Enabled = enabled

    if ESP_Enabled then
        -- Dodajemy ESP dla wszystkich obecnych graczy
        for _, player in ipairs(Players:GetPlayers()) do
            CreateESP(player)
        end
    else
        -- Usuwamy wszystkie ESP
        for _, obj in pairs(ESP_Objects) do
            obj:Destroy()
        end
        ESP_Objects = {}
    end
end

-- Obsługa dołączania i wychodzenia graczy
Players.PlayerAdded:Connect(function(player)
    if ESP_Enabled then
        CreateESP(player)
    end
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- Toggle w Rayfield UI
local Toggle = MainTab:CreateToggle({
   Name = "Glow",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       ToggleESP(Value)
   end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ESP_Name_Enabled = false -- Domyślnie wyłączone
local Snapline_Enabled = false -- Domyślnie wyłączone
local ESP_Objects = {} -- Przechowujemy nazwy i linie

-- Funkcja do tworzenia ESP (nazwy i snapline)
local function CreateESP(player)
    if player ~= LocalPlayer then
        local character = player.Character
        if character and character:FindFirstChild("Head") then
            -- Tworzenie BillboardGui dla nazwy, jeśli włączone
            local billboard
            if ESP_Name_Enabled then
                billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0) -- Wysokość nad głową
                billboard.Adornee = character.Head
                billboard.Parent = character
                billboard.AlwaysOnTop = true

                local textLabel = Instance.new("TextLabel", billboard)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Biały tekst
                textLabel.TextStrokeTransparency = 0 -- Czarne obramowanie tekstu
                textLabel.Text = player.Name
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = 14 -- Możesz zmienić np. na 24
            end

            -- Tworzenie Snapline (Linii), jeśli włączone
            local line
            if Snapline_Enabled then
                line = Drawing.new("Line")
                line.Thickness = 1.5
                line.Color = Color3.fromRGB(255, 255, 255)
                line.Transparency = 1
                line.Visible = false -- Ensure it's hidden initially until it's needed
            end

            ESP_Objects[player] = {
                NameTag = billboard,
                Line = line
            }

            -- Gdy gracz odradza się, ponownie dodajemy elementy
            player.CharacterAdded:Connect(function(newCharacter)
                task.wait(1) -- Czekamy na załadowanie
                if ESP_Name_Enabled and newCharacter:FindFirstChild("Head") then
                    billboard.Adornee = newCharacter.Head
                    billboard.Parent = newCharacter
                end
            end)

            -- Aktualizowanie pozycji Snapline, jeśli włączone
            game:GetService("RunService").RenderStepped:Connect(function()
                -- Check if line exists before proceeding
                if line then
                    if Snapline_Enabled and character and character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local headPosition, onScreen1 = workspace.CurrentCamera:WorldToViewportPoint(character.Head.Position)
                        local myPosition, onScreen2 = workspace.CurrentCamera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)

                        if onScreen1 and onScreen2 then
                            line.From = Vector2.new(myPosition.X, myPosition.Y)
                            line.To = Vector2.new(headPosition.X, headPosition.Y)
                            line.Visible = true -- Only show the line if both characters are on screen
                        else
                            line.Visible = false -- Hide line if either character is off screen
                        end
                    else
                        line.Visible = false -- Hide line if conditions aren't met
                    end
                end
            end)
        end
    end
end

-- Funkcja do usuwania ESP
local function RemoveESP(player)
    if ESP_Objects[player] then
        if ESP_Objects[player].NameTag then ESP_Objects[player].NameTag:Destroy() end
        if ESP_Objects[player].Line then ESP_Objects[player].Line:Remove() end
        ESP_Objects[player] = nil
    end
end

-- Funkcja do włączania/wyłączania ESP (Nazwa)
local function ToggleNameESP(enabled)
    ESP_Name_Enabled = enabled

    if ESP_Name_Enabled then
        -- Tworzymy ESP dla graczy, którzy są już w grze
        for _, player in ipairs(Players:GetPlayers()) do
            if not ESP_Objects[player] then
                CreateESP(player)
            end
        end
    else
        -- Usuwamy wszystkie elementy NameTag
        for _, obj in pairs(ESP_Objects) do
            if obj.NameTag then
                obj.NameTag:Destroy()
            end
        end
        ESP_Objects = {} -- Resetowanie ESP_Objects po wyłączeniu
    end
end

-- Funkcja do włączania/wyłączania Snapline
local function ToggleSnapline(enabled)
    Snapline_Enabled = enabled

    if Snapline_Enabled then
        -- Tworzymy Snapline dla graczy, którzy są już w grze
        for _, player in ipairs(Players:GetPlayers()) do
            if not ESP_Objects[player] then
                CreateESP(player)
            end
        end
    else
        -- Usuwamy wszystkie Snapline
        for _, obj in pairs(ESP_Objects) do
            if obj.Line then
                obj.Line:Remove()
            end
        end
        ESP_Objects = {} -- Resetowanie ESP_Objects po wyłączeniu
    end
end

-- Obsługa dołączania i wychodzenia graczy
Players.PlayerAdded:Connect(function(player)
    if ESP_Name_Enabled then
        CreateESP(player)
    end
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- Toggle w Rayfield UI dla Nazw (ESP)
local ToggleName = MainTab:CreateToggle({
   Name = "Name",
   CurrentValue = false,
   Flag = "Toggle2",
   Callback = function(Value)
       ToggleNameESP(Value)
   end,
})

-- Toggle w Rayfield UI dla Snapline
local ToggleSnapline = MainTab:CreateToggle({
   Name = "Snapline",
   CurrentValue = false,
   Flag = "Toggle3",
   Callback = function(Value)
       ToggleSnapline(Value)
   end,
})


local OtherSection = MainTab:CreateSection("Others")

local Clip = false
local Noclipping = nil
local character = game.Players.LocalPlayer.Character
local RunService = game:GetService("RunService")

-- Funkcja uruchamiająca noclip
local function ToggleNoclip(enabled)
    if not character then return end

    -- Funkcja włączająca noclip
    if enabled and not Clip then
        Clip = true
        -- Przełączamy CanCollide dla wszystkich części postaci na false
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = false
            end
        end

        -- Sprawdzanie co klatkę, aby utrzymać noclip aktywne
        Noclipping = RunService.Stepped:Connect(function()
            if Clip then
                for _, child in pairs(character:GetDescendants()) do
                    if child:IsA("BasePart") then
                        child.CanCollide = false
                    end
                end
            end
        end)

        -- Powiadomienie, że Noclip jest włączony
        Rayfield:Notify({
            Title = "Noclip Włączony",
            Content = "Noclip został włączony. Możesz przechodzić przez obiekty.",
            Duration = 5,
            Image = 13047715178,
            Actions = { 
                Ignore = {
                    Name = "Ok!",
                    Callback = function() end
                },
            },
        })

    elseif not enabled and Clip then
        Clip = false
        -- Przywracamy standardowe ustawienia CanCollide
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = true
            end
        end

        -- Zatrzymujemy Noclip
        if Noclipping then
            Noclipping:Disconnect()
        end

        -- Powiadomienie, że Noclip jest wyłączony
        Rayfield:Notify({
            Title = "Noclip Wyłączony",
            Content = "Noclip został wyłączony. Powrócono do normalnego trybu.",
            Duration = 5,
            Image = 13047715178,
            Actions = { 
                Ignore = {
                    Name = "Ok!",
                    Callback = function() end
                },
            },
        })
    end
end

-- Funkcja do monitorowania zmiany postaci
game.Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    if Clip then
        -- Jeśli noclip był włączony, ponownie aktywujemy noclip dla nowej postaci
        ToggleNoclip(true)
    end
end)

-- Przycisk do togglowania noclip
local ToggleNoclipButton = MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "ToggleNoclip", 
    Callback = function(Value)
        ToggleNoclip(Value)  -- Wywołuje funkcję ToggleNoclip
    end,
})

local FLYING = false
local flyKeyDown, flyKeyUp
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local SPEED = 10  -- Początkowa prędkość lotu

-- Powiadomienie przy włączeniu latania
local function notifyFlyOn()
    Rayfield:Notify({
        Title = "Fly włączony",
        Content = "Możesz teraz latać skibidi toilecie.",
        Duration = 5,
        Image = 13047715178,
        Actions = {
            Ignore = {
                Name = "OK",
                Callback = function() end
            }
        }
    })
end

-- Powiadomienie przy wyłączeniu latania
local function notifyFlyOff()
    Rayfield:Notify({
        Title = "Fly wyłączony",
        Content = "Zatrzymano latnko skurwysynku.",
        Duration = 5,
        Image = 13047715178,
        Actions = {
            Ignore = {
                Name = "OK",
                Callback = function() end
            }
        }
    })
end

local function startFly()
    FLYING = true
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    local rootPart = character and character:FindFirstChild('HumanoidRootPart')

    -- Tworzymy BodyGyro i BodyVelocity
    local BG = Instance.new('BodyGyro')
    local BV = Instance.new('BodyVelocity')

    BG.P = 9e4
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.CFrame = rootPart.CFrame
    BG.Parent = rootPart

    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
    BV.Parent = rootPart

    -- Funkcja latania
    local function flyLoop()
        repeat
            if not FLYING or not humanoid then break end
            BV.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + 
                            ((workspace.CurrentCamera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CFrame.p)) * SPEED
            BG.CFrame = workspace.CurrentCamera.CFrame
            wait(0.01)
        until not FLYING
        BG:Destroy()
        BV:Destroy()
    end

    -- Zaczynamy latanie
    flyLoop()

    -- Powiadomienie o włączeniu
    notifyFlyOn()
end

local function stopFly()
    FLYING = false
    CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}

    -- Powiadomienie o wyłączeniu
    notifyFlyOff()
end

-- Obsługa klawiszy
flyKeyDown = game:GetService('UserInputService').InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W then
            CONTROL.F = SPEED
        elseif input.KeyCode == Enum.KeyCode.S then
            CONTROL.B = -SPEED
        elseif input.KeyCode == Enum.KeyCode.A then
            CONTROL.L = -SPEED
        elseif input.KeyCode == Enum.KeyCode.D then
            CONTROL.R = SPEED
        elseif input.KeyCode == Enum.KeyCode.Q then
            CONTROL.E = -SPEED
        elseif input.KeyCode == Enum.KeyCode.E then
            CONTROL.Q = SPEED
        end
    end
end)

flyKeyUp = game:GetService('UserInputService').InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W then
            CONTROL.F = 0
        elseif input.KeyCode == Enum.KeyCode.S then
            CONTROL.B = 0
        elseif input.KeyCode == Enum.KeyCode.A then
            CONTROL.L = 0
        elseif input.KeyCode == Enum.KeyCode.D then
            CONTROL.R = 0
        elseif input.KeyCode == Enum.KeyCode.Q then
            CONTROL.E = 0
        elseif input.KeyCode == Enum.KeyCode.E then
            CONTROL.Q = 0
        end
    end
end)

-- Przycisk Toggle Fly
local ToggleFlyButton = MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "ToggleFly", 
    Callback = function(Value)
        if Value then
            startFly()
        else
            stopFly()
        end
    end,
})

-- Slider do zmiany prędkości
local Slider = MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {5, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 10,
    Flag = "FlySpeedSlider", -- Unikalny identyfikator
    Callback = function(Value)
        SPEED = Value
    end,
})









-- Tworzenie zakładki w Rayfield UI
local TPTab = Window:CreateTab("🏝 Teleportowanie", nil)

-- Sekcja dla listy graczy
local PlayerSection = TPTab:CreateSection("Lista Graczy")

-- Przechowujemy wszystkie przyciski, aby je usuwać przy aktualizacji
local buttons = {}

-- Funkcja do usuwania starych przycisków
local function ClearButtons()
    for _, button in ipairs(buttons) do
        button:Destroy()
    end
    table.clear(buttons)
end

-- Funkcja do aktualizacji listy graczy i przycisków
local function UpdatePlayerList()
    ClearButtons() -- Usuwamy stare przyciski

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then -- Pomijamy siebie
            local button = TPTab:CreateButton({
                Name = player.Name,
                Callback = function()
                    if player.Character and player.Character.PrimaryPart and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                        LocalPlayer.Character:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
                    else
                        Rayfield:Notify({
                            Title = "Błąd Teleportacji",
                            Content = "Nie można przeteleportować. Gracz nie ma postaci!",
                            Duration = 3
                        })
                    end
                end,
            })
            table.insert(buttons, button) -- Zapisujemy przycisk do późniejszego usunięcia
        end
    end
end

-- Aktualizacja listy natychmiast po uruchomieniu
task.spawn(UpdatePlayerList)

-- Odświeżanie listy, gdy ktoś dołączy lub wyjdzie
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)




local SCTab = Window:CreateTab("🎲 Skrypty", nil) -- Title, Image

local Button4 = SCTab:CreateButton({
   Name = "Admin",
   Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
   end,
})

local Button6 = SCTab:CreateButton({
   Name = "SimpleSpy",
   Callback = function()
        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
   end,
})

local Button5 = SCTab:CreateButton({
   Name = "DeX",
   Callback = function()
	if game:GetService'CoreGui':FindFirstChild'Dex' then
		game:GetService'CoreGui'.Dex:Destroy();
	end

	math.randomseed(tick())

	local charset = {}
	for i = 48,  57 do table.insert(charset, string.char(i)) end
	for i = 65,  90 do table.insert(charset, string.char(i)) end
	for i = 97, 122 do table.insert(charset, string.char(i)) end
	function RandomCharacters(length)
	if length > 0 then
		return RandomCharacters(length - 1) .. charset[math.random(1, #charset)]
	else
		return ""
	end
	end

	local Dex = game:GetObjects("rbxassetid://3567096419")[1]
	Dex.Name = RandomCharacters(math.random(5, 20))
	Dex.Parent = game:GetService("CoreGui")
		
	local function Load(Obj, Url)
	local function GiveOwnGlobals(Func, Script)
		local Fenv = {}
		local RealFenv = {script = Script}
		local FenvMt = {}
		FenvMt.__index = function(a,b)
			if RealFenv[b] == nil then
				return getfenv()[b]
			else
				return RealFenv[b]
			end
		end
		FenvMt.__newindex = function(a, b, c)
			if RealFenv[b] == nil then
				getfenv()[b] = c
			else
				RealFenv[b] = c
			end
		end
		setmetatable(Fenv, FenvMt)
		setfenv(Func, Fenv)
		return Func
	end

	local function LoadScripts(Script)
		if Script.ClassName == "Script" or Script.ClassName == "LocalScript" then
			spawn(function()
				GiveOwnGlobals(loadstring(Script.Source, "=" .. Script:GetFullName()), Script)()
			end)
		end
		for i,v in pairs(Script:GetChildren()) do
			LoadScripts(v)
		end
	end

	LoadScripts(Obj)
	end

	Load(Dex)
   end,
})
