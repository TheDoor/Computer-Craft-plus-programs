local pastebinId = "LFb8qYrZ"

-- Function to get a random delay time between requests
local function getRandomDelay()
    -- Adjust the range and interval based on your preference
    local minDelay = 1 -- Minimum delay in seconds
    local maxDelay = 5 -- Maximum delay in seconds
    return math.random(minDelay, maxDelay)
end

-- Main function for running the script after downloading from Pastebin
local function runScriptAfterDownload()
    -- Run your script after downloading from Pastebin
    shell.run("prog.lua")
end

-- Main function for downloading the script from Pastebin
local function downloadScriptFromPastebin()
    -- Delete the existing script file if it exists
    fs.delete("prog.lua")

    -- Download the script from Pastebin
    shell.run("pastebin get " .. pastebinId .. " prog.lua")

    -- Run the script after download
    runScriptAfterDownload()
end

-- Main function for running the startup script
local function runStartupScript()
    while true do
        -- Download the script from Pastebin
        downloadScriptFromPastebin()

        -- Add a random delay before the next download
        local delay = getRandomDelay()
        os.sleep(delay) -- Sleep for the random delay time
    end
end

-- Run the startup script
runStartupScript()
