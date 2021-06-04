//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

// TODO: add instance lifetime management & sharing

/// A general purpose container for storing and resolving type dependencies.
public class DependencyContainer: DependencyResolving, DependencyRegistering {

    public enum Error: Swift.Error {
        case existingRegistrantForType(Any.Type)
        case missingRegistrantForType(Any.Type)
    }

    private struct Key: Hashable {

        let resolvedType: Any.Type
        let parametersType: Any.Type
        let registrant: AnyHashable

        static func == (lhs: Key, rhs: Key) -> Bool {
            lhs.resolvedType == rhs.resolvedType
                && lhs.parametersType == rhs.parametersType
                && lhs.registrant == rhs.registrant
        }

        public func hash(into hasher: inout Hasher) {
            ObjectIdentifier(resolvedType).hash(into: &hasher)
            ObjectIdentifier(parametersType).hash(into: &hasher)
            registrant.hash(into: &hasher)
        }

    }

    private var resolvers: [Key: Any] = [:]

    public init() {
    }

    public func resolve<Resolved, Registrant, Parameters>(
        _ type: Resolved.Type,
        using registrant: Registrant,
        parameters: Parameters
    ) throws -> Resolved where Registrant: Hashable {
        let key = Key(resolvedType: type, parametersType: Parameters.self, registrant: registrant)
        guard let resolver = resolvers[key] as? Resolver<Resolved, Parameters> else {
            throw Error.missingRegistrantForType(type)
        }
        return try resolver(self, parameters)
    }

    public func register<Resolved, Registrant, Parameters>(
        _ registrant: Registrant,
        type: Resolved.Type,
        resolver: @escaping Resolver<Resolved, Parameters>
    ) throws where Registrant: Hashable {
        let key = Key(resolvedType: type, parametersType: Parameters.self, registrant: registrant)
        guard resolvers[key] == nil else {
            throw Error.existingRegistrantForType(type)
        }
        resolvers[key] = resolver
   }

}
