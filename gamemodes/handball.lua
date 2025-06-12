
Handball = {}

local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()



local font = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 50) 
local wallHeight, paddle, ball, ball_velocity, score, lose

function Handball.init()
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

    -- flag for loss
    lose = false

end

function Handball.handball(dt)
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
        if ball.y > (WINDOWHEIGHT - wallHeight) - ball.height then
            ball_velocity.y = ball_velocity.y * (-1)
            ball.y = (WINDOWHEIGHT - wallHeight) - ball.height

            TEsound.play(wallHits, "static")
        elseif ball.y < wallHeight then
            ball_velocity.y = ball_velocity.y * (-1)
            ball.y = wallHeight

            TEsound.play(wallHits, "static")
        end

        -- x pos ball wall constraints
        if ball.x > (WINDOWWIDTH - 30) - ball.width then
            ball_velocity.x = ball_velocity.x * (-1)
            ball.x = (WINDOWWIDTH - 30) - ball.width

            TEsound.play(wallHits, "static")
        end

        -- check for collisions w/ paddle
        if lose == false then
            if ball.x < paddle.x + paddle.width then
                -- y collision check
                if(ball.y + ball.height > paddle.y ) and (ball.y < paddle.y + paddle.height) then
                    ball_velocity.x = ball_velocity.x * (-1)
                    ball.x = paddle.x + paddle.width

                    score = score + 1

                    TEsound.play(paddleHit, "static")
                else
                    lose = true
                end
            end
        end
end

function Handball.isGameOver()
    if lose == true then
        return true
    end

    return false
end

function Handball.drawGame()
    love.graphics.setFont(font)

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
    dashLine(WINDOWWIDTH / 2, 0, WINDOWWIDTH / 2, WINDOWHEIGHT, 25);

    -- score
    love.graphics.printf(score, (WINDOWWIDTH / 2) - 120, 20, 100, "left")

end