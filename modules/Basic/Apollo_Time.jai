// /*

// This file contains the implementation of Apollo Time, a cross-platform time implementation
// that has both high precision and very long range. It provides a unified way of representing
// time for most common software operations, and provides a common space in which times
// can be easily compared (cleaning up the mess made by many operating systems, where your
// wall clock time and file modification time are measured in different units).

// Apollo Time is a 128-bit integer, defined as the number of femtoseconds since
// the Apollo 11 Moon Landing. (There are 10**15 femtoseconds in one second.)

// While having relatively high accuracy compared to most current time formats, Apollo Time also has
// a very long range, able to represent times 5 quadrillion years in the past and future.

// Because of this combination of high accuracy and long range, you can use Apollo_Time both
// to represent the wall clock time, as well as short durations, like a small fraction of
// a 240Hz frame that you might then use for physics simulation. You can use it to represent
// times measured by specialized hardware that runs faster than your CPU -- general-purpose
// CPUs in the year 2022 can only meaningfully ask what time it is in intervals of something
// like 10**-9 seconds, and this has not changed in 20 years; but you might be interfacing
// with a higher-resolution timer that runs independently of the CPU's clock and buffers
// its results until the slow CPU can get them, or that uses interpolation to measure
// the times of events to much greater accuracy. Thus the quantum of 10**-15 represents
// a reasonable degree of future-proofing, though we do wonder if it is enough (the Planck
// time is around 10**-44 seconds, so ... yeah. If we figure out how to make nanocomputers,
// we might need more.)

// This extra space also gives you the ability to perform math on Apollo_Times without
// worrying too much about losing precision in intermediate results, as easily happens
// with floating-point formats. Also, because this is an integer format, accuracy is
// constant; it doesn't change depending on what time it is, as with floating-point formats.
// So, Apollo_Time is suitable for programs that want to represent time in a way that is
// easy to deal with but also rock solid.


// Frequently Asked Questions:

// Q: Isn't this overkill? Why not use a smaller time format with more reasonable range and accuracy?

// A: The history of computing platforms to date is full of time formats that people decide
// are probably maybe fine, that then cause problems only a short time later.
// In Linux today we have time_t, timeval, timespec, and tm, and yet
// still somehow there's a problem where we'll need to expend a great deal of effort to
// revamp all this software before the year 2038, when it will stop working due to numerical
// overflow (which maybe will attempt to be solved by expanding the sizes of these data
// structures, which will break some programs). Other systems have problems that are similar
// but different; when we want to deploy a robust program across all these systems,
// we start drowning in all the details.

// Shouldn't we have learned, by now, that we need a lot of range and precision in our
// time variables? Instead of kicking the can down the road by adding slightly more information
// each time, then running into more problems,
// why not just hit the problem with a giant hammer and solve it for a very long time?
// We have better things to do than debug timestamp problems.

// If the cost of the solution were low and the amount of benefit were high, this would clearly
// be the right decision. In this case it seems clearly to be true; timestamp data is a small
// minority of the data stored by programs, and manipulations of this data are a very small
// fraction of CPU cycles. So adding more overhead here, by doubling the size, has a small
// cost in reality; but the benefit is big, because we remove a huge class of problems
// and uncertainties.

// Software today tends to be very buggy, and it tends not to do much more than software did
// 30 years ago. It is limited by complexity -- the programmers just have too much to do,
// too many complex scenarios to think about, too many bugs to fix. To the extent we can
// reduce this, we should, and software will be better for it (but it must be said that
// a lot of this complexity is self-induced by programmers' lack of appropriate guiding
// aesthetics).

// (All this said, people who tell you how you should program are always saying stuff
// like the previous paragraph. But this time it's true.)

// In addition, for this programming language and the associated user-level code,
// we have the goal of running the same across many platforms, where those platforms
// have different time conventions. It is helpful to us to know that our time convention
// is a superset of all of those, so that we can build interfaces that do not
// create errors due to their time representations having less range than the
// underlying implementations.

// The goal here is just to clean up the BS that programmers already deal with today,
// and also provide a reasonable amount of future-proofing. It's unclear that we could do a
// good job of this in only 64 bits, and if we get bigger than that, 128 bits is the natural
// size. 64 bits would be friendlier to CPUs of today (though this might not matter tomorrow);
// but if we want gigahertz accuracy (seemingly a minimum since today's CPUs are measured in gigahertz),
// we would only get 292 years of range in 64 bits. 128 bits just kills this problem dead,
// and allows us to have much more accuracy.

// (Even just for applications that start a timer at 0 and startup,
// do you want to be writing programs that could only conceivably run for 292 years
// without crashing? Does that seem like a good idea to anyone?)


// Q: Why not use a different zero point, like trying to be more compatible with one of the already
// established conventions, such as Unix's January 1, 1970 or Windows' January 1, 1601?

