---------------------------
-- Helper math functions --
---------------------------

-- Define a function to calculate the magnitude of a 3D vector
local function magnitude(vector)
    return math.floor(math.sqrt(vector.x ^ 2 + vector.y ^ 2 + vector.z ^ 2))
end



------------------------
-- Movement functions --
------------------------

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
local function calibrate()
    print("callibrating the position of this turtle")
    local initialPosition = vector.new(gps.locate())

    -- Attempt to move forward until the turtle returns to the initial position
    while true do
        if turtle.forward() then
            local currentPosition = vector.new(gps.locate())
            local deltaX = currentPosition.x - initialPosition.x
            local deltaZ = currentPosition.z - initialPosition.z
            if deltaX > 0 then
                facing = POSX
            elseif deltaX < 0 then
                facing = NEGX
            elseif deltaZ > 0 then
                facing = POSZ
            elseif deltaZ < 0 then
                facing = NEGZ
            end

            turtle.back()

            -- Rotate back to the initial orientation

            break
        else
            turtle.turnLeft()
        end
    end
end

-- Function to move to a new target location
local function moveTo(target, position)
    -- give some feeedback about the commencing Journey:
    local directionVector = target - position
    local distance = magnitude(directionVector)
    print("You are " .. distance .. " blocks away from the start location. Starting to move to the starting location.")
    -- Get current location (You need to implement this based on how you track turtle's location)
    -- Subtract current location from target location
    local dx = target.x - position.x
    local dy = target.y - position.y
    local dz = target.z - position.z

    -- Move in X direction
    while dx ~= 0 do
        if dx > 0 then
            if not movePosX() then
                turtle.up() -- If blocked, move up and retry
            else
                dx = dx - 1
            end
        else
            if not moveNegX() then
                turtle.up() -- If blocked, move up and retry
            else
                dx = dx + 1
            end
        end
    end

    -- Move in Z direction
    while dz ~= 0 do
        if dz > 0 then
            if not movePosZ() then
                turtle.up() -- If blocked, move up and retry
            else
                dz = dz - 1
            end
        else
            if not moveNegZ() then
                turtle.up() -- If blocked, move up and retry
            else
                dz = dz + 1
            end
        end
    end

    -- Move in Y direction
    while dy ~= 0 do
        if dy > 0 then
            if not moveUp() then
                -- If blocked, try moving down and retry
                if not moveDown() then
                    -- If unable to move down, then something's blocking the way entirely
                    print("Could not reach the target location.")
                    return
                end
            else
                dy = dy - 1
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
                dy = dy + 1
            end
        end
    end

    -- Relocate turtle to ground level
    while not turtle.down() do
        -- If unable to move down, something is blocking the way, so keep trying
    end

    print("At start location")
end


-----------------
-- Helper file --
-----------------
local function saveStartPosition(startPosition)
    local file = fs.open("start_position.txt", "w") -- Open file in write mode
    file.writeLine(startPosition.x .. "," .. startPosition.y .. "," .. startPosition.z)
    file.close()

    return vector.new(startPosition.x, startPosition.y, startPosition.z)
end

-- Function to retrieve the starting position from the file
local function loadStartPosition()
    local file = fs.open("start_position.txt", "r") -- Open file in read mode
    if not file then
        return nil                                  -- Return nil if file does not exist
    end
    local positionStr = file.readLine()
    file.close()

    local parts = {}
    for part in string.gmatch(positionStr, "[^,]+") do
        table.insert(parts, tonumber(part))
    end

    return vector.new(parts[1], parts[2], parts[3])
end

-- Function to start the sequence
local function start()
    local startPosition
    print("Startup sequence initiated")
    if fs.exists("start_position.txt") then
        startPosition = loadStartPosition()
        print("A start location was found, returning to this position")
    else
        print("No previous start location found, initiating start position")
        local gpsPosition = { gps.locate() }
        if gpsPosition == nil then
            error("Error: Cannot get GPS position.")
        else
            startPosition = saveStartPosition(vector.new(gpsPosition[1], gpsPosition[2], gpsPosition[3]))
        end
    end
    return startPosition
end

-- Function for the main logic
local function main()
    -- print("Running ...")
end

-- Loop to execute the main logic

local startPosition

startPosition = start()
-- Calibrate the turtle's movements
calibrate()
local currentPosition = vector.new(gps.locate())
if startPosition == currentPosition then
    print("You are at the starting location.")
else
    moveTo(startPosition, currentPosition)
end

while true do
    main()
end
