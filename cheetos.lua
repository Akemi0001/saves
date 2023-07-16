local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()
local Window = Library:CreateWindow("AkemiCentrus", Vector2.new(492, 598), Enum.KeyCode.Insert)

local Visuals = Window:CreateTab("Visuals")
local Settings = Window:CreateTab("Settings")

local espSection = Visuals:CreateSector("ESP", "left")
local Other = Visuals:CreateSector("Other", "left")
local menuSection = Settings:CreateSector("Menu Config", "Right")
local Credits = Settings:CreateSector("Credits", "Right")

local toggleState = false -- Estado do toggle

espSection:AddToggle("Enable ESP", false, function(enabled)
    toggleState = enabled
end)

local nameState = false
local distanceState = false
local boxState = false
local filledState = false
local tracersState = false
local fullbrightState = false
local removeShadowsState = false
local localPlayer = game.Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local camera = game:GetService("Workspace").CurrentCamera
local worldToViewportPoint = CurrentCamera.worldToViewportPoint
local maxDistance = 6000 -- Distância máxima inicial para exibir o ESP (em metros)

function getDistanceFromCamera(position)
    return (position - CurrentCamera.CFrame.Position).Magnitude
end

function espFunction(player)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Color = Color3.new(1, 0, 0)
    text.Size = 15

    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.Font = 2
    distanceText.Color = Color3.new(1, 0, 0)
    distanceText.Size = 16

    local outlineBox = Drawing.new("Square")
    outlineBox.Visible = true
    outlineBox.Color = Color3.new(1, 0, 0) -- Outline vermelho
    outlineBox.Filled = false
    outlineBox.Thickness = 2
    outlineBox.Transparency = 1

    local filledBox = Drawing.new("Square")
    filledBox.Visible = true
    filledBox.Color = Color3.new(0, 0, 0) -- Preenchimento preto
    filledBox.Filled = true
    filledBox.Thickness = 1
    filledBox.Transparency = 0.4

    local tracer = Drawing.new("Line")
    tracer.Visible = true
    tracer.Color = Color3.new(1, 0, 0)
    tracer.Thickness = 2
    tracer.Outline = true

    local function updateEsp()
        if toggleState and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localPlayer and player.Character.Humanoid.Health > 0 then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local distance = getDistanceFromCamera(humanoidRootPart.Position)
            if distance <= maxDistance then
                local Vector, onScreen = camera:worldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    if nameState then
                        local head = player.Character.Head
                        local top = worldToViewportPoint(CurrentCamera, (head.CFrame * CFrame.new(0, 3, 0)).p)

                        text.Position = Vector2.new(top.X, top.Y)
                        text.Text = player.DisplayName
                        text.Visible = true
                    else
                        text.Visible = false
                    end

                    if boxState then
                        local minPosition = Vector2.new(math.huge, math.huge)
                        local maxPosition = Vector2.new(-math.huge, -math.huge)

                        local function updateMinMax(part)
                            local position = worldToViewportPoint(CurrentCamera, part.Position)
                            minPosition = Vector2.new(math.min(minPosition.X, position.X), math.min(minPosition.Y, position.Y))
                            maxPosition = Vector2.new(math.max(maxPosition.X, position.X), math.max(maxPosition.Y, position.Y))
                        end

                        for _, bodyPart in ipairs(player.Character:GetDescendants()) do
                            if bodyPart:IsA("BasePart") and bodyPart.Size.Magnitude > 0 then
                                updateMinMax(bodyPart)
                            end
                        end

                        if minPosition ~= Vector2.new(math.huge, math.huge) and maxPosition ~= Vector2.new(-math.huge, -math.huge) then
                            local head = player.Character:FindFirstChild("Head")
                            local extraHeight = head and head.Size.Y * 1.5 or 0

                            local width = maxPosition.X - minPosition.X
                            local height = maxPosition.Y - minPosition.Y + extraHeight

                            local center = (minPosition + maxPosition) / 2
                            local halfWidth = width / 2
                            local halfHeight = height / 2

                            outlineBox.Position = center - Vector2.new(halfWidth, halfHeight)
                            outlineBox.Size = Vector2.new(width, height)
                            outlineBox.Visible = true

                            filledBox.Position = center - Vector2.new(halfWidth, halfHeight)
                            filledBox.Size = Vector2.new(width, height)
                            filledBox.Visible = true
                            filledBox.Filled = filledState
                        else
                            outlineBox.Visible = false
                            filledBox.Visible = false
                        end
                    else
                        outlineBox.Visible = false
                        filledBox.Visible = false
                    end

                    if tracersState then
                        local humanoidRootPartPos, onScreen = CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                        if onScreen then
                            local bottom = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            tracer.From = bottom
                            tracer.To = Vector2.new(humanoidRootPartPos.X, humanoidRootPartPos.Y)
                            tracer.Visible = true
                        else
                            tracer.Visible = false
                        end
                    else
                        tracer.Visible = false
                    end

                    if distanceState then
                        local distanceString = string.format("%.1fm", distance)
                        distanceText.Position = text.Position + Vector2.new(0, 15)
                        distanceText.Text = distanceString
                        distanceText.Visible = true
                    else
                        distanceText.Visible = false
                    end
                else
                    text.Visible = false
                    outlineBox.Visible = false
                    filledBox.Visible = false
                    distanceText.Visible = false
                    tracer.Visible = false
                end
            else
                text.Visible = false
                outlineBox.Visible = false
                filledBox.Visible = false
                distanceText.Visible = false
                tracer.Visible = false
            end
        else
            text.Visible = false
            outlineBox.Visible = false
            filledBox.Visible = false
            distanceText.Visible = false
            tracer.Visible = false
        end
    end

    game:GetService("RunService").RenderStepped:Connect(updateEsp)
end

for _, player in ipairs(game.Players:GetPlayers()) do
    espFunction(player)
end

game.Players.PlayerAdded:Connect(function(player)
    espFunction(player)
end)

game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant:FindFirstChild("HumanoidRootPart") and descendant:FindFirstChild("Humanoid") then
        espFunction(descendant)
    end
end)

espSection:AddToggle("Name ESP", false, function(enabled)
    nameState = enabled
end)

espSection:AddToggle("Distance", false, function(enabled)
    distanceState = enabled
end)

espSection:AddToggle("Box ESP", false, function(enabled)
    boxState = enabled
end)

espSection:AddToggle("Box Filled", false, function(enabled)
    filledState = enabled
    filledBox.Filled = enabled
end)

espSection:AddToggle("Tracers", false, function(enabled)
    tracersState = enabled
end)

Other:AddToggle("Fullbright", false, function(enabled)
    fullbrightState = enabled
    if enabled then
        game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
    else
        game:GetService("Lighting").Ambient = Color3.new(0.5, 0.5, 0.5)
    end
end)

Other:AddToggle("Remove Shadows", false, function(enabled)
    removeShadowsState = enabled
    if enabled then
        game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").GlobalShadows = true
    end
end)

menuSection:AddLabel("Key to open/close: Insert")

Credits:AddLabel("Creator: kobayashiakemi")
Credits:AddLabel("Helper: fernandocorrea77")
Credits:AddLabel("Helper: futaba_1")
Credits:AddLabel("Library: bloodball")
Credits:AddLabel("Thank you for using our cheat!")

local distanceSlider = espSection:AddSlider("Distance", 0, 500, 6000, 1, function(distance)
    maxDistance = distance
end)

Settings:CreateConfigSystem("left")
