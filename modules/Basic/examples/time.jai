main :: () {
    now := current_time_consensus();
    print("Now in Apollo Time: %\n", now);

    calendar_utc := to_calendar(now, .UTC);
    print("Calendar UTC in data structure form: %\n", calendar_utc);

    print("\n");
    
    s := calendar_to_string(calendar_utc);
    print("Date in UTC is:   %\n", s);

    calendar_local := to_calendar(now, .LOCAL);
    s = calendar_to_string(calendar_local);
    print("Date in Local is: %\n", s);

    print("\n");

    #if OS != .WINDOWS {
        print("Unfortunately, since we currently use OS-specific routines to convert to calendar time,\n");
        print("and Linux's time structs do not go far enough into the past, this next call will report an error,\n");
        print("and this is a travesty. We'll fix this before too long.\n");
    }
    
    print("Apollo T plus zero in UTC is %\n", calendar_to_string(to_calendar(.{}, .UTC)));

    print("\n");

    //
    // Let's look at the total range of Apollo_Time, in years.
    //

    // The maximum positive Apollo_Time is just the normal two's complement thing
    // of all bits being 1, except the high bit:
    apollo_max: Apollo_Time;
    apollo_max.high = 0x7fff_ffff_ffff_ffff;  // Maximum positive value.
    apollo_max.low  = 0xffff_ffff_ffff_ffff;

    seconds_per_day  :: 60*60*24;
    seconds_per_year :: seconds_per_day*365 + seconds_per_day/4;

    // Here we are using an overloaded operator / to divide an Apollo_Time by a constant:
    apollo_seconds := apollo_max / 1_000_000_000_000_000;
    print("Apollo max seconds (rounded down): %\n", apollo_seconds);

    apollo_years := apollo_seconds / seconds_per_year;
    assert(apollo_years.high == 0);  // 10**15 * seconds_per_year is a little more than 64 bits, so the result of the divide is less than 64 bits.
    
    years := apollo_years.low;
    print("The maximum representable Apollo_Time is % years in the future (rounded down).\n",
          formatInt(years, comma_string=",", digits_per_comma=3));

    print("\n");
    
    //
    // If the divide operation worked properly, then the remainder of the divide
    // should be less than seconds_per_year. Let's check that.
    //

    // Here we will build a femtoseconds_per_year number. seconds_per_year fits in 64 bits, and
    // FEMTOSECONDS does too (it is the constant value 10**15), but the product does not. So we
    // put one of the terms in the bottom words of an Apollo_Time, then use the overloaded *
    // to multiply in the second term.
    
    femtoseconds_per_year: Apollo_Time;
    femtoseconds_per_year.low  = FEMTOSECONDS;
    femtoseconds_per_year     *= seconds_per_year;

    // Then we multiply this by our number of years, to get the integer number of years
    // that fits into Apollo_Time; this will be somewhat close to apollo_max, but not quite there.
    back := femtoseconds_per_year * cast(s64) years; // This operator is only overloaded for s64 right now.

    FormatApollo :: (a: Apollo_Time) -> string {
        Format :: (x: Any) -> FormatInt {
            return formatInt(x, base=16, digits_per_comma=4, comma_string="_", minimum_digits=16);
        }

        // We are writing it as high then low, as a long hex number.
        // This is different from what you see when you just print the structure,
        // which prints low then high, because low is first in memory.
        return tprint("0x% %", Format(a.high), Format(a.low));  
    }
    
    print("The max Apollo_Time, in hex, is ............................. : %\n", FormatApollo(apollo_max));
    print("When we multiply femtoseconds_per_year by apollo_years, we get: %\n", FormatApollo(back));

    delta := apollo_max - back;
    print("Subtracting these, we get ................................... : %\n", FormatApollo(delta));

    print("This must be less than femtoseconds_per_year, which is ...... : %\n", FormatApollo(femtoseconds_per_year));

    assert(delta < femtoseconds_per_year);
    
    print("\n");


    {
        // Show use of monotonic time, plus conversion to float and back.
        // (You might convert a per-frame dt to float in order to easily do math,
        // because you know the dt is pretty small relative to the age of the Universe.)

        t0 := current_time_monotonic();
        sleep_milliseconds(100);
        t1 := current_time_monotonic();

        dt := t1 - t0;

        dt_float := to_float64_seconds(dt);

        print("dt is % seconds (Apollo format).\n", dt);
        print("dt is % seconds (float64).\n", dt_float);

        // Convert from float back to Apollo. We can see how much
        // precision we lost. For monotonic timers that have a small
        // output range, the answer is possibly none!

        dt_backconverted := to_apollo(dt_float);

        print("dt_backconverted %\n", dt_backconverted);

        print("Difference induced by conversion to float and back: %\n", dt - dt_backconverted);
    }

    // 
    // Let's just do a few random multiplies and divides to test operators:
    //
    delta_t := Apollo_Time.{336, 669};

    divided3    := delta_t / 3;
    multiplied3 := divided3 * 3;

    assert(multiplied3 == delta_t);   // Because the original was a multiple of 3.
    
    divided4    := delta_t / 4;
    multiplied4 := divided4 * 4;

    assert(multiplied4 == delta_t);  // It was also a multiple of 4!
    
    print("delta_t %\n", delta_t);
    print("delta_t %\n", FormatApollo(delta_t));

    print("\n");
    
    print("divided3    %\n", divided3);
    print("multiplied3 %\n", multiplied3);

    print("\n");

    print("divided4    %\n", divided4);
    print("multiplied4 %\n", multiplied4);

    print("\n");

    // Bit shift operations:

    shift_right_2 := delta_t >> 2;
    print("shift_right_2           (should be equal to divided4) %\n", shift_right_2);
    assert(shift_right_2 == divided4);

    shift_left_then_right_2 := (delta_t << 2) >> 2;
    print("shift_left_then_right_2 (should be equal to delta_t)  %\n", shift_left_then_right_2);
    assert(shift_left_then_right_2 == delta_t);

    
    //
    // Multiply and divide by Apollo_Time:
    //

    factor := Apollo_Time.{100, 0};

    // Multiply both ways, just to see:
    product1 := delta_t * factor;
    print("product1 %\n", product1);

    product2 := factor * delta_t;
    print("product2 %\n", product2);

    assert(product1 == product2);
    
    print("\n");

    //
    // Simple dumb divide test, dividing by 1:
    //
    print("Divided by 1: %\n", apollo_max/1);
    assert(apollo_max/1 == apollo_max);
}
    
#import "Basic";
