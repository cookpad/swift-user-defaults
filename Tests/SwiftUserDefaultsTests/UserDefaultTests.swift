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

final class UserDefaultTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #fileID)
        userDefaults.removePersistentDomain(forName: #fileID)
    }

    func testUserDefaultsStorableType() {
        let wrapper = UserDefault<String>(.init("StringKey"), store: userDefaults, defaultValue: "")

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
        let wrapper = UserDefault<Int?>(.init("IntegerKey"), store: userDefaults)

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
        let wrapper = UserDefault<Bool>(.init("BoolKey"), store: userDefaults, defaultValue: true)

        // When setting the value, it is written to UserDefaults
        wrapper.wrappedValue = false
        XCTAssertFalse(wrapper.wrappedValue)
        XCTAssertEqual(userDefaults.object(forKey: "BoolKey") as? Bool, false)

        // When resetting the value, it's cleared from UserDefaults and the wrappedValue uses the defaultValue
        wrapper.reset()
        XCTAssertTrue(wrapper.wrappedValue)
        XCTAssertNil(userDefaults.object(forKey: "BoolKey"))
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testObserver() {
        let wrapper = UserDefault<String>(.init("StringKey"), store: userDefaults, defaultValue: "")

        var changes: [UserDefaults.Change<String>] = []
        let observer = wrapper.addObserver { changes.append($0) }

        wrapper.wrappedValue = "One"
        wrapper.reset()
        wrapper.wrappedValue = "Two"
        userDefaults.x.set("Three", forKey: .init("StringKey"))

        XCTAssertEqual(changes, [.initial(""), .update("One"), .update(""), .update("Two"), .update("Three")])
        observer.invalidate()
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testCodableWithDefault() {
        let key = UserDefaults.Key("CodableKey")
        let wrapper = UserDefault<Subject>(key, strategy: .json, store: userDefaults, defaultValue: Subject(value: "default"))

        // Observe changes
        var changes: [Subject] = []
        let token = wrapper.addObserver(handler: { changes.append($0.value) })

        // Uses default
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))
        XCTAssertEqual(wrapper.wrappedValue, Subject(value: "default"))

        // Writes value
        wrapper.wrappedValue.value = "updated"
        XCTAssertEqual(userDefaults.data(forKey: key.rawValue), Data(#"{"value":"updated"}"#.utf8))
        XCTAssertEqual(wrapper.wrappedValue, Subject(value: "updated"))

        // Resets
        wrapper.reset()
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))

        // Ignores bad data
        userDefaults.set("string", forKey: key.rawValue)
        XCTAssertEqual(wrapper.wrappedValue, Subject(value: "default"))

        // Notifies changes
        XCTAssertEqual(changes.map(\.value), [
            "default",
            "updated",
            "default",
            "default"
        ])
        token.invalidate()
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testCodable() {
        let key = UserDefaults.Key("CodableKey")
        let wrapper = UserDefault<Subject?>(key, strategy: .json, store: userDefaults)

        // Observe changes
        var changes: [Subject?] = []
        let token = wrapper.addObserver(handler: { changes.append($0.value) })

        // nil when unset
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))
        XCTAssertNil(wrapper.wrappedValue)

        // Writes value
        wrapper.wrappedValue = Subject(value: "updated")
        XCTAssertEqual(userDefaults.data(forKey: key.rawValue), Data(#"{"value":"updated"}"#.utf8))
        XCTAssertEqual(wrapper.wrappedValue, Subject(value: "updated"))

        // Resets
        wrapper.reset()
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))
        XCTAssertNil(wrapper.wrappedValue)

        // Ignores bad data
        userDefaults.set("string", forKey: key.rawValue)
        XCTAssertNil(wrapper.wrappedValue)

        // Set to nil clears
        userDefaults.set(Data(#"{"value":"value"}"#.utf8), forKey: key.rawValue)
        wrapper.wrappedValue = nil

        // Notifies changes
        XCTAssertEqual(changes.map(\.?.value), [
            nil,
            "updated",
            nil,
            nil,
            "value",
            nil
        ])
        token.invalidate()
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testRawRepresentableWithDefault() {
        let key = UserDefaults.Key("RawRepresentableKey")
        let wrapper = UserDefault<RawSubject>(key, store: userDefaults, defaultValue: .foo)

        // Observe changes
        var changes: [RawSubject] = []
        let token = wrapper.addObserver(handler: { changes.append($0.value) })

        // Uses default
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))
        XCTAssertEqual(wrapper.wrappedValue, .foo)

        // Writes value
        wrapper.wrappedValue = .bar
        XCTAssertEqual(userDefaults.string(forKey: key.rawValue), "bar")
        XCTAssertEqual(wrapper.wrappedValue, .bar)

        // Resets
        wrapper.reset()
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))

        // Uses default for bad data
        userDefaults.set("unknown", forKey: key.rawValue)
        XCTAssertEqual(wrapper.wrappedValue, .foo)

        // Notifies changes
        XCTAssertEqual(changes, [
            .foo,
            .bar,
            .foo,
            .foo
        ])
        token.invalidate()
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testRawRepresentable() {
        let key = UserDefaults.Key("RawRepresentableKey")
        let wrapper = UserDefault<RawSubject?>(key, store: userDefaults)

        // Observe changes
        var changes: [RawSubject?] = []
        let token = wrapper.addObserver(handler: { changes.append($0.value) })

        // Uses default
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))
        XCTAssertNil(wrapper.wrappedValue)

        // Writes value
        wrapper.wrappedValue = .bar
        XCTAssertEqual(userDefaults.string(forKey: key.rawValue), "bar")
        XCTAssertEqual(wrapper.wrappedValue, .bar)

        // Resets
        wrapper.reset()
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))
        XCTAssertNil(wrapper.wrappedValue)

        // Uses default for bad data
        userDefaults.set("unknown", forKey: key.rawValue)
        XCTAssertNil(wrapper.wrappedValue)

        // Reads raw value
        userDefaults.set("baz", forKey: key.rawValue)
        XCTAssertEqual(wrapper.wrappedValue, .baz)

        // Notifies changes
        XCTAssertEqual(changes, [
            nil,
            .bar,
            nil,
            nil,
            .baz
        ])
        token.invalidate()
    }
}
