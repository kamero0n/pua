
require 'events/lilDudes'

Handball = {}

-- window stuff
local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

-- font
local font = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 50)
local smallFont = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 30) 
local smallerFont = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 20) 

-- local variables
local wallHeight, paddle, balls, ball_velocities, score, lose, max_speed, endScreen, eventTimer, curr_time

-- random events
local events
local ogPaddleHeight = 70
local ogPaddleSpeed = 500
local obstaclesActive = false

local obstacles = {}
local spawnArea = {}

function Handball.init()
    -- wall stuff
    wallHeight = 10

    -- paddle stuff
    paddle = {
        x = 10,
        y = 5,
        width = 10,
        height = 70,
        speed = 500
    }

    -- ball stuff
    balls = {
        {x = WINDOWWIDTH / 2,
        y = 400,
        width = 10,
        height = 10}
    }

    ball_velocities = {
        {x = -200,
        y = -200}
    }

    max_speed = 700

    -- track score
    score = 0

    -- flag for loss
    lose = false

    -- timers for random events
    eventTimer = 0
    curr_time = 0

    -- events 
    events = {
        {Handball.long_paddle, 30},
        {Handball.fast_paddle, 30},
        {Handball.mult_balls, 0},
        {Handball.obstacles_event, 30}
    }

    spawnArea = {
        minX = paddle.x + paddle.width + 30,
        minY = wallHeight + 30,
        maxX = WINDOWWIDTH - 40,
        maxY = WINDOWHEIGHT - wallHeight - 30
    }

    -- endScreen
    endScreen = false

    Handball.spawn_obstacle()
end

function Handball.resetEvents()
   -- reset height
    if paddle.height ~= ogPaddleHeight then
        paddle.height = ogPaddleHeight
   end

   -- reset speed
   if paddle.speed ~= ogPaddleSpeed then
        paddle.speed = ogPaddleSpeed
   end

   -- reset obstacles
   if obstaclesActive then
        obstacles = {}

        obstaclesActive = false
   end
end

function Handball.reset()
    -- reset all the variables

    -- paddle stuff
    paddle.x = 10
    paddle.y = 5
    paddle.speed = 500

    -- ball stuff
    balls = {
        {x = WINDOWWIDTH / 2,
        y = math.random(10, WINDOWHEIGHT - wallHeight),
        width = 10,
        height = 10}
    }

    ball_velocities = {
        {x = -200,
        y = -200}
    }

    -- track score
    score = 0

    -- flag for loss
    lose = false

    -- reset event timer
    eventTimer = 0
    curr_time = 0

    -- ensure obstacles are empty
    obstacles = {}

    -- endScreen
    endScreen = false
end

