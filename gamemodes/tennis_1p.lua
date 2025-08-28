Tennis_1P = {}

-- window stuff
local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

-- font
local font = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 50)
local smallFont = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 30) 
local smallerFont = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 20) 

-- local vars
local wallHeight, paddle, paddle_ai, ball, ball_velocity, score, AI_score, lose, loseScreen, paddleCount, target, win, winScreen, pauseScreen

local titleY = 0
local time = 0
-- audio
local setEndMusic = false

function Tennis_1P.init()
    -- wall stuff
    wallHeight = 10

    -- paddle stuff
    paddle = {
        x = 20,
        y = WINDOWHEIGHT / 2,
        width = 10,
        height = 70,
        speed = 500
    }

    paddle_ai = {
        x = WINDOWWIDTH - 20,
        y = WINDOWHEIGHT / 2,
        width = 10,
        height = 70,
        speed = 500
    }

    -- ball stuff
    ball = {
        x = WINDOWWIDTH / 2,
        y = math.random(10, WINDOWHEIGHT - wallHeight), 
        width = 10,
        height = 10
    }

    ball_velocity = {
        x = -300,
        y = -300
    }

    -- ai stuff
    paddleCount = 0
    target = ball.y

    -- track score
    score = 0
    AI_score = 0

    -- flag for loss
    lose = false
    loseScreen = false

    -- flag for win
    win = false
    winScreen = false

    pauseScreen = false

end

function Tennis_1P.reset()
    -- paddles
    paddle.x = 20
    paddle.y = WINDOWHEIGHT / 2
    paddle.speed = 500

    paddle_ai.x = WINDOWWIDTH - 20
    paddle_ai.y = WINDOWHEIGHT / 2
    paddle_ai.speed = 500

    -- ball stuff
    ball = {
        x = WINDOWWIDTH / 2,
        y = math.random(10, WINDOWHEIGHT - wallHeight), 
        width = 10,
        height = 10
    }

    ball_velocity = {
        x = -300,
        y = -300
    }

    -- scores
    score = 0
    AI_score = 0

    -- ai stuff
    paddleCount = 0
    target = ball.y

    -- reset flags
    lose = false
    loseScreen = false

    win = false
    winScreen = false

    pauseScreen = false

    -- reset music
    setEndMusic = false
    TEsound.stop("endMenu")
    TEsound.stop("winMenu")
end

function Tennis_1P.tennis(dt)
    if pauseScreen ~= true then
        -- human paddle movements
        if love.keyboard.isDown("down") then
            paddle.y = paddle.y + paddle.speed * dt
        elseif love.keyboard.isDown("up") then
            paddle.y = paddle.y - paddle.speed * dt
        end

        -- human paddle constraints/limits
        if paddle.y  < wallHeight then
            paddle.y = wallHeight
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
        paddleCount = paddleCount + dt
        local random_check = math.random(0.3, 0.6)

        if paddleCount >= random_check then
            if ball_velocity.x > 0 then
                local time_to_reach = (paddle_ai.x - ball.x) / ball_velocity.x

                target = ball.y + ball.height / 2 + (ball_velocity.y * time_to_reach) - paddle_ai.height / 2 --math.random(-10, 10)
            else
                target = ball.y + ball.height / 2 - paddle_ai.height / 2
            end

            paddleCount = 0
        end

        local dist = paddle_ai.y - target
        local maxSpeed = paddle_ai.speed

        -- speed gets smaller as distance gets smaller
        local speed = math.min(maxSpeed, math.abs(dist) * 100)

        if target > paddle_ai.y then
            paddle_ai.y = paddle_ai.y + dt * speed
        elseif target < paddle_ai.y then
            paddle_ai.y = paddle_ai.y - dt * speed
        end

        if paddle_ai.y  > (WINDOWHEIGHT - wallHeight) - paddle.height then
            paddle_ai.y  = (WINDOWHEIGHT - wallHeight) - paddle.height
        elseif paddle_ai.y < wallHeight then
            paddle_ai.y = wallHeight
        end

        -- check paddle collisions
        if loseScreen == false and winScreen == false then
            if ball.x < paddle.x + paddle.width then
                if(ball.y + ball.height > paddle.y ) and (ball.y < paddle.y + paddle.height) then
                    ball_velocity.x = ball_velocity.x * (-1)
                    ball.x = paddle.x + paddle.width

                    Tennis_1P.increase_ballSpeed(ball_velocity.x, ball_velocity.y)

                    TEsound.play(paddleHit, "static")
                else
                    AI_score = AI_score + 1

                    Tennis_1P.randomize_ball(false)
                end
            end


            -- ai paddle hits
            if ball.x > paddle_ai.x then
                -- y collision
                if(ball.y + ball.height > paddle_ai.y) and (ball.y < paddle_ai.y + paddle_ai.height) then
                    ball_velocity.x = ball_velocity.x * (-1)
                    ball.x = paddle_ai.x

                    Tennis_1P.increase_ballSpeed(ball_velocity.x, ball_velocity.y)

                    TEsound.play(paddleAIHit, "static")
                else
                    score = score + 1

                    Tennis_1P.randomize_ball(true)
                end
            end
        end

        -- check if ball is off screen and game is over
        if winScreen == true then
            if ball.x > WINDOWWIDTH then
                ball_velocity.x = 0
                ball_velocity.y = 0
            end
        end

        if loseScreen == true then 
            if ball.x < -ball.width then
                ball_velocity.x = 0
                ball_velocity.y = 0
            end
        end

        if AI_score == 10 then
            loseScreen = true
        end

        if score == 10 then
            winScreen = true
        end

        -- play end music
        if loseScreen == true and setEndMusic == false then
            TEsound.playLooping(gameOverMusic, "stream", "endMenu", nil, 0.5)

            setEndMusic = true
        end
        if winScreen == true and setEndMusic == false then
            TEsound.playLooping(winMusic, "stream", "winMenu", nil, 0.5)

            setEndMusic = true
        end

        -- floating UI
        if winScreen == true or loseScreen == true then
            -- update title
            time = time + dt
            titleY = 10 * math.sin(time)
        end
    end
