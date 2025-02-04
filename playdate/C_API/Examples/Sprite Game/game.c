//
//  game.c
//  Extension OS X
//
//  Created by Dan Messing on 1/26/18.
//  Copyright © 2018 Panic, Inc. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include "game.h"


static PlaydateAPI* pd = NULL;

// game state
int score = 0;
int maxBackgroundPlanes = 10;
int backgroundPlaneCount = 0;
int bgPlaneHeight = 0;

int maxEnemies = 10;
int enemyCount = 0;
int enemyPlaneHeight = 0;

LCDSprite *player = NULL;
int bulletHeight = 0;

// background
LCDSprite *bgSprite = NULL;
LCDBitmap *bgImage = NULL;
int bgY = 0;
int bgH = 0;

// cached images
LCDBitmap **explosionImages = NULL;
LCDBitmap *bulletImage = NULL;;
LCDBitmap *enemyPlaneImage = NULL;;
LCDBitmap *backgroundPlaneImage = NULL;;


typedef enum {
	kPlayer = 0,
	kPlayerBullet = 1,
	kEnemyPlane = 2,
} SpriteType;


void setPDPtr(PlaydateAPI* p) {
	pd = p;
}


LCDBitmap *loadImageAtPath(const char *path)
{
	const char *outErr = NULL;
	LCDBitmap *img = pd->graphics->loadBitmap(path, &outErr);
	if ( outErr != NULL ) {
		pd->system->logToConsole("Error loading image at path '%s': %s", path, outErr);
	}
	return img;
}


void preloadImages(void)
{
	explosionImages = pd->system->realloc(NULL, sizeof(LCDBitmap *) * 8);

	uint8_t i = 0;
	char *path = NULL;

	for ( i = 0; i < 8; i++ )
	{
		pd->system->formatString(&path, "images/explosion/%d", i+1);
		if ( path != NULL )
		{
			explosionImages[i] = loadImageAtPath(path);
			pd->system->realloc(path, 0);
			path = NULL;
		}
		else
		{
			pd->system->logToConsole("Error preloading images");
		}
	}

	bulletImage = loadImageAtPath("images/doubleBullet");
	enemyPlaneImage = loadImageAtPath("images/plane1");
	backgroundPlaneImage = loadImageAtPath("images/plane2");
}



// -- Background Sprite -- //

static void drawBackgroundSprite(LCDSprite* sprite, PDRect bounds, PDRect drawrect)
{
	pd->graphics->drawBitmap(bgImage, 0, bgY, 0);
	pd->graphics->drawBitmap(bgImage, 0, bgY-bgH, 0);
}

static void updateBackgroundSprite(LCDSprite* s)
{
	bgY += 1;
	if ( bgY > bgH ) {
		bgY = 0;
	}

	pd->sprite->markDirty(bgSprite);
}

static void setupBackground(void)
{
	bgSprite = pd->sprite->newSprite();

	bgImage = loadImageAtPath("images/background");
	pd->graphics->getBitmapData(bgImage, NULL, &bgH, NULL, NULL, NULL);

	pd->sprite->setUpdateFunction(bgSprite, updateBackgroundSprite);
	pd->sprite->setDrawFunction(bgSprite, drawBackgroundSprite);

	PDRect bgBounds = PDRectMake(0, 0, 400, 240);
	pd->sprite->setBounds(bgSprite, bgBounds);

	pd->sprite->setZIndex(bgSprite, 0);

	pd->sprite->addSprite(bgSprite);
}


// -- Explosions -- //

static void updateExplosion(LCDSprite* s)
{
	int frameNumber = pd->sprite->getTag(s) + 1;

	if ( frameNumber > 7 )
	{
		pd->sprite->removeSprite(s);
		pd->sprite->freeSprite(s);
	}
	else
	{
		pd->sprite->setTag(s, frameNumber);

		LCDBitmap *frameImage = explosionImages[frameNumber];
		if ( frameImage == NULL ) {
			pd->system->logToConsole("NULL FRAME %d", frameNumber);
		}
		pd->sprite->setImage(s, explosionImages[frameNumber], kBitmapUnflipped);
	}
}

static void createExplosion(int x, int y)
{
	LCDSprite *s = pd->sprite->newSprite();

	pd->sprite->setUpdateFunction(s, updateExplosion);

	pd->sprite->setImage(s, explosionImages[0], kBitmapUnflipped);

	pd->sprite->moveTo(s, x, y);

	pd->sprite->setZIndex(s, 2000);
	pd->sprite->addSprite(s);

	pd->sprite->setTag(s, 1);	// using tag here for the frame number of the explosion animation
}



// -- Enemy Planes -- //

