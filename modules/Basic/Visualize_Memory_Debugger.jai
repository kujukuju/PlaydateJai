// //
// // This code communicates the collected information about memory allocations
// // to an external visualization client like examples/codex_view.
// //

// vis_init :: () {
//     // We allow you to start the visualization client after the program is running, so
//     // if we have not connected, we keep trying. MILLISECONDS_PER_VIS_INIT controls
//     // how often we retry.

//     now := current_time_monotonic();
//     if last_update_time != APOLLO_TIME_INVALID {
//         ms := to_milliseconds(now - last_update_time);
//         if ms < MILLISECONDS_PER_VIS_INIT return;
//     }

//     last_update_time = now;

//     // It's the first try, or it's been long enough since the last try.
//     // So, let's try to connect.

//     success, channel := writer_connect(MEMORY_VISUALIZATION_CHANNEL_NAME, name_not_found_is_quiet=true);
//     if !success {
//         if !logged_retry {
//             log("Unable to connect to a memory visualization client. Will retry in case one is started.\n");
//             logged_retry = true;
//         }

//         return;
//     }

//     vis_initted = true;

//     bytes_total := size_of(Memory_Debugger_Version_Info);
//     message_success, message := writer_reserve_message(*channel, bytes_total);
//     if !message_success {
//         log_error("In vis_init(), we were unable to reserve the initial message on the channel. Disabling.\n");
//         return;
//     }

//     info := cast(*Memory_Debugger_Version_Info) message.user_write_pointer;
//     info.tag     = .RESET_AND_TELL_VERSION;
//     info.version = VIS_PROTOCOL_VERSION;
//     info.default_allocator_proc = runtime_support_default_allocator_proc;

//     writer_commit_message(*channel, *message);

//     vis_channel = channel;
//     vis_enabled = true;
// }

// maybe_add_string :: (s: string) {
//     value, found := table_find(*table_sent_strings, s);
//     if !found {
//         array_add(*to_send_strings, s);
//         index := cast(s32) table_sent_strings.count;
//         table_set(*table_sent_strings, s, index);
//     }
// }

// vis_update_if_it_has_been_long_enough :: () {
//     if !vis_initted vis_init();
//     if !vis_enabled return;

//     if did_user_level_per_frame_update return;  // Once the user calls a manual update, we expect that is the way it should go henceforth.

//     now := current_time_monotonic();
//     if last_update_time == APOLLO_TIME_INVALID {
//         last_update_time = now;
//     } else {
//         delta := now - last_update_time;
//         ms := to_milliseconds(delta);
//         if ms >= MILLISECONDS_PER_VIS_UPDATE {
//             vis_update();
//             last_update_time = now;
//         }
//     }
// }

// vis_update :: () {
//     // For each pending stack trace, see if we need to add its strings
//     // and Procedure_Infos.
//     for trace: pending_stack_traces {
//         for node: trace.nodes {
//             info := node.info;
//             value, found := table_find(*table_sent_procedure_infos, info);
//             if !found {
//                 array_add(*to_send_procedure_infos, info);
//                 table_set(*table_sent_procedure_infos, info, true);

//                 maybe_add_string(info.name);
//                 maybe_add_string(info.location.fully_pathed_filename);
//             }
//         }

//         array_add(*to_send_stack_traces, trace);
//     }

//     pending_stack_traces.count = 0;

//     // Send data for the new strings.
//     for s: to_send_strings {
//         count := cast,trunc(s32) s.count;
//         if count < 0  count = 0;

//         bytes_total := size_of(String_Info) + count;
//         success, message := writer_reserve_message(*vis_channel, bytes_total);
//         if !success break;  // We need to wait until later...!

//         data := message.user_write_pointer;
//         info := cast(*String_Info) data;
//         data += size_of(String_Info);

//         index, found := table_find(*table_sent_strings, s);
//         assert(found);

//         info.tag   = .ADD_STRING;
//         info.index = cast(String_Index) index;
//         info.count = count;

//         memcpy(data, s.data, count);

//         writer_commit_message(*vis_channel, *message);
//         remove s;
//     }

//     // Send data for the new Procedure_Infos.
//     for info: to_send_procedure_infos {
//         bytes_total := size_of(Packed_Stack_Trace_Procedure_Info);

//         success, message := writer_reserve_message(*vis_channel, bytes_total);
//         if !success break;  // We need to wait until later...!

//         p := cast(*Packed_Stack_Trace_Procedure_Info) message.user_write_pointer;

//         name_index, name_found := table_find(*table_sent_strings, info.name);
//         assert(name_found);

//         filename_index, filename_found := table_find(*table_sent_strings, info.location.fully_pathed_filename);
//         assert(filename_found);

//         p.tag              = .ADD_PROCEDURE_INFO;
//         p.name             = cast(String_Index) name_index;
//         p.filename         = cast(String_Index) filename_index;
//         p.line_number      = cast,trunc(s32) info.location.line_number;
//         p.character_number = cast,trunc(s32) info.location.character_number;
//         p.remote_address   = info;

//         writer_commit_message(*vis_channel, *message);
//         remove info;
//     }

//     // Now send data for the new stack traces.
//     for trace: to_send_stack_traces {
//         // @Incomplete: Names of these Stack_Trace_Nodes are in the wrong address space,
//         // so we can't draw them yet. We will probably send mappings for the strings
//         // so that the visualizer can put them in a hash table.

