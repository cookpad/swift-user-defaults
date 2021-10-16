/// MIT License
///
/// Copyright (c) 2021 Liam Nichols
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

/// A property wrapper that uses an instance of `UserDefaults` for the storage mechanism.
@propertyWrapper
public struct UserDefault<Value> {
    let getValue: () -> Value
    let setValue: (Value) -> Void
    let resetValue: () -> Void
    let observeValue: (@escaping (UserDefaults.Change<Value>) -> Void) -> UserDefaults.Observation

    public var wrappedValue: Value {
        get {
            getValue()
        }
        nonmutating set {
            setValue(newValue)
        }
    }

    public var projectedValue: Self {
        self
    }

    /// Removes any previously stored value from `UserDefaults` resetting the wrapped value to either `nil` or its default value.
    public func reset() {
        resetValue()
    }

    /// Observes changes to the specified user default in the underlying database.
    /// 
    /// - Parameter handler: A closure invoked whenever the observed value is modified.
    /// - Returns: A token object to be used to invalidate the observation by either deallocating the value or calling `invalidate()`.
    public func addObserver(handler: @escaping (UserDefaults.Change<Value>) -> Void) -> UserDefaults.Observation {
        observeValue(handler)
    }
}

// MARK: - Initializers
public extension UserDefault {
    /// Creates a property that can read and write a user default with a default value.
    ///
    /// ```swift
    /// @UserDefault(.userHasViewedProfile)
    /// var userHasViewedProfile: Bool = false
    /// ```
    ///
    /// - Parameters:
    ///   - defaultValue: The default value used when a value is not stored.
    ///   - key: The key to read and write the value to in the user defaults store.
    ///   - userDefaults: The instance of `UserDefaults` used for storing the value. Defaults to `UserDefaults.standard`.
    init(
        wrappedValue defaultValue: Value,
        _ key: UserDefaults.Key,
        store userDefaults: UserDefaults = .standard
    ) where Value: UserDefaultsStorable {
        self.init(
            getValue: {
                userDefaults.x.object(forKey: key) ?? defaultValue
            },
            setValue: { value in
                userDefaults.x.set(value, forKey: key)
            },
            resetValue: {
                userDefaults.x.removeObject(forKey: key)
            },
            observeValue: { handler in
                userDefaults.x.observeObject(Value.self, forKey: key) { change in
                    handler(change.map({ $0 ?? defaultValue }))
                }
            }
        )
    }

    /// Creates a property that can read and write a user default with a default value.
    ///
    /// This initialiser is more suitable when creating a property wrapper using injected values:
    ///
    /// ```swift
    /// @UserDefault
    /// var userHasViewedProfile: Bool
    ///
    /// init(userDefaults: UserDefaults) {
    ///     _userHasViewedProfile = UserDefault(.userHasViewedProfile, store: userDefaults, defaultValue: false)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - key: The key to read and write the value to in the user defaults store.
    ///   - userDefaults: The instance of `UserDefaults` used for storing the value. Defaults to `UserDefaults.standard`.
    ///   - defaultValue: The default value used when a value is not stored.
    init(
        _ key: UserDefaults.Key,
        store userDefaults: UserDefaults = .standard,
        defaultValue: Value
    ) where Value: UserDefaultsStorable {
        self.init(wrappedValue: defaultValue, key, store: userDefaults)
    }
}

public extension UserDefault where Value: ExpressibleByNilLiteral {
    /// Creates a property that can read and write an Optional user default.
    ///
    /// ```swift
    /// @UserDefault(.userName)
    /// var userName: String?
    /// ```
    ///
    /// - Parameters:
    ///   - key: The key to read and write the value to in the user defaults store.
    ///   - userDefaults: The instance of `UserDefaults` used for storing the value. Defaults to `UserDefaults.standard`.
    init<T: UserDefaultsStorable>(
        _ key: UserDefaults.Key,
        store userDefaults: UserDefaults = .standard
    ) where Value == T? {
        self.init(
            getValue: {
                userDefaults.x.object(forKey: key)
            },
            setValue: { value in
                if let value = value {
                    userDefaults.x.set(value, forKey: key)
                } else {
                    userDefaults.x.removeObject(forKey: key)
                }
            },
            resetValue: {
                userDefaults.x.removeObject(forKey: key)
            },
            observeValue: { handler in
                userDefaults.x.observeObject(forKey: key, handler: handler)
            }
        )
    }
}
