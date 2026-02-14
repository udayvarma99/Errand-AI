import Foundation

// MARK: - Example 01: Optional crash (force unwrap)
//
// Broken (common):
//   return Int(text)!   // crashes if text isn't numeric
//
// Debug:
// - Add an exception breakpoint.
// - `po text` to see the unexpected input.
// - Decide whether the function should return Optional, throw, or default.

public enum Example01_Optionals {
    /// Parses a TCP/UDP port from text.
    /// - Returns: `nil` if the string is not a valid port in 0...65535.
    public static func port(from text: String) -> Int? {
        guard let n = Int(text), (0...65535).contains(n) else { return nil }
        return n
    }

    /// Parses a port, falling back to a default.
    public static func port(from text: String, default defaultPort: Int) -> Int {
        port(from: text) ?? defaultPort
    }
}

