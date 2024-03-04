local arg = { ... }


local function toFirstSlot()
    turtle.drop()
    for i = 2, 16, 1 do
        turtle.select(i)
        if turtle.transferTo(1) then
            turtle.select(1)
            print("Selecting new buildingblock")
            return true
        end
    end
    return false
end

-- Wait for a signal from the pocket computer with the distance
function waitForGoSignal()
    print("Waiting for go signal...")
    local _, message = rednet.receive()
    local distance = tonumber(message)
    if distance then
        print("Received go signal! Starting mining operation for " .. distance .. " blocks.")
        return distance
    else
        print("Received invalid distance. Waiting again...")
        waitForGoSignal() -- Wait again if the distance is invalid
    end
end

local d = 0

-- Import the Rednet API
rednet.open("right") -- Open the modem on the correct side
while true do
    if arg[1] == nill then
        print("Please fill in the required mode for the turtle in the first arg")
        return
    else
        d = waitForGoSignal()
        if tonumber(d) >= 160 then
            print("the distance is too far")
            return
        end
    end

    turtle.select(1)
    if tonumber(arg[1]) == 1 then
        os.setComputerLabel("UpLeft")
        print("this is the upper left turtle")
        for i = 1, d, 1 do
            turtle.dig()
            if turtle.placeUp() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        return
                    end
                end
            end
            turtle.turnLeft()
            if turtle.place() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        turtle.turnRight()
                        return
                    end
                end
            end
            turtle.turnRight()
            turtle.forward()
        end
    elseif tonumber(arg[1]) == 2 then
        os.setComputerLabel("UpMiddle")
        print("This is the upper middle turtle")
        for i = 1, d, 1 do
            turtle.dig()
            if turtle.placeUp() == false then
                print("Something went wrong while placing a block on top")
                if turtle.getItemCount() == 0 then
                    print("No blocks in first slot")
                    if toFirstSlot() == false then
                        return
                    end
                end
            end
            turtle.forward()
        end
    elseif tonumber(arg[1]) == 3 then
        os.setComputerLabel("UpRight")
        print("This is the upper right turtle")
        for i = 1, d, 1 do
            turtle.dig()
            if turtle.placeUp() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        return
                    end
                end
            end
            turtle.turnRight()
            if turtle.place() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        turtle.turnLeft()
                        return
                    end
                end
            end
            turtle.turnLeft()
            turtle.forward()
        end
    elseif tonumber(arg[1]) == 4 then
        os.setComputerLabel("MiddleLeft")
        print("This is the middle left turtle")
        for i = 1, d, 1 do
            turtle.dig()
            turtle.turnLeft()
            if turtle.place() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        turtle.turnRight()
                        return
                    end
                end
            end
            turtle.turnRight()
            turtle.forward()
        end
    elseif tonumber(arg[1]) == 5 then
        os.setComputerLabel("MiddleMiddle")
        print("This is the middle middle turtle")
        for i = 1, d, 1 do
            turtle.dig()
            turtle.forward()
        end
    elseif tonumber(arg[1]) == 6 then
        os.setComputerLabel("MiddleRight")
        print("This is the middle right turtle")
        for i = 1, d, 1 do
            turtle.dig()
            turtle.turnRight()
            if turtle.place() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        turtle.turnLeft()
                        return
                    end
                end
            end
            turtle.turnLeft()
            turtle.forward()
        end
    elseif tonumber(arg[1]) == 7 then
        os.setComputerLabel("BotomLeft")
        print("This is the bottom left turtle")
        for i = 1, d, 1 do
            turtle.dig()
            if turtle.placeDown() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        return
                    end
                end
            end
            turtle.turnLeft()
            if turtle.place() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        turtle.turnRight()
                        return
                    end
                end
            end
            turtle.turnRight()
            turtle.forward()
        end
    elseif tonumber(arg[1]) == 8 then
        os.setComputerLabel("BottomMiddle")
        print("This is the bottom middle turtle")
        for i = 1, d, 1 do
            turtle.dig()
            if turtle.placeDown() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        return
                    end
                end
            end
            turtle.forward()
        end
    elseif tonumber(arg[1]) == 9 then
        os.setComputerLabel("BottomRight")
        print("This is the bottom right turtle")
        for i = 1, d, 1 do
            turtle.dig()
            if turtle.placeDown() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        return
                    end
                end
            end
            turtle.turnRight()
            if turtle.place() == false then
                if turtle.getItemCount() == 0 then
                    if toFirstSlot() == false then
                        turtle.turnLeft()
                        return
                    end
                end
            end
            turtle.turnLeft()
            turtle.forward()
        end
    else
        print("The first argument is incorrect")
    end
end
