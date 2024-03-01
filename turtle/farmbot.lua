-- main --
-- check current position and calibrate orientation
-- check if located on start block = chest -- the chest should be placed in the left down cornor
-- check if seeds and hoe in correct slots
-- start moving forward and harvasting if the crop is mature + planting if harvested do this for a 9*9 area
-- if slots full go to start position and dump everyting except max one stack of seeds in chest down below
-- helper varables --
local farmOriginFilename = "farmOrigin.txt"


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


-----------------
-- Helper file --
-----------------
local function saveOriginPosition(originPosition, orientation)
    local file = fs.open(farmOriginFilename, "w") -- Open file in write mode
    file.writeLine(originPosition.x .. "," .. originPosition.y .. "," .. originPosition.z .. "," .. orientation)
    file.close()

    return vector.new(originPosition.x, originPosition.y, originPosition.z), orientation
end

-- Function to retrieve the starting position from the file
local function loadOriginPosition()
    local file = fs.open(farmOriginFilename, "r") -- Open file in read mode
    if not file then
        return nil                                -- Return nil if file does not exist
    end
    local positionStr = file.readLine()
    file.close()

    local parts = {}
    for part in string.gmatch(positionStr, "[^,]+") do
        table.insert(parts, tonumber(part))
    end

    return vector.new(parts[1], parts[2], parts[3]), parts[4]
end


----------------------
-- startup sequence --
----------------------
local function startSequence(currentPosition)
    print("Startup sequence initiated ...")
    local _, blockDown = turtle.inspectDown()
    if fs.exists(farmOriginFilename) then
        print("A farm origin was found")
        return loadOriginPosition()
    else
        print("No previous farm originfound")
        if currentPosition == nil then
            error("Error: Cannot get GPS position.")
            return false
        elseif blockDown.name ~= "minecraft:chest" then
            print(
            "Place a chest in the left bottom corner of the 9*9 farm and place the turtle facing the top of the farm.")
        else
            return saveOriginPosition(currentPosition, facing), false
        end
    end
end


----------------
-- main  loop --
----------------
local function main()
    print("we are done for now")
end


------------------
-- default loop --
------------------

local currentPosition = vector.new(gps.locate())
-- Calibrate the turtle's orientation
calibrate(currentPosition)

local farmOrigin = startSequence(currentPosition)
if not farmOrigin then
    print("Error: Exiting program ...")
    return -- Exit the program if startSequence failed
end

-- while true do
main()
-- end
