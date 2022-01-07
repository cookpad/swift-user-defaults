import Foundation

/// A protocol used by container types that can have their representations encoded into launch arguments via the ``encodeLaunchArguments()`` method.
///
/// This protocol works exclusively in conjunction with the ``UserDefaultOverride`` property wrapper.
public protocol LaunchArgumentEncodable {
    /// Additional values to be appended to the result of `collectLaunchArguments()`.
    ///
    /// A default implementation is provided that returns an empty array.
    var additionalLaunchArguments: [String] { get }
}

public extension LaunchArgumentEncodable {
    var additionalLaunchArguments: [String] {
        []
    }

    /// Collects the complete array of launch arguments from the receiver.
    ///
    /// The contents of the return value is built by using Reflection to look for all `@UserDefaultOverride` property wrapper instances. See ``UserDefaultOverride`` for more information.
    ///
    /// In addition to overrides, the contents of `additionalLaunchArguments` is appended to the return value.
    func encodeLaunchArguments() throws -> [String] {
        let mirror = Mirror(reflecting: self)
        var container = UserDefaults.ValueContainer()

        for child in mirror.children {
            if let override = child.value as? UserDefaultOverrideRepresentable, let value = try override.getValue() {
                container.set(value, forKey: override.key)
            }
        }

        return container.launchArguments + additionalLaunchArguments
    }
}
