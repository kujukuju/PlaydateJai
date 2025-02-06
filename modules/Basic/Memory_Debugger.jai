// // Procedure_To_Elide is used to make nicer output when generating the reports.
// // See the example.

// // @Incomplete: Document why these are strings instead of procedure pointers
// // (hint: polymorphism!)
// Procedure_To_Elide :: struct {
//     procedure_name: string;
//     module_name:    string;
// }

// Leak_Report_Options :: struct {
//     known_allocation_leaves: [] Procedure_To_Elide;  // If we get to one of these, we know it's an allocator, so we don't need to print anything higher on the stack.
//     roots_to_skip:           [] Procedure_To_Elide;  // If the stack starts out here, it's obvious and gives us no information, so skip it. This is stuff like main() or draw_one_frame().

//     group_by_these_calls:    [] Procedure_To_Elide;

//     scan_global_memory_to_remove_leaks := true;
//     scan_leaks_to_combine              := true;
// }

// Leak_Report :: struct {
//     marked_as_non_leak_allocations: s64;
//     marked_as_non_leak_bytes:       s64;

//     sorted_summaries: [] *Leak_Summary;

//     leak_combiner_table: Table(*void, Leak_Combiner_Record);  // See the comment on Leak_Combiner_Record.

//     pool: Pool;   // Holds all the memory for this report.
// }

// Leak_Summary :: struct {
//     count: s64;  // How many individual allocations.
//     bytes: s64;  // How many bytes total.

//     allocations_since_last_visualizer_update: s64;
//     bytes_allocated_since_last_visualizer_update: s64;

//     alloc_site_trace: *Packed_Stack_Trace;
//     allocator_proc: Allocator_Proc;     // If multiple allocators, we set this to null rather than storing an array of them... maybe we should.
//     group_info: *Group_Info;  // Used only if this node is created by grouping other nodes.

//     child_count: s64;  // How many allocations from children were aggregated because they were pointed-at by this allocation.
//     child_bytes: s64;  // How many bytes from children were aggregated because they were pointed-at by this allocation.
// }

// Group_Info :: struct {
//     procedure: Procedure_To_Elide;

//     sub_summaries: [] *Leak_Summary;  // We don't seem to use this anywhere right now; get rid of it?
//     root_nodes_in_common: s64;  // How many nodes, starting from the root, are common in all these summaries.
//     leaf_nodes_in_common: s64;  // How many nodes, starting from the leaves, are common in all these summaries.
// }

// // This Preamble goes on the front of all _check routines:
// Preamble :: () #expand {
//     // Don't record allocations to pool_allocator or __temporary_allocator. These are not
//     // supposed to be freed; and they are also meant by the user program to be fast,
//     // so doing less work for each may cause the user program to suffer less. We probably
//     // should provide a way for the user to indicate allocators that should also be ignored,
//     // because you would expect a large/serious program to have more of these.
//     //
//     // This may cause some confusion because if you alloc with Pool then free from heap,
//     // it won't know that you allocated from Pool, when that information could be very
//     // helpful in solving problems quickly. So, we'll see...
//     if `allocator.proc == pool_allocator_proc       `return;
//     if `allocator.proc == flat_pool_allocator_proc  `return;
//     if `allocator.proc == temporary_allocator_proc  `return;

//     if context.inside_memory_debugger `return;
//     context.inside_memory_debugger = true;
//     `defer context.inside_memory_debugger = false;

//     if !initted  init();
// }

// _check_alloc :: inline (allocator: Allocator, memory: *void, size: s64) {
//     Preamble();
//     add_allocation_to_table(memory, size, allocator, context.stack_trace);
// }

// _check_free :: inline (allocator: Allocator, memory: *void) {
//     if !memory return;  // Freeing null is fine and does nothing.

//     Preamble();

//     lock(*address_table_mutex);
//     defer unlock(*address_table_mutex);
//     found, success := table_find(*address_table, memory);

//     trace := context.stack_trace;
//     if !success {
//         report_use_of_unknown_memory(memory, "Basic.free()", trace);
//         exit(1);
//         return;
//     }

//     if !found.is_live {
//         report_already_freed_memory(found, "Basic.free()", trace);
//         return;
//     }

//     check_for_allocator_mismatch(found, allocator, "Basic.free()", trace);
//     found.is_live = false;
//     found.vis_reported_freed = false;
//     found.free_site_trace = find_or_pack_stack_trace(trace);

//     #if VISUALIZE_MEMORY_DEBUGGER add_free_this_frame(found, found.size);
// }

// _check_realloc :: inline (allocator: Allocator, old_memory: *void, old_size: s64, new_memory: *void, new_size: s64) {
//     Preamble();

//     trace := context.stack_trace;

//     //
//     // realloc on null is legal, and we should not complain in that case.
//     //
//     if !old_memory {
//         // This is just an alloc, then.
//         add_allocation_to_table(new_memory, new_size, allocator, trace);
//         return;
//     }

//     lock(*address_table_mutex);
//     defer unlock(*address_table_mutex);
//     found, success := table_find(*address_table, old_memory);

//     if !success {
//         report_use_of_unknown_memory(old_memory, "Basic.realloc()", trace);
//         exit(1);
//         add_allocation_to_table(new_memory, new_size, allocator, context.stack_trace); // Try to maintain a picture of the world that will result in fewer errors generated due to chain reactions?
//         return;
//     }

//     if new_memory == null {
//         // I guess realloc can return null when you pass 0 for the size? Hmmm. I thought that was illegal...
//         assert(new_size == 0);

//         // @Copypasta from check_free().
//         if !found.is_live {
//             report_already_freed_memory(found, "Basic.realloc()", trace);
//             return;
//         }

//         check_for_allocator_mismatch(found, allocator, "Basic.realloc()", trace);
//         found.is_live = false;
//         found.vis_reported_freed = false;
//         found.free_site_trace = find_or_pack_stack_trace(trace);

//         #if VISUALIZE_MEMORY_DEBUGGER add_free_this_frame(found, found.size);

//         return;
//     }