// A: The choice of zero point is not arbitrary. It is an opportunity for celebration
// and for aspiration, and we choose to take this opportunity rather than throw it away.

// The author of these notes was born on November 3, 1971 (coincidentally, the day that
// the first edition of Unix was released) and is, at the time of this writing, a little
// over 50 years old; Apollo 11 happened before he was born, and for his entire life,
// he has never seen a feat of technology that comes close to Apollo.

// If you don't go to the moon for 5 to 10 years, maybe you just didn't want to, maybe
// you felt it's a little too expensive, not now, I have a headache, and so forth.
// But if this situation continues and you don't go to the moon for 2 generations of people,
// that's a totally different thing.

// At the current time the USA is no longer capable of landing on the moon, nor has it been
// for almost my entire life.
// If we are not in denial, we must admit that technology appears to have stagnated
// or gone backwards in that area. People don't like to admit this, but when you peaked
// 50 years ago, I mean, come on.
// All this said, there is an initiative toward moon and Mars landings that
// appears strong, so hopefully we can recover.

// In our view, software has undergone a similar period of stagnation. This programming
// language and the accompanying user-level code, including Apollo_Time, is the best
// effort we know how to make, with the meager resources at our disposal, to try to
// contribute toward moving software technology forward again.

// This brings us to the idea of using the Unix timestamp, which is pretty close in time
// to the Apollo landing and seems cleaner because it starts at the beginning of a year.
// Well, Unix was good at the time, but we should be moving past it; yet even
// 52 years later we seem to be unable, and this is deeply sad in some way.
// (Meanwhile the Unix we have becomes worse over time, in that it becomes
// tremendously more complicated while offering a relatively small amount of added
// functionality.)

// We would like to do something about all this. If we can.

// "But why, some say, the Moon? Why choose this as our goal? And they may well ask,
// why climb the highest mountain? Why, 35 years ago, fly the Atlantic?
// Why does Rice play Texas?

// We choose to go to the Moon in this decade and do the other things,
// not because they are easy, but because they are hard;
// because that goal will serve to organize and measure the best
// of our energies and skills, because that challenge is one that we are
// willing to accept, one we are unwilling to postpone, and one
// we intend to win."


// Q: Why is the landing of the lunar module used as the zero point for Apollo_Time,
// rather than the launch of the rocket?

// A: Because coffee is for closers.

// The launch of the rocket represents an ambitious effort. And this kind of ambition
// is important, and probably good to commemorate. But the landing of the lunar module
// represents the success of the mission, rather than just the attempt. And success
// is important; it's the only objective measure we have to help calibrate our beliefs --
// if beliefs result in expected outcomes, maybe they are correct.

// This is not a necessary or even sufficient condition; success and failure have
// large random factors. But successful conclusion of engineering efforts is correlated to
// accurate and self-consistent beliefs; if we lose our aesthetic for engineering success,
// our beliefs become unmoored.

// Unfortunately, across Western societies, we have been changing our attitude
// toward engineering success, in a way that pretends reality is subservient
// to our social system. Community and inclusion and good feelings are valued
// more than correctness. We pretend that the discipline of software engineering
// is somehow more about identifying as a programmer, and wanting to contribute
// positively to a community, than it is about the quality of the resulting code,
// or indeed any measurable characteristics of the resulting system.
// We pretend that engineering success comes *because* someone
// identifies as an engineer inside a community, and that person
// showed up and performed the requisite social signals of doing engineering.

// This new aesthetic has been
// adopted widely without serious consideration for the damage it may do to our ability
// to solve problems. So if we now observe that we are no longer good at solving
// problems, maybe it's not that surprising.

// Good feelings are nice and there's nothing wrong with enjoying your participation
// in the engineering community. But when it comes to the question of how much thrust
// to apply in what direction at what time for the spaceship not to crash into the moon,
// there simply are right answers and wrong answers, and getting a high-quality solution is
// much more important than enjoying your social identity as an engineer or indulging
// your desire to feel smart.


// Q: Why not the time of first foot on the ground, rather than the landing of the module?
// Isn't that the real success?

// A: Aesthetic fine-tuning. Boots-on-ground feels like it pushes things into more of an ego direction,
// being more about one person or one country. The moon landing is an achievement for humanity,
// that any human being on Earth can use as inspiration.


// NB. In Vernor Vinge's novel _A Deepness in the Sky_, the use of the moon landing
// as the 0-point of time measurement is mentioned, though it is then revealed that
// the actual 0-point is 15 million seconds later, in other words, it is the
// Unix time. In that book, software is described as an accretion of
// many layers over thousands of years, and "computer archaeologists" are needed
// in order to do things with the deeper layers of the system. Whereas this is
// a little bit funny, knowing what we know about software, we do not see this
// as a viable model for the future: if we do things this way, it is unlikely
// that we will be able to have cool space ships zooming around the galaxy.
// But, the book's observation that the moon landing is pretty close to the Unix time,
// and the idea that maybe the moon landing was the actual time, probably helped
// generate the idea for the code in this file.

