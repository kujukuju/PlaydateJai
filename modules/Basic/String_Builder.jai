//
// String_Builder guarantees that buffers do not move after they have
// been allocated. Thus you can take pointers to positions inside the
// builder and know they have not changed.
//

//
// As of now, you need to call free_buffers manually to
// release the String_Builder. But, almost everyone calls
// builder_to_string(), so how about if we make that free
// the buffers and reset afterward, unless you tell it not to?
//
//       -jblow, 19 July 2019
//

//
// You can copy the String_Builder by value and the copy will
// function just fine. (But it will also own any extra buffers that
// were allocated, so, make sure to forget about the old copy!)
//

STRING_BUILDER_BUFFER_SIZE :: 4096 - size_of(String_Builder.Buffer);

String_Builder :: struct {
    Buffer :: struct {
        count:     s64;
        //
        // The data pointer is implicit and points to the memory after the buffer itself
        // (see "get_buffer_data()"). Otherwise we wouldn't be able to copy the String_Builder
        // without having to adjust pointers.
        //
        // We could also use a relative pointer, but since it will always point after buffer,
        // there's no need to store it explicitly.              -rluba, 2021-12-15
        //
        allocated: s64;

        #if ENABLE_ASSERT  ensured_count: s64;  // Used for error-checking on ensure_contiguous_space.
        next:      *Buffer;
    }

    initialized            := false;
    failed                 := false;  // If we ever fail to allocate enough memory, this gets set to true ... we can't be sure the entire string has been added.
    subsequent_buffer_size := -1;

    allocator:             Allocator;

    current_buffer:        *Buffer;  // if current_buffer == null, it means use initial_bytes as a base buffer. We don't point it at initial_bytes, so that you can copy a String_Builder in memory and it's still valid.
    initial_bytes:         [STRING_BUILDER_BUFFER_SIZE] u8; // We don't dynamically allocate if we only need one buffer's worth of data.
}

init_string_builder :: (using builder: *String_Builder, buffer_size := -1) {
    if (!allocator.proc) {
        allocator = context.allocator;
    }

    subsequent_buffer_size = ifx buffer_size > 0 then buffer_size else STRING_BUILDER_BUFFER_SIZE;

    base_buffer := get_base_buffer(builder);
    base_buffer.count = 0;
    base_buffer.allocated = initial_bytes.count - size_of(Buffer);
    base_buffer.next = null;

    current_buffer = null;
    initialized = true;
}

free_buffers :: (using builder: *String_Builder) {  // free_buffers will be deprecated pretty soon, and the only entry point to resetting a String_Builder will be reset().  -jblow, 1 June 2022
    base_buffer := get_base_buffer(builder);
    buffer := base_buffer.next;
    while buffer {
        next := buffer.next;
        free(buffer,, allocator=allocator);
        buffer = next;
    }

    base_buffer.next = null; // Just in case we call this twice.
}

reset :: (using builder: *String_Builder) {
    free_buffers(builder);

    base_buffer := get_base_buffer(builder);
    base_buffer.count = 0;
    current_buffer    = null;
}

ensure_contiguous_space :: (using builder: *String_Builder, bytes: s64) -> pointer: *void { // 'pointer' points to the base of the space, or is null if we failed.
    available := ensure_contiguous_space_and_return_available_range(builder, bytes);
    if !available.count then return null;

    #if ENABLE_ASSERT {
        buffer := get_current_buffer(builder);
        buffer.ensured_count = buffer.count + bytes;
    }

    return available.data;
}

ensure_contiguous_space_and_return_available_range :: (using builder: *String_Builder, minimum_bytes := 1) -> [] u8 {
    if !initialized init_string_builder(builder);

    buffer := get_current_buffer(builder);
    if minimum_bytes > buffer.allocated then return .[];  // Nothing we can do there, bro; it's bigger than our buffers!

    available := buffer.allocated - buffer.count;
    if available < minimum_bytes {
        success := expand(builder);
        if !success then return .[];
        buffer = get_current_buffer(builder);
    }

    #if ENABLE_ASSERT buffer.ensured_count = buffer.allocated;

    result: [] u8;
    result.data = get_buffer_data(buffer) + buffer.count;
    result.count = buffer.allocated - buffer.count;
    return result;
}

advance_through_ensured_space :: (using builder: *String_Builder, bytes: s64) {
    // If you ensure space and use the pointer you get back, you might write data
    // directly into that pointer, but then want to advance it without packing stuff
    // manually into the builder. That's what this is for.

    buffer := get_current_buffer(builder);

    length_max := buffer.allocated - buffer.count;
    assert(length_max >= bytes);

    // In order to check whether you didn't use ensure_contiguous_space wrong, we
    // don't only check whether you happen to have enough space in the buffer
    // (above), but we check whether you guaranteed the space correctly, which
    // doesn't depend on chance of where we are in the buffer.
    #if ENABLE_ASSERT assert(buffer.count + bytes <= buffer.ensured_count);
    buffer.count += bytes;

    assert(initialized); // There
}

append :: (using builder: *String_Builder, s: *u8, length: s64) {
    if !initialized init_string_builder(builder);

    while length > 0 {
        buffer := get_current_buffer(builder);

        length_max := buffer.allocated - buffer.count;
        if length_max <= 0 {
            success := expand(builder);
            if !success {
                failed = true;
                return;
            }

            // expand() changes current_buffer, so let's reacquire!
            buffer = current_buffer;
            assert(buffer != null);

            length_max = buffer.allocated - buffer.count;  // Avoid a recursion doing no work that would happen if we left length_max == 0. (It should never be < 0 unless something very bad has happened).
            assert(length_max > 0);
        }

        to_copy := min(length, length_max);
        if length > 0  assert(to_copy >= 0);

        memcpy(get_buffer_data(buffer) + buffer.count, s, to_copy);

        buffer.count += to_copy;

        length -= to_copy;
        s      += to_copy;
    }
}

