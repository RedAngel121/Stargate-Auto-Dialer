if not fs.exists("AddressList.lua") then
    saveFile("AddressList.lua", "return {\\n    {loc=\"Home\" address={1,2,3,4,5,6,7,8}\\n}")
end
shell.run("SGJ_AutoDialer")
