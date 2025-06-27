ClosingWall = {}

local WINDOWWIDTH, WINDOWHEIGHT = love.graphics.getDimensions()

-- ("fill", WINDOWWIDTH - 30, 0, wallHeight, WINDOWHEIGHT);
local originalX = WINDOWWIDTH - 30

wall = {
    mode = "fill",
    x = originalX,
    y = 0,
    time = 0,
    width = 10,
    height = WINDOWHEIGHT,
    speed = 20
}


function ClosingWall.drawWall()
    love.graphics.rectangle(wall.mode, wall.x, wall.y, wall.width, wall.height)
end

function ClosingWall.update(time)
    time = time + wall.time

    wall.x = wall.x + wall.speed * time * (-1)
end

function ClosingWall.reset_wall_pos()
    wall.x = originalX
    wall.time = 0
end

function ClosingWall.get_wall()
    return wall
end