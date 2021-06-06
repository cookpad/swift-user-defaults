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


extension Dictionary: UserDefaultsStorable where Key == String, Value: UserDefaultsStorable {
    public init?(storedValue: Any) {
        guard let storedValue = storedValue as? [String: Any] else { return nil }
        let mappedDictionary = storedValue.compactMapValues(Value.init(storedValue:))
        guard mappedDictionary.count == storedValue.count else { return nil }

        self = mappedDictionary
    }

    public var storableValue: Any {
        self.mapValues(\.storableValue)
    }

    public var storableXMLValue: String {
        if isEmpty {
            return "<dict/>"
        }

        return "<dict>"
            + map({ "<key>" + $0.xmlEscapedValue + "</key>" + $1.storableXMLValue }).joined()
            + "</dict>"
    }
}