//         bytes := size_of(Single_Stack_Trace_Info) + trace.nodes.count * size_of(Stack_Trace_Node);
//         success, message := writer_reserve_message(*vis_channel, bytes);
//         if !success break;  // We need to wait until later...!

//         // Write the ADD_STACK_TRACE command, the hash, and the address in our address space
//         // of this Packed_Stack_Trace (since the Leak_Summary uses that).
//         data := message.user_write_pointer;
//         info := cast(*Single_Stack_Trace_Info) data;
//         info.tag       = .ADD_STACK_TRACE;
//         info.hash      = trace.hash;
//         info.address   = trace;
//         info.num_nodes = cast(s32) trace.nodes.count;

//         data += size_of(Single_Stack_Trace_Info);
//         memcpy(data, trace.nodes.data, trace.nodes.count * size_of(Stack_Trace_Node));
//         writer_commit_message(*vis_channel, *message);

//         remove trace;
//     }

//     // Dump the current report.
//     // @Speed -- now the amount of time it takes to generate the report matters,
//     // since we are doing it during runtime, so we will want to

//     report := make_leak_report(for_visualizer=true);  // @Incomplete: No way to set leak_report_options from here yet.
//     defer deinit(*report);

//     bytes_total := size_of(Summary_Info) + report.sorted_summaries.count * size_of(Packed_Summary) + allocs_this_frame.count * size_of(Allocs_This_Frame) + frees_this_frame.count * size_of(Frees_This_Frame);

//     success, message := writer_reserve_message(*vis_channel, bytes_total);
//     if success {
//         data := message.user_write_pointer;
//         info := cast(*Summary_Info) data;
//         info.tag           = .UPDATE_USAGE;
//         info.num_live = cast(s32) report.sorted_summaries.count;
//         info.num_allocs_this_frame = cast(s32) allocs_this_frame.count;
//         info.num_frees\_this_frame = cast(s32) frees\_this_frame.count;

//         data += size_of(Summary_Info);

//         for report.sorted_summaries {
//             p := cast(*Packed_Summary) data;
//             p.count = it.count;
//             p.bytes = it.bytes;
//             p.allocations\   _since_last_visualizer_update = it.allocations\   _since_last_visualizer_update;
//             p.bytes_allocated_since_last_visualizer_update = it.bytes_allocated_since_last_visualizer_update;

//             p.alloc_site_trace = it.alloc_site_trace;
//             p.allocator_proc   = it.allocator_proc;

//             if it.group_info {
//                 p.grouped_from_this_many_stack_traces = cast(s32) it.group_info.sub_summaries.count;
//                 p.root_nodes_in_common = cast(s32) it.group_info.root_nodes_in_common;
//                 p.leaf_nodes_in_common = cast(s32) it.group_info.leaf_nodes_in_common;
//             } else {
//                 p.grouped_from_this_many_stack_traces = 0;
//                 p.root_nodes_in_common = 0;
//                 p.leaf_nodes_in_common = 0;
//             }

//             data += size_of(Packed_Summary);
//         }

//         for * allocs_this_frame {
//             p := cast(*Allocs_This_Frame) data;
//             p.* = it.*;
//             data += size_of(Allocs_This_Frame);
//         }

//         for * frees_this_frame {
//             p := cast(*Frees_This_Frame) data;
//             p.* = it.*;
//             data += size_of(Frees_This_Frame);
//         }

//         assert(data == message.user_write_pointer + bytes_total);

//         writer_commit_message(*vis_channel, *message);
//     }

//     table_reset(*allocs_this_frame);  // Leave the memory of these arrays active so we don't keep allocating it.
//     table_reset(*frees_this_frame);
// }

// vis_fini :: () {
//     if !vis_enabled return;

//     writer_disconnect(*vis_channel);

//     vis_enabled = false;
// }

// memory_visualizer_per_frame_update :: () {
//     did_user_level_per_frame_update = true; // @Threadsafety... if we turn back on the long_enough thing, we have a race here.

//     if !vis_initted vis_init();
//     if !vis_enabled return;

//     // This is a user-level routine that you call in order to output memory info
//     // at a controlled time.
//     vis_update();
// }

// #scope_module

// pending_stack_traces: [..] *Packed_Stack_Trace;
// to_send_stack_traces: [..] *Packed_Stack_Trace;

// // When we get a new stack trace, we pool the data items we need to send
// // into these arrays, then bleed them off as we send messages.
// to_send_strings:          [..] string;
// to_send_procedure_infos:  [..] *Stack_Trace_Procedure_Info;

// // The pending_stack_traces are only sent to us when we add a new one
// // to a table from the core Memory_Debugger stuff. But there is no such
// // tracking for strings or Procedure_Infos, so we do that ourselves,
// // so we only need to send these once to the viewer.
// table_sent_strings:         Table(string, s32);
// table_sent_procedure_infos: Table(*Stack_Trace_Procedure_Info, bool);

// #scope_file

// vis_channel: Write_Channel;
// vis_enabled := false;
// logged_retry := false;

// vis_initted := false;  // Did we try to call vis_init() yet?
// did_user_level_per_frame_update := false;

// last_update_time := APOLLO_TIME_INVALID;
// last_vis_init_time := APOLLO_TIME_INVALID;

// MILLISECONDS_PER_VIS_UPDATE :: 250;
// MILLISECONDS_PER_VIS_INIT   :: 500;

// #import "Shared_Memory_Channel";
// #import "Protocol_For_Memory_Visualization";
// #import "Hash_Table";
