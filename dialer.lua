local w,h = term.getSize()
local nOption = 1
local editor = false
interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")

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
    drawFrontEnd()
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
    drawFrontEnd()
end

-- Function to edit an existing item on the Address List
function editLocationDetails()
    loadItemList()
    term.clear()
    term.setCursorPos(1,1)
    local selectedLocation = itemList[nOption]
    print("Current Name: " .. selectedLocation.locName)
    print("Current Address: {" .. table.concat(selectedLocation.address, ",") .. "}\n")
    io.write("Enter new Gate Name (Press Enter to keep current): ")
    local newLocName = io.read()
    if newLocName == "" then
        newLocName = selectedLocation.locName
    end
    io.write("Enter new Gate Address (CSV / Press Enter to keep current): ")
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
    drawFrontEnd()
end

-- Function to move an item up in the Address List
function moveItemUp(index)
    loadItemList()
    if index > 1 then
        -- Swap the item with the one above it
        itemList[index], itemList[index - 1] = itemList[index - 1], itemList[index]
        saveItemList()
        nOption = nOption - 1
    end
    drawFrontEnd()
end

-- Function to move an item down in the Address List
function moveItemDown(index)
    loadItemList()
    if index < #itemList then
        -- Swap the item with the one below it
        itemList[index], itemList[index + 1] = itemList[index + 1], itemList[index]
        saveItemList()
        nOption = nOption + 1
    end
    drawFrontEnd()
end

-- Function to Dial the Milky-Way Stargate
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
        printCenter(math.floor(h/2)-7, "\24 or \25 to Select a Destination")
        printCenter(math.floor(h/2)-6, "[Enter] to start Dialing")
        printCenter(math.floor(h/2)+9, "Move \27 or \26 to enter EDIT MODE")
    elseif editor == true then
        term.setTextColor(colors.orange)
        printCenter(math.floor(h/2) - 7, "[Enter] to Edit Selected Destination")
        printCenter(math.floor(h/2) - 6, "[Insert] to Add or [Delete] to Remove")
        printCenter(math.floor(h/2) + 8, "Use [PageUp] or [PageDown] to Move Items")
        printCenter(math.floor(h/2) + 9, "Move \27 or \26 to enter DIAL MODE")
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
            if editor == true then
                editLocationDetails()
            elseif editor == false then
                term.clear()
                loadItemList()
                dial(itemList[nOption])
                break
            end
        elseif key == keys.insert then
            addNewLocation()
        elseif key == keys.delete then
            removeItem(nOption)
        elseif key == keys.d or key == keys.right or key == keys.numPad4 then
            editorMode()
            drawFrontEnd()
        elseif key == keys.a or key == keys.left or key == keys.numPad6 then
            editorMode()
            drawFrontEnd()
        elseif key == keys.pageUp then
            moveItemUp(nOption)
        elseif key == keys.pageDown then
            moveItemDown(nOption)
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