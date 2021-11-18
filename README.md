# Swift User Defaults

A series of Swift friendly utilities for Foundation's `UserDefaults` class.

# Features

- 🔑 [**Constant Keys**](#-constant-keys) - Manage default keys using a specialized type to help prevent bugs and keep your project organized.
- 🦺 [**Type Safety**](#-type-safety) - Automatically cast to the right types and forget about `Any?`.
- 🔍 [**Observations**](#-observations) - Effortless observations in Swift.
- 👩‍💻 [**Codable and RawRepresentable Support**](#-codable-and-rawrepresentable-support) - Consistently encode and decode `Codable` and `RawRepresentable` types with no additional effort.
- 🧪 [**Mocking in UI Tests**](#-mocking-in-ui-tests) - Inject default values from your UI test suite directly into your application.
- 🎁 [**Property Wrappers**](#-property-wrappers) - Bringing the power of SwiftUI's `@AppStorage` wrapper to Swift with `@UserDefault`.

## 🔑 Constant Keys

With `UserDefaults` today, you store values against a given 'key'. This key is a `String` and over time using string's can lead to easy to avoid bugs unless you are defining your own constants somewhere.

You likely have to do something like the following in a project today:

```swift
let userDefaults = UserDefaults.standard
var value = (userDefaults.object(forKey: "UserCount") as? Int) ?? 0
value += 1
userDefaults.set(value, forKey: "UserCoumt")
```

As you can see from the example above, reusing strings can lead to bugs through typos so a common way to guard against this is to define constants:


```swift
struct Constants {
    static let userCountDefaultsKey = "UserCount"
}

// ...

let userDefaults = UserDefaults.standard
var value = (userDefaults.object(forKey: Constants.userCountDefaultsKey) as? Int) ?? 0
value += 1
userDefaults.set(value, forKey: Constants.userCountDefaultsKey)
```

This is much better because you can be safe knowing that you're using the correct key, but we can do better.

Similar to Foundation's `Notification.Name`, SwiftUserDefaults provides a new `UserDefaults.Key` type that acts as a namespace for you to provide your own constants that can be conveniently used around your app without having to worry about typos or other issues that might occur during refactoring.

```swift
import Foundation
import SwiftUserDefaults

extension UserDefaults.Key {
    /// The number of users interacted with.
    static let userCount = Self("UserCount")

    /// The name of the user.
    static let userName = Self("UserName")

    /// The last visit.
    static let lastVisit = Self("LastVisit")
}
```

SwiftUserDefaults then provides a series of additional APIs built on top of this type. Continue reading to learn how to use them.

## 🦺 Type Safety

When using `UserDefaults`, you must only attempt to set booleans, data, dates, numbers or strings, as well as dictionaries or arrays consisting of those types otherwise you'll experience a runtime crash with no protections from the Compiler.

SwiftUserDefaults provides safer APIs that combined with `UserDefaults.Key` offer a much safer experience with `UserDefaults`:

```swift
let userDefaults = UserDefaults.standard
var value = userDefaults.x.object(Int.self, forKey: .userCount) ?? 0
value += 1
userDefaults.x.set(value, forKey: .userCount)
```

In the above example, the `key` argument uses `UserDefaults.Key` constants and the value is automatically cast to a known type all by accessing the safer API via the `x` extension.

Additionally, the compiler can help to catch mistakes when passing unsupported types into `set(_:forKey:)`.


```swift
struct User {
    let id: UUID
}

func updateCurrentUser(_ user: User) {
    // ❌ Runtime Crash
    userDefaults.set(user.id, forKey: "UserId")
    // SIGABRT
    //
    // Attempt to insert non-property list object
    // DAE8F83E-5760-475D-B28D-D493F695E765 for key UserId

    // ✅ Compile Time Error
    userDefaults.x.set(user.id, forKey: .userId)
    // Instance method 'set(_:forKey:)' requires that 'UUID' conform to 'UserDefaultsStorable'
}
```

## 🔍 Observations

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

        observation = store.x.observeObject(String.self, forKey: .userName) { change in
            self.nameLabel.text = change.value
        }
    }

    deinit {
        observation?.invalidate()
    }
}
```

The `change` property is the `UserDefaults.Change` enum which consists of two cases to represent both the `.initial` value and any subsequent `.update`'s. If you don't care about this, you can access the underlying value via the `value` property.

## 👩‍💻 Codable and RawRepresentable Support

In addition to supporting the default value types for `UserDefaults`, convenience methods have also been provided to facilitate the use of `Codable` and `RawRepresentable` types (including enums).

For `RawRepresentable` types, you can use them exactly like `String` and `Int` values and SwiftUserDefaults will automatically read and write the `rawValue` to the underlying store:

```swift
enum Tab: String { // String and Int backed enum's are `RawRepresentable`.
    case home, search, create
}

let initialTab = userDefaults.x.object(Tab.self, forKey: .lastTab) ?? .home
showTab(initialTab)

// ...

func tabDidChange(_ tab: Tab) {
    userDefaults.x.set(tab, forKey: .lastTab)
}
```

For `Codable` types, you pass an additional `CodingStrategy` parameter (`.json` or `.plist`) to dictate the format of encoding to use when reading and writing the value:

```swift
struct Activity: Codable {
    let id: UUID
    let name: String
}

let restoredActivity = userDefaults.x.object(Activity.self, forKey: .currentActivity, strategy: .json)

func showActivity(_ activity: Activity) {
    userDefaults.x.set(activity, forKey: .currentActivity, strategy: .json)
}
```

> ⚠️ **Warning:** While these APIs can make it tempting to encode large models to `UserDefaults`, you should continue to remember that some platforms have strict limits for the size of the `UserDefaults` store.
>
> For more information, see the official [Apple Developer Documentation](https://developer.apple.com/documentation/foundation/userdefaults/1617187-sizelimitexceedednotification).

## 🧪 Mocking in UI Tests

SwiftUserDefaults provides a structured way to inject values into `UserDefaults` of your App target from the UI Testing target. This works by formatting a payload of launch arguments that `UserDefaults` will read into the [`NSArgumentDomain`](https://developer.apple.com/documentation/foundation/nsargumentdomain).

### MyAppCommon Target

```swift
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
import MyAppCommon
import SwiftUserDefaults
import XCTest

final class MyAppTests: XCTestCase {
    func testMyApp() {
        var container = UserDefaults.ValueContainer()
        container.set(8, forKey: .currentLevel)
        container.set("John Doe", forKey: .userName)
        container.set("FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF", forKey: .userGUID)

        let app = XCUIApplication()
        app.launchArguments = container.launchArguments
        app.launch()

        // ...
    }
}
```

### MyApp Target

```swift
import SwiftUserDefaults
import UIKit

class ViewController: UIViewController {
    // ...

    override func viewDidLoad() {
        super.viewDidLoad()

        let store = UserDefaults.standard
        store.x.object(Int.self, for: .currentLevel) // 8
        store.x.object(String.self, for: .userName) // "John Doe"
        store.x.object(String.self, for: .userGUID) // "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    }
}
```

## 🎁 Property Wrappers

SwiftUserDefaults brings `UserDefaults.Key` to SwiftUI's `@AppStorage` property wrapper, and in addition, it introduces an `@UserDefault` property wrapper with similar behavior that is suitable outside of SwiftUI.

 The simplest way to use the property wrapper is as follows:

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

If you need to be able to inject dependencies into `MyStore`, you can also do so as follows:

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

As with the `UserDefault.X` APIs, the property wrapper supports primitive, `RawRepresentable` and `Codable` types.

# Installation

## CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate SwiftUserDefaults into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'swift-user-defaults'
```

## Swift Package Manager

Add the following to your **Package.swift**

```swift
dependencies: [
    .package(url: "https://github.com/cookpad/swift-user-defaults.git", .upToNextMajor(from: "0.1.0"))
]
```

Or use the https://github.com/cookpad/swift-user-defaults.git repository link in Xcode.
