import Foundation

/// A property wrapper used for marking types as a value that should be used as an override in `UserDefaults`.
///
/// On its own, `@UserDefaultOverride` or `LaunchOverrides` cannot override values stored in `UserDefaults`, but they can provide an array of launch arguments that you can then pass to a process. There are two scenarios where you might find this useful:
///
/// 1. Running UI Tests via XCTest, you might set `XCUIApplication`'s `launchArguments` array before calling `launch()`.
/// 2. Invoking a `Process`, you might pass values to the `arguments` array.
///
/// **UI Test Example**
///
/// When using SwiftUserDefaults, if you define `UserDefaults.Key` definitions and other model types in a separate framework target (in this example, `MyFramework`), you can then share them between your application target and your UI test target:
///
/// ```swift
/// import SwiftUserDefaults
///
/// public extension UserDefaults.Key {
///     public static let user = Self("User")
///     public static let state = Self("State")
///     public static let isLegacyUser = Self("LegacyUser")
/// }
///
/// public struct User: Codable {
///     public var name: String
///
///     public init(name: String) {
///         self.name = name
///     }
/// }
///
/// public enum State: String {
///     case registered, unregistered
/// }
/// ```
/// To easily manage overrides in your UI Testing target, import your framework target and define a container that conforms to `LaunchArgumentEncodable`. In this container, use the `@UserDefaultOverride` property wrapper to build up a configuration of overrides that match usage in your app:
///
/// ```swift
/// import MyFramework
/// import SwiftUserDefaults
///
/// struct AppConfiguration: LaunchArgumentEncodable {
///     // An optional Codable property, encoded to data using the `.plist` strategy.
///     @UserDefaultOverride(.user, strategy: .plist)
///     var user: User?
///
///     // A RawRepresentable enum with a default value, encoded to it's backing `rawValue` (a String).
///     @UserDefaultOverride(.state)
///     var state: State = .unregistered
///
///     // An optional primitive type (Bool). When `nil`, values will not be used as an override since null cannot be represented.
///     @UserDefaultOverride(.isLegacyUser)
///     var isLegacyUser: Bool?
///
///     // A convenient place to define other launch arguments that don't relate to `UserDefaults`.
///     var additionalLaunchArguments: [String] {
///         ["UI-Testing"]
///     }
/// }
/// ```
///
/// Finally, in your test cases, create and configure an instance of your container type and use the `collectLaunchArguments()` method to pass the overrides into your `XCUIApplication` and perform the UI tests like normal. The overrides will be picked up by `UserDefaults` instances in your app to help you in testing pre-configured states.
///
/// ```swift
/// import SwiftUserDefaults
/// import XCTest
///
/// class MyAppUITestCase: XCTestCase {
///     func testScenario() throws {
///         // Create a configuration, update the overrides
///         var configuration = AppConfiguration()
///         configuration.user = User(name: "John")
///         configuration.state = .registered
///
///         // Create the test app, assign the launch arguments and launch the process.
///         let app = XCUIApplication()
///         app.launchArguments = try configuration.encodeLaunchArguments()
///         app.launch()
///
///         // The launch arguments will look like the following:
///         app.launchArguments
///         // ["-User", "<data>...</data>", "-State", "<string>registered</string>", "UI-Testing"]
///
///         // ...
///     }
/// }
/// ```
@propertyWrapper
public struct UserDefaultOverride<Value> {
    let getValue: () -> Value
    let setValue: (Value) -> Void
    let getKeyValuePair: () throws -> (key: UserDefaults.Key, value: UserDefaultsStorable)?

    public var wrappedValue: Value {
        get {
            getValue()
        }
        set {
            setValue(newValue)
        }
    }

    init(
        wrappedValue defaultValue: Value,
        key: UserDefaults.Key,
        transform: @escaping (Value) throws -> UserDefaultsStorable?
    ) {
        var value: Value = defaultValue

        getValue = { value }
        setValue = { value = $0 }

        getKeyValuePair = {
            guard let value = try transform(value) else { return nil }
            return (key: key, value: value)
        }
    }

    public init(
        wrappedValue defaultValue: Value,
        _ key: UserDefaults.Key
    ) where Value: UserDefaultsStorable {
        self.init(wrappedValue: defaultValue, key: key, transform: { $0 })
    }

    public init<T: UserDefaultsStorable>(
        _ key: UserDefaults.Key
    ) where Value == T? {
        self.init(wrappedValue: nil, key: key, transform: { $0 })
    }

    public init(
        wrappedValue defaultValue: Value,
        _ key: UserDefaults.Key
    ) where Value: RawRepresentable, Value.RawValue: UserDefaultsStorable {
        self.init(wrappedValue: defaultValue, key: key, transform: { $0.rawValue })
    }

    public init<T: RawRepresentable>(
        _ key: UserDefaults.Key
    ) where Value == T?, T.RawValue: UserDefaultsStorable {
        self.init(wrappedValue: nil, key: key, transform: { $0?.rawValue })
    }

    public init(
        wrappedValue defaultValue: Value,
        _ key: UserDefaults.Key,
        strategy: UserDefaults.CodingStrategy
    ) where Value: Encodable {
        self.init(wrappedValue: defaultValue, key: key, transform: { try strategy.encode($0) })
    }

    public init<T: Encodable>(
        _ key: UserDefaults.Key,
        strategy: UserDefaults.CodingStrategy
    ) where Value == T? {
        self.init(wrappedValue: nil, key: key, transform: { try $0.flatMap({ try strategy.encode($0) }) })
    }
}

// MARK: - UserDefaultKeyValueRepresentable

/// Internal protocol to help erase generic type information from `UserDefaultOverride` when attempting to obtain the key value pair.
protocol UserDefaultKeyValueRepresentable {
    /// Returns the pair, nil or an error upon request.
    func keyValuePair() throws -> (key: UserDefaults.Key, value: UserDefaultsStorable)?
}

extension UserDefaultOverride: UserDefaultKeyValueRepresentable {
    func keyValuePair() throws -> (key: UserDefaults.Key, value: UserDefaultsStorable)? {
        try getKeyValuePair()
    }
}
