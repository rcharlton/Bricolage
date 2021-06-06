//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

public typealias Resolver<Resolved, Parameters> = (DependencyResolving, Parameters) throws -> Resolved

public struct ResolvingOptions: OptionSet {

    public let rawValue: Int

    /// A single shared instance is created. By default this is not retained.
    public static let shared = ResolvingOptions(rawValue: 1 << 0)

    /// Applicable only with .shared. Ensures the instance is independently retained.
    public static let retained = ResolvingOptions(rawValue: 1 << 1)

    public static var `default`: ResolvingOptions = [Self.shared, Self.retained]

    public init(rawValue: Int) {
        self.rawValue = rawValue.clamped(to: 0...3)
    }

}

public protocol DependencyRegistering {

    /**
    try register(Resolver.remoteUserService, type: UserService.self, options: []) { (resolver, parameters) in
        RemoteUserService(configuration: parameters)
    }
    */
    func register<Resolved, Registrant: Hashable, Parameters>(
        _ registrant: Registrant,
        type: Resolved.Type,
        options: ResolvingOptions,
        resolver: @escaping Resolver<Resolved, Parameters>
    ) throws

}

// MARK: -

enum Constant {
    static let defaultRegistrant = ""
}

public extension DependencyRegistering {

    /// Register with default options [.shared, .retained].
    func register<Resolved, Registrant: Hashable, Parameters>(
        _ registrant: Registrant,
        type: Resolved.Type,
        resolver: @escaping Resolver<Resolved, Parameters>
    ) throws {
        try register(Constant.defaultRegistrant, type: type, options: .default, resolver: resolver)
    }

    /// Register with default registrant.
    func register<Resolved, Parameters>(
        _ type: Resolved.Type,
        options: ResolvingOptions,
        resolver: @escaping Resolver<Resolved, Parameters>
    ) throws {
        try register(Constant.defaultRegistrant, type: type, options: options, resolver: resolver)
    }

    /// Register with default registrant and options.
    func register<Resolved, Parameters>(
        _ type: Resolved.Type,
        resolver: @escaping Resolver<Resolved, Parameters>
    ) throws {
        try register(Constant.defaultRegistrant, type: type, options: .default, resolver: resolver)
    }

    /// Register instance.
    func register<Resolved, Registrant: Hashable>(
        _ registrant: Registrant,
        type: Resolved.Type,
        instance: Resolved
    ) throws {
        try register(registrant, type: type, options: [.shared, .retained]) { (_, _: Void) in
            instance
        }
    }

    /// Register instance with default registrant.
    func register<Resolved>(type: Resolved.Type, instance: Resolved) throws {
        try register(Constant.defaultRegistrant, type: type, instance: instance)
    }

}
