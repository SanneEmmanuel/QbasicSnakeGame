-- main.lua
-- Author: Sanne Karibo
-- Snake Game in Lua using Love2D

local width, height = 64, 48
local cellSize = 10
local maxLength = 100

local snake = {}
local dir = "right"
local food = {}
local score = 0
local gameOver = false

function love.load()
    love.window.setMode(width * cellSize, height * cellSize)
    -- Initialize snake
    for i = 5, 1, -1 do
        table.insert(snake, {x = 20 - i, y = 10})
    end
    generateFood()
end

function generateFood()
    while true do
        food.x = math.random(0, width - 1)
        food.y = math.random(0, height - 1)
        local collision = false
        for _, segment in ipairs(snake) do
            if segment.x == food.x and segment.y == food.y then
                collision = true
                break
            end
        end
        if not collision then break end
    end
end

function love.update(dt)
    if gameOver then return end

    -- Move snake every 0.15 seconds
    if not love.timer then return end
    if not love.updateTimer then love.updateTimer = 0 end
    love.updateTimer = love.updateTimer + dt
    if love.updateTimer < 0.15 then return end
    love.updateTimer = 0

    local head = snake[1]
    local newHead = {x = head.x, y = head.y}

    if dir == "right" then newHead.x = newHead.x + 1
    elseif dir == "left" then newHead.x = newHead.x - 1
    elseif dir == "up" then newHead.y = newHead.y - 1
    elseif dir == "down" then newHead.y = newHead.y + 1
    end

    -- Check collisions
    if newHead.x < 0 or newHead.x >= width or newHead.y < 0 or newHead.y >= height then
        gameOver = true
        return
    end

    for i = 1, #snake do
        if snake[i].x == newHead.x and snake[i].y == newHead.y then
            gameOver = true
            return
        end
    end

    table.insert(snake, 1, newHead)

    if newHead.x == food.x and newHead.y == food.y then
        score = score + 10
        generateFood()
        if #snake > maxLength then
            table.remove(snake)
        end
    else
        table.remove(snake)
    end
end

function love.draw()
    love.graphics.clear(0, 0, 0)

    -- Draw snake
    for i, segment in ipairs(snake) do
        if i == 1 then
            love.graphics.setColor(1, 1, 0) -- yellow head
        else
            love.graphics.setColor(0, 1, 0) -- green body
        end
        love.graphics.rectangle("fill", segment.x * cellSize, segment.y * cellSize, cellSize - 1, cellSize - 1)
    end

    -- Draw food
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", food.x * cellSize + cellSize / 2, food.y * cellSize + cellSize / 2, cellSize / 2 - 1)

    -- Draw score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)

    if gameOver then
        love.graphics.printf("Game Over! Final Score: " .. score, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if key == "right" and dir ~= "left" then dir = "right"
    elseif key == "left" and dir ~= "right" then dir = "left"
    elseif key == "up" and dir ~= "down" then dir = "up"
    elseif key == "down" and dir ~= "up" then dir = "down"
    elseif key == "escape" then love.event.quit() end
end
