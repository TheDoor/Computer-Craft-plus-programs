-- Function to wait for a key to contuinue
local function waitForKey()
    while true do
        print("Press 'space' to continue")
        local _, key, _ = os.pullEvent("key")
        if key == keys.space then
            return
        end
    end
end

local configFilename = "cfg.txt"
local lastPositionFilename = "lastPosition.txt"
local minPosition = vector.new(0, 0, 0)
local maxPosition = vector.new(0, 0, 0)
local chestPosition = vector.new(0, 0, 0)
local lastPosition = vector.new(0, 0, 0)

local function parsePositionArray(str)
    local x, y, z = str:match("(%d+),(%d+),(%d+)")
    return tonumber(x), tonumber(y), tonumber(z)
end


-- save config
local function saveConfigToFile()
    local file = fs.open(configFilename, "w") -- Open file in write mode
    file.writeLine("min[" .. minPosition.x .. "," .. minPosition.y .. "," .. minPosition.z .. "]")
    file.writeLine("max[" .. maxPosition.x .. "," .. maxPosition.y .. "," .. maxPosition.z .. "]")
    file.writeLine("chest[" .. chestPosition.x .. "," .. chestPosition.y .. "," .. chestPosition.z .. "]")
    file.close()
end
-- load configurations
local function loadConfigFromFile()
    local file = fs.open(configFilename, "r") -- Open file in read mode
    if not file then
        return nil                            -- Return nil if file does not exist
    end
    for line in file.readLine do
        local key, value = line:match("(%w+)%[(.-)%]")
        if key == "min" then
            minPosition = vector.new(parsePositionArray(value))
        elseif key == "max" then
            maxPosition = vector.new(parsePositionArray(value))
        elseif key == "chest" then
            chestPosition = vector.new(parsePositionArray(value))
        end
    end
    print(chestPosition.x, chestPosition.y, chestPosition.z)
    file.close()
end

-- save to file
local function savePositionToFile()
    local file = fs.open(lastPositionFilename, "w") -- Open file in write mode
    file.writeLine("last_location:[" .. lastPosition.x .. "," .. lastPosition.y .. "," .. lastPosition.z .. "]")
    file.close()
end

--load from file
local function loadLatestPositionFromFile()
    local file = fs.open(lastPositionFilename, "r") -- Open file in read mode
    if not file then
        return nil                                  -- Return nil if file does not exist
    end
    local positionStr = file.readLine()
    file.close()

    local x, y, z = positionStr:match("%[(.-),(.-),(.-)%]")
    lastPosition = vector.new(tonumber(x), tonumber(y), tonumber(z))
    print(lastPosition.x, lastPosition.y, lastPosition.z)
end

local function configureTurtle()
    print("What is the position of the chest?")

    print("What is the X position?")
    chestPosition.x = tonumber(read())
    print("What is the Y position?")
    chestPosition.y = tonumber(read())
    print("What is the Z position?")
    chestPosition.z = tonumber(read())
    print("What is the min position of area?")

    print("What is the X position?")
    minPosition.x = tonumber(read())
    print("What is the Y position?")
    minPosition.y = tonumber(read())
    print("What is the Z position?")
    minPosition.z = tonumber(read())
    print("What is the max position of area?")

    print("What is the X position?")
    maxPosition.x = tonumber(read())
    print("What is the Y position?")
    maxPosition.y = tonumber(read())
    print("What is the Z position?")
    maxPosition.z = tonumber(read())
    saveConfigToFile()
end

--------------
-- movement --
--------------

-- Define constants for cardinal directions
local NEGZ = 0
local POSX = 1
local POSZ = 2
local NEGX = 3 -- Corrected constant name for negative X direction

-- Define global variable for facing direction
local facing = nil

-- update the current position
local function updatePosition()
    lastPosition = vector.new(gps.locate())
    savePositionToFile()
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

-- Function to move the turtle forward
local function moveForward(times)
    times = times or 1
    turtle.dig()
    for _ = 1, times do
        if not turtle.forward() then
            return false -- Return false if movement is obstructed
        end
    end
    return true -- Return true if movement is successful
end

-- Function to move the turtle backward
local function moveBack(times)
    times = times or 1
    for _ = 1, times do
        if not turtle.back() then
            turnRight(2)
            turtle.dig()
            turnLeft(2)
        end
    end
    return true -- Return true if movement is successful
end

-- turtle looks in X axis
local function rotateTowardsX(direction)
    if direction == "positive" then
        while facing ~= 1 do
            turnRight()
        end
    elseif direction == "negative" then
        while facing ~= 3 do
            turnLeft()
        end
    else
        print("Invalid direction")
    end
end

-- turtle looks in Z axis
local function rotateTowardsZ(direction)
    if direction == "positive" then
        while facing ~= 0 do
            turnRight()
        end
    elseif direction == "negative" then
        while facing ~= 2 do
            turnLeft()
        end
    else
        print("Invalid direction")
    end
