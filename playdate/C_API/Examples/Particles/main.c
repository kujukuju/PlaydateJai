//
//  main.c
//  Extension
//
//  Created by Dan Messing on 5/01/18.
//  Copyright (c) 2018 Panic, Inc. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "pd_api.h"

static PlaydateAPI* pd = NULL;

static int particlelib_dealloc(lua_State* L);
static int particlelib_newobject(lua_State* L);
static int particlelib_setNumberOfParticles(lua_State* L);
static int particlelib_particleCountInRect(lua_State* L);
static int particlelib_update(lua_State* L);
static int particlelib_draw(lua_State* L);

static const lua_reg particlesLib[] =
{
	{ "__gc",					particlelib_dealloc },
	{ "new", 					particlelib_newobject },
	{ "setNumberOfParticles", 	particlelib_setNumberOfParticles },
	{ "particleCountInRect", 	particlelib_particleCountInRect },
	{ "update",					particlelib_update },
	{ "draw", 					particlelib_draw },
	{ NULL, NULL }
};

static LCDBitmap *flakes[4];

#ifdef _WINDLL
__declspec(dllexport)
#endif
int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	(void)arg;

	if ( event == kEventInitLua )
	{
		pd = playdate;

		const char* err;

		if ( !pd->lua->registerClass("particlelib.particles", particlesLib, NULL, 0, &err) )
			pd->system->logToConsole("%s:%i: registerClass failed, %s", __FILE__, __LINE__, err);

		srand(pd->system->getSecondsSinceEpoch(NULL));

		// load particle images
		const char *outErr = NULL;
		const char *path1 = "images/snowflake1";
		const char *path2 = "images/snowflake2";
		const char *path3 = "images/snowflake3";
		const char *path4 = "images/snowflake4";
		flakes[0] = pd->graphics->loadBitmap(path1, &outErr);
		flakes[1] = pd->graphics->loadBitmap(path2, &outErr);
		flakes[2] = pd->graphics->loadBitmap(path3, &outErr);
		flakes[3] = pd->graphics->loadBitmap(path4, &outErr);
	}

	return 0;
}


// particles class

typedef struct
{
	float x;
	int y;
	int w;
	int h;
	int speed;
	float drift;
	int type;
} Particle;

typedef struct
{
	int count;
	Particle *particles;
} Particles;


void particles_setCount(Particles *p, int count)
{
	Particle *oldParticles = p->particles;
	int startIndex = 0;

	if ( oldParticles != NULL ) {
		int oldCount = p->count;
		startIndex = ( count > oldCount ) ? oldCount : count;
	}

	p->count = count;
	p->particles = pd->system->realloc(NULL, (sizeof(Particle) * count));	// alloc space for the new particles

	int i;
	for ( i = startIndex; i < count; i++ )
	{
		Particle *particle = &p->particles[i];
		particle->x = (rand() % 441) - 20.0f;
		particle->y = (rand() % 241) - 240.0f;
		particle->w = 19;
		particle->h = 21;
		particle->type = rand() % 4;
		particle->speed = rand() % 4 + 1;
		particle->drift = (float)((rand() % 5) - 2.0) / 10.0f;
	}

	// copy existing particle values to the new particles
	for ( i = 0; i < startIndex; i++ )
	{
		p->particles[i] = oldParticles[i];
	}

	if ( oldParticles != NULL ) {
		pd->system->realloc(oldParticles, 0);	// free old particles
	}
}


static int particlelib_dealloc(lua_State* L)
{
	Particles* p = pd->lua->getArgObject(1, "particlelib.particles", NULL);

	(void)L;

	// realloc with size 0 to free
	pd->system->realloc(p->particles, 0);
	pd->system->realloc(p, 0);

	return 0;
}


static int particlelib_newobject(lua_State* L)
{
	int count = pd->lua->getArgInt(1);
	Particles* p = pd->system->realloc(NULL, sizeof(Particles));

	(void)L;

	p->count = 0;
	p->particles = NULL;
	particles_setCount(p, count);
	pd->lua->pushObject(p, "particlelib.particles", 0);
	return 1;
}


static int particlelib_setNumberOfParticles(lua_State* L)
{
	Particles* p = pd->lua->getArgObject(1, "particlelib.particles", NULL);
	int count = pd->lua->getArgInt(2);

	(void)L;

	particles_setCount(p, count);

	return 0;
}


static int particlelib_particleCountInRect(lua_State* L)
{
	Particles* p = pd->lua->getArgObject(1, "particlelib.particles", NULL);
	int x = pd->lua->getArgInt(2);
	int y = pd->lua->getArgInt(3);
	int w = pd->lua->getArgInt(4);
	int h = pd->lua->getArgInt(5);
	//	int type = pd->lua->getArgInt(6);	// could also filter for type here

	int result = 0;

	(void)L;

	int i;
	for ( i = 0; i < p->count; i++ )
	{
		Particle *particle = &p->particles[i];
		if ( !(particle->y >= y+h || particle->y + particle->h <= y || particle->x >= x+w || particle->x + particle->w <= x) ) {
			result += 1;
		}
	}

	pd->lua->pushInt(result);

	return 1;
}


static int particlelib_update(lua_State* L)
{
	Particles* p = pd->lua->getArgObject(1, "particlelib.particles", NULL);

	(void)L;

	int i;
	for ( i = 0; i < p->count; i++ )
	{
		Particle *particle = &p->particles[i];
		particle->drift += (float)(((rand() % 5) - 2.0f) / 10.0f);
		particle->y += particle->speed;
		particle->x += particle->drift;

		if ( particle->y > 240 )	// if the particle is off the screen, move it back to the top
		{
			particle->y = -22;
			particle->x = (rand() % 441) - 20;
			particle->drift = (float)((rand() % 5) - 2.0f) / 10.0f;
		}
	}

	return 0;
}


static int particlelib_draw(lua_State* L)
{
	Particles* p = pd->lua->getArgObject(1, "particlelib.particles", NULL);

	(void)L;

	pd->graphics->clear(kColorBlack);

	int i;
	for ( i = 0; i < p->count; i++ )
	{
		Particle *particle = &p->particles[i];
		pd->graphics->setDrawMode(kDrawModeInverted);
		pd->graphics->drawBitmap(flakes[particle->type], round(particle->x), particle->y, kBitmapUnflipped);
	}

	return 0;
}
