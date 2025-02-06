
// Although these all come from the Basic module. I've aliased Basic in this way
// to better illustrate where each function comes from and to improve searchability.
#import "Basic";

demo_command_line_arguments :: () {
    args :=  get_command_line_arguments();
    defer  array_reset(*args); // get_command_line_arguments() creates a new array so we release it here. The strings themselves are not copies, however!

     print("Number of command line arguments: %\n", args.count);
    for args {
         print("Argument %: %\n", it_index+1, it);
    }
}

demo_context_stuff :: () {
    my_assertion_handler :: (loc: Source_Code_Location, message: string) -> bool {
        print("Assertion failed: %\n", message);

        return false; // Don't break or exit.
    }

    // The default assertion handler simply prints the source location
    // of the assertion and a message to dump to the console on stdout,
    // then calls abort(). It is pretty trivial to hook the assertion
    // handler to perform arbitrary functions. A less trivial, alternate
    // assertion handler can be observed in jai's Debug module (which,
    // among other things, dumps the current stack and spawns an
    // interactive message box).

    context.assertion_failed = my_assertion_handler;

    // Unfortunately, due to current language constraints, a message must
    // be explicitly be passed to assert() in order to get more context from
    // the assertion without spawning the debugger and navigating to the
    // source location. Passing a message at all is optionally, however.
    assert(1 == 2, "1 == 2");

    context.assertion_failed = Context.{}.assertion_failed;


    // We can do the same with logging and allocation.
    my_logger :: (message: string, data: *void, info: Log_Info) {
        print("my_logger: %\n", message);
    }
    
    context.logger = my_logger;

    log("Hello, Hamburger!\n");
    
    // Note that the identifier string is before the message/format string in log 
    log("1 == 2 is %\n", 1 == 2);

    context.logger = Context.{}.logger; // Note that the default logger is essentailly a no-op. One may miss vital information if a non-default logger is not set!

    my_allocator_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory_pointer: *void, allocator_data: *void) -> *void {
        print("Allocation:\n");
        print("Mode: %\n", mode);
        print("Size: %\n", size);
        print("Old Size: %\n", old_size);
        print("Old Memory Pointer: %\n", old_memory_pointer);
        print("Allocator Data: %\n", allocator_data);
        
        mem := context.default_allocator.proc(mode, size, old_size, old_memory_pointer, allocator_data);

        if mode == .ALLOCATE || mode == .RESIZE
        then  print("Returning memory at: %\n", mem);
        
        return mem;
    }

    my_allocator: Allocator;
    my_allocator.proc = my_allocator_proc;

    context.allocator = my_allocator;

    {
        mem :=  alloc(64);
        mem =  realloc(mem, 4096, 64);
         free(mem);
    }

    context.allocator = Context.{}.allocator;
}


// @TODO this stuff seems to better belong in the Reflection module.
// If/when that happens, this can also be moved to the appropriate
// example file.
demo_reflection_stuff :: () {
    My_Struct :: struct {
        a: int;
        b: string;
        c: float;
    }

    member_info :=  get_field(type_info(My_Struct), "b");
    print("Type_Info_Struct_Member for b: %\n", <<member_info);

    My_Enum :: enum {
        APPLE;
        BANANA;
        OCARINA;
    }

    print("Enum info for My_Enum\n");
    
    print("Names:\n");
    names :=  enum_names(My_Enum);
    for names  print("%\n", it);

    print("Values:\n");
    values :=  enum_values_as_s64(My_Enum);
    for values  print("%\n", it);

    low, high :=  enum_range(My_Enum);
    print("Range: [%, %]\n", low, high);
}

demo_system_info_stuff :: () {
    now := current_time_consensus();

    print("Time in UTC: %\n", to_calendar(now, .UTC));
    print("Time local: %\n",  to_calendar(now, .LOCAL));

    print("Working directory: ");
    working_directory :=  get_working_directory();
    print("%\n", working_directory);

/*
    exec_path :=  get_path_of_running_executable();
    print("Executable path: %\n", exec_path);

    set_working_directory(exec_path);
*/

}

demo_print_stuff :: () {
//     print_sequence("Test ", 1, " ", 32.0, "\n");

    print("% % '%'\n", 1234, 1234.0, "1234");

    print("Hex-formatted int: %\n",  formatInt(12342345234, base=16));
    print("Scientific-notation-formatted float: %, Decimal value: %\n",  formatFloat(12342345234.0, mode=.SCIENTIFIC), 12342345234.0);

    Vector :: struct {
        x: float = 1.0;
        y: float = 3.0;
        z: float = 5.0;
    }

    v: Vector;
    print("Compactly-formatted-struct %\n", v);
    print("Exanded format: %\n",  formatStruct(v, use_long_form_if_more_than_this_many_members=1));

    // Reusing a print parameter more than once by specifying a 1-based index into the parameter list
    print("%1 %2 %1\n", 5423, "Hello");

    // sprint() allows us to quickly get the result of a print operation but as a string
    // Similarly, tprint() returns the result as a string, but allocated from temporary storage
    // instead of as a heap allocation (or whatever the current context.allocator allocates from).
    sprinted_string :=  sprint("%", v);
    defer  free(sprinted_string);
    print("sprint() result: %\n", sprinted_string);

    // For more complex string creation, String_Builder may be more suitable.
    builder:  String_Builder;
    append(*builder, "Hello, String_Builder!\n"); // appends the string as-is to the String_Builder's pools.
    print_to_builder(*builder, "%\n", v); // Performs print-like formatting while appending to the builder.
    builder_string :=  builder_to_string(*builder);
    defer  free(builder_string);
    print("String_Builder result: %\n", builder_string);
}

main :: () {
    time :=  seconds_since_init();
    demo_command_line_arguments();
    demo_context_stuff();
    demo_reflection_stuff();
    demo_system_info_stuff();
    demo_print_stuff();
    time_new :=  seconds_since_init();

    print("Duration: %\n", time_new - time);
    write_string("Done.\n");
}
