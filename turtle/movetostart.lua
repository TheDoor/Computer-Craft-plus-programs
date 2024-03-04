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
local function calibrate(initialPosition)
    print("callibrating the position of this turtle")
    -- Attempt to move forward until the turtle returns to the initial position
    while true do
        if turtle.forward() then
            local currentPosition = vector.new(gps.locate())
            local directionVector = currentPosition - initialPosition
            if directionVector.x > 0 then
                facing = POSX
            elseif directionVector.x < 0 then
                facing = NEGX
            elseif directionVector.z > 0 then
                facing = POSZ
            elseif directionVector.z < 0 then
                facing = NEGZ
            end

            turtle.back()

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

    print("At start location")
end

-----------------
-- Helper file --
-----------------
local function saveOriginPosition(originPosition)
    local file = fs.open("start_position.txt", "w") -- Open file in write mode
    file.writeLine(originPosition.x .. "," .. originPosition.y .. "," .. originPosition.z)
    file.close()

    return vector.new(originPosition.x, originPosition.y, originPosition.z)
end

-- Function to retrieve the starting position from the file
local function loadOriginPosition()
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
local function startSequence(currentPosition)
    print("Startup sequence initiated ...")
    if fs.exists("start_position.txt") then
        print("A start location was found")
        return loadOriginPosition()
    else
        print("No previous start location found")
        if currentPosition == nil then
            error("Error: Cannot get GPS position.")
            return false
        else
            return saveOriginPosition(vector.new(currentPosition.x, currentPosition.y, currentPosition.z)), false
        end
    end
end

-- Function for the main logic
local function main()
    print("we are done for now")
end

-- Loop to execute the main logic
local currentPosition = vector.new(gps.locate())
local originPosition = startSequence(currentPosition)
if not originPosition then
    print("Error: Exiting program ...")
    return -- Exit the program if startSequence failed
end
-- Calibrate the turtle's orientation
calibrate(currentPosition)
if originPosition == currentPosition then
    print("You are at the starting location.")
else
    moveTo(originPosition, currentPosition)
end

-- while true do
main()
-- end
