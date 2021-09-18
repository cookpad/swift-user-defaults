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

final class UserDefaultTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #fileID)
        userDefaults.removePersistentDomain(forName: #fileID)
    }

    func testUserDefaultsStorableType() {
        var wrapper = UserDefault<String>(key: "StringKey", userDefaults: userDefaults, defaultValue: "")

        // When UserDefaults does not have a value, the default value is used
        XCTAssertNil(userDefaults.object(forKey: "StringKey"))
        XCTAssertEqual(wrapper.wrappedValue, "")

        // When setting a value, it is written to UserDefaults
        wrapper.wrappedValue = "Some Value"
        XCTAssertEqual(wrapper.wrappedValue, "Some Value")
        XCTAssertEqual(userDefaults.string(forKey: "StringKey"), "Some Value")

        // Updates from UserDefaults are reflected
        userDefaults.setValue("Something Else", forKey: "StringKey")
        XCTAssertEqual(wrapper.wrappedValue, "Something Else")
    }

    func testOptionalUserDefaultsStorableType() {
        var wrapper = UserDefault<Int?>(key: "IntegerKey", userDefaults: userDefaults)

        // When UserDefaults does not have a value, the default value is nil
        XCTAssertNil(userDefaults.object(forKey: "IntegerKey"))
        XCTAssertNil(wrapper.wrappedValue)

        // When setting a value, it is written to UserDefaults
        wrapper.wrappedValue = 123
        XCTAssertEqual(wrapper.wrappedValue, 123)
        XCTAssertEqual(userDefaults.integer(forKey: "IntegerKey"), 123)

        // When setting the value to `nil`, it clears UserDefaults
        wrapper.wrappedValue = nil
        XCTAssertNil(wrapper.wrappedValue)
        XCTAssertNil(userDefaults.object(forKey: "IntegerKey"))

        // Updates from UserDefaults are reflected
        userDefaults.setValue(0, forKey: "IntegerKey")
        XCTAssertEqual(wrapper.wrappedValue, 0)
    }

    func testReset() {
        var wrapper = UserDefault<Bool>(key: "BoolKey", userDefaults: userDefaults, defaultValue: true)

        // When setting the value, it is written to UserDefaults
        wrapper.wrappedValue = false
        XCTAssertFalse(wrapper.wrappedValue)
        XCTAssertEqual(userDefaults.object(forKey: "BoolKey") as? Bool, false)

        // When resetting the value, it's cleared from UserDefaults and the wrappedValue uses the defaultValue
        wrapper.reset()
        XCTAssertTrue(wrapper.wrappedValue)
        XCTAssertNil(userDefaults.object(forKey: "BoolKey"))
    }
}