//     if !found.is_live report_already_freed_memory(found, "Basic.realloc()", trace);
//     check_for_allocator_mismatch(found, allocator, "Basic.realloc()", trace);

//     if old_memory == new_memory {
//         #if VISUALIZE_MEMORY_DEBUGGER {
//             delta := new_size - found.size;
//             if delta >= 0 {
//                 add_allocation_this_frame(found, delta);
//             } else {
//                 add_free_this_frame(found, -delta);
//             }
//         }

//         found.size = new_size;
//         found.is_live = true;
//         found.free_site_trace = null;
//     } else {
//         found.is_live = false;
//         found.vis_reported_freed = false;
//         found.free_site_trace = find_or_pack_stack_trace(trace);
//         add_allocation_to_table(new_memory, new_size, allocator, trace);

//         #if VISUALIZE_MEMORY_DEBUGGER {
//             add_free_this_frame(found, found.size);
//         }
//     }
// }

// _check_create_heap :: (a: Allocator) {
//     // We do not yet do anything for heap create; if we want to check
//     // for double-heap-destroy, or invalid heap pointers, we could have
//     // a separate table for when heaps are live.
// }

// _check_destroy_heap :: (a: Allocator) {
//     // @Speed: When you destroy a heap, we walk over all allocations and
//     // mark the allocations from that heap as free. This is very slow but
//     // we have just implemented multiple heaps, and we expect to do something
//     // better here eventually.   -jblow, 25 January 2023

//     // Note that we do not yet check for invalid heaps or multiple heap destroys.
//     lock(*address_table_mutex);
//     defer unlock(*address_table_mutex);

//     trace := context.stack_trace;

//     for address_table {
//         if it.allocator.proc != a.proc continue;
//         if it.allocator.data != a.data continue;

//         if it.is_live {
//             // @Copypasta from check_free().
//             it.is_live = false;
//             it.vis_reported_freed = false;
//             it.free_site_trace = find_or_pack_stack_trace(trace);
//             #if VISUALIZE_MEMORY_DEBUGGER add_free_this_frame(it, it.size);
//         }
//     }
// }


// add_allocation_to_table :: (memory: *void, size: s64, allocator: Allocator, trace: *Stack_Trace_Node) {
//     assert(memory != null);

//     // @Speed: We would like not to do the allocations inside this routine from within the mutex,
//     // but e.g. we don't want to change alloc_site_trace outside the mutex either... it just needs
//     // some rearranging and maybe it won't be simple. I think we need a way to say "ensure there's
//     // space for at least one more."
//     lock(*address_table_mutex);
//     defer unlock(*address_table_mutex);

//     allocation, success := table_find(*address_table, memory);  // This could be an address that was previously freed.

//     if success {
//         if allocation.is_live {
//             // This should not happen?!?
//             report_allocation_of_already_live_memory(allocation, trace);
//             assert(allocation.pointer == memory);
//         }
//     } else {
//         // Manually allocate an Allocation so that we don't
//         // confusingly go through the tracker stuff.
//         // (We still will when address_table_pool allocates its own page,
//         // just less often...)

//         allocation = cast(*Allocation) get(*address_table_pool, size_of(Allocation));
//         allocation.* = .{pointer = memory};
//         assert(allocation.alloc_site_trace == null);
//         assert(allocation.free\_site_trace == null);

//         table_add(*address_table, memory, allocation);
//     }

//     allocation.size            = size;
//     allocation.thread_index    = context.thread_index;
//     allocation.propagates_leak_ownership = true;
//     allocation.is_live         = true;
//     allocation.vis_reported_freed = false;
//     allocation.allocator       = allocator;
//     allocation.free_site_trace = null;
//     allocation.visualization_update_cycle = current_visualization_update_cycle;

//     allocation.index = next_allocation_index;
//     next_allocation_index += 1;

//     // We assume if we don't have a trace now, we didn't have one on the old Allocation,
//     // so no need to clear it.
//     if trace {
//         packed := find_or_pack_stack_trace(trace);
//         allocation.alloc_site_trace = packed;

//         #if VISUALIZE_MEMORY_DEBUGGER add_allocation_this_frame(allocation, allocation.size);
//     }
// }

// add_allocation_this_frame :: (a: *Allocation, size: s64) { // address_table_mutex must be held to call this.
//     allocator: Allocator;  // @UnfinishedAllocFree cleanup
//     allocator.proc = pool_allocator_proc;
//     allocator.data = *address_table_pool;
//     push_allocator(allocator);

//     trace := a.alloc_site_trace;

//     this_frame := find_or_add(*allocs_this_frame, trace);
//     this_frame.count += 1;
//     this_frame.bytes += size;
//     this_frame.alloc_site_trace = trace;
//     this_frame.allocator_proc   = a.allocator.proc;
// }

// add_free_this_frame :: (a: *Allocation, size: s64) { // address_table_mutex must be held to call this.
//     allocator: Allocator;  // @UnfinishedAllocFree cleanup
//     allocator.proc = pool_allocator_proc;
//     allocator.data = *address_table_pool;
//     push_allocator(allocator);

//     traces: Alloc_And_Free_Traces;
//     traces.alloc_site_trace = a.alloc_site_trace;  // One free site could free things for several allocation traces. So to avoid confusion around this, we hash by both, so that frees for different allocating sites go into different buckets. (This could be annoying if we don't do good grouping on alloc sites).
//     traces.free_site_trace  = a.free_site_trace;

//     this_frame := find_or_add(*frees_this_frame, traces);
//     this_frame.count += 1;
//     this_frame.bytes += size;
//     this_frame.alloc_site_trace = a.alloc_site_trace;
//     this_frame.free\_site_trace = a.free\_site_trace;
//     this_frame.allocator_proc   = a.allocator.proc;
// }

// allocations_before_this_call_will_not_be_considered_leaks :: () {
//     if !initted  init();

//     lock(*address_table_mutex);
//     defer unlock(*address_table_mutex);
//     first_leak_report_allocation_index = next_allocation_index;
// }

