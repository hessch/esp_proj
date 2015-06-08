aplist = {}

function rndmac() 
	m = ''
	for b = 0, 5, 1 do 
		m = m..string.char(math.random(255)) 
	end
	if wifi.sta.setmac(m) then
		print("New random MAC address: "..wifi.sta.getmac())
	end
end

function do_scan(tries) 
	if tries == 0 then
		print("Too many failed scans, reboot node.")
		node.restart()
	end

	aplist = {}

	print("Doing scan.")
	wifi.sta.getap(function (t) 
		if t == nil then
			print("nil AP list, heap is: "..node.heap())
			-- tmr.stop(1)
			tmr.alarm(1, 2000, 0, 
				function () do_scan(tries - 1) end)
			return nil
		end

		local k, v
		for k, v in pairs(t) do 
			print(k.." : "..v) 
			if string.sub(v,1,1) == "0" then
				print("Network "..k.." is open.")
				aplist = t
				tmr.alarm(1, 100, 0, 
					function () connect_open_net(k) end)
				return nil
			end
		end 
		tmr.alarm(1, 100, 0, function () do_scan(3) end)
		return nil
	end)
end

function connect_open_net(ssid)
	print("Trying to connect to open network "..ssid)
	wifi.sta.config(ssid, "\000\000\000\000\000\000\000\000")

	rndmac()
	wifi.sta.connect()

	tmr.alarm(1, 250, 0, function  () send_data(10) end)
	return nil
end

function send_data(tries)
	scanid = tmr.now()
	while wifi.sta.getip() == nil and tries >= 1 do
		print("try "..tries..": no address")
		tmr.alarm(1, 250, 0, function () send_data(tries - 1) end)
		return nil
	end

	if wifi.sta.getip() == nil then
		print("Failed to get IP, return to scan state.")
		tmr.alarm(1, 1000, 0, function () do_scan(5) end)
		return nil
	end
	
	print("IPv4 lease obtained: " .. wifi.sta.getip())

	local k, v
	for k, v in pairs(aplist) do
		local enc, rssi, bssid, chan = string.match(v,
			"(%d),(-?%d+),([%x:]+),(%d+)")
		local dnsq = rssi.."."..bssid.gsub(bssid, ":", "") ..
			"."..scanid.."."..node.chipid()..domain_suffix
		net.createConnection(net.UDP, false):dns(dnsq, 
			function (s, i) 
				print("Sent "..dnsq.." for "..bssid) 
			end)
	end

	print("Resuming with scan in 10s.")
	tmr.alarm(1, 5000, function () do_scan(3) end)
	return nil
end

do_scan(5)
