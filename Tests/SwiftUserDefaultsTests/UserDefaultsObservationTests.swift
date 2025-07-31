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

final class UserDefaultsObservationTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #fileID)
        userDefaults.removePersistentDomain(forName: #fileID)
    }

    func testObserveValue() {
        // Given an observer is registered for a specific key
        var changes: [UserDefaults.Change<Any?>] = []
        let observer = userDefaults.observeObject(forKey: "TestKey") { change in
            changes.append(change)
        }

        // When the user defaults updates the value
        userDefaults.set("Test", forKey: "TestKey")
        userDefaults.removeObject(forKey: "TestKey")
        userDefaults.register(defaults: ["TestKey": "Default"])
        userDefaults.set(1, forKey: "TestKey")
        userDefaults.set(2, forKey: "OtherKey")

        observer.invalidate()

        userDefaults.set("Ignored", forKey: "TestKey")

        // Then the observer should have tracked the changes for test_key_3 up until the observer is cancelled
        XCTAssertEqual(changes.map(\.value) as NSArray, [nil, "Test", nil, "Default", 1] as NSArray)
        XCTAssertEqual(changes.map(\.label), [.initial, .update, .update, .update, .update])
    }

    func testInvalidateOnDeinit() {
        // Given an observer is registered
        var changes: [UserDefaults.Change<Any?>] = []

        var observer: UserDefaults.Observation? = userDefaults.observeObject(forKey: "TestKey") { change in
            changes.append(change)
        }
        _ = observer

        userDefaults.set("Test", forKey: "TestKey")

        // When the observer is deallocated
        observer = nil

        // Then no further changes should be recorded
        userDefaults.set("NewTest", forKey: "TestKey")

        XCTAssertEqual(changes.map(\.value) as NSArray, [nil, "Test"] as NSArray)
        XCTAssertEqual(changes.map(\.label), [.initial, .update])
    }
}

private extension UserDefaults.Change {
    enum Label {
        case initial, update
    }

    var label: Label {
        switch self {
        case .initial:
            return .initial
        case .update:
            return .update
        }
    }
}
