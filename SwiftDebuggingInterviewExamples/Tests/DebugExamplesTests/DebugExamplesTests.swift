import XCTest
@testable import DebugExamples

final class DebugExamplesTests: XCTestCase {
    func testParseNonNegativeInt() {
        XCTAssertEqual(parseNonNegativeInt("0"), 0)
        XCTAssertEqual(parseNonNegativeInt("42"), 42)
        XCTAssertNil(parseNonNegativeInt("-1"))
        XCTAssertNil(parseNonNegativeInt("abc"))
    }

    func testSum() {
        XCTAssertEqual(sumUsingIndices([]), 0)
        XCTAssertEqual(sumUsingForIn([]), 0)
        XCTAssertEqual(sumUsingIndices([1, 2, 3]), 6)
        XCTAssertEqual(sumUsingForIn([1, 2, 3]), 6)
    }

    func testWeakCaptureAvoidsRetainCycle() {
        var vm: ViewModel? = ViewModel()
        vm?.start()

        weak var weakVM = vm
        vm = nil

        XCTAssertNil(weakVM, "ViewModel should deinit; weak capture avoids self->closure->self cycle")
    }

    func testSafeCounterIsDeterministicUnderConcurrency() async {
        let counter = SafeCounter()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10_000 {
                group.addTask { await counter.increment() }
            }
        }
        XCTAssertEqual(await counter.get(), 10_000)
    }

    func testHashableContract() {
        let a = User(id: 1, name: "Sam")
        let b = User(id: 1, name: "Samuel")
        XCTAssertEqual(a, b)
        XCTAssertEqual(Set([a, b]).count, 1)
    }

    func testSortPlayers() {
        let players = [
            Player(name: "B", score: 10),
            Player(name: "a", score: 10),
            Player(name: "c", score: 12)
        ]
        XCTAssertEqual(
            sortPlayersByScoreDescThenName(players),
            [
                Player(name: "c", score: 12),
                Player(name: "a", score: 10),
                Player(name: "B", score: 10)
            ]
        )
    }

    func testParseYYYYMMDD() {
        let date = parseYYYYMMDD("2026-02-14", timeZone: TimeZone(secondsFromGMT: 0)!)
        XCTAssertNotNil(date)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let comps = calendar.dateComponents([.year, .month, .day], from: date!)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 2)
        XCTAssertEqual(comps.day, 14)
    }

    func testDecodeAPIUser() throws {
        let json = #"{"user_id":1,"display_name":"Sam"}"#.data(using: .utf8)!
        XCTAssertEqual(try decodeAPIUser(from: json), APIUser(userId: 1, displayName: "Sam"))
    }

    func testAreaOverflow() {
        XCTAssertNoThrow(try area(width: 3, height: 7))
        XCTAssertThrowsError(try area(width: Int.max, height: 2)) { error in
            XCTAssertEqual(error as? MathError, .overflow)
        }
    }

    func testIntersection() {
        XCTAssertEqual(intersection([1, 2, 3, 4], [2, 4, 6]), [2, 4])
    }
}

