// 128-bit signed integer:
S128 :: struct {
    low:  u64;
    high: s64;
}

// 128-bit unsigned integer:
U128 :: struct {
    low:  u64;
    high: u64;
}

// These values returned for quotient and remainder of division when overflow or division by zero
U128_ERROR :: U128.{0xffffffff_ffffffff, 0xffffffff_ffffffff};
S128_ERROR :: S128.{0xffffffff_ffffffff, 0xffffffff_ffffffff};


// If you want a 128-bit result, well, we don't have any primitive types
// that hold that, so, here is some code to do it within u64.
// We might put an asm version here, but right now this is used to
// avoid asm stuff...!
multiply_64bits_with_overflow :: (a: u64, b: u64) -> (high: u64, low: u64) {
    lo_lo := (a & 0xFFFF_FFFF) * (b & 0xFFFF_FFFF);
    hi_lo := (a >> 32)         * (b & 0xFFFF_FFFF);
    lo_hi := (a & 0xFFFF_FFFF) * (b >> 32);
    hi_hi := (a >> 32)         * (b >> 32);

    cross := (lo_lo >> 32) + (hi_lo & 0xFFFF_FFFF) + lo_hi;

    high := (hi_lo >> 32) + (cross >> 32) + hi_hi;
    low  := (cross << 32) | (lo_lo & 0xFFFF_FFFF);

    return high, low;
}

to_s128 :: (a: $T) -> S128
#modify {
    return (cast(*Type_Info)T).type == .INTEGER;
} {
    return .{cast,no_check(u64) a, (cast(s64)a) >> 63};
}

to_u128 :: (a: $T) -> U128
#modify {
    return T == u64 || T == u32 || T == u16 || T == u8;
} {
    return U128.{a, 0};
}


operator == :: inline (a: S128, b: S128) -> bool {
    return (a.low == b.low) && (a.high == b.high);
}

operator == :: inline (a: U128, b: U128) -> bool {
    return (a.low == b.low) && (a.high == b.high);
}

operator ! :: inline (a: S128) -> bool {
    return a.low == 0 && a.high == 0;
}

operator ! :: inline (a: U128) -> bool {
    return a.low == 0 && a.high == 0;
}

operator + :: inline (a: S128, b: S128) -> S128 { // This can be the same code for S128 and U128.
    c: S128 = ---;

    #if CPU == .X64 {
        #asm {
            mov a_low:,  [*a + 0];
            mov a_high:, [*a + 8];

            mov b_low:,  [*b + 0];
            mov b_high:, [*b + 8];

            mov [*c + 0], a_low;
            mov [*c + 8], a_high;

            add [*c + 0], b_low;
            adc [*c + 8], b_high;
        }
    } else {
        c.low  = a.low  + b.low;
        c.high = a.high + b.high;
        if c.low < a.low  c.high += 1;  // We overflowed!
    }

    return c;
}

operator - :: inline (a: S128, b: S128) -> S128 {
    return cast,force(S128) (cast,force(U128)a - cast,force(U128)b);
}

operator - :: inline (a: U128, b: U128) -> U128 {
    c: U128 = ---;

    #if CPU == .X64 {
        #asm {
            mov a_low:,  [*a + 0];
            mov a_high:, [*a + 8];

            mov b_low:,  [*b + 0];
            mov b_high:, [*b + 8];

            mov [*c + 0], a_low;
            mov [*c + 8], a_high;

            sub [*c + 0], b_low;
            sbb [*c + 8], b_high;

            // I guess these are not legal forms of 'add':
            // add [*c + 0], a_low,  b_low;
            // adc [*c + 8], a_high, b_high;
        }
    } else {
        c.high = a.high - b.high;
        c.low  = a.low  - b.low;
        if c.low > a.low  c.high -= 1;  // We underflowed!
    }

    return c;
}

operator - :: inline (a: S128) -> S128 {
    // Apollo Time is two's complement.
    // To negate it, we flip all the bits and then add 1.
    // We'll use #asm to avoid a branch.

    c: S128 = ---;
    c.low  = ~a.low;
    c.high = ~a.high;

    #if CPU == .X64 {
        #asm {
            add [*c + 0], 1;
            adc [*c + 8], 0;
        }
    } else {
        c.low += 1;
        if !c.low  c.high += 1;  // If c.low overflowed, carry into high.
    }

    return c;
}

