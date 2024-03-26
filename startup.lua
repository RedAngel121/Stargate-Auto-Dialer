-- Make AddressList if it doesnt exist
if not fs.exists("AddressList.lua") then
    local f = io.open("AddressList.lua", "w")
    f:write("return {\n\t{locName=\"Home\", address={1,2,3,4,5,6,7,8,0}}\n}")
end

-- Check if the interface exists and find out what kind
interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")
if interface == nil then
    term.clear()
    term.setCursorPos(2, 2)
    term.setTextColor(colors.red)
    print("INTERFACE NOT FOUND")
    term.setTextColor(colors.white)
    print("\nPlease Check your Modem's Connection\n\nThe wired modem connected to this terminal and the wired modem connected to the interface both need to be Turned On. Make sure there is a red outline around the wire on both modems.\n\nTerminal will automatically reboot...")
    sleep(3)
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
    term.setCursorPos(2, 2)
    term.setTextColor(colors.red)
    print("STARGATE NOT FOUND")
    term.setTextColor(colors.white)
    print("\nPlease Check your Interface's Orientation\n\nThe Interface block has one side with a large black box/hole. Make sure that black side is facing AWAY from the Stargate.\n\nTerminal will automatically reboot...")
    sleep(3)
    os.reboot()
elseif interface.getStargateType() ~= "sgjourney:milky_way_stargate" and iType == "basic" then
    term.clear()
    term.setCursorPos(2, 2)
    term.setTextColor(colors.red)
    print("INCORRECT INTERFACE")
    term.setTextColor(colors.white)
    print("\nPlease upgrade to the Crystal Interface to begin dialing this Stargate\n\nBasic Interfaces can only be used with the Milky-Way Stargate and are incompatable with Classic, Pegasus, Tollan, and Universe.\n\nTerminal will automatically reboot...")
    sleep(3)
    os.reboot()
end

-- Main Menu Go!
shell.run("dialer")