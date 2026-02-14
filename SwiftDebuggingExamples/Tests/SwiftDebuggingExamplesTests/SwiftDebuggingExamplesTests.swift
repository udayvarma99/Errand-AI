import XCTest
@testable import SwiftDebuggingExamples

final class SwiftDebuggingExamplesTests: XCTestCase {
    func testExample01_Optionals() {
        XCTAssertEqual(Example01_Optionals.port(from: "8080"), 8080)
        XCTAssertNil(Example01_Optionals.port(from: "oops"))
        XCTAssertNil(Example01_Optionals.port(from: "70000"))
        XCTAssertEqual(Example01_Optionals.port(from: "oops", default: 80), 80)
    }

    func testExample02_SafeIndexing() {
        XCTAssertEqual([10, 20][safe: 0], 10)
        XCTAssertNil([10, 20][safe: 2])
        XCTAssertNil([10, 20][safe: -1])
    }

    func testExample04_ValueSemantics() {
        let original = Bag(items: ["a"])
        Example04_ValueSemantics.addBroken("b", to: original)
        XCTAssertEqual(original.items, ["a"], "Broken version should not mutate caller")

        var bag = original
        Example04_ValueSemantics.addFixed("b", to: &bag)
        XCTAssertEqual(bag.items, ["a", "b"])

        let bag2 = Example04_ValueSemantics.adding("c", to: original)
        XCTAssertEqual(bag2.items, ["a", "c"])
        XCTAssertEqual(original.items, ["a"])
    }

    func testExample05_CounterActor() async {
        let counter = CounterActor()
        await counter.increment()
        await counter.increment()
        XCTAssertEqual(await counter.get(), 2)
    }

    func testExample06_BinarySearch() {
        XCTAssertNil(Example06_BinarySearch.binarySearch([Int](), target: 1))
        XCTAssertEqual(Example06_BinarySearch.binarySearch([1], target: 1), 0)
        XCTAssertNil(Example06_BinarySearch.binarySearch([1], target: 2))
        XCTAssertEqual(Example06_BinarySearch.binarySearch([1, 3, 5, 7], target: 7), 3)
        XCTAssertNil(Example06_BinarySearch.binarySearch([1, 3, 5, 7], target: 6))
    }

    func testExample07_PerformanceSet() {
        let a = [1, 2, 3, 4]
        let b = [0, 2, 4, 6]
        XCTAssertEqual(Example07_PerformanceSet.commonElementsFast(a, b), [2, 4])
        XCTAssertEqual(Example07_PerformanceSet.commonElementsSlow(a, b), [2, 4])
    }

    func testExample08_DateParsing() {
        let text = "2026-02-14T12:34:56Z"
        guard let date = Example08_DateParsing.parseInternetDateTime(text) else {
            return XCTFail("Expected to parse fixed-format date")
        }
        XCTAssertEqual(Example08_DateParsing.formatInternetDateTime(date), text)
    }

    func testExample10_CodableKeys() throws {
        let json = #"{"id":1,"user_name":"sam"}"#.data(using: .utf8)!
        let user = try JSONDecoder().decode(UserDTO.self, from: json)
        XCTAssertEqual(user, UserDTO(id: 1, userName: "sam"))
    }
}

