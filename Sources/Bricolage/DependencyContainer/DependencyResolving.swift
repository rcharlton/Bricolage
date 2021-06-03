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
    func resolve<Resolved, Registrant: Hashable, Parameters>(
        _ type: Resolved.Type,
        using registrant: Registrant,
        parameters: Parameters
    ) throws -> Resolved

}

