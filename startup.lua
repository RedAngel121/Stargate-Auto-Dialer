if not fs.exists("AddressList.lua") then
    local f = io.open("AddressList.lua", "w")
    f:write("return {\n\t{loc=\"Home\" address={1,2,3,4,5,6,7,8,0}}\n}")
end
shell.run("dialer")
