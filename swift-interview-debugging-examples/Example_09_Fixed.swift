// Example 9 FIXED: Handle all cases (or use default)
// Always handle new enum cases - use @unknown default for future-proofing

import Foundation

enum PaymentStatus {
    case pending
    case paid
    case refunded
}

func formatStatus(_ status: PaymentStatus) -> String {
    switch status {
    case .pending: return "Waiting"
    case .paid: return "Complete"
    case .refunded: return "Refunded"  // ✅ All cases covered
    }
}

// Tip: When you add a new enum case, fix ALL switch statements that use it.
// The compiler will error on each one - fix them one by one.
