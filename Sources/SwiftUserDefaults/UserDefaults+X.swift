/// MIT License
///
/// Copyright (c) 2021 Cookpad Inc.
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
import os.log

// MARK: - X
public extension UserDefaults {
    /// A namespace for extra convenience API
    struct X {
        let base: UserDefaults
    }

    /// `UserDefaults` extra convenience API namespace.
    var x: X { X(base: self) }
}

// MARK: - API
public extension UserDefaults.X {
    internal static let log: OSLog = OSLog(
        subsystem: "com.cookpad.swift-user-defaults",
        category: "UserDefaults.X"
    )

    // MARK: Common

    /// Adds the contents of the specified dictionary to the registration domain.
    ///
    /// - Parameter defaults: The dictionary of keys and values you want to register.
    func register(defaults: [UserDefaults.Key: UserDefaultsStorable]) {
        let sequence = defaults.map({ ($0.key.rawValue, $0.value.storableValue) })
        base.register(defaults: Dictionary(uniqueKeysWithValues: sequence))
    }

    func register(defaults container: UserDefaults.ValueContainer) {
        register(defaults: container.contents)
    }

    /// Removes the value of the specified default key.
    ///
    /// - Parameter key: The key whose value you want to remove.
    func removeObject(forKey key: UserDefaults.Key) {
        base.removeObject(forKey: key.rawValue)
    }

    // MARK: Read

    /// Returns the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - key: A key in the user‘s defaults database.
    /// - Returns: The object associated with the specified key, or `nil` if the key was not found or if the value did not match the generic type `T`.
    func object<T: UserDefaultsStorable>(_ type: T.Type = T.self, forKey key: UserDefaults.Key) -> T? {
        base.object(forKey: key.rawValue).flatMap({ decode(from: $0, context: key) })
    }

    /// Returns the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - type: The type of the value to return.
    ///   - key: A key in the user‘s defaults database.
    /// - Returns: The object associated with the specified key, or `nil` if the key was not found or if the value was not stored in a format that was compatible with `T.RawValue`.
    func object<T: RawRepresentable>(_ type: T.Type = T.self, forKey key: UserDefaults.Key) -> T? where T.RawValue: UserDefaultsStorable {
        object(forKey: key).flatMap({ T.init(rawValue: $0) })
    }

    /// Returns the object associated with the specific key after attempting to deserialise a data blob using the provided strategy.
    ///
    /// If an error occurs trying to decode the data into the given type, or if a value is not stored against the given key, `nil` will be returned.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - key: A key in the user‘s defaults database.
    ///   - strategy: The custom coding strategy used when decoding the stored data.
    /// - Returns: The deserialised object conforming to the `Decodable` protocol.
    func object<T: Decodable>(_ type: T.Type = T.self, forKey key: UserDefaults.Key, strategy: UserDefaults.CodingStrategy) -> T? {
        base.object(forKey: key.rawValue).flatMap({ decode(from: $0, strategy: strategy, context: key) })
    }

    // MARK: Write

    /// Sets the value of the specified default key.
    ///
    /// - Parameters:
    ///   - value: The object to store in the defaults database.
    ///   - key: The key with which to associate the value.
    func set(_ value: UserDefaultsStorable, forKey key: UserDefaults.Key) {
        base.set(value.storableValue, forKey: key.rawValue)
    }

    /// Sets the value of the specified default key.
    ///
    /// - Parameters:
    ///   - value: The object of which the `rawValue` should be stored in the defaults database.
    ///   - key: The key with which to associate the value.
    func set<T: RawRepresentable>(_ value: T, forKey key: UserDefaults.Key) where T.RawValue: UserDefaultsStorable {
        set(value.rawValue, forKey: key)
    }

    /// Sets the value of the specified default key.
    ///
    /// While primitive `UserDefaults` types are stored directly in the property list data,
    /// this method uses the `Codable` protocol to serialize a data blob using the specified coding strategy.
    ///
    ///
    /// When using this method, you should continue to consider that `UserDefaults` might not be suitable for storing large amounts of data.
    ///
    /// - Parameters:
    ///   - value: The object to store in the defaults database.
    ///   - key: A key in the user‘s defaults database.
    ///   - strategy: The custom coding strategy used when decoding the stored data.
    func set<T: Encodable>(_ value: T, forKey key: UserDefaults.Key, strategy: UserDefaults.CodingStrategy) {
        if let value = encode(value, strategy: strategy, context: key) {
            set(value, forKey: key)
        } else {
            // FIXME: Can we improve this? Is removing the data the right approach?
            //
            // Pros: It's convenient (user doesn't have to think about it) and will be consistent with @UserDefault
            // Cons: It's not clear, logs might get missed
            //
            // I'm leaning towards asserting or throwing a fatal error but need to wait and see i think.
            //
            // If we didn't remove the data, i figure it might be confusing because you wouldn't expect the old
            // value to return in `object(forKey:)` but at the same time, this is also confusing.
            os_log("Removing data stored for '%@' after failing to encode new value", log: Self.log, type: .info, key.rawValue)
            removeObject(forKey: key)
        }
    }

