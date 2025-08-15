local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Variables para protección contra reinicios
local isProtected = false
local originalCanBeDamaged = nil

-- Variables para las paredes
local safetyWall = nil
local controllableWall = nil

-- Variables para la lógica de "Wait"
local teleportCount = 0
local lastTeleportTime = tick()
local TELEPORT_LIMIT = 4 -- Límite de teletransportaciones rápidas para activar el aviso
local TELEPORT_COOLDOWN = 1 -- Tiempo en segundos para reiniciar el contador

-- Variables para la nueva lógica del botón Tween To Base
local isTweening = false
local originalPosition = nil
local tweeningInstance = nil

-- Variable para la detección de colisiones
local lastPositionCheck = tick()
local lastPosition = Vector3.new(0,0,0)

-- Crear la GUI principal con un nombre único
local menuScreen = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
menuScreen.Name = "CustomMenuGUI"
menuScreen.ResetOnSpawn = false

-- Botón circular para abrir/cerrar el menú
local toggleButton = Instance.new("TextButton", menuScreen)
toggleButton.Name = "MenuToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleButton.BorderSizePixel = 1
toggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "" -- Sin texto
toggleButton.ZIndex = 2 -- Asegura que esté encima del menú

-- Añadir esquinas redondeadas para el botón
local buttonCorner = Instance.new("UICorner", toggleButton)
buttonCorner.CornerRadius = UDim.new(0.5, 0)

-- Añadir una relación de aspecto para mantenerlo como un círculo perfecto
local buttonAspectRatio = Instance.new("UIAspectRatioConstraint", toggleButton)
buttonAspectRatio.AspectRatio = 1

-- Añadir la imagen del logo
-- IMPORTANTE: Reemplaza "rbxassetid://ID_DE_TU_IMAGEN_AQUI" con el ID de activo de la imagen después de subirla a Roblox.
local logoImage = Instance.new("ImageLabel", toggleButton)
logoImage.Size = UDim2.new(1, 0, 1, 0)
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://ID_DE_TU_IMAGEN_AQUI" -- Reemplaza este valor

-- Frame principal con bordes redondeados y tamaño más pequeño
local mainPanel = Instance.new("Frame", menuScreen)
mainPanel.Size = UDim2.new(0, 300, 0, 200)
mainPanel.Position = UDim2.new(0.5, -150, 0.5, -100) -- Centrado en la pantalla
mainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainPanel.BorderSizePixel = 0
mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
mainPanel.Name = "MainPanel"
mainPanel.Visible = false -- El menú está cerrado por defecto

-- Añadir esquinas redondeadas al frame principal
local panelCorner = Instance.new("UICorner", mainPanel)
panelCorner.CornerRadius = UDim.new(0, 8)

-- Contenedor de botones de pestaña y arrastre
local tabButtonContainer = Instance.new("Frame", mainPanel)
tabButtonContainer.Size = UDim2.new(1, 0, 0, 40)
tabButtonContainer.Position = UDim2.new(0, 0, 0, 0)
tabButtonContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Color ligeramente diferente para destacar
tabButtonContainer.BorderSizePixel = 1
tabButtonContainer.BorderColor3 = Color3.fromRGB(255, 255, 255) -- Borde blanco para indicar arrastre
tabButtonContainer.Name = "TabButtonContainer"

-- Contenedor principal del contenido
local contentContainer = Instance.new("Frame", mainPanel)
contentContainer.Size = UDim2.new(1, 0, 1, -40)
contentContainer.Position = UDim2.new(0, 0, 0, 40)
contentContainer.BackgroundTransparency = 1
contentContainer.Name = "ContentContainer"

-- Crear la pestaña de contenido "Main"
local mainTabContent = Instance.new("Frame", contentContainer)
mainTabContent.Size = UDim2.new(1, 0, 1, 0)
mainTabContent.BackgroundTransparency = 1
mainTabContent.Visible = true
mainTabContent.Name = "Main"

-- Crear la pestaña de contenido "Visual"
local visualTabContent = Instance.new("Frame", contentContainer)
visualTabContent.Size = UDim2.new(1, 0, 1, 0)
visualTabContent.BackgroundTransparency = 1
visualTabContent.Visible = false
visualTabContent.Name = "Visual"

-- Layouts para organizar los elementos de las pestañas
local mainLayout = Instance.new("UIListLayout", mainTabContent)
mainLayout.Padding = UDim.new(0, 5)
mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainLayout.VerticalAlignment = Enum.VerticalAlignment.Top
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder

