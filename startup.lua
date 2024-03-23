-- Make AddressList if it doesnt exist
if not fs.exists("AddressList.lua") then
    local f = io.open("AddressList.lua", "w")
    f:write("return {\n\t{locName=\"Home\", address={1,2,3,4,5,6,7,8,0}}\n}")
end

-- Check if the interface exists and find out what kind
interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")
if interface == nil then
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    print("INTERFACE NOT FOUND")
    term.setTextColor(colors.white)
    print("\nPlease Check your Modem's Connection\n\nComputer will automatically reboot in 5 seconds...")
    sleep(5)
    os.reboot()
elseif peripheral.find("basic_interface") then
    iType = "basic"
elseif peripheral.find("crystal_interface") then
    iType = "crystal"
elseif peripheral.find("advanced_crystal_interface") then
    iType = "advanced"
end

-- Check and make sure that you are not using a basic interface on anything that isnt the milky way gate
if interface.getStargateType == nil then
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    print("STARGATE NOT FOUND")
    term.setTextColor(colors.white)
    print("\nPlease Check your Interface's Orientation\n\nComputer will automatically reboot in 5 seconds...")
    sleep(5)
    os.reboot()
elseif interface.getStargateType() ~= "sgjourney:milky_way_stargate" and iType == "basic" then
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    print("INCORRECT INTERFACE")
    term.setTextColor(colors.white)
    print("\nPlease upgrade to the Crystal Interface to begin dialing this gate\n\nComputer will automatically reboot in 5 seconds...")
    sleep(5)
    os.reboot()
end

-- Main Menu Go!
shell.run("dialer")