    // MARK: Observe

    /// Observes changes to the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - type: The type of the value to observe.
    ///   - key: A key in the user‘s defaults database.
    ///   - handler: A closure invoked whenever the observed value is modified.
    /// - Returns: A token object to be used to invalidate the observation by either deallocating the value or calling `invalidate()`.
    func observeObject<T: UserDefaultsStorable>(
        _ type: T.Type = T.self,
        forKey key: UserDefaults.Key,
        handler: @escaping (UserDefaults.Change<T?>) -> Void
    ) -> UserDefaults.Observation {
        base.observeObject(forKey: key.rawValue) { change in
            handler(change.map({ $0.flatMap({ decode(from: $0, context: key) }) }))
        }
    }

    /// Observes changes to the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - type: The type of the value to observe.
    ///   - key: A key in the user‘s defaults database.
    ///   - handler: A closure invoked whenever the observed value is modified.
    /// - Returns: A token object to be used to invalidate the observation by either deallocating the value or calling `invalidate()`.
    func observeObject<T: RawRepresentable>(
        _ type: T.Type = T.self,
        forKey key: UserDefaults.Key,
        handler: @escaping (UserDefaults.Change<T?>) -> Void
    ) -> UserDefaults.Observation where T.RawValue: UserDefaultsStorable {
        observeObject(T.RawValue.self, forKey: key) { change in
            handler(change.map({ $0.flatMap(T.init(rawValue:)) }))
        }
    }

    /// Observes changes to the data associated with the specified key and decodes it into the given type.
    ///
    /// Even when using a custom coding strategy, types are stored in the underlying `UserDefaults` instance as `Data`.
    /// If an error occurs trying to decode the data into the given type, the value will be returned as `nil`.
    ///
    /// - Parameters:
    ///   - type: The type of the value to observe.
    ///   - key: A key in the user‘s defaults database.
    ///   - strategy: The strategy used when decoding the stored data.
    ///   - handler: A closure invoked whenever the observed value is modified.
    /// - Returns: A token object to be used to invalidate the observation by either deallocating the value or calling `invalidate()`.
    func observeObject<T: Decodable>(
        _ type: T.Type = T.self,
        forKey key: UserDefaults.Key,
        strategy: UserDefaults.CodingStrategy,
        handler: @escaping (UserDefaults.Change<T?>) -> Void
    ) -> UserDefaults.Observation {
        base.observeObject(forKey: key.rawValue) { change in
            handler(change.map({ $0.flatMap({ decode(from: $0, strategy: strategy, context: key) }) }))
        }
    }
}

// MARK: - Internal
extension UserDefaults.X {
    func decode<Value: UserDefaultsStorable>(
        from storedValue: Any,
        context key: UserDefaults.Key
    ) -> Value? {
        // If the value can be decoded successfully, simply return it
        if let decoded = Value(storedValue: storedValue) {
            return decoded
        }

        // If the value wasn't decoded, log a message for debugging
        os_log(
            "Unable to decode '%@' as %{public}@ when stored object was %{public}@",
            log: Self.log,
            type: .info,
            key.rawValue,
            String(describing: Value.self),
            String(describing: type(of: storedValue))
        )

        return nil
    }

    func decode<Value: Decodable>(
        from storedValue: Any,
        strategy: UserDefaults.CodingStrategy,
        context key: UserDefaults.Key
    ) -> Value? {
        // Before decoding using the custom strategy, we must first attempt to read as data
        guard let data: Data = decode(from: storedValue, context: key) else {
            return nil
        }

        do {
            // Return the decoded object
            return try strategy.decode(from: data)

        } catch {
            // Log any errors thrown during decoding
            os_log(
                "Error thrown decoding data for '%@' using strategy '%{public}@' as %{public}@: %@",
                log: Self.log,
                type: .fault,
                key.rawValue,
                String(describing: strategy),
                String(describing: Value.self),
                error as NSError
            )
            return nil
        }
    }

    func encode<Value: Encodable>(
        _ value: Value,
        strategy: UserDefaults.CodingStrategy,
        context key: UserDefaults.Key
    ) -> Data? {
        do {
            // Encode the object and return the data to be written to UserDefaults
            return try strategy.encode(value)

        } catch {
            // Log an error to help with debugging
            os_log(
                "Error thrown encoding data for '%@' using strategy '%{public}@': %@",
                log: Self.log,
                type: .fault,
                key.rawValue,
                String(describing: strategy),
                error as NSError
            )
            return nil
        }
    }
}
