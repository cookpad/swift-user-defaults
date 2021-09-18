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

final class UserDefaultsConvenienceTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #fileID)
        userDefaults.removePersistentDomain(forName: #fileID)
    }

    func testConvenienceMethods() {
        // Observer is registered
        var changes: [UserDefaults.Change<RawSubject?>] = []
        let observer = userDefaults.observeObject(for: .rawSubject, as: RawSubject.self) { change in
            changes.append(change)
        }

        // Initial value should read nil
        let initialValue = userDefaults.object(for: .rawSubject, as: RawSubject.self)
        XCTAssertNil(initialValue)

        // Mutations should be recorded
        userDefaults.set(RawSubject.baz, for: .rawSubject)
        userDefaults.removeObject(for: .rawSubject)
        userDefaults.register(defaults: [.rawSubject: RawSubject.bar])
        observer.invalidate()

        // Updated value should be read
        XCTAssertEqual(userDefaults.object(for: .rawSubject), RawSubject.bar)

        // Changes should have been observed
        XCTAssertEqual(changes, [.initial(nil), .update(.baz), .update(nil), .update(.bar)])
    }
}