static void updateEnemyPlane(LCDSprite* s)
{
	float x, y;
	pd->sprite->getPosition(s, &x, &y);

	int newY = y + 4;

	if ( newY > 400 + enemyPlaneHeight )	// enemy plane flew offscreen
	{
		pd->sprite->removeSprite(s);
		pd->sprite->freeSprite(s);
		enemyCount -= 1;
	} else {
		pd->sprite->moveTo(s, x, newY);
	}
}

static SpriteCollisionResponseType enemyPlaneCollisionResponse(LCDSprite* sprite, LCDSprite* other)
{
	pd->system->logToConsole("return Overlap from Enemy Plane!");
	return kCollisionTypeOverlap;
}

static LCDSprite* createEnemyPlane(void)
{
	LCDSprite *plane = pd->sprite->newSprite();

	pd->sprite->setUpdateFunction(plane, updateEnemyPlane);
	pd->sprite->setCollisionResponseFunction(plane, enemyPlaneCollisionResponse);

	int w;
	pd->graphics->getBitmapData(enemyPlaneImage, &w, &enemyPlaneHeight, NULL, NULL, NULL);
	pd->sprite->setImage(plane, enemyPlaneImage, kBitmapUnflipped);

	PDRect cr = PDRectMake(0, 0, w, enemyPlaneHeight);
	pd->sprite->setCollideRect(plane, cr);

	pd->sprite->moveTo(plane, (rand() % 400) - w/2, -(rand() % 30) - enemyPlaneHeight);

	pd->sprite->setZIndex(plane, 500);
	pd->sprite->addSprite(plane);

	pd->sprite->setTag(plane, kEnemyPlane);	// tag to identify enemy planes during collision detection

	enemyCount += 1;

	return plane;
}

static void destroyEnemyPlane(LCDSprite *plane)
{
	float x, y;
	pd->sprite->getPosition(plane, &x, &y);
	createExplosion(x, y);

	pd->sprite->removeSprite(plane);
	pd->sprite->freeSprite(plane);
	enemyCount -= 1;
}

static void spawnEnemyIfNeeded(void)
{
	if ( enemyCount < maxEnemies )
	{
		if ( rand() % (120/maxEnemies) == 0 )
		{
			(void)createEnemyPlane();
		}
	}
}


// -- Background Planes -- //

static void updateBackgroundPlane(LCDSprite* s)
{
	float x, y;
	pd->sprite->getPosition(s, &x, &y);

	int newY = y + 2;

	if ( newY > 400 + bgPlaneHeight )
	{
		pd->sprite->removeSprite(s);
		pd->sprite->freeSprite(s);
		backgroundPlaneCount -= 1;
	}
	else
	{
		pd->sprite->moveTo(s, x, newY);
	}
}

static LCDSprite* createBackgroundPlane(void)
{
	LCDSprite *plane = pd->sprite->newSprite();

	pd->sprite->setUpdateFunction(plane, updateBackgroundPlane);

	int w;
	pd->graphics->getBitmapData(backgroundPlaneImage, &w, &bgPlaneHeight, NULL, NULL, NULL);

	pd->sprite->setImage(plane, backgroundPlaneImage, kBitmapUnflipped);

	pd->sprite->moveTo(plane, (rand() % 400) - w/2, -bgPlaneHeight);

	pd->sprite->setZIndex(plane, 100);
	pd->sprite->addSprite(plane);

	backgroundPlaneCount += 1;

	return plane;
}

static void spawnBackgroundPlaneIfNeeded(void)
{
	if ( backgroundPlaneCount < maxBackgroundPlanes )
	{
		if ( rand() % (120/maxBackgroundPlanes) == 0 )
		{
			(void)createBackgroundPlane();
		}
	}
}



// -- Player Plane -- //

static SpriteCollisionResponseType playerFireCollisionResponse(LCDSprite* sprite, LCDSprite* other)
{
	return kCollisionTypeOverlap;
}

static void updatePlayerFire(LCDSprite* s)
{
	float x, y;
	pd->sprite->getPosition(s, &x, &y);

	int newY = y - 20;

	if ( newY < -bulletHeight ) 		// bullet is offscreen, remove it
	{
		pd->sprite->removeSprite(s);
		pd->sprite->freeSprite(s);
	}
	else
	{
		int len;
		SpriteCollisionInfo *cInfo = pd->sprite->moveWithCollisions(s, x, newY, NULL, NULL, &len);

		int i;
		int hit = 0;

		for ( i = 0; i < len; i++ )
		{
			SpriteCollisionInfo info = cInfo[i];

			if ( pd->sprite->getTag(info.other) == kEnemyPlane )
			{
				destroyEnemyPlane(info.other);
				hit = 1;
				score += 1;
				pd->system->logToConsole("Score: %d", score);
			}
		}

		if ( hit )
		{
			pd->sprite->removeSprite(s);
			pd->sprite->freeSprite(s);
		}

		pd->system->realloc(cInfo, 0); 	// free memory of array returned by moveWithCollisions()
	}
}

