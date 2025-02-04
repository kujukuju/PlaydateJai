
--Array: Demonstration of custom class for moving arrays of data between C and Lua

local gfx = playdate.graphics

a = array.new(10)

for i=1,10 do a[i] = i*i end
print(#a)
print(a[5])
print(a:getMinimum())
print(a:getMaximum())
print(a:getAverage())

function playdate.update()
	playdate.drawFPS(0, 0)
end
