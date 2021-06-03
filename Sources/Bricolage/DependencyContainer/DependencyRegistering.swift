//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

public typealias Resolver<Resolved, Parameters> = (DependencyResolving, Parameters) throws -> Resolved

public protocol DependencyRegistering {

    /**
    try register(Resolver.remoteUserService, type: UserService.self) { (resolver, parameters) in
        RemoteUserService(configuration: parameters)
    }
    */
    func register<Resolved, Registrant: Hashable, Parameters>(
        _ registrant: Registrant,
        type: Resolved.Type,
        resolver: @escaping Resolver<Resolved, Parameters>
    ) throws

}


