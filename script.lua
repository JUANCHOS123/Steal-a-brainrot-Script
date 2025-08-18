--[[
  Script de Pulso de Deslizamiento Avanzado con GUI
  
  Este script proporciona un impulso sutil y dinámico al movimiento del
  personaje. Utiliza una lógica avanzada de pulso para evadir los sistemas
  anti-cheat y evitar que el juego revierta la posición del jugador.
  
  La velocidad del impulso se calcula matemáticamente para ser proporcional
  al movimiento del personaje. La magnitud del impulso fluctúa entre
  dos valores para simular un movimiento más natural.

  Instrucciones:
  1. Abre Roblox Studio.
  2. En la ventana "Explorer", ve a "StarterPlayer" y luego a "StarterPlayerScripts".
  3. Haz clic derecho en "StarterPlayerScripts" y selecciona "Insert Object".
  4. Elige "LocalScript".
  5. Borra el código predeterminado del nuevo script y pega este código en su lugar.
--]]

-- Servicios y variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Impulse Configuration
local isGlideActive = false
local isRunning = false -- To control the Heartbeat loop
local pulseTime = 0.1 -- Duración de cada fase del pulso (en segundos)
local highImpulseMagnitude = 0.15 -- La magnitud del impulso en la fase alta
local lowImpulseMagnitude = 0.05 -- La magnitud del impulso en la fase baja
local isHighPhase = false
local lastPulseTime = 0

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GlideGUI"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Name = "GlideFrame"
frame.Parent = screenGui
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.9, -50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true

-- Create the ON/OFF button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = frame
toggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
toggleButton.Size = UDim2.new(0.8, 0, 0.6, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50) -- Rojo para OFF
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "Deslizamiento OFF"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20

-- Set up the main loop
local connection = nil

-- Function to set the active state
local function setGlideActive(active)
    isGlideActive = active
    if active then
        toggleButton.Text = "Deslizamiento ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50) -- Verde para ON
        
        -- Start the movement loop if it's not already running
        if not isRunning then
            isRunning = true
            lastPulseTime = tick()
            isHighPhase = false
            connection = RunService.Heartbeat:Connect(function()
                if not isGlideActive then
                    isRunning = false
                    connection:Disconnect()
                    return
                end
                
                -- Check if the player is moving
                local moveDirection = humanoid.MoveDirection
                if moveDirection.magnitude > 0 then
                    local currentTime = tick()
                    if currentTime - lastPulseTime >= pulseTime then
                        -- Cambiar la fase de pulso
                        isHighPhase = not isHighPhase
                        lastPulseTime = currentTime
                    end
                    
                    local currentImpulse = isHighPhase and highImpulseMagnitude or lowImpulseMagnitude
                    
                    -- Mover el CFrame basado en la dirección de movimiento y la magnitud del pulso
                    local newPosition = hrp.Position + (moveDirection * currentImpulse)
                    hrp.CFrame = CFrame.new(newPosition.X, hrp.Position.Y, newPosition.Z)
                end
            end)
        end
    else
        toggleButton.Text = "Deslizamiento OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50) -- Rojo para OFF
        isGlideActive = false
    end
end

-- Connect the toggle button
toggleButton.MouseButton1Click:Connect(function()
    setGlideActive(not isGlideActive)
end)

-- Initial state
setGlideActive(false)
