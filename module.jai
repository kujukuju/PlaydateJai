
// pdrealloc: #type (ptr: *void, size: u64) -> *void #c_call;

// #program_export "eventHandlerShim"
// eventHandlerShim :: (playdate: *PlaydateAPI, event: PDSystemEvent, arg: u32) -> s32 #c_call {
//     pdrealloc = playdate.system.realloc;

//     // #if OS == .NONE {
//         ts := *first_thread_temporary_storage;
//         set_initial_data(ts, TEMPORARY_STORAGE_SIZE, first_thread_temporary_storage_data.data);
//         first_thread_context.temporary_storage = ts;

//         allocate_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory: *void, allocator_data: *void) -> *void {
//             if mode == {
//                 case .ALLOCATE;
//                     return pdrealloc(null, cast(u64) size);
//                 case .RESIZE;
//                     return pdrealloc(old_memory, cast(u64) size);
//                 case .FREE;
//                     pdrealloc(old_memory, 0);
//                     return null;
//                 case;
//                     return null;
//             }
//         }

//         first_thread_context.allocator = .{
//             allocate_proc,
//             null,
//         };

//         ctx := *first_thread_context;
//     // } else {
//     //     ctx := __jai_runtime_init(0, null);
//     // }

//     push_context ctx.* {
//         return eventHandler(playdate, event, arg);
//     }
// }

#program_export
_sbrk :: () #c_call {}

#program_export
_write :: () #c_call {}

#program_export
_close :: () #c_call {}

#program_export
_lseek :: () #c_call {}

#program_export
_read :: () #c_call {}

#program_export
_fstat :: () #c_call {}

#program_export
_isatty :: () #c_call {}

#program_export
_exit :: () #c_call {}

#program_export
_open :: () #c_call {}

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
