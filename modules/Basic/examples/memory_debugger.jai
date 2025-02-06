//
// We import Basic with MEMORY_DEBUGGER=true to cause alloc(), free(), and realloc()
// to be hooked with routines that record allocations and frees. This is a layer
// built on top of allocators, so that allocators do not have to implement their own
// memory debugging if they don't want to, and also, we can make sure you free a chunk 
// of memory on the same allocator you allocated it from, which is a cross-cutting concern
// that involves multiple allocators.
//
// You can look at this memory debugging code if you want; it's not too complicated.
// it lives in modules/Basic/Memory_Debugger.jai.
//
// Note that enabling the MEMORY_DEBUGGER will slow down your program by some amount
// relative to how many allocations there are. So we recommend only enabling 
// MEMORY_DEBUGGER when you really are working on memory issues, and disabling it
// at other times.
//
#import "Basic"()(MEMORY_DEBUGGER=true);
#import "Pool";

Status :: struct {  // Here's an arbitrary stuff that just has some things in it.
    name1: string;
    name2: string;

    number: float64;
}

fruits :: string.["Apple", "Blueberry", "Canteloupe", "Zebra Fruit"];

main :: () {
    // Often in programs you want to allocate some global data at startup, and that data
    // remains in use for the duration of runtime. The RAII people would then say you should
    // "destruct" this data at the end of runtime, because it's no longer in use. But this
    // wastes CPU cycles and adds complexity to the program; the operating system is about
    // to bulk-free all your memory, so why would you put the computer through a bunch of
    // extra pain of getting all sorts of pointers into cache just so you can free them
    // before the operating system frees them?
    //
    // But even if one decides they don't want to do this, then one day we come along and want
    // to profile our memory use and make sure there aren't leaks. And the tool doesn't know that
    // this data is global, and reports it as a leak. When there is a lot of global data, this
    // clouds the reports with things we don't care about, making it harder to see the actual
    // leaks, and decreasing our quality of life. So one feels pressured into adding code
    // to free the global data.
    //
    // This doesn't sound hard (and indeed in this simple example it would not be hard to free
    // the global data), but sometimes that data resides in many data structures across many
    // subsystems of a large program, and freeing that stuff adds nontrivial complexity.
    // We take an alternate approach: you can call a procedure that tells the leak detector
    // that this memory should not be counted as a leak; instead it's intentional global data.
    // The nice thing is, this can be done at the site of the allocation, rather than having
    // code spread out in two places that have to coordinate with each other logically (which
    // is one of the things that makes programs complicated).

    the_status := New(Status);                  // Allocate a global Status.
    this_allocation_is_not_a_leak(the_status);  // Tell the memory debugger it's not a leak.

    // (We can call this_allocation_is_not_a_leak even if memory debugging is disabled;
    // Basic defines it to be an empty macro if MEMORY_DEBUGGING==false.)

    // Now let's do some main program stuff:

    numbers: [] int;
    for i: 1..10 {
        numbers = make_numbers(i);  // make_numbers gives us a heap-allocated array.

        sum := 0;
        for numbers sum += it;
        print("Sum is: %.\n", sum);

        // Oops... we forgot to free 'numbers'!
    }

    // Let's start allocating using a Pool...
    pool: Pool;
    set_allocators(*pool);

    fruit_copies: [fruits.count] string;
    
    {
        // Allocate a copy of each fruit from the Pool.
        // This will show up in the report as just one allocation,
        // performed by the Pool, of the page onto which all these fruits fit.
        push_allocator(pool_allocator_proc, *pool);

        for fruits fruit_copies[it_index] = copy_string(it);
    }

    // We are back using the default allocator now.
    // What happens if we try to free memory, allocated from Pool,
    // with the default allocator (this is wrong!!)

    // Uncomment this to see... 
    // free(fruit_copies[0]);

    
    // At the end of execution, or any time really, we can report memory leaks.


    // Here's the simplest way to do it:

    print("\n\n **** First Leak Report: ****\n\n");
    report_memory_leaks();

    //
    // We're going to do another leak report. But before we do that, let's free
    // whichever was the last 'numbers' array we allocated, to show that the report
    // notices we freed stuff.
    //

    free(numbers.data);
    
    
    //
    // For a big program, these leak reports can become verbose, and this can make it harder
    // to understand what is a legitimate leak. But we can easily trim the reports down,
    // because there are many procedures that we just know allocate memory, so if we called
    // one of those, we don't need to see further down the call stack. For example,
    // if we call copy_string, it's obvious that this allocates memory, so we don't need
    // to show that this then calls alloc_string, which then calls alloc. Trimming this
    // for every report can make things substantially more readable. We indicate what to trim
    // by setting known_allocation_leaves. It's a structure with two strings; the first is
    // the name of the procedure, and the second is a substring of the module or file that
    // it lives in. (Use the empty string to skip this substring match and just match on
    // the name of the procedure).
    //
    {
        print("\n\n **** Second Leak Report, without common leaves: ****\n\n");
        
        options: Leak_Report_Options;
        options.known_allocation_leaves = .[.{"New", "Basic"}, .{"NewArray", "Basic"}, .{"array_add", "Basic"}, .{"array_resize", "Basic"}, .{"array_reserve", "Basic"}, .{"copy_string", "Basic"}, .{"alloc_string", "Basic"}, .{"add_bucket", "Bucket_Array"}, .{"find_and_occupy_empty_slot", "Bucket_Array"}, .{"init", "Hash_Table"}, .{"resize", "Hash_Table"}, .{"table_add", "Hash_Table"}, .{"read_entire_file", "File"}, .{"get", "Pool"}];

        report_memory_leaks(*options);
    }

    //
    // In a larger program, you may get several levels down in the call stack before
    // your code starts to go anywhere interesting -- say from main, to a procedure that
    // runs the main loop, to a procedure that does all the simulation. Seeing these top
    // few procedures all the time in every report may make it verbose and increase the
    // noise level, so you can trim things out of the *bottom* of the call stack by
    // setting roots_to_skip. This works differently than known_allocation_leaves:
    // here, we start at the root and trim only so long as the current function is
    // inside 'roots_to_skip'. As soon as we are outisde that set, we stop trimming.
    //
    {
        print("\n\n **** Third Leak Report, without main: ****\n\n");
        options: Leak_Report_Options;
        options.known_allocation_leaves = .[.{"New", "Basic"}, .{"NewArray", "Basic"}, .{"array_add", "Basic"}, .{"copy_string", "Basic"}, .{"alloc_string", "Basic"}];
        options.roots_to_skip           = .[.{"main", ""}, .{"some_other_common_routine", ""}];
        report_memory_leaks(*options);
    }
    
    //
    // As programs get bigger, sometimes these memory reports can get very noisy
    // in other ways. For example, if you have a recursive procedure, or group of procedures
    // that call each other, and then there is a function at the bottom of all this recursion
    // that allocates, you might get to that allocation via many different call stacks.
    // The system tells you all those different stacks as separate reports, because it
    // doesn't know what information in those stacks is important to you and what isn't.
    // But if you decide that differences between call stacks are irrelevant, you can
    // give the reporter procedures such that all calls to that procedure go into the
    // same group, and get reported once. Only the portions of the call stack that are
    // common to all members of the group are shown.
    //

    //
    // To illustrate this, let's add some more leaks that happen via a recursive function,
    // then just look at the default report that is generated:
    //

    // (In order to make mutually recursive functions in an imperative scope, we need to do
    // this hack where we use a struct, so that they live in a data scope... otherwise
    // there's no way for them to call each other without one calling ahead into the other. Sigh!)

    Holder :: struct {
        handle_even_number :: (x: int) -> *void {
            return recursive(x/2);
        }
        
        recursive :: (x: int) -> *void {
            if x <= 1        return alloc(100);

            if (x % 5) == 0  return recursive(x/5);

            if (x & 1)       return recursive(x-1);
            
            return handle_even_number(x);
        }
    }

    recursive :: Holder.recursive;
    
    recursive(1);
    recursive(5);
    recursive(10);
    recursive(11);

    {
        print("\n\n **** Fourth Leak Report, with extra noisy recursive stacks: ****\n\n");
        options: Leak_Report_Options;
        options.known_allocation_leaves = .[.{"copy_string", "Basic"}, .{"NewArray", "Basic"}, .{"get", "Pool"}];
        report_memory_leaks(*options);
    }


    //
    // To make that report less noisy, we can just say, hey, anything that ever called 'recursive'
    // goes into the same group.
    //
    {
        print("\n\n **** Fifth Leak Report, with grouped stacks: ****\n\n");
        options: Leak_Report_Options;
        options.known_allocation_leaves = .[.{"copy_string", "Basic"}, .{"NewArray", "Basic"}, .{"get", "Pool"}];
        options.group_by_these_calls    = .[.{"recursive", ""}];
        report_memory_leaks(*options);
    }
    
    //
    // You can also get a leak report as a data structure, rather than logging it as a string.
    // So you can do whatever you want with it -- filter it in some way, draw it graphically,
    // send it to a server, etc. And you don't have to deal with the slowness, errors and
    // uncertainty involved in parsing string output.
    //
    
    print("\n\n **** As a Data Structure: ****\n\n");

    report := make_leak_report();
    print("%\n", report);

    for report.sorted_summaries print("** Summary %: **\n%\n", it_index, <<it);

    caps, name := get_capabilities(context.default_allocator);

    print("Allocator is \"%\", caps: %\n", name, caps);
    
    if caps & .CREATE_HEAP {
        //
        // Let's test first-class heaps. We should be able to create a heap,
        // allocate individual things in it, then destroy the heap, and all
        // individual allocations inside that heap should be known to be gone,
        // without us having to free them individually. In other words, the total
        // number of leaked allocations from our previous report should be equal
        // to the total number of bytes and leaked allocations after we destroy
        // that heap; we'll assert this.
        //

        leaked_count_before := 0;
        leaked_bytes_before := 0;

        for report.sorted_summaries {
            leaked_count_before += it.count;
            leaked_bytes_before += it.bytes;
        }

        // Let's make that messy first-class heap and do some stuff to it:
        old_allocator := context.allocator;
        new_heap := create_heap(context.allocator);
        for 1..10 {
            waste := alloc(69105,, allocator=new_heap);
        }

        // Let's count how much leakage we have before destroying the heap:
        middle := make_leak_report();
        leaked_count_middle := 0;
        leaked_bytes_middle := 0;
        for middle.sorted_summaries {
            leaked_count_middle += it.count;
            leaked_bytes_middle += it.bytes;
        }

        // Now let's destroy that heap:
        destroy_heap(new_heap);

        
        // Now let's make a new leak report and make sure there are no more leaks:

        print("\n\nAsserting that destruction of a messy first-class heap did not increase our leaks:\n");
        after := make_leak_report();

        leaked_count_after := 0;
        leaked_bytes_after := 0;
        for after.sorted_summaries {
            leaked_count_after += it.count;
            leaked_bytes_after += it.bytes;
        }

        
        print("leaked_count_before = %\n", leaked_count_before);
        print("leaked_count_middle = %\n", leaked_count_middle);
        print("leaked_count_after  = %\n", leaked_count_after);
        assert(leaked_count_before == leaked_count_after);
        
        print("leaked_bytes_before = %\n", leaked_bytes_before);
        print("leaked_bytes_middle = %\n", leaked_bytes_middle);
        print("leaked_bytes_after  = %\n", leaked_bytes_after);
        assert(leaked_bytes_before == leaked_bytes_after);
    } else {
        print("Skipping the first-class heap test until we have an allocator that supports this.\n");
    }
    
    print("We're good! Done.\n");
}


    
make_numbers :: (n: int) -> [] int {
    // Allocate, on the heap (or whatever allocator is currently set), an array of n integers, and return it.
    
    result := NewArray(n, int);

    for 0..n-1 result[it] = it;

    return result;
}

