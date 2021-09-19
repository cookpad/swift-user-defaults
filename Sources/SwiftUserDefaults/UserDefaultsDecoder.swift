import Foundation
import os.log

enum UserDefaultsDecoder {
    static let log: OSLog = OSLog(subsystem: "eu.liamnichols.swift-user-defaults", category: "UserDefaultsDecoder")

    /// Logging method for initialising generic `UserDefaultsStorable` types from underlying stored objects.
    static func decode<Value: UserDefaultsStorable>(
        from storedValue: Any,
        context key: UserDefaults.Key
    ) -> Value? {
        // If the value can be decoded successfully, simply return it
        if let decoded = Value(storedValue: storedValue) {
            return decoded
        }

        // If the value wasn't decoded, log a message for debugging
        os_log(
            "Unable to decode '%@' as %{public}@ when stored object was %{public}@",
            log: log,
            type: .info,
            key.rawValue,
            String(describing: Value.self),
            String(describing: type(of: storedValue))
        )

        return nil
    }
}
