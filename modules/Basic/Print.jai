#scope_file

USE_SIMD   :: (CPU == .X64);
SIMD_WIDTH :: 16;  // Bytes.

#scope_export

Formatter :: struct {
    value   : Any;
}

FormatInt :: struct {
    using #as formatter : Formatter;

    base             := 10;
    minimum_digits   := 1;
    padding          : u8 = #char "0"; // What character to use to pad the input if it’s less than minimum_digits long

    digits_per_comma : u16 = 0;  // 0 means don't draw commas.
    comma_string     := "";      // What to draw between the digits.
}

FormatFloat :: struct {
    #as using formatter : Formatter;

    width := -1;
    trailing_width := -1;

    Zero_Removal :: enum { YES; NO; ONE_ZERO_AFTER_DECIMAL; };

    zero_removal := Zero_Removal.YES;  // This will also remove the decimal if it's the last character.

    Mode :: enum { DECIMAL; SCIENTIFIC; SHORTEST; };
    mode := Mode.DECIMAL;

    // @Cleanup: We should make the thousand_separators work the same way
    // as comma_string in integers, because why would it be different?
    // Also, possibly these should be utf32 characters? I have a bit of
    // reticence about making them strings, since it's just a lot of strings
    // to put into Context.
    thousand_separators := false;
    thousand_separator_character : u8 = #char ",";
    decimal_separator_character  : u8 = #char ".";
    exponent_character           : u8 = #char "e";

    Positive_Number_Prefix :: enum { NONE; PLUS; SPACE; };
    positive_number_prefix := Positive_Number_Prefix.NONE;
}

FormatStruct :: struct {
    #as using formatter : Formatter;

    draw_type_name   := false;

    // "short form" means don't draw names, just draw values with separators. Example: {1, 3, 5}
    // "long form"  means draw name, then separator_between_name_and_value, then value. Example: {x = 1; y = 3; z = 5;}

    use_long_form_if_more_than_this_many_members := 5;  // Set this to -1 to us long form always.
    separator_between_name_and_value := " = ";

    short_form_separator_between_fields := ", ";
    long_form_separator_between_fields  := "; ";        // You could put a newline in here, for example.

    begin_string := "{";
    end_string   := "}";

    indentation_width : s32 = 4;                        // Used when outputting structs in long form if newlines are enabled.

    use_newlines_if_long_form := false;
}

FormatArray :: struct {
    #as using formatter : Formatter;

    separator    := ", ";
    begin_string := "[";
    end_string   := "]";

    printing_stopped_early_string := "...";

    draw_separator_after_last_element := false;
    stop_printing_after_this_many_elements := 100;  // Don't spam by default. If you set this to -1, it means don't ever stop printing.
}

Print_Style :: struct {
    // default_format_* ignore the Formatter part of each type.
    // They are just here so you can set the configuration parameters
    // like base, width, etc.
    // Maybe we should clean this up and make them two separate things,
    // but, this way of configuring printing is experimental for now.
    // If it sticks, we'll work on it more.  -jblow, 4 October 2020
    default_format_int:    FormatInt;
    default_format_float:  FormatFloat;
    default_format_struct: FormatStruct;
    default_format_array:  FormatArray;

    default_format_absolute_pointer: FormatInt;
    default_format_absolute_pointer.base             = 16;
    default_format_absolute_pointer.digits_per_comma = 4;
    default_format_absolute_pointer.comma_string     = "_";

    struct_printer: (builder: *String_Builder, any: Any, struct_printer_data: *void) -> bool;  // Return true if it's handled; false if Print should engage its default print routine.
    struct_printer_data: *void;

    // This is a worker variable used by Print. You probably don't
    // want to change it!
    indentation_depth: s32;

    log_runtime_errors := true;
}

#add_context print_style: Print_Style;

// Not yet deprecating the format* functions, but would like to.
// It's just still slightly inconvenient not to use them... -jblow, 21 December 2022
formatInt :: (value : Any, base := 10, minimum_digits := 1, padding: u8 = #char "0", digits_per_comma : u16 = 0, comma_string := "") -> FormatInt /*#deprecated "Use FormatInt.{...} instead."*/ {
    result : FormatInt;

    result.value            = value;
    result.base             = base;
    result.minimum_digits   = minimum_digits;
    result.padding          = padding;
    result.digits_per_comma = digits_per_comma;
    result.comma_string     = comma_string;

    return result;
}

