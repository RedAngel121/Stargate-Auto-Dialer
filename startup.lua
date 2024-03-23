if not fs.exists("AddressList.lua") then
    local f = io.open("AddressList.lua", "w")
    f:write("return {\n\t{locName=\"Home\", address={1,2,3,4,5,6,7,8,0}}\n}")
end
/interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")
if interface == nil then
    term.clear()
    term.setCursorPos(1, 1)
    print("INTERFACE NOT FOUND:\nPlease Check your Modem's Connection\n\nComputer will automatically reboot in 5 seconds...")
    sleep(5)
    os.reboot()
end
shell.run("dialer")
