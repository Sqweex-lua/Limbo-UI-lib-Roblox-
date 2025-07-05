-- custom_ui.lua

local UI = {}
UI.__index = UI

local UserInputService = game:GetService("UserInputService")

local function create(inst, props)
    local obj = Instance.new(inst)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

function UI:CreateWindow(title)
    local gui = create("ScreenGui", {
        Name = "CustomUI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })

    local window = create("Frame", {
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(255, 200, 220),
        BorderSizePixel = 0,
        Parent = gui,
        Name = "MainWindow"
    })

    local stroke = Instance.new("UIStroke", window)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(255, 0, 255)

    task.spawn(function()
        local t = 0
        while window and window.Parent do
            stroke.Color = Color3.fromHSV(t, 1, 1)
            t = (t + 0.01) % 1
            task.wait(0.03)
        end
    end)

    local titleBar = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = title or "UI Library",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 24,
        Parent = window
    })

    local dragging, offset
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = input.Position - window.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            window.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
        end
    end)

    local toggleBtn = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 2),
        Text = "-",
        Font = Enum.Font.SourceSansBold,
        TextColor3 = Color3.new(1, 1, 1),
        BackgroundColor3 = Color3.fromRGB(200, 120, 160),
        Parent = window
    })

    local isMinimized = false
    local contentFrames = {}

    toggleBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        for _, obj in pairs(contentFrames) do
            obj.Visible = not isMinimized
        end
        toggleBtn.Text = isMinimized and "+" or "-"
        window.Size = isMinimized and UDim2.new(0, 400, 0, 40) or UDim2.new(0, 400, 0, 300)
    end)

    local resizer = create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0,
        Parent = window
    })

    local resizing
    resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
        end
    end)
    resizer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newSize = Vector2.new(
                input.Position.X - window.Position.X,
                input.Position.Y - window.Position.Y
            )
            window.Size = UDim2.new(0, math.clamp(newSize.X, 200, 800), 0, math.clamp(newSize.Y, 100, 600))
        end
    end)

    window.ContentList = contentFrames
    return window
end

function UI:AddCheckbox(parent, label, default, callback)
    local checkbox = create("TextButton", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, #parent.ContentList * 35 + 35),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSans,
        TextSize = 18,
        Text = (default and "[✔] " or "[ ] ") .. label,
        Parent = parent
    })

    local state = default or false
    checkbox.MouseButton1Click:Connect(function()
        state = not state
        checkbox.Text = (state and "[✔] " or "[ ] ") .. label
        if callback then callback(state) end
    end)

    table.insert(parent.ContentList, checkbox)
    return checkbox
end

function UI:AddSlider(parent, label, min, max, default, callback)
    local frame = create("Frame", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, #parent.ContentList * 45 + 35),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local value = default or min
    local labelText = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = label .. ": " .. value,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSans,
        TextSize = 18,
        Parent = frame
    })

    local bar = create("Frame", {
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        BorderSizePixel = 0,
        Parent = frame
    })

    local fill = create("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        BorderSizePixel = 0,
        Parent = bar
    })

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local relative = inp.Position.X - bar.AbsolutePosition.X
                    local percent = math.clamp(relative / bar.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + percent * (max - min) + 0.5)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    labelText.Text = label .. ": " .. value
                    if callback then callback(value) end
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    conn:Disconnect()
                end
            end)
        end
    end)

    table.insert(parent.ContentList, frame)
    return frame
end

return UI