end


function Tennis_1P.keypressed(key)
    if loseScreen or winScreen or pauseScreen then
        if key == '1' then
            TEsound.play(selectDing, "static")
            Tennis_1P.reset()
            
            if loseScreen == true then
                loseScreen = false
            end

            if winScreen == true then
                winScreen = false
            end
        elseif key == '2' then
            TEsound.play(selectDing, "static")
            
            if lose == false then
                lose = true
            elseif win == false then
                win = true
            end
        end
    end

    if key == 'escape' then
        if pauseScreen then
            pauseScreen = false
        else
            pauseScreen = true
        end
    end
end

function Tennis_1P.isGameOver()
    if lose == true then
        TEsound.stop("endMenu")

        return true
    end

    if win == true then
        TEsound.stop("winMenu")

        return true
    end

    return false
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

    if loseScreen == true then
        -- fill up the background to be black! with some opacity
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)

        -- then we will add text
        love.graphics.setColor(1, 1, 1, 1) -- make text white

        love.graphics.printf("GAME OVER", WINDOWWIDTH / 2 - 99, WINDOWHEIGHT / 2 - 150 + titleY, 200, "left")

        -- set smaller font
        love.graphics.setFont(smallFont)
        love.graphics.printf("You lost :(", WINDOWWIDTH / 2 - 150, WINDOWHEIGHT / 2, 400, "left")

        -- go back to menu or restart
        love.graphics.setFont(smallerFont)
        love.graphics.printf("[1] Restart", WINDOWWIDTH / 2 - 250, WINDOWHEIGHT / 2 + 120, 400, "left")
        love.graphics.printf("[2] Menu", WINDOWWIDTH / 2 + 50, WINDOWHEIGHT / 2 + 120, 400, "left")
    end

    if winScreen == true then
        -- fill up the background to be black! with some opacity
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)

        -- then we will add text
        love.graphics.setColor(1, 1, 1, 1) -- make text white

        love.graphics.printf("GAME OVER", WINDOWWIDTH / 2 - 99, WINDOWHEIGHT / 2 - 150 + titleY, 200, "left")

        -- set smaller font
        love.graphics.setFont(smallFont)
        love.graphics.printf("You won :)", WINDOWWIDTH / 2 - 150, WINDOWHEIGHT / 2, 400, "left")

        -- go back to menu or restart
        love.graphics.setFont(smallerFont)
        love.graphics.printf("[1] Restart", WINDOWWIDTH / 2 - 250, WINDOWHEIGHT / 2 + 120, 400, "left")
        love.graphics.printf("[2] Menu", WINDOWWIDTH / 2 + 50, WINDOWHEIGHT / 2 + 120, 400, "left")
    end

    if pauseScreen == true then
        -- fill up the background to be black! with some opacity
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)

        -- then we will add text
        love.graphics.setColor(1, 1, 1, 1) -- make text white

        love.graphics.printf("PAUSED", WINDOWWIDTH / 2 - 150, WINDOWHEIGHT / 2 - 150 + titleY, 300, "left")


        -- go back to menu or restart
        love.graphics.setFont(smallerFont)
        love.graphics.printf("[1] Restart", WINDOWWIDTH / 2 - 250, WINDOWHEIGHT / 2 + 120, 400, "left")
        love.graphics.printf("[2] Menu", WINDOWWIDTH / 2 + 50, WINDOWHEIGHT / 2 + 120, 400, "left")
    end
end

function Tennis_1P.randomize_ball(playerScored)
    ball.x = WINDOWWIDTH / 2
    ball.y = math.random(10, WINDOWHEIGHT - wallHeight)

    if playerScored then
        ball_velocity.x = 300
        ball_velocity.y = 300
    else
        ball_velocity.x = -300
        ball_velocity.y = -300
    end
end

function Tennis_1P.increase_ballSpeed(ballSpeedX, ballSpeedY)
    local current_speed = math.sqrt(ballSpeedX^2 + ballSpeedY^2)

    local speed_increase = 20
    local newSpeed = math.max(speed_increase + current_speed, 700)


    local speed_factor = newSpeed / current_speed

    ball_velocity.x = ballSpeedX * speed_factor
    ball_velocity.y = ballSpeedY * speed_factor
end