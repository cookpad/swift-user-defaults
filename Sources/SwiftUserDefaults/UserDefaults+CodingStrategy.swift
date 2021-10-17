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

public extension UserDefaults {
    /// Available strategies for serializing `Codable` types into `UserDefaults` as data blobs and reading them back again.
    enum CodingStrategy {
        /// Uses the default `JSONEncoder` and `JSONDecoder` types to map between data and a `Codable` type
        case json

        /// Uses the default `PropertyListEncoder` and `PropertyListDecoder` types to map between data and a `Codable` type
        case plist
    }
}

public extension UserDefaults.CodingStrategy {
    /// Encodes an instance of the indicated type.
    ///
    /// - Parameter value: The value to encode.
    /// - Throws: An error if any value throws an error during encoding.
    /// - Returns: A new `Data` value containing the encoded type using the receivers strategy.
    func encode<T: Encodable>(_ value: T) throws -> Data {
        switch self {
        case .json:
            return try JSONEncoder().encode(value)
        case .plist:
            return try PropertyListEncoder().encode(value)
        }
    }

    /// Decodes an instance of the indicated type.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    /// - Throws: An error if any value throws an error during decoding.
    /// - Returns: The value of the requested type.
    func decode<T: Decodable>(_ type: T.Type = T.self, from data: Data) throws -> T {
        switch self {
        case .json:
            return try JSONDecoder().decode(T.self, from: data)
        case .plist:
            return try PropertyListDecoder().decode(T.self, from: data)
        }
    }
}
