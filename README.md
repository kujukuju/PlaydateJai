
## Setup

Add PlaydateSDK/bin to your path.

Add Mirror to your path.

## Jai ARM32 Notes

Even if you have a function struct member #place aligned with a value that's correct. The default alignment will be 8 if jai thinks something is in there that is of size 8, like a pointer.

So you need to #align not only normal struct members but also the #place'ed members.

Passing functions through parameters is totally fine. If you try to convert the function to a u32 or something as a "pointer" and pass it it will get compiled differently and break.

Calling library functions with pointers is potentially fine somehow? But passing a function that takes a pointer as an argument into a library function isn't fine.

Wait maybe the entire problem this whole time was struct alignment.......

## TODO

* if I have 3 sets of fake string arrays it crashes

* string constants I think don't work because they rely on global memory or something?

* DO NOT CREATE GLOBAL DATA THAT YOU DON'T MANUALLY INITIALIZE UNTIL I FIX THAT PROBLEM!!!

* map the 64 bit module_windows functions to 32 bit equivalents... just for sizes though I think

* I can't properly write into the flash memory, I don't know why...
* I think the solution to this is to create a jai metaprogram that will fill in the data at start time

* pausing doesn't work I think, it crashes?

* fix one_time_init
* fix write_string
* fix write_strings
* fix write_nonnegative_number
* fix write_number
* fix assert

## Random Notes

calling pdrealloc from inside the a context crashes without explanation
calling pdrealloc from inside a #c_call is fine
this was beacuse after you push context I'm pretty sure somehow magically the contact is tracking the call stack
and you have to disable stack_trace in the jai build options
