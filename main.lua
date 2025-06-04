--[[
    description: pong time... hope to add 3 modes like in the original: telstar tennis, handball, hockey
]]

-- get window width & height
WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()


function love.load()
    -- wall stuff
    wallHeight = 10
   -- bottomWallY = 590

    -- paddle stuff
    paddleX = 20
    paddleY = 5
    paddleHeight = 70
    paddleSpeed = 300

end


function love.update(dt)
    if love.keyboard.isDown("down") then
        paddleY = paddleY + paddleSpeed * dt
    elseif love.keyboard.isDown("up") then
        paddleY = paddleY - paddleSpeed * dt
    end

    if paddleY <= wallHeight then
        paddleY = wallHeight
    elseif paddleY >= (WINDOWHEIGHT - wallHeight) - paddleHeight then
        paddleY = (WINDOWHEIGHT - wallHeight) - paddleHeight
    end
end


function love.draw()
    -- pong paddle
    love.graphics.rectangle("fill", paddleX, paddleY, 10, paddleHeight);

    -- top wall needs to be drawn
    love.graphics.rectangle("line", 0, 0, WINDOWWIDTH, wallHeight);

    -- bottom wall needs to be drawn
    love.graphics.rectangle("line", 0, WINDOWHEIGHT - wallHeight, WINDOWWIDTH, wallHeight);

end