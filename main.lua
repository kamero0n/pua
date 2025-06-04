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
    ballSize = 10
    ballYDir = 1
    ballXDir = 1
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
    ballX = ballX + ballSpeed * ballXDir * dt
    ballY = ballY + ballSpeed * ballYDir * dt

    -- y pos ball wall constraints
    if ballY >= (WINDOWHEIGHT - wallHeight) - ballSize then
        ballYDir = -1
    elseif ballY <= wallHeight then
        ballYDir = 1
    end

    -- x pos ball wall constraints
    if ballX >= (WINDOWWIDTH - 30) - ballSize then
        ballXDir = -1
    end
end


function love.draw()
    -- pong paddle
    love.graphics.rectangle("fill", paddleX, paddleY, 10, paddleHeight);

    -- top wall needs to be drawn
    love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, wallHeight);

    -- bottom wall needs to be drawn
    love.graphics.rectangle("fill", 0, WINDOWHEIGHT - wallHeight, WINDOWWIDTH, wallHeight);

    -- wall to the right will be drawn -- in the future this will be the "handball" mode
    love.graphics.rectangle("fill", WINDOWWIDTH - 30, 0, wallHeight, WINDOWHEIGHT);

    -- ball time
    love.graphics.rectangle("fill", ballX, ballY, ballSize, ballSize);

end