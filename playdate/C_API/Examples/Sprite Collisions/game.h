//
//  game.h
//  Extension OS X
//
//  Created by Dan Messing on 1/26/18.
//  Copyright © 2018 Panic, Inc. All rights reserved.
//

#ifndef game_h
#define game_h

#include <stdio.h>

#include "pd_api.h"

int update(void* ud);
void setPDPtr(PlaydateAPI* p);
void setupGame(void);

#endif /* game_h */
