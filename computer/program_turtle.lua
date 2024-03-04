-- Detect Turtle next to the Computer
local turtle_side = "right" -- Change this to the side where the Turtle is connected
if peripheral.isPresent(turtle_side) and peripheral.getType(turtle_side) == "turtle" then
    print("Turtle detected on the right side.")
else
    print("No Turtle detected on the right side.")
    return -- Exit the program if no Turtle is detected
end

-- Configure the Turtle
rednet.open(turtle_side) -- Open the modem on the side where the Turtle is connected

-- Send commands to the Turtle
rednet.send(turtle_id, "forward") -- Send command to move the Turtle forward
rednet.send(turtle_id, "dig")     -- Send command to make the Turtle dig
rednet.send(turtle_id, "place")   -- Send command to make the Turtle place a block

-- Close the rednet connection
rednet.close(turtle_side)