end

-- Function to move the turtle upward
local function movePosY(times)
    times = times or 1
    for _ = 1, times do
        turtle.digUp()
        turtle.up()
    end
    return true -- Return true if movement is successful
end

-- Function to move the turtle downward
local function moveNegY(times)
    times = times or 1
    for _ = 1, times do
        turtle.digDown()
        turtle.down()
    end
    return true -- Return true if movement is successful
end

-- Function to move the turtle to positive X direction
local function movePosX(times)
    if facing == POSX then
        return moveForward(times)
    elseif facing == NEGX then
        turnRight(2)
        return moveForward(times)
    elseif facing == POSZ then
        turnLeft()
        return moveForward(times)
    elseif facing == NEGZ then
        turnRight()
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
        turnLeft()
        return moveForward(times)
    elseif facing == POSZ then
        return moveForward(times)
    elseif facing == NEGZ then
        turnLeft(2)
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
        if moveBack() then
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
            moveForward()
            break
        else
            error("movement is obstructed")
        end
    end
end

-- Function to move to a new target location
local function moveTo(target, position)
    -- Calculate differences in coordinates
    local delta = target - position

    -- Define movement functions based on direction
    local moveFunctions = {
        [1] = { movePosX, moveNegX }, -- X-axis movement
        [2] = { movePosY, moveNegY }, -- Y-axis movement
        [3] = { movePosZ, moveNegZ }  -- Z-axis movement
    }

    -- Move to the target position
    for _, axis in ipairs({ 1, 2, 3 }) do
        local movement = moveFunctions[axis]
        local direction = delta[axis]

        if direction ~= 0 then
            movement[direction > 0 and 2 or 1](math.abs(direction))
        end
    end
end

local function handleTreasure()
    -- treasure handeling
    -- -- check content of slots
    -- -- if not diamond (minecraft:diamond), redstone(minecraft:redstone), gold (minecraft:raw_gold), zinc (create:raw_zinc), coal (minecraft:coal), emerald (minecraft:emerald), cupper (minecraft:raw_copper)
    -- -- -- drop item
    -- -- if not empty slots
    -- -- -- move to chest and drop items
    -- -- -- -- path find function
    -- -- -- -- drop function
    -- -- -- move back to saved position
    -- -- -- -- move to function
    -- -- -- -- commence dig cycle
end

-- dig cycle
local function dig()
    -- Check if Y layer is even or odd
    local yIsEven = lastPosition.y % 2 == 0

    while lastPosition.y >= minPosition.y and lastPosition.y <= maxPosition.y do
        -- Dig along Z axis
        while lastPosition.z >= minPosition.z and lastPosition.z <= maxPosition.z do
            -- Check if Z column is even or odd
            local zIsEven = lastPosition.z % 2 == 0
            while lastPosition.x >= minPosition.x and lastPosition.x <= maxPosition.x do
                -- Rotate and dig along X axis based on Y and Z parity
                if (yIsEven and zIsEven) or (not yIsEven and not zIsEven) then
                    rotateTowardsX("positive")
                    turtle.dig()
                    movePosX()
                else
                    rotateTowardsX("negative")
                    turtle.dig()
                    moveNegX()
                end

                updatePosition()
                handleTreasure()
            end
            -- Move along Z axis, alternate rotation along X axis
            rotateTowardsZ("positive")
            turtle.dig()
            movePosZ()

            if lastPosition.x <= minPosition.x then
                rotateTowardsX("positive")
                turtle.dig()
                movePosX()
            else
                rotateTowardsX("negative")
                turtle.dig()
                moveNegX()
            end

            updatePosition()
            handleTreasure()
            print("Digging new block")
        end
        -- Move down along Y axis
        turtle.digDown()
        moveNegY()
        updatePosition()
        handleTreasure()
        print("starting new row")
    end
    print("starting new layer")
end

-- update screen
-- -- loading bar, calculate the amount of points to dig and amount digged.

local function startup()
    -- locating turtle
    print("Getting curren position ...")
    local currentPosition = vector.new(gps.locate())
    if currentPosition == nil then
        term.clear()
        print("Please check your gps system or the turtle's modem")
        waitForKey()
        error("Please check your gps system or the turtle's modem")
    end
    waitForKey()
    print("Calibrating the turtle ...")
    -- Calibrating the orientation of the turtle
    calibrate(currentPosition)
    waitForKey()
    -- Checking if turtle is already configuered
    if fs.exists(configFilename) then
        print("Loading configuration ...")
    else
        configureTurtle()
        lastPosition = minPosition
        savePositionToFile()
    end
    loadConfigFromFile()
    loadLatestPositionFromFile()
    print("moving to last position")
    waitForKey()
    moveTo(lastPosition, currentPosition)
end

local function main()
    print("Starting up the program...")
    startup()
    print("Start to dig...")
    dig()
end

while true do
    main()
end
