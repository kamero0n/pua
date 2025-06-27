LilDudes = {}

local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

lilGuys = {}

-- example of a lil guy
oneLilGuy = {
    x = 10,
    y = WINDOWHEIGHT - 45,
    width = 20,
    height = 20,
    time = 0,
    walkSpeed = 4, -- frequency
    legSwing = 2, -- X amplitude
    stepHeight = 2, -- Y amplitude
    bobHeight = 2,
    direction = 1, -- going right
    animSpeed = 50, -- pixels/sec
    state = "walk", -- track current state
    xmin = 0,
    xmax = WINDOWWIDTH
}

function LilDudes.drawtheONEGuy()
    -- set the canvas color to white
        love.graphics.setColor(1, 1, 1, 1)

        if oneLilGuy.state == "walk" then
            -- draw a small rectangle (this is the body)
            local bodyBob = oneLilGuy.bobHeight * math.cos(oneLilGuy.time * oneLilGuy.walkSpeed * 2)
            love.graphics.rectangle("fill", oneLilGuy.x, oneLilGuy.y + bodyBob, oneLilGuy.width, oneLilGuy.height)

            -- draw legs? left leg!
            local leftLegXOffset = oneLilGuy.legSwing * math.sin(oneLilGuy.time * oneLilGuy.walkSpeed)
            local leftLegYOffset = oneLilGuy.stepHeight * math.abs(math.sin((oneLilGuy.time * oneLilGuy.walkSpeed)))
            love.graphics.rectangle("fill", oneLilGuy.x + 3 + leftLegXOffset, oneLilGuy.y + oneLilGuy.height + leftLegYOffset, 4, 15)

            -- right leg!
            local rightLegXOffset = oneLilGuy.legSwing * math.sin(oneLilGuy.time * oneLilGuy.walkSpeed + math.pi)
            local rightLegYOffset = oneLilGuy.stepHeight * math.abs(math.sin((oneLilGuy.time * oneLilGuy.walkSpeed + math.pi)))
            love.graphics.rectangle("fill", oneLilGuy.x + oneLilGuy.width - 8 + rightLegXOffset, oneLilGuy.y + oneLilGuy.height + rightLegYOffset, 4, 15)

            -- set the canvas color to black
            love.graphics.setColor(0, 0, 0, 1)

            -- draw eyes (add body bob here so the eyes move w/ the head)
            if oneLilGuy.direction == 1 then
                love.graphics.rectangle("fill", oneLilGuy.x + oneLilGuy.width - 5, oneLilGuy.y + 10 + bodyBob, 3, 5)
                love.graphics.rectangle("fill", oneLilGuy.x + oneLilGuy.width - 10, oneLilGuy.y + 10 + bodyBob, 3, 5)
            else
                love.graphics.rectangle("fill", oneLilGuy.x + 2, oneLilGuy.y + 10 + bodyBob, 3, 5)
                love.graphics.rectangle("fill", oneLilGuy.x + 8, oneLilGuy.y + 10 + bodyBob, 3, 5)
            end
        end
end

function LilDudes.drawDude()
    for i = #lilGuys, 1, -1 do
        local lilGuy = lilGuys[i]

        -- set the canvas color to white
        love.graphics.setColor(1, 1, 1, 1)


        if lilGuy.state == "walk" then
            -- draw a small rectangle (this is the body)
            local bodyBob = lilGuy.bobHeight * math.cos(lilGuy.time * lilGuy.walkSpeed * 2)
            love.graphics.rectangle("fill", lilGuy.x, lilGuy.y + bodyBob, lilGuy.width, lilGuy.height)

            -- draw legs? left leg!
            local leftLegXOffset = lilGuy.legSwing * math.sin(lilGuy.time * lilGuy.walkSpeed)
            local leftLegYOffset = lilGuy.stepHeight * math.abs(math.sin((lilGuy.time * lilGuy.walkSpeed)))
            love.graphics.rectangle("fill", lilGuy.x + 3 + leftLegXOffset, lilGuy.y + lilGuy.height + leftLegYOffset, 4, 15)

            -- right leg!f
            local rightLegXOffset = lilGuy.legSwing * math.sin(lilGuy.time * lilGuy.walkSpeed + math.pi)
            local rightLegYOffset = lilGuy.stepHeight * math.abs(math.sin((lilGuy.time * lilGuy.walkSpeed + math.pi)))
            love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 8 + rightLegXOffset, lilGuy.y + lilGuy.height + rightLegYOffset, 4, 15)

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

        elseif lilGuy.state == "collapsed" then
            -- draw body
            love.graphics.rectangle("fill", lilGuy.x, lilGuy.y + lilGuy.height, lilGuy.width, lilGuy.height)

            -- no legs!

            -- set canvas color to black
            love.graphics.setColor(0, 0, 0, 1)
            if lilGuy.direction == 1 then
                love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 5, lilGuy.y + lilGuy.height + 10, 3, 2)
                love.graphics.rectangle("fill", lilGuy.x + lilGuy.width - 10, lilGuy.y + lilGuy.height + 10, 3, 2)
            else
                love.graphics.rectangle("fill", lilGuy.x + 2, lilGuy.y + lilGuy.height + 10, 3, 2)
                love.graphics.rectangle("fill", lilGuy.x + 8, lilGuy.y + lilGuy.height + 10, 3, 2)
            end

        end
    end
end

function LilDudes.update(time)
    for i = #lilGuys, 1, -1 do
        local lilGuy = lilGuys[i]

        lilGuy.time = lilGuy.time + time

        if lilGuy.state == "walk" then
            lilGuy.x = lilGuy.x + (lilGuy.animSpeed * time) * lilGuy.direction

        elseif lilGuy.state == "collapsed" then
            lilGuy.x = lilGuy.x 
        end

        -- hits the right wall
        if lilGuy.x > WINDOWWIDTH - 30 - lilGuy.width then
            TEsound.play(paddleGuyHit, "static")

            lilGuy.direction = lilGuy.direction * (-1)
        end

        -- hits the paddle
        if Handball.check_collision(Handball.get_paddle(), lilGuy) then
            TEsound.play(paddleGuyHit, "static")

            lilGuy.direction = lilGuy.direction * (-1)
        end
    end

    oneLilGuy.time = oneLilGuy.time + time
    if oneLilGuy.state == "walk" then
        oneLilGuy.x = oneLilGuy.x + (oneLilGuy.animSpeed * time) * oneLilGuy.direction

        if oneLilGuy.x < oneLilGuy.xmin or oneLilGuy.x > oneLilGuy.xmax then
            oneLilGuy.direction = oneLilGuy.direction * (-1)
        end
    end
end

function LilDudes.dude_event()
    local numGuys = math.random(4, 8)
    local dir = {
        -1, 1
    }

    for i = 1, numGuys do
        local newLilGuy = {
            x = math.random(Handball.get_paddle().x + Handball.get_paddle().width + 20, WINDOWWIDTH - 50 - 20),
            y = WINDOWHEIGHT - 45,
            width = 20,
            height = 20,
            time = 0,
            walkSpeed = math.random(3, 6), -- frequency
            legSwing = 2, -- X amplitude
            stepHeight = 2, -- Y amplitude
            bobHeight = 2,
            direction = dir[math.random(#dir)], -- going right or left?
            animSpeed = math.random(40, 50), -- pixels/sec
            state = "walk" -- track current states
        }

        table.insert(lilGuys, newLilGuy)
    end
end

function LilDudes.clear_lilGuys()
    lilGuys = {}
end

function LilDudes.get_lilGuys()
    return lilGuys
end