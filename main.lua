--[[
    description: pong time... hope to add 3 modes like in the original: telstar tennis, handball, hockey
    currently, working on handball
]]--

require "gamemodes/handball"
require "gamemodes/tennis_1p"
require "TEsound"

-- get window width & height
-- i think it's like 800 x 600
local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

-- game state
local game_state = 'menu'
local menus = {
    'Handball',
    'Tennis (1P)',
    'Quit'
}
local selected_menu_item = 1

-- font stuff
local font = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 50) 
local smallFont = love.graphics.newFont("assets/fonts/PublicPixel.ttf", 20) 

-- shader stuff
local crtShader

function love.load()
    crtShader = love.graphics.newShader("assets/shaders/chrom.glsl")

    -- create canvas
    gameCanvas = love.graphics.newCanvas(WINDOWWIDTH, WINDOWHEIGHT)

    -- init game modes
    Handball.init()
    Tennis_1P.init()

    -- sound effects!
    wallHits = {
        "assets/audio/sound_effects/wallHit1.wav",
        "assets/audio/sound_effects/wallHit2.wav",
        "assets/audio/sound_effects/wallHit3.wav"
    }

    paddleHit = "assets/audio/sound_effects/paddleHit.wav"

    paddleAIHit = "assets/audio/sound_effects/paddleAIHit.wav"

    scoreDing = "assets/audio/sound_effects/score.wav"

    speedIncrease = "assets/audio/sound_effects/speedIncrease.wav"

    TEsound.volume("all", .3)
end


function love.update(dt)
    
    if game_state == 'handball' then
        Handball.handball(dt)
    elseif game_state == 'tennis_1p' then
        Tennis_1P.tennis(dt)
    end

    -- check if handball lost
    if Handball.isGameOver() then
        game_state = "menu"
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
        x = 270
    }
    local pointer = {
        x = 160,
        y = 10 + startY,
        width = 20,
        height = 10,
        angle = 2 * math.pi
    }

    -- draw game title
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.printf("PONG", startX - 90, titleY, font:getWidth("PONG"), "center")

    love.graphics.setFont(smallFont)

    -- draw menu items
    for i = 1, #menus do
        if i == selected_menu_item then
            drawBoid("fill", menu.x - smallFont:getWidth(menus[selected_menu_item]) + pointer.x, pointer.y + fontHeight * (i - 1), pointer.width, pointer.height, pointer.angle)
        end

        love.graphics.printf(menus[i], menu.x, startY + fontHeight * (i - 1), 300, "center")
    end

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
    elseif game_state == "handball" then
        Handball.drawGame()
    elseif game_state == "tennis_1p" then
        Tennis_1P.drawGame()
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
        if menus[selected_menu_item] == 'Handball' then
            Handball.init()

            game_state = 'handball'
        elseif menus[selected_menu_item] == 'Tennis (1P)' then
            Tennis_1P.init()

            game_state = 'tennis_1p'
        elseif menus[selected_menu_item] == 'Quit' then
            love.event.quit()
        end
    end
end