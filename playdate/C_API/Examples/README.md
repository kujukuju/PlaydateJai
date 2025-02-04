### C API Examples

This folder contains projects demonstrating usage of the C interface to the Playdate runtime. The code is not extensively commented but hopefully gives an idea how some of the interfaces work. See "Inside Playdate with C" for more information on how to build these projects using Xcode, Visual Studio, Make and CMake.


**3D library** : A small 3D library showing how to build Lua libraries in C for performance

**Exposure** : Another example of using C code for performance, implements a Lua function that returns the number of white pixels in an image

**Hello World** : A barebones C demo and a useful starting point for development

**JSON** : A demonstration of the very flexible (but also rather complex) JSON parser interface

**Life** : Conway's Game of Life, the nerd classic

**Particles** : An C API example that creates a custom object type, exposes functions to lua and passes data back and forth between C and Lua. This demonstrates using C for efficient low-level code and Lua for top-level UI code where ease of development is more useful.

**bach.mid** : Uses the sound API to create an instrument and load a midi file to play on it

**Sprite Game** : A simple shoot-em-up built entirely in C