formatFloat :: (value : Any, width := -1, trailing_width := -1, mode := FormatFloat.Mode.DECIMAL, zero_removal := FormatFloat.Zero_Removal.YES) -> FormatFloat /*#deprecated "Use FormatFloat.{...} instead."*/ {
    result : FormatFloat;

    result.value = value;
    result.width = width;
    result.trailing_width = trailing_width;
    result.mode = mode;
    result.zero_removal = zero_removal;

    return result;
}

formatStruct :: (value: Any, use_long_form_if_more_than_this_many_members := 5, use_newlines_if_long_form := false) -> FormatStruct /*#deprecated "Use FormatStruct.{...} instead."*/ {
    result: FormatStruct;
    result.value = value;
    result.use_newlines_if_long_form = use_newlines_if_long_form;
    result.use_long_form_if_more_than_this_many_members = use_long_form_if_more_than_this_many_members;

    return result;
}

//#scope_file

/*
buffer_to_string_without_copy :: (using builder: String_Builder) -> string {
    bytes := base_buffer.occupied;
    for allocated_extra_buffers  bytes += it.occupied;

    assert(occupied < SIZE);

    result : string;
    result.data  = data.data;
    result.count = occupied;

    return result;
}
*/

get_s64_from_void_pointer :: (pointer: *void, size_in_bytes: int) -> s64 {
    if size_in_bytes == {
      case 1;  return << cast(*s8)  pointer;
      case 2;  return << cast(*s16) pointer;
      case 4;  return << cast(*s32) pointer;
      case 8;  return << cast(*s64) pointer;
      case;
        if context.print_style.log_runtime_errors {
            log_error("Integer size is %.\n", size_in_bytes);
        }

        assert(false);
        return 0;
    }

    return 0;  // @Temporary: Shut up @Incomplete control flow analysis.
}

get_u64_from_void_pointer :: (pointer: *void, size_in_bytes: int) -> u64 {
    if size_in_bytes == {
      case 1;  return << cast(*u8)  pointer;
      case 2;  return << cast(*u16) pointer;
      case 4;  return << cast(*u32) pointer;
      case 8;  return << cast(*u64) pointer;
      case;
        if context.print_style.log_runtime_errors {
            log_error("Integer size is %.\n", size_in_bytes);
        }

        assert(false);
        return 0;
    }

    return 0;  // @Temporary: Shut up @Incomplete control flow analysis.
}

print_u64_base_n :: (builder: *String_Builder, v: u64, format: FormatInt) {
    base_64_characters :: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_.";

    base := cast(u64) format.base;
    assert(base >=  2);
    assert(base <= 64);

    MAX_OUTPUT_LENGTH :: 64;

    assert(format.minimum_digits >= 0);
    digits := format.minimum_digits;

    if digits > MAX_OUTPUT_LENGTH digits = MAX_OUTPUT_LENGTH;


    output : [MAX_OUTPUT_LENGTH] u8;

    end := output.data + MAX_OUTPUT_LENGTH;
    p   := end;

    while v || (digits > 0) {
        place := v % base;
        v     =  v / base;

        p -= 1;
        if place || v || p == end - 1 {
            p.* = base_64_characters[place];
        } else {
            p.* = format.padding;
        }

        digits -= 1;
    }

    if p == end && digits > 0 {
        p -= 1;
        p.* = format.padding;
    }

    assert(p >= output.data);

    if format.digits_per_comma && format.comma_string {
        s: string;
        s.data = p;
        s.count = end - p;

        per    := format.digits_per_comma;
        before := s.count % per;

        if before {
            t := s;
            t.count = before;
            append(builder, t);
            advance(*s, before);
            if s.count  append(builder, format.comma_string);  // This could be a number with fewer digits than digits_per_comma...!
        }

        while s.count > 0 {
            t := s;
            t.count = per;
            append(builder, t);
            if s.count > per append(builder, format.comma_string);
            advance(*s, per);
        }
    } else {
        append(builder, p, end - p);
    }
}

print_float :: (builder : *String_Builder, format : FormatFloat) {
    // @Cleanup: We should collapse this extra call.
    stb_print_float(builder, format);
}

