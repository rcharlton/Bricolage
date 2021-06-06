//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

// TODO: convenience methods

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

    private class Coordinator<Resolved, Parameters> {
        let resolver: Resolver<Resolved, Parameters>
        let options: ResolvingOptions
        var reference: Reference<Resolved>?

        init(resolver: @escaping Resolver<Resolved, Parameters>, options: ResolvingOptions) {
            self.resolver = resolver
            self.options = options
        }

        func resolve(dependencyResolver: DependencyResolving, parameters: Parameters) throws -> Resolved {
            guard let instance = reference?.instance else {
                let instance = try resolver(dependencyResolver, parameters)
                switch options {
                case [.shared, .retained]:
                    reference = .strong(instance)
                case .shared:
                    reference = .weak(instance)
                default:
                    break
                }
                return instance
            }
            return instance
        }
    }

    private var coordinators: [Key: Any] = [:]

    public init() {
    }

    public func resolve<Resolved, Registrant: Hashable, Parameters>(
        _ type: Resolved.Type,
        using registrant: Registrant,
        parameters: Parameters
    ) throws -> Resolved {
        let key = Key(resolvedType: type, parametersType: Parameters.self, registrant: registrant)
        guard let coordinator = coordinators[key] as? Coordinator<Resolved, Parameters> else {
            throw Error.missingRegistrantForType(type)
        }
        return try coordinator.resolve(dependencyResolver: self, parameters: parameters)
    }

    public func register<Resolved, Registrant: Hashable, Parameters>(
        _ registrant: Registrant,
        type: Resolved.Type,
        options: ResolvingOptions,
        resolver: @escaping Resolver<Resolved, Parameters>
    ) throws {
        let key = Key(resolvedType: type, parametersType: Parameters.self, registrant: registrant)
        guard coordinators[key] == nil else {
            throw Error.existingRegistrantForType(type)
        }
        coordinators[key] = Coordinator(resolver: resolver, options: options)
   }

}
