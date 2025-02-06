
pd_context: Context;

// TODO can I make this eventHandler and elsewhere another name?
playdate_setup :: (pd: *PlaydateAPI) #c_call {
    // #if OS == .KRAMPOS || OS == .NN_SWITCH {
    //     // you have to manually assign the flash memory in embedded devices I guess
    //     dst := __data_start__;
    //     src := __etext;
    //     end := __data_end__;
    //     while dst < end {
    //         dst.* = src.*;
    //         dst += 1;
    //         src += 1;
    //     }

    //     dst = __bss_start__;
    //     end = __bss_end__;
    //     while dst < end {
    //         dst.* = 0;
    //         dst += 1;
    //     }
    // }

    pd_context = .{};
    pd_temporary_storage = .{};
    pd_temporary_storage_data_empty: [TEMPORARY_STORAGE_SIZE] u8;
    pd_temporary_storage_data = pd_temporary_storage_data_empty;

    pdrealloc = pd.system.realloc;

    set_initial_data(*pd_temporary_storage, TEMPORARY_STORAGE_SIZE, pd_temporary_storage_data.data);
    pd_context.temporary_storage = *pd_temporary_storage;

    allocate_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory: *void, allocator_data: *void) -> *void {
        if mode == {
            case .ALLOCATE;
                return pdrealloc(null, xx size);
            case .RESIZE;
                return pdrealloc(old_memory, xx size);
            case .FREE;
                pdrealloc(old_memory, 0);
                return null;
            case;
                return null;
        }
    }

    pd_context.allocator = .{
        allocate_proc,
        null,
    };
}

// #program_export
// _sbrk :: () #c_call {}

// #program_export
// _write :: () #c_call {}

// #program_export
// _close :: () #c_call {}

// #program_export
// _lseek :: () #c_call {}

// #program_export
// _read :: () #c_call {}

// #program_export
// _fstat :: () #c_call {}

// #program_export
// _isatty :: () #c_call {}

#program_export
_exit :: () #c_call {}

// #program_export
// _open :: () #c_call {}

#program_export
_kill :: () #c_call {}

#program_export
_getpid :: () #c_call {}

#program_export
__exidx_start :: () #c_call {}

#program_export
__exidx_end :: () #c_call {}

#if OS == .WINDOWS {
    #load "module_windows.jai";
} else #if OS == .KRAMPOS || OS == .NN_SWITCH {
    #load "module_playdate.jai";
} else {
    #assert false "Unsupported playdate OS.\n";
}

#scope_file

__etext: *u8 #elsewhere;
__data_start__: *u8 #elsewhere;
__data_end__: *u8 #elsewhere;
__bss_start__: *u8 #elsewhere;
__bss_end__: *u8 #elsewhere;

#if OS == .WINDOWS {
    pdrealloc: #type (ptr: *void, size: u64) -> *void #c_call;
} else {
    pdrealloc: #type (ptr: *void, size: u32) -> *void #c_call;
}

pd_temporary_storage: Temporary_Storage;
pd_temporary_storage_data: [TEMPORARY_STORAGE_SIZE] u8 #align 64;

// #if OS == .NONE {
    // first_thread_context: Context;
    // first_thread_temporary_storage: Temporary_Storage;
    // first_thread_temporary_storage_data: [TEMPORARY_STORAGE_SIZE] u8 #align 64;

    // _malloc_r :: (_reent: *void, nbytes: u64) -> *void {
    //     return pdrealloc(null, nbytes);
    // }

    // _realloc_r :: (_reent: *void, ptr: *void, nbytes: u64) -> *void {
    //     return pdrealloc(ptr, nbytes);
    // }

    // _free_r :: (_reent: *void, ptr: *void) {
    //     if ptr then pdrealloc(ptr, 0);
    // }
// } else {
//     malloc :: (nbytes: u64) -> *void #c_call {
//         return pdrealloc(null, nbytes);
//     }

//     realloc :: (ptr: *void, nbytes: u64) -> *void #c_call {
//         return pdrealloc(ptr, nbytes);
//     }

//     free :: (ptr: *void) #c_call {
//         if ptr then pdrealloc(ptr, 0);
//     }
// }

// TODO do I need to disable runtime support initialization to prevent the temp data from going in memory?