print_integer :: (builder : *String_Builder, format : FormatInt) {
    any := format.value;

    assert(any.type != null);
    type := any.type;
    while type.type == .VARIANT {
        variant := cast(*Type_Info_Variant) type;
        type = variant.variant_of;
    }

    assert(type.type == .INTEGER);
    info := cast(*Type_Info_Integer) type;

    v : u64 = ---;

    if format.base == 10 {
        if info.signed {
            v_signed := get_s64_from_void_pointer(any.value_pointer, info.runtime_size);

            if v_signed < 0 {
                append(builder, "-");
                v = cast,no_check(u64) -v_signed;
            } else {
                v = cast(u64)  v_signed;
            }
        } else {
            v = get_u64_from_void_pointer(any.value_pointer, info.runtime_size);
        }
    } else {
        v = get_u64_from_void_pointer(any.value_pointer, info.runtime_size);
    }

    print_u64_base_n(builder, v, format);
}

#scope_export

print_character :: (_c: u8) {
    // A ridiculous way of printing a character.
    c := _c;
    s: string;
    s.data = *c;
    s.count = 1;
    write_string(s);
}

print :: (format_string: string, args: .. Any, to_standard_error := false) -> bytes_printed: s64 {
    builder: String_Builder;

    print_to_builder(*builder, format_string, ..args);
    written := write_builder(*builder, to_standard_error = to_standard_error);

    return written;
} @PrintLike

sprint :: (format_string: string, args: .. Any) -> string #must {
    builder: String_Builder;

    print_to_builder(*builder, format_string, ..args);

    return builder_to_string(*builder);
} @PrintLike

tprint :: (format_string: string, args: .. Any) -> string #must {
    builder: String_Builder;
    builder.allocator = __temporary_allocator;

    print_to_builder(*builder, format_string, ..args);

    return builder_to_string(*builder,, allocator = __temporary_allocator);
} @PrintLike


//
// log() formats a message, then sends it to context.logger.
// You can pass flags. source_identifier and data get copied from context.
//
log :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0, section : *Log_Section = null) {
    builder: String_Builder;

    print_to_builder(*builder, format_string, ..args);

    s := builder_to_string(*builder,, allocator = __temporary_allocator);
    if !s.count return;

    info: Log_Info;
    info.source_identifier = context.log_source_identifier;
    info.location          = loc;
    info.common_flags      = flags;
    info.user_flags        = user_flags;
    info.section           = section;
    context.logger(s, context.logger_data, info);
} @PrintLike

// Log function with section pointer as first parameter
log :: (section : *Log_Section, format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0) {
    log(format_string, ..args, loc, flags, user_flags, section);
} @PrintLike

log_error :: (format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0, section : *Log_Section = null) {
    // In case people prefer to say log_error instead of putting a flags argument on the end,
    // we provide this for convenience. Not really sure if it's worth it, but here you go.
    new_flags := flags | .ERROR;
    log(format_string, ..args, loc, new_flags, user_flags, section);
} @PrintLike

// Log error function with section pointer as first parameter
log_error :: (section : *Log_Section, format_string: string, args: .. Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags : u32 = 0) {
    new_flags := flags | .ERROR;
    log(format_string, ..args, loc, new_flags, user_flags, section);
}

append_indentation :: (builder: *String_Builder, format: *FormatStruct) {
    spaces16 :: "                ";

    num_spaces := context.print_style.indentation_depth * format.indentation_width;
    if num_spaces <= 0  return;

    div := num_spaces / 16;
    mod := num_spaces % 16;

    for 1..div  append(builder, spaces16);

    append(builder, spaces16.data, mod);
}

