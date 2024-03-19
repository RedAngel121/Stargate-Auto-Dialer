if not fs.exists("AddressList.lua") then
    local f = io.open("AddressList.lua", "w")
    f:write("return {\n\t{loc=\"Home\" address={1,2,3,4,5,6,7,8,0}}\n}")
end
if not fs.exists("sal.lua") then
    local f = io.open("sal.lua", "w")
    f:write("function saveItemList()\n\tlocal file = io.open(\"AddressList.lua\", \"w\")\n\tif file then\n\t\tfile:write(\"return {\\n\")\n\t\tfor _, item in ipairs(itemList) do\n\t\t\tfile:write(string.format(\"\\t{locName=\\\"%s\\\", address={%s}},\\n\", item.locName, table.concat(item.address, \",\")))\n\t\tend\n\t\tfile:write(\"}\\n\")\n\t\tfile:close()\n\tend\nend\nfunction loadItemList()\n\tlocal file = io.open(\"AddressList.lua\", \"r\")\n\tif file then\n\t\tlocal content = file:read(\"*all\")\n\t\tfile:close()\n\t\tlocal success, loadedItemList = pcall(load(content))\n\t\tif success and type(loadedItemList) == \"table\" then\n\t\t\titemList = loadedItemList\n\t\tend\n\tend\nend")
end
interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")
if interface == nil then
    term.clear()
    term.setCursorPos(1, 1)
    print("INTERFACE NOT FOUND:\nPlease Check your Modem's Connection\n\nComputer will automatically reboot in 5 seconds...")
    sleep(5)
    os.reboot()
end
shell.run("dialer")
