//
//  game.c
//  Extension OS X
//
//  Created by Dan Messing on 8/15/23.
//  Copyright © 2023 Panic, Inc. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include "game.h"

static PlaydateAPI* pd = NULL;

float dt = 0.05f;

float p1_velocityX = 60.0f;
float p1_velocityY = 50.0f;

float p2_velocityX = 20.0f;
float p2_velocityY = 30.0f;

float rayRotation = 0.0f;

LCDSprite *player1 = NULL;
LCDSprite *player2 = NULL;

unsigned int ms = 0;
unsigned int lastFrameTime = 0;
#define MAXSAMPLES 200
int tickindex = 0;
int ticksum = 50 * MAXSAMPLES;
int ticklist[MAXSAMPLES] = {};
int rate = 24;


void setPDPtr(PlaydateAPI* p) {
	pd = p;
}

static SpriteCollisionResponseType playerCollisionResponse(LCDSprite* sprite, LCDSprite* other)
{
	return kCollisionTypeBounce;
}

static void updatePlayer(LCDSprite* sprite)
{
	LCDSprite *s = NULL;
	LCDSprite *other = NULL;
	
	float dx, dy;
	
	if ( sprite == player1 )
	{
		s = player1;
		dx = p1_velocityX * dt;
		dy = p1_velocityY * dt;
		other = player2;
	}
	else
	{
		s = player2;
		dx = p2_velocityX * dt;
		dy = p2_velocityY * dt;
		other = player1;
	}
	
	float x, y;
	pd->sprite->getPosition(s, &x, &y);
	
	if ( dx != 0 || dy != 0 )
	{
		int len;
		float ax, ay;
		SpriteCollisionInfo *colls = pd->sprite->moveWithCollisions(s, x + dx, y + dy, &ax, &ay, &len);
		
		int i;
		for ( i = 0; i < len; i++ )
		{
			SpriteCollisionInfo *cInfo = &colls[i];
			
			if ( cInfo->normal.x != 0 )
			{
				if ( sprite == player1 )
					p1_velocityX = -p1_velocityX;
				else
					p2_velocityX = -p2_velocityX;
			}
			
			if ( cInfo->normal.y != 0 )
			{
				if ( sprite == player1 )
					p1_velocityY = -p1_velocityY;
				else
					p2_velocityY = -p2_velocityY;
			}
		}
		
		if ( colls != NULL )
			pd->system->realloc(colls, 0); // caller is responsible for freeing memory of array returned by moveWithCollisions()
	}
}


void drawPlayer(LCDSprite* sprite, PDRect bounds, PDRect drawrect)
{
	pd->graphics->fillRect(bounds.x, bounds.y, bounds.width, bounds.height, kColorBlack);
}


static LCDSprite* createPlayer(int x, int y, int w, int h)
{
	LCDSprite *player = pd->sprite->newSprite();

	pd->sprite->setUpdateFunction(player, updatePlayer);

	PDRect bounds = PDRectMake(x - w/2, y-h/2, w, h);
	pd->sprite->setBounds(player, bounds);
	
	pd->sprite->setDrawFunction(player, drawPlayer);

	PDRect cr = PDRectMake(0, 0, w, h);
	pd->sprite->setCollideRect(player, cr);
	pd->sprite->setCollisionResponseFunction(player, playerCollisionResponse);	

	pd->sprite->setZIndex(player, 1000);
	pd->sprite->addSprite(player);

	return player;
}


void drawBlock(LCDSprite* sprite, PDRect bounds, PDRect drawrect)
{
	pd->graphics->drawRect(bounds.x, bounds.y, bounds.width, bounds.height, kColorBlack);
}


static LCDSprite* createBlock(int x, int y, int w, int h)
{
	LCDSprite *block = pd->sprite->newSprite();

	PDRect bounds = PDRectMake(x, y, w, h);
	pd->sprite->setBounds(block, bounds);
	
	pd->sprite->setDrawFunction(block, drawBlock);

	PDRect cr = PDRectMake(0, 0, w, h);
	pd->sprite->setCollideRect(block, cr);

	pd->sprite->addSprite(block);

	return block;
}