function Handball.handball(dt)
        -- paddle movements
        if love.keyboard.isDown("down") then
            paddle.y  = paddle.y  + paddle.speed * dt
        elseif love.keyboard.isDown("up") then
            paddle.y  = paddle.y  - paddle.speed * dt
        end

        if love.keyboard.isDown("m") then
            endScreen = true
        end

        -- paddle constraints/limits
        if paddle.y  < wallHeight then
            paddle.y  = wallHeight
        elseif paddle.y  > (WINDOWHEIGHT - wallHeight) - paddle.height then
            paddle.y  = (WINDOWHEIGHT - wallHeight) - paddle.height
        end

        -- track lil guy
        LilDudes.updateTime(dt)

        for i = #balls, 1, -1 do 
            local ball = balls[i]
            local ball_velocity = ball_velocities[i]

            -- move ball
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

            -- handle if ball went off left side
            if ball.x < -ball.width then
                table.remove(balls, i)
                table.remove(ball_velocities, i)

                if #balls == 0 then
                    endScreen = true
                end

                goto continue
            end

            -- check for collisions w/ other paddles
            if obstaclesActive then
                if #obstacles > 0 then 
                    for j = #obstacles, 1, -1 do
                        local collided = Handball.check_collision(ball, obstacles[j])

                        if collided == true then
                            Handball.handle_obstacle_collision(ball, ball_velocity, obstacles[j])
                            TEsound.play(wallHits, "static")

                            break
                        end
                    end
                end
            end

            -- check for collisions w/ paddle
            if lose == false and endScreen ~= true then
                if ball.x < paddle.x + ball.width then
                    -- y collision check
                    if(ball.y + ball.height >= paddle.y ) and (ball.y <= paddle.y + paddle.height) then
                        ball_velocity.x = ball_velocity.x * (-1)
                        ball.x = paddle.x + paddle.width

                        score = score + 1
                        TEsound.play(scoreDing, "static", 0.5)
                        TEsound.play(paddleHit, "static")

                        -- every five hits increase the speed of the ball ... max speed at 800 AND have a special event start
                        if score % 5 == 0 and score ~= 0 then
                            if ball_velocity.x <= max_speed and ball_velocity.x >= -max_speed then
                                if ball_velocity.x < 0 then
                                    ball_velocity.x = ball_velocity.x - 50.0
                                else
                                    ball_velocity.x = ball_velocity.x + 50.0
                                end

                                TEsound.play(speedIncrease, "static")
                            end

                            if ball_velocity.y <= max_speed and ball_velocity.y >= -max_speed then
                                if ball_velocity.y < 0 then
                                    ball_velocity.y = ball_velocity.y - 50.0
                                else
                                    ball_velocity.y = ball_velocity.y + 50.0
                                end

                                TEsound.play(speedIncrease, "static")
                            end

                            local randomChoice = math.random(1, #events)
                            
                            -- only have an event play if it's non timed or no timer is currently active
                            if events[randomChoice][2] == 0 or eventTimer == 0 then
                                events[randomChoice][1]()

                                if events[randomChoice][2] > 0 then
                                    eventTimer = events[randomChoice][2]
                                end
                            end
                        end

                    else
                        table.remove(balls, i)
                        table.remove(ball_velocities, i)

                        if #balls == 0 then
                            endScreen = true
                        end
                    end
                end
            end

            ::continue::
        end

        -- if there is a random event playing and eventTimer is > 0, set up curr_time... otherwise, make curr_time = 0
        if eventTimer > 0 then
            curr_time = curr_time + dt

            if curr_time >= eventTimer then
                Handball.resetEvents()
                eventTimer = 0
                curr_time = 0
            end
        else
            curr_time = 0
        end

        -- set the high score
        if score > handball_highscore then
            handball_highscore = score
        end
end

function Handball.keypressed(key)
    if key == '1' then
        TEsound.play(selectDing, "static")
        Handball.reset()

        endScreen = false
    elseif key == '2' then
        TEsound.play(selectDing, "static")
        lose = true
    end

end

function Handball.isGameOver()
    if lose == true then
        return true
    end

    return false
end

function Handball.drawTimer(t)
    -- find out how much time is left
    local progress_ratio = t / eventTimer

    local angle = progress_ratio * (2 * math.pi)

    -- draw timer
   if progress_ratio ~= 1 then
        love.graphics.arc("fill", WINDOWWIDTH / 2 + 50, 50, 30, angle - (math.pi / 2), 2 * math.pi - (math.pi / 2))
   end
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
    for _, ball in ipairs(balls) do
        love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height);
    end

    -- trying out dashed line
    dashLine(WINDOWWIDTH / 2, 0, WINDOWWIDTH / 2, WINDOWHEIGHT, 25);

    -- draw timer only if there is an event going on
    if eventTimer ~= 0 then
        Handball.drawTimer(curr_time)
    end

    -- draw obstacle
    if obstaclesActive then
        for i = #obstacles, 1, -1 do
            local obstacle = obstacles[i]
            love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.width, obstacle.height)
        end
    end

    -- score
    love.graphics.printf(score, (WINDOWWIDTH / 2) - 120, 20, 300, "left")

    -- lil dude
    LilDudes.drawDude()

    if endScreen == true then
        -- fill up the background to be black! with some opacity
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)

        -- then we will add text
        love.graphics.setColor(1, 1, 1, 1) -- make text white

        love.graphics.printf("GAME OVER", WINDOWWIDTH / 2 - 99, WINDOWHEIGHT / 2 - 150, 200, "left")

        -- set smaller font
        love.graphics.setFont(smallFont)
        love.graphics.printf("Score: ", WINDOWWIDTH / 2 - 200, WINDOWHEIGHT / 2, 400, "left")
       -- love.graphics.printf(handball_highscore, WINDOWWIDTH / 2 - 99, WINDOWHEIGHT / 2 + 20, 200, "center")
        love.graphics.printf(score, WINDOWWIDTH / 2 + 10, WINDOWHEIGHT / 2, 200, "center")

        love.graphics.printf("Hi-score: ", WINDOWWIDTH / 2 - 200, WINDOWHEIGHT / 2 + 60, 400, "left")
        love.graphics.printf(handball_highscore, WINDOWWIDTH / 2 + 10, WINDOWHEIGHT / 2 + 60, 200, "center")

        -- go back to menu or restart
        love.graphics.setFont(smallerFont)
        love.graphics.printf("[1] Restart", WINDOWWIDTH / 2 - 300, WINDOWHEIGHT / 2 + 150, 400, "left")
        love.graphics.printf("[2] Menu", WINDOWWIDTH / 2 + 50, WINDOWHEIGHT / 2 + 150, 400, "left")
    end