// Complexity-wise, it may not be worth specializing << and >> for constant x,
// since the win is relatively low these days. But I did it anyway.
operator << :: (a: S128, $$x: u8) -> S128 {
    result : S128 = ---;

    if x >= 64 {
        new_high := cast,no_check(s64)(a.low << (x - 64));
        return .{0, new_high};
    } else {
        #if CPU == .X64 {
            result = a;

            #if !is_constant(x)  #asm { x === c; }  // Use the cl form of shift.

            #asm {
                mov low:, [*result + 0];
                shld [*result + 8], low, x;
                shl  [*result + 0], x;
            }
        } else {
            result.high = a.high << x | cast(s64)(a.low >> (64 - x));
            result.low  = a.low << x;
        }
    }

    return result;
}

operator << :: inline (a: U128, $$x: u8) -> U128 {
    result : U128 = ---;

    if x >= 64 {
        new_high := a.low << (x - 64);
        return .{0, new_high};
    } else {
        #if CPU == .X64 {
            result = a;

            #if !is_constant(x)  #asm { x === c; }  // Use the cl form of shift.

            #asm {
                mov low:, [*result + 0];
                shld [*result + 8], low, x;
                shl  [*result + 0], x;
            }
        } else {
            result.high = a.high << x | (a.low >> (64 - x));
            result.low  = a.low << x;
        }
    }

    return result;
}

operator >> :: (a: S128, $$x: u8) -> S128 {  // Arithmetic shift
    if x >= 64 {
        new_low := cast,no_check (u64) (a.high >> (x - 64));
        return .{low = new_low, high = a.high >> 63};
    } else {
        #if CPU == .X64 {
            result := a;

            #if !is_constant(x)  #asm { x === c; }  // Use the cl form of shift.

            #asm {
                mov high:, [*result + 8];
                shrd [*result + 0], high, x;
                sar  [*result + 8], x;
            }
        } else {
            result: S128 = ---;
            result.low = (a.low >> x) | cast(u64)(a.high << (64 - x));
            result.high = a.high >> x;
        }

        return result;
    }
}

operator >> :: (a: U128, $$x: u8) -> U128 {  // Logical shift.
    if !a || !x  return a;

    if x >= 64 {
        return .{low = a.high >> (x - 64), high = 0};
    } else {
        #if CPU == .X64 {
            result := a;
            #if !is_constant(x)  #asm { x === c; }  // Use the cl form of shift.

            #asm {
                mov high:, [*result + 8];
                shrd [*result + 0], high, x;
                shr  [*result + 8], x;
            }
        } else {
            result: U128 = ---;
            result.low = a.low >> x | (a.high << (64 - x));
            result.high = a.high >> x;
        }

        return result;
    }
}

// @Incomplete: Refactor logical_shift_right as >> on U128.
logical_shift_right :: (a: S128, $$x: u8) -> S128 {
    return cast,force(S128) ((cast,force(U128) a) >> x);
}


// Our division procs handle divide-by-zero and overflow without aborting, returning an error flag and
// setting the result to U128_MAX.  While using operator `/` you don't get this error flag, and the expected
// result of any operator `/` divide-by-zero is boom, so here we'll assert to simulate that behaviour.
// OTOH, overflow is bit weird and not as easy to anticipate, so we'll allow it to return (and the programmer can
// test for the error return value when they notice weird behaviour with their results, but their program won't
// unexpectedly crash in production when the user puts in some bad values).
// Maybe it'd be better to halt on both conditions, with the programmer expected to validate the inputs before
// calling, but the easiest way for them to do that would be for them to call the (un)signed_divide_with_remainder
// proc themselves... at which point they don't need the `/` operator, so we're letting the `/` operator be the
// "easy use" version of divide. - IK
operator / :: (dividend: U128, divisor: U128) -> U128 {
    assert(divisor != .{0, 0}, "Cannot divide by zero!");
    return inline unsigned_divide_with_remainder(dividend, divisor);
}

operator / :: (dividend: S128, divisor: S128) -> S128 {
    assert(divisor != .{0, 0}, "Cannot divide by zero!");
    return inline signed_divide_with_remainder(dividend, divisor);
}

operator / :: inline (a: S128, factor: s64) -> S128 {
    // We'll put a faster version here later?

    b: S128;

    negate := false;
    b.low = cast,no_check(u64) factor;
    if factor < 0  b.high = -1;

    return a / b;
}


