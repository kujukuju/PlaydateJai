//
//  main.c
//  Extension
//
//  Created by Dan Messing on 1/26/18.
//  Copyright © 2018 Panic, Inc. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>

#include "pd_api.h"

#include "game.h"

#ifdef _WINDLL
__declspec(dllexport)
#endif
int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	if ( event == kEventInit )
	{
		setPDPtr(playdate);
		playdate->display->setRefreshRate(20);
		playdate->system->setUpdateCallback(update, NULL);
		setupGame();
	}
	
	return 0;
}