local visualLayout = Instance.new("UIListLayout", visualTabContent)
visualLayout.Padding = UDim.new(0, 5)
visualLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
visualLayout.VerticalAlignment = Enum.VerticalAlignment.Top
visualLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Crear los botones de pestaña
local buttonLayout = Instance.new("UIListLayout", tabButtonContainer)
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonLayout.Padding = UDim.new(0, 5)

local mainButton = Instance.new("TextButton", tabButtonContainer)
mainButton.Size = UDim2.new(0, 100, 0, 30)
mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.Font = Enum.Font.SourceSans
mainButton.TextSize = 16
mainButton.Text = "Main"
mainButton.Name = "Main"
local mainButtonCorner = Instance.new("UICorner", mainButton)
mainButtonCorner.CornerRadius = UDim.new(0, 5)

local visualButton = Instance.new("TextButton", tabButtonContainer)
visualButton.Size = UDim2.new(0, 100, 0, 30)
visualButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
visualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
visualButton.Font = Enum.Font.SourceSans
visualButton.TextSize = 16
visualButton.Text = "Visual"
visualButton.Name = "Visual"
local visualButtonCorner = Instance.new("UICorner", visualButton)
visualButtonCorner.CornerRadius = UDim.new(0, 5)

-- Lógica de las pestañas
local function switchTab(tabName)
    if tabName == "Main" then
        mainTabContent.Visible = true
        visualTabContent.Visible = false
        mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        visualButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    elseif tabName == "Visual" then
        mainTabContent.Visible = false
        visualTabContent.Visible = true
        mainButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        visualButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end
end
mainButton.MouseButton1Click:Connect(function() switchTab("Main") end)
visualButton.MouseButton1Click:Connect(function() switchTab("Visual") end)

-- Lógica para mostrar/ocultar el menú
local isMenuOpen = false
toggleButton.MouseButton1Click:Connect(function()
    isMenuOpen = not isMenuOpen
    mainPanel.Visible = isMenuOpen
end)


-- Lógica de arrastre para el menú principal (restaurada)
local isDraggable = false
local dragStartPoint
local initialPos

tabButtonContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggable = true
        dragStartPoint = input.Position
        initialPos = mainPanel.Position
    end
end)

tabButtonContainer.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggable = false
    end
end)

UserInput.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if isDraggable then
            local delta = input.Position - dragStartPoint
            mainPanel.Position = UDim2.new(initialPos.X.Scale, initialPos.X.Offset + delta.X, initialPos.Y.Scale, initialPos.Y.Offset + delta.Y)
        end
    end
end)

-- Funciones del script anterior
local function showNotification(message)
    local notificationGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Parent = notificationGui
    notificationFrame.Size = UDim2.new(0.3, 0, 0.05, 0)
    notificationFrame.Position = UDim2.new(0.5, -150, 1, 20)
    notificationFrame.AnchorPoint = Vector2.new(0.5, 1)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notificationFrame.BorderSizePixel = 0

    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 8)
    notificationCorner.Parent = notificationFrame

    local notificationLabel = Instance.new("TextLabel")
    notificationLabel.Parent = notificationFrame
    notificationLabel.Size = UDim2.new(1, 0, 1, 0)
    notificationLabel.BackgroundTransparency = 1
    notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationLabel.Font = Enum.Font.SourceSans
    notificationLabel.TextSize = 14
    notificationLabel.Text = message

    local enterTween = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 1, -10)})
    enterTween:Play()
    task.wait(3)
    local exitTween = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 1, 20)})
    exitTween:Play()

    exitTween.Completed:Wait()
    notificationGui:Destroy()
end

local function protectPlayer()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        originalCanBeDamaged = humanoid.BreakJointsOnDeath
        humanoid.BreakJointsOnDeath = false
        isProtected = true
    end
end

local function restorePlayerProtection()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid and isProtected then
        humanoid.BreakJointsOnDeath = originalCanBeDamaged
        isProtected = false
    end
end

-- =======================================================
-- ========== Contenido en la pestaña Main ==========
-- =======================================================

