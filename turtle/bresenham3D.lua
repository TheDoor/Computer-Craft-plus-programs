-- Define constants for cardinal directions
local NEGZ = 0
local POSX = 1
local POSZ = 2
local NEGX = 3 -- Corrected constant name for negative X direction

-- Define global variable for facing direction
local facing = nil

-- Function to move the turtle forward
local function moveForward(times)
    times = times or 1
    for _ = 1, times do
        if not turtle.forward() then
            return false -- Return false if movement is obstructed
        end
    end
    return true -- Return true if movement is successful
end

-- Function to move the turtle backward
local function moveBackward(times)
    times = times or 1
    for _ = 1, times do
        if not turtle.back() then
            return false -- Return false if movement is obstructed
        end
    end
    return true -- Return true if movement is successful
end

-- Function to turn the turtle right
local function turnRight(times)
    times = times or 1
    for _ = 1, times do
        turtle.turnRight()
        facing = (facing + 1) % 4
    end
end

-- Function to turn the turtle left
local function turnLeft(times)
    times = times or 1
    for _ = 1, times do
        turtle.turnLeft()
        facing = (facing - 1) % 4
    end
end

-- Function to move the turtle upward
local function moveUp(times)
    times = times or 1
    for _ = 1, times do
        if not turtle.up() then
            return false -- Return false if movement is obstructed
        end
    end
    return true -- Return true if movement is successful
end

-- Function to move the turtle downward
local function moveDown(times)
    times = times or 1
    for _ = 1, times do
        if not turtle.down() then
            return false -- Return false if movement is obstructed
        end
    end
    return true -- Return true if movement is successful
end

-- Function to move the turtle to positive X direction
local function movePosX(times)
    if facing == POSX then
        return moveForward(times)
    elseif facing == NEGX then
        turnRight()
        return moveForward(times)
    elseif facing == POSZ then
        turnLeft()
        return moveForward(times)
    elseif facing == NEGZ then
        turnRight(2)
        return moveForward(times)
    end
end

-- Function to move the turtle to negative X direction
local function moveNegX(times)
    if facing == POSX then
        turnRight(2)
        return moveForward(times)
    elseif facing == NEGX then
        return moveForward(times)
    elseif facing == POSZ then
        turnRight()
        return moveForward(times)
    elseif facing == NEGZ then
        turnLeft()
        return moveForward(times)
    end
end

-- Function to move the turtle to positive Z direction
local function movePosZ(times)
    if facing == POSX then
        turnRight()
        return moveForward(times)
    elseif facing == NEGX then
        turnRight(2)
        return moveForward(times)
    elseif facing == POSZ then
        return moveForward(times)
    elseif facing == NEGZ then
        turnLeft()
        return moveForward(times)
    end
end

-- Function to move the turtle to negative Z direction
local function moveNegZ(times)
    if facing == POSX then
        turnLeft()
        return moveForward(times)
    elseif facing == NEGX then
        turnRight()
        return moveForward(times)
    elseif facing == POSZ then
        turnRight(2)
        return moveForward(times)
    elseif facing == NEGZ then
        return moveForward(times)
    end
end

-- Function to calibrate the turtle's movements
local function calibrate(initialPosition)
    print("callibrating the position of this turtle")
    -- Attempt to move forward until the turtle returns to the initial position
    while true do
        if turtle.back() then
            local currentPosition = vector.new(gps.locate())
            local directionVector = currentPosition - initialPosition
            if directionVector.x < 0 then
                facing = POSX
            elseif directionVector.x > 0 then
                facing = NEGX
            elseif directionVector.z < 0 then
                facing = POSZ
            elseif directionVector.z > 0 then
                facing = NEGZ
            end
            turtle.forward()

            break
        else
            error("movement is obstructed")
        end
    end
end

