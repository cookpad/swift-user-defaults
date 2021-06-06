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

// A test suite for
final class StorableXMLValueTests: XCTestCase {
    func testXMLString_array() {
        assertValueMatchesPlist(Array<String>())
        assertValueMatchesPlist([true, true, false])
        assertValueMatchesPlist([["A": 1], ["B": 2], ["C": 3]])
    }

    func testXMLString_boolean() {
        assertValueMatchesPlist(true)
        assertValueMatchesPlist(false)
    }

    func testXMLString_data() {
        assertValueMatchesPlist(Data([0x48, 0x65, 0x6c, 0x6c, 0x6f]))
    }

    func testXMLString_date() {
        assertValueMatchesPlist(Date(timeIntervalSinceReferenceDate: 60 * 60 * 24))
    }

    func testXMLString_dictionary() {
        assertValueMatchesPlist(Dictionary<String, String>())
        assertValueMatchesPlist(["Data": Data([0x48, 0x65, 0x6c, 0x6c, 0x6f])])
        assertValueMatchesPlist(["Array": ["A", "B", "C"]])
        assertValueMatchesPlist(["Dictionary": ["A": 1]])
    }

    func testXMLString_integer() {
        assertValueMatchesPlist(Int(1))
        assertValueMatchesPlist(Int8(-22))
        assertValueMatchesPlist(Int32(213))
        assertValueMatchesPlist(Int64.min)

        assertValueMatchesPlist(UInt(1))
        assertValueMatchesPlist(UInt8(22))
        assertValueMatchesPlist(UInt32(213))
        assertValueMatchesPlist(UInt64.max)
    }

    func testXMLString_real() {
        assertValueMatchesPlist(Float(1.0))
        assertValueMatchesPlist(Float(0))
        assertValueMatchesPlist(Float(-1.1))
        assertValueMatchesPlist(Float(200.20))
        assertValueMatchesPlist(Float.nan)
        assertValueMatchesPlist(Float.infinity)
        assertValueMatchesPlist(-Float.infinity)

        assertValueMatchesPlist(Double(200.20))
        assertValueMatchesPlist(Double.infinity - 1)
    }

    func testXMLString_string() {
        // FIXME: Multiline string encoding.
//        assertValueMatchesPlist(
//            """
//            Hello
//            Do newlines get escaped properly?
//            """
//        )

        assertValueMatchesPlist("Hello, World")

        assertValueMatchesPlist("<Hello & Goodbye>")
    }

    func testXMLString_rawRepresentable() {
        let xmlString = "<array><string>foo</string><string>bar</string><string>baz</string></array>"

        XCTAssertEqual([RawSubject.foo, .bar, .baz].storableXMLValue, xmlString)
        XCTAssertEqual(["foo", "bar", "baz"].storableXMLValue, xmlString)
    }
}

// MARK: - Utilities

private func assertValueMatchesPlist(_ value: UserDefaultsStorable, file: StaticString = #filePath, line: UInt = #line) {
    do {
        let linesToRemove: [String] = [
            #"<?xml version="1.0" encoding="UTF-8"?>"#,
            #"<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">"#,
            #"<plist version="1.0">"#,
            #"</plist>"#
        ]

        let data = try PropertyListSerialization.data(fromPropertyList: value, format: .xml, options: .zero)
        let plistString = try XCTUnwrap(String(data: data, encoding: .utf8))

        var plistLines = plistString.components(separatedBy: .newlines)
        plistLines.removeAll(where: { linesToRemove.contains($0) })
        plistLines = plistLines.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })

        let string = plistLines.joined().trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(value.storableXMLValue, string, file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}
