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
    /// The key used for storing the wrapped value in `UserDefaults`.
    public let key: UserDefaults.Key

    /// The instance of `UserDefaults` used for storing the wrapped value.
    public let userDefaults: UserDefaults

    /// A closure used for encoding the wrapped value into a representation suitable for `UserDefaults`.
    let valueEncoder: (Value) -> Any?

    /// A closure used for decoding the representation stored in `UserDefaults` into the wrapped value type.
    let valueDecoder: (Any?) -> Value

    public var wrappedValue: Value {
        get {
            valueDecoder(userDefaults.value(forKey: key.rawValue))
        }
        set {
            if let value = valueEncoder(newValue) {
                userDefaults.set(value, forKey: key.rawValue)
            } else {
                userDefaults.removeObject(forKey: key.rawValue)
            }
        }
    }
}

// MARK: - Initializers
public extension UserDefault {
    /// Creates a `UserDefault` property wrapper with support for a default value that is applied in the event of the stored value being `nil`.
    ///
    /// - Parameters:
    ///   - key: The key of the value stored within `UserDefaults`.
    ///   - userDefaults: The instance of `UserDefaults` used for storing the value. Defaults to `UserDefaults.standard`.
    ///   - defaultValue: The default value used when the stored value is `nil`.
    init(
        key: UserDefaults.Key,
        userDefaults: UserDefaults = .standard,
        defaultValue: Value
    ) where Value: UserDefaultsStorable {
        self.init(
            key: key,
            userDefaults: userDefaults,
            valueEncoder: { $0.storableValue },
            valueDecoder: { $0.flatMap(Value.init(storedValue:)) ?? defaultValue }
        )
    }

    /// Creates a `UserDefault` property wrapper.
    ///
    /// - Parameters:
    ///   - key: The key of the value stored within `UserDefaults`.
    ///   - userDefaults: The instance of `UserDefaults` used for storing the value. Defaults to `UserDefaults.standard`.
    init<T: UserDefaultsStorable>(
        key: UserDefaults.Key,
        userDefaults: UserDefaults = .standard
    ) where Value == T? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            valueEncoder: { $0?.storableValue },
            valueDecoder: { $0.flatMap(T.init(storedValue:)) }
        )
    }
}