// */

// /*
// @Incomplete:
//     lerp
//     If it greatly facilitates calendar_to_apollo, add day_of_year_starting_at_0 to the struct (analogous to the Unix one), but then clarify which members are used for conversion and which can be left empty.
// */



// // We do not currently have 128-bit integers, and may never (?), so we are defining Apollo_Time
// // as a struct.

// // Apollo_Time represents a time in objective reality. It does not get adjusted based on what time zone
// // you're in. Adding and subtracting hours to Apollo_Time is not the right way to implement time zones,
// // and if you do this, you are inviting weird bugs and generally asking for trouble.
// // Time zones are not a property of time passing in objective reality; they are a choice we make
// // when we describe what time it is. We have another struct, Calendar_Time, that is meant to help
// // describe time in ways that humans find convenient. You can convert from Apollo_Time to Calendar_Time,
// // and when you do this, you can supply a time zone for the conversion.

// // The same goes for leap seconds and other calendar adjustments. These are not properties of time
// // passing in the physical world, so Apollo_Time does not know or care about them. Apollo_Time is very simple.
// // Leap seconds, day skips, and so forth, are aspects of Calendar_Time only.


// // Note, if we establish a more accurate time for the moon landing, then we may adjust the baseline time
// // during the beta. Anticipate that this might happen (of course it won't change by much!)

// // Eventually this will replace the stuff in modules/Time. Maybe this will become modules/Time?

// Apollo_Time :: #type,isa S128;

// // We reserve the maximum negative value of Apollo Time, which (in the regular
// // two's-complement way has no corresponding positive value), to be an invalid
// // time that you can use to represent a field that is unset:

// APOLLO_TIME_INVALID :: Apollo_Time.{0, 0x8000_0000_0000_0000};

// // We did not make this the default value of Apollo_Time, though, because it's
// // not totally clear that this is the best move. But maybe we should.


// // Here is some stuff for dealing with calendar times:


// Time_Zone :: enum u32 {
//     UTC   :: 0;
//     LOCAL :: 1;  // Whatever the system local time zone is.

//     // Maybe we will extend this with other fixed zones.
// }

// Calendar_Time :: struct {
//     year:        s32;
//     month\      _starting_at_0: s8;  // 0-11. Use as an index to a month name array, or add 1 to get the normal human-readable number.
//     day_of_month_starting_at_0: s8;  // 0-30. Add 1 to get the normal human-readable number.
//     day_of_week\_starting_at_0: s8;  // Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday.
//     hour:        s8;
//     minute:      s8;
//     second:      s8;
//     millisecond: s16;

//     time_zone: Time_Zone;
// }

// // Why are those members of Calendar_Time named verbosely with _starting_at_0?
// // Because on different OSs, these all have different conventions, that are inconsistent
// // not only with each other, but internally as well. We put the base of each variable
// // in the name so that you are reminded of this every time you use it, which will hopefully
// // make use of this kind of struct less error-prone.


// //
// // When it comes to asking what time it is right now, there are two basic functions
// // that are designed in an operating-system-specific way (so they are further down
// // in the file, in the OS-specific section). These are:
// //
// //     current_time_consensus() -> Apollo_Time
// //     current_time_monotonic() -> Apollo_Time
// //
// // This is because there are two different concepts of time that we need today in software,
// // and mixing them up leads to a lot of confusions and problems and bugs.
// //
// // The way things still work in 2022, your computer has an internal timer that it uses
// // to advance its own local concept of time in some mostly correct way. But
// // there are inaccuracies, so if you have a bunch of computers in the world, eventually
// // their idea of time will drift apart from each other due to compounded small errors.
// // So we synchronize times over the network; somewhere we have computers that we trust
// // more, and they tell us what time it really is, and if our local computer is off
// // by a little bit, we correct the error and move on.
// //
// // But this correction step means that if you want to know what time it is, according
// // to this consensus, then in rare cases it can skip forward, or even go backward.
// // That's not a very good thing if you are trying to run a realtime program that is
// // simulating forward a world, or some UI animation transitions, in sync with real time.
// // If that program asks what time it is on frame N, and then again on frame N+1, and
// // subtracts those times to know how much to simulate forward, and it gets a negative
// // result, this is very confusing and bad and it doesn't know what to do. (And even
// // when results are positive, they may jitter substantially with respect to realtime,
// // whenever corrections to the consensus time happen). This is why we have a thing
// // called monotonic time, which is guaranteed to never decrease (and in general to
// // increase as smoothly as possible relative to the average passage of time).
// //
// // So, if you want to get a time value that you wish to convert to a readable
// // calendar time that users can see, use current_time_consensus().
// //
// // If you want to get a time that you can use for simulation, use current_time_monotonic().
// //
// // Consensus time will make sense to a human when you call to_calendar() on it.
// // Monotonic time may or may not, depending on the implementation, so don't rely on that.
// // This suggests that we may want to have more typesafety on Apollo_Time, or maybe even
// // dedicate a bit to representing which of these we are talking about, to help you spot
// // errors. But that's not how it is right now, so, just look out for this.
// //