// Put this in file scope?
append_struct_info :: (builder: *String_Builder, info: *Type_Info_Struct, base_pointer: *void, format : *FormatStruct = null) {
    using Type_Info_Tag;

    if info.textual_flags & .UNION {  // Don't try to print unions, since we don't know what is actually in there!
        append(builder, "(union)");
        return;
    }

    if !format format = *context.print_style.default_format_struct;

    if format.draw_type_name  append(builder, info.name);

    append(builder, format.begin_string);

    use_newlines := false;
    long_form_limit := format.use_long_form_if_more_than_this_many_members;

    CheckMemberAndMaybeContinue :: (member: *Type_Info_Struct_Member, highest_offset: *int) #expand {
        // For now, don't draw constant members, since you are probably using this for
        // debugging and that can be spammy when you declare lots of constants (and it
        // adds no information usually!)   -jblow, 10 September 2015

        // ... Similarly for imported, since we usually just imported
        // stuff from the base class that we already printed or are
        // about to print.

        if member.flags & .CONSTANT continue;
        if member.flags & .IMPORTED continue;

        if member.offset_in_bytes < (<<highest_offset) continue;
        if member.type.runtime_size == 0               continue;  // Skip 'void' elements, as these can't hold values.

        <<highest_offset = member.offset_in_bytes + member.type.runtime_size;
    }

    printable_count := 0;

    highest_offset := -1;  // We use this to skip unioned things, to reduce printout size. Maybe this is not the right policy for data structures in general. -jblow, 22 March 2017
    for * info.members {
        CheckMemberAndMaybeContinue(it, *highest_offset);
        printable_count += 1;
    }

    long_form := false;
    if (long_form_limit < 0) || (printable_count > long_form_limit) {
        long_form = true;
        use_newlines = format.use_newlines_if_long_form;
    }

    if use_newlines append(builder, "\n");

    context.print_style.indentation_depth += 1;

    cursor := 0;
    highest_offset = -1;
    for * info.members {
        CheckMemberAndMaybeContinue(it, *highest_offset);
        defer cursor += 1;

        if use_newlines  append_indentation(builder, format);

        if long_form {
            append(builder, it.name);
            append(builder, format.separator_between_name_and_value);
        }

        may_be_uninitialized := false;
        for note: it.notes {
            if note == "---" {
                may_be_uninitialized = true;
                break;
            }
        }

        address := (cast(*u8) base_pointer) + it.offset_in_bytes;

        any: Any = ---;
        any.type = it.type;
        any.value_pointer = address;

        print_item_to_builder(builder, any, may_be_uninitialized=may_be_uninitialized);

        if long_form {
            append(builder, format.long_form_separator_between_fields);
        } else {
            if cursor < printable_count - 1  append(builder, format.short_form_separator_between_fields);
        }

        if use_newlines {
            append(builder, "\n");
        }
    }

    context.print_style.indentation_depth -= 1;

    if use_newlines append_indentation(builder, format);
    append(builder, format.end_string);
}

print_type_to_builder :: (builder: *String_Builder, info: *Type_Info) {
    using Type_Info_Tag;

    if info.type == STRUCT {
        info_struct := cast(*Type_Info_Struct) info;
        if info_struct.name {
            append(builder, info_struct.name);
        } else {
            if info_struct.textual_flags & .UNION {
                append(builder, "(anonymous union)");
            } else {
                append(builder, "(anonymous struct)");
            }
        }

        if info_struct.polymorph_source_struct {
            append(builder, "(");

            for * param: info_struct.specified_parameters {
                if it_index append(builder, ", ");
                append(builder, param.name);
                append(builder, "=");

                if param.offset_into_constant_storage >= 0 {
                    any: Any;
                    any.type = param.type;
                    any.value_pointer = info_struct.constant_storage.data + param.offset_into_constant_storage;
                    print_item_to_builder(builder, any);
                }
            }

            append(builder, ")");
        }

    } else if info.type == POINTER {
        info_pointer := cast(*Type_Info_Pointer) info;
        append(builder, "*");
        print_type_to_builder(builder, info_pointer.pointer_to);
    } else if info.type == ARRAY {
        info_array := cast(*Type_Info_Array) info;

        if info_array.array_type == .FIXED {
            append(builder, "[");
            print_item_to_builder(builder, info_array.array_count);
            append(builder, "]");
        } else if info_array.array_type == .VIEW {
            append(builder, "[]");
        } else if info_array.array_type == .RESIZABLE {
            append(builder, "[..]");
        } else {
            assert(false);
        }

        append(builder, " ");
        print_type_to_builder(builder, info_array.element_type);
    } else if info.type == TYPE {
        append(builder, "Type");
    } else if info.type == ENUM {
        info_enum := cast(*Type_Info_Enum)(info);
        if info_enum.name {
            append(builder, info_enum.name);
        } else {
            append(builder, "(anonymous enum)");
        }
    } else if info.type == STRING {
        append(builder, "string");
    } else if info.type == PROCEDURE {
        info_proc := cast(*Type_Info_Procedure)(info);
        append(builder, "procedure (");
        for info_proc.argument_types {
            if it_index != 0  append(builder, ", ");
            print_type_to_builder(builder, it);
        }
        append(builder, ")");

        if info_proc.return_types {
            append(builder, " -> ");

            if info_proc.return_types.count > 1  append(builder, "(");
            for info_proc.return_types {
                if it_index != 0  append(builder, ", ");
                print_type_to_builder(builder, it);
            }
            if info_proc.return_types.count > 1  append(builder, ")");
        }

        f := info_proc.procedure_flags;
        if f & .IS_ELSEWHERE     append(builder, " #elsewhere");
        if f & .IS_COMPILE_TIME_ONLY  append(builder, " #compiler");
        if f & .IS_C_CALL        append(builder, " #c_call");
        if f & .IS_INTRINSIC     append(builder, " #intrinsic");
    } else if info.type == CODE {  // @redundant with other "code" in here... !
        append(builder, "Code");
    } else if info.type == VARIANT {
        tiv := cast(*Type_Info_Variant) info;
        if tiv.name {
            append(builder, tiv.name);
        } else {
            // It's anonymous; print out something kinda reasonable.
            append(builder, "#type");
            if tiv.variant_flags & .DISTINCT append(builder, ",distinct");
            if tiv.variant_flags & .ISA      append(builder, ",isa");
            append(builder, " ");
            print_type_to_builder(builder, tiv.variant_of);
        }
    } else if info.type == POLYMORPHIC_VARIABLE {
        append(builder, "$");  // "  This is here just temporarily, to un-confuse emacs syntax highlighting. Yay.
    } else if info.type == ANY {
        append(builder, "Any");
    } else {
        element_type := "";

        // Quick hack!
        size := info.runtime_size;
        if info.type == {
          case .INTEGER;
            tii := cast(*Type_Info_Integer) info;
            if size == 1 {
                if tii.signed  element_type = "s8";
                else           element_type = "u8";
            } else if size == 2 {
                if tii.signed  element_type = "s16";
                else           element_type = "u16";
            } else if size == 4 {
                if tii.signed  element_type = "s32";
                else           element_type = "u32";
            } else {
                if tii.signed  element_type = "s64";
                else           element_type = "u64";
            }
          case .FLOAT;
            if info == type_info(float)    element_type = "float";  // We will never print 'float' if this *Type_Info comes from antoher workspace then...
            if info.runtime_size == 4      element_type = "float32";
            else                           element_type = "float64";

          case .BOOL;                      element_type = "bool";
          case .VOID;                      element_type = "void";
        }

        if element_type {
            append(builder, element_type);
        } else {
            append(builder, "(some type)");
        }
    }
}

