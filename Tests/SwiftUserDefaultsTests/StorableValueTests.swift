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

enum RawSubject: String {
    case foo, bar, baz
}

final class StorableValueTests: XCTestCase {
    func testArray() {
        let arrayValue: [String] = ["one", "two", "three"]
        let nsArrayValue: NSArray = ["one", "two", "three"]

        XCTAssertEqual(Array<String>(storedValue: arrayValue), ["one", "two", "three"])
        XCTAssertEqual(Array<String>(storedValue: nsArrayValue), ["one", "two", "three"])

        XCTAssertEqual(arrayValue.storableValue as? NSArray, ["one", "two", "three"])

        XCTAssertNil(Array<String>(storedValue: "A"))
        XCTAssertNil(Array<String>(storedValue: ["1", 2, "3"]))
    }

    func testBool() {
        let boolValue: Bool = true
        let numberValue: NSNumber = false

        XCTAssertEqual(Bool(storedValue: boolValue), true)
        XCTAssertEqual(Bool(storedValue: numberValue), false)

        XCTAssertEqual(boolValue.storableValue as? NSNumber, NSNumber(value: true))

        XCTAssertNil(Bool(storedValue: "true"))
    }

    func testData() throws {
        let dataValue = Data([0x48, 0x65, 0x6c, 0x6c, 0x6f])
        let nsDataValue = try XCTUnwrap(NSData(base64Encoded: "SGVsbG8=", options: .ignoreUnknownCharacters))

        XCTAssertEqual(Data(storedValue: dataValue), Data([0x48, 0x65, 0x6c, 0x6c, 0x6f]))
        XCTAssertEqual(Data(storedValue: nsDataValue), Data([0x48, 0x65, 0x6c, 0x6c, 0x6f]))

        XCTAssertEqual(dataValue.storableValue as? NSData, nsDataValue)

        XCTAssertNil(Data(storedValue: "SGVsbG8"))
    }

    func testDate() {
        let dateValue = Date(timeIntervalSinceReferenceDate: 60 * 60 * 24)
        let nsDateValue: NSDate = NSDate(timeIntervalSinceReferenceDate: 60 * 60 * 24)

        XCTAssertEqual(Date(storedValue: dateValue), dateValue)
        XCTAssertEqual(Date(storedValue: nsDateValue), dateValue)

        XCTAssertEqual(dateValue.storableValue as? NSDate, nsDateValue)
    }

    func testDictionary() {
        let dictionaryValue: [String: Int] = ["A": 1, "B": 2, "C": 3]
        let nsDictionaryValue: NSDictionary = ["A": 1, "B": 2, "C": 3]

        XCTAssertEqual(Dictionary<String, Int>(storedValue: dictionaryValue), dictionaryValue)
        XCTAssertEqual(Dictionary<String, Int>(storedValue: nsDictionaryValue), dictionaryValue)

        XCTAssertEqual(dictionaryValue.storableValue as? NSDictionary, nsDictionaryValue)

        XCTAssertNil(Dictionary<String, String>(storedValue: "{}"))
        XCTAssertNil(Dictionary<String, String>(storedValue: ["A": "1", "B": 2, "C": "3"]))
    }

    func testFloatingPoints() {
        let numberValue = NSNumber(value: 1)
        let floatValue: Float = 1
        let doubleValue: Double = 1

        XCTAssertEqual(Double(storedValue: doubleValue), 1)
        XCTAssertEqual(Double(storedValue: numberValue), 1)

        XCTAssertEqual(Float(storedValue: floatValue), 1)
        XCTAssertEqual(Float(storedValue: numberValue), 1)

        XCTAssertEqual(floatValue.storableValue as? NSNumber, NSNumber(value: 1))
        XCTAssertEqual(doubleValue.storableValue as? NSNumber, NSNumber(value: 1))

        XCTAssertNil(Float(storedValue: "1"))
        XCTAssertNil(Double(storedValue: "1"))
    }

    func testIntegers() {
        let numberValue = NSNumber(value: 123)
        let intValue = Int(123)
        let int8Value = Int8(123)
        let int16Value = Int16(123)
        let int32Value = Int32(123)
        let int64Value = Int64(123)
        let uIntValue = UInt(123)
        let uInt8Value = UInt8(123)
        let uInt16Value = UInt16(123)
        let uInt32Value = UInt32(123)
        let uInt64Value = UInt64(123)

        XCTAssertEqual(Int(storedValue: numberValue), 123)
        XCTAssertEqual(Int(storedValue: intValue), 123)

        XCTAssertEqual(Int8(storedValue: numberValue), 123)
        XCTAssertEqual(Int8(storedValue: int8Value), 123)

        XCTAssertEqual(Int16(storedValue: numberValue), 123)
        XCTAssertEqual(Int16(storedValue: int16Value), 123)

        XCTAssertEqual(Int32(storedValue: numberValue), 123)
        XCTAssertEqual(Int32(storedValue: int32Value), 123)

        XCTAssertEqual(Int64(storedValue: numberValue), 123)
        XCTAssertEqual(Int64(storedValue: int64Value), 123)

        XCTAssertEqual(UInt(storedValue: numberValue), 123)
        XCTAssertEqual(UInt(storedValue: uIntValue), 123)

        XCTAssertEqual(UInt8(storedValue: numberValue), 123)
        XCTAssertEqual(UInt8(storedValue: uInt8Value), 123)

        XCTAssertEqual(UInt16(storedValue: numberValue), 123)
        XCTAssertEqual(UInt16(storedValue: uInt16Value), 123)

        XCTAssertEqual(UInt32(storedValue: numberValue), 123)
        XCTAssertEqual(UInt32(storedValue: uInt32Value), 123)

        XCTAssertEqual(UInt64(storedValue: numberValue), 123)
        XCTAssertEqual(UInt64(storedValue: uInt64Value), 123)

        XCTAssertEqual(intValue.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(int8Value.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(int16Value.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(int32Value.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(int64Value.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(uIntValue.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(uInt8Value.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(uInt16Value.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(uInt32Value.storableValue as? NSNumber, NSNumber(value: 123))
        XCTAssertEqual(uInt64Value.storableValue as? NSNumber, NSNumber(value: 123))

        XCTAssertNil(Int(storedValue: "123"))
        XCTAssertNil(Int8(storedValue: "123"))
        XCTAssertNil(Int16(storedValue: "123"))
        XCTAssertNil(Int32(storedValue: "123"))
        XCTAssertNil(Int64(storedValue: "123"))
        XCTAssertNil(UInt(storedValue: "123"))
        XCTAssertNil(UInt8(storedValue: "123"))
        XCTAssertNil(UInt16(storedValue: "123"))
        XCTAssertNil(UInt32(storedValue: "123"))
        XCTAssertNil(UInt64(storedValue: "123"))
    }

    func testString() throws {
        let stringValue = "Hello"
        let substringValue = stringValue[stringValue.startIndex ..< stringValue.endIndex]
        let nsStringValue: NSString = "Hello"

        XCTAssertEqual(String(storedValue: stringValue), "Hello")
        XCTAssertEqual(String(storedValue: nsStringValue), "Hello")

        XCTAssertEqual(stringValue.storableValue as? NSString, nsStringValue)
        XCTAssertEqual(substringValue.storableValue as? NSString, nsStringValue)

        XCTAssertNil(String(storedValue: NSObject()))
    }
}
