LilDudes = {}

local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

local lilGuy = {
    x = WINDOWWIDTH / 2 + 10,
    y = WINDOWHEIGHT - 45,
    width = 20,
    height = 20
}


function LilDudes.drawDude()
    -- set the canvas color to white
    love.graphics.setColor(1, 1, 1, 1)

    -- draw a small rectangle (this is the body)
    love.graphics.rectangle("fill", lilGuy.x, lilGuy.y, lilGuy.width, lilGuy.height)

    -- draw legs? left leg!
    love.graphics.rectangle("fill", lilGuy.x + 3, lilGuy.y + lilGuy.height, 5, 15)

    -- right leg!
    love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 8, lilGuy.y + lilGuy.height, 5, 15)

    -- set the canvas color to black
    love.graphics.setColor(0, 0, 0, 1)

    -- draw eyes
    love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 5, lilGuy.y + 10, 3, 5)
    love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 10, lilGuy.y + 10, 3, 5)
end