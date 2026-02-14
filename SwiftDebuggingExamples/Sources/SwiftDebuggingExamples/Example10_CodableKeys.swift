import Foundation

// MARK: - Example 10: Codable decoding fails due to key mismatch
//
// Broken (common):
//   struct User: Decodable { let userName: String } // but JSON is "user_name"
//
// Debug:
// - Print the raw JSON.
// - Catch decoding error and inspect it; it often tells you which key was missing.
//
// Fix:
// - Map keys using CodingKeys (or custom decoding).

public struct UserDTO: Codable, Equatable {
    public let id: Int
    public let userName: String

    public init(id: Int, userName: String) {
        self.id = id
        self.userName = userName
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
    }
}

