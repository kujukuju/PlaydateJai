// Simple procedures that many programs may want to use.

#load "Array.jai";
#load "Simple_String.jai";
#load "String_Builder.jai";
#load "Print.jai";
#load "Int128.jai";
#load "Apollo_Time.jai";
#load "string_to_float.jai";
#load "float_to_string.jai";

// // We would like to make program parameters more robust so we can provide an Interface here, etc, but that requires a
// // bit more structuring with the compiler. In the meantime we just do it without typechecking:

// // @ToDo: Test with COMPARE_CONVERT_FROM_APOLLO_IMPLEMENTATIONS=true on x64
// // @Cleanup: Remove COMPARE_CONVERT_FROM_APOLLO_IMPLEMENTATIONS once we’re sure Iain’s implementation is alright.
#module_parameters () (MEMORY_DEBUGGER := false, ENABLE_ASSERT := true, REPLACEMENT_INTERFACE: $I/interface Memory_Debugger_Interface = Memory_Debugger_Interface, VISUALIZE_MEMORY_DEBUGGER := true, TEMP_ALLOCATOR_POISON_FREED_MEMORY := false) {

    // Your custom-supplied memory debugger should conform to this interface:
    Memory_Debugger_Interface :: struct {
        check_alloc   :: inline (allocator: Allocator, memory: *void, size: s64) {};
        check_free    :: inline (allocator: Allocator, memory: *void) {};
        check_realloc :: inline (allocator: Allocator, old_memory: *void, old_size: s64, new_memory: *void, new_size: s64) {};

        check_create_heap  :: inline (a: Allocator) {};
        check_destroy_heap :: inline (a: Allocator) {};
    }
};

// VISUALIZE_MEMORY_DEBUGGER and REPLACEMENT_INTERFACE only do anything if MEMORY_DEBUGGER == true.

// TEMP_ALLOCATOR_POISON_FREED_MEMORY memset free memory values to help track down use-after-free issues
SET_STORAGE_MARK_STAMP :: 0xda;
RESET_STORAGE_STAMP    :: 0xdb;
FREE_PAGE_STAMP        :: 0xdc;

//
// modules/Basic is intended to include a bunch of stuff that most programs will want to do;
// however, it is also supposed to be completely replaceable, so that you don't have to
// run on top of it if you don't want to.
//
// We could definitely use some comprehensive documentation on this module!
//

// #if MEMORY_DEBUGGER {
//     #load "Memory_Debugger.jai";

//     #if VISUALIZE_MEMORY_DEBUGGER #load "Visualize_Memory_Debugger.jai";

//     #if REPLACEMENT_INTERFACE == Memory_Debugger_Interface { // Memory_Debugger_Interface is a sentinel; it means the user didn't pass a replacement, so if we see this, we just use our own stuff.
//         Memory_Debugger :: struct {
//             check_alloc   :: _check_alloc;
//             check_free    :: _check_free;
//             check_realloc :: _check_realloc;

//             check_create_heap  :: _check_create_heap;
//             check_destroy_heap :: _check_destroy_heap;
//         }
//     } else {
//         Memory_Debugger :: REPLACEMENT_INTERFACE;
//     }
// } else {
//     // Declare this routine as a dummy so it can be used throughout the user-level code without #iffing it.
//     this_allocation_is_not_a_leak :: (memory: *void) #expand #no_debug {}
//     this_allocation_leaks_todo :: (memory: *void) #expand #no_debug {}
//     this_allocation_does_not_propagate_leak_ownership :: (memory: *void) #expand #no_debug {}
// }

// #if !(MEMORY_DEBUGGER && VISUALIZE_MEMORY_DEBUGGER) {
//     memory_visualizer_per_frame_update :: () #expand #no_debug {}
// }

// get_command_line_arguments :: () -> [] string {
//     c_args := __command_line_arguments;
//     result := NewArray(c_args.count, string);
//     for c_args  result[it_index] = to_string(it);
//     return result;
// }

// assert_helper :: (message := "", args: .. Any, loc := #caller_location) -> bool {
//     if context.handling_assertion_failure  return false;  // Avoid infinite loops.
//     context.handling_assertion_failure = true;

//     // We provide 'loc' in case _STACK_TRACE is turned off, but assertion_failed may well
//     // look at the stack trace if it is available.

//     should_break := context.assertion_failed(loc, tprint(message, ..args));
//     context.handling_assertion_failure = false;

