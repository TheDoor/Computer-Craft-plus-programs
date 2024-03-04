-- Define constants for cardinal directions
local NORTH = 0 -- -Z
local EAST = 1  -- +X
local SOUTH = 2 -- +Z
local WEST = 3  -- -X

-- Define global variable for facing direction
local facingDirection = nil

-- Function to stringify a table
local function tableToString(tbl)
    local result = "{"
    local isFirst = true

    for k, v in pairs(tbl) do
        if not isFirst then
            result = result .. ", "
        end

        if type(v) == "table" then
            result = result .. tableToString(v)
        else
            result = result .. tostring(v)
        end

        isFirst = false
    end

    result = result .. "}"
    return result
end

-- Function to compare vectors
local function compareVectors(a, b)
    if a.x ~= b.x then
        return a.x < b.x
    elseif a.y ~= b.y then
        return a.y < b.y
    else
        return a.z < b.z
    end
end

-- Function to find the highest X, Z, and Y values among a list of position tables
local function findHighestValues(positionList)
    local highestX = -math.huge
    local highestZ = -math.huge
    local highestY = -math.huge

    for _, position in pairs(positionList) do
        if position.x > highestX then
            highestX = position.x
        end
        if position.z > highestZ then
            highestZ = position.z
        end
        if position.y > highestY then
            highestY = position.y
        end
    end

    return highestX, highestY, highestZ
end

-- Function to find the lowest X, Z, and Y values among a list of position tables
local function findLowestValues(positionList)
    local lowestX = math.huge
    local lowestZ = math.huge
    local lowestY = math.huge

    for _, position in pairs(positionList) do
        if position.x < lowestX then
            lowestX = position.x
        end
        if position.z < lowestZ then
            lowestZ = position.z
        end
        if position.y < lowestY then
            lowestY = position.y
        end
    end

    return lowestX, lowestY, lowestZ
end

-- Function to send messages
local function sendMessages(message)
    rednet.broadcast(message, "BorInc")
end

-- Function to wait for a start key
local function waitForKey()
    while true do
        local x, y = term.getSize()
        -- term.clear()
        --  term.setCursorPos(1, y)
        print("Press 'space' to continue")
        local event, key, isHeld = os.pullEvent("key")
        if key == keys.space then
            return
        end
    end
end

-- Function to wait for a start key
local function waitStartKey()
    while true do
        local x, y = term.getSize()
        -- term.clear()
        --  term.setCursorPos(1, y)
        print("Press 'space' when all turtles are in position")
        local event, key, isHeld = os.pullEvent("key")
        if key == keys.space then
            -- term.clear()
            --  term.setCursorPos(1, y)
            print("Starting...")
            sendMessages("calibrate")
            return
        end
    end
end

-- Function to connect to Rednet and handle messages
local function connectRednet(side)
    rednet.open(side)
end

-- Function to wait for calibrate signal
local function waitForCalibrate()
    while true do
        local _, message, _ = rednet.receive("BorInc")
        if message == "calibrate" then
            print("Start calibrating turtles")
            return
        end
    end
end

-- Function to calibrate the turtle's movements
local function calibrate(initialPosition)
    -- print("Calibrating the orientation of this turtle...")

    while true do
        if turtle.back() then
            local currentPosition = vector.new(gps.locate())
            local directionVector = currentPosition - initialPosition

            if directionVector.x < 0 then
                facingDirection = EAST
            elseif directionVector.x > 0 then
                facingDirection = WEST
            elseif directionVector.z < 0 then
                facingDirection = SOUTH
            elseif directionVector.z > 0 then
                facingDirection = NORTH
            end

            turtle.forward()
            break
        else
            error("Please remove all blocks behind this turtle")
        end
    end
end

-- Function to retrieve the value associated with the first key in a table
local function getFirstValue(tableWithNumbers)
    for id, value in pairs(tableWithNumbers) do
        return value -- Return the value associated with the first key encountered
    end
end

-- Function to compare orientations
local function compareOrientations(orientations)
    local referenceOrientation = getFirstValue(orientations)
    print("the referenceOrientation is: " .. referenceOrientation)

    for _, orientation in ipairs(orientations) do
        if orientation ~= referenceOrientation then
            return false
        end
    end

    return true, referenceOrientation
end