// this_allocation_is_not_a_leak :: (memory: *void) {
//     if !memory return;  // Don't worry about null.

//     lock(*address_table_mutex);
//     defer unlock(*address_table_mutex);
//     found, success := table_find(*address_table, memory);
//     if !success {
//         report_use_of_unknown_memory(memory, "Basic.this_allocation_is_not_a_leak()", context.stack_trace);
//         exit(1);
//         return;
//     }

//     found.index = 0;
// }

// this_allocation_leaks_todo :: (memory: *void) {
//     this_allocation_is_not_a_leak(memory);
// }

// this_allocation_does_not_propagate_leak_ownership :: (memory: *void) {
//     if !memory return;  // Don't worry about null.

//     lock(*address_table_mutex);
//     defer unlock(*address_table_mutex);

//     found, success := table_find(*address_table, memory);
//     if !success return;  // Just ignore

//     found.propagates_leak_ownership = false;
// }

// report_memory_leaks :: (options: Leak_Report_Options = .{}) {
//     report := make_leak_report(options);
//     defer deinit(*report);

//     log_leak_report(report, options);
// }

// //
// // We provide a data structure version of the leak report, so that you can
// // draw it graphically, save it to something that you analyze over time, etc,
// // and you don't have to parse it and put up with any inaccuracies or
// // uncertainties that would arise due to that.
// //
// make_leak_report :: (options: Leak_Report_Options = .{}, for_visualizer := false) -> Leak_Report {
//     if !initted  init();

//     //
//     // Note: We are going to be holding live_table_mutex for a long time! In general,
//     // you only want this routine to be called when you are done, and don't have
//     // an actively running program trying to do stuff in a timely manner.
//     //

//     context.inside_memory_debugger = true;
//     defer context.inside_memory_debugger = false;

//     lock(*address_table_mutex);
//     defer unlock(*address_table_mutex);

//     report: Leak_Report;
//     set_allocators(*report.pool);

//     if !for_visualizer {
//         if options.scan_global_memory_to_remove_leaks {
//             do_scan_global_memory_to_remove_leaks();
//         }

//         if options.scan_leaks_to_combine {
//             do_scan_leaks_to_combine(*report);
//         }
//     }

//     allocated_summary_table: Table(*Packed_Stack_Trace, *Leak_Summary);
//     defer deinit(*allocated_summary_table);

//     first_index := ifx !for_visualizer then first_leak_report_allocation_index;

//     a: Allocator;
//     a.proc = pool_allocator_proc;
//     a.data = *report.pool;

//     for allocation, memory: address_table {
//         if !allocation.is_live continue;

//         if allocation.index == 0 {
//             // It might be marked 0 because we propagated it to another leak
//             // that points at it. So, check that.
//             // Later if we get organized we might actually flag this in a clear way,
//             // so we don't need to check the table.

//             handled := false;
//             if report.leak_combiner_table.count {
//                 record := table_find_pointer(*report.leak_combiner_table, memory);
//                 handled = record && record.my_bytes_were_combined_into_this_parent;
//             }

//             if !handled {
//                 report.marked_as_non_leak_allocations += 1;
//                 report.marked_as_non_leak_bytes       += allocation.size;
//             }
//         }

//         if allocation.index < first_index continue;

//         summary, success := table_find(*allocated_summary_table, allocation.alloc_site_trace);
//         if !success {
//             summary = New(Leak_Summary,, a);
//             summary.alloc_site_trace = allocation.alloc_site_trace;
//             summary.allocator_proc   = allocation.allocator.proc;    // We ignore the data for now.
//             table_add(*allocated_summary_table, allocation.alloc_site_trace, summary);
//         }

//         summary.count += 1;

//         if allocation.visualization_update_cycle == current_visualization_update_cycle { // This is the thing we are trying to get to by setting was_unlive.
//             summary.allocations_since_last_visualizer_update += 1;
//             summary.bytes_allocated_since_last_visualizer_update += allocation.size;
//         }

//         summary.bytes += allocation.size;

//         if report.leak_combiner_table.count {
//             record := table_find_pointer(*report.leak_combiner_table, memory);
//             if record {
//                 assert(!record.my_bytes_were_combined_into_this_parent);   // If this is true, we should have marked it as no longer being a leak.
//                 summary.child_count += record.child_count;
//                 summary.child_bytes += record.child_bytes;
//             }
//         }
//     }

// /* :WhyDoesThisBreakThings??
//     hotted := 0;
//     for summary_table {
//         if it.allocations_since_last_visualizer_update {
//             hotted += 1;
//         }
//     }

//     log("hotted %/%\n", hotted, summary_table.count);
// */

//     output: [..] *Leak_Summary;
//     output.allocator = a;

//     array_reserve(*output, allocated_summary_table.count);

//     for summary: allocated_summary_table {  // Copy into a linear array so we can sort.
//         array_add(*output, summary);
//     }

//     for options.group_by_these_calls {
//         group_summaries(*report, *output, it);
//     }

//     quick_sort(output, x => -(x.bytes + x.child_bytes));

//     report.sorted_summaries = output;

//     current_visualization_update_cycle += 1;

//     return report;
// }

// log_leak_report :: (report: Leak_Report, options: Leak_Report_Options = .{}) {
//     if !initted  init();

//     // Do NOT set inside_memory_debugger, because if we do, then
//     // when the temporary allocator allocates an overflow page,
//     // we would not record that, then if the user resets Temporary_Storage,
//     // we will not know that this page was legitimately allocated.

//     maybe_s :: (x: $T) -> string {
//         return ifx x == 1 then "" else "s";
//     }

//     bytes_total: s64;
//     leaks_total: s64;
//     for summary: report.sorted_summaries {
//         from_root := -1;
//         from_leaf := -1;
//         grouped_string := "";
//         if summary.group_info {
//             info := summary.group_info;
//             grouped_string = tprint(", grouped from % stack traces for \"%\" in \"%\"", commas(info.sub_summaries.count), info.procedure.procedure_name, info.procedure.module_name);
//             from_root = info.root_nodes_in_common;
//             from_leaf = info.leaf_nodes_in_common;
//         }

