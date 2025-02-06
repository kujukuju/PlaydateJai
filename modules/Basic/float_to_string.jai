// This file contains a port of the floating-point printing functionality in stb_sprintf; the original code has been
// significantly refactored to support this single use case.

stb_print_float :: (builder: *String_Builder, format: FormatFloat) -> int {
    copy_repeated_character :: (destination: *u8, count: int, $character: u8) {
        c :: cast,no_check(u32) character;
        characters_wide : u32 : (c << 24) | (c << 16) | (c << 8) | c;

        i := count;
        d := destination;
        while i {
            if ((cast,no_check(u64) d) & 3) == 0  break;
            d.* = character;
            d += 1;
            i -= 1;
        }
        
        while i >= 4 {
            (cast(*u32) d).* = characters_wide;
            d += 4;
            i -= 4;
        }
        
        while i {
            d.* = character;
            d += 1;
            i -= 1;
        }
    }

    copy_integer_part :: (count: int, s: *u8) -> (n: int, s: *u8) #expand {
        n := 0;
        if use_thousand_separators {
            while n < count {
                cs += 1;
                if cs > thousand_group_size {
                    cs = 0;
                    s.* = thousand_separator_character;
                    s += 1;
                } else {
                    s.* = (sn + n).*;
                    s += 1;
                    n += 1;
                }
            }
        } else {
            while n < count {
                s.* = (sn + n).*;
                s += 1;
                n += 1;
            }
        }

        return n, s;
    }

    determine_mode_for_shortest :: () -> FormatFloat.Mode #expand {
        // clamp the precision and delete extra zeros after clamp
        n = pr;
        if l > pr  l = pr;

        while l > 1 && pr && sn[l - 1] == #char "0" {
            pr -= 1;
            l -= 1;
        }

        if dp <= -4 || dp > n {
            if      pr > l  pr = l - 1;
            else if pr      pr -= 1; // when using %e, there is one digit before the decimal
            return .SCIENTIFIC;
        } else {
            // this is the insane action to get the pr to match %g sematics for %f
            if dp > 0  pr =       ifx dp < l then l - dp else 0;
            else       pr = -dp + ifx pr > l then l      else pr;
            return .DECIMAL;
        }
    }

    num: [512] u8;    // Big enough for e308 (with thousand separators) or e-307.
    exponent: [8] u8; // Stores the exponent string at index 1 and the length of the string at index 0.
    fw, pr, tz, dp, l, n, cs: int;
    s, sn: *u8;

    total_string_length: int;
    trailing_zeroes_in_string: int;
    decimal_digits_in_string: int;

    // @Cleanup: We can just 'using' format here:
    decimal_separator_character  := format.decimal_separator_character;
    thousand_separator_character := format.thousand_separator_character;
    exponent_character           := format.exponent_character;
    use_thousand_separators      := format.thousand_separators;
    mode_to_use                  := format.mode;

    // @Note: These features aren't available through FormatFloat yet.
    use_left_justification :: false;
    left_pad_with_zeroes   :: false;

    fw = format.width;
    pr = format.trailing_width;
    if pr < 0  pr = default_precision;

    any := format.value;
    assert(any.type != null);
    type := any.type;

    while type.type == .VARIANT {
        variant := cast(*Type_Info_Variant) type;
        type = variant.variant_of;
    }

    assert(type.type == .FLOAT);
    info := cast(*Type_Info_Float) type;

    float_value: float64;
    if info.runtime_size == 8 {
        float_value = << cast(*float64) format.value.value_pointer;
    } else {
        float_value = << cast(*float32) format.value.value_pointer;
    }

    pr_flag, pr_bias: u32;
    if mode_to_use == {
        case .SHORTEST;
            if pr == 0   pr = 1;
            pr_bias = 1;
            pr_flag = 0x80000000;
        case .SCIENTIFIC;  pr_flag = 0x80000000;
    }

    is_negative := stbsp__real_to_str(*sn, *l, num.data, *dp, float_value, (cast,no_check(u32)pr - pr_bias) | pr_flag);

    prefix_character: u8;
    if is_negative {
        prefix_character = #char "-";
    } else if format.positive_number_prefix == {
        case .SPACE; prefix_character = #char " ";
        case .PLUS;  prefix_character = #char "+";
    }

    if dp == INFINITY_OR_NAN {
        s = sn; cs = 0; pr = 0;
    } else {
        if mode_to_use == .SHORTEST  mode_to_use = determine_mode_for_shortest();

        if mode_to_use == .DECIMAL {
            //
            // Decimal float.
            //
            s_start := num.data + 64;
            s = s_start;

            // handle the three decimal varieties
            if dp <= 0 { // handle 0.000*000xxxx
                s.* = #char "0"; s += 1;
                if pr { s.* = decimal_separator_character; s += 1; }

                first_trailing_zero_in_string := s;

                n = -dp;
                if n > pr  n = pr;

                copy_repeated_character(s, n, #char "0"); s += n;

                if l + n > pr  l = pr - n;

                decimal_digits_in_string = n + l;

                for 1..l {
                    s.* = sn.*;
                    if sn.* != #char "0"  first_trailing_zero_in_string = s + 1;
                    s += 1; sn += 1;
                }

                tz = pr - (n + l);
                cs = 1 + (thousand_group_size << 24); // how many tens did we write (for commas below)
                trailing_zeroes_in_string = s - first_trailing_zero_in_string;
            } else {
                cs = ifx use_thousand_separators then (600 - dp) % thousand_group_size else 0;

                if dp >= l { // handle xxxx000*000.0
                    n, s = inline copy_integer_part(l, s);

                    if n < dp { // Copy the remaining zeroes of the integer part.
                        n = dp - n;

                        if !use_thousand_separators {
                            copy_repeated_character(s, n, #char "0"); s += n;
                        } else {
                            while n {
                                cs += 1;
                                if cs > thousand_group_size {
                                    cs = 0;
                                    s.* = thousand_separator_character; s += 1;
                                } else {
                                    s.* = #char "0"; s += 1;
                                    n -= 1;
                                }
                            }
                        }
                    }

                    cs = (s - s_start) + (thousand_group_size << 24); // cs is how many tens

                    if pr {
                        s.* = decimal_separator_character; s += 1;
                        tz = pr;
                    }
                } else { // handle xxxxx.xxxx000*000
                    n, s = inline copy_integer_part(dp, s);

                    cs = (s - s_start) + (thousand_group_size << 24); // cs is how many tens

                    if pr { s.* = decimal_separator_character; s += 1; }

                    if l - dp > pr  l = pr + dp;

                    decimal_digits_in_string = l - n;
                    first_trailing_zero_in_string := s;

                    sn = sn + n;
                    n = l - n;

                    for 1..n {
                        s.* = sn.*;
                        if sn.* != #char "0"  first_trailing_zero_in_string = s + 1;
                        s += 1; sn += 1;
                    }

                    tz = pr - (l - dp);
                    trailing_zeroes_in_string = s - first_trailing_zero_in_string;
                }
            }

            pr = 0;
            l = s - s_start; // get the length that we copied
            s = s_start;
        } else {
            //
            // Scientific float.
            //
            s_start := num.data + 64;
            s = s_start;

            // handle leading chars
            s.* = sn.*; s += 1;

            if pr { s.* = decimal_separator_character; s += 1; }

            // handle after decimal
            if (l - 1) > pr  l = pr + 1;

            decimal_digits_in_string = l - 1;
            first_trailing_zero_in_string := s;

            n = 1;
            while n < l {
                s.* = (sn + n).*;
                if s.* != #char "0"  first_trailing_zero_in_string = s + 1;
                s += 1; n += 1;
            }

            trailing_zeroes_in_string = s - first_trailing_zero_in_string;

            // trailing zeros
            tz = pr - (l - 1);
            pr = 0;

            // dump expo
            exponent[1] = exponent_character;
            dp -= 1;
            if dp < 0 {
                exponent[2] = #char "-";
                dp = -dp;
            } else {
                exponent[2] = #char "+";
            }
            
            n = ifx dp >= 100 then 5 else 4;
            exponent[0] = cast,no_check(u8)n;
            while true {
                exponent[n] = cast,no_check(u8)(#char "0" + (dp % 10));
                if n <= 3  break;
                n -= 1;
                dp /= 10;
            }
            
            cs = 1 + (thousand_group_size << 24); // how many tens

            l = s - s_start; // get the length that we copied
            s = s_start;
        }
    }


    //
    // This used to be finalize_string():
    //
    
    append_repeated_character :: (builder: *String_Builder, count: int, $character: u8) -> int {
        result := count;
        
        while count {
            available_range := ensure_contiguous_space_and_return_available_range(builder);
            clamped_count := min(count, available_range.count);
            count -= clamped_count;
            copy_repeated_character(available_range.data, clamped_count, character);
            advance_through_ensured_space(builder, clamped_count);
        }
        
        return result;
    }

    characters_removed_by_zero_removal: int;

    if format.zero_removal != .NO && mode_to_use != .SHORTEST {
        //
        // :ZeroRemoval
        //
        // When we remove zeroes (and possibly the decimal separator itself), special behavior occurs when the width
        // and/or trailing width are explicit (i.e., non-negative). When a width is set and a number of characters
        // are removed by zero removal, the same number of spaces will be removed from any potential left padding,
        // so that the printed number does not shift to the right. When a trailing width is set, any removed
        // characters at the end will be replaced by spaces to maintain the width of the string.
        //
        // Note that the .SHORTEST mode already does its own version of zero removal, so using that in combination
        // with a zero removal mode other than .YES might lead to somewhat surprising results.
        //

        if (decimal_digits_in_string || tz) && dp != INFINITY_OR_NAN {
            if (decimal_digits_in_string > 0 && trailing_zeroes_in_string == decimal_digits_in_string) || (decimal_digits_in_string == 0 && tz > 0) {
                if format.zero_removal == .YES {
                    characters_removed_by_zero_removal = trailing_zeroes_in_string + tz + 1;
                    l -= trailing_zeroes_in_string + 1;
                    tz = 0;
                } else if format.zero_removal == .ONE_ZERO_AFTER_DECIMAL {
                    if trailing_zeroes_in_string {
                        characters_removed_by_zero_removal = (trailing_zeroes_in_string - 1) + tz;
                        l -= (trailing_zeroes_in_string - 1);
                        tz = 0;
                    } else {
                        characters_removed_by_zero_removal = tz - 1;
                        tz = 1;
                    }
                }
            } else if trailing_zeroes_in_string {
                characters_removed_by_zero_removal = trailing_zeroes_in_string + tz;
                l -= trailing_zeroes_in_string;
                tz = 0;
            } else if tz {
                characters_removed_by_zero_removal = tz;
                tz = 0;
            }
        }
    }

    // Calculate fw (= leading/trailing space) and pr (= leading zeroes).
    pr = max(pr, l);

    n = pr + exponent[0] + tz;
    if prefix_character  n += 1;

    fw = max(fw, n);

    fw -= n;
    pr -= l;

    // Maintain number alignment by taking the number of characters removed by zero removal and removing that many spaces from the left padding. :ZeroRemoval
    fw -= min(fw, characters_removed_by_zero_removal);

    if !use_left_justification {
        if left_pad_with_zeroes { // if leading zeros, everything is in pr
            pr = ifx fw > pr then fw else pr;
            fw = 0;
        } else {
            use_thousand_separators = false;
        }
    }

    // copy the spaces and/or zeros
    if fw + pr {
        // copy leading spaces (or when doing %8.4d stuff)
        if !use_left_justification  total_string_length += append_repeated_character(builder, fw, #char " ");

        // copy leader
        if prefix_character { append(builder, prefix_character); total_string_length += 1; }

        // copy leading zeros
        c := cs >> 24;
        cs &= 0xffffff;
        cs = ifx use_thousand_separators then c - ((pr + cs) % (c + 1)) else 0;

        if pr {
            if !use_thousand_separators {
                total_string_length += append_repeated_character(builder, pr, #char "0");
            } else {
                for 1..pr {
                    if cs == c {
                        cs = 0;
                        append(builder, thousand_separator_character); total_string_length += 1;
                    } else {
                        cs += 1;
                        append(builder, #char "0"); total_string_length += 1;
                    }
                }
            }
        }
    } else if prefix_character { append(builder, prefix_character); total_string_length += 1; }

    append(builder, s, l); total_string_length += l; // Copy number string.

    total_string_length += append_repeated_character(builder, tz, #char "0"); // Copy trailing zeros.

    append(builder, *exponent[1], exponent[0]); total_string_length += exponent[0]; // Copy exponent (if there is one).

    // Add spaces back to compensate for removed characters. :ZeroRemoval
    if format.trailing_width > -1  total_string_length += append_repeated_character(builder, characters_removed_by_zero_removal, #char " ");

    // In case of left justify, put the spaces at the end.
    if use_left_justification && fw > 0  total_string_length += append_repeated_character(builder, fw, #char " ");
    

    return total_string_length;
}



#scope_file

default_precision :: 6;
thousand_group_size :: 3;

nan_label :: "NaN";
inf_label :: "Inf";

INFINITY_OR_NAN :: 0x7000;



// =======================================================================
//   low level float utility functions

STBSP__COPYFP :: (dest: Code, src: Code) #expand {
    << cast(*u64)*(#insert dest) = << cast(*u64)*(#insert src);
}

stbsp__bot       :: float64.[0h3ff0000000000000, 0h4024000000000000, 0h4059000000000000, 0h408f400000000000, 0h40c3880000000000, 0h40f86a0000000000, 0h412e848000000000, 0h416312d000000000, 0h4197d78400000000, 0h41cdcd6500000000, 0h4202a05f20000000, 0h42374876e8000000, 0h426d1a94a2000000, 0h42a2309ce5400000, 0h42d6bcc41e900000, 0h430c6bf526340000, 0h4341c37937e08000, 0h4376345785d8a000, 0h43abc16d674ec800, 0h43e158e460913d00, 0h4415af1d78b58c40, 0h444b1ae4d6e2ef50, 0h4480f0cf064dd592];
stbsp__negbot    :: float64.[0h3fb999999999999a, 0h3f847ae147ae147b, 0h3f50624dd2f1a9fc, 0h3f1a36e2eb1c432d, 0h3ee4f8b588e368f1, 0h3eb0c6f7a0b5ed8d, 0h3e7ad7f29abcaf48, 0h3e45798ee2308c3a, 0h3e112e0be826d695, 0h3ddb7cdfd9d7bdbb, 0h3da5fd7fe1796495, 0h3d719799812dea11, 0h3d3c25c268497682, 0h3d06849b86a12b9b, 0h3cd203af9ee75616, 0h3c9cd2b297d889bc, 0h3c670ef54646d497, 0h3c32725dd1d243ac, 0h3bfd83c94fb6d2ac, 0h3bc79ca10c924223, 0h3b92e3b40a0e9b4f, 0h3b5e392010175ee6];
stbsp__negboterr :: float64.[0hbc5999999999999a, 0hbc0eb851eb851eb8, 0hbbd89374bc6a7efa, 0hbbb6a161e4f765fe, 0hbb8ee78183f91e64, 0h3b4b5a63f9a49c2c, 0h3b15e1e99483b023, 0hbad03023df2d4c94, 0hbab34674bfabb83b, 0hba720a5465df8d2c, 0h3a47f7bc7b4d28aa, 0h39f97f27f0f6e886, 0hb9cecd79a5a0df95, 0h394ea70909833de7, 0hb97937831647f5a0, 0h3925b4c2ebe68799, 0hb90db7b2080a3029, 0hb8d7c628066e8cee, 0h388a52b31e9e3d07, 0h38675447a5d8e536, 0h383f769fb7e0b75e, 0hb7fa7566d9cba769];
stbsp__top       :: float64.[0h44b52d02c7e14af6, 0h497c06a5ec5433c6, 0h4e428bc8abe49f64, 0h53088ba3bf284e24, 0h57d03e29f5c2b18c, 0h5c957f48bb41db7c, 0h615c73892ecbfbf4, 0h6622d3d6f88f0b3d, 0h6ae8eb0138858d0a, 0h6fb07d457124123d, 0h7475d2ce55747a18, 0h793ce2137f743382, 0h7e031cfd3999f7b0];
stbsp__negtop    :: float64.[0h3b282db34012b251, 0h366244ce242c5561, 0h319b9b6364f30304, 0h2cd4dbf7b3f71cb7, 0h280f8587e7083e30, 0h2347d12a4670c123, 0h1e81fee341fc585d, 0h19bb31bb5dc320d2, 0h14f48c22ca71a1bd, 0h102f0ce4839198db, 0h0b677603725064a8, 0h06a1ba03f5b21000, 0h01dac9a7b3b7302f];
stbsp__toperr    :: float64.[0h4160000000000000, 0h45ebb542c80deb40, 0hcae83b80b9aab60a, 0hcfa32e22d17a166c, 0hd4523606902e180e, 0hd9296fb782462e87, 0hddf358952c0bd011, 0he2a78c1376a34b6c, 0he7817569fc243adf, 0hec5d9365a897aaa6, 0h7119050c256123a0, 0hf5db1799d76cc7a6, 0hfaa213fe39571a38];
stbsp__negtoperr :: float64.[0h37c13badb829e079, 0hb2ee46a98d3d9f64, 0h2e3227c7218a2b65, 0h2951d96999aa01e9, 0ha4acc2229efc3962, 0h9fecd04a2263407a, 0h9b123b80f187a157, 0h965c4e22914ed912, 0h119bc296cdf42f82, 0h8cc9f9e7f4e16fe1, 0h880aeb0a72a8902a, 0h834e228e12c13408, 0h0000000000fa1259];

stbsp__powten :: u64.[1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 10000000000, 100000000000, 1000000000000, 10000000000000, 100000000000000, 1000000000000000, 10000000000000000, 100000000000000000, 1000000000000000000, 10000000000000000000];
stbsp__tento19th : u64 : 1000000000000000000;

stbsp__ddmulthi :: (oh: Code, ol: Code, xh: Code, yh: Code) #expand {
    ahi: float64 = 0;
    alo: float64 = ---;
    bhi: float64 = 0;
    blo: float64 = ---;
    bt: s64 = ---;
    (#insert oh) = (#insert xh) * (#insert yh);
    STBSP__COPYFP(bt, (#insert xh)); bt &= cast,no_check(s64)((~cast,no_check(u64)0) << 27); STBSP__COPYFP(ahi, bt); alo = (#insert xh) - ahi;
    STBSP__COPYFP(bt, (#insert yh)); bt &= cast,no_check(s64)((~cast,no_check(u64)0) << 27); STBSP__COPYFP(bhi, bt); blo = (#insert yh) - bhi;
    (#insert ol) = ((ahi * bhi - (#insert oh)) + ahi * blo + alo * bhi) + alo * blo;
}

stbsp__ddtoS64 :: (ob: Code, xh: Code, xl: Code) #expand {
    ahi: float64 = 0;
    alo: float64 = ---;
    vh:  float64 = ---;
    t:   float64 = ---;
    (#insert ob) = cast,no_check(s64)`ph;
    vh = cast,no_check(float64) (#insert ob);
    ahi = (#insert xh) - vh;
    t = ahi - (#insert xh);
    alo = ((#insert xh) - (ahi - t)) - (vh + t);
    (#insert ob) += cast,no_check(s64)(ahi + alo + (#insert xl));
}

stbsp__ddrenorm :: (oh: Code, ol: Code) #expand {
    s: float64 = ---;
    s = cast,no_check(float64)((#insert oh) + (#insert ol));
    (#insert ol) = (#insert ol) - (s - (#insert oh));
    (#insert oh) = s;
}

stbsp__ddmultlo :: (oh: Code, ol: Code, xh: Code, xl: Code, yh: Code, yl: Code) #expand {
    (#insert ol) = (#insert ol) + ((#insert xh)*(#insert yl) + (#insert xl)*(#insert yh));
}

stbsp__ddmultlos :: (oh: Code, ol: Code, xh: Code, yl: Code) #expand {
    (#insert ol) = (#insert ol) + ((#insert xh)*(#insert yl));
}

stbsp__raise_to_power10 :: (ohi: *float64, olo: *float64, d: float64, power: s32 /* power can be -323 to +350 */) {
    ph, pl: float64;
    if (power >= 0) && (power <= 22) {
        stbsp__ddmulthi(ph, pl, d, stbsp__bot[power]);
    } else {
        e, et, eb: s32;
        p2h, p2l: float64;

        e = power;
        if power < 0  e = -e;
        et = (e * 0x2c9) >> 14;/* %23 */
        if et > 13  et = 13;
        eb = e - (et * 23);

        ph = d; pl = 0;
        if power < 0 {
            if eb {
                eb -= 1;
                stbsp__ddmulthi(ph, pl, d, stbsp__negbot[eb]);
                stbsp__ddmultlos(ph, pl, d, stbsp__negboterr[eb]);
            }

            if et {
                stbsp__ddrenorm(ph, pl);
                et -= 1;
                stbsp__ddmulthi(p2h, p2l, ph, stbsp__negtop[et]);
                stbsp__ddmultlo(p2h, p2l, ph, pl, stbsp__negtop[et], stbsp__negtoperr[et]);
                ph = p2h;
                pl = p2l;
            }
        } else {
            if eb {
                e = eb;
                if eb > 22  eb = 22;
                e -= eb;
                stbsp__ddmulthi(ph, pl, d, stbsp__bot[eb]);
                if e {
                    stbsp__ddrenorm(ph, pl);
                    stbsp__ddmulthi(p2h, p2l, ph, stbsp__bot[e]);
                    stbsp__ddmultlos(p2h, p2l, stbsp__bot[e], pl);
                    ph = p2h;
                    pl = p2l;
                }
            }
            if et {
                stbsp__ddrenorm(ph, pl);
                et -= 1;
                stbsp__ddmulthi(p2h, p2l, ph, stbsp__top[et]);
                stbsp__ddmultlo(p2h, p2l, ph, pl, stbsp__top[et], stbsp__toperr[et]);
                ph = p2h;
                pl = p2l;
            }
        }
    }
    stbsp__ddrenorm(ph, pl);
    ohi.* = ph;
    olo.* = pl;
}

// given a float value, returns the significant bits in bits, and the position of the
//   decimal point in decimal_pos.  +/-INF and NAN are specified by special values
//   returned in the decimal_pos parameter.
// frac_digits is absolute normally, but if you want from first significant digits (got %g and %e), or in 0x80000000
stbsp__real_to_str :: (start: **u8, len: *int, out: *u8, decimal_pos: *int, value: float64, frac_digits: u32) -> bool {
    bits: s64;
    e, tens: s32;
    d := value;

    STBSP__COPYFP(bits, d);
    expo := cast,no_check(s32)((bits >> 52) & 2047);
    is_negative := cast,no_check(bool)(bits >> 63);
    if is_negative  d = -d;

    if expo == 2047 { // is nan or inf?
        if bits & cast,no_check(s64)(((cast,no_check(u64)1) << 52) - 1) {
            start.* = nan_label.data;
            len.*   = nan_label.count;
        } else {
            start.* = inf_label.data;
            len.*   = inf_label.count;
        }

        decimal_pos.* = INFINITY_OR_NAN;
        return is_negative;
    }

    if expo == 0 { // is zero or denormal
        if (bits << 1) == 0 { // do zero
            decimal_pos.* = 1;
            start.*= out;
            out.* = #char "0";
            len.* = 1;
            return is_negative;
        }

        // find the right expo for denormals
        {
            one : u64 : 1;
            v: s64 = cast,no_check(s64)(one << 51);
            while (bits & v) == 0 {
                expo -= 1;
                v >>= 1;
            }
        }
    }

    // find the decimal exponent as well as the decimal bits of the value
    {
        ph, pl: float64;

        // log10 estimate - very specifically tweaked to hit or undershoot by no more than 1 of log10 of all expos 1..2046
        tens = expo - 1023;
        tens = ifx tens < 0 then (tens * 617) / 2048 else ((tens * 1233) / 4096) + 1;

        // move the significant bits into position and stick them into an int
        stbsp__raise_to_power10(*ph, *pl, d, 18 - tens);

        // get full as much precision from double-double as possible
        stbsp__ddtoS64(bits, ph, pl);

        // check if we undershot
        if cast(u64)bits >= stbsp__tento19th  tens += 1;
    }

    // now do the rounding in integer land
    #no_aoc {  // In some (legit?) cases the tens + frac_digits can overflow.
        frac_digits = ifx frac_digits & 0x80000000 then (frac_digits & 0x7ffffff) + 1 else cast,no_check(u32)tens + frac_digits;
    }
    
    if frac_digits < 24 {
        dg: u32 = 1;
        if cast,no_check(u64)bits >= stbsp__powten[9]  dg = 10;

        done_fracing := false;
        while cast,no_check(u64)bits >= stbsp__powten[dg] {
            dg += 1;
            if dg == 20 {
                done_fracing = true;
                break;
            }
        }

        if !done_fracing && frac_digits < dg {
            // add 0.5 at the right position and round
            e = cast,no_check(s32)dg - cast,no_check(s32)frac_digits;
            if cast,no_check(u32)e < 24 {
                r: u64 = stbsp__powten[e];
                bits = bits + cast,no_check(s64)(r / 2);
                if cast,no_check(u64)bits >= stbsp__powten[dg]
                    tens += 1;
                bits /= cast,no_check(s64)r;
            }
        }
    }

    // kill long trailing runs of zeros
    if bits {
        done_killing := false;
        while true {
            if bits <= 0xffffffff  break;
            if bits % 1000 {
                done_killing = true;
                break;
            }
            bits /= 1000;
        }
        if !done_killing {
            n := cast,no_check(u32)bits;
            while (n % 1000) == 0
                n /= 1000;
            bits=n;
        }
    }

    // convert to string
    out += 64;
    e = 0;

    stbsp__digitpair :: "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899";

    while true {
        n: u32 = ---;
        o := out - 8;
        // do the conversion in chunks of U32s (avoid most 64-bit divides, worth it, constant denomiators be damned)
        if bits >= 100000000 {
            n = cast,no_check(u32)(bits % 100000000);
            bits /= 100000000;
        } else {
            n = cast,no_check(u32)bits;
            bits = 0;
        }

        while n {
            out -= 2;
            << cast,no_check(*u16)out = << cast,no_check(*u16)*stbsp__digitpair[(n % 100) * 2];
            n /= 100;
            e += 2;
        }

        if bits == 0 {
            if e && out.* == #char "0" {
                out += 1;
                e -= 1;
            }
            break;
        }

        while out != o {
            out -= 1;
            out.* = #char "0";
            e += 1;
        }
    }

    decimal_pos.* = tens;
    start.*= out;
    len.* = e;

    return is_negative;
}

