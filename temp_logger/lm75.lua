-- lm75.lua - NodeMCU Library for LM75 i2c temperature sensors
-- version 0.1, Hessel Schut, hessel@isquared.nl, 2015-01-03

lm75 = {
	address = 71,
	temp_reg = 0,

	init = function (self, sda, scl)
		self.bus = 0
		i2c.setup(self.bus, sda, scl, i2c.SLOW)
	end,

	read = function (self)
		i2c.start(self.bus)
		i2c.address(self.bus, self.address, i2c.TRANSMITTER)
		i2c.write(self.bus, self.temp_reg)
		i2c.stop(self.bus)

		i2c.start(self.bus)
		i2c.address(self.bus, self.address + 1, i2c.RECEIVER)
		c=i2c.read(self.bus, 2)
		i2c.stop(self.bus)
		return c
	end,

	convert = function (self, msb, lsb)
		if msb > 127 then msb = msb - 255 end
		return msb, bit.band(bit.rshift(lsb, 5), 7) * 10 / 8
	end,

	strTemp = function (self)
		local h, l 
		h, l = string.byte(self:read(), 1, 2)
		return string.format("%d.%d", self:convert(h, l))
	end,

	intTemp = function (self)
		local h, l 
		h, l = string.byte(self:read(), 1, 2)
		return tonumber(string.format("%d%d", self:convert(h, l)))
	end
}
