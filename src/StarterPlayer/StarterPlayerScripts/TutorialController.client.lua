-- チュートリアルコントローラー（完全版 - WASD修正）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tutorialUI = playerGui:WaitForChild("TutorialUI")
local mainFrame = tutorialUI:WaitForChild("MainFrame")
local menuUI = playerGui:WaitForChild("MenuUI")

local Events = ReplicatedStorage:WaitForChild("Events")
local StartTutorial = Events:WaitForChild("StartTutorial")
local TutorialComplete = Events:WaitForChild("TutorialComplete")
local SkipTutorial = Events:WaitForChild("SkipTutorial")

-- UI要素
local instructionPanel = mainFrame:WaitForChild("InstructionPanel")
local titleLabel = instructionPanel:WaitForChild("TitleLabel")
local descLabel = instructionPanel:WaitForChild("DescriptionLabel")
local keyFrame = instructionPanel:WaitForChild("KeyFrame")
local progressFrame = mainFrame:WaitForChild("ProgressFrame")
local progressBar = progressFrame:WaitForChild("ProgressBar")
local stepLabel = mainFrame:WaitForChild("StepLabel")
local successLabel = mainFrame:WaitForChild("SuccessLabel")
local skipBtn = mainFrame:WaitForChild("SkipButton")
local objectivePanel = mainFrame:WaitForChild("ObjectivePanel")
local completePanel = mainFrame:WaitForChild("CompletePanel")

local tutorialActive = false
local currentStep = 0
local stepCompleted = false
local keyButtons = {}

-- 移動キー（gameProcessedを無視するキー）
local movementKeys = {
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true,
    [Enum.KeyCode.Q] = true,
    [Enum.KeyCode.E] = true,
}

-- チュートリアルステップ定義
local tutorialSteps = {
    {
        title = "移動",
        description = "WASDキーで移動してみよう！\n前後左右に動いてみてください。",
        keys = {
            {key = Enum.KeyCode.W, label = "W"},
            {key = Enum.KeyCode.A, label = "A"},
            {key = Enum.KeyCode.S, label = "S"},
            {key = Enum.KeyCode.D, label = "D"},
        },
        pressedKeys = {},
        pressCount = {}
    },
    {
        title = "ジャンプ",
        description = "Spaceキーでジャンプ！\n高く飛んでみよう。",
        keys = {
            {key = Enum.KeyCode.Space, label = "Space"},
        },
        pressedKeys = {},
        pressCount = {}
    },
    {
        title = "攻撃",
        description = "Fキーで攻撃！\n2回押してみよう。",
        keys = {
            {key = Enum.KeyCode.F, label = "F", count = 2},
        },
        pressedKeys = {},
        pressCount = {}
    },
    {
        title = "ガード",
        description = "Shiftキーを長押しでガード！\n0.5秒間押し続けてみよう。",
        keys = {
            {key = Enum.KeyCode.LeftShift, label = "Shift", hold = true},
        },
        pressedKeys = {},
        pressCount = {}
    },
    {
        title = "回避",
        description = "Q/Eキーで左右に回避！\n両方試してみよう。",
        keys = {
            {key = Enum.KeyCode.Q, label = "Q"},
            {key = Enum.KeyCode.E, label = "E"},
        },
        pressedKeys = {},
        pressCount = {}
    },
    {
        title = "スキル",
        description = "Rキーでスキル発動！\n強力な特殊技を使おう。",
        keys = {
            {key = Enum.KeyCode.R, label = "R"},
        },
        pressedKeys = {},
        pressCount = {}
    }
}