//         if summary.child_count {
//             // Print a special breakout that includes child bytes, but also prints the original bytes.
//             bytes := summary.bytes + summary.child_bytes;
//             count := summary.count + summary.child_count;
//             log("\n----- % byte% in % allocation%0% [including aggregated children pointed at by the original memory, which % % byte% in % allocation%] -----\n", commas(bytes), maybe_s(bytes), commas(count), maybe_s(count), grouped_string,
//                 ifx summary.count > 1 then "were" else "was", commas(summary.bytes), maybe_s(summary.bytes), commas(summary.count), maybe_s(summary.count));
//         } else {
//             log("\n----- % byte% in % allocation%4% -----\n", commas(summary.bytes), maybe_s(summary.bytes), commas(summary.count), maybe_s(summary.count), grouped_string);
//         }

//         bytes_total += summary.bytes;
//         leaks_total += summary.count;

//         bytes_total += summary.child_bytes;
//         leaks_total += summary.child_count;

//         packed := summary.alloc_site_trace;
//         if packed {
//             first := 0;
//             last  := packed.nodes.count - 1;

//             if options.known_allocation_leaves || options.roots_to_skip || options.group_by_these_calls {
//                 first, last = trim_displayed_trace_based_on_options(options, packed);
//             }

//             my_log_stack_trace(packed, first, last, from_root, from_leaf, summary.group_info);
//         } else {
//             log("(stack trace unavailable)\n");
//         }
//     }

//     log("\nTotal: % byte% in % allocation%.\n", commas(bytes_total), maybe_s(bytes_total), commas(leaks_total), maybe_s(leaks_total));
//     log("\nMarked as non-leaks: % byte% in % allocation%.\n", commas(report.marked_as_non_leak_bytes), maybe_s(report.marked_as_non_leak_bytes), commas(report.marked_as_non_leak_allocations), maybe_s(report.marked_as_non_leak_allocations));
// }

// deinit :: (report: *Leak_Report) {
//     if !initted  init();

//     // If called from within the debugger, leave the flag true!
//     old := context.inside_memory_debugger;
//     context.inside_memory_debugger = true;
//     defer context.inside_memory_debugger = old;

//     release(*report.pool);
// }

// #scope_file


// init :: () {
//     Atomics :: #import "Atomics";

//     // We need to set up our mutexes, etc.
//     // But we don't have anything to synchronize on yet, and maybe
//     // multiple threads will enter allocator procs at the same time.

//     // So, just for this routine, we loop on spin_boolean, like a
//     // spin lock, but we sleep on the inside, because if someone else
//     // managed to take the lock, they are going to init and we are fine...
//     // *but* we still need to take the spinlock to ensure we are
//     // synchronized.

//     // We would not need to do this if we had a way to register routines
//     // that run at startup. I have been avoiding this since we took out
//     // constructors, but maybe we will want to add it back in.

//     // @Incomplete:
//     // @Correctness: We do not currently have an atomic_read, which we
//     // would like to have for 'initted' above; otherwise
//     // we are not strictly correct since maybe a cache will never see
//     // that it has been set to true, and we will send everyone here
//     // to spin, which is sad!
//     first_initter := true;
//     while (1) {
//         success := Atomics.compare_and_swap(*spin_boolean, false, true);
//         if success {
//             if first_initter {
//                 old := context.inside_memory_debugger;
//                 context.inside_memory_debugger = true;
//                 defer context.inside_memory_debugger = old;

//                 set_allocators(*address_table_pool, Context_Base.default_allocator);
//                 init(*stack_trace_table_mutex);
//                 init(*address_table_mutex);
//                 {
//                     // We just use the heap for stack_trace_table right now. We may change this.
//                     push_allocator(Context_Base.default_allocator);
//                     init(*stack_trace_table, 1024);
//                 }

//                 {
//                     push_allocator(pool_allocator_proc, *address_table_pool);
//                     init(*address_table, 1024*1024);  // Start with a table of some size. Bigger programs will want it much bigger; we probably want to provide a way to init with a better guess.
//                 }

//                 get(*address_table_pool, 8);  // Purely for developer convenince; pre-allocate a new block so that we don't get extra allocation tracking happening during the first allocation when we are trying to debug changes to the system. This line could be removed.

//                 Atomics.atomic_swap(*initted, true);
//             }

//             success = Atomics.compare_and_swap(*spin_boolean, true, false);
//             assert(success);

//             return;
//         } else {
//             first_initter = false;
//             sleep_milliseconds(1);
//         }
//     }
// }

// get_memory_hash :: (/*record: *Allocator_Record,*/memory: *void) -> u32 #no_aoc {
//     // Multiply by 11400714819323198485, 2**64 divided by the golden ratio. This is Knuth's multiplicative hashing.
//     // We probably want a better hash function here.

//     // Looks like we swapped in a different constant. I am not sure why... was this random?
//     // Should we change it back? We might have been getting bad birthday paradox collisions
//     // due to the Knuth hash, and just changed it to something else to do better, but,
//     // since then we fixed the Hash_Table to hopefully not have this problem.
// //    factor: u64 = 11400714819323198485;
//     factor: u64 = 11400714819323185;

//     b := (cast(u64) memory) * factor;
//     return cast,trunc(u32) b;
// }

// report_use_of_unknown_memory :: (memory: *void, procedure_name: string, trace: *Stack_Trace_Node) {
//     log_error("----- Memory Debugging Error! Attempt to call % on an address that was not generated by Basic.alloc. The address was: %. -----\n", procedure_name, memory);

//     if context.temporary_storage {
//         result := temporary_allocator_proc(.IS_THIS_YOURS, 0, 0, memory, null);
//         if result {
//             log("... This memory belongs to this thread's Context.Temporary_Storage, so it was possibly generated by calling talloc() or with context.allocator set to the temporary allocator (currently this Memory_Debugger screens such allocations out.)\n");
//         }
//     }

//     if trace {
//         log_stack_trace(trace);
//     } else {
//         log("(Stack traces are disabled.)\n");
//     }

