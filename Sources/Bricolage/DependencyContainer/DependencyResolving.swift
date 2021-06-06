//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

public protocol DependencyResolving {

    /**
     enum Resolver: Hashable {
        case remoteUserService
        case cachedUserService
     }

     let userService = try resolve(
         UserService.self,
         using: Resolver.cachedUserService,
         parameters: [UserService.Option.one]
     )
     */
    func resolve<Resolved: AnyObject, Registrant: Hashable, Parameters>(
        _ type: Resolved.Type,
        using registrant: Registrant,
        parameters: Parameters
    ) throws -> Resolved

}

extension DependencyResolving {

    /// Resolve without parameters
    func resolve<Resolved: AnyObject, Registrant: Hashable>(
        _ type: Resolved.Type,
        using registrant: Registrant
    ) throws -> Resolved {
        try resolve(type, using: registrant, parameters: ())
    }

    /// Resolve without parameters and using default registrant.
    func resolve<Resolved: AnyObject>(_ type: Resolved.Type) throws -> Resolved {
        try resolve(type, using: Constant.defaultRegistrant, parameters: ())
    }

    /// Resolve using default registrant.
    func resolve<Resolved: AnyObject, Parameters>(
        _ type: Resolved.Type,
        parameters: Parameters
    ) throws -> Resolved {
        try resolve(type, using: Constant.defaultRegistrant, parameters: parameters)
    }

}
