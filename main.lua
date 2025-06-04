--[[
    description: pong time
]]

function love.load()
    -- wall stuff
    wallWidth = 800
    wallHeight = 10
    bottomWallY = 590

    -- paddle stuff
    paddleX = 10
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
    elseif paddleY >= bottomWallY - paddleHeight then
        paddleY = bottomWallY - paddleHeight
    end
end


function love.draw()
    -- pong paddle
    love.graphics.rectangle("fill", paddleX, paddleY, 10, paddleHeight);

    -- top wall needs to be drawn
    love.graphics.rectangle("fill", 0, 0, wallWidth, wallHeight);

    -- bottom wall needs to be drawn
    love.graphics.rectangle("fill", 0, bottomWallY, wallWidth, wallHeight);

end