//     log("--------------------------------------------------------------\n");
// }

// report_already_freed_memory :: (allocation: *Allocation, name: string, trace: *Stack_Trace_Node) {
//     memory := allocation.pointer;
//     log_error("----- Memory Debugging Error! Attempt to call % on memory that was already freed. The address was: %. -----\n", name, memory);

//     log("\nHere is the stack by which we called %:\n", name);
//     if trace {
//         log_stack_trace(trace);
//     } else {
//         log("(Stack traces are disabled.)\n");
//     }

//     log("\nHere is how % was freed:\n", memory);
//     if allocation.free_site_trace.nodes {
//         log_stack_trace(*allocation.free_site_trace.nodes[0]);
//     } else {
//         log("(Stack traces are disabled.)\n");
//     }

//     log("\nHere is how % was first allocated:\n", memory);
//     if allocation.alloc_site_trace {
//         log_stack_trace(*allocation.alloc_site_trace.nodes[0]);
//     } else {
//         log("(Stack traces are disabled.)\n");
//     }

//     log("--------------------------------------------------------------\n");
// }

// find_or_pack_stack_trace :: (trace: *Stack_Trace_Node) -> *Packed_Stack_Trace {
//     // All callers want us to skip 1 layer of stack reporting, because that's just
//     // _check_alloc or whatever:
//     trace = ifx trace then trace.next;

//     lock(*stack_trace_table_mutex);  // Is this @Redundant with address_table_mutex?
//     defer unlock(*stack_trace_table_mutex);

//     // The trace's hash is in this case the key to the table as well,
//     // because we aren't looking up a pointer, we want to know if we have
//     // gotten this exact call trace before (with high probability).

//     hash := ifx trace then trace.hash + trace.line_number;

//     packed, success := table_find(*stack_trace_table, hash);
//     if success return packed;

//     push_allocator(pool_allocator_proc, *address_table_pool);  // Must remain pushed for the entire rest of the procedure...!

//     packed_data := pack_stack_trace(trace);  // Does allocations.

//     packed = cast(*Packed_Stack_Trace) get(*address_table_pool, size_of(Packed_Stack_Trace));
//     packed.* = .{};
//     packed.nodes = packed_data;
//     packed.hash  = hash;

//     if packed.nodes.count {
//         // Right now there is a node at the end that comes from startup that has no Procedure_Info;
//         // we'll just take it out for now.
//         if !packed.nodes[packed.nodes.count-1].info  packed.nodes.count -= 1;
//     }

//     // The hash table already had its allocator set at init time, so no need to worry.
//     table_add(*stack_trace_table, packed.hash, packed);

//     #if VISUALIZE_MEMORY_DEBUGGER {
//         // So the visualizer knows what to tell the client about.
//         array_add(*pending_stack_traces, packed);  // Does allocations.
//     }

//     return packed;
// }

// report_allocation_of_already_live_memory :: (found: *Allocation, trace: *Stack_Trace_Node) {
//     log_error("----- Memory Debugging Error! We somehow got an allocation for an address that the memory debugging system thought was still live: %. This should not happen! Maybe it's heap corruption, maybe a bug in the debugging system. -----\n", found.pointer);
//     log_stack_trace(trace);
// }

// get_allocator_description :: (a: Allocator) -> string /* Temporary_Storage */ {
//     s: string;
//     if a.proc == runtime_support_default_allocator_proc {
//         s = tprint("Context.default_allocator (proc == %, data == %)", a.proc, a.data);
//     } else {
//         // @Speed: We could cache this result per allocator so we don't call this a zillion times?
//         // In case the allocator itself is slow at responding to CAPS? (But probably it isn't, so who cares?)
//         version: string;
//         a.proc(.CAPS, 0, 0, *version, null);
//         if version {
//             s = tprint("% (an allocator with proc == %, data == %)", version, a.proc, a.data);
//         } else {
//             s = tprint("(an unidentified allocator with proc == %, data == %)", a.proc, a.data);
//         }
//     }

//     return s;
// }

// check_for_allocator_mismatch :: (allocation: *Allocation, allocator: Allocator, name: string, trace: *Stack_Trace_Node) {
//     if (allocation.allocator.proc != allocator.proc) || (allocation.allocator.data != allocator.data) {
//         log_error("----- Memory Debugging Error! When calling %, there was an allocator/allocator_data mismatch. The address was: %. -----\n", name, allocation.pointer);

//         proc := allocation.allocator.proc;
//         desc_a := get_allocator_description(allocation.allocator);
//         desc_b := get_allocator_description(allocator);

//         log("This memory was allocated with %.\n", desc_a);
//         log("% was called with %.\n", name, desc_b);

//         log_stack_trace(trace);
//     }
// }

// my_log_stack_trace :: (packed: *Packed_Stack_Trace, first: s64, last: s64, from_root: s64, from_leaf: s64, group_info: *Group_Info) {
//     // Unlike the version in modules/Basic, here we want to print
//     // a subset of the stack trace, and we know it's packed
//     // in an array.

//     ellipses_i0 := from_leaf;  // We set this if we are doing a group stack trace, so we can draw a "...".
//     if ellipses_i0 <= first {
//         // Show at least some context at the leaves, if we have it, even if that was
//         // elided due to being a common allocation root. @Improvement: Maybe in this case
//         // we just don't group these guys? The problem is that we do the root trimming
//         // *after* the intersection, so we don't have this information yet.

//         if ellipses_i0 > 0  first = ellipses_i0 - 1;
//     }

//     // Do a first pass to find the longest width of each procedure name, so we can
//     // output something nicer.
//     longest := 0;
//     for i: first..last {
//         node := *packed.nodes[i];
//         if node.info  longest = max(longest, node.info.name.count);
//     }

//     SPACES     :: "                                            ";
//     PAD        :: 1;

//     longest += PAD;
//     longest =  min(longest, SPACES.count);


//     ellipses_i1 := -1;

//     if from_root >= 0 {
//         ellipses_i1 = packed.nodes.count - 1 - from_root;