-- Function to move to a new target location
local function moveTo(target, position)
    -- Get current location (You need to implement this based on how you track turtle's location)
    -- Subtract current location from target location
    local d = target - position

    -- Move in X direction
    while d.x ~= 0 do
        if d.x > 0 then
            if not movePosX() then
                if not moveUp() then -- If blocked, move up and retry
                    print("The Path is blocked :-/")
                else
                    d.y = d.y - 1
                end
            else
                d.x = d.x - 1
            end
        else
            if not moveNegX() then
                if not moveUp() then -- If blocked, move up and retry
                    print("The Path is blocked :-/")
                else
                    d.y = d.y - 1
                end
            else
                d.x = d.x + 1
            end
        end
    end

    -- Move in Z direction
    while d.z ~= 0 do
        if d.z > 0 then
            if not movePosZ() then
                if not moveUp() then -- If blocked, move up and retry
                    print("The Path is blocked :-/")
                else
                    d.y = d.y - 1
                end
            else
                d.z = d.z - 1
            end
        else
            if not moveNegZ() then
                if not moveUp() then -- If blocked, move up and retry
                    print("The Path is blocked :-/")
                else
                    d.y = d.y - 1
                end
            else
                d.z = d.z + 1
            end
        end
    end

    -- Move in Y direction
    while d.y ~= 0 do
        if d.y > 0 then
            if not moveUp() then
                -- If blocked, try moving down and retry
                if not moveDown() then
                    -- If unable to move down, then something's blocking the way entirely
                    print("Could not reach the target location.")
                    return
                end
            else
                d.y = d.y - 1
            end
        else
            if not moveDown() then
                -- If blocked, try moving up and retry
                if not moveUp() then
                    -- If unable to move up, then something's blocking the way entirely
                    print("Could not reach the target location.")
                    return
                end
            else
                d.y = d.y + 1
            end
        end
    end

    -- -- Relocate turtle to ground level
    -- while not turtle.down() do
    --     -- If unable to move down, something is blocking the way, so keep trying
    -- end
end

function Bresenham3D(x1, y1, z1, x2, y2, z2)
    local ListOfPoints = {}
    table.insert(ListOfPoints, { x1, y1, z1 })
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local dz = math.abs(z2 - z1)
    local xs, ys, zs

    if x2 > x1 then
        xs = 1
    else
        xs = -1
    end

    if y2 > y1 then
        ys = 1
    else
        ys = -1
    end

    if z2 > z1 then
        zs = 1
    else
        zs = -1
    end

    -- Driving axis is X-axis
    if dx >= dy and dx >= dz then
        local p1 = 2 * dy - dx
        local p2 = 2 * dz - dx
        while x1 ~= x2 do
            x1 = x1 + xs
            if p1 >= 0 then
                y1 = y1 + ys
                p1 = p1 - 2 * dx
            end
            if p2 >= 0 then
                z1 = z1 + zs
                p2 = p2 - 2 * dx
            end
            p1 = p1 + 2 * dy
            p2 = p2 + 2 * dz
            table.insert(ListOfPoints, { x1, y1, z1 })
        end

        -- Driving axis is Y-axis
    elseif dy >= dx and dy >= dz then
        local p1 = 2 * dx - dy
        local p2 = 2 * dz - dy
        while y1 ~= y2 do
            y1 = y1 + ys
            if p1 >= 0 then
                x1 = x1 + xs
                p1 = p1 - 2 * dy
            end
            if p2 >= 0 then
                z1 = z1 + zs
                p2 = p2 - 2 * dy
            end
            p1 = p1 + 2 * dx
            p2 = p2 + 2 * dz
            table.insert(ListOfPoints, { x1, y1, z1 })
        end

        -- Driving axis is Z-axis
    else
        local p1 = 2 * dy - dz
        local p2 = 2 * dx - dz
        while z1 ~= z2 do
            z1 = z1 + zs
            if p1 >= 0 then
                y1 = y1 + ys
                p1 = p1 - 2 * dz
            end
            if p2 >= 0 then
                x1 = x1 + xs
                p2 = p2 - 2 * dz
            end
            p1 = p1 + 2 * dy
            p2 = p2 + 2 * dx
            table.insert(ListOfPoints, { x1, y1, z1 })
        end
    end

    return ListOfPoints
end

function main()
    local x1, y1, z1 = gps.locate()
    print("give x")
    local x2 = tonumber(read())
    print("give y")
    local y2 = tonumber(read())
    print("give z")
    local z2 = tonumber(read())
    local ListOfPoints = Bresenham3D(x1, y1, z1, x2, y2, z2)
    local currentPosition = vector.new(x1, y1, z1)
    calibrate(vector.new(x1, y1, z1))
    for i, v in ipairs(ListOfPoints) do
        -- move to next point
        local newPosition = vector.new(v[1], v[2], v[3])
        moveTo(currentPosition)
        currentPosition = newPosition
    end
end

main()
