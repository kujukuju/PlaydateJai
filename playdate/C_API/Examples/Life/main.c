//
//  main.c
//  Extension
//
//  Created by Dave Hayden on 7/30/14.
//  Copyright (c) 2014 Panic, Inc. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>

#include "pd_api.h"

/*
 Game of Life:
 
 Any live cell with fewer than two live neighbours dies, as if caused by under-population.
 Any live cell with two or three live neighbours lives on to the next generation.
 Any live cell with more than three live neighbours dies, as if by overcrowding.
 Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
*/

static inline int ison(uint8_t* row, int x)
{
	return !(row[x/8] & (0x80 >> (x%8)));
}

static inline int val(uint8_t* row, int x)
{
	return 1 - ((row[x/8] >> (7 - (x%8))) & 1);
}

static inline int rowsum(uint8_t* row, int x)
{
	if ( x == 0 )
		return val(row, LCD_COLUMNS-1) + val(row, x) + val(row, x+1);
	else if ( x < LCD_COLUMNS - 1 )
		return val(row, x-1) + val(row, x) + val(row, x+1);
	else
		return val(row, x-1) + val(row, x) + val(row, 0);
}

static inline int middlerowsum(uint8_t* row, int x)
{
	if ( x == 0 )
		return val(row, LCD_COLUMNS-1) + val(row, x+1);
	else if ( x < LCD_COLUMNS - 1 )
		return val(row, x-1) + val(row, x+1);
	else
		return val(row, x-1) + val(row, 0);
}

static inline void
doRow(uint8_t* rowabove, uint8_t* row, uint8_t* rowbelow, uint8_t* outrow)
{
	char b = 0;
	int bitpos = 0x80;
	int x;
	
	for ( x = 0; x < LCD_COLUMNS; ++x )
	{
		// If total is 3 cell is alive
		// If total is 4, no change
		// Else, cell is dead
		
		int sum = rowsum(rowabove, x) + middlerowsum(row, x) + rowsum(rowbelow, x);
		
		if ( sum == 3 || (ison(row, x) && sum == 2) )
			b |= bitpos;
		
		bitpos >>= 1;
		
		if ( bitpos == 0 )
		{
			outrow[x/8] = ~b;
			b = 0;
			bitpos = 0x80;
		}
	}
}


static PlaydateAPI* pd = NULL;

static void randomize(void)
{
	int x, y;
	uint8_t* frame = pd->graphics->getDisplayFrame();

	for ( y = 0; y < LCD_ROWS; ++y )
	{
		uint8_t* row = &frame[y * LCD_ROWSIZE];
		
		for ( x = 0; x < LCD_COLUMNS / 8; ++x )
			row[x] = rand();
	}
}

static int
update(void* ud)
{
	PDButtons pushed;
	pd->system->getButtonState(NULL, &pushed, NULL);
	
	if ( pushed & kButtonA )
		randomize();
	
	uint8_t* nextframe = pd->graphics->getFrame(); // working buffer
	uint8_t* frame = pd->graphics->getDisplayFrame(); // buffer currently on screen (or headed there, anyway)
	
	if ( frame != NULL )
	{
		uint8_t* rowabove = &frame[LCD_ROWSIZE * (LCD_ROWS - 1)];
		uint8_t* row = frame;
		uint8_t* rowbelow = &frame[LCD_ROWSIZE];
		
		for ( int y = 0; y < LCD_ROWS; ++y )
		{
			doRow(rowabove, row, rowbelow, &nextframe[y * LCD_ROWSIZE]);
			
			rowabove = row;
			row = rowbelow;
			rowbelow = &frame[((y+2)%LCD_ROWS) * LCD_ROWSIZE];
		}
	}
	
	// we twiddled the framebuffer bits directly, so we have to tell the system about it
	pd->graphics->markUpdatedRows(0, LCD_ROWS);
	
	return 1;
}

#ifdef _WINDLL
__declspec(dllexport)
#endif
int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	if ( event == kEventInit )
	{
		pd = playdate;
		pd->display->setRefreshRate(0); // run as fast as possible
		pd->system->setUpdateCallback(update, NULL);

		randomize();
	}
	
	return 0;
}