//     return should_break;
// }

#if ENABLE_ASSERT {
    // We make assert() a macro so that it doesn't annoy you by being on the call stack.
    // To keep it short we factor most of the code into assert_helper() (which you could call
    // from your own assert implementation, as it is included in the module even if ENABLE_ASSERT
    // is false).
    assert :: (arg: bool, message := "", args: .. Any, loc := #caller_location) #no_debug #expand {
        // if !arg && assert_helper(message, ..args, loc) then debug_break();
    }
} else {
    assert :: (#discard arg: bool, #discard message := "", #discard args: .. Any, #discard loc := #caller_location) #expand {}
    // assert :: (arg: bool, message := "", args: .. Any, loc := #caller_location) #expand {}
}

alloc :: (size: s64) -> *void {
    a := context.allocator;

    result := a.proc(.ALLOCATE, size, 0, null, a.data);

    #if MEMORY_DEBUGGER  Memory_Debugger.check_alloc(a, result, size);

    return result;
}

free :: (memory: *void) {
    a := context.allocator;

    #if MEMORY_DEBUGGER  Memory_Debugger.check_free(a, memory);

    a.proc(.FREE, 0, 0, memory, a.data);
}

realloc :: (memory: *void, size: s64, old_size: s64) -> *void {
    a := context.allocator;

    result := a.proc(.RESIZE, size, old_size, memory, a.data);

    #if MEMORY_DEBUGGER  Memory_Debugger.check_realloc(a, memory, old_size, result, size);

    return result;
}

// create_heap :: (a: Allocator) -> Allocator {
//     b_data := a.proc(.CREATE_HEAP, 0, 0, null, a.data);

//     b := Allocator.{a.proc, b_data};

//     #if MEMORY_DEBUGGER  Memory_Debugger.check_create_heap(b);

//     return b;
// }

// destroy_heap :: (b: Allocator) {
//     #if MEMORY_DEBUGGER  Memory_Debugger.check_destroy_heap(b);

//     b.proc(.DESTROY_HEAP, 0, 0, null, b.data);
// }

// get_capabilities :: (b: Allocator) -> (caps: Allocator_Caps, name: string) {
//     name: string;
//     result := cast,no_check(Allocator_Caps)b.proc(.CAPS, 0, 0, *name, null);
//     return result, name;
// }

// Allocates a string.
alloc_string :: (count: int) -> string {
    assert(count >= 0);

    if !count return "";

    s: string = ---;
    s.data  = alloc(count);
    s.count = count;

    return s;
}

talloc_string :: (count: int) -> string {  // This is kind of silly now; we might deprecate it.
    return inline alloc_string(count,, temp);
}

free :: inline (s: string) {
    free(s.data);
}

push_allocator :: (allocator: Allocator) #expand #no_debug {  // This should probably be in caps or something, to tell people it's a macro.
    old_allocator     := context.allocator;
    context.allocator  = allocator;

    `defer context.allocator = old_allocator;
}

push_allocator :: (proc: Allocator_Proc, data: *void) #expand #no_debug {
    old_allocator     := context.allocator;

    context.allocator.proc = proc;
    context.allocator.data = data;

    `defer context.allocator = old_allocator;
}

// Should get_field be in Basic or somewhere else?
get_field :: (info: *Type_Info_Struct, name: string) -> *Type_Info_Struct_Member, offset_in_bytes: s64 {
    // First pass: Don't try recursing.
    for * info.members {
        if name == it.name return it, it.offset_in_bytes;
    }

    // Second pass: See if we can get something recursively.
    for * info.members {
        if (it.flags & .USING) && (it.type.type == .STRUCT) {
            result, child_offset := get_field(cast(*Type_Info_Struct)it.type, name);
            if result return result, it.offset_in_bytes + child_offset;
        }
    }

    return null, 0;
}

// For floating point values, it returns the second value if the first is NaN.
min :: (a: $T, b: T) -> T {
    if a < b return a;
    return b;
}

// For floating point values, it returns the second value if the first is NaN.
max :: (a: $T, b: T) -> T {
    if b < a return a;
    return b;
}

// In case you shadow 'min' and 'max' with local variables, provide capitalized versions...?
// I had originally made these capitalized until someone passive-aggressively changed them.
// Change them back?   -jblow, 2 June 2021.

Min :: min;
Max :: max;

