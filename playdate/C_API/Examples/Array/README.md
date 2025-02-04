
Array
---------
An extension example that creates a custom type that mimics a Lua table, exposes functions to lua and passes data back and forth between c and lua.

Configuration
-------------
You must have `arm-gcc` installed to build an extension. In the makefile, change the `GCC` variable to point at the correct path on your system.

Using Xcode is not required, and the project can be built from the command line using:
`make`
