// Example 9: Switch Not Exhaustive
// BUG: Adding new enum case breaks switch statements
// Swift's exhaustiveness helps - but you must handle all cases

import Foundation

enum PaymentStatus {
    case pending
    case paid
    case refunded  // New case added later - breaks existing switches!
}

func formatStatus(_ status: PaymentStatus) -> String {
    switch status {
    case .pending: return "Waiting"
    case .paid: return "Complete"
    // 💥 Compiler error: Switch must be exhaustive (missing .refunded)
    }
}