IsScalar :: (T: Type) -> bool #compile_time {  // This is a utility used in the #modify routines for max, min, clamp.
    ti := cast(*Type_Info) T;
    if ti.type == {
      // These are fine:
      case .INTEGER; #through;
      case .FLOAT;   #through;
      case .POINTER; #through;
      case .ENUM;
        return true;
    }

    return false;
}

max :: inline (a: $T, x: ..T) -> T
#modify { return IsScalar(T), "Argument is not of a scalar type."; }
{
    m := a;
    for x if m < it m = it;
    return m;
}

min :: inline (a: $T, x: ..T) -> T
#modify { return IsScalar(T), "Argument is not of a scalar type."; }
{
    m := a;
    for x if it < m m = it;
    return m;
}

clamp :: (x: $T, a: T, b: T) -> T
#modify { return IsScalar(T), "Argument is not of a scalar type."; }
{
    return min(max(x, a), b);
}

Swap :: (a: *$T, b: *T) {   // @@ Why uppercase?
    tmp := << a;
    << a = << b;
    << b = tmp;
}

// IC: Isn't this cleaner than the version above? a,b = swap(a,b); @@ Note, in go you can simply do a,b = b,a, but not in jai!
// Yeah it is probably cleaner!
swap :: inline (a: $T, b: T) -> T #must, T #must {
    return b, a;
}

// @Cleanup: Put a better version of this into the standard library.
enum_names :: ($t: Type) -> [] string {
    info := type_info(t);
    assert(info.type == .ENUM);
    return info.names;
}

enum_values_as_s64 :: ($T: Type) -> [] s64 {
    info := type_info(T);
    assert(info.type == .ENUM);
    return info.values;
}

enum_values_as_enum :: ($T: Type) -> [] T { // This is likely to be renamed "enum_values" eventually.
    info := type_info(T);
    assert(info.type == .ENUM);

    result: [..] T;
    result.allocator = temp;

    array_reserve(*result, info.values.count);
    for info.values array_add(*result, cast,no_check(T) it);

    return result;
}

enum_highest_value :: ($t: Type) -> s64 {  // @Cleanup: A safe version of this will return type_of(T.loose)
    low, high := enum_range_given_info(type_info(t));
    return high;
}

enum_range :: ($t: Type) -> (low: s64, high: s64) {  // @Cleanup: A safe version of this will return type_of(T.loose)
    low, high := enum_range_given_info(type_info(t));
    return low, high;
}

enum_range_given_info :: (info: *Type_Info_Enum) -> (low: s64, high: s64) {  // @Cleanup: A safe version of this will return type_of(T.loose)
    if info.values.count == 0  return 0, 0;

    low  := cast(s64) info.values[0];
    high := low;
    for info.values {
        low  = min(low,  it);
        high = max(high, it);
    }

    return low, high;
}

// ## Temporary Memory Functions

// @Cleanup: We would like to do:
//
//     talloc :: temporary_alloc;
//
// But this makes the code live right now. When we fix this part of the
// dead code elimination, we can do that...
talloc :: inline (size: s64) -> *void {
    return temporary_allocator_proc(.ALLOCATE, size, 0, null, null);
}

temporary_alloc :: inline (size: s64) -> *void {
    return temporary_allocator_proc(.ALLOCATE, size, 0, null, null);
}

temp :: Allocator.{temporary_allocator_proc, null};

__temporary_allocator :: temp;  // This declaration is, uhh, temporary. Officially deprecated, it will be removed at some point soon.
temporary_allocator :: temp;

