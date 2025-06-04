--[[
    description: pong time... hope to add 3 modes like in the original: telstar tennis, handball, hockey
]]

-- get window width & height
-- i think it's like 800 x 600
WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()


function love.load()
    -- wall stuff
    wallHeight = 10

    -- paddle stuff
    paddleX = 20
    paddleY = 5
    paddleHeight = 70
    paddleSpeed = 300

    -- ball stuff
    ballX = 300
    ballY = 400
    ballDir = 1
    ballSpeed = 300

end


function love.update(dt)
    -- paddle movements
    if love.keyboard.isDown("down") then
        paddleY = paddleY + paddleSpeed * dt
    elseif love.keyboard.isDown("up") then
        paddleY = paddleY - paddleSpeed * dt
    end

    -- paddle constraints/limits
    if paddleY <= wallHeight then
        paddleY = wallHeight
    elseif paddleY >= (WINDOWHEIGHT - wallHeight) - paddleHeight then
        paddleY = (WINDOWHEIGHT - wallHeight) - paddleHeight
    end

    -- ball movements
    ballY = ballY + ballSpeed * ballDir * dt

    if ballY >= (WINDOWHEIGHT - wallHeight) - 10 then
        ballDir = -1
    elseif ballY <= wallHeight then
        ballDir = 1
    end
end


function love.draw()
    -- pong paddle
    love.graphics.rectangle("fill", paddleX, paddleY, 10, paddleHeight);

    -- top wall needs to be drawn
    love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, wallHeight);

    -- bottom wall needs to be drawn
    love.graphics.rectangle("fill", 0, WINDOWHEIGHT - wallHeight, WINDOWWIDTH, wallHeight);

    -- ball time
    love.graphics.rectangle("fill", ballX, ballY, 10, 10);

end