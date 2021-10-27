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

private var userDefaultsObserverContext = 0

public extension UserDefaults {
    /// Observes changes to the object associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The key of the object in `UserDefaults` to observe.
    ///   - handler: A closure invoked whenever the observed value is modified.
    /// - Returns: A token object to be used to invalidate the observation by either deallocating the value or calling `invalidate()`.
    /// - Warning: The underline observation leverages `UserDefault`'s KVO compliance and as a result, requires that the `key`'s underlying `rawValue` is compliant with a key path. This typically means that the use of `.` can result in an observation not working. An assertion will be raised if the key is not valid.
    func observeObject(forKey key: String, handler: @escaping (Change<Any?>) -> Void) -> Observation {
        assert(!key.contains("."), "Key '\(key)' is not suitable for observation")
        return Observation(userDefaults: self, keyPath: key, handler: handler)
    }

    // MARK: - Change

    /// Encapsulates change updates produced by an observer
    enum Change<T> {
        /// The initial results of the observation.
        ///
        /// Does not signify a change but instead can be used as a base for comparison of future changes.
        case initial(T)

        /// Indicates that the observed collection has changed and includes the updated value.
        case update(T)
    }

    // MARK: - Observation

    /// An observation focused on a specific user default key.
    ///
    /// The `invalidate()` method will be called automatically when an `Observation` is deallocated.
    final class Observation: NSObject {
        let userDefaults: UserDefaults
        let keyPath: String
        let handler: (Change<Any?>) -> Void

        private(set) var isRegistered: Bool = false

        init(
            userDefaults: UserDefaults,
            keyPath: String,
            handler: @escaping (Change<Any?>) -> Void
        ) {
            self.userDefaults = userDefaults
            self.keyPath = keyPath
            self.handler = handler

            super.init()

            userDefaults.addObserver(
                self,
                forKeyPath: keyPath,
                options: [.initial, .new, .old],
                context: &userDefaultsObserverContext
            )
            isRegistered = true
        }

        // swiftlint:disable:next block_based_kvo
        public override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let change = change, context == &userDefaultsObserverContext else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }

            // `change` contains `NSNull` if no value was stored so be sure to remove that.
            let value = change[.newKey] ?? NSNull()
            let actualValue: Any? = value is NSNull ? nil : value

            if change.keys.contains(.oldKey) {
                handler(.update(actualValue))
            } else {
                handler(.initial(actualValue))
            }
        }

        deinit {
            invalidate()
        }

        /// Stops observing the user defaults for changes.
        public func invalidate() {
            guard isRegistered else { return }

            userDefaults.removeObserver(self, forKeyPath: keyPath, context: &userDefaultsObserverContext)
            isRegistered = false
        }
    }
}

// MARK: - Change Util

extension UserDefaults.Change: Equatable where T: Equatable {}
extension UserDefaults.Change: Hashable where T: Hashable {}

public extension UserDefaults.Change {
    /// Convenience property for returning the value. Useful in scenarios where you don't need to distinguish between the initial value or an update.
    var value: T {
        switch self {
        case .initial(let value), .update(let value):
            return value
        }
    }

    /// Returns a change containing the results of mapping the changes value using the given closure.
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts the value of this change as its parameter and returns a transformed value of the same or of a different type.
    /// - Returns: A change with the transformed value
    func map<U>(_ transform: (T) -> U) -> UserDefaults.Change<U> {
        switch self {
        case .initial(let value):
            return .initial(transform(value))
        case .update(let value):
            return .update(transform(value))
        }
    }
}
