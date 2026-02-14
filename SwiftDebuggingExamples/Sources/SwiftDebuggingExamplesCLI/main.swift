import Foundation
import SwiftDebuggingExamples

print("SwiftDebuggingExamplesCLI")

print("Example01 port('8080') =", Example01_Optionals.port(from: "8080") as Any)
print("Example01 port('oops', default 80) =", Example01_Optionals.port(from: "oops", default: 80))

print("Example02 element(at: 2, in: [10,20]) =", Example02_SafeIndexing.element(at: 2, in: [10, 20]) as Any)

let vm = Example03_ViewModel()
vm.simulateWork()
print("Example03 progress =", vm.progress)

var bag = Bag(items: ["a"])
Example04_ValueSemantics.addFixed("b", to: &bag)
print("Example04 bag =", bag.items)

print("Example06 binarySearch [1,3,5], target 3 =", Example06_BinarySearch.binarySearch([1, 3, 5], target: 3) as Any)

print("Example07 commonElementsFast =", Example07_PerformanceSet.commonElementsFast([1, 2, 3], [2, 4, 3]))

let parsed = Example08_DateParsing.parseInternetDateTime("2026-02-14T12:34:56Z")
print("Example08 parsed date =", parsed as Any)

let json = #"{"id":1,"user_name":"sam"}"#.data(using: .utf8)!
let user = try JSONDecoder().decode(UserDTO.self, from: json)
print("Example10 decoded =", user)

