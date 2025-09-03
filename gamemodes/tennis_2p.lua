Tennis_2P = {}

-- window stuff
local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

-- font
local font = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 50)
local smallFont = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 30) 
local smallerFont = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 20) 

-- local vars
local wallHeight, paddle, paddle2, ball, ball_velocity, score, player2_score, player2Win, player2WinScreen, paddleCount, target, player1Win, player1WinScreen, pauseScreen

local titleY = 0
local time = 0
-- audio
local setEndMusic = false

function Tennis_2P.init()
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

    paddle2 = {
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

    -- player2 stuff
    paddleCount = 0
    target = ball.y

    -- track score
    score = 0
    player2_score = 0

    -- flag for loss
    player2Win = false
    player2WinScreen = false

    -- flag for win
    player1Win = false
    player1WinScreen = false

    pauseScreen = false

end

function Tennis_2P.reset()
    -- paddles
    paddle.x = 20
    paddle.y = WINDOWHEIGHT / 2
    paddle.speed = 500

    paddle2.x = WINDOWWIDTH - 20
    paddle2.y = WINDOWHEIGHT / 2
    paddle2.speed = 500

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
    player2_score = 0

    -- ai stuff
    paddleCount = 0
    target = ball.y

    -- reset flags
    player2Win = false
    player2WinScreen = false

    player1Win = false
    player1WinScreen = false

    pauseScreen = false

    -- reset music
    setEndMusic = false
    TEsound.stop("endMenu")
    TEsound.stop("winMenu")
end

function Tennis_2P.tennis(dt)
    if love.keyboard.isDown("b") then
        player1WinScreen = true
    end

    if pauseScreen ~= true then
        -- human paddle movements
        if love.keyboard.isDown("down") then
            paddle.y = paddle.y + paddle.speed * dt
        elseif love.keyboard.isDown("up") then
            paddle.y = paddle.y - paddle.speed * dt
        end

        -- 2nd player movements
        if love.keyboard.isDown("w") then
            paddle2.y = paddle2.y - paddle2.speed * dt
        elseif love.keyboard.isDown("s") then
            paddle2.y = paddle2.y + paddle2.speed * dt
        end

        -- paddle 2 limits
        if paddle2.y  > (WINDOWHEIGHT - wallHeight) - paddle2.height then
            paddle2.y  = (WINDOWHEIGHT - wallHeight) - paddle2.height
        elseif paddle2.y < wallHeight then
            paddle2.y = wallHeight
        end

        -- paddle 1 constraints/limits
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


        -- check paddle collisions
        if player2WinScreen == false and player1WinScreen == false then
            if ball.x < paddle.x + paddle.width then
                if(ball.y + ball.height > paddle.y ) and (ball.y < paddle.y + paddle.height) then
                    ball_velocity.x = ball_velocity.x * (-1)
                    ball.x = paddle.x + paddle.width

                    Tennis_2P.increase_ballSpeed(ball_velocity.x, ball_velocity.y)

                    TEsound.play(paddleHit, "static")
                else
                    player2_score = player2_score + 1

                    Tennis_2P.randomize_ball(false)
                end
            end


            -- ai paddle hits
            if ball.x > paddle2.x then
                -- y collision
                if(ball.y + ball.height > paddle2.y) and (ball.y < paddle2.y + paddle2.height) then
                    ball_velocity.x = ball_velocity.x * (-1)
                    ball.x = paddle2.x

                    Tennis_2P.increase_ballSpeed(ball_velocity.x, ball_velocity.y)

                    TEsound.play(paddleAIHit, "static")
                else
                    score = score + 1

                    Tennis_2P.randomize_ball(true)
                end
            end
        end

        -- check if ball is off screen and game is over
        if player1WinScreen == true then
            if ball.x > WINDOWWIDTH then
                ball_velocity.x = 0
                ball_velocity.y = 0
            end
        end

        if player2WinScreen == true then 
            if ball.x < -ball.width then
                ball_velocity.x = 0
                ball_velocity.y = 0
            end
        end

        if player2_score == 10 then
            player2WinScreen = true
        end

        if score == 10 then
            player1WinScreen = true
        end

        -- play end music
        if player2WinScreen == true and setEndMusic == false then
            TEsound.playLooping(gameOverMusic, "stream", "winMenu", nil, 0.5)

            setEndMusic = true
        end
        if player1WinScreen == true and setEndMusic == false then
            TEsound.playLooping(winMusic, "stream", "winMenu", nil, 0.5)

            setEndMusic = true
        end

        -- floating UI
        if player1WinScreen == true or player2WinScreen == true then
            -- update title
            time = time + dt
            titleY = 10 * math.sin(time)
        end
    end
end


function Tennis_2P.keypressed(key)
    if player2WinScreen or player1WinScreen or pauseScreen then
        if key == '1' then
            TEsound.play(selectDing, "static")
            Tennis_2P.reset()
            
            if player2WinScreen == true then
             player2WinScreen = false
            end

            if player1WinScreen == true then
                player1WinScreen = false
            end
        elseif key == '2' then
            TEsound.play(selectDing, "static")
            
            if player2Win == false then
                player2Win = true
            elseif player1Win == false then
                player1Win = true
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

function Tennis_2P.isGameOver()
    if player2Win == true then
        TEsound.stop("endMenu")

        return true
    end

    if player1Win == true then
        TEsound.stop("winMenu")

        return true
    end

    return false
end

function Tennis_2P.drawGame()
    love.graphics.setFont(font)

    -- pong paddle
    love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height);

    -- ai paddle
    love.graphics.rectangle("fill", paddle2.x, paddle2.y, paddle2.width, paddle2.height);

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
    love.graphics.printf(player2_score, (WINDOWWIDTH / 2) + 60, 20, 100, "left")

    if player2WinScreen == true then
        -- fill up the background to be black! with some opacity
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)

        -- then we will add text
        love.graphics.setColor(1, 1, 1, 1) -- make text white

        love.graphics.printf("GAME OVER", WINDOWWIDTH / 2 - 99, WINDOWHEIGHT / 2 - 150 + titleY, 200, "left")

        -- set smaller font
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player 2 won :D", WINDOWWIDTH / 2 - 240, WINDOWHEIGHT / 2, 500, "left")

        -- go back to menu or restart
        love.graphics.setFont(smallerFont)
        love.graphics.printf("[1] Restart", WINDOWWIDTH / 2 - 250, WINDOWHEIGHT / 2 + 120, 400, "left")
        love.graphics.printf("[2] Menu", WINDOWWIDTH / 2 + 50, WINDOWHEIGHT / 2 + 120, 400, "left")
    end

    if player1WinScreen == true then
        -- fill up the background to be black! with some opacity
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)

        -- then we will add text
        love.graphics.setColor(1, 1, 1, 1) -- make text white

        love.graphics.printf("GAME OVER", WINDOWWIDTH / 2 - 99, WINDOWHEIGHT / 2 - 150 + titleY, 200, "left")

        -- set smaller font
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player 1 won :D", WINDOWWIDTH / 2 - 240, WINDOWHEIGHT / 2, 500, "left")

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

function Tennis_2P.randomize_ball(playerScored)
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

function Tennis_2P.increase_ballSpeed(ballSpeedX, ballSpeedY)
    local current_speed = math.sqrt(ballSpeedX^2 + ballSpeedY^2)

    local speed_increase = 20
    local newSpeed = math.max(speed_increase + current_speed, 700)


    local speed_factor = newSpeed / current_speed

    ball_velocity.x = ballSpeedX * speed_factor
    ball_velocity.y = ballSpeedY * speed_factor
end