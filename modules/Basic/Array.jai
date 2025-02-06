/*

  Because arrays are built-in types in this language, for people
  to have high morale when using them, things need to be very clear.

  The set of basic operations included here, that most programs are
  expected to use, should be simple and small. People should be able
  to read this file and have no questions. They should know exactly
  what is going to happen when they use one of these arrays in their
  program.

  Simplicity is always good, but it is ***CRITICAL*** in this file,
  because without it, people will just stumble through life not really
  knowing what their code does, or even what it is trying to do --
  just like most modern programming languages. We want to avoid that.

  This is not meant to contain anything people might just want to do
  with arrays. It's supposed to be a minimal and clear set of
  functions that let you do the most universal things.

  Please don't add new things to this file without checking with me.

              -jblow, 20 July 2019

 */

/*

    These routines operate on [] and [..] arrays.
    These two kinds of arrays are straightforwardly defined, and are
    equivalent to small structs. You can look in modules/Preload.jai
    for the declarations: [] is equivalent to Array_View_64,
    and [..] is equivalent to Resizable_Array.

*/

// Now that we have namespacing, we can consider removing the array_ prefixes here.
// Maybe we want better renamers before we consider that too seriously, though.

array_copy :: (array: [] $T) -> [] T {
    dest := NewArray(array.count, T, initialized=false);
    memcpy(dest.data, array.data, array.count * size_of(T));
    return dest;
}

// This seems unnecessary. A couple people use it, but ... bleah.
array_copy :: (dest: *[..] $T, source: [] T) {
    array_reserve_(xx dest, source.count, size_of(T));
    memcpy(dest.data, source.data, source.count * size_of(T));
    dest.count = source.count;
}

array_view :: inline (array: [] $T, index: int) -> [] T {
    return array_view(array, index, array.count - index);
}

array_view :: inline (array: [] $T, index: int, count: int) -> [] T {
    assert(index >= 0, "index = %", index);             // @@ Should we also clamp in these cases?
    assert(count >= 0, "count = %", count);
    if index >= array.count {
		return .[];
	}

    if index + count > array.count {
        count = array.count - index;
    }

	result: [] T = ---;
    result.data = array.data + index;
    result.count = count;
    return result;
}

array_free :: inline (array: [] $T) {
    free(array.data);
}

// @@ IC: Note that table_reset doesn't free memory, and it's confusing that array_reset does. For dynamic arrays we have array_reset and array_reset_keeping_memory, which is verbose, and as long as you
// are aware of the second function, the behavior is clear, but maybe it should be the other way around. array_reset doesn't free memory, while array_reset_and_free does. Or maybe we could follow
// STL's convention and use the term 'clear' for removing elements without freeing memory. So we would have:
// Static array:    array_reset
// Dynamic array:   array_clear, array_reset
// Table:           table_clear, table_reset
array_reset :: (array: *[] $T) {
    free(array.data);
    array.count = 0;
    array.data = null;
}

//
// Adding things to an array:
//
array_add :: (array: *[..] $T, item: T) #no_abc {
    maybe_grow(array);
    array.data[array.count] = item;  // Note, we don't have an ABC here since we believe maybe_grow does the right thing.
    array.count += 1;
}

array_add :: (array: *[..] $T, to_append: ..T) {  // Multi-argument version. Single-argument will be chosen in overload resolution for appropriate cases!
    old_count := array.count;
    array_reserve_(xx array, old_count + to_append.count, size_of(T));
    memcpy(array.data + old_count, to_append.data, to_append.count * size_of(T));
    array.count += to_append.count;
}

array_add :: (array: *[..] $T) -> *T #must {
    maybe_grow(array);
    result := *array.data[array.count];

    ini :: initializer_of(T);
    #if ini {
        ini(result);
    } else {
        memset(result, 0, size_of(T));
    }

    array.count += 1;
    return result;
}

array_add_if_unique :: (array: *[..] $T, item: T) -> bool, s64 {   // Return true if newly added; also return index.
    found, index := array_find(<<array, item);
    if found return false, index;

    array_add(array, item);
    return true, array.count-1;
}

array_insert_at :: (array: *[..] $T, item: T, index: int) {
    assert(index >= 0);
    assert(index <= array.count);

    maybe_grow(array);

    array.count += 1;

    i := array.count-1;
    while i > index {
        array.data[i] = array.data[i-1];
        i -= 1;
    }

    array.data[index] = item;
}

//
// Removing things:
//

array_unordered_remove_by_value :: inline (array: *[] $T, item: T, $stop_after_first := false) -> s64 {
    // Probably want to say something to debug memory trackers here.
    // Need to make sure it doesn't cost anything in Release.
    removed := 0;
    for array.*  if it == item {
        removed += 1;
        remove it;

        #if stop_after_first  break;   // Early-out optimization.
    }

    return removed;
}

array_unordered_remove_by_index :: inline (array_pointer: *[] $T, index: s64) {
    assert(index >= 0);
    assert(index < array_pointer.count);

    array := array_pointer.*;
    last_index := array_pointer.count - 1;
    if index != last_index  array[index] = array[last_index];

    array_pointer.count -= 1;
}

