-- For block placement and how to use this script please watch this Video by Povstalec (the mod author)
-- https://www.youtube.com/watch?v=qNi9NUAmOJM
-- To navigate the menu please use W/S or the UP/DOWN arrows, Make your Selection using Enter.

local gateAddress = require("AddressList")
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

local function drawFrontEnd()
    curs = -3
    x = 1
    term.clear()
    printCenter(math.floor(h/2)-7, "Select a Destination to Dial:")
    printCenter(math.floor(h/2)+9, "Move \17 or \16 to EDIT")

    local function drawOption(index)
        return ((nOption == index) and "\16 " .. gateAddress[index].locName .. " \17") or gateAddress[index].locName
    end

    if #gateAddress < 10 then
        for i, t in ipairs(gateAddress) do
            printCenter(math.floor(h/2)+curs, drawOption(i))
            curs = curs + 1
        end
    else
        local start, stop
        if nOption < 6 then
            start, stop = 1, 9
        elseif nOption > 5 and nOption < #gateAddress - 4 then
            start, stop = nOption - 4, nOption + 4
        else
            start, stop = #gateAddress - 8, #gateAddress
        end

        for i = start, stop do
            printCenter(math.floor(h/2)+curs, drawOption(i))
            curs = curs + 1
        end

        if nOption < #gateAddress - 4 then
            printCenter(math.floor(h/2)+curs, "=== \31 ===")
        end
        if nOption > 5 then
            printCenter(math.floor(h/2)-4, "=== \30 ===")
        end
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
        dial(gateAddress[nOption])
        break
    elseif p == keys.d or p == keys.right or p == keys.numPad4 then
        shell.run("editor")
    elseif p == keys.a or p == keys.left or p == keys.numPad6 then
        shell.run("editor")
    end
end
