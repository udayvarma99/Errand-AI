import Foundation

// MARK: - 1) Optional crash -> safe parsing

public func parseNonNegativeInt(_ input: String) -> Int? {
    guard let value = Int(input), value >= 0 else { return nil }
    return value
}

// MARK: - 2) Off-by-one -> correct ranges

public func sumUsingIndices(_ numbers: [Int]) -> Int {
    var total = 0
    for i in 0..<numbers.count {
        total += numbers[i]
    }
    return total
}

public func sumUsingForIn(_ numbers: [Int]) -> Int {
    var total = 0
    for x in numbers { total += x }
    return total
}

// MARK: - 3) Retain cycle -> weak capture

public final class ViewModel {
    public var onUpdate: (() -> Void)?
    public private(set) var refreshCount = 0

    public init() {}

    public func start() {
        onUpdate = { [weak self] in
            self?.refreshUI()
        }
    }

    public func triggerUpdate() {
        onUpdate?()
    }

    private func refreshUI() {
        refreshCount += 1
    }
}

// MARK: - 4) Data race -> actor isolation

public actor SafeCounter {
    private var value = 0

    public init() {}

    public func increment() {
        value += 1
    }

    public func get() -> Int {
        value
    }
}

// MARK: - 5) Hashable/Equatable contract -> consistent identity

public struct User: Hashable, Sendable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - 6) Sort comparator -> correct ordering + tie-break

public struct Player: Equatable, Sendable {
    public let name: String
    public let score: Int

    public init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
}

public func sortPlayersByScoreDescThenName(_ players: [Player]) -> [Player] {
    players.sorted {
        if $0.score != $1.score { return $0.score > $1.score }
        return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
    }
}

// MARK: - 7) Date parsing -> fixed locale/timezone + no shared formatter

public func parseYYYYMMDD(_ input: String, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) -> Date? {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = timeZone
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: input)
}

// MARK: - 8) JSON decoding -> snake_case support

public struct APIUser: Decodable, Equatable, Sendable {
    public let userId: Int
    public let displayName: String

    public init(userId: Int, displayName: String) {
        self.userId = userId
        self.displayName = displayName
    }
}

public func decodeAPIUser(from data: Data) throws -> APIUser {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(APIUser.self, from: data)
}

// MARK: - 9) Integer overflow -> report overflow as error

public enum MathError: Error, Equatable {
    case overflow
}

public func area(width: Int, height: Int) throws -> Int {
    let (result, overflow) = width.multipliedReportingOverflow(by: height)
    if overflow { throw MathError.overflow }
    return result
}

// MARK: - 10) O(n^2) -> Set-based O(n)

public func intersection(_ a: [Int], _ b: [Int]) -> [Int] {
    let setB = Set(b)
    return a.filter { setB.contains($0) }
}

