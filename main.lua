gpio0 = 3
gpio2 = 4

count = {0, 0}

gpio.mode(gpio0, gpio.INT)
gpio.mode(gpio2, gpio.OUTPUT)

function increment(index, state)
	if state == gpio.HIGH then
		count[index] = count[index] + 1
	end
	print("state of gpio "
		..tostring(index)
		.." changed to "
		..tostring(state)
		..", count is "
		..tostring(count[index]))
end

gpio.trig(gpio0, "both", function (state) increment(1, state) end)
-- gpio.trig(gpio2, "both", function (state) increment(2, state) end)

srv=net.createServer(net.TCP)
srv:listen(1335, function(c)
	str = ""
	for i=1,2 do
		str = str .. tostring(count[i]).."\n"
	end
	str = str .. tostring(tmr.now()).." ticks\n"
	str = str .. "node-"..tostring(node.chipid()).."\n"
	c:send(str)
	c:on("sent", function(c) c:close() end)
end)

gpio.write(gpio2, gpio.HIGH)
