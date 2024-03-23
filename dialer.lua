local w,h = term.getSize()
local mid = math.floor(h/2)
local nOption = 1
local editor = false
local interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")
stargateType = interface.getStargateType()
term.clear()

-- Function to save the Address List to AddressList.lua
function saveItemList()
	local file = io.open("AddressList.lua", "w")
	if file then
		file:write("return {\n")
		for _, item in ipairs(itemList) do
			file:write(string.format("\t{locName=\"%s\", address={%s}},\n", item.locName, table.concat(item.address, ",")))
		end
		file:write("}\n")
		file:close()
	end
end

-- Function to load the Address List from AddressList.lua
function loadItemList()
	local file = io.open("AddressList.lua", "r")
	if file then
		local content = file:read("*all")
		file:close()
		local success, loadedItemList = pcall(load(content))
		if success and type(loadedItemList) == "table" then
			itemList = loadedItemList
		end
	end
end

-- Function to switch to edit mode
function editorMode()
    if editor == true then
        editor = false
    elseif editor == false then
        editor = true
    end
end

-- Function to add a new item to the Address List
function addNewLocation()
    os.sleep(0.1)
    loadItemList()
    term.clear()
    term.setCursorPos(1,1)
    io.write("Enter Gate Name: ")
    local newLocName = io.read()
    io.write("Enter Gate Address (CSV): ")
    local newAddressInput = io.read()
    local newAddress = {}
    if newAddressInput ~= "" then
        for num in newAddressInput:gmatch("%d+") do
            table.insert(newAddress, tonumber(num))
        end
        if newAddress[#newAddress] ~= 0 then
            table.insert(newAddress, 0)
        end
    else
        newAddress = {0}
    end
    table.insert(itemList, {locName = newLocName, address = newAddress})
    saveItemList()
end

-- Function to remove an item from the Address List
function removeItem(index)
    loadItemList()
    if itemList[index] then
        table.remove(itemList, index)
        saveItemList()
    end
    if nOption >= #itemList then
        nOption = #itemList
    end
end

-- Function to edit an existing item on the Address List
function editLocationDetails()
    loadItemList()
    term.clear()
    term.setCursorPos(1,1)
    local selectedLocation = itemList[nOption]
    print("Current Name: " .. selectedLocation.locName)
    print("Current Address: {" .. table.concat(selectedLocation.address, ",") .. "}\n")
    io.write("Enter new Gate Name (Press Enter to keep current):\n")
    local newLocName = io.read()
    if newLocName == "" then
        newLocName = selectedLocation.locName
    end
    io.write("Enter new Gate Address (CSV / Press Enter to keep current):\n")
    local newAddressInput = io.read()
    local newAddress = {}
    if newAddressInput ~= "" then
        for num in newAddressInput:gmatch("%d+") do
            table.insert(newAddress, tonumber(num))
        end
        if newAddress[#newAddress] ~= 0 then
            table.insert(newAddress, 0)
        end
    else
        newAddress = selectedLocation.address
    end
    itemList[nOption].locName = newLocName
    itemList[nOption].address = newAddress
    saveItemList()
end

-- Function to move an item up in the Address List
function moveItemUp(index)
    loadItemList()
    if index > 1 then
        itemList[index], itemList[index - 1] = itemList[index - 1], itemList[index]
        saveItemList()
        nOption = nOption - 1
    end
end

-- Function to move an item down in the Address List
function moveItemDown(index)
    loadItemList()
    if index < #itemList then
        itemList[index], itemList[index + 1] = itemList[index + 1], itemList[index]
        saveItemList()
        nOption = nOption + 1
    end
end

-- Function to Dial the Milky-Way Stargate
function dial(address)
    printCenter(mid - 2, "Dialing Stargate Address")
    printCenter(mid - 1, "Please Wait...")
    local start = interface.getChevronsEngaged() + 1
    local prevSymbol = 0
    for chevron = start,#address.address,1 do
        local symbol = address.address[chevron]
        if stargateType == "sgjourney:milky_way_stargate" then
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
        else
            interface.engageSymbol(symbol)
            -- sleep(0.5)
        end
    end
    printCenter(mid - 1, "Dialing Complete")
    sleep(3)
    os.reboot()
end

-- Function to set the cursor the the center of the screen and print on the line
function printCenter(y,s)
    local x = math.floor((w - string.len(s))/2)
    term.setCursorPos(x,y)
    term.clearLine()
    term.write(s)
end

-- Function to draw the Main Menu
function drawFrontEnd()
    loadItemList()
    term.clear()
    if editor == false then
        term.setTextColor(colors.green)
        printCenter(mid - 7, "\24 or \25 to Select a Destination")
        printCenter(mid - 6, "[Enter] to start Dialing")
        printCenter(mid + 9, "Move \27 or \26 to enter EDIT MODE")
    elseif editor == true then
        term.setTextColor(colors.orange)
        printCenter(mid - 7, "[Enter] to Edit Selected Destination")
        printCenter(mid - 6, "[Insert] to Add or [Delete] to Remove")
        printCenter(mid + 8, "Use [PageUp] or [PageDown] to Move Items")
        printCenter(mid + 9, "Move \27 or \26 to enter DIAL MODE")
    end
    term.setTextColor(colors.white)
    local function drawOption(index)
        return ((nOption == index) and "\187 " .. itemList[index].locName .. " \171") or itemList[index].locName
    end
    local curs = -3
    if #itemList < 10 then
        for i, t in ipairs(itemList) do
            printCenter(mid + curs, drawOption(i))
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
            printCenter(mid + curs, drawOption(i))
            curs = curs + 1
        end
        if nOption < #itemList - 4 then
            printCenter(mid + curs, "\131\131\131 \25 \131\131\131")
        end
        if nOption > 5 then
            printCenter(mid - 4, "\140\140\140 \24 \140\140\140")
        end
    end
end

-- Terminal Button for Disconnecting the Active Stargate
function buttonDCW()
    paintutils.drawFilledBox(14, 7, 36, 11, colors.white)
    term.setCursorPos(16, 9)
    term.setTextColor(colors.black)
    term.write("Disconnect Wormhole")
    term.setTextColor(colors.white)
end

-- Script Actually Starts Here
while true do
    term.setBackgroundColor(colors.black)
    loadItemList()
    drawFrontEnd()
    if interface.isStargateConnected() == true then
        term.clear()
        buttonDCW()
        local event, button, xPos, yPos = os.pullEvent("mouse_click")
        if (xPos > 13 and xPos < 37) and (yPos > 6 and yPos < 12) then
            interface.disconnectStargate()
        end
    end
    local event, key = os.pullEvent()
    if event == "key" then
        if key == keys.up or key == keys.w or key == keys.numPad8 then
            if nOption > 1 then
                nOption = nOption - 1
            end
        elseif key == keys.down or key == keys.s or key == keys.numPad2 then
            if nOption < #itemList then
                nOption = nOption + 1
            end
        elseif key == keys.enter or key == keys.numPadEnter then
            if #itemList < 1 then
                addNewLocation()
            elseif editor == true then
                editLocationDetails()
            elseif editor == false then
                term.clear()
                dial(itemList[nOption])
            end
        elseif key == keys.insert and editor == true then
            addNewLocation()
        elseif key == keys.delete and editor == true then
            removeItem(nOption)
        elseif key == keys.d or key == keys.right or key == keys.numPad4 then
            editorMode()
        elseif key == keys.a or key == keys.left or key == keys.numPad6 then
            editorMode()
        elseif key == keys.pageUp and editor == true then
            moveItemUp(nOption)
        elseif key == keys.pageDown and editor == true then
            moveItemDown(nOption)
        elseif key == keys.home then
            nOption = 1
        elseif key == keys['end'] then
            nOption = #itemList
        end
    elseif event == "mouse_scroll" then
        if key == -1 then 
            -- Scroll up
            if nOption > 1 then
                nOption = nOption - 1
            end
        elseif key == 1 then 
            -- Scroll down
            if nOption < #itemList then
                nOption = nOption + 1
            end
        end
    end
end