# Example 9: String Indices

## The Bug
Swift strings use `String.Index`, not `Int`! This is because characters can have variable width (emojis = multiple codepoints). You can't do `string[0]` like in other languages.

## The Fix
- `string.startIndex` - First character
- `string.index(before: endIndex)` - Last character  
- `string.index(startIndex, offsetBy: n)` - Character at position n
- Create a custom subscript for convenience

## Interview Tip
"Why doesn't Swift use Int for string indexing?" - Unicode! "🇺🇸" is one character but multiple bytes. Int indexing would break for emoji and international text.