signed_divide_with_remainder :: inline (dividend: S128, divisor: S128) -> quotient: S128, remainder: S128, overflow_or_divide_by_zero: bool {
    u := dividend;
    v := divisor;

    negate := false;
    if u.high < 0 {
        negate = true;
        u = -u;
    }

    if v.high < 0 {
        negate = !negate;
        v = -v;
    }

    quotient, remainder, overflow_or_divide_by_zero := unsigned_divide_with_remainder(cast,force(U128)u, cast,force(U128)v);
    if overflow_or_divide_by_zero  return  cast,force(S128)quotient, cast,force(S128)remainder, true;
    else if negate                 return -cast,force(S128)quotient, cast,force(S128)remainder, false;
    else                           return  cast,force(S128)quotient, cast,force(S128)remainder, false;
}


unsigned_divide_with_remainder :: (u: U128, v: U128) -> quotient: U128, remainder: U128, overflow_or_divide_by_zero: bool {
    // This unsigned divide is used to help implement our operator /, which is
    // a wrapper that does sign manipulations then calls this routine.

    // Code adapted from Hacker's Delight by Henry S. Warren, Jr., Second Edition, section 9-5.
    // That listing was for 64-bit division, but here we do 128-bit division.

    if !v  return U128_ERROR, U128_ERROR, true;

    #if CPU == .X64  { // Lifted these procs out of here so they can be tested against each other
        DIVU_FF :: unsigned_divide_with_remainder_128_64_x64;
    } else {
        DIVU_FF :: unsigned_divide_with_remainder_128_64_no_asm;
    }

    if v.high == 0 {
        u1 := cast,no_check(u64) u.high;
        d  := v.low;

        if u1 < d { // If u/v cannot overflow, just do one division.
            quotient: U128 = ---;
            remainder: U128 = ---;
            quotient.high, remainder.high = 0;
            error : bool = ---;
            quotient.low, remainder.low, error = DIVU_FF(u, d);
            if error  return U128_ERROR, U128_ERROR, true;
            else      return quotient, remainder, false;
        } else {
            // If u/v would overflow: Break up u into two halves.
            u0 := u.low;
            // q1 := DIVU_FF(u1, d);   // First quotient digit.
            q1 := u1 / d;           // First quotient digit.
            k := u1 - q1*d;         // First remainder, < v.

            c: U128 = ---;
            c.high = k;
            c.low  = u0;

            q0, remainder_u64, error := DIVU_FF(c, d);
            quotient := U128.{low = q0, high = q1};
            remainder := U128.{low = remainder_u64, high = 0};

            if error  return U128_ERROR, U128_ERROR, true;
            else      return quotient, remainder, false;
        }
    }

    n := count_leading_zero_bits(v.high);

    _v1 := v << n;
    // Warren shifts right here to get the top bits, but we can just use .high
    v1 := cast(u64) _v1.high;

    // Right-shift u by 1 bit, to ensure no overflow.
    u1 := (u >> 1);

    q1, _, error := DIVU_FF(u1, v1);
    if error  return U128_ERROR, U128_ERROR, true;

    // Undo normalization and division of u by 2.
    _q1 := U128.{low = q1};
    _q1 <<= n;
    q0 := _q1 >> 63;

    // Make q0 correct or too small by 1.
    if q0.high || q0.low {  // q0 != 0
        if q0.low == 0 {
            // Borrow from the top; could use #asm.
            q0.low  -= 1;
            q0.high -= 1;
        } else {
            q0.low  -= 1;
        }
    }

    remainder := u - q0*v;
    if remainder >= v {  // Finally correct q0.
        q0.low += 1;
        if q0.low == 0  q0.high += 1;
        remainder -= v;
    }

    return q0, remainder, false;
}

#scope_file

U64_MAX :: 0xFFFF_FFFF_FFFF_FFFF;

#if CPU == .X64 {
    unsigned_divide_with_remainder_128_64_x64 :: (a: U128, d: u64) -> quotient: u64, remainder: u64, overflow_or_divide_by_zero: bool {
        #assert CPU == .X64;

        if a.high >= d
            return U64_MAX, U64_MAX, true;

        quotient: u64 = ---;
        remainder: u64 = ---;
        #asm {
            high: gpr === d;
            low:  gpr === a;

            mov low,  [*a + 0];
            mov high, [*a + 8];
            div high, low, d;

            mov quotient, low;
            mov remainder, high;
        }

        return quotient, remainder, false;
    }
}