-- Función para crear un interruptor (switch)
local function createSwitch(parentFrame, labelText)
    local switchFrame = Instance.new("Frame", parentFrame)
    switchFrame.Size = UDim2.new(0.9, 0, 0, 30)
    switchFrame.BackgroundTransparency = 1

    local switchLabel = Instance.new("TextLabel", switchFrame)
    switchLabel.Size = UDim2.new(0.8, 0, 1, 0)
    switchLabel.BackgroundTransparency = 1
    switchLabel.Text = labelText
    switchLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    switchLabel.Font = Enum.Font.SourceSans
    switchLabel.TextSize = 14
    switchLabel.TextXAlignment = Enum.TextXAlignment.Left

    local switchToggle = Instance.new("TextButton", switchFrame)
    switchToggle.Size = UDim2.new(0, 40, 0, 20)
    switchToggle.Position = UDim2.new(1, -40, 0.5, -10)
    switchToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    switchToggle.BorderSizePixel = 0
    local toggleCorner = Instance.new("UICorner", switchToggle)
    toggleCorner.CornerRadius = UDim.new(0.5, 0)

    local toggleCircle = Instance.new("Frame", switchToggle)
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    toggleCircle.BorderSizePixel = 0
    local circleCorner = Instance.new("UICorner", toggleCircle)
    circleCorner.CornerRadius = UDim.new(0.5, 0)

    local isActivated = false
    switchToggle.MouseButton1Click:Connect(function()
        isActivated = not isActivated
        if isActivated then
            toggleCircle:TweenPosition(UDim2.new(1, -18, 0.5, -8), "Out", "Sine", 0.2, true)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            toggleCircle:TweenPosition(UDim2.new(0, 2, 0.5, -8), "Out", "Sine", 0.2, true)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
    return switchFrame, isActivated, switchToggle
end

-- Botón Tween To Base
local tweenBaseBtn = Instance.new("TextButton", mainTabContent)
tweenBaseBtn.Size = UDim2.new(0.8, 0, 0, 30)
tweenBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
tweenBaseBtn.TextColor3 = Color3.fromRGB(255,255,255)
tweenBaseBtn.Font = Enum.Font.SourceSans
tweenBaseBtn.TextSize = 14
tweenBaseBtn.Text = "Tween To Base"
local tweenBtnCorner = Instance.new("UICorner", tweenBaseBtn)
tweenBtnCorner.CornerRadius = UDim.new(0, 5)

-- Lógica de las paredes (integrada aquí)
-- **Código de la pared de seguridad (se ejecuta una sola vez al cargar el personaje)**
local function createSafetyWall()
    local character = player.Character
    if character and not safetyWall then
        local rootPart = character:WaitForChild("HumanoidRootPart")
        safetyWall = Instance.new("Part")
        safetyWall.Name = "SafetyWall"
        safetyWall.Size = Vector3.new(1000, 1, 1000)
        safetyWall.Anchored = true
        safetyWall.CanCollide = true
        safetyWall.Transparency = 0.5
        safetyWall.Color = Color3.fromRGB(255, 0, 0)

        -- Posicionar la pared de seguridad 50 studs por encima del jugador
        safetyWall.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 50, 0))
        safetyWall.Parent = workspace
    end
end
player.CharacterAdded:Connect(createSafetyWall)
if player.Character then
    createSafetyWall()
end

-- Botón de toggle "Pared Controllable"
local toggleControllableWallButton = Instance.new("TextButton", mainTabContent)
toggleControllableWallButton.Size = UDim2.new(0.9, 0, 0, 30)
toggleControllableWallButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleControllableWallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleControllableWallButton.Font = Enum.Font.SourceSans
toggleControllableWallButton.TextSize = 14
toggleControllableWallButton.Text = "Toggle Pared Controllable"
toggleControllableWallButton.BorderSizePixel = 0
local toggleControllableWallCorner = Instance.new("UICorner", toggleControllableWallButton)
toggleControllableWallCorner.CornerRadius = UDim.new(0, 5)

-- Botón "Up"
local upButton = Instance.new("TextButton", mainTabContent)
upButton.Size = UDim2.new(0.9, 0, 0, 30)
upButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Font = Enum.Font.SourceSans
upButton.TextSize = 14
upButton.Text = "Up"
upButton.BorderSizePixel = 0
upButton.Visible = false
local upCorner = Instance.new("UICorner", upButton)
upCorner.CornerRadius = UDim.new(0, 5)

