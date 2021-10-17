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

/// A protocol used to identify types that can be stored within `UserDefaults`.
///
/// - Warning: It is not suitable to add `UserDefaultsStorable` conformance to types that cannot be passed into the `UserDefaults.set(_:forKey:)` method. Doing so defeats the purpose of this protocol.
public protocol UserDefaultsStorable {
    /// A representation of the given property list value that can be passed via command line arguments.
    ///
    /// The value returned by this property will match what you would see if you opened a **.plist** file that had used xml encoding but instead of representing a complete property list, the xml represents just a single value (and its children if its a container type).
    var storableXMLValue: String { get }
}

// MARK: - Default Implementation
extension UserDefaultsStorable {
    init?(storedValue: Any) {
        guard let value = storedValue as? Self else { return nil }
        self = value
    }

    var storableValue: Any {
        self
    }
}

// MARK: - Array
extension Array: UserDefaultsStorable where Element: UserDefaultsStorable {
    public var storableXMLValue: String {
        if isEmpty {
            return "<array/>"
        }

        return "<array>" + map(\.storableXMLValue).joined() + "</array>"
    }
}

// MARK: - Bool
extension Bool: UserDefaultsStorable {
    public var storableXMLValue: String {
        self ? "<true/>" : "<false/>"
    }
}

// MARK: - Data
extension Data: UserDefaultsStorable {
    public var storableXMLValue: String {
        "<data>" + base64EncodedString() + "</data>"
    }
}

// MARK: - Date
extension Date: UserDefaultsStorable {
    public var storableXMLValue: String {
        "<date>" + stringValue + "</date>"
    }

    private var stringValue: String {
        ISO8601DateFormatter.string(
            from: self,
            timeZone: TimeZone(abbreviation: "GMT")!,
            formatOptions: .withInternetDateTime
        )
    }
}

// MARK: - Dictionary
extension Dictionary: UserDefaultsStorable where Key == String, Value: UserDefaultsStorable {
    public var storableXMLValue: String {
        if isEmpty {
            return "<dict/>"
        }

        return "<dict>"
            + map({ "<key>" + $0.xmlEscapedValue + "</key>" + $1.storableXMLValue }).joined()
            + "</dict>"
    }
}

// MARK: - Floating Point
extension BinaryFloatingPoint where Self: UserDefaultsStorable {
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

// MARK: - Integer
extension UserDefaultsStorable where Self: BinaryInteger {
    public var storableXMLValue: String {
        "<integer>" + String(describing: self) + "</integer>"
    }
}

extension UInt: UserDefaultsStorable {}
extension UInt8: UserDefaultsStorable {}
extension UInt16: UserDefaultsStorable {}
extension UInt32: UserDefaultsStorable {}
extension UInt64: UserDefaultsStorable {}

extension Int: UserDefaultsStorable {}
extension Int8: UserDefaultsStorable {}
extension Int16: UserDefaultsStorable {}
extension Int32: UserDefaultsStorable {}
extension Int64: UserDefaultsStorable {}

// MARK: - String
extension UserDefaultsStorable where Self: StringProtocol {
    public var storableXMLValue: String {
        "<string>" + xmlEscapedValue + "</string>"
    }

    // There is probably a more efficient way to do this
    var xmlEscapedValue: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}

extension String: UserDefaultsStorable {}
extension Substring: UserDefaultsStorable {}