local function checkRectForm(positionList, orientation)
    if not positionList or orientation == nil then
        error("we are missing avalue for the orientation or position")
    end
    local highestX, highestY, highestZ = findHighestValues(positionList)
    local lowestX, lowestY, lowestZ = findLowestValues(positionList)

    local highestHorizontal, lowestHorizontal, highestVertical, lowestVertical, constant

    if orientation == 0 or orientation == 2 then
        highestHorizontal, lowestHorizontal = highestX, lowestX
        highestVertical, lowestVertical = highestY, lowestY
        constant = highestZ
    elseif orientation == 1 or orientation == 3 then
        highestHorizontal, lowestHorizontal = highestZ, lowestZ
        highestVertical, lowestVertical = highestY, lowestY
        constant = highestX
    else
        error("The orientaion is not a correct value")
    end

    -- print("Position list size:", #positionList)

    -- -- Print the values used for calculation
    -- print("highestHorizontal:", highestHorizontal)
    -- print("lowestHorizontal:", lowestHorizontal)
    -- print("highestVertical:", highestVertical)
    -- print("lowestVertical:", lowestVertical)
    -- print("constant:", constant)
    -- print("Orientation:", orientation)


    print("the rectangle is " ..
        math.abs(highestHorizontal - lowestHorizontal) + 1 ..
        " blocks wide and " .. math.abs(highestVertical - lowestVertical) + 1 .. " blocks tall")


    for horizontal = lowestHorizontal, highestHorizontal do
        for vertical = lowestVertical, highestVertical do
            local found = false
            for positionListKey, realPos in pairs(positionList) do
                if orientation == 0 or orientation == 2 then
                    if horizontal == realPos.z and vertical == realPos.y and constant == realPos.x then
                        positionList[positionListKey] = nil
                        found = true
                        print("we found a match for: " .. horizontal, vertical, constant)
                        break
                    end
                elseif orientation == 1 or orientation == 3 then
                    if horizontal == realPos.x and vertical == realPos.y and constant == realPos.z then
                        positionList[positionListKey] = nil
                        print("we found a match for: " .. horizontal, vertical, constant)
                        found = true
                        break
                    end
                end
            end
            if not found then
                error("Nor a rectangle nor square")
            end
        end
    end
    waitForKey()
    return next(positionList) == nil,
        { min = { h = lowestHorizontal, v = lowestVertical }, max = { h = highestHorizontal, v = highestVertical } } -- All generated positions were found in real positions
end

-- Function to check if turtles are in a rectangle formation
local function checkIfArea(OrientationAndPositionList)
    local orientations = {}
    local positions = {}

    -- Iterate through the OrientationAndPositionList table
    for id, data in pairs(OrientationAndPositionList) do
        orientations[id] = data.orientation
        positions[id] = data.position
        print(data.position.x, data.position.y, data.position.z, data.orientation)
    end
    waitForKey()

    print("check if the orientation is the same")
    local orientationEqual, mainOrientation = compareOrientations(orientations)

    print("check if the area is a complete rectangle" .. mainOrientation)
    local FormationRect, minMax = checkRectForm(positions, mainOrientation)

    if FormationRect and orientationEqual then
        return true, minMax, mainOrientation
    end
    error("The turtles are not in a rectangular formation, please fix this issue")
end

local function turtleArea()
    local startTime = os.clock()
    local duration = 3 -- Run for 5 seconds
    local endTime = startTime + duration
    local OrientationAndPositionList = {}
    local x, y = term.getSize()
    while os.clock() <= endTime do
        -- term.clear()
        --  term.setCursorPos(1, y)
        print("Waiting " .. math.floor(endTime - os.clock()) .. "s for all turtles to send there location")
        local senderId, message = rednet.receive("BorInc", 0) -- Use 0 as the timeout for non-blocking receive
        if senderId then
            OrientationAndPositionList[senderId] = message
        end
        if os.clock() > endTime then
            break -- Break out of the loop if time exceeds duration
        end
    end

    -- After the specified duration, check if it's an area
    -- term.clear()
    --  term.setCursorPos(1, y)
    print("Checking if turtles are in a rectangular formation")
    return checkIfArea(OrientationAndPositionList)
end

local function inputDistance(minMax, mainOrientation)
    -- term.clear()
    --  term.setCursorPos(1, y)
    print("How far do you want to dig?")
    local message = read()
    sendMessages({ command = "digydigyhole", distance = message, minMax = minMax, mainOrientation = mainOrientation })
end

-- Wait for a signal from the pocket computer with the distance
local function waitForGoSignal()
    print("Waiting for go signal...")
    while true do
        local _, message, _ = rednet.receive("BorInc")
        if message.command == "digydigyhole" then
            break
        end
    end
    local distance = tonumber(message.distance)
    if distance and distance <= 160 then
        print("Received go signal! Starting mining operation for " .. distance .. " blocks.")
        return message
    else
        print("Received invalid distance. Waiting again...")
        waitForGoSignal() -- Wait again if the distance is invalid
    end
end

local function checkTunnelFormation(facing, minMax, position)
    local pair = {}      -- Pair format: {horizontal, vertical} where middle = 0, left is 1, right is 2. Middle is 0, top is 1, bottom is 2.
    local horizontal = 0 -- Default horizontal value (middle)
    local vertical = 0   -- Default vertical value (middle)

    if position.y == minMax.min.v then
        vertical = 2
    elseif position.y == minMax.max.y then
        vertical = 1
    else
        vertical = 0
    end

    if facing == 0 then
        if position.x == minMax.min.v then
            horizontal = 1
        elseif position.x == minMax.max.y then
            horizontal = 2
        else
            horizontal = 0
        end
    elseif facing == 1 then
        if position.z == minMax.min.v then
            horizontal = 1
        elseif position.z == minMax.max.y then
            horizontal = 2
        else
            horizontal = 0
        end
    elseif facing == 2 then
        if position.x == minMax.max.v then
            horizontal = 1
        elseif position.x == minMax.min.y then
            horizontal = 2
        else
            horizontal = 0
        end
    elseif facing == 3 then
        if position.z == minMax.max.v then
            horizontal = 1
        elseif position.z == minMax.min.y then
            horizontal = 2
        else
            horizontal = 0
        end
    else
        error("something went wrong deciding position of turtle in tunnel formation")
    end

    -- Assign values to pair
    pair = { horizontal, vertical }

    return pair
end

local function calculateDestinationPostion(mainOrientation, position, distance)
    if mainOrientation == 0 then
        return position + vector.new(0, 0, -distance)
    elseif mainOrientation == 1 then
        return position + vector.new(distance, 0, 0)
    elseif mainOrientation == 2 then
        return position + vector.new(0, 0, distance)
    elseif mainOrientation == 3 then
        return position + vector.new(-distance, 0, 0)
    else
        error("the orientation value is wrong")
    end
end

local function digTunnel(distance, minMax, mainOrientation, position)
    -- check current position and calculate the end position based on the message.distance and facing value
    local pair = checkTunnelFormation(mainOrientation, minMax, position)
    local destinationPosition = calculateDestinationPostion(mainOrientation, position, distance)
    if pair == { h = 0, v = 0 } then
        os.setComputerLabel("Middle_Miner")
        print("This is a middle miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    elseif pair == { h = 1, v = 0 } then
        os.setComputerLabel("Left_Middle_Miner")
        print("This is a left middle miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    elseif pair == { h = 2, v = 0 } then
        os.setComputerLabel("Right_Middle_Miner")
        print("This is a right middle miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    elseif pair == { h = 0, v = 1 } then
        os.setComputerLabel("Top_Miner")
        print("This is a top miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    elseif pair == { h = 1, v = 1 } then
        os.setComputerLabel("Left_Top_Miner")
        print("This is a left top miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    elseif pair == { h = 2, v = 1 } then
        os.setComputerLabel("Right_Top_Miner")
        print("This is a right top miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    elseif pair == { h = 0, v = 2 } then
        os.setComputerLabel("Bottom")
        print("This is a Bottom miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    elseif pair == { h = 1, v = 2 } then
        os.setComputerLabel("Bottom")
        print("This is a left Bottom miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    elseif pair == { h = 2, v = 2 } then
        os.setComputerLabel("Bottom")
        print("This is a right Bottom miner")
        if vector.new(gps.location) ~= destinationPosition then
            turtle.dig()
            turtle.forward()
        end
    else
        error("something went wrong assigning the position in the tunnel formation")
    end
end
-- Main function for running turtle script
local function runTurtleScript()
    -- term.clear()
    --  term.setCursorPos(1, 1)
    connectRednet("left")
    waitForCalibrate()
    local currentLocation = vector.new(gps.locate());

    if currentLocation == nil then
        error("No GPS connection, please check if your system is set up correctly.")
    end

    calibrate(currentLocation)
    print("sending message")
    sendMessages({ orientation = facingDirection, position = currentLocation })
    local message = waitForGoSignal()
    digTunnel(message.distance, message.minMax, message.mainOrientation, currentLocation)
end

-- Main function for running pocket computer script
local function runPadScript()
    -- term.clear()
    --  term.setCursorPos(1, 1)
    connectRednet("back")
    waitStartKey()
    print("Detecting area")
    local isArea, minMax, mainOrientation = turtleArea()
    if not isArea then
        return
    end
    print("Waiting for input")
    inputDistance(minMax, mainOrientation)
    -- Implement the rest of the functionality for the pocket computer script here
end

-- Function to determine the type of device
local function getDeviceType()
    if turtle then
        return "turtle"
    elseif pocket then
        return "pocket"
    elseif commands then
        return "command_computer"
    else
        return "computer"
    end
end

-- Main function
local function main()
    local deviceType = getDeviceType()

    if deviceType == "turtle" then
        -- print("This is a turtle")
        while true do
            runTurtleScript()
        end
    elseif deviceType == "computer" or deviceType == "command_computer" then
        -- print("This is a computer. It is recommended to use a pocket computer.")
        while true do
            runPadScript()
        end
    elseif deviceType == "pocket" then
        -- print("This is a pocket computer")
        while true do
            runPadScript()
        end
    end
end

-- Run the main function
main()