// ConvertToApollo :: (m: s64, FACTOR: s64) #expand {
//     result: Apollo_Time = ---;

//     #if CPU == .X64 { // Maybe ditch this and simply always use the Int128 routine?
//         #asm {
//             result_high: gpr === d;
//             result_low:  gpr === a;

//             mov result_low, FACTOR;
//             imul result_high, result_low, m;

//             mov [*result + 0], result_low;
//             mov [*result + 8], result_high;
//         }
//     } else {
//         result = cast(Apollo_Time)(to_s128(m) * FACTOR);
//     }

//     `return result;
// }

// seconds_to_apollo :: (m: s64) -> Apollo_Time {
//     // seconds are 10**0, Apollo_Time is 10**-15.
//     // So we multiply by 10**15.
//     ConvertToApollo(m, 1_000_000_000_000_000);
// }

// milliseconds_to_apollo :: (m: s64) -> Apollo_Time {
//     // milliseconds are 10**-3, Apollo_Time is 10**-15.
//     // So we multiply by 10**12.
//     ConvertToApollo(m, 1_000_000_000_000);
// }

// microseconds_to_apollo :: (m: s64) -> Apollo_Time {
//     // microseconds are 10**-6, Apollo_Time is 10**-15.
//     // So we multiply by 10**9.
//     ConvertToApollo(m, 1_000_000_000);
// }

// nanoseconds_to_apollo :: (m: s64) -> Apollo_Time {
//     // nanoseconds are 10**-9, Apollo_Time is 10**-15.
//     // So we multiply by 10**6.
//     ConvertToApollo(m, 1_000_000);
// }

// ConvertFromApollo :: inline (t: Apollo_Time, divisor: u64, $DO_ROUNDING: bool) -> (result: s64, success: bool) {
//     quotient, remainder, overflow := signed_divide_with_remainder(t, S128.{divisor, 0});

//     // The quotient may be too large to store in an s64: for valid values quotient.high will only be
//     // zero (positive result) or full (negative result); if it's anything else the value is extending
//     // into the high bits.
//     overflow ||= !(quotient.high == 0 || quotient.high == 0xffffffff_ffffffff);

//     // The low bits are already stored in two's-complement - we don't need to do anything to negate them!
//     // However, see later...
//     result := cast,no_check(s64) quotient.low;

//     // result is the output of integer division; that is, it is how many times divisor fits inside t.
//     // If divisor is not a factor of t then remainder will be > 0, and you can think of result as if it were
//     // real division truncated to the nearest integer toward 0: if t is positive then result will
//     // be lower than the exact real value, if t is negative then result will be greater than the exact real
//     // value. Therefor for rounding, when positive we are choosing either result or result+1, and for
//     // negative we are choosing either result or result-1.
//     #if DO_ROUNDING {
//         // remainder will be in range 0 to divisor-1; remainder and divisor are both positive!
//         // The decision we use to round is whether remainder is greater than divisor / 2; if it is then
//         // we need to change result to the value further away from 0.
//         // Note that because remainder < divisor (a u64), remainder.high is always 0 and we can ignore it.
//         half_divisor_floored := divisor / 2;
//         if t.high >= 0 {
//             // When t is positive we also want to round up when remainder is exactly half divisor
//             if remainder.low > half_divisor_floored
//             || divisor % 2 == 0 && remainder.low == half_divisor_floored
//                 result += 1;
//         } else {
//             // When t is negative the rouded-up value is the default, so we don't need to check for equality.
//             if remainder.low > half_divisor_floored
//                 result -= 1;
//         }
//     }

//     // ...It is possible for result to be wrong; we may have overflowed.  This is easy to detect because
//     // divisor is a u64 - always positive - so a valid result will always be the same sign as t.
//     // Therefor, if we have a sign difference between t and result we know we've overflowed.
//     overflow ||= result != 0 && ((t.high < 0) != (result < 0));

//     return result, !overflow;
// }

// // The following routines return success==true unless the Apollo_Time quantity
// // is too big to fit into 'result'.

// to_seconds :: (t: Apollo_Time, $DO_ROUNDING := false) -> (result: s64, success: bool) {
//     // seconds are 10**0, Apollo_Time is 10**-15.
//     // So we divide by 10**15.
//     result, success := ConvertFromApollo(t, 1_000_000_000_000_000, DO_ROUNDING);
//     return result, success;
// }

