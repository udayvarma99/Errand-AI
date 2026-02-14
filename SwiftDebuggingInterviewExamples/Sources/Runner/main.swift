import Foundation
import DebugExamples

@main
struct Runner {
    static func main() async {
        print("1) Optional parsing:", parseNonNegativeInt("42") as Any, parseNonNegativeInt("abc") as Any)

        print("2) Sum:", sumUsingIndices([1, 2, 3]), sumUsingForIn([1, 2, 3]))

        let vm = ViewModel()
        vm.start()
        vm.triggerUpdate()
        print("3) ViewModel refreshCount:", vm.refreshCount)

        let counter = SafeCounter()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<1_000 {
                group.addTask { await counter.increment() }
            }
        }
        print("4) SafeCounter value:", await counter.get())

        let users: Set<User> = [
            User(id: 1, name: "Sam"),
            User(id: 1, name: "Samuel")
        ]
        print("5) Set<User> count (id identity):", users.count)

        let players = [
            Player(name: "B", score: 10),
            Player(name: "a", score: 10),
            Player(name: "c", score: 12)
        ]
        print("6) Sorted players:", sortPlayersByScoreDescThenName(players).map { "\($0.name):\($0.score)" })

        print("7) Parse date:", parseYYYYMMDD("2026-02-14") as Any)

        let json = #"{"user_id":1,"display_name":"Sam"}"#.data(using: .utf8)!
        if let decoded = try? decodeAPIUser(from: json) {
            print("8) Decoded APIUser:", decoded)
        }

        do {
            _ = try area(width: 3, height: 7)
            print("9) Area ok")
        } catch {
            print("9) Area overflow:", error)
        }

        print("10) Intersection:", intersection([1, 2, 3, 4], [2, 4, 6]))
    }
}

