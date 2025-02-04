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

static PlaydateAPI* pd = NULL;
static int image_popcount(lua_State* L);


#ifdef _WINDLL
__declspec(dllexport)
#endif
int
eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	if ( event == kEventInitLua )
	{
		pd = playdate;
		
		const char* err;

		if ( !pd->lua->addFunction(image_popcount, "playdate.graphics.image.popcount", &err) )
			pd->system->logToConsole("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
	}
	
	return 0;
}

static int image_popcount(lua_State* L)
{
	LCDBitmap* bitmap = pd->lua->getBitmap(1);

	int width;
	int height;
	int rowbytes;
	uint8_t* data;
	uint8_t* mask;
	int y;
	int count = 0;
	
	pd->graphics->getBitmapData(bitmap, &width, &height, &rowbytes, &mask, &data);

	for ( y = 0; y < height; ++y )
	{
		int x;
		uint32_t* row = (uint32_t*)&data[rowbytes*y];
		
		for (x = 0; x < width; x += 32)
		{
#if(_WINDLL)
			count += __popcnt(row[x / 32]);
#else
			count += __builtin_popcount(row[x / 32]);
#endif
		}
	}
	
	pd->lua->pushInt(count);
	return 1;
}
