print_int_tests :: () {
    assert(tprint("%", 0) == "0", "0: Plain failed");
    assert(tprint("%", formatInt(0)) == "0", "0: Default failed");
    assert(tprint("%", formatInt(0, minimum_digits = 0)) == "", "0: Explicit 0 failed");
    assert(tprint("%", formatInt(0, minimum_digits = 1)) == "0", "0: Explicit 1 failed");
    assert(tprint("%", formatInt(0, minimum_digits = 3)) == "000", "0: Explicit 3 failed");

    assert(tprint("%", 25) == "25", "25: Plain failed");
    assert(tprint("%", formatInt(25)) == "25", "25: Default failed");
    assert(tprint("%", formatInt(25, minimum_digits = 3)) == "025", "25: Explicit 3 failed");
    assert(tprint("%", formatInt(25, minimum_digits = 1)) == "25", "25: Explicit 1 failed");
    assert(tprint("%", formatInt(25, minimum_digits = 0)) == "25", "25: Explicit 0 failed");

    assert(tprint("%", formatInt(1234, minimum_digits = 0)) == "1234", "1234: Explicit 0 failed");
    assert(tprint("%", formatInt(1234, minimum_digits = 1)) == "1234", "1234: Explicit 1 failed");

} @test

print_int_hex_tests :: () {
    assert(tprint("%", formatInt(25, base = 16)) == "19", "Default failed");
    assert(tprint("%", formatInt(25, base = 16, minimum_digits = 3)) == "019", "3 failed");
    assert(tprint("%", formatInt(25, base = 16, minimum_digits = 1)) == "19", "1 failed");
}

print_float_tests :: () {
    assert(tprint("%", 1234.5) == "1234.5", "Plain failed");
    assert(tprint("%", formatFloat(1234.5)) == "1234.5", "Default failed");
    assert(tprint("%", formatFloat(1234.5, trailing_width = 1)) == "1234.5", "Traling 1 failed");
    assert(tprint("%", formatFloat(1234.5, trailing_width = 4, zero_removal = .NO)) == "1234.5000", "Traling 4 no_removal failed");
    assert(tprint("%", formatFloat(1234.5, trailing_width = 4)) == "1234.5   ", "Traling 4 failed");
    assert(tprint("%", formatFloat(1234.5, mode = .SHORTEST)) == "1234.5", "Shortest 1 failed");
    assert(tprint("%", formatFloat(60.0, mode = .SHORTEST)) == "60", "Shortest 2 failed");
    assert(tprint("%", formatFloat(60.0, mode = .SHORTEST, zero_removal = .NO)) == "60", "Shortest without zero removal failed");
    assert(tprint("%", formatFloat(2.0e-31, mode = .SHORTEST)) == "2e-31", "Shortest scientific failed");
    print("%", formatFloat(60.0, trailing_width=2, mode = .SCIENTIFIC));
    {
        scientific := tprint("%", formatFloat(60.0, mode = .SCIENTIFIC, zero_removal = .NO));
        EXPECTED_SCIENTIFIC :: "6.000000e+01";
        assert(scientific == EXPECTED_SCIENTIFIC, "Scientific w/o zero removal failed: % vs %", scientific, EXPECTED_SCIENTIFIC);
    }
    // @ToDo: This one fails for the old implementation but there’s no point fixing that if we plan to ditch it very soon.
    // Enable this test when we switch to the new implementation.
    //  -rluba, 2023-08-07
    // {
    //     scientific := tprint("%", formatFloat(60.0, mode = .SCIENTIFIC));
    //     EXPECTED_SCIENTIFIC :: "6e+01";
    //     assert(scientific == EXPECTED_SCIENTIFIC, "Scientific with zero removal failed: % vs %", scientific, EXPECTED_SCIENTIFIC);
    // }
    print("%\n", formatFloat(8.314472e0, mode = .SCIENTIFIC));
    print("%\n", formatFloat(8.314472e0, mode = .SCIENTIFIC, zero_removal = .NO));
    assert(tprint("%", formatFloat(8.314472e0, mode = .SCIENTIFIC)) == "8.314472e+00", "Scientific 2 failed");

}