//         // Expand 'first' and 'last' to include the ellipses range, if needed.
//         if first >= ellipses_i0  first = max(0, ellipses_i0 - 1);
//         if last  <= ellipses_i1  last  = min(packed.nodes.count-1, ellipses_i1+1);
//     }

//     for i: first..last {
//         node := *packed.nodes[i];
// 		if !node.info continue;  // @Cleanup: Figure out why this happens; I thought we filtered this out when computing 'last'?

//         if (i >= ellipses_i0) && (i <= ellipses_i1) {
//             if i == ellipses_i0 {
//                 log("...\n");
//             }

//             continue;
//         }

//         periods := SPACES;
//         periods.count = max(0, longest - node.info.name.count);
//         periods.data  += longest - periods.count;

//         // See the comments in log_stack_trace().
//         if !node.info continue;

//         multiple_line_numbers: [..] s64;
//         if group_info {
//             //
//             // :MultipleLineNumbers
//             //
//             // When we have grouped call stacks, we want to provide intelligible information
//             // in as brief and readable form as possible. One thing that happens once in a while
//             // is that procedure A might call B from different line numbers with different arguments.
//             // Rather than say "we don't know what the calling sites are, they are just in A", we
//             // collect and sort all the originating line numbers so that we can print them out.
//             //
//             multiple_line_numbers.allocator = __temporary_allocator;
//             initial_line_number := node.line_number;
//             for sub: group_info.sub_summaries {
//                 trace := sub.alloc_site_trace;

//                 // Map this into the target stack trace, which
//                 // is a different height, probably!
//                 j := i;
//                 if i > ellipses_i1  {
//                     below := packed.nodes.count - 1 - i;
//                     j = trace.nodes.count - 1 - below;
//                     if j <= ellipses_i0 continue;  // Sometimes you might have a call stack with no ... in the middle, blended in with stacks that do have ellipses. In that case the pre-ellipses and post-ellipses portions might overlap. Here we are just getting rid of that overlap.
//                 }

//                 assert(node.info == trace.nodes[j].info);

//                 other := trace.nodes[j];
//                 if other.line_number != initial_line_number {
//                     if !multiple_line_numbers  array_add(*multiple_line_numbers, initial_line_number);
//                     array_add_if_unique(*multiple_line_numbers, other.line_number);
//                 }
//             }

//             quick_sort(multiple_line_numbers, x => x);
//         }

//         if multiple_line_numbers {
//             builder: String_Builder;  // @Speed! Pass this in from the outside so we don't keep recreating?

//             builder.allocator      = __temporary_allocator;

//             for multiple_line_numbers {
//                 if it_index != 0  append(*builder, ", ");
//                 print_to_builder(*builder, "%", it);
//             }

//             concatenated := builder_to_string(*builder);
//             log("%1% %:(%)\n", node.info.name, periods, node.info.location.fully_pathed_filename, concatenated);
//         } else {
//             log("%1% %:%\n", node.info.name, periods, node.info.location.fully_pathed_filename, node.line_number);
//         }
//     }
// }

// trim_displayed_trace_based_on_options :: (options: Leak_Report_Options, packed: *Packed_Stack_Trace) -> (first: s64, last: s64) {
//     last  := packed.nodes.count-1;

//     //
//     // These two loops are a bit different.
//     // The loop that decrements 'last' is trimming the roots of the displayed call stack
//     // (since the array indices go from 0 == leaf); as long as the nodes[last] node
//     // has a name that's in 'options', keep trimming. As soon as one node does not match,
//     // then stop.
//     //
//     // The loop that increments 'first' has a different policy. As long as *any* node
//     // matches anything in 'options', we bump first forward to that point. The reason is,
//     // we just want to let the user specify the known_allocation_leaves, and not worry
//     // about every intermediate procedure called by those leaves.
//     //
//     while last >= 0 {
//         node := *packed.nodes[last];

//         // If there is a null node at the top (which usually or always happens!), skip.
//         if !node.info {
//             last -= 1;
//             continue;
//         }

//         // @Speed: Use a hash table, probably??
//         found := false;
//         for options.roots_to_skip {
//             if procedures_match(it, <<node) {
//                 found = true;
//                 break;
//             }
//         }

//         if !found break;
//         last -= 1;
//     }

//     for < i: last..0 {  // Go from last downward so that we hit the rootmost allocation leaf then stop.
//         node := *packed.nodes[i];
//         // @Speed: Use a hash table, probably??
//         for leaf: options.known_allocation_leaves {
//             if procedures_match(leaf, <<node) {
//                 return i, last;
//             }
//         }
//     }

//     return 0, last;
// }


// procedures_match :: (to_elide: Procedure_To_Elide, node: Stack_Trace_Node) -> bool {
//     info := node.info;
//     if !info return false;

//     if info.name != to_elide.procedure_name return false;

//     // We don't have module information in Stack_Trace_Procedure_Info,
//     // apart from the Source_Code_Location, so, for now we just do
//     // a substring check (ugh!)

//     if to_elide.module_name {
//         if !contains(info.location.fully_pathed_filename, to_elide.module_name) return false;
//     }

//     return true;
// }

// // Hash function called from within the hash table.
// get_hash_from_stack_trace :: (hash: u64) -> u32 {
//     return cast,trunc(u32) hash;
// }


// group_summaries :: (report: *Leak_Report, summaries: *[..] *Leak_Summary, procedure: Procedure_To_Elide) {
//     // Find the first match. From there, look at subsequent matches, and when found,
//     // put them into the first match's sorted_summaries array, removing them in-place
//     // by putting the last member of 'reports' there. ('reports' is not yet sorted,
//     // so it is fine if we scramble it.)

//     target_summary: *Leak_Summary;
//     target_summary_index: s64;
//     for i: 0..summaries.count-1 {
//         summary := (<<summaries)[i];
//         if summary_should_be_grouped(summary, procedure) {
//             target_summary       = summary;
//             target_summary_index = i;
//             break;
//         }
//     }

//     if !target_summary return;