print_item_to_builder :: (builder: *String_Builder, item: Any, inside_struct_or_array := true, may_be_uninitialized := false) {
    using Type_Info_Tag;

    if !item.value_pointer { // We could get an uninitialized Any from the user, if they are printing a declaration that was already an Any, so that the cast was a no-op.
        append(builder, "(zero-initialized Any)");
        return;
    }

    t := item.type.type;

    if t == {
      case STRING;
        s := get_full_sized_string(item);

        if inside_struct_or_array {
            // Print the string in quotes, escaping any characters.
            // A little slow for now.

            append(builder, "\"");

            for 0..s.count-1 {
                c := s[it];
                if c == 10 {
                    append(builder, "\\n".data, 2);
                } else {
                    append(builder, *c, 1);
                }
            }

            append(builder, "\"");
        } else {
            append(builder, s);
        }

      case BOOL;
        b := << cast(*bool) item.value_pointer;
        if b {
            append(builder, "true");
        } else {
            append(builder, "false");
        }

      case INTEGER;
        default := context.print_style.default_format_int;
        default.value = item;
        print_integer(builder, default);

      case FLOAT;
        default := context.print_style.default_format_float;
        default.value = item;
        print_float(builder, default);

      case POINTER;
        pt := cast(*Type_Info_Pointer)(item.type);

        if pt.pointer_to.type == .STRUCT {
            printer := context.print_style.struct_printer;
            printed := ifx printer then printer(builder, item, context.print_style.struct_printer_data);
            if printed return;
        }

        u64_val := << cast(*u64) item.value_pointer;
        if u64_val {
            default := context.print_style.default_format_absolute_pointer;
            default.value = u64_val;
            print_integer(builder, default);
        } else {
            append(builder, "null");
        }

      case STRUCT;
        info_struct := cast(*Type_Info_Struct) item.type;
        printer := context.print_style.struct_printer;
        printed := ifx printer then printer(builder, item, context.print_style.struct_printer_data);
        if printed return;


        expansion: *Type_Info_Struct_Member;
        if (!inside_struct_or_array) && item.value_pointer  expansion = isFormatter(info_struct);  // The check for item.value_pointer is a safety in case we get passed bad data.

        if expansion {
            expander := cast(*Formatter) item.value_pointer;

            // If it's a silent default-setter, set the new default pointer, then bail.

            if item.type == type_info(FormatInt) {
                format := << cast(*FormatInt) item.value_pointer;

                if check_null_formatter(format, builder) return;

                print_integer(builder, format);
                return;
            } else if item.type == type_info(FormatFloat) {
                format := << cast(*FormatFloat) item.value_pointer;

                if check_null_formatter(format, builder) return;

                print_float(builder, format);
                return;
            } else if item.type == type_info(FormatStruct) {
                format := cast(*FormatStruct) item.value_pointer;

                if check_null_formatter(<<format, builder) return;

                new_info_struct := cast(*Type_Info_Struct) format.value.type;
                value_pointer := format.value.value_pointer;
                if format.value.type.type == POINTER {  // We let people wrap a pointer to a struct, since often that's what you'll have...
                    tip := cast(*Type_Info_Pointer)format.value.type;
                    if tip.pointer_to.type == STRUCT {
                        new_info_struct = cast(*Type_Info_Struct) tip.pointer_to;
                        value_pointer = << cast(**void) format.value.value_pointer;
                    }
                }

                if new_info_struct.type == STRUCT {
                    append_struct_info(builder, new_info_struct, value_pointer, format);
                    return;
                } else {
                    log_error("Attempt to pass a non-struct inside a FormatStruct.\n");
                    append(builder, "error");
                    return;
                }
            } else if item.type == type_info(FormatArray) {
                format := cast(*FormatArray) item.value_pointer;
                new_info := cast(*Type_Info_Array) format.value.type;

                if check_null_formatter(format, builder) return;
                print_array(builder, format.value, new_info, format, may_be_uninitialized);

                return;
            }
        }

        append_struct_info(builder, info_struct, item.value_pointer);

      case ARRAY;
        format := *context.print_style.default_format_array;
        info_array := cast(*Type_Info_Array) item.type;

        print_array(builder, item, info_array, format, may_be_uninitialized);

      case PROCEDURE;
        pv := << cast(**void) item.value_pointer;  // @Hack

        if pv {
            append(builder, "procedure 0x");

            print_item_to_builder(builder, pv);
            // append(builder, ")");
        } else {
            append(builder, "null");
        }

      case VARIANT;
        printer := context.print_style.struct_printer;
        printed := ifx printer then printer(builder, item, context.print_style.struct_printer_data);
        if printed return;

        info_variant := cast(*Type_Info_Variant) item.type;
        variant_item := item;
        variant_item.type = info_variant.variant_of;
        print_item_to_builder(builder, variant_item, inside_struct_or_array, may_be_uninitialized);

      case ENUM;
        // Kind of ugly, but let's go for it.

        info_enum := cast(*Type_Info_Enum) item.type;
        info_int  := cast(*Type_Info_Integer) info_enum.internal_type;
        assert(info_int.type == INTEGER);

        size := info_int.runtime_size;

        if info_enum.enum_type_flags & .FLAGS {
            target_value := get_u64_from_void_pointer(item.value_pointer, size);  // Treat flags as unsigned, even for signed types. Simpler.

            if target_value == 0 {
                append(builder, "0");
                return;
            }

            // I felt like doing this in unsigned for some reason!
            flags_total := target_value;
            flags_printed : u64 = 0;

            first := true;
            for info_enum.values {
                value := cast(u64) it;
                matching := flags_total & value;
                if matching != value  matching = 0;  // We need to match all of the bits in the enum member.

                if !matching continue;
                if !(matching & ~flags_printed) continue;

                flags_printed |= matching;

                if !first  append(builder, " | ");
                append(builder, info_enum.names[it_index]);
                first = false;
            }

            unmatched := flags_total & ~flags_printed;
            if unmatched {
                if !first  append(builder, " | 0x");
                format := FormatInt.{base=16};
                print_u64_base_n(builder, unmatched, format);
            }
        } else {
            assert(info_enum.names.count == info_enum.values.count);

            target_value_s64 := get_s64_from_void_pointer(item.value_pointer, size);
            if info_int.signed {
                for info_enum.values  if target_value_s64 == it {
                    append(builder, info_enum.names[it_index]);
                    return;
                }
            } else {
                target_value_u64 := get_u64_from_void_pointer(item.value_pointer, size);

                for info_enum.values  if target_value_u64 == cast,no_check(u64) it {
                    append(builder, info_enum.names[it_index]);
                    return;
                }
            }

            if target_value_s64 {
                append(builder, "(enum out of range: ");
                // Print an unsigned value if the enum is unsigned,
                // otherwise we allow it to be signed.
                if info_int.signed  print_item_to_builder(builder, target_value_s64);
                else                print_item_to_builder(builder, get_u64_from_void_pointer(item.value_pointer, size));
                append(builder, ")");
            } else {
                print_item_to_builder(builder, target_value_s64);
            }
        }

      case TYPE;
        ti := << cast(**Type_Info) item.value_pointer;

        if ti {
            print_type_to_builder(builder, ti);
        } else {
            append(builder, "(null)");
        }

/*
        append(builder, "(Type, address ");

        default : FormatInt;
        default.base = 16;
        default.value = cast(s64) ti;
        print_integer(builder, default);

        append(builder, ")");
*/
      case VOID;
        append(builder, "void");

      case CODE;
        append(builder, "Code");

      case OVERLOAD_SET;
        append(builder, "(procedure overloads)");

      case ANY;  // We can get here when printing an array or struct of Any.
        if may_be_uninitialized {
            append(builder, "(potentially uninitialized Any)");
        } else {
            new_any := << cast(*Any) item.value_pointer;
            if new_any.type {
                print_item_to_builder(builder, new_any);
            } else {
                if new_any.value_pointer append(builder, "(Any with null 'type' field)");
                else                     append(builder, "(zero-initialized Any)");
            }
        }

      case;
        // This is a type we don't know or don't yet handle.

        append(builder, "(corrupted type tag ");
        print_item_to_builder(builder, cast(int)t);
        append(builder, ")");
    }
}