append :: inline (builder: *String_Builder, s: string) {
    append(builder, s.data, s.count);
}

append :: inline (builder: *String_Builder, byte: u8) {
    local_byte := byte;  // So we can take the address, yay.
    append(builder, *local_byte, 1);
}

append_by_pointer :: inline (builder: *String_Builder, pointer: *$T) {
    append(builder, cast(*u8) pointer, size_of(T));
}


builder_string_length :: (using builder: *String_Builder) -> int {
    if !allocator.proc  return 0;

    buffer := get_base_buffer(builder);
    bytes  := 0;
    while buffer {
        bytes  += buffer.count;
        buffer  = buffer.next;
    }

    return bytes;
}

builder_to_string :: (builder: *String_Builder, extra_bytes_to_prepend := 0, do_reset := true) -> string {
    // 'extra_bytes_to_prepend' gives you extra space at the beginning, so you can
    // do something like put in a length that you didn't know when you were
    // writing out the data. This may not be worth the extra complexity, though;
    // for heavier-duty use you probably want something like the String_Builder bucket stealing
    // that is in the compiler's source but hasn't yet made it into this port yet.
    //        -jblow, 30 September 2020

    if !builder.initialized init_string_builder(builder);

    count := builder_string_length(builder);
    if !count && !extra_bytes_to_prepend {
        return "";
    }

    result: string = ---;
    result.data  = alloc(count + extra_bytes_to_prepend);
    result.count = count + extra_bytes_to_prepend;

    data := result.data + extra_bytes_to_prepend;
    buffer := get_base_buffer(builder);
    while buffer {
        memcpy(data, get_buffer_data(buffer), buffer.count);
        data += buffer.count;

        buffer = buffer.next;
    }

    if do_reset reset(builder);  // @Speed: Could free buffers inline with the bucket traversal above. Code would be less clear.

    return result;
}

write_builder :: (using builder: *String_Builder, do_reset := true, to_standard_error := false) -> s64 {
    //
    // Future expanded functionality: We can make a macro
    // that calls its argument code with a string representing
    // the contents of each bucket. Then you can do whatever
    // operation you want.
    //              -jblow, 19 July 2019
    //

    if !allocator.proc return 0;

    buffer  := get_base_buffer(builder);
    written := 0;
    while buffer {
        s: string = ---;
        s.data  = get_buffer_data(buffer);
        s.count = buffer.count;

        write_string(s, to_standard_error);
        written += s.count;

        buffer = buffer.next;
    }

    if do_reset reset(builder);

    return written;
}

consume_u8_and_length :: (input: *string, s: *u8, length: s64) -> bool {  // Looks a lot like append_u8_and_length.
    if length <  0 return false;  // Error!
    if length > input.count return false;  // Error!
    if length == 0 return true;

    memcpy(s, input.data, length);

    input.count -= length;
    input.data  += length;

    return true;
}

get_current_buffer :: inline (using builder: *String_Builder) -> *String_Builder.Buffer {
    if current_buffer return current_buffer;

    assert(builder.allocator.proc != null);
    return get_base_buffer(builder);
}

get_base_buffer :: inline (using builder: *String_Builder) -> *String_Builder.Buffer {
    return cast(*Buffer) initial_bytes.data;
}

get_buffer_data :: inline (using buffer: *String_Builder.Buffer) -> *u8 {
    return (cast (*u8) buffer) + size_of(String_Builder.Buffer);
}

simple_memcpy :: inline (using builder: *String_Builder, x: $T) {
    // Don't call this unless you know the buffer has been initialized and there is enough space in the current buffer!
    // Otherwise you will corrupt memory and be sad.
    // This is included here just as a utility routine you can call
    // when writing serializers and whatnot.
    using buffer := get_current_buffer(builder);
    assert(size_of(T) <= allocated - count);
    memcpy(get_buffer_data(buffer) + count, *x, size_of(T));
    count += size_of(T);
}

expand :: (using builder: *String_Builder) -> bool {
    assert (allocator.proc != null); // This is initialized in init_string_builder.

    subsequent := ifx subsequent_buffer_size > 0 then subsequent_buffer_size else STRING_BUILDER_BUFFER_SIZE;

    bytes := cast(*u8) alloc(size_of(Buffer) + subsequent,, allocator);
    if !bytes return false;  // Failed!

    buffer := cast(*Buffer) bytes;

    buffer.next      = null;
    buffer.count     = 0;
    buffer.allocated = subsequent;

    old_buffer := get_current_buffer(builder);
    old_buffer.next = buffer;

    current_buffer = buffer;

    return true;
}

// Move all data from "steal_from" to "builder", taking ownership of all dynamically allocated buffers in the process.
append_and_steal_buffers :: (builder: *String_Builder, steal_from: *String_Builder) {
    buffer := get_base_buffer(steal_from);
    if !buffer.count return;

    // We need to copy the base buffer because it’s part of the other builder’s struct
    // so we can’t take ownership of it:
    append(builder, get_buffer_data(buffer), buffer.count);

    assert(builder.allocator.proc == steal_from.allocator.proc);
    assert(builder.allocator.data == steal_from.allocator.data);

    // Take ownership of the rest of the buffer chain:
    our_end := get_current_buffer(builder);
    our_end.next = buffer.next;
    // Reset the victim’s base buffer
    buffer.count = 0;
    buffer.next = null;
    if steal_from.current_buffer {
        builder.current_buffer = steal_from.current_buffer; // Use the victim’s final buffer as our current buffer.
        steal_from.current_buffer = null; // Reset the victim to use the base buffer again
    }
}

