
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pd_api.h"

PlaydateAPI* pd = NULL;

char* pd_strdup(const char* str)
{
	size_t len = strlen(str);
	char* s = pd->system->realloc(NULL, len+1);
	memcpy(s, str, len);
	s[len] = '\0';
	return s;
}

void decodeError(json_decoder* decoder, const char* error, int linenum)
{
	pd->system->logToConsole("decode error line %i: %s", linenum, error);
}

const char* typeToName(json_value_type type)
{
	switch ( type )
	{
		case kJSONNull: return "null";
		case kJSONTrue: return "true";
		case kJSONFalse: return "false";
		case kJSONInteger: return "integer";
		case kJSONFloat: return "float";
		case kJSONString: return "string";
		case kJSONArray: return "array";
		case kJSONTable: return "table";
		default: return "???";
	}
}

void willDecodeSublist(json_decoder* decoder, const char* name, json_value_type type)
{
	pd->system->logToConsole("%s willDecodeSublist %s %s", decoder->path, typeToName(type), name);
}

int shouldDecodeTableValueForKey(json_decoder* decoder, const char* key)
{
	pd->system->logToConsole("%s shouldDecodeTableValueForKey %s", decoder->path, key);
	return 1;
}

void didDecodeTableValue(json_decoder* decoder, const char* key, json_value value)
{
	pd->system->logToConsole("%s didDecodeTableValue %s %s", decoder->path, key, typeToName(value.type));
}

int shouldDecodeArrayValueAtIndex(json_decoder* decoder, int pos)
{
	pd->system->logToConsole("%s shouldDecodeArrayValueAtIndex %i", decoder->path, pos);
	return 1;
}

void didDecodeArrayValue(json_decoder* decoder, int pos, json_value value)
{
	pd->system->logToConsole("%s didDecodeArrayValue %i %s", decoder->path, pos, typeToName(value.type));
}

void* didDecodeSublist(json_decoder* decoder, const char* name, json_value_type type)
{
	pd->system->logToConsole("%s didDecodeSublist %s %s", decoder->path, typeToName(type), name);
	return NULL;
}

int update(void* ud)
{
	(void)ud; // unused
	return 1;
}

#ifdef _WINDLL
__declspec(dllexport)
#endif
int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	(void)arg;

	if ( event == kEventInit )
	{
		pd = playdate;
		pd->system->setUpdateCallback(update, NULL);

		json_decoder decoder =
		{
			.decodeError = decodeError,
			.willDecodeSublist = willDecodeSublist,
			.shouldDecodeTableValueForKey = shouldDecodeTableValueForKey,
			.didDecodeTableValue = didDecodeTableValue,
			.shouldDecodeArrayValueAtIndex = shouldDecodeArrayValueAtIndex,
			.didDecodeArrayValue = didDecodeArrayValue,
			.didDecodeSublist = didDecodeSublist
		};
		
		SDFile* file = pd->file->open("test.json", kFileRead);
		
		json_value val;

		pd->json->decode(&decoder, (json_reader){ .read = (json_readFunc*)pd->file->read, .userdata = file }, &val);
		pd->file->close(file);
	}
	
	return 0;
}
