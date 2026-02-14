// BUGGY: Swift strings don't use Int indices - Common gotcha!
let greeting = "Hello, Swift!"

// 💥 Error: 'subscript' is unavailable: cannot subscript String with an Int
let firstChar = greeting[0]

// 💥 Error: Binary operator '-' cannot be applied to 'String.Index' and 'Int'
let lastChar = greeting[greeting.count - 1]

// 💥 Wrong approach - Strings in Swift are NOT arrays of characters!
// Each "character" might be multiple unicode scalars (e.g., emoji)
