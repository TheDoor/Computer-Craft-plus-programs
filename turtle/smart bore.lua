-- local receivedMessagesList = {}

-- Define constants for cardinal directions
local NEGZ = 0
local POSX = 1
local POSZ = 2
local NEGX = 3 -- Corrected constant name for negative X direction

-- Define global variable for facing direction
local facing = nil


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

-- Define a custom comparison function
local function compareVectors(a, b)
    -- Compare based on the x component first
    if a.x ~= b.x then
        return a.x < b.x
    end
    -- If x components are equal, compare based on y component
    if a.y ~= b.y then
        return a.y < b.y
    end
    -- If x and y components are equal, compare based on z component
    return a.z < b.z
end

local function compareOrientations(tableOfTables)
    -- probleem is de tabel zelf, deze wordt fout aangemaakt
    if #tableOfTables <= 1 then
        -- If there is only one or no elements, orientations are considered equal

        -- Get the orientation of the first inner table
        local referenceID = next(tableOfTables) -- Get the first key and its value
        local referenceOrientation = tableOfTables[referenceID].orientation
        print("1 turtle is facing the same direction" .. referenceOrientation)
        return true
    end

    -- Get the orientation of the first inner table
    local referenceID = next(tableOfTables) -- Get the first key and its value
    local referenceOrientation = tableOfTables[referenceID].orientation

    -- Compare the orientation of each inner table with the reference orientation
    for id in pairs(tableOfTables) do
        print(tableOfTables[id].orientation)
        if tableOfTables[id].orientation ~= referenceOrientation then
            -- If any orientation is different, print a message and return false
            print("Not all turtles are facing the same direction")
            return false
        end
    end

    -- If all orientations are the same, print a message and return true
    print("All turtles are facing the same direction")
    return true
end

-- Screen update function
local function listCoordinates(list, orientation)
    local x, y = term.getSize()
    term.clear()
    term.setCursorPos(1, 1)
    for i, receivedMessage in pairs(list) do
        if receivedMessage ~= nil then
            print("turtle[" .. i .. "]: " .. tableToString(receivedMessage))
        end
    end
    term.setCursorPos(1, y)
    -- Check the boolean value and print messages accordingly
    if orientation then
        print("all turtles are facing the same direction")
    else
        print("all turtles are NOT facing the same direction")
    end
end

-- Function to receive messages and print them
local function receiveMessages()
    while true do
        local senderId, message, protocol = rednet.receive("BorInc")
        return message
    end
end

-- Function to send messages
local function sendMessages(message)
    rednet.broadcast(message, "BorInc")
end

-- Function to send messages
local function waitAndsendMessages()
    while true do
        local message = read()
        rednet.broadcast(message, "BorInc")
    end
end

-- check for start key "space"
local function waitStartKey()
    while true do
        local x, y = term.getSize()
        term.clear()
        term.setCursorPos(1, y)
        print("press 'space' when all turtles are in position")
        local event, key, isHeld = os.pullEvent("key")
        if key == keys.space then
            term.clear()
            term.setCursorPos(1, y)
            print("starting ...")
            sendMessages("calibrate")
            return
        end
    end
end
-- Function to connect to Rednet and handle messages
local function connectRednet(side)
    rednet.open(side)
end

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
    print("callibrating the orientation of this turtle")
    -- Attempt to move back until the turtle returns to the initial position
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
            error("Please remove all blocks behind this turtle")
        end
    end
end

--CHeck if turtles are in a rectangle formation
local function checkIfArea(positionList)
    local orientation = compareOrientations(positionList)
    -- print(tableToString(positionList))
    -- listCoordinates(positionList, orientation)
    return false
end

-- Wait for all turtles to send message
local function turtleArea()
    -- Example condition
    local isArea = false
    local positionList = {}

    while not isArea do
        local senderId, message, protocol = rednet.receive("BorInc")
        positionList[senderId] = message
        isArea = checkIfArea(positionList)
    end
end

-- Run this program in two modes: one for the pocket computer to send signals to the turtle, the other is the mode for the turtles
local function runTurtleScript()
    -- make a rednet connection
    connectRednet("left")
    -- wait for calibrate signal send via a pocket computer
    waitForCalibrate()
    -- start callibrating process:
    -- do location
    local currentLocation = vector.new(gps.locate());
    if currentLocation == nil then
        error("No gps connection, please check of your system is setup correct.")
    end
    -- find orientation by moving backwards
    calibrate(currentLocation)
    -- send location, orientation and ID and recieve all other messages
    sendMessages({ orientation = facing, position = currentLocation })
end

-- Run this program in two modes: one for the pocket computer to send signals to the turtle, the other is the mode for the turtles
local function runPadScript()
    connectRednet("back")
    waitStartKey()
    turtleArea()
    -- save all recieved message in a table and sort them based on the coordinates
    -- table.sort(vectors, compareVectors)
    -- check if orientation is the same
    -- check the X and Z coordinates and look for the group that has the same value and check if that is correct with the orientation.
    -- Check if turtles are setup correctly
    -- sort the table of coordiantes form largest to smallest X or Z with Y secondary,
    --Take the largest X or Z and the smallest do the same for Y
    -- Make a for loop from smallest to large X or Z and in that loop make one for Y
    -- Check if all generated coordiantes are in the table
    -- exit with error if not
    -- contuniue if OK

    -- Assign every turtle a correct mining mode
    -- if largest turtle has largest X or Z then is left or right depending on orientation
    -- send number for mining mode
    -- if largest turtle has smallest X or Z then is left or right depending on orientation
    -- if largest turtle has largest Y value then is top
    -- if largest turtle has smallest Y value then is bottom
    -- if large X and large Y is corner
    -- ...
    -- if niether it is in the middle

    -- print me a text that says how manu turtle there are and the dimensions of the area they cover. Tell me what way they are facing +X, -X +Z -Z
end

-- Run this program in two modes: one for the pocket computer to send signals to the turtle, the other is the mode for the turtles
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

local function main()
    local dt = getDeviceType()
    if dt == "turtle" then
        print("This is a turtle")
        runTurtleScript()
    elseif dt == "computer" or dt == "command_computer" then
        print("This is a computer, it is recommended to use a pocket computer")
        runPadScript()
    elseif dt == "pocket" then
        print("This is a pocket computer")
        runPadScript()
    end
end


main()
