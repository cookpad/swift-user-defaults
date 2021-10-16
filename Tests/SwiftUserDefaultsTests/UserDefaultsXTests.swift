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
}