temporary_allocator_proc :: (mode: Allocator_Mode, requested_size: s64, old_size: s64, old_memory: *void, allocator_data: *void) -> *void {
    if #complete mode == {
      case .FREE;
        return null;
      case .RESIZE;
        real_old_size := (old_size + 7) & ~7; // We know old_size was padded
        if requested_size <= real_old_size return old_memory;
        #through;
      case .ALLOCATE;
        // Pad to 8-byte alignment.
        size := (requested_size + 7) & ~7;

        ts := context.temporary_storage;

        // If someone gave us a context with no temporary_storage, fall back to context.allocator.
        if !ts {
            a := context.allocator;
            if a.proc == temporary_allocator_proc {
                // context.allocator is temporary_allocator, so, fall back to default_allocator.
                a.proc = Context.default_allocator.proc;
                a.data = null;
            }

            return a.proc(mode, requested_size, old_size, old_memory, a.data);
        }

        if size > ts.size - ts.current_page_bytes_occupied {
            success := add_new_page(ts, size);
            if !success  return null;
        }

        result := ts.data + ts.current_page_bytes_occupied;
        if result && (mode == .RESIZE) {
            memcpy(result, old_memory, min(old_size, requested_size));
        }

        ts.current_page_bytes_occupied += cast(s32) size;
        ts.total_bytes_occupied += cast(s32) size;
        ts.high_water_mark = max(ts.high_water_mark, ts.total_bytes_occupied);

        return result;

      case .STARTUP;      #through;
      case .SHUTDOWN;
        return null;

      case .THREAD_START; #through;
      case .THREAD_STOP;
        assert(false, "Multithreaded access is not supported by temporary_allocator_proc.\n");
        return null;

      case .CREATE_HEAP; #through;
      case .DESTROY_HEAP;
        assert(false, "Create/Destroy heap are not supported by temporary_allocator_proc.\n");
        return null;

      case .IS_THIS_YOURS;
        ts := context.temporary_storage;
        if !ts return null;

        if (old_memory >= ts.data) && (old_memory < ts.data + ts.size) return cast(*void) true;
        if (old_memory >= ts.original_data) && (old_memory < ts.original_data + ts.original_size) return cast(*void) true;

        page := ts.overflow_pages;
        while page {
            if (old_memory >= page) && (old_memory < cast(*void)page + page.size + ALIGNED_OVERFLOW_PAGE_ALLOCATION) return cast(*void) true;
            page = page.next;
        }

        // Not found!
        return null;

      case .CAPS;
        if old_memory { <<cast(*string)old_memory = "modules/Basic temporary_allocator_proc"; }
        return cast(*void)(Allocator_Caps.HINT_I_AM_PER_FRAME_TEMPORARY_STORAGE);
    }
}

Temporary_Storage_State :: struct {
    top_overflow_page: *Temporary_Storage.Overflow_Page;
    current_page_bytes_occupied: s64;
    total_bytes_occupied: s64;
}


get_temporary_storage_mark :: inline () -> Temporary_Storage_State {
    ts := context.temporary_storage;
    if !ts return .{};  // Just to have something to return!

    state: Temporary_Storage_State = ---;
    state.current_page_bytes_occupied = ts.current_page_bytes_occupied;
    state.total_bytes_occupied        = ts.total_bytes_occupied;
    state.top_overflow_page           = ts.overflow_pages;

    return state;
}

// Typically used as follows:
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// mark := get_temporary_storage_mark();
// defer set_temporary_storage_mark(mark);
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// You can also use the `auto_release_temp` macro.
set_temporary_storage_mark :: inline (state: Temporary_Storage_State, loc := #caller_location) {
    ts := context.temporary_storage;
    if !ts return;
    free_pages_down_to(ts, state.top_overflow_page);

    ts.last_set_mark_location = loc;

    if state.top_overflow_page {
        page := state.top_overflow_page;
        ts.data = (cast(*u8) page) + ALIGNED_OVERFLOW_PAGE_ALLOCATION;
        ts.size = page.size;
        assert(page.size >= 0);
    } else {
        ts.data = ts.original_data;
        ts.size = ts.original_size;
        assert(ts.overflow_pages == null);
    }

    ts.current_page_bytes_occupied = state.current_page_bytes_occupied;
    ts.total_bytes_occupied        = state.total_bytes_occupied;

    if TEMP_ALLOCATOR_POISON_FREED_MEMORY {
        memset(cast(*u8) ts.data + ts.current_page_bytes_occupied, SET_STORAGE_MARK_STAMP, ts.size - ts.current_page_bytes_occupied);
    }
}

reset_temporary_storage :: () {
    ts := context.temporary_storage;
    if !ts return;

    ts.data = ts.original_data;
    ts.size = ts.original_size;
    ts.current_page_bytes_occupied = 0;
    ts.total_bytes_occupied = 0;
    ts.high_water_mark = 0;

    // @Speed: Maybe we should keep the allocated pages on the side,
    // rather than freeing them every frame. It probably would not
    // add much complexity here.
    free_pages_down_to(ts, null);

    if TEMP_ALLOCATOR_POISON_FREED_MEMORY {
        memset(ts.data, RESET_STORAGE_STAMP, ts.size);
    }
}