//     matches: [..] *Leak_Summary;
//     matches.allocator = __temporary_allocator;  // @Incomplete: Make this be some memory on the Report? We only need one array that is the max size of the initial report.

//     i := target_summary_index + 1;
//     while i < summaries.count {
//         summary := (<<summaries)[i];
//         if !summary_should_be_grouped(summary, procedure) {
//             i += 1;
//             continue;
//         }

//         array_add(*matches, summary);

//         // Leave i where it is, as we will overwrite this in the array now.
//         (<<summaries)[i] = (<<summaries)[summaries.count-1];
//         summaries.count -= 1;
//     }

//     if !matches return; // Nothing to match against!

//     summary_node: *Leak_Summary;
//     {
//         push_allocator(pool_allocator_proc, *report.pool);
//         results: [..] *Leak_Summary;

//         array_reserve(*results, matches.count + 1);  // 1 for target_summary;
//         array_add(*results, target_summary);
//         array_add(*results, ..matches);

//         info := New(Group_Info);
//         info.procedure     = procedure;
//         info.sub_summaries = results;

//         summary_node = New(Leak_Summary);
//         summary_node.group_info = info;

//         assert(results.count > 0);
//         summary_node.allocator_proc = results[0].allocator_proc;

//         trace := target_summary.alloc_site_trace;  // @Temporary? Just copy the first trace over for now ... ?
//         summary_node.alloc_site_trace = trace;  // @Temporary? Just copy the first trace over for now ... ?

//         from_root := trace.nodes.count;
//         from_leaf := trace.nodes.count;
//         for results {
//             summary_node.count += it.count;
//             summary_node.bytes += it.bytes;

//             summary_node.child_count += it.count;
//             summary_node.child_bytes += it.bytes;

//             if summary_node.allocator_proc != it.allocator_proc  summary_node.allocator_proc = null;

//             if it != target_summary  from_root, from_leaf = intersect_call_stacks(trace, it.alloc_site_trace, from_root, from_leaf);
//         }

//         info.root_nodes_in_common = from_root;
//         info.leaf_nodes_in_common = from_leaf;
//     }

//     (<<summaries)[target_summary_index] = summary_node;
// }

// summary_should_be_grouped :: (summary: *Leak_Summary, procedure: Procedure_To_Elide) -> bool {
//     if summary.group_info           return false;  // Don't group stuff that is already grouped, for now, unless we find a way to make that more well-defined.
//     if !summary.alloc_site_trace    return false; // We can’t group without stack traces

//     // If anything in the stack trace matches, we group.
//     for * node: summary.alloc_site_trace.nodes {
//         if procedures_match(procedure, <<node) return true;
//     }

//     return false;
// }

// intersect_call_stacks :: (a: *Packed_Stack_Trace, b: *Packed_Stack_Trace, from_root: s64, from_leaf: s64) -> (from_root: s64, from_leaf: s64) {
//     highest_root_match := 0;
//     highest_leaf_match := 0;

//     limit := min(a.nodes.count, b.nodes.count);

//     for i: 0..from_leaf-1 {
//         if i >= limit break;
//         if !nodes_match(a.nodes[i], b.nodes[i]) break;

//         highest_leaf_match = i+1;
//     }

//     for i: 0..from_root-1 {
//         if i >= limit break;
//         if !nodes_match(a.nodes[a.nodes.count-1-i], b.nodes[b.nodes.count-1-i]) break;

//         highest_root_match = i+1;
//     }

//     return highest_root_match, highest_leaf_match;
// }

// nodes_match :: (a: Stack_Trace_Node, b: Stack_Trace_Node) -> bool {
//     // :MultipleLineNumbers
//     // We don't check line numbers here, just procedure infos,
//     // because we want to be able to group call stacks for brevity
//     // even when there are different calls to some routine
//     // at different line numbers.
//     if a.info != b.info return false;

//     return true;
// }

// commas :: (n: Any) -> FormatInt {
//     result: FormatInt;
//     result.digits_per_comma = 3;
//     result.comma_string     = ",";
//     result.value            = n;
//     return result;
// }


// do_scan_global_memory_to_remove_leaks :: () {
//     // Called while holding address_table_mutex.
//     ri := get_runtime_info();
//     global_data := ri.global_data_info;
//     if !global_data return;

//     for * segment: global_data.segment_info {
//         do_scan_global_memory_to_remove_leaks(segment);
//     }
// }

// do_scan_global_memory_to_remove_leaks :: (segment: *Global_Data_Segment_Info) {
//     // Called while holding address_table_mutex.

//     // For now we only scan at alignment 8, but we can adjust this
//     // later (once we are comfortable with it) to scan at alignment 1
//     // to handle packed structs.

//     pointer_size := size_of(*void);

//     if segment.data.count < pointer_size return;

//     p := segment.data.data;
//     end := p + segment.data.count - pointer_size;

//     while p <= end {
//         defer p += pointer_size;
//         casted := cast(**void) p;
//         pointing_to := casted.*;

//         found, success := table_find(*address_table, pointing_to);
//         if success {
//             found.index = 0;
//         }
//     }
// }

// do_scan_leaks_to_combine :: (report: *Leak_Report) {
//     // Called while holding address_table_mutex.
//     // A little bit @Copypasta from do_scan_global_memory_to_remove_leaks().

//     pointer_size := size_of(*void);

//     combiner := *report.leak_combiner_table;
//     combiner.allocator = .{pool_allocator_proc, *report.pool};

//     for allocation, memory: address_table {
//         if !allocation.is_live continue;
//         if !allocation.propagates_leak_ownership continue;

//         // Even if this one is marked as not a leak, it may point at things that are.
//         // So we need to scan those, then we'll end up ignoring the aggregated allocations.
//         // if allocation.index < first_leak_report_allocation_index  continue;

//         assert(allocation.size >= 0);

//         // Memory scan @Copypasta.
//         p := memory;
//         end := p + allocation.size - pointer_size;

//         record_root: *Leak_Combiner_Record;
//         root_memory: *void;

//         while p <= end {
//             defer p += pointer_size;

//             casted := cast(**void) p;
//             pointing_to := casted.*;