simple_string_tests :: () { // Very simple, to get the ball rolling.
    SIZE :: 15;

    s1 : [SIZE] u8;
    memcpy(s1.data, "Hello, Sailor!".data, SIZE-1);
    s1[SIZE-1] = 0;

    // @todo @abner use temporary_storage too and add is_* tests (but those may be moved out of Basic)

    // @Cleanup: These asserts are awful, wtf.

    assert(c_style_strlen(s1.data) == SIZE-1);
    assert(cast(string)s1 == "Hello, Sailor!\0");
    assert(to_string(s1.data) == "Hello, Sailor!");
    assert(to_string(s1.data, SIZE-1) == "Hello, Sailor!");

    s2 : [..] u8;
    for index : 0..SIZE-2 array_add(*s2, s1[index]); // Inefficient, but uses array_add which is part of Basic so it's good to test.

    assert(cast(string)s2 == "Hello, Sailor!");

    s3 := cast(string) s2;
    s3_c_string := to_c_string(s3);
    defer free(s3_c_string);

    assert(c_style_strlen(s3_c_string) == SIZE-1);
    assert(memcmp(s3_c_string, s3.data, SIZE-1) == 0);

    advance(*s3, 0);
    assert(s3[0] == #char "H", message="s3[0] (%) == #char \"H\"", s3[0]);

    advance(*s3, SIZE-2);
    assert(s3[0] == #char "!", message="s3[0] (%) == #char \"!\"", s3[0]);
}


string_builder_tests :: () { // Very simple, to get the ball rolling.
    builder : String_Builder;

    init_string_builder(*builder);

    assert(get_current_buffer(*builder).count == 0);
    assert(builder_to_string(*builder) == "");
    assert(builder_string_length(*builder) == 0);

    //
    // Append nothing, string literals, and u8s.
    //

    // @todo @abner test string builder's buffer swap strategy; so if we append something bigger than BUFFER_SIZE
    //              we could assert current_buffer is a new address.

    append(*builder, "");

    {
        output := builder_to_string(*builder);
        defer free(output);
        length := builder_string_length(*builder);

        assert(get_current_buffer(*builder).count == 0, message="get_current_buffer(*builder).count (%) == 0", get_current_buffer(*builder).count);
        assert(output == "", message="builder_to_string(*builder) (%) == \"\"", output);
        assert(length == 0, message="builder_string_length(*builder) (%) == 0", length);
    }

    append(*builder, "Hello");

    {
        output := builder_to_string(*builder, do_reset=false);
        defer free(output);
        length := builder_string_length(*builder);

        assert(output == "Hello", message="builder_to_string(*builder) (\"%\") == \"%\"", builder_to_string(*builder, do_reset=false), "Hello");
        assert(length == 5, message="builder_string_length(*builder) (%) == %", length, 5);
        assert(get_current_buffer(*builder).count == length, message="get_current_buffer(*builder).count (%) == %", get_current_buffer(*builder).count, length);
    }

    append(*builder, ", ");

    {
        output := builder_to_string(*builder, do_reset=false);
        defer free(output);
        length := builder_string_length(*builder);

        assert(output == "Hello, ", message="builder_to_string(*builder) (\"%\") == \"%\"", output, "Hello, ");
        assert(length == 7, message="builder_string_length(*builder) (%) == %", length, 7);
        assert(get_current_buffer(*builder).count == length, message="get_current_buffer(*builder).count (%) == %", get_current_buffer(*builder).count, length);
    }

    append(*builder, "Sailor!");

    {
        output := builder_to_string(*builder, do_reset=false);
        defer free(output);
        length := builder_string_length(*builder);

        assert(output == "Hello, Sailor!", message="builder_to_string(*builder) (\"%\") == \"%\"", output, "Hello, Sailor!");
        assert(length == 14, message="builder_string_length(*builder) (%) == %", length, 14);
        assert(get_current_buffer(*builder).count == 14, message="get_current_buffer(*builder).count (%) == %", get_current_buffer(*builder).count, 14);
    }

    SIZE :: 13;
    goodbye : [SIZE] u8;
    memcpy(goodbye.data, " Goodbye now.".data, SIZE);
    append(*builder, goodbye.data, SIZE);

    {
        output := builder_to_string(*builder, do_reset=false);
        defer free(output);
        length := builder_string_length(*builder);

        assert(output == "Hello, Sailor! Goodbye now.", message="builder_to_string(*builder) (\"%\") == \"%\"", output, "Hello, Sailor! Goodbye now.");
        assert(length == 14+SIZE, message="builder_string_length(*builder) (%) == %", length, 14+SIZE);
        assert(get_current_buffer(*builder).count == 14+SIZE, message="get_current_buffer(*builder).count (%) == %", get_current_buffer(*builder).count, 14+SIZE);
    }

    //
    // Reset
    //

    reset(*builder);

    {
        output := builder_to_string(*builder);
        defer free(output);
        length := builder_string_length(*builder);

        assert(get_current_buffer(*builder).count == 0, message="get_current_buffer(*builder).count (%) == 0", get_current_buffer(*builder).count);
        assert(output == "", message="builder_to_string(*builder) (%) == \"\"", output);
        assert(length == 0, message="builder_string_length(*builder) (%) == 0", length);
    }

    // Stealing
    {
        victim: String_Builder;
        thief: String_Builder;

        append(*victim, "First line\n");
        old_victim_count := builder_string_length(*victim);

        append_and_steal_buffers(*thief, *victim);
        log("Result after heist #1: %", builder_to_string(*thief, do_reset = false));

        thief_count := builder_string_length(*thief);
        assert(thief_count == old_victim_count);
        assert(builder_string_length(*victim) == 0);

        // The first one only copied from the base buffer.
        // Let’s try actual stealing:
        old_thief_count := thief_count;
        for 1..100 {
            print_to_builder(*victim, "This will be stolen next and we want multiple buffers, part %\n", it);
        }
        old_victim_count = builder_string_length(*victim);

        append_and_steal_buffers(*thief, *victim);
        log("\n\nResult after heist #2: %", builder_to_string(*thief, do_reset = false));

        thief_count = builder_string_length(*thief);
        assert(thief_count == old_victim_count + old_thief_count);
        assert(builder_string_length(*victim) == 0);

        // Make sure that we can append normally after stealing from victim a bunch:
        old_thief_count = thief_count;
        INTERMISSION :: "Appended between heist jobs\n";
        print_to_builder(*thief, INTERMISSION);
        log("\n\nResult after intermission: %", builder_to_string(*thief, do_reset = false));
        thief_count = builder_string_length(*thief);
        assert(thief_count == old_thief_count + INTERMISSION.count);

        // Try stealing some more now that thief also has multiple buffers:
        old_thief_count = thief_count;
        for 1..100 {
            print_to_builder(*victim, "This will be stolen again and we want to make sure we have multiple buffers, part %\n", it);
        }
        old_victim_count = builder_string_length(*victim);

        append_and_steal_buffers(*thief, *victim);
        log("\n\nResult after heist #3: %", builder_to_string(*thief, do_reset = false));

        thief_count = builder_string_length(*thief);
        assert(thief_count == old_victim_count + old_thief_count);
        assert(builder_string_length(*victim) == 0);
    }
} @test

copy_string_builder_tests :: () {
    {
        builder := create_builder("What", "we", "expected", init = false);
        print("Builder %, outer current buffer: %\n", *builder, builder.current_buffer);

        stuff := do_other_stack_stuff();
        assert(stuff[0] == 0); // Just so the optimizer doesn't get rid of it
        assert(stuff[1023] == 255); // Just so the optimizer doesn't get rid of it

        output := builder_to_string(*builder);
        print("Outer output: %\n", output);
        assert(output == "What we expected");
    }
    {
        builder := create_builder("What", "we", "expected", init = true);
        print("Builder %, outer current buffer: %\n", *builder, builder.current_buffer);

        stuff := do_other_stack_stuff();
        assert(stuff[0] == 0); // Just so the optimizer doesn't get rid of it
        assert(stuff[1023] == 255); // Just so the optimizer doesn't get rid of it

        output := builder_to_string(*builder);
        print("Outer output: %\n", output);
        assert(output == "What we expected");
    }
    print("OK\n");
}


apollo_time_tests :: () {
    #if OS != .WINDOWS {
        unix_epoch_start := timespec_to_apollo(.{0, 0});
        ct := to_calendar(unix_epoch_start, .UTC);
        log("Unix epoch start: %", ct);

        assert(ct.year == 1970);
        assert(ct.month_starting_at_0 == 0);
        assert(ct.day_of_month_starting_at_0 == 0);
        assert(ct.day_of_week_starting_at_0 == 4);
        assert(ct.hour == 0);
        assert(ct.minute == 0);
        assert(ct.second == 0);
        assert(ct.millisecond == 0);
        assert(ct.time_zone == .UTC);
    }

    {
        ct: Calendar_Time;
        ct.year = 2022;
        ct.month_starting_at_0 = 3;
        ct.day_of_month_starting_at_0 = 5;
        ct.hour = 16;
        ct.minute = 26;
        ct.second = 30;
        ct.millisecond = 500;
        ct.time_zone = .LOCAL;

        apollo_time := calendar_to_apollo(ct);
        ct_roundtrip := to_calendar(apollo_time, ct.time_zone);
        log("Calendar to Apollo to Calendar roundtrip for %: %", ct, ct_roundtrip);

        assert(ct_roundtrip.year == 2022);
        assert(ct_roundtrip.month_starting_at_0 == 3);
        assert(ct_roundtrip.day_of_month_starting_at_0 == 5);
        assert(ct_roundtrip.hour == 16);
        assert(ct_roundtrip.minute == 26);
        assert(ct_roundtrip.second == 30);
        assert(ct_roundtrip.millisecond == 500);
        assert(ct_roundtrip.time_zone == .LOCAL);
    }
    {
        ct: Calendar_Time;
        ct.year = 2022;
        ct.month_starting_at_0 = 3;
        ct.day_of_month_starting_at_0 = 5;
        ct.hour = 16;
        ct.minute = 26;
        ct.second = 30;
        ct.millisecond = 500;
        ct.time_zone = .UTC;

        apollo_time := calendar_to_apollo(ct);
        ct_roundtrip := to_calendar(apollo_time, ct.time_zone);
        log("Calendar to Apollo to Calendar roundtrip for %: %", ct, ct_roundtrip);

        assert(ct_roundtrip.year == 2022);
        assert(ct_roundtrip.month_starting_at_0 == 3);
        assert(ct_roundtrip.day_of_month_starting_at_0 == 5);
        assert(ct_roundtrip.hour == 16);
        assert(ct_roundtrip.minute == 26);
        assert(ct_roundtrip.second == 30);
        assert(ct_roundtrip.millisecond == 500);
        assert(ct_roundtrip.time_zone == .UTC);
    }
} @test

create_builder :: (strings: .. string, init: bool) -> String_Builder {
    builder: String_Builder;
    if init     init_string_builder(*builder);

    for strings {
        if it_index {
            append(*builder, " ");
        }
        append(*builder, it);
    }

    print("Current buffer: %\n", builder.current_buffer);
    output := builder_to_string(*builder, do_reset=false);
    print("Inner output: %\n", output);
    return builder;
}

do_other_stack_stuff :: () -> [1024] u8 {
    my_array: [1024] u8;
    for 0..my_array.count - 1 {
        my_array[it] = xx (it % 256);
    }

    return my_array;
}

parse_int_tests :: () {
    result_10 := string_to_int("105", 10, u8);
    assert(result_10 == 105);
    result_16 := string_to_int("105", 16, u16);
    assert(result_16 == 0x105);
    result_8 := string_to_int("105", 8, u8);
    assert(result_8 == 69);
    result_2 := string_to_int("101", 2, u8);
    assert(result_2 == 0b101);
}

parse_float_tests :: () {
    // Check that parsing denormalized float values is fine. This is the minimum positive subnormal value:
    parsed_value, success, remainder := string_to_float64("4.9406564584124654e-324");
    print("Result: % % %", parsed_value, success, remainder);
    assert(success == true);
    assert(parsed_value == 0h0000_0000_0000_0001, "Unexpected parsed value: 0h%", formatInt(<<(cast(*u64) *parsed_value), base=16, minimum_digits = 16, digits_per_comma = 4, comma_string = "_"));
}


test_single_apollo_time_conversion :: (time: Apollo_Time, factor: u64, $round: bool, expected_result: s64, expected_success: bool) -> fail: int {
    to_string :: (x: S128) -> string {
        chars: [39] u8;
        count := 0;
        n := x;
        while n != .{} {
            n=, digit := signed_divide_with_remainder(n, .{10, 0});
            if digit == S128_ERROR  return "<overflow>";
            chars[count] = cast,trunc(u8)(digit.low) + #char "0";
            count += 1;
        }
        builder: String_Builder;
        if x < .{}  append(*builder, "-");
        for < count - 1 .. 0  append(*builder, chars[it]);
        return builder_to_string(*builder);
    }

    result, success := ConvertFromApollo(time, factor, round);
    error := false;
    if success {
        print("% % / % = % ", ifx round then "^" else " ", to_string(time), factor, result);
        if expected_success  error = expected_result != result;
        else                 error = true;
    } else {
        print("% % / % = % ", ifx round then "^" else " ", to_string(time), factor, "<OVERFLOW>");
        error = expected_success;
    }
    if error  print_color("FAIL\n", color = .RED);
    else      print_color("OK\n", color = .GREEN);

    return ifx error then 1 else 0;
}

test_apollo_time_conversion :: () {
    test :: (time: Apollo_Time, factor: u64, expected_result: s64) -> fail: int {
        return test_single_apollo_time_conversion(time, factor, false, expected_result, true);
    }

    test_round :: (time: Apollo_Time, factor: u64, expected_result: s64) -> fail: int {
        return test_single_apollo_time_conversion(time, factor, true, expected_result, true);
    }

    test :: (time: Apollo_Time, factor: u64, expected_success: bool) -> fail: int {
        return test_single_apollo_time_conversion(time, factor, false, 0, expected_success);
    }

    test_round :: (time: Apollo_Time, factor: u64, expected_success: bool) -> fail: int {
        return test_single_apollo_time_conversion(time, factor, true, 0, expected_success);
    }

    fails := 0;
    print("\nApollo Time Conversion:\n\n");

    // expected values ascertained from wolfram alpha

    plus_one := Apollo_Time.{low = 1, high = 0};
    fails += test(plus_one, 1, 1);
    fails += test(plus_one, 2, 0);
    fails += test(plus_one, 3, 0);
    fails += test(plus_one, 4, 0);
    fails += test(plus_one, 5, 0);
    fails += test(plus_one, xx S64_MAX, 0);
    fails += test(plus_one, 0x80000000_00000000, 0);
    fails += test(plus_one, U64_MAX, 0);
    print("\n");
    fails += test_round(plus_one, 1, 1);
    fails += test_round(plus_one, 2, 1);
    fails += test_round(plus_one, 3, 0);
    fails += test_round(plus_one, 4, 0);
    fails += test_round(plus_one, 5, 0);
    fails += test_round(plus_one, xx S64_MAX, 0);
    fails += test_round(plus_one, 0x80000000_00000000, 0);
    fails += test_round(plus_one, U64_MAX, 0);
    print("\n");

    fails += test(-plus_one, 1, -1);
    fails += test(-plus_one, 2, 0);
    fails += test(-plus_one, 3, 0);
    fails += test(-plus_one, 4, 0);
    fails += test(-plus_one, 5, 0);
    fails += test(-plus_one, xx S64_MAX, 0);
    fails += test(-plus_one, 0x80000000_00000000, 0);
    fails += test(-plus_one, U64_MAX, 0);
    print("\n");
    fails += test_round(-plus_one, 1, -1);
    fails += test_round(-plus_one, 2, 0);
    fails += test_round(-plus_one, 3, 0);
    fails += test_round(-plus_one, 4, 0);
    fails += test_round(-plus_one, 5, 0);
    fails += test_round(-plus_one, xx S64_MAX, 0);
    fails += test_round(-plus_one, 0x80000000_00000000, 0);
    fails += test_round(-plus_one, U64_MAX, 0);
    print("\n");

    plus_two := Apollo_Time.{low = 2, high = 0};
    fails += test(plus_two, 1, 2);
    fails += test(plus_two, 2, 1);
    fails += test(plus_two, 3, 0);
    fails += test(plus_two, 4, 0);
    fails += test(plus_two, 5, 0);
    fails += test(plus_two, xx S64_MAX, 0);
    fails += test(plus_two, 0x80000000_00000000, 0);
    fails += test(plus_two, U64_MAX, 0);
    print("\n");
    fails += test_round(plus_two, 1, 2);
    fails += test_round(plus_two, 2, 1);
    fails += test_round(plus_two, 3, 1);
    fails += test_round(plus_two, 4, 1);
    fails += test_round(plus_two, 5, 0);
    fails += test_round(plus_two, xx S64_MAX, 0);
    fails += test_round(plus_two, 0x80000000_00000000, 0);
    fails += test_round(plus_two, U64_MAX, 0);
    print("\n");

    fails += test(-plus_two, 1, -2);
    fails += test(-plus_two, 2, -1);
    fails += test(-plus_two, 3, 0);
    fails += test(-plus_two, 4, 0);
    fails += test(-plus_two, 5, 0);
    fails += test(-plus_two, xx S64_MAX, 0);
    fails += test(-plus_two, 0x80000000_00000000, 0);
    fails += test(-plus_two, U64_MAX, 0);
    print("\n");
    fails += test_round(-plus_two, 1, -2);
    fails += test_round(-plus_two, 2, -1);
    fails += test_round(-plus_two, 3, -1);
    fails += test_round(-plus_two, 4, 0);
    fails += test_round(-plus_two, 5, 0);
    fails += test_round(-plus_two, xx S64_MAX, 0);
    fails += test_round(-plus_two, 0x80000000_00000000, 0);
    fails += test_round(-plus_two, U64_MAX, 0);
    print("\n");


    // 9223372036854775807
    s64_max := Apollo_Time.{low = xx S64_MAX, high = 0};
    fails += test(s64_max, 1, 9223372036854775807);
    fails += test(s64_max, 2, 4611686018427387903);
    fails += test(s64_max, 3, 3074457345618258602);
    fails += test(s64_max, 4, 2305843009213693951);
    fails += test(s64_max, 5, 1844674407370955161);
    fails += test(s64_max, xx S64_MAX, 1);
    fails += test(s64_max, 0x80000000_00000000, 0);
    fails += test(s64_max, U64_MAX, 0);
    print("\n");
    fails += test_round(s64_max, 1, 9223372036854775807);
    fails += test_round(s64_max, 2, 4611686018427387904);
    fails += test_round(s64_max, 3, 3074457345618258602);
    fails += test_round(s64_max, 4, 2305843009213693952);
    fails += test_round(s64_max, 5, 1844674407370955161);
    fails += test_round(s64_max, xx S64_MAX, 1);
    fails += test_round(s64_max, 0x80000000_00000000, 1);
    fails += test_round(s64_max, U64_MAX, 0);
    print("\n");

    // -9223372036854775807
    fails += test(-s64_max, 1, -9223372036854775807);
    fails += test(-s64_max, 2, -4611686018427387903);
    fails += test(-s64_max, 3, -3074457345618258602);
    fails += test(-s64_max, 4, -2305843009213693951);
    fails += test(-s64_max, 5, -1844674407370955161);
    fails += test(-s64_max, xx S64_MAX, -1);
    fails += test(-s64_max, 0x80000000_00000000, 0);
    fails += test(-s64_max, U64_MAX, 0);
    print("\n");
    fails += test_round(-s64_max, 1, -9223372036854775807);
    fails += test_round(-s64_max, 2, -4611686018427387903);
    fails += test_round(-s64_max, 3, -3074457345618258602);
    fails += test_round(-s64_max, 4, -2305843009213693952);
    fails += test_round(-s64_max, 5, -1844674407370955161);
    fails += test_round(-s64_max, xx S64_MAX, -1);
    fails += test_round(-s64_max, 0x80000000_00000000, -1);
    fails += test_round(-s64_max, U64_MAX, 0);
    print("\n");

    // 9223372036854775808
    s64_max_plus_one := s64_max + .{1, 0};
    fails += test(s64_max_plus_one, 1, false);
    fails += test(s64_max_plus_one, 2, 4611686018427387904);
    fails += test(s64_max_plus_one, 3, 3074457345618258602);
    fails += test(s64_max_plus_one, 4, 2305843009213693952);
    fails += test(s64_max_plus_one, 5, 1844674407370955161);
    fails += test(s64_max_plus_one, xx S64_MAX, 1);
    fails += test(s64_max_plus_one, 0x80000000_00000000, 1);
    fails += test(s64_max_plus_one, U64_MAX, 0);
    print("\n");
    fails += test_round(s64_max_plus_one, 1, false);
    fails += test_round(s64_max_plus_one, 2, 4611686018427387904);
    fails += test_round(s64_max_plus_one, 3, 3074457345618258603);
    fails += test_round(s64_max_plus_one, 4, 2305843009213693952);
    fails += test_round(s64_max_plus_one, 5, 1844674407370955162);
    fails += test_round(s64_max_plus_one, xx S64_MAX, 1);
    fails += test_round(s64_max_plus_one, 0x80000000_00000000, 1);
    fails += test_round(s64_max_plus_one, U64_MAX, 1);
    print("\n");

    // -9223372036854775808
    fails += test(-s64_max_plus_one, 1, -9223372036854775808);
    fails += test(-s64_max_plus_one, 2, -4611686018427387904);
    fails += test(-s64_max_plus_one, 3, -3074457345618258602);
    fails += test(-s64_max_plus_one, 4, -2305843009213693952);
    fails += test(-s64_max_plus_one, 5, -1844674407370955161);
    fails += test(-s64_max_plus_one, xx S64_MAX, -1);
    fails += test(-s64_max_plus_one, 0x80000000_00000000, -1);
    fails += test(-s64_max_plus_one, U64_MAX, 0);
    print("\n");
    fails += test_round(-s64_max_plus_one, 1, -9223372036854775808);
    fails += test_round(-s64_max_plus_one, 2, -4611686018427387904);
    fails += test_round(-s64_max_plus_one, 3, -3074457345618258603);
    fails += test_round(-s64_max_plus_one, 4, -2305843009213693952);
    fails += test_round(-s64_max_plus_one, 5, -1844674407370955162);
    fails += test_round(-s64_max_plus_one, xx S64_MAX, -1);
    fails += test_round(-s64_max_plus_one, 0x80000000_00000000, -1);
    fails += test_round(-s64_max_plus_one, U64_MAX, -1);
    print("\n");


    // 18446744073709551615
    u64_max := Apollo_Time.{low = U64_MAX, high = 0};
    fails += test(u64_max, 1, false);
    fails += test(u64_max, 2, 9223372036854775807);
    fails += test(u64_max, 3, 6148914691236517205);
    fails += test(u64_max, 4, 4611686018427387903);
    fails += test(u64_max, 5, 3689348814741910323);
    fails += test(u64_max, xx S64_MAX, 2);
    fails += test(u64_max, 0x80000000_00000000, 1);
    fails += test(u64_max, U64_MAX, 1);
    print("\n");
    fails += test_round(u64_max, 1, false);
    fails += test_round(u64_max, 2, false);
    fails += test_round(u64_max, 3, 6148914691236517205);
    fails += test_round(u64_max, 4, 4611686018427387904);
    fails += test_round(u64_max, 5, 3689348814741910323);
    fails += test_round(u64_max, xx S64_MAX, 2);
    fails += test_round(u64_max, 0x80000000_00000000, 2);
    fails += test_round(u64_max, U64_MAX, 1);
    print("\n");

    // -18446744073709551615
    fails += test(-u64_max, 1, false);
    fails += test(-u64_max, 2, -9223372036854775807);
    fails += test(-u64_max, 3, -6148914691236517205);
    fails += test(-u64_max, 4, -4611686018427387903);
    fails += test(-u64_max, 5, -3689348814741910323);
    fails += test(-u64_max, xx S64_MAX, -2);
    fails += test(-u64_max, 0x80000000_00000000, -1);
    fails += test(-u64_max, U64_MAX, -1);
    print("\n");
    fails += test_round(-u64_max, 1, false);
    fails += test_round(-u64_max, 2, -9223372036854775807);
    fails += test_round(-u64_max, 3, -6148914691236517205);
    fails += test_round(-u64_max, 4, -4611686018427387904);
    fails += test_round(-u64_max, 5, -3689348814741910323);
    fails += test_round(-u64_max, xx S64_MAX, -2);
    fails += test_round(-u64_max, 0x80000000_00000000, -2);
    fails += test_round(-u64_max, U64_MAX, -1);
    print("\n");

    // 36893488147419103230
    double_u64_max := u64_max * .{2, 0};
    fails += test(double_u64_max, 1, false);
    fails += test(double_u64_max, 2, false);
    fails += test(double_u64_max, 3, false);
    fails += test(double_u64_max, 4, 9223372036854775807);
    fails += test(double_u64_max, 5, 7378697629483820646);
    fails += test(double_u64_max, xx S64_MAX, 4);
    fails += test(double_u64_max, 0x80000000_00000000, 3);
    fails += test(double_u64_max, U64_MAX, 2);
    print("\n");
    fails += test_round(double_u64_max, 1, false);
    fails += test_round(double_u64_max, 2, false);
    fails += test_round(double_u64_max, 3, false);
    fails += test_round(double_u64_max, 4, false);
    fails += test_round(double_u64_max, 5, 7378697629483820646);
    fails += test_round(double_u64_max, xx S64_MAX, 4);
    fails += test_round(double_u64_max, 0x80000000_00000000, 4);
    fails += test_round(double_u64_max, U64_MAX, 2);
    print("\n");

    // -36893488147419103230
    fails += test(-double_u64_max, 1, false);
    fails += test(-double_u64_max, 2, false);
    fails += test(-double_u64_max, 3, false);
    fails += test(-double_u64_max, 4, -9223372036854775807);
    fails += test(-double_u64_max, 5, -7378697629483820646);
    fails += test(-double_u64_max, xx S64_MAX, -4);
    fails += test(-double_u64_max, 0x80000000_00000000, -3);
    fails += test(-double_u64_max, U64_MAX, -2);
    print("\n");
    fails += test_round(-double_u64_max, 1, false);
    fails += test_round(-double_u64_max, 2, false);
    fails += test_round(-double_u64_max, 3, false);
    fails += test_round(-double_u64_max, 4, -9223372036854775807);
    fails += test_round(-double_u64_max, 5, -7378697629483820646);
    fails += test_round(-double_u64_max, xx S64_MAX, -4);
    fails += test_round(-double_u64_max, 0x80000000_00000000, -4);
    fails += test_round(-double_u64_max, U64_MAX, -2);
    print("\n");

    if fails  print("% FAILED TESTS!\n", fails);
    else      print("ALL TESTS PASSED\n");
}

#import "Basic";
#import "Math";
#import "Print_Color";
#import "Random";

main :: () {
    print_int_tests();
    print_float_tests();
    simple_string_tests();
    string_builder_tests();
    apollo_time_tests();

    parse_int_tests();
    parse_float_tests();

    seed := random_get();
    print("\n\nRandom seed: %\n", seed);
    random_seed(seed);
    #if CPU == .X64 {
        test_unsigned_division(10000, random_get);
    }
    test_apollo_time_conversion();
}

// @ToDo @Fixme: parse_float_tests() fails when running at compile time, so there is something very sus going on…
// #run main();
