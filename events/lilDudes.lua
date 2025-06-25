LilDudes = {}

local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

local lilGuy = {
    x = WINDOWWIDTH / 2 + 60,
    y = WINDOWHEIGHT - 45,
    width = 20,
    height = 20,
    time = 0,
    walkSpeed = 4, -- frequency
    legSwing = 2, -- X amplitude
    stepHeight = 2, -- Y amplitude
    bobHeight = 2,
    direction = 1, -- going right
    animSpeed = 40 -- pixels/sec
}


function LilDudes.drawDude()
    -- set the canvas color to white
    love.graphics.setColor(1, 1, 1, 1)

    -- draw a small rectangle (this is the body)
    local bodyBob = lilGuy.bobHeight * math.cos(lilGuy.time * lilGuy.walkSpeed * 2)
    love.graphics.rectangle("fill", lilGuy.x, lilGuy.y + bodyBob, lilGuy.width, lilGuy.height)

    -- draw legs? left leg!
    local leftLegXOffset = lilGuy.legSwing * math.sin(lilGuy.time * lilGuy.walkSpeed)
    local leftLegYOffset = lilGuy.stepHeight * math.abs(math.sin((lilGuy.time * lilGuy.walkSpeed)))
    love.graphics.rectangle("fill", lilGuy.x + 3 + leftLegXOffset, lilGuy.y + lilGuy.height + leftLegYOffset, 5, 15)

    -- right leg!
    local rightLegXOffset = lilGuy.legSwing * math.sin(lilGuy.time * lilGuy.walkSpeed + math.pi)
    local rightLegYOffset = lilGuy.stepHeight * math.abs(math.sin((lilGuy.time * lilGuy.walkSpeed + math.pi)))
    love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 8 + rightLegXOffset, lilGuy.y + lilGuy.height + rightLegYOffset, 5, 15)

    -- set the canvas color to black
    love.graphics.setColor(0, 0, 0, 1)

    -- draw eyes (add body bob here so the eyes move w/ the head)
    if lilGuy.direction == 1 then
        love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 5, lilGuy.y + 10 + bodyBob, 3, 5)
        love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 10, lilGuy.y + 10 + bodyBob, 3, 5)
    else
        love.graphics.rectangle("fill", lilGuy.x + 2, lilGuy.y + 10 + bodyBob, 3, 5)
        love.graphics.rectangle("fill", lilGuy.x + 8, lilGuy.y + 10 + bodyBob, 3, 5)
    end
end

function LilDudes.updateTime(time)
    lilGuy.time = lilGuy.time + time

    lilGuy.x = lilGuy.x + (lilGuy.animSpeed * time) * lilGuy.direction

    if lilGuy.x > WINDOWWIDTH - 30 - lilGuy.width then
        lilGuy.direction = lilGuy.direction * (-1)
    end
end