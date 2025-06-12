Tennis_1P = {}

local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()



local font = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 50) 
local wallHeight, paddle, paddle_ai, ball, ball_velocity, score, AI_score, lose

function Tennis_1P.init()
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

    paddle_ai = {
        x = WINDOWWIDTH - 20,
        y = 5,
        width = 10,
        height = 70,
        speed = 500
    }

    -- ball stuff
    ball = {
        x = 400,
        y = 300, 
        width = 10,
        height = 10
    }

    ball_velocity = {
        x = 300,
        y = 300
    }

    -- track score
    score = 0
    AI_score = 0

    -- flag for loss
    lose = false

end

function Tennis_1P.tennis(dt)
    -- human paddle movements
    if love.keyboard.isDown("down") then
        paddle.y = paddle.y + paddle.speed * dt
    elseif love.keyboard.isDown("up") then
        paddle.y = paddle.y - paddle.speed * dt
    end

    -- human paddle constraints/limits
    if paddle.y  < wallHeight then
        paddle.y  = wallHeight
    elseif paddle.y  > (WINDOWHEIGHT - wallHeight) - paddle.height then
        paddle.y  = (WINDOWHEIGHT - wallHeight) - paddle.height
    end

    -- ball movements
    ball.x = ball.x + ball_velocity.x * dt
    ball.y = ball.y + ball_velocity.y * dt

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

    -- AI movements
    paddle_ai.y = ball.y

    -- ai paddle constraints/limits
    if paddle_ai.y  < wallHeight then
        paddle_ai.y  = wallHeight
    elseif paddle_ai.y  > (WINDOWHEIGHT - wallHeight) - paddle.height then
        paddle_ai.y  = (WINDOWHEIGHT - wallHeight) - paddle.height
    end

    -- ai paddle hits
    if ball.x > paddle_ai.x then
        -- y collision
        if(ball.y + ball.height > paddle_ai.y) and (ball.y < paddle_ai.y + paddle_ai.height) then
            ball_velocity.x = ball_velocity.x * (-1)
            ball.x = paddle_ai.x

            TEsound.play(paddleAIHit, "static")
        end
    end

    if lose == false then
        if ball.x < paddle.x + paddle.width then
            if(ball.y + ball.height > paddle.y ) and (ball.y < paddle.y + paddle.height) then
                ball_velocity.x = ball_velocity.x * (-1)
                ball.x = paddle.x + paddle.width

                TEsound.play(paddleHit, "static")
            else
                AI_score = AI_score + 1

                ball.x = 400
                ball.y = 300
            end
        end
    end

    if AI_score == 10 then
        lose = true
    end
end


function Tennis_1P.drawGame()
    love.graphics.setFont(font)

    -- pong paddle
    love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height);

    -- ai paddle
    love.graphics.rectangle("fill", paddle_ai.x, paddle_ai.y, paddle_ai.width, paddle_ai.height);

    -- top wall needs to be drawn
    love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, wallHeight);

    -- bottom wall needs to be drawn
    love.graphics.rectangle("fill", 0, WINDOWHEIGHT - wallHeight, WINDOWWIDTH, wallHeight);

    -- ball time
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height);

    -- trying out dashed line
    dashLine(WINDOWWIDTH / 2, 0, WINDOWWIDTH / 2, WINDOWHEIGHT, 25);

    -- score
    love.graphics.printf(score, (WINDOWWIDTH / 2) - 120, 20, 100, "left")

    -- enemy score
    love.graphics.printf(AI_score, (WINDOWWIDTH / 2) + 60, 20, 100, "left")

end