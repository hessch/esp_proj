require('lm75')

sda, scl = 4, 3
lm75:init(sda, scl)

srv=net.createServer(net.TCP)
srv:listen(27315, 
        function(conn)
		local temp
		temp = lm75:intTemp()
	        conn:send(
			temp.."\n"
			..temp.."\n"
			..tmr.now().." ticks\n"
			.."node-"..node.chipid())
            	conn:on("sent",
                	function(conn) conn:close() end
            	)
        end
)
