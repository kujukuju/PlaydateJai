#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";
#import "Process";

// https://github.com/pd-rs/crank/blob/main/src/main.rs

#run build(false, false, false, "C:/Program Files/PlaydateSDK");

build :: (release: bool, optimized_only: bool, simulator: bool, sdk_path: string, output_path: string = "build", output_name: string = "game", should_launch_mirror: bool = true) {
    current_workspace := get_current_workspace();
    set_build_options_dc(.{do_output = false}, current_workspace);

    make_directory_if_it_does_not_exist(tprint("%build", #filepath));

    workspace := compiler_create_workspace("Playdate Game");
    options := get_build_options(workspace);
    if simulator {
        if file_exists(tprint("%.pdx/pdex.dll", output_name)) {
            file_move(tprint("%.pdx/pdex.dll", output_name), tprint("%.pdx/pdex_old.dll", output_name));
            file_delete(tprint("%.pdx/pdex_old.dll", output_name));
        }

        options.output_type = .DYNAMIC_LIBRARY;
        // options.output_executable_name = output_name;
        // options.append_executable_filename_extension = false;
        options.output_path = output_path;
        options.output_executable_name = "pdex";
    } else {
        options.output_type = .EXECUTABLE;
        options.cpu_target = .CUSTOM;
        options.os_target = .NN_SWITCH;
        options.runtime_support_definitions = .OMIT;
        options.enable_bytecode_inliner = false;
        options.enable_bytecode_deduplication = false;
        options.entry_point_name = "eventHandlerShim";

        options.dead_code_elimination = .NONE;

        options.llvm_options.output_bitcode_before_optimizations = true;

        options.output_executable_name = "pdex";

        // options.prevent_compile_time_calls_from_runtime = true;

        options.llvm_options.target_system_triple = "armv7em-none-eabihf";
        options.llvm_options.target_system_cpu = "cortex-m7";
        // options.llvm_options.target_system_features = "+thumb2,+vfp4";
        options.llvm_options.output_bitcode = true;
        options.llvm_options.function_sections = true;

        // options.additional_linker_arguments = .[
        //     "-nostartfiles",
        //     tprint("-T%/C_API/buildsupport/link_map.ld", sdk_path),
        //     // "-T/path/to/SDK/C_API/buildsupport/link_map.ld",
        //     "--entry", "eventHandlerShim",
        //     "-mthumb", "-mcpu=cortex-m7", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16", "-D__FPU_USED=1",
        //     "-Wl,-Map=game.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs,--strip-all,-R,.comment,-g",
        // ];
    }
    // 1 mb
    // options.temporary_storage_size = 1048576;
    options.temporary_storage_size = 1024;
    options.import_path = .[tprint("%../modules", #filepath), "C:/jai/modules", tprint("%../../", #filepath), "/mnt/c/jai/modules"];

    if release || optimized_only {
        set_optimization(*options, .VERY_OPTIMIZED);
    } else {
        // options.backend = .X64;
        set_optimization(*options, .DEBUG);
    }

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
                    }
                }

            case .COMPLETE;
                // create pdx

                delete_directory(tprint("%.pdx", output_name));

                if simulator {
                    print("Building playdate game...\n");
                    run_command("pdc", output_path, tprint("%.pdx", output_name));
                    print("Done building playdate game.\n");
                    if !is_playdate_running() {
                        print("Launching simulator...\n");
                        run_playdate(tprint("%.pdx", output_name));
                    }
                } else {
                    print("Converting to arm32.\n");

                    output_files: [..] string;
                    for file: file_list(tprint("%.build", #filepath)) {
                        if !ends_with(file, "no_opt.bc") {
                            continue;
                        }

                        file_name := file;
                        file_name.count -= 3;
                        // -O2 optimization would go here
                        run_command(
                            "clang", "-target", "armv7em-none-eabihf",
                            "-mthumb", "-mcpu=cortex-m7", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16", "-D__FPU_USED=1",
                            "-falign-functions=16", "-fomit-frame-pointer", "-ffunction-sections", "-fdata-sections", "-fno-common",
                            "-fno-exceptions", "-fno-unwind-tables", // "-fpic", // fpic kind of conflicts with mword-relocations which is what it actually wants
                            "-mlong-calls", "-fno-pic", "-mno-movt",
                            // "-Wl,--emit-relocs",
                            "-gdwarf-2",
                            "-D__HEAP_SIZE=8388208", "-D__STACK_SIZE=61800",
                            "-c", file, "-o", tprint("%.o", file_name));

                        array_add(*output_files, tprint("%.o", file_name));
                    }

                    print("Compiled to object files.\n");

                    command_parts: [..] string;
                    array_add(*command_parts,
                        // "arm-none-eabi-gcc", "-nostdlib", "-nodefaultlibs", "-mcpu=cortex-m7", "-mthumb", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16", "-D__FPU_USED=1", "-O2"
                        "arm-none-eabi-gcc", "-nostartfiles",
                        "-mthumb", "-mcpu=cortex-m7", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16", "-D__FPU_USED=1",
                        "-Wl,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs", "-fno-exceptions",
                        "-mword-relocations",
                        tprint("-T%/C_API/buildsupport/link_map.ld", sdk_path),
                        "-Wl,-Map=game.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs",
                        "-Wdouble-promotion",
                        "--entry", "eventHandlerShim");
                        // "-falign-functions=16", "-fomit-frame-pointer", "-gdwarf-2", "-fverbose-asm", "-ffunction-sections", "-fdata-sections", "-mword-relocations", "-fno-common",
                        // "-nostartfiles");
                    array_add(*command_parts, ..output_files);
                    array_add(*command_parts,
                        // "-Wl,--no-dynamic-linker", "-Wl,-e,eventHandlerShim", "-Wl,--gc-sections", "-Wl,--build-id=none", "-T", tprint("%/C_API/buildsupport/link_map.ld", sdk_path), "-o", tprint("%/pdex.elf", output_path));
                        "-o", tprint("%/pdex.elf", output_path));

                    run_command(..command_parts);

                    run_command("pdc", output_path, tprint("%.pdx", output_name));


                    // command_parts: [..] string;
                    // array_add(*command_parts,
                    //     "clang", "-target", "armv7em-unknown-none-eabihf",
                    //     "-mcpu=cortex-m7", "-mthumb", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16");
                    // array_add(*command_parts, ..output_files);
                    // array_add(*command_parts,
                    //     "-o", tprint("%.elf", output_name), "-nostartfiles",
                    //     "-T", tprint("%/C_API/buildsupport/link_map.ld", sdk_path),
                    //     "--entry", "eventHandlerShim",
                    //     "-mthumb", "-mcpu=cortex-m7", "-mfloat-abi=hard", "-mfpu=fpv5-sp-d16", "-D__FPU_USED=1",
                    //     "-Wl,-Map=game.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs,--strip-all,-R,.comment,-g");

                    // run_command(..command_parts);

                    // copy_file(tprint("%.elf", output_name), tprint("%/pdex.elf", output_path));
                    // run_command("pdc", "-sdkpath", sdk_path, output_path, tprint("%.pdx", output_name));
                    // print("Done building playdate file.\n");



                    // if should_launch_mirror && !is_mirror_running() {
                    //     print("Launching mirror...\n");
                    //     run_mirror();
                    // }

                    // push somehow
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