// array_ordered_remove_by_value removes the first occurrence only.
// We could consider having array_ordered_remove_all_by_value as well.
array_ordered_remove_by_value :: inline (array_pointer: *[] $T, item: T) -> bool {
    found, index := array_find(<<array_pointer, item);
    if found array_ordered_remove_by_index(array_pointer, index);
    return found;
}

array_ordered_remove_by_index :: inline (array_pointer: *[] $T, index: s64) {
    assert(index >= 0);
    assert(index < array_pointer.count);

    array := <<array_pointer;

    for i : index..array.count-2
        array[i] = array[i+1];

    array_pointer.count -= 1;
}

array_find :: (array: [] $T, item: T) -> bool, s64 {
    for array if it == item return true, it_index;
    return false, -1;  // Not found.
}

//
// Treating an array like a stack:
//
peek :: inline (array: [] $T) -> T {
    return array[array.count-1];
}

peek_pointer :: inline (array: [] $T) -> *T {
    return *array[array.count-1];
}

pop :: (array: *[] $T) -> T {
    // If we weren't worried about tripping an array bounds check, we wouldn't have to use
    // this temporary copy of 'result', but possibly a future change in the way we
    // return values may make it not matter.
    result := (<< array)[array.count-1];
    array.count -= 1;
    return result;
}



//
// Managing array memory:
//

array_free :: (array: [..] $T) {
    free(array.data,, array.allocator);
}

array_reset :: (array: *[..] $T) {
    free(array.data,, array.allocator);

    array.data      = null;
    array.allocated = 0;
    array.count     = 0;
}

array_reset_keeping_memory :: inline (array: *[..] $T) {
    array.count = 0;
}

array_reserve :: inline (array: *[..] $T, desired_items: s64) {
    array_reserve_(xx array, desired_items, size_of(T));
}

array_reserve :: inline (array: *Resizable_Array, desired_items: s64, element_size: s64) {
    array_reserve_(xx array, desired_items, element_size);
}

//
// The following two routines are not part of the basic [..] operation above.
// They are here for end-user convenience.
//
array_resize :: (array: *[] $T, new_count: s64, $initialize:=true) {
    old_count := array.count;
    if old_count == new_count return;
    array.data = cast(*T) realloc(array.data, new_count * size_of(T), array.count * size_of(T));
    array.count = new_count;

    #if initialize  init_range(array.data, old_count, new_count);
}

array_resize :: (array: *[..] $T, new_count: s64, $initialize:=true) {
    old_count := array.count;
    array_reserve_(xx array, new_count, size_of(T));
    array.count = new_count;

    #if initialize  init_range(array.data, old_count, new_count);
}

maybe_grow :: inline (array: *[..] $T) {
    if array.count >= array.allocated {
        reserve := 2 * array.allocated;
        if reserve < 8  reserve = 8;

        array_reserve_(xx array, reserve, size_of(T));
    }
}

maybe_grow :: (array: *Resizable_Array, element_size: s64) {
	if array.count >= array.allocated {
		reserve := 2 * array.allocated;
		if reserve < 8  reserve = 8;

        array_reserve_(xx array, reserve, element_size);
	}
}

array_swap :: (array_a : *[..] $T, array_b : *[..] T) {
    assert(array_a.allocator.proc == array_b.allocator.proc); // don't swap arrays with different allocators.
    b_count := array_b.count;
    b_data := array_b.data;
    b_allocated := array_b.allocated;

    array_b.count = array_a.count;
    array_b.data = array_a.data;
    array_b.allocated = array_a.allocated;

    array_a.count = b_count;
    array_a.data = b_data;
    array_a.allocated = b_allocated;

}

#scope_file

init_range :: (ptr: *$T, begin: s64, end: s64) {
    ini :: initializer_of(T);
    #if ini {
        for begin..end-1  inline ini(ptr + it);  // Really this can be one ini followed by a bunch of memcpy. For long arrays we could power-of-two double the copy out, etc.
    } else {
        count := end - begin;
        if count <= 0  return;

        // Fast path for init to zero.
        // In the case that we are shrinking an array, count will be negative.
        memset(ptr + begin, 0, count * size_of(T));
    }
}


// array_reserve_ is here for our own internal use, so we can prevent
// too much code bloat by allowing all arrays to use the same rellocate routine;
// when a leaf like this has many more polymorphs than necessary (due to the size_of(T)
// in vanilla array_reserve() being a constant), it causes everyone up the chain to
// have more polymorphs than necessary, because they need to call different leaves!
array_reserve_ :: (array: *[..] *void, desired_items: s64, size: s64) {
    if desired_items <= array.allocated return;

    if !array.allocator.proc  remember_allocators(array);

    array.data = realloc(array.data, desired_items * size, array.allocated * size,, array.allocator);
    assert(array.data != null); // The program will die if we couldn't get memory. We can think about an alternative strategy, but it's hard to know what would be reasonable.

    array.allocated = desired_items;
}
