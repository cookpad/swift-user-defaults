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

import SwiftUserDefaults
import XCTest

private extension UserDefaults.Key {
    static let valueOne = Self("ValueOne")
    static let valueTwo = Self("ValueTwo")
    static let valueThree = Self("ValueThree")
}

final class UserDefaultsValueContainerTests: XCTestCase {
    func testContents() {
        // When values are stored within the container
        var container = UserDefaults.ValueContainer()
        container.set("First Value", forKey: .valueOne)
        container.set("Second Value", forKey: .valueOne)
        container.set(RawSubject.baz, forKey: .valueTwo)
        XCTAssertNoThrow(try container.set(Subject(value: "foo"), forKey: .valueThree, strategy: .json))

        // Then the contents should have encoded as expected
        let expected: [UserDefaults.Key: UserDefaultsStorable] = [
            .valueOne: "Second Value",
            .valueTwo: "baz",
            .valueThree: Data(#"{"value":"foo"}"#.utf8)
        ]
        XCTAssertEqual(container.contents as NSDictionary, expected as NSDictionary)
    }

    func testLaunchArguments() {
        // Given values are stored within the container
        var container = UserDefaults.ValueContainer()
        container.set("Hello, World", forKey: .valueOne)

        // The values should be encoded to the expected launch arguments
        XCTAssertEqual(container.launchArguments, ["-ValueOne", "<string>Hello, World</string>"])
    }

    func testLaunchArguments_multiple() throws {
        // Given values are stored within the container
        var container = UserDefaults.ValueContainer()
        container.set("Hello, World", forKey: .valueOne)
        container.set(true, forKey: .valueTwo)
        container.set(123, forKey: .valueThree)

        // When the launch arguments are chunked by every two item and put into a dictionary (since order is ambiguous)
        let launchArguments = Dictionary(
            uniqueKeysWithValues: container.launchArguments
                .chunked(into: 2)
                .map({ ($0.first!, $0.last!) })
        )

        // The contents will match as expected
        XCTAssertEqual(launchArguments, [
            "-ValueOne": "<string>Hello, World</string>",
            "-ValueTwo": "<true/>",
            "-ValueThree": "<integer>123</integer>"
        ])
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
