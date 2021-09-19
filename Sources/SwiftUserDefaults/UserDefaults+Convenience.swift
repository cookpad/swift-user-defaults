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

public extension UserDefaults {
    /// Adds the contents of the specified dictionary to the registration domain.
    ///
    /// - Parameter defaults: The dictionary of keys and values you want to register.
    func register(defaults: [Key: UserDefaultsStorable]) {
        let sequence = defaults.map({ ($0.key.rawValue, $0.value.storableValue) })
        register(defaults: Dictionary(uniqueKeysWithValues: sequence))
    }

    /// Removes the value of the specified default key.
    ///
    /// - Parameter key: The key whose value you want to remove.
    func removeObject(for key: Key) {
        removeObject(forKey: key.rawValue)
    }

    /// Sets the value of the specified default key.
    ///
    /// - Parameters:
    ///   - value: The object to store in the defaults database.
    ///   - key: The key with which to associate the value.
    func set(_ value: UserDefaultsStorable, for key: Key) {
        set(value.storableValue, forKey: key.rawValue)
    }

    /// Returns the object associated with the specified key.
    /// 
    /// - Parameter key: A key in the user‘s defaults database.
    /// - Returns: The object associated with the specified key, or `nil` if the key was not found or if the value did not match the generic type `T`.
    func object<T: UserDefaultsStorable>(for key: Key) -> T? {
        object(forKey: key.rawValue).flatMap({ UserDefaultsDecoder.decode(from: $0, context: key) })
    }

    /// Returns the object associated with the specified key.
    ///
    /// - Parameter key: A key in the user‘s defaults database.
    /// - Returns: The object associated with the specified key, or `nil` if the key was not found or if the value did not match the generic type `T`.
    func object<T: UserDefaultsStorable>(for key: Key, as _: T.Type) -> T? {
        object(for: key)
    }

    /// Observes changes to the object associated with the specified key.
    /// 
    /// - Parameters:
    ///   - key: A key in the user‘s defaults database.
    ///   - handler: A closure invoked whenever the observed value is modified.
    /// - Returns: A token object to be used to invalidate the observation by either deallocating the value or calling `invalidate()`.
    func observeObject<T: UserDefaultsStorable>(
        for key: Key,
        handler: @escaping (Change<T?>) -> Void
    ) -> Observation {
        observeObject(forKey: key.rawValue) { change in
            handler(change.map({ $0.flatMap({ UserDefaultsDecoder.decode(from: $0, context: key) }) }))
        }
    }

    /// Observes changes to the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: A key in the user‘s defaults database.
    ///   - handler: A closure invoked whenever the observed value is modified.
    /// - Returns: A token object to be used to invalidate the observation by either deallocating the value or calling `invalidate()`.
    func observeObject<T: UserDefaultsStorable>(
        for key: Key,
        as _: T.Type,
        handler: @escaping (Change<T?>) -> Void
    ) -> Observation {
        observeObject(for: key, handler: handler)
    }
}
