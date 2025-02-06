#load "posix.jai";

store_in_integer :: (str: string) -> s32 {
    assert(str.count <= 4);
    // store contents of a string within an int
    // attempt to mimick what C does with single-quote
    // strings. For example:
    // int c = 'sora';
    // The value 0x736F7261 would be written to "c"

    slice: [] u8;
    slice.data = str.data;
    slice.count = str.count;
    out: s32;
    for slice {
        bits := ((slice.count - it_index) -1) * 8;
        out = out | cast(s32) ((cast(u32) it) << bits);
    }

    return out;
}


// Returns a temporary string.
get_working_directory :: () -> string {
    cwd := getcwd(null, 0);

    defer c_free(cwd);
    return copy_temporary_string(to_string(cwd));
}

// macOS API

IID :: struct {};
LPVOID :: *void;

AbsoluteTime :: u64;

_NSGetExecutablePath :: (buf: *u8, bufsize: *u32) -> s32 #foreign libc;

// this stuff has been deprecated for awhile it seems but Apple still lists this API as their recommended way
// to get GL addresses. see :NSGLGetProcAddress:
NSSymbol :: *void; // typedef'd to a pointer to an internal __NSSymbol struct
NSIsSymbolNameDefined :: (symbolName: *u8) -> bool #foreign libc #deprecated "use dlysym()";
NSLookupAndBindSymbol :: (symbolName: *u8) -> NSSymbol #foreign libc #deprecated "use dlysym()";
NSAddressOfSymbol     :: (symbol: NSSymbol) -> *void #foreign libc #deprecated "use dlysym()";


FourCharCode :: u32;

OSStatus :: s32;
OSType :: FourCharCode;

noErr :OSStatus: 0;

#scope_file

libc :: #system_library "libc";
c_free   :: (memory: *void)                        #foreign libc "free"; // :CFree:

