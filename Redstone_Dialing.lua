local interface = peripheral.find("basic_interface") or peripheral.find("crystal_interface") or peripheral.find("advanced_crystal_interface")
stargateType = interface.getStargateType()
the_overworld={1,2,3,4,5,6,7,8,0}
the_nether={1,2,3,4,5,6,7,8,0}
the_end={1,2,3,4,5,6,7,8,0}
abydos={1,2,3,4,5,6,7,8,0}
undergarden={1,2,3,4,5,6,7,8,0}

function dial(address)
    local start = interface.getChevronsEngaged() + 1
    local prevSymbol = 0
    for chevron = start,#address,1 do
        local symbol = address[chevron]
        if stargateType == "sgjourney:milky_way_stargate" then
            if (prevSymbol > symbol and (prevSymbol - symbol) < 19) or (prevSymbol < symbol and (symbol - prevSymbol) > 19) then
                interface.rotateClockwise(symbol)
            else
                interface.rotateAntiClockwise(symbol)
            end
            while(not interface.isCurrentSymbol(symbol)) do sleep(0) end
            sleep(0.25)
            interface.openChevron()
            sleep(0.4)
            interface.closeChevron()
            sleep(0.4)
            prevSymbol = symbol
        else
            interface.engageSymbol(symbol)
            sleep(0.4)
        end
    end
end

while true do
    os.pullEvent("redstone")
    if redstone.getInput("left") == true then
        dial(the_nether)
    elseif redstone.getInput("back") == true then
        dial(the_end)
    elseif redstone.getInput("right") == true then
        dial(abydos)
    elseif redstone.getInput("bottom") == true then
        dial(undergarden)
    elseif redstone.getInput("top") == true then
        dial(the_overworld)
    elseif redstone.getInput("front") == true and interface.isStargateConnected() == true then
        interface.disconnectStargate()
    end
end

-- Redstone Link - Command Blocks in Red Slot / Dim Blocks in Blue Slot
-- Gate Rooms - Green Button to Dial Home, Red to DC Gate
-- Protect the PCs with claims - /flan add x y z x2 y2 z2 minecraft:overworld +Admin