//             child_allocation, success := table_find(*address_table, pointing_to);
//             if success {
//                 if pointing_to == memory      continue;  // Pointing at ourself is fine.
//                 if !child_allocation.is_live  continue;  // If we are pointing at a thing that's been freed, no worries!
//                 if child_allocation.index < first_leak_report_allocation_index  continue;

//                 // Ensure space for 2 items, so that in the case that we allocate both
//                 // in the block below, we don't end up in a situation where the second one
//                 // invalidates the first one.
//                 table_ensure_space(combiner, 2);  // :SpaceIsEnsured

//                 if !record_root {
//                     record_parent, newly_added := find_or_add(combiner, memory);
//                     root_memory = memory;

//                     // We don't want to attribute our memory to the
//                     // immediate parent, because that parent may have already been
//                     // attributed to someone else, and so on, recursively. So we
//                     // cursor our way up to the root.

//                     // @Speed: We can cache the root for each guy so that we don't
//                     // have to cursor up iteratively??

//                     record_root = record_parent;
//                     while record_root.my_bytes_were_combined_into_this_parent {
//                         root_memory = record_root.my_bytes_were_combined_into_this_parent;
//                         parent_parent := table_find_pointer(combiner, root_memory);
//                         assert(parent_parent != null);  // If this field got set, it had better be in the table!
//                         record_root = parent_parent;
//                     }
//                 }

//                 record_child := find_or_add(combiner, pointing_to);  // This does not invalidate record_root because of :SpaceIsEnsured.
//                 if !record_child.my_bytes_were_combined_into_this_parent {
//                     if record_child == record_root {
//                         // This would make a cycle. Don't do it!
//                         continue;
//                     }

//                     record_child.my_bytes_were_combined_into_this_parent = root_memory;

//                     record_root.child_count += 1                      + record_child.child_count;
//                     record_root.child_bytes += child_allocation.size  + record_child.child_bytes;

//                     // print("Cowabunga! Root % now count %, bytes %\n", record_root, record_root.child_count, record_root.child_bytes);
//                     child_allocation.index = 0;
//                 } else {
//                     // We already added this child's bytes into some other
//                     // allocation (you can easily point at an allocation from
//                     // multiple other allocations!), so don't double-count it,
//                     // please!
//                 }
//             }
//         }
//     }
// }

// //
// // Leak_Combiner_Records are stored in the leak_combiner_table,
// // which is parallel to allocation_table and just stores some other
// // stuff. It would be simpler to just store that stuff in Allocation,
// // but this probably would noticeably increase runtime overhead,
// // as we would be manipulating more data on each memory access.
// // Maybe in practice it wouldn't matter, though, and we should
// // simplify this out.
// //
// Leak_Combiner_Record :: struct {
//     child_count: s64;  // How many other leaks are pointed at by this leak (so we don't count them separately).
//     child_bytes: s64;  // Ibid, but for bytes.

//     my_bytes_were_combined_into_this_parent: *void;
// }


// #import "Hash_Table";
// #import "Hash";
// #import "Thread";
// #import "String";  // For contains(), join().
// #import "Compiler";
// #import "Sort";

// #import "Pool";      // Just so we can ignore pool_allocator. Probably want a better way to do this!
// #import "Flat_Pool"; // Just so we can ignore flat_pool_allocator. Probably want a better way to do this!

// #scope_module

// Allocation :: struct {
//     pointer: *void;
//     size:    s64;

//     index:   u64;  // Used to filter out which "leaks" we report.

//     alloc_site_trace: *Packed_Stack_Trace;
//     free_\site_trace: *Packed_Stack_Trace;

//     thread_index:   u32;

//     // These should probably be a flags field at this point:
//     propagates_leak_ownership := true;

//     is_live:        bool;    // Possibly is_live could be combined with some other field, like alloc_site_trace etc.
//     vis_reported_freed: bool;  // Whether we have told the remote client that this is freed yet. Once it has been freed, we ignore it.

//     visualization_update_cycle: u32;    // Used to compute heat during live visualizations. If we want to make this a flag, it would be something we clear every update?

//     allocator:      Allocator;
// }

// Packed_Stack_Trace :: struct {
//     hash:  u64;
//     nodes: [] Stack_Trace_Node;
// }


// current_visualization_update_cycle: u32;

// address_table_mutex: Mutex;
// address_table: Table(*void, *Allocation, get_memory_hash);

// // :WhyWeStoreAllocationsEachFrame
// // This data is *kind of* reproducable just by looking in address_table,
// // but you lose information if a particular address gets allocated, then freed,
// // then allocated again, freed again etc during the same frame. When diagnosing
// // heap behavior it's very useful not to be confused by these things, and to see
// // exactly what happened, so, here we go.
// allocs_this_frame: Table(*Packed_Stack_Trace,   Allocs_This_Frame);
// frees\_this_frame: Table(Alloc_And_Free_Traces, Frees\_This_Frame, hash_alloc_and_free_traces, compare_alloc_and_free_traces);

// next_allocation_index: u64 = 1;  // Only access this while holding address_table_mutex. We start at 1 because index 0 means it's not intended to be freed, and the exclusion from reporting falls out naturally.
// first_leak_report_allocation_index: u64 = 1;  // See above.
// address_table_pool: Pool;        // Only access this while holding address_table_mutex.

// stack_trace_table_mutex: Mutex;
// stack_trace_table: Table(u64, *Packed_Stack_Trace, get_hash_from_stack_trace);

// // Since we will allocate memory, we want a quick way to know whether
// // we should ignore our own allocations, without walking the stack.
// #add_context inside_memory_debugger := false;

// spin_boolean: bool;
// initted := false;


// hash_alloc_and_free_traces :: (traces: Alloc_And_Free_Traces) -> u32 {
//     a := fnv1a_hash(cast(u64) traces.alloc_site_trace);
//     b := fnv1a_hash(cast(u64) traces.free_site_trace);

//     return cast,trunc(u32) a ^ b;  // xor seems fine here (?) since they cannot be swapped. But maybe this is bad.
// }