unsigned_divide_with_remainder_128_64_no_asm :: (num: U128, den: u64) -> quotient: u64, remainder: u64, overflow_or_divide_by_zero: bool {
    // This software version is derived from public domain/CC0 code found at:
    // https://ridiculousfish.com/blog/posts/labor-of-division-episode-v.html

    numhi := num.high;
    numlo := num.low;

    // Check for overflow and divide by 0.
    if numhi >= den
        return U64_MAX, U64_MAX, true;

    // We work in base 2**32.
    // A uint32 holds a single digit. A uint64 holds two digits.
    // Our numerator is conceptually [num3, num2, num1, num0].
    // Our denominator is [den1, den0].
    b : u64 : (1 << 32);

    // The high and low digits of our computed quotient.
    q1: u32 = ---;
    q0: u32 = ---;

    // The normalization shift factor.
    shift: int = ---;

    // The high and low digits of our denominator (after normalizing).
    // Also the low 2 digits of our numerator (after normalizing).
    den1: u32 = ---;
    den0: u32 = ---;
    num1: u32 = ---;
    num0: u32 = ---;

    // A partial remainder.
    rem: u64 = ---;

    // The estimated quotient, and its corresponding remainder (unrelated to true remainder).
    qhat: u64 = ---;
    rhat: u64 = ---;

    // Variables used to correct the estimated quotient.
    c1: u64 = ---;
    c2: u64 = ---;

    // Determine the normalization factor. We multiply den by this, so that its leading digit is at
    // least half b. In binary this means just shifting left by the number of leading zeros, so that
    // there's a 1 in the MSB.
    // We also shift numer by the same amount. This cannot overflow because numhi < den.
    // The expression (-shift & 63) is the same as (64 - shift), except it avoids the UB of shifting
    // by 64. The funny bitwise 'and' ensures that numlo does not get shifted into numhi if shift is 0.
    // clang 11 has an x86 codegen bug here: see LLVM bug 50118. The sequence below avoids it.
    shift = count_leading_zero_bits(den);
    den <<= cast(u64)shift;
    numhi <<= cast(u64)shift;
    numhi |= (numlo >> (-shift & 63)) & cast,no_check(u64)(-shift >> 63);
    numlo <<= cast(u64)shift;

    // Extract the low digits of the numerator and both digits of the denominator.
    num1 = cast(u32)(numlo >> 32);
    num0 = cast(u32)(numlo & 0xFFFF_FFFF);
    den1 = cast(u32)(den >> 32);
    den0 = cast(u32)(den & 0xFFFF_FFFF);

    // We wish to compute q1 = [n3 n2 n1] / [d1 d0].
    // Estimate q1 as [n3 n2] / [d1], and then correct it.
    // Note while qhat may be 2 digits, q1 is always 1 digit.
    qhat = numhi / den1;
    rhat = numhi % den1;
    c1 = qhat * den0;
    c2 = rhat * b + num1;
    if c1 > c2
        qhat -= ifx c1 - c2 > den then cast(u64)2 else 1;
    q1 = cast(u32)qhat;

    // Compute the true (partial) remainder.
    rem = numhi * b + num1 - q1 * den;

    // We wish to compute q0 = [rem1 rem0 n0] / [d1 d0].
    // Estimate q0 as [rem1 rem0] / [d1] and correct it.
    qhat = rem / den1;
    rhat = rem % den1;
    c1 = qhat * den0;
    c2 = rhat * b + num0;
    if c1 > c2
        qhat -= ifx c1 - c2 > den then cast(u64)2 else 1;
    q0 = cast(u32)qhat;

    quotient := ((cast(u64)q1) << 32) | q0;
    remainder := (rem * b + num0 - q0 * den) >> shift;
    return quotient, remainder, false;
}

count_leading_zero_bits :: inline (x: u64) -> u8 {
    // Maybe Basic should have a Simple_Math component with stuff like this in it? - IK
    n: u8 = ---;
    #if CPU == .X64 {
        #asm {
            lzcnt n, x;
        }
    } else {
        if x == 0 return(64);
        n = 0;
        if x <= 0x00000000FFFFFFFF { n = n + 32; x = x << 32; }
        if x <= 0x0000FFFFFFFFFFFF { n = n + 16; x = x << 16; }
        if x <= 0x00FFFFFFFFFFFFFF { n = n +  8; x = x <<  8; }
        if x <= 0x0FFFFFFFFFFFFFFF { n = n +  4; x = x <<  4; }
        if x <= 0x3FFFFFFFFFFFFFFF { n = n +  2; x = x <<  2; }
        if x <= 0x7FFFFFFFFFFFFFFF { n = n +  1; }
    }
    return n;
}


#scope_export

