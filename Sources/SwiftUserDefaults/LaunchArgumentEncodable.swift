import Foundation

/// A protocol used by container types that can have their representations encoded into launch arguments via the ``encodeLaunchArguments()`` method.
///
/// This protocol works exclusively in conjunction with the ``UserDefaultOverride`` property wrapper.
public protocol LaunchArgumentEncodable {
    /// Additional values to be appended to the result of `collectLaunchArguments()`.
    ///
    /// A default implementation is provided that returns an empty array.
    var additionalLaunchArguments: [String] { get }

    /// An array of types that represent UserDefault key/value overrides to be converted into launch arguments.
    ///
    /// A default implementation is provided that uses reflection to collect these values from the receiver.
    /// You are free to override and provide your own implementation if you would prefer.
    var userDefaultOverrides: [UserDefaultOverrideRepresentable] { get }
}

public extension LaunchArgumentEncodable {
    var additionalLaunchArguments: [String] {
        []
    }

    /// Uses reflection to collect properties that conform to `UserDefaultOverrideRepresentable` from the receiver.
    var userDefaultOverrides: [UserDefaultOverrideRepresentable] {
        Mirror(reflecting: self)
            .children
            .compactMap { $0.value as? UserDefaultOverrideRepresentable }
    }

    /// Collects the complete array of launch arguments from the receiver.
    ///
    /// The contents of the return value is built by using Reflection to look for all `@UserDefaultOverride` property wrapper instances. See ``UserDefaultOverride`` for more information.
    ///
    /// In addition to overrides, the contents of `additionalLaunchArguments` is appended to the return value.
    func encodeLaunchArguments() throws -> [String] {
        // Map the overrides into a container
        var container = UserDefaults.ValueContainer()
        for userDefaultOverride in userDefaultOverrides {
            // Add the storable value into the container only if it wasn't nil
            guard let value = try userDefaultOverride.getValue() else { continue }
            container.set(value, forKey: userDefaultOverride.key)
        }

        // Return the collected user default overrides along with any additional arguments
        return container.launchArguments + additionalLaunchArguments
    }
}
