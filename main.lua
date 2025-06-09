--[[
    description: pong time... hope to add 3 modes like in the original: telstar tennis, handball, hockey
    currently, working on handball
]]--

require "TEsound"

-- get window width & height
-- i think it's like 800 x 600
local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

-- game state
local game_state = 'menu'
local menus = {
    'Play',
    'Quit'
}
local selected_menu_item = 1

-- font stuff
font = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 50) 


function love.load()
    crtShader = love.graphics.newShader("assets/shaders/chrom.glsl")

    -- create canvas
    gameCanvas = love.graphics.newCanvas(WINDOWWIDTH, WINDOWHEIGHT)

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

    TEsound.volume("all", .3)
end


function love.update(dt)
    
    if game_state == 'handball' then
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

    -- they told me to do this
    TEsound.cleanup()
end

--[[
    i got this by adapting this function: https://love2d.org/forums/viewtopic.php?t=83808
    + a lil math logic from claude to simplify the logic i had originally
]]--
function dashLine(x1, y1, x2, y2, numDashes)
    -- distance formula first!
    local dx, dy = x2 - x1, y2 - y1
    local dist = math.sqrt((dx * dx) + (dy * dy))

    -- these are the steps... for now, distX is just 0 since this is a purely vertical line
    local distX = math.abs(dx) / dist
    local distY = math.abs(dy) / dist

    local gap = 30
    local size = 20
    for i = 0, numDashes do
        local currX = x1 + (distX * i) * gap 
        local currY = y1 + (distY * i) * gap

        local nextX = currX + distX * size -- + distX
        local nextY = currY + distY * size --+ distY
        love.graphics.line(currX, currY, nextX, nextY)
    end
end

function drawBoid (mode, x, y, length, width, angle)
    -- pos, length, width and angle
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    love.graphics.polygon(mode, -length/2, -width/2, -length/2, width/2, length/2, 0)
    love.graphics.pop()
end

function drawMenu()
    local fontHeight = font:getHeight()
    
    -- local constants for tuning
    local startX = WINDOWWIDTH / 2 
    local startY = WINDOWHEIGHT / 2 - (fontHeight * (#menus / 2))
    local titleY = 20
    local menu = {
        x = 310,
        font = 20
    }
    local pointer = {
        x = 345,
        y = 10 + startY,
        width = 20,
        height = 10,
        angle = 2 * math.pi
    }

    -- draw game title
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.printf("PONG", startX - 90, titleY, font:getWidth("PONG"), "center")

    local newFont = love.graphics.newFont("assets/fonts/PublicPixel.ttf", menu.font) 
    love.graphics.setFont(newFont)

    -- draw menu items
    for i = 1, #menus do

        if i == selected_menu_item then
            drawBoid("fill", pointer.x, pointer.y + fontHeight * (i - 1), pointer.width, pointer.height, pointer.angle)
        end

        love.graphics.printf(menus[i], menu.x, startY + fontHeight * (i - 1), 200, "center")
    end

end


function drawGame()
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

function love.draw()
    -- set the target canvas to draw on 
    love.graphics.setCanvas(gameCanvas) 
    -- clear before we do anything
    love.graphics.clear()

    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 1) -- set the drawin color to black

    -- fill up the background to be black!
    love.graphics.rectangle("fill", 0, 0, WINDOWWIDTH, WINDOWHEIGHT)

    love.graphics.setColor(1, 1, 1, 1) -- set the drawin color to white

    if game_state == "menu" then
        drawMenu()
    else
        drawGame()
    end
    
    -- i think this means we take the canvas out as it is now ready to be used
    love.graphics.setCanvas() 
    love.graphics.setShader(crtShader)

    -- draw it
    love.graphics.draw(gameCanvas, 0, 0);
    love.graphics.setShader()
end

function love.keypressed(key, scan_code, is_repeat)
    if game_state == "menu" then
        menu_keypressed(key)
    end
end

function menu_keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'up' then
        selected_menu_item = selected_menu_item - 1

        if selected_menu_item < 1 then
            selected_menu_item = #menus
        end
    elseif key == 'down' then
        selected_menu_item = selected_menu_item + 1

        if selected_menu_item > #menus then
            selected_menu_item = 1
        end
    elseif key == 'return' or key == 'kpenter' then
        if menus[selected_menu_item] == 'Play' then
            game_state = 'handball'
        elseif menus[selected_menu_item] == 'Quit' then
            love.event.quit()
        end
    end
end