// to_milliseconds :: (t: Apollo_Time, $DO_ROUNDING := false) -> (result: s64, success: bool) {
//     // milliseconds are 10**-3, Apollo_Time is 10**-15.
//     // So we divide by 10**12.
//     result, success := ConvertFromApollo(t, 1_000_000_000_000, DO_ROUNDING);
//     return result, success;
// }

// to_microseconds :: (t: Apollo_Time, $DO_ROUNDING := false) -> (result: s64, success: bool) {
//     // microseconds are 10**-6, Apollo_Time is 10**-15.
//     // So we divide by 10**9.
//     result, success := ConvertFromApollo(t, 1_000_000_000, DO_ROUNDING);
//     return result, success;
// }

// to_nanoseconds :: (t: Apollo_Time, $DO_ROUNDING := false) -> (result: s64, success: bool) {
//     // nanoseconds are 10**-9, Apollo_Time is 10**-15.
//     // So we divide by 10**6.
//     result, success := ConvertFromApollo(t, 1_000_000, DO_ROUNDING);
//     return result, success;
// }


// calendar_to_string :: (ct: Calendar_Time) -> string /* Temporary_Storage */ {
//     // For now we just do English. We can explore how to internationalize this later,
//     // as well as provide different formats (numeric, wordy, abbreviated, etc).
//     // Probably once things get complicated like that, it should live in another file,
//     // and this here should just be about the numeric parts of the time.

//     month_names :: string.["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

//     month := ct.month_starting_at_0;
//     month = clamp(month, 0, 11);

//     month_name := month_names[month];

//     {
//         using ct;

//         Clock :: (x: Any) -> FormatInt {
//             return formatInt(x, minimum_digits=2);
//         }

//         time_string := tprint("% % %, %:%:%", day_of_month_starting_at_0+1, month_name, year, Clock(hour), Clock(minute), Clock(second));
//         return time_string;
//     }
// }

// calendar_to_iso_string :: (ct: Calendar_Time) -> string /* Temporary_Storage */ {
// 	using ct;

// 	date_part :: #bake_arguments formatInt(minimum_digits = 2);

// 	timezone_name := ifx ct.time_zone == .UTC then "Z" else ""; // @Incomplete: Maybe determine local time zone name or offset

// 	time_string := tprint("%-%-%T%:%:%.%0%", year, date_part(month_starting_at_0 + 1), date_part(day_of_month_starting_at_0 + 1), date_part(hour), date_part(minute), date_part(second), formatInt(millisecond, minimum_digits = 3), timezone_name);
// 	return time_string;
// }
// // #run {
// // 	time: Apollo_Time;
// // 	cal := to_calendar(time);
// // 	time_string := calendar_to_iso_string(cal);
// // 	assert(time_string == "1969-07-20T20:17:39.000Z", "Unexpected time string: %", time_string);
// // }


// compare_apollo_times :: (a: Apollo_Time, b: Apollo_Time) -> s32 {
//     // If you want to pass this to a two-op compare function.
//     // Probably we should fix some stuff about this language so you don't need this?

//     if a < b   return -1;
//     if a == b  return 0;
//     return 1;
// }

// to_float64_seconds :: (input: Apollo_Time) -> (result: float64, success: bool) {
//     // @Incomplete @Robustness:
//     // Not sure what the best strategy is here. We probably should manually convert,
//     // like we do in to_apollo(), but
//     // as an intermediate low-effort thing I am going to convert each word separately to
//     // float64 and then add them.

//     a := input;
//     if input.high < 0  a = -a;  // Do this on a positive number and re-negate at the end.

//     seconds, success := to_seconds(a, DO_ROUNDING=false); // @Robustness: Note that our 'seconds' is signed which means we are missing 1 bit of range.
//     if !success return 0, false;

//     f := cast(float64) seconds;

//     b := seconds_to_apollo(seconds);
//     femto := a - b;

//     assert(femto.high == 0);  // This requires the result of to_seconds not to be rounded.
//     f_femto := femto.low / cast(float64)FEMTOSECONDS;

//     f += f_femto;

//     if input.high < 0  f = -f;
//     return f, true;
// }

// to_apollo :: (seconds: float64) -> Apollo_Time {
//     MANTISSA_BITS   :: 52;
//     SIGN_BIT        :: 0x8000_0000_0000_0000;
//     EXPONENT_MASK   :: 0x7ff0_0000_0000_0000;

//     i64 := << cast(*u64) *seconds;
//     exponent := cast(s16)((i64 & EXPONENT_MASK) >> 52);
//     exponent -= 1023;
//     exponent -= MANTISSA_BITS;  // Not treating this as a decimal, just an integer.

//     MANTISSA_HIGH_BIT :: 1 << MANTISSA_BITS;
//     mantissa := (i64 & (MANTISSA_HIGH_BIT-1)) | MANTISSA_HIGH_BIT;

//     if !mantissa {
//         a: Apollo_Time;
//         return a;  // Zero.
//     }

