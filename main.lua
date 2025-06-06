--[[
    description: pong time... hope to add 3 modes like in the original: telstar tennis, handball, hockey
    currently, working on telstar tennis
]]--

require "TEsound"

-- get window width & height
-- i think it's like 800 x 600
WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

-- font stuff
font = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 50) 
love.graphics.setFont(font)


function love.load()
    Object = require "classic"

    -- wall stuff
    wallHeight = 10

    -- paddle stuff
    paddle = {
        x = 20,
        y = 5,
        width = 10,
        height = 70,
        speed = 500
    }

    -- ball stuff
    ball = {
        x = 300,
        y = 400, 
        width = 10,
        height = 10
    }

    ball_velocity = {
        x = 300,
        y = 300
    }

    -- track score
    score = 0

    -- track game state
    lose = false

    -- sound effects!
    wallHits = {
        "assets/audio/sound_effects/wallHit1.wav",
        "assets/audio/sound_effects/wallHit2.wav",
        "assets/audio/sound_effects/wallHit3.wav"
    }

    paddleHit = "assets/audio/sound_effects/paddleHit.wav"

    TEsound.volume("all", .1)
end


function love.update(dt)
    -- paddle movements
    if love.keyboard.isDown("down") then
        paddle.y  = paddle.y  + paddle.speed * dt
    elseif love.keyboard.isDown("up") then
        paddle.y  = paddle.y  - paddle.speed * dt
    end

    -- paddle constraints/limits
    if paddle.y  < wallHeight then
        paddle.y  = wallHeight
    elseif paddle.y  > (WINDOWHEIGHT - wallHeight) - paddle.height then
        paddle.y  = (WINDOWHEIGHT - wallHeight) - paddle.height
    end

    -- ball movements
    ball.x = ball.x + ball_velocity.x * dt--ballSpeed * ballXDir * dt
    ball.y = ball.y + ball_velocity.y * dt--ballSpeed * ballYDir * dt

    -- y pos ball wall constraints
    if ball.y >= (WINDOWHEIGHT - wallHeight) - ball.height then
        ball_velocity.y = ball_velocity.y * (-1)

        TEsound.play(wallHits, "static")
    end

    if ball.y <= wallHeight then
        ball_velocity.y = ball_velocity.y * (-1)

        TEsound.play(wallHits, "static")
    end

    -- x pos ball wall constraints
    if ball.x >= (WINDOWWIDTH - 30) - ball.width then
        ball_velocity.x = ball_velocity.x * (-1)

       TEsound.play(wallHits, "static")
    end

    -- check for collisions w/ paddle
    if lose == false then
         if ball.x <= paddle.x + paddle.width then
            -- y collision check
            if(ball.y + ball.height >= paddle.y ) and (ball.y <= paddle.y + paddle.height) then
                ball_velocity.x = ball_velocity.x * (-1)
                score = score + 1

                TEsound.play(paddleHit, "static")
            else
                lose = true
            end
        end
    end

    -- they told me to do this
    TEsound.cleanup()
end

--[[
    i got this by adapting this function: https://love2d.org/forums/viewtopic.php?t=83808
    + a lil math logic from claude to simplify the logic i had originally
]]--
function dashLine(x1, y1, x2, y2)
    -- distance formula first!
    local dx, dy = x2 - x1, y2 - y1
    local dist = math.sqrt((dx * dx) + (dy * dy))

    -- these are the steps... for now, distX is just 0 since this is a purely vertical line
    local distX = math.abs(dx) / dist
    local distY = math.abs(dy) / dist

    local gap = 10
    local size = 5
    for i = 0, dist do
        local currX = x1 + (distX * i) * gap 
        local currY = y1 + (distY * i) * gap

        local nextX = currX + distX * size -- + distX
        local nextY = currY + distY * size --+ distY
        love.graphics.line(currX, currY, nextX, nextY)
    end  
end


function love.draw()
    -- pong paddle
    love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height);

    -- top wall needs to be drawn
    love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, wallHeight);

    -- bottom wall needs to be drawn
    love.graphics.rectangle("fill", 0, WINDOWHEIGHT - wallHeight, WINDOWWIDTH, wallHeight);

    -- wall to the right will be drawn -- in the future this will be the "handball" mode
    love.graphics.rectangle("fill", WINDOWWIDTH - 30, 0, wallHeight, WINDOWHEIGHT);

    -- ball time
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height);

    -- trying out dashed line
    dashLine(WINDOWWIDTH / 2, 0, WINDOWWIDTH / 2, WINDOWHEIGHT);

    -- score
    love.graphics.printf(score, (WINDOWWIDTH / 2) - 120, 20, 100, "left")
    
end