end

function Handball.long_paddle()
    paddle.height = paddle.height + 30
end

function Handball.fast_paddle() -- REALLY fast
    paddle.speed = paddle.speed + 400
end

function Handball.mult_balls()
    local numBalls = math.random(2, 4) -- 2-4 balls max

    for i = 1, numBalls do
        local newBall = {
            x = WINDOWWIDTH / 2 + math.random(-50, 50),
            y = math.random(wallHeight + 20, WINDOWHEIGHT - wallHeight - 20),
            width = 10,
            height = 10
        }

        local newVelocity = {
            x = math.random(-400, 400),
            y = math.random(-300, 300)
        }

        table.insert(balls, newBall)
        table.insert(ball_velocities, newVelocity)
    end
end

function Handball.obstacles_event()
    obstaclesActive = true
    obstacles = {} -- clear existing obstacles
    Handball.spawn_obstacle()
end

function Handball.spawn_obstacle()
    if #obstacles == 0 then
        local numObstacles = math.random(3, 6)

        for i = 1, numObstacles do
            local newObstacle = {
                x = math.random(spawnArea.minX, spawnArea.maxX), 
                y = math.random(spawnArea.minY, spawnArea.maxY),
                width = math.random(40, 90),
                height = math.random(40, 90)
            }

            table.insert(obstacles, newObstacle)
        end
    end
end

function Handball.check_collision(a, b)
    local a_left = a.x
    local a_right = a.x + a.width
    local a_top = a.y
    local a_bottom = a.y + a.height

    local b_left = b.x
    local b_right = b.x + b.width
    local b_top = b.y
    local b_bottom = b.y + b.height

    return a_right > b_left 
        and a_left < b_right 
        and a_bottom > b_top
        and a_top < b_bottom
end

function Handball.handle_obstacle_collision(ball, ball_velocity, obstacle)
    -- calculate overlap
    local overlapX = math.min(ball.x + ball.width - obstacle.x, obstacle.x + obstacle.width - ball.x)
    local overlapY = math.min(ball.y + ball.height - obstacle.y, obstacle.y + obstacle.height - ball.y)

    -- push ball out on the axis w/ smallest distance
    if overlapX < overlapY then
        if ball.x < obstacle.x then
            ball.x = obstacle.x - ball.width -- push left
        else
            ball.x = obstacle.x + obstacle.width -- push right
        end

        ball_velocity.x = ball_velocity.x * (-1)
    else
        if ball.y < obstacle.y then
            ball.y = obstacle.y - ball.height -- push up
        else
            ball.y = obstacle.y + obstacle.height -- push down
        end

        ball_velocity.y = ball_velocity.y * (-1)
    end
end

function Handball.get_paddle()
    return paddle
end