void drawRays(LCDSprite *player)
{	
	int i, extraAngle, len;
	float startX, startY, endX, endY, rads;
	pd->sprite->getPosition(player, &startX, &startY);
	
	for ( extraAngle = 0; extraAngle < 360; extraAngle = extraAngle + 30 )
	{
		rads = (rayRotation + extraAngle) * 3.1415f / 180.0f;
		int endX = floorf(500 * cosf(rads)) + startX;
		int endY = floorf(500 * sinf(rads)) + startY;
		
		SpriteQueryInfo *results = pd->sprite->querySpriteInfoAlongLine(startX, startY, endX, endY, &len);
		
		for ( i = 0; i < len; i++ )
		{
			SpriteQueryInfo *info = &results[i];
			if ( info->sprite != player1 && info->sprite != player2 )
			{
				int r = 6 - 10*info->ti1;
				pd->graphics->drawEllipse(info->entryPoint.x-r, info->entryPoint.y-r, r*2, r*2, 3, 0.0f, 360.0f, kColorBlack);
				r = 5 - 10*info->ti1;
				pd->graphics->drawEllipse(info->exitPoint.x-r, info->exitPoint.y-r, r*2, r*2, 1, 0.0f, 360.0f, kColorBlack);
			}
		}
		
		pd->graphics->drawLine(startX, startY, endX, endY, 1, kColorBlack);
		
		if ( results != NULL )
			pd->system->realloc(results, 0);
	}
}


// game initialization
void setupGame(void)
{
	pd->display->setRefreshRate(50);
	
	ms = pd->system->getCurrentTimeMilliseconds();
	lastFrameTime = ms;
	
	int i;
	for ( i = 0; i < MAXSAMPLES; i++ )
	{
		ticklist[i] = 50;
	}	

	player1 = createPlayer(190, 223, 20, 20);
	player2 = createPlayer(100, 40, 16, 16);
	
	int borderSize = 5;
	float displayWidth = 400;
	float displayHeight = 240;
	
	createBlock(0, 0, displayWidth, borderSize);
	createBlock(0, borderSize, borderSize, displayHeight-borderSize*2);
	createBlock(displayWidth-borderSize, borderSize, borderSize, displayHeight-borderSize*2);
	createBlock(0, displayHeight-borderSize, displayWidth, borderSize);
	
	srand(pd->system->getSecondsSinceEpoch(NULL));
	
	for ( i = 0; i < 6; i++ )
	{
		createBlock((rand() % 270) + 50,
				    (rand() % 100) + 50,
					(rand() % 30) + 10,
					(rand() % 90) + 10);
	}
}


float calcAverageTick(int newtick)
{
	ticksum = ticksum - ticklist[tickindex];
	ticksum = ticksum + newtick;
	ticklist[tickindex++] = newtick;
	if ( tickindex == MAXSAMPLES )
		tickindex = 0;
	return (float)ticksum / (float)MAXSAMPLES;
}


void drawFPS(int x, int y)
{
	int currentTime = pd->system->getCurrentTimeMilliseconds();
	float averageTick = calcAverageTick(currentTime - lastFrameTime);
	int fps = (int)floorf((1000.0f/averageTick) + 0.5f);
	lastFrameTime = currentTime;
	
	char fps_text[3] = "99";
	fps_text[0] = fps >= 10 ? '0' + fps/10 : ' ';
	fps_text[1] = '0' + fps%10;
		
	pd->graphics->drawText(fps_text, strlen(fps_text), kASCIIEncoding, x, y); // not drawing sometimes??
}


// main update function
int update(void* ud)
{
	pd->sprite->updateAndDrawSprites();
	drawRays(player1);
	drawRays(player2);
	
	drawFPS(8, 8);
	
	rayRotation = rayRotation + 0.5f;

	return 1;
}
