// Example 9: JSON Decoding Failures
// Common Codable and JSON parsing bugs

import Foundation

// BUG 1: Key mismatch
struct User: Codable {
    let name: String
    let age: Int
    let email: String  // 🐛 JSON has "emailAddress" not "email"
}

let jsonString1 = """
{
    "name": "Alice",
    "age": 30,
    "emailAddress": "alice@example.com"
}
"""

// BUG 2: Type mismatch
struct Product: Codable {
    let id: Int  // 🐛 JSON has string "123", not number
    let price: Double
}

let jsonString2 = """
{
    "id": "123",
    "price": 29.99
}
"""

// BUG 3: Missing required field
struct Article: Codable {
    let title: String
    let content: String
    let author: String  // 🐛 Required but not in JSON!
}

let jsonString3 = """
{
    "title": "Swift Tutorial",
    "content": "Learn Swift..."
}
"""

// BUG 4: Date parsing without strategy
struct Event: Codable {
    let name: String
    let date: Date  // 🐛 JSON has "2024-02-14", not Date object
}

let jsonString4 = """
{
    "name": "Conference",
    "date": "2024-02-14"
}
"""

// BUG 5: Nested JSON with wrong structure
struct Response: Codable {
    let data: [String]  // 🐛 Expecting array, but it's an object!
}

let jsonString5 = """
{
    "data": {
        "items": ["a", "b", "c"]
    }
}
"""

// BUG 6: Enum with wrong case
enum Status: String, Codable {
    case active
    case inactive
    case pending  // 🐛 JSON has "ACTIVE" (uppercase)
}

struct Task: Codable {
    let name: String
    let status: Status
}

let jsonString6 = """
{
    "name": "My Task",
    "status": "ACTIVE"
}
"""

// BUG 7: Optional not marked as optional
struct Profile: Codable {
    let username: String
    let bio: String  // 🐛 Should be optional, bio might not be present
    let avatar: String
}

let jsonString7 = """
{
    "username": "john_doe",
    "avatar": "avatar.jpg"
}
"""

// BUG 8: Custom date format not specified
struct Post: Codable {
    let title: String
    let createdAt: Date  // 🐛 JSON: "14/02/2024 15:30"
}

let jsonString8 = """
{
    "title": "My Post",
    "createdAt": "14/02/2024 15:30"
}
"""

// BUG 9: Snake case vs camel case
struct APIResponse: Codable {
    let userId: Int  // 🐛 JSON has "user_id"
    let firstName: String  // 🐛 JSON has "first_name"
    let createdAt: String  // 🐛 JSON has "created_at"
}

let jsonString9 = """
{
    "user_id": 123,
    "first_name": "John",
    "created_at": "2024-02-14"
}
"""

// BUG 10: Decode without error handling
func decodeUser(from json: String) -> User {
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    return try! decoder.decode(User.self, from: data)  // 💥 Crashes on error!
}

// Demonstrate the bugs:
print("=== JSON Decoding Bugs ===\n")

do {
    let data1 = jsonString1.data(using: .utf8)!
    let user = try JSONDecoder().decode(User.self, from: data1)
    print("User decoded: \(user)")
} catch {
    print("Bug 1 - Key mismatch: \(error)")  // 💥 Error
}

do {
    let data2 = jsonString2.data(using: .utf8)!
    let product = try JSONDecoder().decode(Product.self, from: data2)
    print("Product decoded: \(product)")
} catch {
    print("Bug 2 - Type mismatch: \(error)")  // 💥 Error
}

do {
    let data3 = jsonString3.data(using: .utf8)!
    let article = try JSONDecoder().decode(Article.self, from: data3)
    print("Article decoded: \(article)")
} catch {
    print("Bug 3 - Missing field: \(error)")  // 💥 Error
}

print("\n❌ Multiple decoding failures due to common mistakes!")