static void playerFire(void)
{
	LCDSprite *bullet = pd->sprite->newSprite();

	pd->sprite->setUpdateFunction(bullet, updatePlayerFire);

	int w;
	pd->graphics->getBitmapData(bulletImage, &w, &bulletHeight, NULL, NULL, NULL);

	pd->sprite->setImage(bullet, bulletImage, kBitmapUnflipped);

	PDRect cr = PDRectMake(0, 0, w, bulletHeight);
	pd->sprite->setCollideRect(bullet, cr);

	pd->sprite->setCollisionResponseFunction(bullet, playerFireCollisionResponse);

	PDRect bounds = pd->sprite->getBounds(player);

	pd->sprite->moveTo(bullet, bounds.x + bounds.width/2, bounds.y);
	pd->sprite->setZIndex(bullet, 999);
	pd->sprite->addSprite(bullet);

	pd->sprite->setTag(bullet, kPlayerBullet);
}

static SpriteCollisionResponseType playerCollisionResponse(LCDSprite* sprite, LCDSprite* other)
{
	return kCollisionTypeOverlap;
}

static void updatePlayer(LCDSprite* s)
{
	PDButtons current;
	pd->system->getButtonState(&current, NULL, NULL);

	int dx = 0;
	int dy = 0;

	if ( current & kButtonUp ) {
		dy = -4;
	} else if ( current & kButtonDown ) {
		dy = 4;
	}
	if ( current & kButtonLeft ) {
		dx = -4;
	} else if ( current & kButtonRight ) {
		dx = 4;
	}

	float x, y;
	pd->sprite->getPosition(s, &x, &y);

	int len;
	SpriteCollisionInfo *cInfo = pd->sprite->moveWithCollisions(s, x + dx, y + dy, NULL, NULL, &len);

	int i;
	for ( i = 0; i < len; i++ )
	{
		SpriteCollisionInfo info = cInfo[i];

		if ( pd->sprite->getTag(info.other) == kEnemyPlane ) {
			destroyEnemyPlane(info.other);
			score -= 1;
			pd->system->logToConsole("Score: %d", score);
		}
	}

	pd->system->realloc(cInfo, 0); // caller is responsible for freeing memory of array returned by moveWithCollisions()
}

static LCDSprite* createPlayer(int centerX, int centerY)
{
	LCDSprite *plane = pd->sprite->newSprite();

	pd->sprite->setUpdateFunction(plane, updatePlayer);

	LCDBitmap *planeImage = loadImageAtPath("images/player");
	int w, h;
	pd->graphics->getBitmapData(planeImage, &w, &h, NULL, NULL, NULL);

	pd->sprite->setImage(plane, planeImage, kBitmapUnflipped);

	PDRect cr = PDRectMake(5, 5, w-10, h-10);
	pd->sprite->setCollideRect(plane, cr);
	pd->sprite->setCollisionResponseFunction(plane, playerCollisionResponse);

	pd->sprite->moveTo(plane, centerX, centerY);

	pd->sprite->setZIndex(plane, 1000);
	pd->sprite->addSprite(plane);

	pd->sprite->setTag(plane, kPlayer);

	backgroundPlaneCount += 1;

	return plane;
}


// game initialization
void setupGame(void)
{
	srand(pd->system->getSecondsSinceEpoch(NULL));

	setupBackground();
	player = createPlayer(200, 180);
	preloadImages();
}

// cranking the crank changes the maximum number of enemy planes allowed
void checkCrank(void)
{
	float change = pd->system->getCrankChange();

	if ( change > 1 ) {
		maxEnemies += 1;
		if ( maxEnemies > 119 ) { maxEnemies = 119; }
		pd->system->logToConsole("Maximum number of enemy planes: %d", maxEnemies);
	} else if ( change < -1 ) {
		maxEnemies -= 1;
		if ( maxEnemies < 0 ) { maxEnemies = 0; }
		pd->system->logToConsole("Maximum number of enemy planes: %d", maxEnemies);
	}
}


void checkButtons(void)
{
	PDButtons pushed;
	pd->system->getButtonState(NULL, &pushed, NULL);

	if ( pushed & kButtonA || pushed & kButtonB )
	{
		playerFire();
	}
}


// main update function
int update(void* ud)
{
	checkButtons();
	checkCrank();

	spawnEnemyIfNeeded();
	spawnBackgroundPlaneIfNeeded();

	pd->sprite->updateAndDrawSprites();

	return 1;
}
