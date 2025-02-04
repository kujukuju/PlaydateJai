
import 'CoreLibs/sprites'

local TARGETSIZE = 100
local COVERSIZE = 60
local COVERCOUNT = 100

-- run as fast as possible
playdate.display.setRefreshRate(0)

local gfx = playdate.graphics
local sprite = gfx.sprite

local stripes = { 0x0f, 0x1e, 0x3c, 0x78, 0xf0, 0xe1, 0xc3, 0x87 }

-- make images for the sprites. Could just as easily load these from bitmaps..
blackCircle = gfx.image.new(TARGETSIZE, TARGETSIZE)
gfx.pushContext(blackCircle)
gfx.setPattern(stripes)
gfx.fillEllipseInRect(0,0,TARGETSIZE,TARGETSIZE)
gfx.setColor(gfx.kColorBlack)
gfx.drawEllipseInRect(0,0,TARGETSIZE,TARGETSIZE)
gfx.popContext()

whiteCircle = gfx.image.new(COVERSIZE, COVERSIZE)
gfx.pushContext(whiteCircle)
gfx.setColor(gfx.kColorWhite)
gfx.fillEllipseInRect(0,0,COVERSIZE,COVERSIZE)
gfx.setColor(gfx.kColorBlack)
gfx.drawEllipseInRect(0,0,COVERSIZE,COVERSIZE)
gfx.popContext()

-- White is already the default background color, but we'll be pedantic
gfx.setBackgroundColor(gfx.kColorWhite)

-- we'll be measuring how much of this sprite is visible after the cover sprites are drawn over it
target = sprite.new(blackCircle)
target.mask = target:getImage():getMaskImage() -- cache for later
-- we set the collide rect so that the collision detector tracks which cover sprites are overlapping the target
target:setCollideRect(0,0,TARGETSIZE,TARGETSIZE)
sprite.addSprite(target)
target:moveTo(200,120)

covers = {}

for i=1,COVERCOUNT do
	local c = sprite.new(whiteCircle)
	c.mask = c:getImage():getMaskImage():invertedImage() -- we want these to be black on white. I'll explain below.
	c:setCollideRect(0,0,COVERSIZE,COVERSIZE)
	covers[#covers+1] = c
	sprite.addSprite(c)
end

-- this is the image we use to test the sprite coverage. we draw the target mask uncovered first to count the total number of pixels in the sprite's mask
test = gfx.image.new(TARGETSIZE, TARGETSIZE, gfx.kColorBlack) -- image doesn't need a mask, so we set bg color to black
gfx.pushContext(test)
target.mask:draw(0,0)
gfx.popContext()

-- gfx.image.popcount() is a C function we added through the C API. It returns the number of white pixels in an image.
totalCount = test:popcount()

function randomizeCovers()
	for i=1,#covers do
		local c = covers[i]
		c.px = 4 * math.random() - 2
		c.py = 4 * math.random() - 2
		c.pz = 3 * math.random() + 0.2
		c:setZIndex(c.pz * 1000) -- make sure drawing order matches parallax
	end
end

randomizeCovers()

playdate.startAccelerometer()

-- the raw accelerometer data is pretty noisy, so we smooth it out with a simple low-pass filter
local shiftx = 0
local shifty = 0
local smoothing = 0.9

function playdate.update()
	local x,y = playdate.readAccelerometer()

	shiftx = smoothing * shiftx + (1-smoothing) * x
	shifty = smoothing * shifty + (1-smoothing) * y

	local i

	for i=1,#covers do
		local s = covers[i]
		-- perspective transform
		s:moveTo(200 + 200 * (s.px + shiftx * s.pz), 120 + 120 * (s.py + shifty * s.pz))
	end

	-- update the sprite scene first..
	sprite.update()

	-- then we can use the collider to tell us what's overlapping the target sprite
	local list = target:overlappingSprites()
	local visible = 1.0

	if list ~= nil then
		-- we compute coverage by first drawing the target sprite's mask normally (white pixels where the bitmap is opaque)
		gfx.pushContext(test)
		target.mask:draw(0,0)

		-- we inverted the cover masks (black where the bitmap is drawn) so that we can use this mode to draw them black in the test bitmap
		gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)

		for i=1,#list do
			local s = list[i]
			local x,y = s:getPosition()
			s.mask:draw((x-COVERSIZE/2)-(200-TARGETSIZE/2), (y-COVERSIZE/2)-(120-TARGETSIZE/2))
		end

		gfx.popContext()

		visible = test:popcount() / totalCount
	end

	-- coverage meter
	local y = 240 * visible
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(380,0,20,240-y)
	gfx.setPattern(stripes)
	gfx.fillRect(380,240-y,20,y)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawLine(380,0,380,240)

	-- show test image
	test:draw(0,140)
	gfx.drawLine(0,139,100,139)
	gfx.drawLine(100,139,100,240)

	-- finally, fps!
	playdate.drawFPS(0,0)
end

playdate.AButtonDown = randomizeCovers
playdate.BButtonDown = randomizeCovers
