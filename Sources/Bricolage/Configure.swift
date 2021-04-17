//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

/// A generic configuration pattern.
/// - Parameters:
///   - resolve: An expression to provide the initial instance. Value types are copied.
///   - closure: An expression to mutate the provided instance.
/// - Returns:  The configured instance.
public func configure<T>(_ resolve: @autoclosure () -> T, with closure: (inout T) -> Void) -> T {
    var instance = resolve()
    closure(&instance)
    return instance
}