//
// The sign handling in these operator * below is a little uncertain given
// that I don't really understand the difference between imul and mul.
// @Incomplete: Consult Hacker's Delight.
//
operator * :: (_a: S128, _b: S128) -> S128 {
    a := _a; // @Speed @Temporary
    b := _b;

    negate := false;
    if a.high < 0 {
        a = -a;
        negate = true;
    }

    if b.high < 0 {
        b = -b;
        negate = !negate;
    }

    u := cast,force(U128)a * cast,force(U128) b;
    result := cast,force(S128) u;

    if negate return -result;
    else      return result;
}

operator * :: (_a: U128, _b: U128) -> U128 {
    a := _a; // @Speed @Temporary
    b := _b;

    result: U128 = ---;

    // The code below is really convoluted because I am not sure if we can
    // bind multiple names to the same physical register? Would really like to.
    #if CPU == .X64 {
        #asm {
            result_high: gpr === d;
            result_low:  gpr === a;

            factor:   gpr;
            high_sum: gpr;

            // Low times low:
            mov result_low, [*a + 0];  // This is input as well as result.
            mov factor,     [*b + 0];

            mul result_high, result_low, factor;

            mov [*result + 0],  result_low;   // Store the low part.
            mov high_sum, result_high;  // Store the high part.

            // High a times low b. 'factor' still holds low b.
            mov result_low, [*a + 8];
            imul result_high, result_low, factor;
            add high_sum, result_low;

            // Low a times high b.
            mov result_low, [*a + 0];
            mov factor,     [*b + 8];
            imul result_high, result_low, factor;
            add high_sum, result_low;

            // High a times high b is discarded.

            mov [*result + 8], high_sum;
        }
    } else {
        result.high, result.low = multiply_64bits_with_overflow(a.low, b.low);
        result.high += a.high * b.low + a.low * b.high;
    }

    return result;
}

operator * :: (a: S128, factor: s64) -> S128 #symmetric {
    at := a; // @Speed @Temporary

    negate := false;
    if at.high < 0 {
        at = -at;
        negate = true;
    }

    if factor < 0 {
        factor = -factor;
        negate = !negate;
    }

    result: S128 = ---;

    // We would like to be able to bind multiple names to the same machine register
    // to make code like the following less confusing.
    #if CPU == .X64 {
        #asm {
            result_high: gpr === d;
            result_low:  gpr === a;

            mov result_low, [*at + 0];  // This is input as well as result.
            mul result_high, result_low, factor;

            mov [*result + 0], result_low;

            mov carry:, result_high;

            mov result_low, [*at + 8];  // This is input as well as result.
            imul result_high, result_low, factor;

            add result_low, carry;

            mov [*result + 8], result_low;  // This is actually the high.
        }
    } else {
        u128 : U128 = ---;
        u128.high, u128.low = multiply_64bits_with_overflow(at.low, cast(u64)factor);
        u128.high += cast(u64)at.high * cast(u64)factor;
        result = cast,force(S128)u128;
    }

    if negate return -result;
    else      return result;
}

operator < :: (a: S128, b: S128) -> bool {
    result: bool = ---;

    #if CPU == .X64 {
        #asm {
            mov a_low:,  [*a + 0];
            mov a_high:, [*a + 8];

            mov b_low:,  [*b + 0];
            mov b_high:, [*b + 8];

            sub a_low,  b_low;
            sbb a_high, b_high;

            setl  result;
        }
    } else {
        if a.high < b.high return true;
        if a.high > b.high return false;
        return a.low < b.low;
    }

    return result;
}

operator < :: (a: U128, b: U128) -> bool {  // @Speed: Do #asm.
    if (a.high < b.high) return true;
    if (a.high > b.high) return false;

    return (a.low < b.low);
}

operator <= :: (a: S128, b: S128) -> bool {
    // We would like the compiler to generate this for us, probably, like it does with +=.
    return (a == b) || (a < b);  // Probably not very efficient.
}

operator > :: (a: S128, b: S128) -> bool {
    // We would like the compiler to generate this for us, probably, like it does with +=.
    return !(a <= b);
}

operator >= :: (a: S128, b: S128) -> bool {
    // We would like the compiler to generate this for us, probably, like it does with +=.
    return !(a < b);
}

operator <= :: (a: U128, b: U128) -> bool {
    // We would like the compiler to generate this for us, probably, like it does with +=.
    return (a == b) || (a < b);  // Probably not very efficient.
}

