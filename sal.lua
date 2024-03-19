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