//     a := seconds_to_apollo(xx mantissa);  // In the current format, seconds start in the low word, so we know we have more than the mantissa size available.

//     shift := exponent;
//     if shift < 0 {
//         shift = -shift;
//         if shift > 255 return .{};

//         a >>= cast(u8)(shift);
//     } else if shift {
//         if shift > 255 return .{};
//         a <<= cast(u8) shift;
//     }

//     return a;
// }

// //
// // Windows stuff:
// //

// #if OS == .WINDOWS {
//     #scope_file;

//     // Instead of importing Windows, we could just locally define the small set
//     // of bindings here that we actually use. Maybe a good project would be to provide
//     // a Windows module that is divided into little pieces of what you might
//     // commonly use.
//     W :: #import "Windows";
//     FILETIME :: W.FILETIME;

//     // You can compute filetime_apollo by uncommenting and calling get_apollo_moon_landing_windows_filetime().
//     filetime_apollo :: FILETIME.{QuadPart=0x19d_30e0_99a4_7380};

//     // And this is computed by get_january_1_1601_apollo_time():
//     apollo_filetime :: Apollo_Time.{12544592398102855680, -630480};

//     // FILETIME is in 100-nanosecond increments, i.e. 10**-7.
//     // Apollo_Time is 10**-15.
//     // So we multiply by 10**8.
//     FILETIME_FACTOR :: 100_000_000;

//     #scope_export;

//     current_time_consensus :: () -> Apollo_Time {
//         ft_now: FILETIME;
//         W.GetSystemTimePreciseAsFileTime(*ft_now);

//         apollo := filetime_to_apollo(ft_now);
//         return apollo;
//     }

//     current_time_monotonic :: () -> Apollo_Time {
//         pc, freq: s64;

//         // In principle QPC/QPF can fail, in that they return 'success',
//         // but in reality they don't. We don't want to dirty our API by
//         // passing this success code upward. Maybe this is a mistake,
//         // but causing all user programs to worry about what happens if they
//         // can't get a monotonic time seems weird and friction-inducing.
//         // If we get false back, we could fail over to rdtscp or something.

//         success := W.QueryPerformanceCounter(*pc);

//         // We could try to cache the frequency somewhere, but
//         // it seems like this may be slower than asking for it again,
//         // in a multithreaded environment. Hard to say. Should ask around.
//         //           -jblow, 9 March 2022.

//         success  = W.QueryPerformanceFrequency(*freq);

//         a: Apollo_Time;
//         a.low = cast,no_check(u64)pc;

//         a *= FEMTOSECONDS;
//         a /= freq;

//         return a;
//     }

//     filetime_to_apollo :: (ft: FILETIME) -> Apollo_Time {
//         FILETIME_FACTOR :: 100_000_000;

//         a: Apollo_Time = ---;
//         a.low  = ft.QuadPart;
//         a.high = 0;

//         a *= FILETIME_FACTOR;
//         a += apollo_filetime;

//         return a;
//     }

//     to_filetime :: (at: Apollo_Time) -> (ft: FILETIME, success: bool) {
//         result, success := ConvertFromApollo(at, FILETIME_FACTOR, true);

//         result1 := cast(u64) result;
//         result += xx filetime_apollo.QuadPart;

//         // @Incomplete: Check for overflow results due to the filetime_apollo add?

//         ft: FILETIME = ---;
//         ft.QuadPart = cast(u64) result;
//         return ft, success;
//     }

//     to_calendar :: (at: Apollo_Time, time_zone := Time_Zone.UTC) -> Calendar_Time {
//         // :OSSpecific
//         // @Incomplete: We would like to do this via our own code
//         // that is cross-platform and guaranteed to be the same everywhere,
//         // etc, but for now we are falling back
//         // on OS-specific routines in order to get things going.
//         // Since our own routine probably will not have failure modes (?), we are not for now
//         // trying to detect and return failure.

//         ft, success := to_filetime(at);
//         if !success log("Error: Input Apollo_Time was out of range when calling to_calendar(). We are not putting failure into the API though, because long-term in an OS-independent scenario we should not have this kind of failure case, maybe.\n");

//         if time_zone == .LOCAL {
//             ft_local: FILETIME;
//             success := W.FileTimeToLocalFileTime(*ft, *ft_local);
//             assert(success != .FALSE);
//             if success ft = ft_local;
//         }

//         st: W.SYSTEMTIME;
//         st_success := W.FileTimeToSystemTime(*ft, *st);
//         assert(st_success != .FALSE);  // Under what conditions does this fail?  @Incomplete @Robustness.