my_is_digit :: (c: s64) -> bool {
    relative := c - #char "0";
    return (relative >= 0) && (relative <= 9);
}

// @Cleanup: Can use to_integer in Basic.jai now, but would have to
// deal with the cursor situation.
parse_number :: (s: string, cursor: s64) -> (end_cursor: s64, sum: s64) {
    sum := 0;

    while cursor < s.count {
        c := s[cursor];
        if !my_is_digit(c) break;

        sum *= 10;
        sum += cast(int) c - #char "0";

        cursor += 1;
    }

    return cursor, sum;
}

print_to_builder :: (builder : *String_Builder, format_string : string, args: .. Any) -> bool {
    implicit_index_cursor := 0;

    #if USE_SIMD {
        PERCENTS :: "%%%%%%%%%%%%%%%%";
        PercentsData := PERCENTS.data;

        #asm {
            movdqu.x percents:, [PercentsData];
        }
    }

    cursor := 0;
    printed := 0;
    while cursor < format_string.count {
        #if 0 && USE_SIMD {  // Disabled for now, as we don't currently handle character 31 in this loop. Once we do, re-enable.
            // Hardcoded for SSE2 currently, since that has wide support.
            // For other CPUs, etc, we will ... do something!

            // If we have at least SIMD_WIDTH characters in our buffer, use
            // SSE2 to scan that many characters at a time, looking for the
            // first % character.

            // We also do this kind of thing in modules/String, in
            // find_character_from_left*, so, maybe we could just move that stuff
            // into Basic and use it here, inlined.
            if format_string.count - cursor >= SIMD_WIDTH {
                point := format_string.data + cursor;

                mask:    u32 = ---;
                advance: u32;

                #asm {
                    movdqu.x    test:, [point];
                    pcmpeqb.x   test, percents;
                    pmovmskb.x  mask, test;
                    bsf.d       advance, mask;
                }

                if mask {
                    cursor += advance;
                    // Fall through and do the normal handling below.
                    // If we had a goto we could skip past the redundant c != #char, hmm.
                } else {
                    cursor += 16;
                    continue;
                }
            }
        }

        c := format_string.data[cursor];

        if c != #char "%" {
            if c == 31 {
                append(builder, format_string.data + printed, cursor - printed);
                append(builder, "%");
                cursor += 1;
                printed = cursor;
                continue;
            }

            cursor += 1;
            continue;
        }

        append(builder, format_string.data + printed, cursor - printed);
        cursor += 1;  // Skip the %.

        value := implicit_index_cursor; // Will get bumped below.

        if cursor < format_string.count {
            next := format_string.data[cursor];
            if next == #char "%" {  // Double-percent means to actually output a percent.
                append(builder, "%");
                cursor += 1;
                printed = cursor;
                continue;
            }

            if my_is_digit(next) {
                if next == #char "0" {  // %00 outputs the empty string; %0 is like a regular %.
                    cursor += 1;
                    if (cursor < format_string.count) && (format_string.data[cursor] == #char "0") {
                        // Empty string.
                        cursor += 1;
                        printed = cursor;
                        continue;
                    } else {
                        // Fall through and do the thing.
                    }
                } else {
                    // @Robustness: We probably want to test that parse_number does not overflow!
                    cursor, value = parse_number(format_string, cursor);
                    value -= 1;      // Arguments are 0-based indices from here on.
                }
            }
        }


        if value < 0 {
            if context.print_style.log_runtime_errors {
                log_error("Invalid negative %% index % in the format string at character %. Skipping.\n", value, cursor);
            }

            implicit_index_cursor = 0;
            printed = cursor;
            continue;
        }

        if value >= args.count {
            if context.print_style.log_runtime_errors {
                do_free := false;
                arguments_string := "(There are no insertable arguments.)";
                if value == 1 {
                    arguments_string = "(There is only 1 insertable argument.)";
                } else {
                    arguments_string = sprint("(There are only % insertable arguments.)", value);
                    do_free = true;
                }

                log_error("Invalid %% index % in the format string \"%\" at character %. %\n", value+1, format_string, cursor, arguments_string);
                if do_free free(arguments_string);
            }

            implicit_index_cursor = 0;
            printed = cursor;
            continue;
        }

        print_item_to_builder(builder, args[value], false);
        implicit_index_cursor = value + 1;

        printed = cursor;   // Next time we append, start here.
    }

    append(builder, format_string.data + printed, cursor - printed);

    if builder.failed return false;
    return true;
} @PrintLike

