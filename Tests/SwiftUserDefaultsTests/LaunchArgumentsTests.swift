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

import SwiftUserDefaults
import XCTest

final class LaunchArgumentsTests: XCTestCase {
    func testLaunchArgumentsAsSequence() {
        let input: [(String, UserDefaultsStorable)] = [
            ("String", "Bar"),
            ("Date", Date(timeIntervalSinceReferenceDate: 0)),
            ("Boolean", true)
        ]

        let launchArguments = UserDefaults.launchArguments(from: input)

        XCTAssertEqual(
            launchArguments,
            ["-String", "<string>Bar</string>", "-Date", "<date>2001-01-01T00:00:00Z</date>", "-Boolean", "<true/>"]
        )
    }

    func testLaunchArgumentsAsDictionary() {
        let input: [String: UserDefaultsStorable] = [
            "Integer": 1
        ]

        let launchArguments = UserDefaults.launchArguments(from: input)

        XCTAssertEqual(
            launchArguments,
            ["-Integer", "<integer>1</integer>"]
        )
    }

    func testLaunchArgumentsAsDictionaryWithRawRepresentable() {
        let key = UserDefaults.Key("Real")

        let input: [UserDefaults.Key: UserDefaultsStorable] = [
            key: Float.zero
        ]

        let launchArguments = UserDefaults.launchArguments(from: input)

        XCTAssertEqual(
            launchArguments,
            ["-Real", "<real>0.0</real>"]
        )
    }
}
