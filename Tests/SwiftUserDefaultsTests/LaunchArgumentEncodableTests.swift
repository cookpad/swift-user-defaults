import SwiftUserDefaults
import XCTest

private extension UserDefaults.Key {
    static let appleLanguages = Self("AppleLanguages")
    static let appleLocale = Self("AppleLocale")
}

private extension UserDefaults.Key {
    static let uuid = Self("UUID")
    static let user = Self("User")
    static let state = Self("State")
    static let lastState = Self("LastState")
    static let isLegacyUser = Self("LegacyUser")
    static let lastVisitDate = Self("LastVisitDate")
    static let windowPreferences = Self("WindowPreferences")
}

private struct AppConfiguration: LaunchArgumentEncodable {
    struct User: Codable, Equatable {
        var name: String
    }

    enum State: String {
        case registered, unregistered
    }

    struct WindowPreferences: Codable, Equatable {
        var isFullScreenSupported: Bool = false
        var isMinimizeEnabled: Bool = true
    }

    // UserDefaultsStorable with default value
    @UserDefaultOverride(.uuid)
    var uuid: String = "TESTING"

    // Optional Codable
    @UserDefaultOverride(.user, strategy: .json)
    var user: User?

    // RawRepresentable with default value
    @UserDefaultOverride(.state)
    var state: State = .unregistered

    // Optional RawRepresentable
    @UserDefaultOverride(.lastState)
    var lastState: State?

    // Optional UserDefaultsStorable
    @UserDefaultOverride(.isLegacyUser)
    var isLegacyUser: Bool?

    // Optional UserDefaultsStorable
    @UserDefaultOverride(.lastVisitDate)
    var lastVisitDate: Date?

    // Codable with default value
    @UserDefaultOverride(.windowPreferences, strategy: .json)
    var windowPreferences: WindowPreferences = WindowPreferences()

    // The device locale to mock, can't be represented as a single @UserDefaultOverride
    var deviceLocale: Locale = Locale(identifier: "en_US")

    // Additonal Launch Arguments
    var additionalLaunchArguments: [String] {
        ["UI-Testing"]
    }
}

class LaunchArgumentEncodableTests: XCTestCase {
    func testEncodeLaunchArguments() throws {
        var configuration = AppConfiguration()
        configuration.user = AppConfiguration.User(name: "John")
        configuration.state = .registered
        configuration.lastState = .unregistered
        configuration.lastVisitDate = Date(timeIntervalSinceReferenceDate: 60 * 60 * 24)
        configuration.windowPreferences.isMinimizeEnabled = false

        let launchArguments = try configuration.encodeLaunchArguments()

        XCTAssertEqual(configuration.uuid, "TESTING")
        XCTAssertEqual(configuration.user, AppConfiguration.User(name: "John"))
        XCTAssertEqual(configuration.state, .registered)
        XCTAssertEqual(configuration.lastState, .unregistered)
        XCTAssertNil(configuration.isLegacyUser)
        XCTAssertEqual(configuration.lastVisitDate, Date(timeIntervalSinceReferenceDate: 60 * 60 * 24))
        XCTAssertEqual(configuration.windowPreferences.isMinimizeEnabled, false)

        XCTAssertEqual(launchArguments, [
            "-UUID", "<string>TESTING</string>",
            "-User", "<data>eyJuYW1lIjoiSm9obiJ9</data>",
            "-State", "<string>registered</string>",
            "-LastState", "<string>unregistered</string>",
            "-LastVisitDate", "<date>2001-01-02T00:00:00Z</date>",
            "-WindowPreferences", "<data>eyJpc0Z1bGxTY3JlZW5TdXBwb3J0ZWQiOmZhbHNlLCJpc01pbmltaXplRW5hYmxlZCI6ZmFsc2V9</data>",
            "UI-Testing"
        ])
    }

    func testProjectedValue() throws {
        // Given a property wrapper
        @UserDefaultOverride(.state)
        var state = AppConfiguration.State.registered

        // When the projected value is accessed
        let projectedValue = $state

        XCTAssertEqual(projectedValue.key, .state)
        XCTAssertEqual(try projectedValue.getValue() as? String, "registered")
    }
}