//         ct: Calendar_Time;
//         ct.year = st.wYear;
//         ct.month_starting_at_0 = cast,trunc(s8) Max(0, st.wMonth - 1);  // @Temporary: Guarding against fails and getting a 0 back for st.wMonth then returning a negative number.
//         ct.day_of_month_starting_at_0 = cast,trunc(s8) Max(0, st.wDay-1);  // @Temporary
//         ct.day_of_week_starting_at_0 = cast,trunc(s8) st.wDayOfWeek;
//         ct.hour   = cast,trunc(s8) st.wHour;
//         ct.minute = cast,trunc(s8) st.wMinute;
//         ct.second = cast,trunc(s8) st.wSecond;
//         ct.millisecond = cast,trunc(s16) st.wMilliseconds;

//         ct.time_zone = time_zone;

//         return ct;
//     }

//     calendar_to_apollo :: (ct: Calendar_Time) -> Apollo_Time {
//         // @Incomplete.  See :OSSpecific
//         result: Apollo_Time = ---;

//         st: W.SYSTEMTIME;
//         st.wYear      = xx,trunc ct.year;
//         st.wMonth     = xx,trunc (ct.month\      _starting_at_0 + 1);
//         st.wDay       = xx,trunc (ct.day_of_month_starting_at_0 + 1);
//         st.wDayOfWeek = xx,trunc ct .day_of_week\_starting_at_0;
//         st.wHour      = xx,trunc ct.hour;
//         st.wMinute    = xx,trunc ct.minute;
//         st.wSecond    = xx,trunc ct.second;
//         st.wMilliseconds = xx,trunc ct.millisecond;

//         ft: FILETIME;
//         success := W.SystemTimeToFileTime(*st, *ft);
//         assert(success != .FALSE);  // @Temporary

//         if ct.time_zone == .LOCAL {
//             ft_local: FILETIME;
//             success := W.LocalFileTimeToFileTime(*ft, *ft_local);
//             if success ft = ft_local;
//             assert(success != .FALSE);
//         }

//         apollo := filetime_to_apollo(ft);
//         return apollo;
//     }

//     /*
//     get_apollo_moon_landing_windows_filetime :: () -> FILETIME {
//         st_apollo: SYSTEMTIME;
//         {
//             // Sunday July 20, 1969 at 20:17:39 UTC.  (Wikipedia says :40, other sources say :39).

//             using st_apollo;
//             wYear      = 1969;
//             wMonth     = 7;      // July. Months in Windows SYSTEMTIME start at 1 even though wDayOfWeek starts at 0. Go figure.
//             wDayOfWeek = 0;      // Sunday. Probably not necessary?
//             wDay       = 20;     // wDay starts at 1.
//             wHour      = 20;     // wHour starts at 0.
//             wMinute    = 17;
//             wSecond    = 39;
//             wMilliseconds = 0;   // We don't have a more accurate number for this.
//         }

//         ft_apollo: FILETIME;
//         success := SystemTimeToFileTime(*st_apollo, *ft_apollo);
//         assert(success != .FALSE);

//         return ft_apollo;
//     }

//     get_january_1_1601_apollo_time :: () -> Apollo_Time {
//         ft0: FILETIME;
//         ft0a := filetime_to_apollo(ft0);

//         ca := to_calendar(ft0a); // Print this just to double-check.
//         print("ca: %\n", ca);

//         return ft0a;
//     }
//     */
// } else #if (OS == .LINUX || OS == .MACOS || OS == .ANDROID) {
//     #scope_file;

//     #import "POSIX";


//     libc :: #system_library "libc";
//     timelocal :: (timeptr: *tm) -> time_t #foreign libc;
//     timegm    :: (timeptr: *tm) -> time_t #foreign libc;

//     #scope_export;

//     current_time_consensus :: () -> Apollo_Time {
//         ts: timespec;
//         clock_gettime(.REALTIME, *ts);

//         apollo := timespec_to_apollo(ts);
//         return apollo;
//     }

//     current_time_monotonic :: () -> Apollo_Time {
//         ts: timespec;
//         clock_gettime(.MONOTONIC_RAW, *ts);

//         apollo := timespec_to_apollo(ts);
//         return apollo;
//     }

//     timespec_to_apollo :: (ts: timespec) -> Apollo_Time {
//         a_seconds     :=     seconds_to_apollo(ts.tv_sec);
//         a_nanoseconds := nanoseconds_to_apollo(ts.tv_nsec);

//         apollo := a_seconds + a_nanoseconds + APOLLO_TIME_FOR_JAN_1_1970;
//         return apollo;
//     }

//     to_timespec :: (at: Apollo_Time) -> (ts: timespec, success: bool) {
//         a := at - APOLLO_TIME_FOR_JAN_1_1970;

//         seconds: s64 = ---;

//         divided := a / FEMTOSECONDS;
//         if divided.high == 0 {
//             // We have a small enough number of seconds to fit into 64 bits.
//             // But we actually want 63 bits, so check the high bit of 'low'.
//             if divided.low & 0x8000_0000_0000_0000 {
//                 return .{}, false; // Out of range.
//             } else {
//                 seconds = cast(s64) divided.low;
//             }
//         } else if divided.high == -1 {
//             // This is a negative number with all the information in the low bits, so that's fine.
//             seconds = cast,no_check(s64) divided.low;
//         } else {
//             // There's information in the high bits, i.e. the result number of seconds
//             // is too big for the timespec range. Return false.

