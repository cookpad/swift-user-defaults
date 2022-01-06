import Foundation

/// A protocol used by container types that can have their representations encoded into launch arguments via the ``encodeLaunchArguments()`` method.
///
/// This protocol works exclusively in conjunction with the ``UserDefaultOverride`` property wrapper.
public protocol LaunchArgumentEncodable {
    /// Additional values to be apended to the result of `collectLaunchArguments()`.
    ///
    /// A default implementation is provided that returns an empty array.
    var additionalLaunchArguments: [String] { get }
}

public extension LaunchArgumentEncodable {
    var additionalLaunchArguments: [String] {
        []
    }

    /// Collects the complete array of launch arguments from the reciever.
    ///
    /// The contents of the return value is built by using Reflection to look for all `@UserDefaultOverride` property wrapper instances. See ``UserDefaultOverride`` for more information.
    ///
    /// In addition to overrides, the contents of `additionalLaunchArguments` is apended to the return value.
    func encodeLaunchArguments() throws -> [String] {
        let mirror = Mirror(reflecting: self)
        var container = UserDefaults.ValueContainer()

        for child in mirror.children {
            if let argument = child.value as? UserDefaultKeyValueRepresentable, let (key, value) = try argument.keyValuePair() {
                container.set(value, forKey: key)
            }
        }

        return container.launchArguments + additionalLaunchArguments
    }
}
