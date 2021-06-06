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

import Foundation


extension BinaryFloatingPoint where Self: UserDefaultsStorable {
    public init?(storedValue: Any) {
        guard let value = storedValue as? Self else { return nil }
        self = value
    }

    public var storableValue: Any {
        self
    }

    public var storableXMLValue: String {
        "<real>" + stringValue + "</real>"
    }

    // Reimplementation of __CFNumberCopyFormattingDescriptionAsFloat64
    // https://opensource.apple.com/source/CF/CF-299.3/NumberDate.subproj/CFNumber.c.auto.html
    //
    // Matches implementation of _CFAppendXML0
    // https://opensource.apple.com/source/CF/CF-550/CFPropertyList.c.auto.html
    private var stringValue: String {
        let floatValue = Float64(self)

        if floatValue.isNaN {
            return "nan"
        }

        if floatValue.isInfinite {
            return 0.0 < floatValue ? "+infinity" : "-infinity"
        }

        if floatValue == 0.0 {
            return "0.0"
        }

        return String(format: "%.*g", DBL_DIG + 2, floatValue)
    }
}

extension Double: UserDefaultsStorable {}
extension Float: UserDefaultsStorable {}
