
#import "Bindings_Generator";
#import "Basic";
#import "File";
#import "String";
#import "BuildCpp";
#import "File_Utilities";

library: Library_Info;

#run {
    using opts: Generate_Bindings_Options;

    array_add(*include_paths, "playdate");

    array_add(*source_files, "playdate/pd_api.h");
    array_add(*source_files, "playdate/pd_api/pd_api_display.h");
    array_add(*source_files, "playdate/pd_api/pd_api_file.h");
    array_add(*source_files, "playdate/pd_api/pd_api_gfx.h");
    array_add(*source_files, "playdate/pd_api/pd_api_json.h");
    array_add(*source_files, "playdate/pd_api/pd_api_lua.h");
    array_add(*source_files, "playdate/pd_api/pd_api_scoreboards.h");
    array_add(*source_files, "playdate/pd_api/pd_api_sound.h");
    array_add(*source_files, "playdate/pd_api/pd_api_sprite.h");
    array_add(*source_files, "playdate/pd_api/pd_api_sys.h");

    array_add(*extra_clang_arguments, "-DTARGET_EXTENSION");

    strip_flags = strip_flags & (~.SYMBOLS_WITH_UNKNOWN_FOREIGN_LIBS);
    generate_compile_time_struct_checks = false;
    visitor = (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
        // decl.foreign_name = "";
        decl.library = *library;

        if decl.name == "eventHandler" {
            decl.decl_flags = .OMIT_FROM_OUTPUT;
            return .STOP;
        }

        return .RECURSE;
    };

    #if OS == .WINDOWS {
        generate_bindings(opts, "module_windows.jai");
    } else {
        assert(false, "Invalid OS.\n");
    }
}