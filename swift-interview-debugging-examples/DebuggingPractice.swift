import Foundation
import Dispatch

// Example 1: Avoid force unwrap crashes.
func uppercaseFirstLetter(_ text: String?) -> String {
    guard let text, let first = text.first else { return "" }
    return String(first).uppercased() + text.dropFirst()
}

// Example 2: Safe array indexing.
func thirdElement(_ arr: [Int]) -> Int? {
    guard arr.indices.contains(2) else { return nil }
    return arr[2]
}

// Example 3: Prevent off-by-one range bugs.
func sum(_ nums: [Int]) -> Int {
    nums.reduce(0, +)
}

// Example 4: Break closure retain cycles with [weak self].
final class SafeProfileViewModel {
    var onUpdate: (() -> Void)?
    private(set) var didRefresh = false

    func bind() {
        onUpdate = { [weak self] in
            self?.refreshUI()
        }
    }

    private func refreshUI() {
        didRefresh = true
    }
}

func safeProfileViewModelDeallocates() -> Bool {
    var vm: SafeProfileViewModel? = SafeProfileViewModel()
    weak var weakVM = vm
    vm?.bind()
    vm = nil
    return weakVM == nil
}

// Example 5: MainActor-safe UI style state updates.
@MainActor
final class NamePresenter {
    private(set) var labelText = ""

    func fetchName(loader: () async -> String) async {
        let name = await loader()
        labelText = name
    }
}

// Example 6: Actor for thread-safe mutation.
actor Counter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}

// Example 7: Correct frequency map logic.
func frequency(_ words: [String]) -> [String: Int] {
    var map: [String: Int] = [:]
    for word in words {
        map[word, default: 0] += 1
    }
    return map
}

// Example 8: Correct binary search boundaries.
func binarySearch(_ nums: [Int], target: Int) -> Int {
    var left = 0
    var right = nums.count - 1

    while left <= right {
        let mid = left + (right - left) / 2
        if nums[mid] == target { return mid }
        if nums[mid] < target {
            left = mid + 1
        } else {
            right = mid - 1
        }
    }
    return -1
}

// Example 9: Break class-to-class retain cycles with weak.
final class Person {
    var apartment: Apartment?
}

final class Apartment {
    weak var tenant: Person?
}

func personApartmentCanDeallocate() -> Bool {
    var person: Person? = Person()
    var apartment: Apartment? = Apartment()
    weak var weakPerson = person
    weak var weakApartment = apartment

    person?.apartment = apartment
    apartment?.tenant = person

    person = nil
    apartment = nil

    return weakPerson == nil && weakApartment == nil
}

// Example 10: inout for value-type mutation.
struct Cart {
    var items: [String]
}

func addItem(_ cart: inout Cart, item: String) {
    cart.items.append(item)
}

func runAsyncAndBlock(_ operation: @escaping () async -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        await operation()
        semaphore.signal()
    }
    semaphore.wait()
}

func runAllExamples() {
    assert(uppercaseFirstLetter(nil) == "")
    assert(uppercaseFirstLetter("swift") == "Swift")

    assert(thirdElement([1, 2]) == nil)
    assert(thirdElement([1, 2, 3, 4]) == 3)

    assert(sum([1, 2, 3, 4]) == 10)
    assert(sum([]) == 0)

    assert(safeProfileViewModelDeallocates())

    runAsyncAndBlock {
        let presenter = await MainActor.run { NamePresenter() }
        await presenter.fetchName { "Ada" }
        let text = await MainActor.run { presenter.labelText }
        assert(text == "Ada")
    }

    runAsyncAndBlock {
        let counter = Counter()
        await counter.increment()
        await counter.increment()
        let value = await counter.value
        assert(value == 2)
    }

    let counts = frequency(["apple", "banana", "apple"])
    assert(counts["apple"] == 2)
    assert(counts["banana"] == 1)

    assert(binarySearch([1, 3, 5, 7, 9], target: 7) == 3)
    assert(binarySearch([1, 3, 5, 7, 9], target: 2) == -1)

    assert(personApartmentCanDeallocate())

    var cart = Cart(items: [])
    addItem(&cart, item: "MacBook")
    assert(cart.items == ["MacBook"])
}

runAllExamples()
print("All Swift debugging examples passed.")
