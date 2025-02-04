//
//  main.c
//  bach.mid
//
//  Created by Dave Hayden on 5/10/21.
//  Copyright (c) 2021 Panic, Inc. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>

#include "pd_api.h"

PlaydateAPI* pd = NULL;
const struct playdate_sound* snd = NULL;
const struct playdate_graphics* gfx = NULL;

SoundSequence* seq = NULL;
int laststep = -1;

int update(void* ud);

#ifdef _WINDLL
__declspec(dllexport)
#endif
int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	(void)arg;
	
	if ( event == kEventInit )
	{
		pd = playdate;
		snd = playdate->sound;
		gfx = playdate->graphics;
		
		pd->system->setUpdateCallback(update, NULL);

		seq = snd->sequence->newSequence();
		snd->sequence->loadMIDIFile(seq, "bach.mid"); // from http://www.jsbach.net/midi/midi_goldbergvariations.html
		
		// usually you'd assign a different instrument to each track, but in this file
		// the tracks are separate parts played on the same instrument
		
		PDSynthInstrument* inst = snd->instrument->newInstrument();
		snd->instrument->setVolume(inst, 0.2, 0.2);
		snd->channel->addSource(snd->getDefaultChannel(), (SoundSource*)inst);

		int n = snd->sequence->getTrackCount(seq);
		
		PDSynth* synth = snd->synth->newSynth();
		AudioSample* piano = snd->sample->load("piano");
		snd->synth->setSample(synth, piano, 0, 0);
		
		for ( int i = 0; i < n; ++i )
		{
			SequenceTrack* track = snd->sequence->getTrackAtIndex(seq, i);
			snd->track->setInstrument(track, inst);

			for ( int p = snd->track->getPolyphony(track); p > 0; --p )
				snd->instrument->addVoice(inst, snd->synth->copy(synth), 0, 127, 0);
		}
		
		snd->sequence->play(seq, NULL, NULL);
	}
	
	return 0;
}

int
update(void* ud)
{
	(void)ud; // unused

	int step = snd->sequence->getCurrentStep(seq, NULL);
	
	if ( step > laststep )
	{
		// draw the previous frame one pixel to the left
		gfx->drawBitmap(gfx->getDisplayBufferBitmap(), -1, 0, kBitmapUnflipped);
		// and clear the end column
		gfx->fillRect(399, 0, 1, 240, kColorWhite);
		
		int n = snd->sequence->getTrackCount(seq);

		for ( int i = 0; i < n; ++i )
		{
			SequenceTrack* track = snd->sequence->getTrackAtIndex(seq, i);
			int idx = snd->track->getIndexForStep(track, laststep+1);
			uint32_t s;
			MIDINote note;
			
			while ( snd->track->getNoteAtIndex(track, idx++, &s, NULL, &note, NULL) && s <= step )
				gfx->fillRect(399, 240 - 3*(note-20), 1, 3, kColorBlack);
		}
	}
	
	laststep = step;
	
	pd->system->drawFPS(0,0);
	return 1;
}
