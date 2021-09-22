# Swift User Defaults

A series of Swift friendly utilities for Foundation's `UserDefaults` class.

# Features

- [`Key` Type](#key-type)
- [Observations](#observations)
- [Type Safety](#type-safety)
- [UI Testing](#ui-testing)
- [Enums and `RawRepresentable`](#enums-and-rawrepresentable)
- [`@UserDefault` Property Wrapper](#userdefault-property-wrapper)

## `Key` Type

Reading and writing from `UserDefaults` works using a key that is a simple `String` property. This is often great, but the compiler is not able to protect you from typos when referencing the key value multiple times.

Similar to Foundation's `Notification.Name`, SwiftUserDefaults provides a new `UserDefaults.Key` type that acts as a namespace for you to provide your own constants that can be conveniently used around your app without having to worry about typos or other issues that might occur during refactoring.

```swift
import Foundation
import SwiftUserDefaults

extension UserDefaults.Key {
    /// The name of the user using the app
    static let userName = Self("UserName")
}
```

You can then use these keys later on with the `@UserDefault` property wrapper or the convenience methods added to `UserDefaults` and `@AppStorage`.

## Observations

`UserDefaults` is key-value observing compliant however you can't use Swift's key-path based overlay since the stored defaults don't associate to actual properties. SwiftUserDefaults helps solve this problem by providing a wrapper around the Objective C based KVO methods:

```swift
import Foundation
import SwiftUserDefaults

class MyViewController: UIViewController {
    let store = UserDefaults.standard
    var observation: UserDefaults.Observation?

    // ...

    override func viewDidLoad() {
        super.viewDidLoad()

        // ...

        observation = store.observeObject(forKey: "UserName") { change in
            self.nameLabel.text = change.value as? String
        }
    }

    deinit {
        observation?.invalidate()
    }
}
```

The `change` property is the `UserDefaults.Change` enum which consists of two cases to represent both the `.initial` value and any subsequent `.update`'s

## Type Safety

The `UserDefaults` are backed by the Property List format which is only suitable for storing dates, numbers, booleans, strings, data, dictionaries and arrays but it can be easy to mistakenly insert other objects since there is no type safety on the setter methods. This would result in a crash:

```swift
let store = UserDefaults.standard
store.set(UUID(), forKey: "UserGUID")
// SIGABRT
//
// Attempt to insert non-property list object
// DAE8F83E-5760-475D-B28D-D493F695E765 for key UserGUID
```

SwiftUserDefaults provides extension methods, which when used with [`UserDefaults.Key`](#key-type) can help you two write safer code and eliminate any type casting:

```swift
import Foundation
import SwiftUserDefaults

extension UserDefaults.Key {
    /// The current level of the user
    static let currentLevel = Self("CurrentLevel")
    /// The name of the user using the app
    static let userName = Self("UserName")
    /// The unique identifier assigned to this user
    static let userGUID = Self("UserGUID")
}

let store = UserDefaults.standard

// MARK: - Default Values
store.register(defaults: [
    .currentLevel: 1
])

// MARK: - Setting Values
let name: String = ...
let guid: UUID = ...

store.set(name, for: .userName)
store.set(guid.stringValue, for: .userGUID)

store.set(guid, for: .userGUID)
       // ^^^^ Argument type 'UUID' does not conform to expected
       //      type 'UserDefaultsStorable'

// MARK: - Removing Values
store.removeObject(for: .userName)

// MARK: - Reading Values
func userName() -> String? {
    return store.object(for: .userName) // type inferred from context
}

let currentLevel = store.object(for: .currentLevel, as: Int.self)
currentLevel // Int?, 1

// MARK: - Observing
let observer = store.observeObject(for: .userName, as: String.self) { change
    change // UserDefaults.Change<String?>

    switch change {
    case .initial(let value):
        print("Initial Value:", value ?? "nil")
    case .update(let value):
        print("Value Updated:", value ?? "nil")
    }
}
```

## UI Testing

SwiftUserDefaults provides a structured way to inject values into `UserDefaults` of your App target from the UI Testing target. This works by formatting a payload of launch arguments that `UserDefaults` will read into the [`NSArgumentDomain`](https://developer.apple.com/documentation/foundation/nsargumentdomain).

### MyAppCommon Target

```swift
import Foundation
import SwiftUserDefaults

extension UserDefaults.Key {
    /// The current level of the user
    public static let currentLevel = Self("CurrentLevel")
    /// The name of the user using the app
    public static let userName = Self("UserName")
    /// The unique identifier assigned to this user
    public static let userGUID = Self("UserGUID")
}

```

### MyAppUITests Target

```swift
import Foundation
import SwiftUserDefaults
import MyAppCommon
import XCTest

final class MyAppTests: XCTestCase {
    func testMyApp() {
        let store: [UserDefaults.Key: UserDefaultsStorable] = [
            .currentLevel: 8,
            .userName: "John Doe",
            .userGUID: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
        ]

        let app = XCUIApplication()
        app.launchArguments = UserDefaults.launchArguments(from: store)
        app.launch()

        // ...
    }
}
```

### MyApp Target

```swift
class ViewController: UIViewController {
    // ...

    override func viewDidLoad() {
        super.viewDidLoad()

        let store = UserDefaults.standard
        store.object(for: .currentLevel, as: Int.self) // 8
        store.object(for: .userName, as: String.self) // "John Doe"
        store.object(for: .userGUID, as: String.self) // "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    }
}
```

## Enums and `RawRepresentable`

Beyond the standard types that are supported by the Property List format, you can easily

```swift
import SwiftUserDefaults

enum Difficulty: String, UserDefaultsStorable {
    case easy, medium, hard
}
```

As long as your `Difficulty.RawValue` is a type that conforms to `UserDefaultsStorable`, you can use this enum automatically in all of the convenience methods provided by SwiftUserDefaults.


## `@UserDefault` Property Wrapper

The `@UserDefault` property wrapper supports all values that conform to the `UserDefaultsStorable` protocol. The simplest way to use the property wrapper is as follows:

```swift
import SwiftUserDefaults

class MyStore {
    @UserDefault(.userName)
    var userName: String?

    @UserDefault(.currentLevel)
    var currentLevel: Int = 1

    @UserDefault(.difficulty)
    var difficulty: Difficulty = .medium
}
```

If you need to be able to inject dependencies into `MyStore`, you can do so as follows:

```swift
import SwiftUserDefaults

class MyStore {
    @UserDefault var userName: String?
    @UserDefault var currentLevel: Int
    @UserDefault var difficulty: Difficulty

    init(userDefaults store: UserDefaults) {
        _userName = UserDefault(.userName, store: store)
        _currentLevel = UserDefault(.currentLevel, store: store, defaultValue: 1)
        _difficulty = UserDefault(.difficulty, store: store, defaultValue: .medium)
    }
}
```

Finally, through the projected value, `@UserDefault` allows you to reset and observe the stored value:

```swift
let store = MyStore(userDefaults: .standard)

// Removes the value from user defaults
store.$userName.reset()

// Observes the user default, respecting the default value
let observer = store.$currentLevel.addObserver { change in
    change.value // Int, 1
}
```