-- Botón "Down"
local downButton = Instance.new("TextButton", mainTabContent)
downButton.Size = UDim2.new(0.9, 0, 0, 30)
downButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Font = Enum.Font.SourceSans
downButton.TextSize = 14
downButton.Text = "Down"
downButton.BorderSizePixel = 0
downButton.Visible = false
local downCorner = Instance.new("UICorner", downButton)
downCorner.CornerRadius = UDim.new(0, 5)

-- Lógica del toggle de la pared controlable (suelo)
local isControllableWallActive = false
toggleControllableWallButton.MouseButton1Click:Connect(function()
    isControllableWallActive = not isControllableWallActive
    if isControllableWallActive then
        toggleControllableWallButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        
        if not controllableWall and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            
            controllableWall = Instance.new("Part")
            controllableWall.Name = "ControllableWall"
            controllableWall.Size = Vector3.new(1000, 1, 1000)
            controllableWall.Anchored = true
            controllableWall.CanCollide = true
            controllableWall.Transparency = 0.5
            controllableWall.Color = Color3.fromRGB(0, 255, 0)

            local wallPosition = rootPart.Position - Vector3.new(0, 2, 0)
            controllableWall.CFrame = CFrame.new(wallPosition)
            controllableWall.Parent = workspace
            
            upButton.Visible = true
            downButton.Visible = true
        end
    else
        toggleControllableWallButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        if controllableWall then
            controllableWall:Destroy()
            controllableWall = nil
            
            upButton.Visible = false
            downButton.Visible = false
        end
    end
end)

-- Lógica para el botón "Up" (solo afecta a la pared controlable)
upButton.MouseButton1Click:Connect(function()
    if controllableWall and safetyWall then
        if (safetyWall.Position.Y - controllableWall.Position.Y) > 4.1 then
            controllableWall.CFrame = controllableWall.CFrame * CFrame.new(0, 0.5, 0)
            upButton.Text = "Up"
        else
            upButton.Text = "Max"
        end
    end
end)

-- Lógica para el botón "Down" (solo afecta a la pared controlable)
downButton.MouseButton1Click:Connect(function()
    if controllableWall then
        controllableWall.CFrame = controllableWall.CFrame * CFrame.new(0, -0.5, 0)
        upButton.Text = "Up"
    end
end)

local function handleTweenButton()
    if isTweening then
        -- Detener el tween y mostrar notificación
        isTweening = false
        if tweeningInstance then
            tweeningInstance:Cancel()
        end
        showNotification("Operation stopped✅️")
        
        tweenBaseBtn.Text = "Tween To Base"
        tweenBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        restorePlayerProtection()
    else
        -- Iniciar el tween
        local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return
        end
        
        isTweening = true
        tweenBaseBtn.Text = "Stop"
        tweenBaseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        
        task.spawn(function()
            local currentTime = tick()
            if currentTime - lastTeleportTime < TELEPORT_COOLDOWN then
                teleportCount = teleportCount + 1
                if teleportCount >= TELEPORT_LIMIT then
                    showNotification("Wait: El sistema ha detectado muchos intentos de movimiento. Por favor, espere antes de intentarlo de nuevo.")
                    task.wait(5)
                    teleportCount = 0
                    isTweening = false
                    tweenBaseBtn.Text = "Tween To Base"
                    tweenBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    return
                end
            else
                teleportCount = 1
            end
            lastTeleportTime = currentTime
            
            local myBase = nil
            for _, item in pairs(workspace:WaitForChild("Plots"):GetChildren()) do
                local userBase = item:FindFirstChild("YourBase", true)
                if userBase and userBase.Enabled and item:FindFirstChild("DeliveryHitbox", true) then
                    myBase = item:FindFirstChild("DeliveryHitbox", true)
                    break
                end
            end

            if not myBase then
                showNotification("No se encontró la base o el personaje.")
                isTweening = false
                tweenBaseBtn.Text = "Tween To Base"
                tweenBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                return
            end
            
            local rootPart = player.Character.HumanoidRootPart
            local playerHumanoid = player.Character:FindFirstChild("Humanoid")
            
            if not playerHumanoid then 
                isTweening = false
                tweenBaseBtn.Text = "Tween To Base"
                tweenBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                return 
            end

            local endPosition = Vector2.new(myBase.Position.X, myBase.Position.Z)
            
            protectPlayer()

            -- Lógica para detectar si el jugador está atascado
            local stuckCount = 0
            
            while (Vector2.new(rootPart.Position.X, rootPart.Position.Z) - endPosition).Magnitude > 5 and isTweening do
                
                -- Detectar si el jugador está atascado
                if (rootPart.Position - lastPosition).Magnitude < 0.1 then
                    stuckCount = stuckCount + 1
                else
                    stuckCount = 0
                end
                lastPosition = rootPart.Position
                
                if stuckCount >= 20 then -- 20 intentos de 0.1 segundos son 2 segundos
                    showNotification("You must be off base")
                    isTweening = false
                    tweenBaseBtn.Text = "Tween To Base"
                    tweenBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    restorePlayerProtection()
                    return
                end
                
                -- Ajuste de velocidad (movimiento más lento)
                local segmentDistance = math.random(1.5, 2.5) 
                local tweenTime = math.random(0.04, 0.08)
                local currentPos = rootPart.Position
                
                local direction = (endPosition - Vector2.new(currentPos.X, currentPos.Z)).Unit
                local targetPosition = Vector3.new(currentPos.X, currentPos.Y, currentPos.Z) + Vector3.new(direction.X, 0, direction.Y) * segmentDistance
                local antiCheatOffset = -Vector3.new(direction.X, 0, direction.Y) * 0.1
                
                tweeningInstance = TweenService:Create(rootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad), {CFrame = CFrame.new(targetPosition + antiCheatOffset)})
                
                tweeningInstance:Play()
                tweeningInstance.Completed:Wait()
                
                task.wait(0.1)
            end
            
            if isTweening then
                local finalTween = TweenService:Create(rootPart, TweenInfo.new(0.04, Enum.EasingStyle.Quad), {CFrame = CFrame.new(Vector3.new(myBase.Position.X, rootPart.Position.Y, myBase.Position.Z) + Vector3.new(0, 0.1, 0))})
                finalTween:Play()
                finalTween.Completed:Wait()

                restorePlayerProtection()
                showNotification("You have arrived successfully✅️")
            end
            
            isTweening = false
            tweenBaseBtn.Text = "Tween To Base"
            tweenBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            
        end)
    end
