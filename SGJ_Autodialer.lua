-- Place this entire code in startup.lua in the Advanced Computer.
-- For block placement and how to use this script please watch this Video by Povstalec (the mod author)
-- https://www.youtube.com/watch?v=qNi9NUAmOJM
-- To navigate the menu please use W/S or the UP/DOWN arrows, Make your Selection using Enter.
-- =================================================================================
-- These are the names and addresses of the gates you find/place.
-- You must have at least one gate added to this list for the script to function.
-- Will accept any Cartuche and Gate address as long as it's valid.
-- ALWAYS end an address with a Zero, as shown below. Failure to do so means the gate will not dial anything.
-- I am going to fix the No Zero problem too
local gateAddress = require("AddressList")


-- =================================================================================
-- I am working on converting gateAddress to an external JSON file instead of an internal array
-- In doing that I will eventually be able to add Editing tools to this script for ease of use
-- =================================================================================

local w,h = term.getSize()
local nOption = 1

function dial(address)
    printCenter(math.floor(h/2)-2, "Dialing Stargate Address")
    printCenter(math.floor(h/2)-1, "Please Wait...")
    local start = interface.getChevronsEngaged() + 1
    local prevSymbol = 0
    for chevron = start,#address.address,1 do
        local symbol = address.address[chevron]
        if (prevSymbol > symbol and (prevSymbol - symbol) < 19) or (prevSymbol < symbol and (symbol - prevSymbol) > 19) then
            interface.rotateClockwise(symbol)
        else
            interface.rotateAntiClockwise(symbol)
        end
        while(not interface.isCurrentSymbol(symbol))
        do
            sleep(0)
        end
        sleep(0.3)
        interface.openChevron()
        sleep(0.5)
        interface.closeChevron()
        sleep(0.5)
        prevSymbol = symbol
    end
    printCenter(math.floor(h/2)-1, "Dialing Complete")
    sleep(3)
    os.reboot()
end

function printCenter (y,s)
    local x = math.floor((w - string.len(s))/2)
    term.setCursorPos(x,y)
    term.clearLine()
    term.write(s)
end

-- I know I can probably do better here, but I just dont care to fix it right now.
local function drawFrontEnd()
    curs = -3
    x=1
    term.clear()
    printCenter(math.floor(h/2)-7, "Select a Destination:")
    if #gateAddress < 10 then
        for i,t in ipairs(gateAddress) do
            printCenter(math.floor(h/2)+curs, ((nOption == i)  and "[> - " .. t.locName .. " - <]") or t.locName)
            curs = curs + 1
        end
    elseif nOption < 5 then
        printCenter(math.floor(h/2)-3, ((nOption == 1)  and "[> - " .. gateAddress[1].locName .. " - <]") or gateAddress[1].locName)
        printCenter(math.floor(h/2)-2, ((nOption == 2)  and "[> - " .. gateAddress[2].locName .. " - <]") or gateAddress[2].locName)
        printCenter(math.floor(h/2)-1, ((nOption == 3)  and "[> - " .. gateAddress[3].locName .. " - <]") or gateAddress[3].locName)
        printCenter(math.floor(h/2)+0, ((nOption == 4)  and "[> - " .. gateAddress[4].locName .. " - <]") or gateAddress[4].locName)
        printCenter(math.floor(h/2)+1, ((nOption == 5)  and "[> - " .. gateAddress[5].locName .. " - <]") or gateAddress[5].locName)
        printCenter(math.floor(h/2)+2, gateAddress[6].locName)
        printCenter(math.floor(h/2)+3, gateAddress[7].locName)
        printCenter(math.floor(h/2)+4, gateAddress[8].locName)
        printCenter(math.floor(h/2)+5, gateAddress[9].locName)
        printCenter(math.floor(h/2)+6, "=== v ===")
    elseif nOption > 5 and nOption < #gateAddress - 4 then
        printCenter(math.floor(h/2)-4, "=== ^ ===")
        printCenter(math.floor(h/2)-3,(gateAddress[nOption-4]).locName)
        printCenter(math.floor(h/2)-2,(gateAddress[nOption-3]).locName)
        printCenter(math.floor(h/2)-1,(gateAddress[nOption-2]).locName)
        printCenter(math.floor(h/2)+0,(gateAddress[nOption-1]).locName)
        printCenter(math.floor(h/2)+1, "[> - " .. (gateAddress[nOption]).locName .. " - <]")
        printCenter(math.floor(h/2)+2,(gateAddress[nOption+1]).locName)
        printCenter(math.floor(h/2)+3,(gateAddress[nOption+2]).locName)
        printCenter(math.floor(h/2)+4,(gateAddress[nOption+3]).locName)
        printCenter(math.floor(h/2)+5,(gateAddress[nOption+4]).locName)
        printCenter(math.floor(h/2)+6, "=== v ===")
    elseif nOption > #gateAddress - 4 then
        printCenter(math.floor(h/2)-4, "=== ^ ===")
        printCenter(math.floor(h/2)-3, gateAddress[#gateAddress - 8].locName)
        printCenter(math.floor(h/2)-2, gateAddress[#gateAddress - 7].locName)
        printCenter(math.floor(h/2)-1, gateAddress[#gateAddress - 6].locName)
        printCenter(math.floor(h/2)+0, gateAddress[#gateAddress - 5].locName)
        printCenter(math.floor(h/2)+1, ((nOption == #gateAddress - 4)  and "[> - " .. gateAddress[#gateAddress - 4].locName .. " - <]") or gateAddress[#gateAddress - 4].locName)
        printCenter(math.floor(h/2)+2, ((nOption == #gateAddress - 3)  and "[> - " .. gateAddress[#gateAddress - 3].locName .. " - <]") or gateAddress[#gateAddress - 3].locName)
        printCenter(math.floor(h/2)+3, ((nOption == #gateAddress - 2)  and "[> - " .. gateAddress[#gateAddress - 2].locName .. " - <]") or gateAddress[#gateAddress - 2].locName)
        printCenter(math.floor(h/2)+4, ((nOption == #gateAddress - 1)  and "[> - " .. gateAddress[#gateAddress - 1].locName .. " - <]") or gateAddress[#gateAddress - 1].locName)
        printCenter(math.floor(h/2)+5, ((nOption == #gateAddress)  and "[> - " .. gateAddress[#gateAddress].locName .. " - <]") or gateAddress[#gateAddress].locName)
    end
end


term.clear()
interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")
drawFrontEnd()

while true do
    local e,p = os.pullEvent("key")
    if p == keys.up or p == keys.w or p == keys.numPad8 then
        if nOption > 1 then
            nOption = nOption - 1
            drawFrontEnd()
        end
    elseif p == keys.down or p == keys.s or p == keys.numPad2 then
        if nOption < (#gateAddress) then
            nOption = nOption + 1
            drawFrontEnd()
        end
    elseif p == keys.enter or p == keys.numPadEnter then
        term.clear()
        term.setCursorPos(1,1)
        dial(gateAddress[nOption])
        break
    end
end
