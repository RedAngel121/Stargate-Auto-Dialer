local gateAddress = require("AddressList")
local w,h = term.getSize()
local nOption = 1

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
    else
        print("FILE SAVE FAILED")
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
        else
            print("FILE LOAD FAILED")
        end
    else
        print("UNABLE TO OPEN FILE")
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

-- Function to set the text to Print Center
function printCenter (y,s)
    local x = math.floor((w - string.len(s))/2)
    term.setCursorPos(x,y)
    term.clearLine()
    term.write(s)
end

-- Function that displays the Menu
function drawFrontEnd()
    loadItemList()
    term.clear()
    term.setCursorPos(1, 1)
    printCenter(math.floor(h/2) - 7, "Select a Destination to Edit:")
    printCenter(math.floor(h/2) - 6, "Press Delete to Remove or PGUP to Move")
    printCenter(math.floor(h/2) + 8, "Press Insert to Add or PGDN to Move")
    printCenter(math.floor(h/2) + 9, "Press Enter to Edit Selected Item")
    printCenter(math.floor(h/2) + 10, "Move \17 or \16 to DIAL")

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
            printCenter(math.floor(h/2) + curs, "=== \31 ===")
        end
        if nOption > 5 then
            printCenter(math.floor(h/2) - 4, "=== \30 ===")
        end
    end

end

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
        editLocationDetails()
    elseif p == keys.insert then
        addNewLocation()
    elseif p == keys.delete then
        removeItem(nOption)
    elseif p == keys.d or p == keys.right or p == keys.numPad4 then
        shell.run("dialer")
    elseif p == keys.a or p == keys.left or p == keys.numPad6 then
        shell.run("dialer")
    elseif p == keys.pageUp then
        moveItemUp(nOption)
    elseif p == keys.pageDown then
        moveItemDown(nOption)
    elseif p == keys.home then
        nOption = 1
        drawFrontEnd()
    elseif p == keys['end'] then
        nOption = #gateAddress
        drawFrontEnd()
    end
end
