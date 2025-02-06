// @Cleanup: Get rid of the importing of POSIX, as that is way too much.
#load "posix.jai";

get_working_directory :: () -> result: string {  // Returns the empty string on failure.
    PATH_MAX :: 4096; 
    buf: [PATH_MAX] u8;
    result := getcwd(buf.data, buf.count);

    // getcwd is supposed to malloc its return value if buf is null,
    // but for some reason I was getting invalid free() on some versions
    // of Ubuntu. Also it is probably better not to malloc. That said,
    // we are adding this PATH_MAX limit, but, we don't know that such a
    // limit does not exist internally to getcwd anyway. But, this is
    // just kind of bleah.
/*
    crt    :: #system_library "libc";
    c_free :: (memory: *void) #foreign crt "free";

    defer c_free(cwd);
*/
    if !result {
        log_error("Unable to get the current directory: %.", errno());
        return "";
    }
    
    return copy_temporary_string(to_string(buf.data));
}

