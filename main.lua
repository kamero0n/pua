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

function dashLine(x1, y1, x2, y2)
    -- distance formula first!
    local dx, dy = x2 - x1, y2 - y1
    local dist = math.sqrt((dx * dx) + (dy * dy))

    -- these are the steps... for now, distX is just 0 since this is a purely vertical line
    local distX = math.abs(dx) / dist
    local distY = math.abs(dy) / dist

    local currX = x1
    local currY = y1
    local gap = 10
    for i = 0, dist do
        currY = currY * distY + gap --currY * distY + gap 
        local nextX = currX + distX
        local nextY = currY + distY -- if i want to make the lines slightly longer, i can just add a const like 10 * distY... however note, it should not exceed the size of gap
        love.graphics.line(currX, currY, nextX, nextY)
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

    -- trying out dashed line
    dashLine(WINDOWWIDTH / 2, 0, WINDOWWIDTH / 2, WINDOWHEIGHT);
   -- love.graphics.line(WINDOWWIDTH / 2, 0, WINDOWWIDTH / 2, WINDOWHEIGHT);

    
end