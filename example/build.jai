#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";
#import "Process";

#run build(false, false, false, "C:/Program Files/PlaydateSDK");

build :: (release: bool, optimized_only: bool, simulator: bool, sdk_path: string, output_path: string = "build", output_name: string = "game", should_launch_mirror: bool = true) {
    current_workspace := get_current_workspace();
    set_build_options_dc(.{do_output = false}, current_workspace);

    make_directory_if_it_does_not_exist(tprint("%build", #filepath));

    workspace := compiler_create_workspace("Playdate Game");
    options := get_build_options(workspace);

    if release || optimized_only {
        set_optimization(*options, .VERY_OPTIMIZED);
    } else {
        // options.backend = .X64;
        set_optimization(*options, .DEBUG);
    }

    if simulator {
        if file_exists(tprint("%.pdx/pdex.dll", output_name)) {
            file_move(tprint("%.pdx/pdex.dll", output_name), tprint("%.pdx/pdex_old.dll", output_name));
            file_delete(tprint("%.pdx/pdex_old.dll", output_name));
        }

        options.output_type = .DYNAMIC_LIBRARY;
        // options.append_executable_filename_extension = false;
        options.output_path = output_path;
        options.output_executable_name = "pdex";
        options.import_path = .["C:/jai/modules", tprint("%../../", #filepath), "/mnt/c/jai/modules"];
    } else {
        options.output_type = .STATIC_LIBRARY;
        options.cpu_target = .CUSTOM;
        options.os_target = .NN_SWITCH;
        options.emit_debug_info = .DWARF;
        options.use_custom_link_command = true;
        options.runtime_support_definitions = .OMIT;
        options.enable_bytecode_inliner = false;
        options.enable_bytecode_deduplication = false;
        options.entry_point_name = "eventHandlerShim";

        options.dead_code_elimination = .NONE;
        options.lazy_foreign_function_lookups = true;

        options.output_executable_name = "pdex";

        // options.prevent_compile_time_calls_from_runtime = true;

        options.llvm_options.target_system_triple = "thumbv7em-none-eabihf";
        options.llvm_options.target_system_cpu = "cortex-m7";
        options.llvm_options.target_system_features = "-fp64";
        options.llvm_options.output_bitcode = true;
        options.llvm_options.output_bitcode_before_optimizations = true;
        options.llvm_options.function_sections = true;
        options.llvm_options.enable_split_modules = false;
        options.import_path = .[tprint("%../modules", #filepath), "C:/jai/modules", tprint("%../../", #filepath), "/mnt/c/jai/modules"];
    }
    // 1 mb
    // options.temporary_storage_size = 1048576;
    options.temporary_storage_size = 1024;


    compiler_begin_intercept(workspace);
    defer compiler_end_intercept(workspace);

    set_build_options(options, workspace);
    set_working_directory(#filepath);

    if simulator {
        add_build_string("DEVICE :: false;\n", workspace);
    } else {
        add_build_string("DEVICE :: true;\n", workspace);
    }

    if release {
        add_build_string("PRODUCTION :: true;\n", workspace);
    } else {
        add_build_string("PRODUCTION :: false;\n", workspace);
    }

    // source files
    files := file_list(tprint("%src", #filepath), true);
    for file: files {
        if !ends_with(file, ".jai") {
            continue;
        }

        add_build_file(file, workspace);
    }

    while true {
        message := compiler_wait_for_message();

        if message.kind == {
            case .TYPECHECKED;
                typechecked := cast(*Message_Typechecked) message;

                for typechecked.procedure_bodies {
                    body: *Code_Procedure_Body = it.expression;
                    if body.body_flags & .ALREADY_MODIFIED {
                        continue;
                    }

                    contains_asm := false;
                    for it.subexpressions {
                        if it.kind == .ASM {
                            // we won't do this for now
                            // contains_asm = true;
                        }
                    }
                    if contains_asm {
                        body := it.expression;
                        print("Removing the body of %.\n", body.header.name);
                        compiler_report(tprint("Removing the body of %.\n", body.header.name), make_location(body), .WARNING);
                        new_statements: [..] *Code_Node;
                        body.block.statements = new_statements;
                        compiler_modify_procedure(workspace, body);

                        continue;
                    }
                }

                // for typechecked.procedure_bodies {
                //     body: *Code_Procedure_Body = it.expression;
                //     if body.body_flags & .ALREADY_MODIFIED {
                //         continue;
                //     }

                //     assert(!!body.header);
                //     if body.header.name == "eventHandler" {
                //         arg := body.header.arguments[0];

                //         create_expression :: () -> *Code_Type_Definition {
                //             u32_type := New(Type_Info_Integer);
                //             u32_type.type = .INTEGER;
                //             u32_type.runtime_size = 4;
                //             u32_type.signed = false;

                //             node := New(Code_Type_Definition);
                //             node.type = New(Type_Info);
                //             node.type.type = .TYPE;
                //             node.type.runtime_size = 4;
                //             node.info = u32_type;
                //             return node;
                //         }

                //         create_resolved_declaration :: () -> *Code_Declaration {
                //             node := New(Code_Declaration);
                //             node.type = New(Type_Info);
                //             node.type.type = .TYPE;
                //             node.type.runtime_size = 4;
                //             node.name = "u32";
                //             node.flags = .IS_CONSTANT | .IS_GLOBAL;
                //             node.expression = create_expression();
                //             return node;
                //         }

                //         create_type_valued_expression :: () -> *Code_Ident {
                //             node := New(Code_Ident);
                //             node.name = "u32";
                //             node.type = New(Type_Info);
                //             node.type.type = .TYPE;
                //             node.type.runtime_size = 4;
                //             node.resolved_declaration = create_resolved_declaration();
                //             return node;
                //         }

                //         create_type_inst :: () -> *Code_Type_Instantiation {
                //             u32_type := New(Type_Info_Integer);
                //             u32_type.type = .INTEGER;
                //             u32_type.runtime_size = 4;
                //             u32_type.signed = false;

                //             node := New(Code_Type_Instantiation);
                //             node.type = New(Type_Info);
                //             node.type.type = .TYPE;
                //             node.type.runtime_size = 4;
                //             node.result = u32_type;
                //             node.type_valued_expression = create_type_valued_expression();

                //             return node;
                //         }

                //         create_pointer_u32 :: (current: *Code_Declaration) -> *Code_Declaration {
                //             u32_type := New(Type_Info_Integer);
                //             u32_type.type = .INTEGER;
                //             u32_type.runtime_size = 4;
                //             u32_type.signed = false;

                //             node := New(Code_Declaration);
                //             node.location = current.location;
                //             node.node_flags = current.node_flags;
                //             node.type = u32_type;
                //             node.name = current.name;
                //             node.type_inst = create_type_inst();
                //             node.program_export_name = current.program_export_name;

                //             return node;
                //         }

                //         body.header.arguments[0] = create_pointer_u32(body.header.arguments[0]);

                //         for it.subexpressions {
                //             if it.kind == .IDENT {
                //                 print("%\n", (cast(*Code_Ident) it).*);
                //             }
                //             print("%\n", it.*);
                //         }

                //         compiler_modify_procedure(workspace, body);
                //     }

                //     // print("%\n", it.expression.*);
                //     // print("%\n", it.subexpressions.*);
                // }

                // look for any pointers and make them u32s that runtime cast back into their respective types...
                // for typechecked.all {
                //     fix_pointers(it.expression);
                //     for it.subexpressions {
                //         fix_pointers(it);
                //     }
                // }

            case .PHASE;
                phase := cast(*Message_Phase) message;

                if phase.phase == .READY_FOR_CUSTOM_LINK_COMMAND {
                    assert(!simulator, "Simulator was ready for custom link which shouldn't happen.\n");

                    print("Converting to arm32.\n");

                    clang_command: [..] string;
                    array_add(*clang_command,
                        "clang", "-target", "thumbv7em-none-eabihf",
                        "-mthumb", "-mcpu=cortex-m7", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16",
                        "-mlong-calls", "-fpic", "-fPIC", /*"-fno-pic",*/ "-mno-movt", // hack to get it generating absolute addresses as gcc -mword-relocations... at least that's the idea
                        "-D__FPU_USED=1", "-O2", "-falign-functions=16", "-fomit-frame-pointer", "-g3", "-gdwarf-2",
                        "-Wall", "-Wno-unused", "-Wstrict-prototypes", "-Wno-unknown-pragmas", "-Wdouble-promotion",
                        "-fverbose-asm", "-fno-common", "-ffunction-sections", "-fdata-sections",
                        "-ffunction-sections", "-fdata-sections", "-fno-common",
                        "-fno-exceptions", "-fno-unwind-tables",
                        "-DTARGET_PLAYDATE=1", "-DTARGET_EXTENSION=1", "-D__HEAP_SIZE=8388208", "-D__STACK_SIZE=61800");

                    compile_buildsupport_with_gcc :: true;
                    if compile_buildsupport_with_gcc {
                        run_command(
                            "arm-none-eabi-gcc",
                            "-g3", "-c", "-mthumb", "-mcpu=cortex-m7", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16",
                            "-D__FPU_USED=1", "-O2",
                            "-falign-functions=16", "-fomit-frame-pointer", "-gdwarf-2",
                            "-Wall", "-Wno-unused", "-Wstrict-prototypes", "-Wno-unknown-pragmas",
                            "-fverbose-asm", "-Wdouble-promotion", "-mword-relocations", "-fno-common", "-ffunction-sections", "-fdata-sections",
                            "-DTARGET_PLAYDATE=1", "-DTARGET_EXTENSION=1", "-fno-exceptions",
                            tprint("%/C_API/buildsupport/setup.c", sdk_path),
                            // "-I", "C:/Program Files (x86)/GNU Arm Embedded Toolchain/10 2021.10/arm-none-eabi/include",
                            "-I", tprint("%/C_API", sdk_path),
                            "-o", tprint("%.build/setup.o", #filepath));
                    } else {
                        run_command(..combine_commands(
                            clang_command,
                            "-c",
                            tprint("%/C_API/buildsupport/setup.c", sdk_path),
                            "-I", "C:/Program Files (x86)/GNU Arm Embedded Toolchain/10 2021.10/arm-none-eabi/include",
                            "-I", tprint("%/C_API", sdk_path),
                            "-o", tprint("%.build/setup.o", #filepath)));
                    }

                    output_files: [..] string;
                    array_add(*output_files, tprint("%.build/setup.o", #filepath));

                    for file: file_list(tprint("%.build", #filepath)) {
                        if !ends_with(file, "no_opt.bc") {
                            continue;
                        }

                        file_name := file;
                        file_name.count -= 3;
                        run_command(..combine_commands(
                            clang_command,
                            "-c", file, "-o", tprint("%.o", file_name)));

                        array_add(*output_files, tprint("%.o", file_name));
                    }

                    print("Object files: %\n", output_files);

                    print("Compiled to object files.\n");

                    command_parts: [..] string;
                    array_add(*command_parts, "arm-none-eabi-gcc");
                    array_add(*command_parts, ..output_files);
                    array_add(*command_parts, "-nostartfiles",
                        "-mthumb", "-mcpu=cortex-m7", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16",
                        "-D__FPU_USED=1",
                        "-Wl,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs",
                        "-fno-exceptions", "-fno-unwind-tables",
                        "-Wdouble-promotion",
                        // "-mword-relocations",
                        tprint("-T%/C_API/buildsupport/link_map.ld", sdk_path));
                    array_add(*command_parts, "-o", tprint("%/pdex.elf", output_path));
                    array_add(*command_parts, "--entry", "eventHandlerShim");

                    run_command(..command_parts);

                    // delete_directory(tprint("%.pdx", output_name));
                    run_command("pdc", "--strip", output_path, tprint("%.pdx", output_name));

                    print("Done building pdx file.\n");

                    compiler_custom_link_command_is_complete(workspace);


                    // print("Installing pdx game...\n");

                    // run_command("pdutil", "install", tprint("%.pdx", output_name));

                    // // sleep_milliseconds(5000);
                    // sleep_milliseconds(500);

                    // print("Done installing pdx game.\n");

                    // run_command("pdutil", "run", tprint("/Games/%.pdx", output_name));

                    // print("Done building pdx file.\n");

                    // break;

                    // if should_launch_mirror && !is_mirror_running() {
                    //     print("Launching mirror...\n");
                    //     run_mirror();
                    // }
                }

            case .COMPLETE;
                // create pdx

                if simulator {
                    print("Creating pdx build...\n");
                    print("Building playdate game...\n");
                    // delete_directory(tprint("%.pdx", output_name));
                    run_command("pdc", output_path, tprint("%.pdx", output_name));
                    print("Done building playdate game.\n");
                    if !is_playdate_running() {
                        print("Launching simulator...\n");
                        run_playdate(tprint("%.pdx", output_name));
                    }
                }

                break;
        }
    }
}

is_playdate_running :: () -> bool {
    return is_process_running("PlaydateSimulator.exe");
}

is_mirror_running :: () -> bool {
    return is_process_running("Mirror.exe");
}

run_playdate :: (path: string) {
    run_process("PlaydateSimulator.exe", tprint("%\0", path).data);
}

run_mirror :: () {
    run_process("Mirror.exe");
}

is_debug :: () -> bool {
    args := get_build_options().compile_time_command_line;

    for args {
        if it == "debug" {
            return true;
        }
    }

    return false;
}

is_release :: () -> bool {
    args := get_build_options().compile_time_command_line;

    for args {
        if it == "release" {
            return true;
        }
    }

    return false;
}

is_optimized :: () -> bool {
    args := get_build_options().compile_time_command_line;

    for args {
        if it == "optimized" {
            return true;
        }
    }

    return false;
}

#scope_file

fix_pointers :: (node: *Code_Node) {
    if !node {
        return;
    }
    // print("Found node type: %\n", node.kind);

    fix_pointers(node.type);

    if node.kind == {
        case .STRUCT;
            node_struct := cast(*Code_Struct) node;
            block := node_struct.block;

            fix_pointers(node_struct.defined_type);

            // new_members := NewArray(block.members.count * 2, *Code_Scope_Entry);
            // new_statements := NewArray(block.statements.count * 2, *Code_Node);

            // print("struct block type is %\n", block.kind);
            // print("CHECKING STRUCT %\n", node_struct.defined_type.name);
            // defer print("DONE CHECKING STRUCT\n");
            // for block.members print("struct % block member % %\n", node_struct.defined_type.name, it.kind, it.name);
            // for block.statements print("struct % block statement %\n", node_struct.defined_type.name, it.kind);
            // for block.statements {
            //     assert(it.kind == .DECLARATION, "Fonud struct member of type %.\n", it.kind);
            //     print("alignemnt_expression %\n", (cast(*Code_Declaration) it).alignment_expression.kind);
            // }
            // for block.members fix_pointers(it);
            for block.statements fix_pointers(it);
            fix_pointers(node_struct.defined_type);
            node_struct.alignment = min(node_struct.alignment, 4);

        case .IDENT;
            node_ident := cast(*Code_Ident) node;
            fix_pointers(node_ident.resolved_declaration);

        case .DECLARATION;
            node_declaration := cast(*Code_Declaration) node;
            // if !node_declaration.alignment_expression {
            //     alignment_literal := New(Code_Literal);
            //     alignment_literal.value_type = .NUMBER;
            //     alignment_literal._u64 = 4;
            //     alignment_literal.value_flags = .IS_A_NUMBER;
            //     // node_declaration.alignment_expression = alignment_literal;
            //     // print(" alignmnt_expression %\n", node_declaration.alignment_expression.kind);
            // }
            // fix_pointers(node.type_inst);
            // print(" checking decl type_inst %\n", node_declaration.type_inst.kind);
            // print(" checking declaration %\n", node_declaration.expression.kind);
            fix_pointers(node_declaration.type_inst);
            fix_pointers(node_declaration.expression);

        case .BLOCK;
            node_block := cast(*Code_Block) node;
            for node_block.members fix_pointers(it);
            for node_block.statements fix_pointers(it);

        case .PROCEDURE_BODY;
            node_procedure_body := cast(*Code_Procedure_Body) node;
            fix_pointers(node_procedure_body.block);
            // fix_pointers(node_procedure_body.header);

        case .PROCEDURE_HEADER;
            node_procedure_header := cast(*Code_Procedure_Header) node;
            fix_pointers(node_procedure_header.constants_block);
            for node_procedure_header.arguments fix_pointers(it);
            for node_procedure_header.returns fix_pointers(it);
            for node_procedure_header.parameter_usings fix_pointers(it);
            // ignoring polymorph_source_header I guess?
            fix_pointers(node_procedure_header.body_or_null);

        case .IF;
            node_if := cast(*Code_If) node;
            if node_if.is_static return;
            fix_pointers(node_if.condition);
            fix_pointers(node_if.then_block);
            fix_pointers(node_if.else_block);

        case .RETURN;
            node_return := cast(*Code_Return) node;
            // skipping arguments_unsorted?
            for node_return.arguments_sorted fix_pointers(it);

        case .CAST;
            node_cast := cast(*Code_Cast) node;
            fix_pointers(node_cast.target_type);
            fix_pointers(node_cast.expression);

        case .TYPE_INSTANTIATION;
            node_type_instantiation := cast(*Code_Type_Instantiation) node;
            // print("  type_inst result: %\n", node_type_instantiation.result.*);
            fix_pointers(node_type_instantiation.result);
            fix_pointers(node_type_instantiation.must_implement);
            fix_pointers(node_type_instantiation.pointer_to);
            fix_pointers(node_type_instantiation.type_directive_target);
            fix_pointers(node_type_instantiation.array_element_type);
            fix_pointers(node_type_instantiation.array_dimension);

        case;
            // print("Unsupported node kind. %\n", node.kind);
    }
}

fix_pointers :: (type: *Type_Info) -> int {
    if !type {
        return 0;
    }

    if type.type == {
        case .POINTER;
            type.runtime_size = 4;
            // I could literally construct a new type here but I don't think I can even change it at this point
            type_pointer := cast(*Type_Info_Pointer) type;
            // type.type = .INTEGER;
            // fix_pointers(type_pointer.pointer_to);

        case .PROCEDURE;
            type.runtime_size = 4;
            type_procedure := cast(*Type_Info_Procedure) type;
            for type_procedure.argument_types fix_pointers(it);
            for type_procedure.return_types fix_pointers(it);

        case .STRUCT;
            type_struct := cast(*Type_Info_Struct) type;
            for type_struct.specified_parameters fix_pointers(it.type);
            // assert(type_struct.members.count == 0 || type_struct.members[0].offset_in_bytes == 0, "Struct member at unexpected location. % %\n", type_struct.name, type_struct.members[0].offset_in_bytes);
            member_offset := 0;
            // if type_struct.members.count > 0 {
            //     member_offset =
            for *member: type_struct.members {
                member_size := fix_pointers(member.type);
                if member.offset_into_constant_storage == -1 {
                    member_offset += member_size;
                    member.offset_in_bytes = member_offset;
                }
            }
            type.runtime_size = member_offset;

        case .ARRAY;
            type_array := cast(*Type_Info_Array) type;
            fix_pointers(type_array.element_type);

        case .TYPE;
            type.runtime_size = 4;
            // print("size: %\n", type.runtime_size);

        case;
            // print("Unsupported type kind. %\n", type.type);
    }

    return type.runtime_size;
}

combine_commands :: (a: [] string, b: ..string) -> [] string {
    combined := NewArray(a.count + b.count, string);
    for i: 0..a.count - 1 {
        combined[i] = a[i];
    }
    for i: 0..b.count - 1 {
        combined[i + a.count] = b[i];
    }
    return combined;
}

is_process_running :: (name: string) -> bool {
    #assert OS == .WINDOWS "Cannot get if playdate is running outside of windows.\n";
    #import "Windows";
    #import "Windows_Utf8";

    TH32CS_SNAPPROCESS :: 0x00000002;

    PROCESSENTRY32W :: struct {
        dwSize: u32;
        cntUsage: u32;
        th32ProcessID: u32;
        th32DefaultHeapID: u64;
        th32ModuleID: u32;
        cntThreads: u32;
        th32ParentProcessID: u32;
        pcPriClassBase: s32;
        dwFlags: u32;
        szExeFile: [260] u16;
    }

    kernel32 :: #system_library "kernel32";
    msvcrt :: #system_library "msvcrt";
    CreateToolhelp32Snapshot :: (flags: u32, pid: u32) -> HANDLE #foreign kernel32;
    Process32FirstW :: (snapshot: HANDLE, entry: *PROCESSENTRY32W) -> BOOL #foreign kernel32;
    Process32NextW :: (snapshot: HANDLE, entry: *PROCESSENTRY32W) -> BOOL #foreign kernel32;
    _wcsicmp :: (str1: *u16, str2: *u16) -> s32 #foreign msvcrt;

    snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if snapshot == INVALID_HANDLE_VALUE {
        return false;
    }

    entry: PROCESSENTRY32W;
    entry.dwSize = size_of(PROCESSENTRY32W);

    defer CloseHandle(snapshot);

    process_name := utf8_to_wide_new(name,, temp);

    has_next := Process32FirstW(snapshot, *entry);
    while has_next {
        if _wcsicmp(entry.szExeFile.data, process_name) == 0 {
            return true;
        }
        has_next = Process32NextW(snapshot, *entry);
    }

    return false;
}

run_process :: (process_name: *u8, args: *u8 = null) {
    shell32 :: #system_library "shell32";
    ShellExecuteA :: (hwnd: *void, lpOperation: *u8, lpFile: *u8, lpParameters: *u8, lpDirectory: *u8, nShowCmd: s32) -> *void #foreign shell32;

    ShellExecuteA(null, "open", process_name, args, null, SW_SHOW);
}
