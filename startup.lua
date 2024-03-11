if not fs.exists("AddressList.lua") then
    local f = io.open("AddressList.lua", "w")
    f:write("return {\n    {loc=\"Home\" address={1,2,3,4,5,6,7,8}}\n}")
end
shell.run("SGJ_Autodialer.lua")
