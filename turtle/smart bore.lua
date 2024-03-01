local receivedMessagesList = {}

-- Screen update function
local function updateScreen()
    local x, y = term.getSize()
    term.clear()
    term.setCursorPos(1, 1)
    for i, receivedMessage in pairs(receivedMessagesList) do
        if receivedMessage ~= nil then
            print("[" .. i .. "]: " .. receivedMessage)
        end
    end
    term.setCursorPos(1, y - 2)
    term.clearLine()
    print("Your message:")
    term.setCursorPos(1, y - 1)
    term.clearLine()
    term.setCursorPos(1, y)
    term.clearLine()
end

-- Function to receive messages and print them
local function receiveMessages()
    while true do
        local senderId, message, protocol = rednet.receive("BorInc")
        -- Update receivedMessages table
        receivedMessagesList[senderId] = message
        updateScreen();
    end
end

-- Function to send messages
local function sendMessages()
    while true do
        local message = read()
        rednet.broadcast(message, "BorInc")
        updateScreen()
    end
end

-- Function to connect to Rednet and handle messages
local function connectRednet(side)
    rednet.open(side)
end

-- Run this program in two modes: one for the pocket computer to send signals to the turtle, the other is the mode for the turtles
local function runTurtleScript()
    -- make a rednet connection
    connectRednet("left")
    updateScreen()
    parallel.waitForAny(receiveMessages, sendMessages)
    -- wait for calibrate signal send via a pocket computer
    -- start callibrating process:
    -- do location
    -- find orientation by moving backwards

    -- send location, orientatio and ID and recieve all other messages
    -- save all recieved message in a table and sort them based on the coordinates

    -- check if orientation is the same
    -- check the X and Z coordinates and look for the group that has the same value and check if that is correct with the orientation.
    -- position with largest Y and (X or Z depending on orientation) - the lowest coordinate
    -- calculate the difference between these and check the area of the field by multiplying the Y difference and the X or Z difference
    -- check if the area (in blocks) corresponds with the amount of turtles that send a message - one

    -- print me a text that says how manu turtle there are and the dimensions of the area they cover. Tell me what way they are facing +X, -X +Z -Z
    return
end

-- Run this program in two modes: one for the pocket computer to send signals to the turtle, the other is the mode for the turtles
local function runPadScript()
    connectRednet("back")
    updateScreen()
    parallel.waitForAny(receiveMessages, sendMessages)
    return
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

getDeviceType()
