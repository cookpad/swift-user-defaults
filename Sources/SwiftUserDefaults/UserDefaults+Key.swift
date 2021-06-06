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
    /// An alias for a type used to represent the key of a user default value.
    ///
    /// # Usage
    ///
    /// This type can be used as a namespace for defining type-safe key definitions within your own code.
    /// Simply create an extension and define your own static properties:
    ///
    /// ```swift
    /// import SwiftUserDefaults
    ///
    /// extension UserDefaults.Key {
    ///     /// The current state of a user
    ///     static let userState = Self("user_state")
    ///
    ///     // ...
    /// }
    /// ```
    ///
    /// You can then use your custom defined keys with other API provided by UserDefaultTools:
    ///
    /// ```swift
    /// import SwiftUserDefaults
    /// import UIKit
    ///
    /// enum UserState: String, UserDefaultsStorable {
    ///     case idle, onboarding, active
    /// }
    ///
    /// class ViewController: UIViewController {
    ///     @UserDefault(key: .userState, defaultValue: .idle)
    ///     var userState: UserState
    /// }
    /// ```
    ///
    /// Or you can access the underlying value using the `rawValue` property should you need to:
    ///
    /// ```swift
    /// import Foundation
    /// import SwiftUserDefaults
    ///
    /// UserDefaults.standard.register(defaults: [
    ///     UserDefaults.Key.userState.rawValue: "onboarding"
    /// ])
    /// ```
    struct Key: RawRepresentable, Hashable, ExpressibleByStringLiteral {
        /// The underlying string value that is used for assigning a value against within the user defaults.
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: StringLiteralType) {
            self.rawValue = value
        }
    }
}
