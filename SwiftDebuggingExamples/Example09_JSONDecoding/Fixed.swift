// Example 9: JSON Decoding - FIXED VERSION
// Proper Codable usage and error handling

import Foundation

// FIX 1: Custom CodingKeys for key mismatch
struct User: Codable {
    let name: String
    let age: Int
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case age
        case email = "emailAddress"  // ✅ Map to different JSON key
    }
}

let jsonString1 = """
{
    "name": "Alice",
    "age": 30,
    "emailAddress": "alice@example.com"
}
"""

// FIX 2: Custom decoding for type mismatch
struct Product: Codable {
    let id: Int
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case id, price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // ✅ Try to decode as Int first, then String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = idInt
        } else if let idString = try? container.decode(String.self, forKey: .id),
                  let idInt = Int(idString) {
            id = idInt
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "ID must be Int or String convertible to Int"
            )
        }
        
        price = try container.decode(Double.self, forKey: .price)
    }
}

let jsonString2 = """
{
    "id": "123",
    "price": 29.99
}
"""

// FIX 3: Make optional or provide default
struct Article: Codable {
    let title: String
    let content: String
    let author: String?  // ✅ Optional
    
    // Alternative: Provide default
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        author = try? container.decode(String.self, forKey: .author) ?? "Unknown"
    }
}

let jsonString3 = """
{
    "title": "Swift Tutorial",
    "content": "Learn Swift..."
}
"""

// FIX 4: Custom date decoding strategy
struct Event: Codable {
    let name: String
    let date: Date
}

let jsonString4 = """
{
    "name": "Conference",
    "date": "2024-02-14"
}
"""

func decodeEvent() throws -> Event {
    let data = jsonString4.data(using: .utf8)!
    let decoder = JSONDecoder()
    
    // ✅ Set date decoding strategy
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    decoder.dateDecodingStrategy = .formatted(formatter)
    
    return try decoder.decode(Event.self, from: data)
}

// FIX 5: Match actual JSON structure
struct ResponseData: Codable {
    let items: [String]
}

struct Response: Codable {
    let data: ResponseData  // ✅ Match nested structure
}

let jsonString5 = """
{
    "data": {
        "items": ["a", "b", "c"]
    }
}
"""

// FIX 6: Case-insensitive enum or lowercase
enum Status: String, Codable {
    case active = "ACTIVE"  // ✅ Match JSON case
    case inactive = "INACTIVE"
    case pending = "PENDING"
    
    // Or implement custom decoding for case-insensitive
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue.lowercased() {
        case "active": self = .active
        case "inactive": self = .inactive
        case "pending": self = .pending
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid status: \(rawValue)"
            )
        }
    }
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

// FIX 7: Make field optional
struct Profile: Codable {
    let username: String
    let bio: String?  // ✅ Optional
    let avatar: String
}

let jsonString7 = """
{
    "username": "john_doe",
    "avatar": "avatar.jpg"
}
"""

// FIX 8: Custom date formatter
struct Post: Codable {
    let title: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case title, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        
        // ✅ Custom date parsing
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Invalid date format"
            )
        }
        createdAt = date
    }
}

let jsonString8 = """
{
    "title": "My Post",
    "createdAt": "14/02/2024 15:30"
}
"""

// FIX 9: Use keyDecodingStrategy
struct APIResponse: Codable {
    let userId: Int
    let firstName: String
    let createdAt: String
}

let jsonString9 = """
{
    "user_id": 123,
    "first_name": "John",
    "created_at": "2024-02-14"
}
"""

func decodeAPIResponse() throws -> APIResponse {
    let data = jsonString9.data(using: .utf8)!
    let decoder = JSONDecoder()
    
    // ✅ Convert snake_case to camelCase
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    return try decoder.decode(APIResponse.self, from: data)
}

// FIX 10: Proper error handling
func decodeUserSafe(from json: String) -> User? {
    guard let data = json.data(using: .utf8) else {
        print("Failed to convert string to data")
        return nil
    }
    
    let decoder = JSONDecoder()
    
    do {
        return try decoder.decode(User.self, from: data)
    } catch DecodingError.keyNotFound(let key, let context) {
        print("Missing key: \(key.stringValue)")
        print("Context: \(context.debugDescription)")
    } catch DecodingError.typeMismatch(let type, let context) {
        print("Type mismatch for type: \(type)")
        print("Context: \(context.debugDescription)")
    } catch DecodingError.valueNotFound(let type, let context) {
        print("Value not found for type: \(type)")
        print("Context: \(context.debugDescription)")
    } catch DecodingError.dataCorrupted(let context) {
        print("Data corrupted: \(context.debugDescription)")
    } catch {
        print("Other error: \(error)")
    }
    
    return nil
}

// BONUS: Helper extensions

extension KeyedDecodingContainer {
    // Safe decode with default value
    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: Key, default defaultValue: T) throws -> T {
        return try decodeIfPresent(type, forKey: key) ?? defaultValue
    }
}

// Generic JSON decoding
func decode<T: Decodable>(_ type: T.Type, from json: String) -> Result<T, Error> {
    guard let data = json.data(using: .utf8) else {
        return .failure(NSError(domain: "Invalid JSON string", code: -1))
    }
    
    do {
        let decoded = try JSONDecoder().decode(type, from: data)
        return .success(decoded)
    } catch {
        return .failure(error)
    }
}

// Demonstrate the fixes:
print("=== JSON Decoding Fixed ===\n")

do {
    let data1 = jsonString1.data(using: .utf8)!
    let user = try JSONDecoder().decode(User.self, from: data1)
    print("✅ User decoded: \(user.name), \(user.email)")
} catch {
    print("Error: \(error)")
}

do {
    let data2 = jsonString2.data(using: .utf8)!
    let product = try JSONDecoder().decode(Product.self, from: data2)
    print("✅ Product decoded: ID \(product.id), Price \(product.price)")
} catch {
    print("Error: \(error)")
}

do {
    let data3 = jsonString3.data(using: .utf8)!
    let article = try JSONDecoder().decode(Article.self, from: data3)
    print("✅ Article decoded: \(article.title), Author: \(article.author ?? "Unknown")")
} catch {
    print("Error: \(error)")
}

do {
    let event = try decodeEvent()
    print("✅ Event decoded: \(event.name), Date: \(event.date)")
} catch {
    print("Error: \(error)")
}

do {
    let apiResponse = try decodeAPIResponse()
    print("✅ API Response decoded: User \(apiResponse.userId), Name: \(apiResponse.firstName)")
} catch {
    print("Error: \(error)")
}

// Using Result type
let result = decode(User.self, from: jsonString1)
switch result {
case .success(let user):
    print("✅ User from Result: \(user.name)")
case .failure(let error):
    print("❌ Error: \(error)")
}

print("\n✅ All JSON decoding issues resolved!")