local function createKeyButtons(step)
    for _, btn in pairs(keyButtons) do
        btn:Destroy()
    end
    keyButtons = {}

    for idx, keyInfo in ipairs(step.keys) do
        local btn = Instance.new("TextLabel")
        btn.Name = "Key_" .. keyInfo.label
        btn.Size = UDim2.new(0, 55, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        btn.BorderSizePixel = 0
        btn.Text = keyInfo.label
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 18
        btn.Font = Enum.Font.GothamBold
        btn.LayoutOrder = idx
        btn.Parent = keyFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn

        if keyInfo.count and keyInfo.count > 1 then
            local countLabel = Instance.new("TextLabel")
            countLabel.Name = "CountLabel"
            countLabel.Size = UDim2.new(0, 22, 0, 16)
            countLabel.Position = UDim2.new(1, -24, 0, 2)
            countLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            countLabel.Text = "0/" .. keyInfo.count
            countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            countLabel.TextSize = 10
            countLabel.Font = Enum.Font.GothamBold
            countLabel.Parent = btn

            local countCorner = Instance.new("UICorner")
            countCorner.CornerRadius = UDim.new(0, 4)
            countCorner.Parent = countLabel
        end

        keyButtons[keyInfo.key] = btn
    end
end

local function highlightKey(keyCode, completed)
    local btn = keyButtons[keyCode]
    if btn then
        if completed then
            btn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(180, 180, 80)
        end
    end
end

local function updateKeyCount(keyCode, current, max)
    local btn = keyButtons[keyCode]
    if btn then
        local countLabel = btn:FindFirstChild("CountLabel")
        if countLabel then
            countLabel.Text = current .. "/" .. max
        end
        if current >= max then
            btn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end

local function updateUI()
    local step = tutorialSteps[currentStep]
    if not step then return end

    titleLabel.Text = step.title
    descLabel.Text = step.description
    stepLabel.Text = "ステップ " .. currentStep .. "/" .. #tutorialSteps

    local progress = (currentStep - 1) / #tutorialSteps
    TweenService:Create(progressBar, TweenInfo.new(0.3), {
        Size = UDim2.new(progress, 0, 1, 0)
    }):Play()

    createKeyButtons(step)
end

local function showSuccess()
    successLabel.Visible = true
    successLabel.TextTransparency = 0

    task.delay(1, function()
        local tween = TweenService:Create(successLabel, TweenInfo.new(0.3), {
            TextTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            successLabel.Visible = false
        end)
    end)
end

local function checkStepComplete()
    local step = tutorialSteps[currentStep]
    if not step then return false end

    for _, keyInfo in ipairs(step.keys) do
        if keyInfo.count then
            local pressCount = step.pressCount[keyInfo.key] or 0
            if pressCount < keyInfo.count then return false end
        elseif keyInfo.hold then
            if not step.pressedKeys[keyInfo.key] then return false end
        else
            if not step.pressedKeys[keyInfo.key] then return false end
        end
    end
    return true
end

local function nextStep()
    currentStep = currentStep + 1
    stepCompleted = false

    if currentStep > #tutorialSteps then
        instructionPanel.Visible = false
        progressFrame.Visible = false
        stepLabel.Visible = false
        completePanel.Visible = true
        mainFrame.BackgroundTransparency = 0.5

        TweenService:Create(progressBar, TweenInfo.new(0.3), {
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
    else
        local step = tutorialSteps[currentStep]
        step.pressedKeys = {}
        step.pressCount = {}
        updateUI()
    end
end

local function onKeyPressed(keyCode)
    if not tutorialActive or stepCompleted or currentStep < 1 then return end

    local step = tutorialSteps[currentStep]
    if not step then return end

    for _, keyInfo in ipairs(step.keys) do
        if keyInfo.key == keyCode then
            if keyInfo.count then
                step.pressCount[keyCode] = (step.pressCount[keyCode] or 0) + 1
                local count = step.pressCount[keyCode]
                updateKeyCount(keyCode, count, keyInfo.count)
                print("Key pressed:", keyInfo.label, "Count:", count, "/", keyInfo.count)
                if count >= keyInfo.count then
                    step.pressedKeys[keyCode] = true
                end
            elseif not keyInfo.hold then
                if not step.pressedKeys[keyCode] then
                    step.pressedKeys[keyCode] = true
                    highlightKey(keyCode, true)
                    print("Key completed:", keyInfo.label)
                end
            end
            break
        end
    end

    if checkStepComplete() then
        stepCompleted = true
        showSuccess()
        task.delay(1.2, nextStep)
    end
end

local shiftHoldStart = 0
local function checkShiftHold()
    if not tutorialActive or currentStep ~= 4 or stepCompleted then return end

    local step = tutorialSteps[4]

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        if shiftHoldStart == 0 then
            shiftHoldStart = tick()
            highlightKey(Enum.KeyCode.LeftShift, false)
        elseif tick() - shiftHoldStart >= 0.5 then
            step.pressedKeys[Enum.KeyCode.LeftShift] = true
            highlightKey(Enum.KeyCode.LeftShift, true)
            if checkStepComplete() then
                stepCompleted = true
                showSuccess()
                task.delay(1.2, nextStep)
            end
        end
    else
        shiftHoldStart = 0
        if not step.pressedKeys[Enum.KeyCode.LeftShift] then
            local btn = keyButtons[Enum.KeyCode.LeftShift]
            if btn then btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70) end
        end
    end
end

local function startTutorialPractice()
    objectivePanel.Visible = false
    instructionPanel.Visible = true
    progressFrame.Visible = true
    stepLabel.Visible = true
    mainFrame.BackgroundTransparency = 0.85
    currentStep = 1

    for _, step in ipairs(tutorialSteps) do
        step.pressedKeys = {}
        step.pressCount = {}
    end

    updateUI()
end

local function startTutorial()
    tutorialActive = true
    menuUI.Enabled = false

    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 0.5
    objectivePanel.Visible = true
    instructionPanel.Visible = false
    progressFrame.Visible = false
    stepLabel.Visible = false
    completePanel.Visible = false
    currentStep = 0

    for _, step in ipairs(tutorialSteps) do
        step.pressedKeys = {}
        step.pressCount = {}
    end

    print("Tutorial started!")
end

local function endTutorial()
    tutorialActive = false
    mainFrame.Visible = false
    TutorialComplete:FireServer()
end

local function skipTutorialFunc()
    tutorialActive = false
    mainFrame.Visible = false
    SkipTutorial:FireServer()
end

StartTutorial.OnClientEvent:Connect(startTutorial)
objectivePanel:WaitForChild("StartButton").MouseButton1Click:Connect(startTutorialPractice)
completePanel:WaitForChild("StartBattleButton").MouseButton1Click:Connect(endTutorial)
skipBtn.MouseButton1Click:Connect(skipTutorialFunc)

-- 入力検出（WASDはgameProcessedを無視）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- 移動キーはgameProcessedを無視
    if movementKeys[input.KeyCode] then
        onKeyPressed(input.KeyCode)
        return
    end

    -- その他のキーはgameProcessedをチェック
    if not gameProcessed then
        onKeyPressed(input.KeyCode)
    end
end)

RunService.Heartbeat:Connect(checkShiftHold)

print("TutorialController READY (WASD Fixed)")
