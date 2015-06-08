wifi.setmode(wifi.STATION)
domain_suffix = "CHANGEME"

if file.open("main.lua") then
	node.compile("main.lua")
	file.remove("main.lua")
end

dofile("main.lc")