//             return .{}, false;
//         }

//         a_seconds := seconds_to_apollo(seconds);

//         a_femtoseconds := a - a_seconds;
//         assert(a_femtoseconds.high == 0);

//         nanoseconds: s64 = (cast(s64) a_femtoseconds.low + 500_000) / 1_000_000;  // The number of femtoseconds in 1 second cannot be high enough such that the sign bit would be set after the cast.

//         ts: timespec = ---;
//         ts.tv_sec  = xx,trunc seconds;
//         ts.tv_nsec = xx,trunc nanoseconds;

//         if seconds < 0 return ts, false;  // timespec does not go negative.
//         return ts, true;
//     }

//     to_calendar :: (at: Apollo_Time, time_zone := Time_Zone.UTC) -> Calendar_Time {
//         // :OSSpecific  @Incomplete
//         // Not returning a success code for the same reason as in the Windows version.
//         // (Read that comment to see.)

//         ts, success := to_timespec(at);
//         if !success {
//             log("Error: Input Apollo_Time was out of range when calling to_calendar(). We are not putting failure into the API though, because long-term in an OS-independent scenario we should not have this kind of failure case, maybe.\n");
//             return .{};
//         }


//         NANO_TO_MILLI_FACTOR :: 1_000_000;
//         milliseconds := cast,trunc(s16)((ts.tv_nsec + NANO_TO_MILLI_FACTOR/2) / NANO_TO_MILLI_FACTOR);
//         if milliseconds >= 1000 {
//             // The rounding above may have given us a result
//             // of 1000 milliseconds, which would be incorrect to return! So we need to add to
//             // the seconds, but we must do this *before* converting from timespec, because if
//             // we do it after, then we maybe have to increment minutes, hours, etc, which
//             // would be a big mess.

//             assert(milliseconds == 1000);
//             milliseconds = 0;
//             ts.tv_sec += 1;
//         }


//         // Wow, what a garbage. There almost certainly is a better way of doing this
//         // but I couldn't figure it out from browsing the Web because nobody there knows either.
//         tmp: tm;
//         if time_zone == .LOCAL {
//             tmp = localtime_r(*ts.tv_sec, *tmp);
//         } else {
//             tmp = gmtime_r(*ts.tv_sec, *tmp);
//         }

//         ct: Calendar_Time;
//         ct.year = tmp.tm_year + 1900;
//         ct.month_starting_at_0        = xx,trunc tmp.tm_mon;
//         ct.day_of_month_starting_at_0 = xx,trunc Max(0, tmp.tm_mday-1);  // @Temporary
//         ct.day_of_week_starting_at_0  = cast,trunc(s8) tmp.tm_wday;
//         ct.hour   = xx,trunc tmp.tm_hour;
//         ct.minute = xx,trunc tmp.tm_min;
//         ct.second = xx,trunc tmp.tm_sec;
//         ct.millisecond = milliseconds;

//         ct.time_zone = time_zone;

//         return ct;
//     }

//     calendar_to_apollo :: (ct: Calendar_Time) -> Apollo_Time {
//         // @Incomplete.  See :OSSpecific

//         using parts: tm;
//         tm_year = ct.year - 1900;
//         tm_mon  = ct.month_starting_at_0;
//         tm_mday = ct.day_of_month_starting_at_0 + 1;
//         tm_hour = ct.hour;
//         tm_min  = ct.minute;
//         tm_sec  = ct.second;
//         tm_isdst = -1;

//         time_t_sec: time_t;
//         if #complete ct.time_zone == {
//             case .LOCAL;
//                 time_t_sec = timelocal(*parts);
//             case .UTC;
//                 time_t_sec = timegm(*parts);
//         }

//         if time_t_sec == -1	    return .{};

//         a_seconds      :=      seconds_to_apollo(time_t_sec);
//         a_milliseconds := milliseconds_to_apollo(ct.millisecond);
//         result := a_seconds + a_milliseconds + APOLLO_TIME_FOR_JAN_1_1970;

//         return result;
//     }

//     /*
//     get_apollo_moon_landing_time_on_january_1_1970_for_unix :: () -> Apollo_Time {
//         c1970: Calendar_Time;
//         c1970.year      = 1970;
//         c1970.time_zone = .UTC;

//         a1970 := calendar_to_apollo(c1970);
//         // print("a1970: %\n", a1970);

//         return a1970;
//     }
//     */
// }

// APOLLO_TIME_FOR_JAN_1_1970 :: Apollo_Time.{low=0xdbd87f0edb7c8000, high=0x300}; // For easy conversions from/to Unix timestamps


// FEMTOSECONDS :: 1_000_000_000_000_000;
