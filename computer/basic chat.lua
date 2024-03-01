-- Check if there's a speaker peripheral connected
local speaker = peripheral.find("speaker")

-- Generate the sound buffer
local buffer = {}
local t, dt = 0, 2 * math.pi * 1000 / 10000 -- Frequency increased to 1000 Hz for a higher pitch
for i = 1, 48000 do
    buffer[i] = math.floor(math.sin(t) * 127)
    t = (t + dt) % (math.pi * 2)
end

-- Function to play the generated sound
local function playSound(buffer)
    if speaker then
        speaker.playAudio(buffer)
    end
end


-- Open Rednet on the side the modem is attached to
local modem = peripheral.find("modem")
if modem then
    rednet.open("left")
    playSound(buffer)
else
    print("No modem found!")
    return
end

-- Function to receive messages and print them
local function receiveMessages()
    while true do
        local senderId, message, protocol = rednet.receive("chat")
        print("[" .. senderId .. "]: " .. message)
        -- Play ping sound when a message is received
        playSound(buffer)
    end
end

-- Function to send messages
local function sendMessages()
    while true do
        local message = read()
        rednet.broadcast(message, "chat")
    end
end

-- Start receiving and sending messages in separate threads
parallel.waitForAll(receiveMessages, sendMessages)