print :: print_to_builder;

print_sequence_to_builder :: (builder : *String_Builder, args: .. Any) {
    for args {
        print_item_to_builder(builder, it);
    }
}

isFormatter :: (info: *Type_Info_Struct) -> *Type_Info_Struct_Member {
    for * info.members {
        if it.type == type_info(Formatter) return it;
    }

    return null;
}


print_bytes :: (a: *void, length: int, format_string := "% ") {
    b := cast(*u8) a;
    for 0..length-1 {
        print(format_string, formatInt(b[it], base=16));
    }

    print("\n");
}

print_array :: (builder: *String_Builder, any: Any, info_array: *Type_Info_Array, format: FormatArray, may_be_uninitialized := false) {
    // Figure out count and data.

    count: s64;
    data: *void;
    if info_array.array_type == .FIXED {
        count = info_array.array_count;
        data  = any.value_pointer;
    } else {
        count = << cast(*s64)  (any.value_pointer);
        data  = << cast(**void)(any.value_pointer + 8);
    }

    // Now start printing.

    append(builder, format.begin_string);

    if may_be_uninitialized {
        print_to_builder(builder, "% potentially uninitialized elements", count);
    } else {
        to_print := count;
        limit := format.stop_printing_after_this_many_elements;
        if limit >= 0  to_print = min(to_print, limit);

        etype := info_array.element_type;
        for 0..to_print-1 {
            pointer := data + info_array.element_type.runtime_size * it;
            item: Any = ---;
            item.type = etype;
            item.value_pointer = pointer;

            print_item_to_builder(builder, item);

            if format.draw_separator_after_last_element || (it < to_print-1) {
                append(builder, format.separator);
            }
        }

        if to_print < count  append(builder, format.printing_stopped_early_string);
    }

    append(builder, format.end_string);
}

type_to_string :: (info: *Type_Info) -> string {  // Returns a string in Temporary_Storage.
    // A relatively inefficient way to do this! If you are printing a bunch of stuff
    // into the same builder, you can use print_type_to_builder() instead!

    builder: String_Builder;
    builder.allocator = __temporary_allocator;

    print_type_to_builder(*builder, info);

    return builder_to_string(*builder,, temp);
}

#scope_file

get_full_sized_string :: (any: Any) -> string {
    assert(any.type && (any.type.type == .STRING));
    tis := cast(*Type_Info_String) any.type;

    return << cast(*string) any.value_pointer;
}


check_null_formatter :: (format: Formatter, builder: *String_Builder) -> bool {
    if !format.value.type {
        append(builder, "(null Any)");
        return true;
    }

    return false;
}


my_c_style_strlen :: (x: *u8) -> int {  // @Cleanup: Remove this when we know what is going on.
    p := x;
    while << p  { p += 1; assert(p - x < 2048);}
    return p - x;
}