operator > :: (a: U128, b: U128) -> bool {
    // We would like the compiler to generate this for us, probably, like it does with +=.
    return !(a <= b);
}

operator >= :: (a: U128, b: U128) -> bool {
    // We would like the compiler to generate this for us, probably, like it does with +=.
    return !(a < b);
}


operator * :: (a: U128, b: s64) -> U128 {
    return a * cast(u64)b;
}

operator * :: (a: U128, b: u64) -> U128 {
    b128 : U128 = ---;
    b128.high = 0;
    b128.low = b;
    return a * b128;
}

operator + :: (a: U128, b: U128) -> U128 {
    return cast,force(U128)(cast,force(S128)a + cast,force(S128)b);
}

operator + :: (a: U128, b: u64) -> U128 {
    return a + U128.{b, 0};
}

#if CPU == .X64 {
    test_unsigned_division :: (random_iterations := 0, random_get : () -> u64 = null) {
        to_string :: (x: U128) -> string {
            if x.high
                return tprint("0x%0_%0", formatInt(x.high, base=16), formatInt(x.low, base=16, minimum_digits=16));
            else
                return tprint("%0", x.low);
        }

        test_pattern : u64 : 0xAAAAAAAA_AAAAAAAA;
        dividend := U128.{test_pattern, test_pattern};

        // Test x64 version against no_asm version - both should give identical results!
        // Also test the result played backwards through multiply gives the start point.
        while true  {
            divisor := test_pattern;
            while true {
                x64_quotient, x64_remainder, x64_error := unsigned_divide_with_remainder_128_64_x64(dividend, divisor);
                jai_quotient, jai_remainder, jai_error := unsigned_divide_with_remainder_128_64_no_asm(dividend, divisor);
                assert(x64_quotient == jai_quotient);
                assert(x64_remainder == jai_remainder);
                assert(x64_error == jai_error);
                if !x64_error {
                    print("[OK] % / % = % remainder %\n", to_string(dividend), divisor, x64_quotient, x64_remainder);
                    assert(U128.{divisor, 0} * x64_quotient + x64_remainder == dividend);
                }
                if !divisor  break;
                divisor >>= 1;
            }
            if !dividend  break;
            dividend >>= 1;
        }

        // Test `/` operator
        dividend = U128.{test_pattern, test_pattern};
        while true {
            divisor := U128.{test_pattern, test_pattern};
            while true {
                quotient, remainder, overflow_or_div_zero := unsigned_divide_with_remainder(dividend, divisor);
                operator_quotient := dividend / divisor;
                if overflow_or_div_zero {
                    print("[OVR] % / %\n", to_string(dividend), to_string(divisor));
                    assert(operator_quotient.high == U64_MAX && operator_quotient.low == U64_MAX);
                } else {
                    print("[OK] % / % = % remainder %\n", to_string(dividend), to_string(divisor), to_string(quotient), to_string(remainder));
                    assert(quotient * divisor + remainder == dividend);
                    assert(quotient == operator_quotient);
                    operator_remainder := dividend - (operator_quotient * divisor);
                    assert(remainder == operator_remainder);
                    if quotient == .{}
                        assert(remainder == dividend);
                }
                divisor >>= 1; // Currently operator `/` halts on divide-by-zero - if that behaviour changes then swap this line and the one below it around
                if !divisor  break;
            }
            if !dividend  break;
            dividend >>= 1;
        }

        // Test randomly
        for 1 .. random_iterations {
            assert(random_get != null);
            x := U128.{low = random_get(), high = 0};
            y := U128.{low = random_get(), high = 0};
            r := U128.{low = random_get() % x.low, high = 0};
            dividend = x * y + r;
            divisor := x;

            quotient, remainder, overflow_or_div_zero := unsigned_divide_with_remainder(dividend, divisor);
            operator_quotient := dividend / divisor;
            if overflow_or_div_zero {
                print("[OVR] % / %\n", to_string(dividend), to_string(divisor));
                assert(operator_quotient.high == U64_MAX && operator_quotient.low == U64_MAX);
            } else {
                print("[OK] % / % = % remainder %\n", to_string(dividend), to_string(divisor), to_string(quotient), to_string(remainder));
                assert(quotient * divisor + remainder == dividend);
                assert(quotient == operator_quotient);
                operator_remainder := dividend - (operator_quotient * divisor);
                assert(remainder == operator_remainder);
                assert(divisor == x);
                assert(quotient == y);
                assert(remainder == r);
                if quotient == .{}
                    assert(remainder == dividend);
            }
        }
    }
}
