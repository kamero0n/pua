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
    -- wall stuff
    wallHeight = 10

    -- paddle stuff
    paddle = {}
    paddle.x = 20
    paddle.y = 5
    paddle.width = 10
    paddle.height = 70
    paddle.speed = 300

    -- ball stuff
    ballX = 300
    ballY = 400
    ballSize = 10
    ballYDir = 1
    ballXDir = 1
    ballSpeed = 300

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
    if paddle.y  <= wallHeight then
        paddle.y  = wallHeight
    elseif paddle.y  >= (WINDOWHEIGHT - wallHeight) - paddle.height then
        paddle.y  = (WINDOWHEIGHT - wallHeight) - paddle.height
    end

    -- ball movements
    ballX = ballX + ballSpeed * ballXDir * dt
    ballY = ballY + ballSpeed * ballYDir * dt

    -- y pos ball wall constraints
    if ballY >= (WINDOWHEIGHT - wallHeight) - ballSize then
        ballYDir = -1
        
        TEsound.play(wallHits, "static")
    elseif ballY <= wallHeight then
        ballYDir = 1

        TEsound.play(wallHits, "static")
    end

    -- x pos ball wall constraints
    if ballX >= (WINDOWWIDTH - 30) - ballSize then
        ballXDir = -1

       TEsound.play(wallHits, "static")
    end

    -- check for collisions w/ paddle
    if lose == false then
         if ballX <= paddle.x + paddle.width then
            -- y collision check
            if(ballY + ballSize >= paddle.y ) and (ballY <= paddle.y + paddle.height) then
                ballXDir = 1
                score = score + 1

                paddle.speed = paddle.speed + 1
                ballSpeed = ballSpeed + 1

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
    love.graphics.rectangle("fill", ballX, ballY, ballSize, ballSize);

    -- trying out dashed line
    dashLine(WINDOWWIDTH / 2, 0, WINDOWWIDTH / 2, WINDOWHEIGHT);

    -- score
    love.graphics.printf(score, (WINDOWWIDTH / 2) - 120, 20, 100, "left")
    
end