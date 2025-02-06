to_string :: inline (s: *u8, length: s64) -> string {
    if !s return "";

    result: string = ---;
    result.count = length;
    result.data  = s;
    return result;
}

to_string :: inline (buffer: [] u8) -> string #deprecated "Use cast(string) instead." {
    return to_string(buffer.data, buffer.count);
}

to_string :: inline (buffer: [..] u8) -> string #deprecated "Use cast(string) instead." {
    return to_string(buffer.data, buffer.count);
}


// The following functions:
//
//    to_string :: inline (s: *u8) -> string;
//    c_style_strlen :: (x: *u8) -> s64;
//
// are in Runtime_Support.jai and can be called from anywhere.

// Allocates memory.
to_c_string :: (s: string) -> *u8 {
    result : *u8 = alloc(s.count + 1);
    memcpy(result, s.data, s.count);
    result[s.count] = 0;
    return result;
}


// Note: Right now when code is generated, c + A - a
// doesn't get constexpr evaluation evoked on the A - a
// because it parses into the AST as (c + A) - a, and we
// do not do tree rearrangement for constexpr evaluation.
// (And I am not sure that we should).  -jblow, 25 April 2018.

// Maybe to_upper, to_lower, etc should not even be in Basic...  -jblow

// These are locale indepdent, only support english characters, and do not support utf8.

to_upper :: (c: u8) -> u8 {
    if c >= #char "a" && c <= #char "z" return c + #char "A" - #char "a";
    else return c;
}

to_lower :: (c: u8) -> u8 {
    if (c >= #char "A" && c <= #char "Z") return c + #char "a" - #char "A";
    else return c;
}

is_alpha :: (c: u8) -> bool {
    return (c >= #char "a" && c <= #char "z") || (c >= #char "A" && c <= #char "Z");
}

is_digit :: (c: u8) -> bool {
    return c >= #char "0" && c <= #char "9";
}

is_alnum :: (c: u8) -> bool { // This also includes underscore!
    return is_alpha(c) || is_digit(c) || c == #char "_";
}

is_space :: (c: u8) -> bool {
    return c == #char " " || c == #char "\t" || c == #char "\r" || c == #char "\n";
}

is_print :: (c: u8) -> bool {
    // True for any character from space to tilde (DEL not included).
    return c >= 0x20 && c < 0x7F;
}

advance :: inline (s: *string, amount: s64 = 1) {
    assert(amount >= 0);
    assert(s.count >= amount);
    s.count -= amount;
    s.data  += amount;
}

advance :: inline (s: string, amount: s64 = 1) -> string #must {
    assert(amount >= 0);
    assert(s.count >= amount);

    t: string = ---;
    t.count = s.count - amount;
    t.data  = s.data  + amount;
    return t;
}


temp_c_string :: (s: string) -> *u8 {
    result : *u8 = temporary_alloc(s.count + 1);
    memcpy(result, s.data, s.count);
    result[s.count] = 0;

    return result;
}

copy_temporary_string :: inline (s: string) -> string {
    return copy_string(s,, allocator=__temporary_allocator);
}

copy_string :: (s: string) -> string {
    if !s.count return "";

    copy := alloc_string(s.count);
    memcpy(copy.data, s.data, s.count);
    return copy;
}


/*

@Bug: We want to have string_to_float be parameterized,
but it doesn't quite work consistently for some reason.
In both LLVM and x64, the procedures appear to return
0 sometimes (but not always, depending on what is going on
in the calling procedure).  -jblow, 19 February 2017

Test code:

    f1 := string_to_float("42.6");
    print("f1 is type %, value %\n", type_of(f1), f1);

    f2 := string_to_float64("42.6");
    print("f2 is type %, value %\n", type_of(f2), f2);

    f3 := string_to_float_old("42.6");
    print("f3 is type %, value %\n", type_of(f3), f3);


string_to_float   :: #bake_constants string_to_float_type_T (T = float);
string_to_float64 :: #bake_constants string_to_float_type_T (T = float64);

string_to_float_type_T :: (_arg: string) -> result: $T, success: bool, remainder: string {
    arg := eat_spaces(_arg);

    if !arg {
        return 0, false, arg;
    }

    found_decimal := false;

    // @Temporary:
    // See how much of the string is a digit, +, -, ., or e.
    limit := arg.count;
    for 0..arg.count-1 {
        c := arg[it];
        if (c >= #char "0") && (c <= #char "9") {
            // We are good.
        } else if c == #char "." {
            // We are good.
        } else if (c == #char "-") || (c == #char "+") || (c == #char "e") {
            // We are good.
        } else {
            limit = it;
            break;
        }
    }

    substring := arg;
    substring.count = limit;

    remainder := arg;
    advance(*remainder, limit);

    // @Temporary @Speed @Ugh
    cs := temp_c_string(substring);
    result := cast(T) atof(cs);

    return result, true, remainder;
}

*/


//
// @Cleanup! We would like to just do:
//
//     to_integer :: #bake_arguments string_to_int(base=10);
//
// But this causes dead code elimination to think string_to_int is live,
// even if it's not. So it would be good to come up with a way to make
// this work better! In the meantime...
//
to_integer :: (s: string) -> result: int, success: bool, remainder: string {
    result, success, remainder := string_to_int(s);
    return result, success, remainder;
}

string_to_int :: (t: string, base := 10, $T := int) -> result: T, success: bool, remainder: string {
    //
    // This string_to_int might be a little slower than max speed because we multiply by 'sign' for
    // each digit. Our original approach did not do this, but rather we just accumulated into a
    // positive value and then negated at the end if we saw a -. But this does not let us parse the
    // maximum negative number without overflowing the positive number, which works, *if* you are
    // not doing arithmetic bounds checks. We could have done #no_abc on this procedure, but
    // I decided it's worthwhile to just try to preserve the ability to report genuine overflows,
    // so I did 'the clean version' here.    -jblow, 4 July 2023
    //
    assert(base == 16 || base <= 10);
    
    s := eat_spaces(t);

    if !s return 0, false, "";

    sign : T = 1;
    
    #if #run type_info(T).signed {
        if s[0] == #char "-" {
            sign = -1;
            advance(*s, 1);
            s = eat_spaces(s);
        } else if s[0] == #char "+" {
            advance(*s, 1);
            s = eat_spaces(s);
        }
    }

    sum: T = 0;
    cursor := 0;

    // @Incomplete: We should probably check for overflows…
    if base == 16 {
        while cursor < s.count {
            c := s[cursor];

            value: u8 = ---;
            if is_digit(c) {
                value = c - #char "0";
            } else if (c >= #char "a") && (c <= #char "f") {
                value = c - #char "a" + 10;
            } else if (c >= #char "A") && (c <= #char "F") {
                value = c - #char "A" + 10;
            } else {
                break;
            }

            sum *= cast(T) base;
            sum += sign * cast(T)value;

            cursor += 1;
        }
    } else {
        while cursor < s.count {
            c := s[cursor];
            if !is_digit(c) break;

            digit := c - #char "0";
            if digit >= base break;

            sum *= cast(T) base;
            sum += sign*cast(T)digit;

            cursor += 1;
        }
    }

    success := (cursor != 0);
    advance(*s, cursor);

    return sum, success, s;
}

eat_spaces :: (_s: string) -> string {
    s := _s;
    while s {
        if (s[0] != #char " ") && (s[0] != 9) break;  // 9 is horizontal tab.
        advance(*s, 1);
    }

    return s;
}