auto_release_temp :: (loc := #caller_location) #expand {
    __mark := get_temporary_storage_mark();
    `defer set_temporary_storage_mark(__mark, loc);
}

Initialize :: (memory: *$T) {
    ini :: initializer_of(T);

    #if ini  inline ini(memory);
    else     memset(memory, 0, size_of(T));
}

New :: ($T: Type, $initialized := true) -> *T {
    memory := alloc(size_of(T));

    // Since New gets called a lot, we just roll Initialize() into here, so that
    // we don't kick off so many extra polymorphs.
    #if initialized {
        ini :: initializer_of(T);

        #if ini  inline ini(memory);
        else     memset(memory, 0, size_of(T));
    }

    return cast(*T) memory;
}

NewArray :: (count: s64, $T: Type, $initialized := true, alignment: s32 = -1) -> (result: [] T, unaligned_base: *void) {
    if !count return .[], null;

    // NewArray is for when we want to new a not-known-at-compile-time
    // number of things...

    a := context.allocator;

    extra: s32 = 0;
    if alignment > 0 {
        extra = alignment;
    }

    // 'extra' lets us allocate extra memory so that the user can bump the pointer forward
    // for alignment purposes.
    // This is more versatile than requiring all allocators to support wacky alignments.
    // This doesn't mean it's the best solution, but it is what we are doing for now.
    original_memory := cast(*void) alloc(size_of(T) * count + extra);

    memory: *void;
    if alignment > 0 {
        memory = cast(*void) align_forward(cast(s64)original_memory, alignment);
    } else {
        memory = original_memory;
    }

    result: [] T = ---;
    result.count = count;
    result.data  = memory;

    #if initialized {
        ini :: initializer_of(T);

        #if ini {
            for 0..count-1 {
                inline ini(memory);
                memory += size_of(T);
            }
        } else {
            memset(memory, 0, count * size_of(T));
        }
    }

    // If alignment == -1, you don't need to think about original_memory; you can just ignore it.
    // You only need to care if alignment != -1; in that case, when it comes time to free the memory,
    // you should free original_memory, not result.data.
    return result, original_memory;
}

// align_forward adds to orig_size so that it becomes an even multiple of 'alignment'.
align_forward :: (orig_size: s64, alignment: s64) -> s64 {
    a := alignment;
    assert(a > 0);

    size := ((orig_size + a - 1) / a) * a;

    // The above code might be hard to think about. Here's another implementation,
    // that has a branch:

    //    size := orig_size;
    //    remainder := orig_size % a;
    //    if remainder  size += a - remainder;

    return size;
}

// #if OS == {
//     case .WINDOWS;   #load "windows.jai";
//     case .LINUX;     #load "linux.jai";
//     case .ANDROID;   #load "linux.jai";
//     case .MACOS;     #load "osx.jai";
//     case .PS5;       #load "ps5.jai";
//     case .NN_SWITCH; #load "switch.jai";  // Not distributed, for license reasons.
// }

#scope_file
free_pages_down_to :: (ts: *Temporary_Storage, page: *ts.Overflow_Page) {
    cursor := ts.overflow_pages;
    while cursor != page {
        if !cursor {
            log_error("Attempt to free down to page %, but that page was not found! This is probably an error in using set_temporary_storage_mark, or a general memory corruption.\n", page);
            ts.overflow_pages = null;
            return;
        }

        next := cursor.next;
        allocator := cursor.allocator;

        if TEMP_ALLOCATOR_POISON_FREED_MEMORY {
            memset(cursor, FREE_PAGE_STAMP, cursor.size);
        }

        free(cursor,, allocator=allocator);
        cursor = next;
    }

    ts.overflow_pages = page;
}

ALIGNED_OVERFLOW_PAGE_ALLOCATION :: 32;
add_new_page :: (ts: *Temporary_Storage, minimum_size: s64) -> bool {
    #assert(size_of(Temporary_Storage.Overflow_Page) <= ALIGNED_OVERFLOW_PAGE_ALLOCATION);

    data_size : s64 = ts.original_size - ALIGNED_OVERFLOW_PAGE_ALLOCATION;
    if data_size < minimum_size  data_size = minimum_size;

    size_including_header := data_size + ALIGNED_OVERFLOW_PAGE_ALLOCATION;

    // Pad to 8-byte alignment.
    size_including_header = (size_including_header + 7) & ~7;

    // It's legal for overflow_allocator to be null, in which case
    // we do whatever alloc does.
    allocator      := ts.overflow_allocator;
    if !allocator.proc {
        // We don't know what allocator might be pushed onto the context,
        // so, fall back to __default_allocator.
        allocator      = Context_Base.default_allocator;
    }

    memory := alloc(size_including_header,, allocator=allocator);
    if !memory {
        log_error("Failed to allocate % bytes for a Temporary_Storage overflow page.\n", size_including_header);
        return false;  // This is going to be bad!
    }

    page := cast(*ts.Overflow_Page) memory;
    page.next           = ts.overflow_pages;
    page.allocator      = allocator;
    page.size           = data_size;

    ts.overflow_pages = page;

    ts.data = memory + ALIGNED_OVERFLOW_PAGE_ALLOCATION;
    ts.size = data_size;
    ts.current_page_bytes_occupied = 0;
    assert(ts.size >= 0);

    return true;
}


#scope_export

// pack_stack_trace is convenient in case you want to store the stack trace
// on a data structure. You can't just store a pointer to context.stack_trace,
// because that data will be destroyed as the stack unwinds. So this routine
// copies that trace into a packed array.
pack_stack_trace :: () -> [] Stack_Trace_Node {
    return pack_stack_trace(context.stack_trace);
}

pack_stack_trace :: (node: *Stack_Trace_Node) -> [] Stack_Trace_Node {
    // We could do a two-pass version where we array_reserve the right amount of data...!

    result: [..] Stack_Trace_Node;
    while node {
        array_add(*result, << node);
        node = node.next;
    }

    // Fix up the 'next' pointers so you can use them normally.
    for * result {
        if it.next   // The one that was already null, at the end, leave it null. Otherwise:
            it.next = it + 1;  // Set 'next' to point at the subsequent element in the array.
    }

    return result;
}

//
// print_stack_trace() can be used as a low-level routine for people writing
// Allocators, assertion handlers, loggers etc, and who are encountering
// bugs that they want help with. This is guaranteed not to call into
// any logger, allocator, etc because it uses only bottom-level routines.
//
// That said, you can also use it in other code!
//
print_stack_trace :: (node: *Stack_Trace_Node, prefix: string = "", to_standard_error := true) {
    while node {
        if node.info {
            if prefix.count    write_string(prefix, to_standard_error = to_standard_error);
            write_string("'", to_standard_error = to_standard_error);
            if node.info.name  write_string(node.info.name, to_standard_error = to_standard_error);
            write_string("' at ", to_standard_error = to_standard_error);
            if node.info.location.fully_pathed_filename write_string(node.info.location.fully_pathed_filename, to_standard_error = to_standard_error);
            write_string(":", to_standard_error = to_standard_error);
            write_nonnegative_number(node.line_number, to_standard_error = to_standard_error);
            write_string("\n", to_standard_error = to_standard_error);
        }

        node = node.next;
    }
}

log_stack_trace :: (node: *Stack_Trace_Node, log_flags := Log_Flags.ERROR, prefix := "") {  // @Redundant with print_stack_trace ... hmmm, maybe get rid of that and just have this?
    while node {
        // See the comments in print_stack_trace().
        if node.info log("%'%' at %:%\n", prefix, node.info.name, node.info.location.fully_pathed_filename, node.line_number, flags = log_flags);
        node = node.next;
    }
}

get_stack_trace_string :: (node: *Stack_Trace_Node) -> string {
    if node {
        builder: String_Builder;

        while node {
            if node.info {
                print_to_builder(*builder, "'%' at %:%\n", node.info.name, node.info.location.fully_pathed_filename, node.line_number);
            }
            node = node.next;
        }

        return builder_to_string(*builder);
    }

    return "";
}

remember_allocators :: (data: *$T) {
    // In this language, we want the user of a function or library to be able to
    // control that function's memory allocation using context.allocator.
    //
    // When you make a data structure that needs to allocate memory over a long
    // period of time, though, this introduces a potential annoying constraint:
    // if the user wants to store that data structure or pass it to some other code,
    // that the user did not write, that other code will not know what allocator to push.
    // So it's a good idea for data structures like this to store allocators at
    // initialization time. (Data structures like Hash_Table and Bucket_Array do this;
    // this is also why the language-native [..] array has allocator and allocator_data
    // slots.)
    //
    // To make it convenient to save allocators in this way, we provide this function;
    // it's a very simple function, but it helps people remember and continue the convention.
    // All you need is to have 'allocator' and 'allocator_data' members, then call
    // this routine.

    if context.allocator.proc {
        data.allocator      = context.allocator;
    } else {
        data.allocator      = context.default_allocator;
    }
}

resizable :: (a: [] $T, set_allocators := true) -> [..] T {
    // Convert a [] to a [..] that owns the same memory.
    // The [..]'s allocated pointer will be set to a.count, so it will
    // reallocate if you try to add any more.

    // Since there is no way to know what the allocator of the [] was,
    // we assume it's the current allocator, and remember that, unless you
    // say set_allocators=false.

    result: [..] T = ---;
    result.count     = a.count;
    result.allocated = a.count;
    result.data      = a.data;

    if set_allocators remember_allocators(*result);

    return result;
}


get_integer_range :: ($T: Type) -> (low: T, high: T) {
    // Returns the lowest and highest values for a given integer type.
    // For example, u8 returns (0, 255); s8 returns (-127, 128).

    IS_INTEGER, SIGNED, BITS :: #run is_integer_type(T);
    #assert(IS_INTEGER);

    #if SIGNED {
        low := (cast(T)1) << (BITS-1);
    } else {
        low: T = 0;
    }

    return low, ~low;
}

clamp_to_another_integer_type :: (value: $SourceType, $TargetType: Type) -> TargetType {
    // SourceType and TargetType
    SOURCE_INTEGER, SOURCE_SIGNED, SOURCE_BITS :: #run is_integer_type(SourceType);
    TARGET_INTEGER, TARGET_SIGNED, TARGET_BITS :: #run is_integer_type(TargetType);

    #assert SOURCE_INTEGER && TARGET_INTEGER;

    LOW, HIGH :: #run get_integer_range(TargetType);

    #if SOURCE_SIGNED == TARGET_SIGNED {
        // Both are signed, or both are unsigned.

        #if TARGET_BITS < SOURCE_BITS {
            if value < LOW   value = LOW;
            if value > HIGH  value = HIGH;
        }

        return cast,no_check(TargetType) value;
    } else {
        // If we get here, SOURCE_SIGNED != TARGET_SIGNED.
        #if SOURCE_SIGNED {
            // TARGET_SIGNED == false.

            if value < 0  value = 0;

            #if TARGET_BITS < SOURCE_BITS {
                if value > HIGH  value = HIGH;
            }
        } else {
            // SOURCE_SIGNED == false, TARGET_SIGNED == true.

            #if TARGET_BITS <= SOURCE_BITS {
                if value > HIGH  value = HIGH;
            }
        }

        return cast,no_check(TargetType) value;
    }
}


is_integer_type :: ($T: Type) -> (is_integer: bool, is_signed: bool, bits: u8) {
    info := type_info(T);
    if info.type == .INTEGER {
        info_int  := cast(*Type_Info_Integer) info;
        return true, info_int.signed, size_of(T)*8;
    }

    return false, false, 0;
}

// seconds_since_init :: () -> float64 {
//     // This is the replacement for seconds_since_init().
//     one_time_init(*is_get_seconds_initialized, init_get_seconds());

//     delta := current_time_monotonic() - get_seconds_base_time;
//     return to_float64_seconds(delta);
// }

// get_time :: () -> float64 #deprecated "This name is old; use seconds_since_init instead." {
//     return seconds_since_init();
// }

//
// WARNING: The SystemTime struct is going to go away soon; it's deprecated.
// Instead, use current_time_consensus() and Calendar_Time from modules/Basic/Apollo_Time.jai.
//
// SystemTime :: struct {
//     year        : s32; // [1601 - 30827]
//     month       : s32; // [1-12]
//     day_of_week : s32; // [0-6]
//     day         : s32; // [1-31]
//     hour        : s32; // [0-36]
//     minute      : s32; // [0-59]
//     second      : s32; // [0-59]
//     millisecond : s32; // Warning: get_system_time() on Linux currently leaves this at 0.
// }


// #scope_file

// // is_get_seconds_initialized: s32;
// // get_seconds_base_time: Apollo_Time;

// // init_get_seconds :: () {
// //     get_seconds_base_time = current_time_monotonic();
// // }