end

tweenBaseBtn.MouseButton1Click:Connect(handleTweenButton)

-- =======================================================
-- ========== Contenido en la pestaña Visual ==========
-- =======================================================

-- Funcionalidad ESP
local espActive = false
local espToggleBtn = nil
local visualSwitchFrame = nil

-- Crear el switch para el ESP
visualSwitchFrame, _, espToggleBtn = createSwitch(visualTabContent, "Toggle ESP")

local espObjects = {}

local function createESPForPlayer(targetPlayer)
    if not espActive or targetPlayer == player or espObjects[targetPlayer] then
        return
    end

    local character = targetPlayer.Character
    if not character then return end
    
    local head = character:WaitForChild("Head", 5)
    if not head then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local nameTag = Instance.new("BillboardGui")
    nameTag.Parent = head
    nameTag.Name = "ESP_NameTag"
    nameTag.AlwaysOnTop = true
    nameTag.Size = UDim2.new(0, 200, 0, 50)
    nameTag.StudsOffset = Vector3.new(0, 2, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = nameTag
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.Text = targetPlayer.Name
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    
    espObjects[targetPlayer] = {
        Highlight = highlight,
        NameTag = nameTag
    }
end

local function removeESPForPlayer(targetPlayer)
    if espObjects[targetPlayer] then
        if espObjects[targetPlayer].Highlight and espObjects[targetPlayer].Highlight.Parent then
            espObjects[targetPlayer].Highlight:Destroy()
        end
        if espObjects[targetPlayer].NameTag and espObjects[targetPlayer].NameTag.Parent then
            espObjects[targetPlayer].NameTag:Destroy()
        end
        espObjects[targetPlayer] = nil
    end
end

-- Lógica para el toggle del ESP
espToggleBtn.MouseButton1Click:Connect(function()
    espActive = not espActive

    if espActive then
        for _, v in pairs(Players:GetPlayers()) do
            createESPForPlayer(v)
        end
    else
        for _, v in pairs(Players:GetPlayers()) do
            removeESPForPlayer(v)
        end
    end
end)

-- Conexiones de eventos para jugadores que entran/salen
Players.PlayerAdded:Connect(function(v)
    if espActive then
        v.CharacterAdded:Connect(function(char)
            createESPForPlayer(v)
        end)
    end
end)

Players.PlayerRemoving:Connect(removeESPForPlayer)

player.NameDisplayDistance = 0
