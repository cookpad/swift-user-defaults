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

public extension UserDefaults {
    /// A container used for holding `UserDefaultsStorable` representations
    struct ValueContainer {
        /// The underlying contents of the container.
        public private(set) var contents: [UserDefaults.Key: UserDefaultsStorable]

        /// An array of keys in the order that they were applied
        private var order: [UserDefaults.Key] = []

        public init() {
            contents = [:]
        }

        // MARK: -

        /// Sets the value of the specified default key.
        ///
        /// - Parameters:
        ///   - value: The object to store in the container.
        ///   - key: The key with which to associate the value.
        public mutating func set(_ value: UserDefaultsStorable, forKey key: UserDefaults.Key) {
            contents[key] = value
            order.append(key)
        }

        /// Sets the value of the specified default key.
        ///
        /// - Parameters:
        ///   - value: The object of which the `rawValue` should be stored in the container.
        ///   - key: The key with which to associate the value.
        public mutating func set<T: RawRepresentable>(_ value: T, forKey key: UserDefaults.Key) where T.RawValue: UserDefaultsStorable {
            set(value.rawValue, forKey: key)
        }

        /// Sets the value of the specified default key.
        ///
        /// - Parameters:
        ///   - value: The object to store in the container.
        ///   - key: The key with which to associate the value.
        ///   - strategy: The custom coding strategy used when decoding the stored data.
        public mutating func set<T: Encodable>(_ value: T, forKey key: UserDefaults.Key, strategy: UserDefaults.CodingStrategy) throws {
            set(try strategy.encode(value), forKey: key)
        }

        // MARK: - Launch Arguments

        private func sortValue(for key: UserDefaults.Key) -> Int {
            order.lastIndex(of: key) ?? 0
        }

        /// An array of strings representing the contents of the container that can be passed into a process as launch arguments in order to be read into `UserDefaults`'s `NSArgumentDomain`.
        public var launchArguments: [String] {
            contents
                .sorted(by: { sortValue(for: $0.key) < sortValue(for: $1.key) })
                .reduce(into: Array<String>()) { launchArguments, element in
                    launchArguments.append("-" + element.key.rawValue)
                    launchArguments.append(element.value.storableXMLValue)
                }
        }
    }
}
