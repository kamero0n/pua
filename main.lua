--[[
    description: pong time
]]

function love.load()
    -- wall stuff
    wallWidth = 800
    wallHeight = 10

    -- paddle stuff
    paddleX = 10
    paddleY = 5
    paddleSpeed = 300


end


function love.update(dt)
    if love.keyboard.isDown("down") then
        paddleY = paddleY + paddleSpeed * dt
    elseif love.keyboard.isDown("up") then
        paddleY = paddleY - paddleSpeed * dt
    end
end


function love.draw()
    -- pong paddle
    love.graphics.rectangle("fill", paddleX, paddleY, 10, 70);

    -- top wall needs to be drawn
    love.graphics.rectangle("line", 0, 0, wallWidth, wallHeight);

    -- bottom wall needs to be drawn
    love.graphics.rectangle("line", 0, 590, wallWidth, wallHeight);

end