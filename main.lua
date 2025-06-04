--[[
    description: making a moving rectangle
]]

function love.load()
    x = 100
end


function love.update(dt)
    x = x + 100 * dt
end


function love.draw()

    love.graphics.rectangle("line", x, 50, 200, 150);
end