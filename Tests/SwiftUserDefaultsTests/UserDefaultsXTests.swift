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

private struct Subject: Codable, Equatable {
    let value: String
}

private extension UserDefaults.Key {
    static let rawSubject = Self("RawSubject")
}

final class UserDefaultsXTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #fileID)
        userDefaults.removePersistentDomain(forName: #fileID)
    }

    func testConvenienceMethods() {
        // Observer is registered
        var changes: [UserDefaults.Change<RawSubject?>] = []
        let observer = userDefaults.x.observeObject(RawSubject.self, forKey: .rawSubject) { change in
            changes.append(change)
        }

        // Initial value should read nil
        let initialValue = userDefaults.x.object(RawSubject.self, forKey: .rawSubject)
        XCTAssertNil(initialValue)

        // Mutations should be recorded
        userDefaults.x.set(RawSubject.baz, forKey: .rawSubject)
        userDefaults.x.removeObject(forKey: .rawSubject)
        userDefaults.x.register(defaults: [.rawSubject: RawSubject.bar])
        observer.invalidate()

        // Updated value should be read
        XCTAssertEqual(userDefaults.x.object(forKey: .rawSubject), RawSubject.bar)

        // Changes should have been observed
        XCTAssertEqual(changes, [.initial(nil), .update(.baz), .update(nil), .update(.bar)])
    }

    func testDecodeFailsGracefully() {
        // When underlying data is a String
        userDefaults.set("0", forKey: "NumberAsString")

        // And we try to cast to Int
        let value = userDefaults.x.object(Int.self, forKey: .init("NumberAsString"))

        // Returned value is `nil`
        XCTAssertNil(value)

        // And log message is sent:
        // [UserDefaults.X] Unable to decode 'NumberAsString' as Int when stored object was NSTaggedPointerString
    }

    func testCodable_setJSON() throws {
        let subject = Subject(value: "something")
        let key = UserDefaults.Key("Key")

        // When the subject is set with the JSON strategy
        userDefaults.x.set(subject, forKey: key, strategy: .json)

        // The raw data is compact JSON
        let data = try XCTUnwrap(userDefaults.data(forKey: key.rawValue))
        XCTAssertEqual(data, Data(#"{"value":"something"}"#.utf8))
    }

    func testCodable_getJSON() throws {
        let key = UserDefaults.Key("Key")

        // Given JSON data exists in UserDefaults
        userDefaults.set(Data(#"{"value":"something else"}"#.utf8), forKey: key.rawValue)

        // Then reading into a Decodable type will parse the JSON
        let subject = userDefaults.x.object(Subject.self, forKey: key, strategy: .json)
        XCTAssertEqual(Subject(value: "something else"), subject)
    }

    func testCodable_plist() throws {
        let subject = Subject(value: "something")
        let key = UserDefaults.Key("Key")

        // When the subject is set with the plist strategy
        userDefaults.x.set(subject, forKey: key, strategy: .plist)
        XCTAssertNotNil(userDefaults.data(forKey: key.rawValue))

        // Then the subject can be read back
        XCTAssertEqual(subject, userDefaults.x.object(forKey: key, strategy: .plist))
    }

    func testCodable_readInvalid() throws {
        let key = UserDefaults.Key("Key")

        // Given invalid data is written
        userDefaults.x.set(Data("[]".utf8), forKey: key)

        // When UserDefaults attempts to read as a CodableType
        let value = userDefaults.x.object(Subject.self, forKey: key, strategy: .json)

        // Then the value will be nil
        XCTAssertNil(value)

        // And an error will be logged
        // [UserDefaults.X] Error thrown decoding data for 'Key' using strategy 'json' as Subject: {error}
    }

    func testCodable_writeInvalid() throws {
        let key = UserDefaults.Key("Key")

        // Given a value is already written
        userDefaults.setValue("Test", forKey: key.rawValue)

        // When writing an invalid value
        userDefaults.x.set("Test", forKey: key, strategy: .plist)

        // Then the value will have been removed due to the failure
        XCTAssertNil(userDefaults.object(forKey: key.rawValue))

        // And an error will have been logged
        // [UserDefaults.X] Error thrown encoding data for 'Key' using strategy 'plist': {error}
        // [UserDefaults.X] Removing data stored for 'Key' after failing to encode new value
    }

    func testCodableObservation() {
        let key = UserDefaults.Key("Key")

        // Given changes are being observed
        var changes: [Subject?] = []
        let observer = userDefaults.x.observeObject(Subject.self, forKey: key, strategy: .json) { change in
            changes.append(change.value)
        }

        // When a sequence of events take place
        userDefaults.x.set(Subject(value: "one"), forKey: key, strategy: .json)
        userDefaults.x.set(Subject(value: "two"), forKey: key, strategy: .json)
        userDefaults.x.set(Subject(value: "three"), forKey: key, strategy: .plist)
        userDefaults.x.set(Subject(value: "four"), forKey: key, strategy: .json)
        userDefaults.set("five", forKey: key.rawValue)
        userDefaults.set(Data(#"{"value":"six"}"#.utf8), forKey: key.rawValue)
        userDefaults.x.removeObject(forKey: key)
        observer.invalidate()
        userDefaults.x.set(Subject(value: "seven"), forKey: key, strategy: .json)

        // Then the correct values will have been observed
        XCTAssertEqual(changes, [
            nil, // initial
            Subject(value: "one"),
            Subject(value: "two"),
            nil, // plist
            Subject(value: "four"),
            nil, // string
            Subject(value: "six"), // manual
            nil, // remove
        ])
    }
}
