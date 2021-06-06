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
    /// Returns an array of strings that can be used in command line launch arguments to influence the contents of processes `UserDefaults` store.
    ///
    /// - Parameter values: A dictionary where the keys represent the key of a user default value and the value matches the data to be assigned to the key.
    /// - Returns: An ordered array that can then be passed as arguments when launching a process.
    static func launchArguments(from values: [String: UserDefaultsStorable]) -> [String] {
        launchArguments(from: values.map({ $0 }))
    }

    /// Returns an array of strings that can be used in command line launch arguments to influence the contents of processes `UserDefaults` store.
    ///
    /// - Parameter values: A dictionary where the keys represent the key of a user default value and the value matches the data to be assigned to the key.
    /// - Returns: An ordered array that can then be passed as arguments when launching a process.
    static func launchArguments<T: RawRepresentable>(from values: [T: UserDefaultsStorable]) -> [String] where T.RawValue == String {
        launchArguments(from: values.map({ ($0.key.rawValue, $0.value) }))
    }

    /// Returns an array of strings that can be used in command line launch arguments to influence the contents of processes `UserDefaults` store.
    ///
    /// - Parameter values: An array of tuples where the first value represents the key of a user default value and the second value represents the data to be assigned to the given key.
    /// - Returns: An ordered array that can then be passed as arguments when launching a process.
    static func launchArguments(from values: [(key: String, value: UserDefaultsStorable)]) -> [String] {
        values.reduce(into: Array<String>()) { launchArguments, element in
            launchArguments.append("-" + element.key)
            launchArguments.append(element.value.storableXMLValue)
        }
    }
}
