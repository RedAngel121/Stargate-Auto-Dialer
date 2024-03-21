require("sal")
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
        while(not interface.isCurrentSymbol(symbol)) do sleep(0) end
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

function drawFrontEnd()
    loadItemList()
    term.clear()
    term.setTextColor(colors.green)
    printCenter(math.floor(h/2)-7, "\24 or \25 to Select a Destination")
    printCenter(math.floor(h/2)-6, "[Enter] to start Dialing")
    if fs.exists("editor.lua") then
        printCenter(math.floor(h/2)+9, "Move \27 or \26 to enter EDIT MODE")
    end
    term.setTextColor(colors.white)
    local function drawOption(index)
        return ((nOption == index) and "\16 " .. itemList[index].locName .. " \17") or itemList[index].locName
    end

    local curs = -3
    if #itemList < 10 then
        for i, t in ipairs(itemList) do
            printCenter(math.floor(h/2) + curs, drawOption(i))
            curs = curs + 1
        end
    else
        local start, stop
        if nOption < 6 then
            start, stop = 1, 9
        elseif nOption > 5 and nOption < #itemList - 4 then
            start, stop = nOption - 4, nOption + 4
        else
            start, stop = #itemList - 8, #itemList
        end

        for i = start, stop do
            printCenter(math.floor(h/2) + curs, drawOption(i))
            curs = curs + 1
        end

        if nOption < #itemList - 4 then
            printCenter(math.floor(h/2) + curs, "\131\131\131 \25 \131\131\131")
        end
        if nOption > 5 then
            printCenter(math.floor(h/2) - 4, "\140\140\140 \24 \140\140\140")
        end
    end
end

term.clear()
interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")
drawFrontEnd()

while true do
    local event, key = os.pullEvent()
    if event == "key" then
        loadItemList()
        if key == keys.up or key == keys.w or key == keys.numPad8 then
            if nOption > 1 then
                nOption = nOption - 1
                drawFrontEnd()
            end
        elseif key == keys.down or key == keys.s or key == keys.numPad2 then
            if nOption < #itemList then
                nOption = nOption + 1
                drawFrontEnd()
            end
        elseif key == keys.enter or key == keys.numPadEnter then
            term.clear()
            loadItemList()
            dial(itemList[nOption])
            break
        elseif fs.exists("editor.lua") and (key == keys.d or key == keys.right or key == keys.numPad4) then
            shell.run("editor")
        elseif fs.exists("editor.lua") and (key == keys.a or key == keys.left or key == keys.numPad6) then
            shell.run("editor")
        elseif key == keys.home then
            nOption = 1
            drawFrontEnd()
        elseif key == keys['end'] then
            nOption = #itemList
            drawFrontEnd()
        end
    elseif event == "mouse_scroll" then
        loadItemList()
        if key == -1 then -- Scroll up
            if nOption > 1 then
                nOption = nOption - 1
                drawFrontEnd()
            end
        elseif key == 1 then -- Scroll down
            if nOption < #itemList then
                nOption = nOption + 1
                drawFrontEnd()
            end
        end
    end
end