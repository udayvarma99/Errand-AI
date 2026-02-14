# Example 2: Array Bounds

## The Bug
Accessing `array[4]` when the array has only 3 elements causes **Index out of range** crash.

## The Fix
1. Check `array.count > index` before accessing
2. Use `array.indices.contains(index)` - more idiomatic Swift
3. Return optional `Int?` when element might not exist

## Interview Tip
"How would you safely access array elements?" - Show both guard and optional return. Know the difference between `count` (number of elements) and `indices` (valid index range).
