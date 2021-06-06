//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class DependencyContainerTests: XCTestCase {

    let container = DependencyContainer()

    override func setUpWithError() throws {
        try container.register(
            Resolver.one,
            type: ProtocolA.self,
            options: []
        ) { (_, parameters: String) in
            SpyA(resolver: Resolver.one, parameters: parameters)
        }

        try container.register(
            Resolver.two,
            type: ProtocolA.self,
            options: [.shared]
        ) { (_, parameters: String) in
            SpyA(resolver: Resolver.two, parameters: parameters)
        }

        try container.register(
            Resolver.three,
            type: (ProtocolA & ProtocolB).self,
            options: [.shared, .retained]
        ) { (_, parameters: String) in
            SpyB(resolver: Resolver.one, parameters: parameters)
        }
    }

    // MARK: - Resolving

    func testResolve_MultipleResolversAreRegistratedForType_CorrectResolverIsInvoked() throws {
        let resolvedA = try container.resolve(
            ProtocolA.self,
            using: Resolver.one,
            parameters: ""
        ) as? SpyA

        XCTAssertEqual(resolvedA?.resolver, Resolver.one)

        let resolvedB = try container.resolve(
            ProtocolA.self,
            using: Resolver.two,
            parameters: ""
        ) as? SpyA

        XCTAssertEqual(resolvedB?.resolver, Resolver.two)
    }

    func testResolve_TypeIsComposed_CorrectResolverIsInvoked() throws {
        let resolved = try container.resolve(
            (ProtocolA & ProtocolB).self,
            using: Resolver.three,
            parameters: ""
        ) as? SpyB

        XCTAssertNotNil(resolved)
    }

    func testResolve_ResolversAreRegistratedForType_ResolverIsInvokedWithCorrectParameters() throws {
        let resolved = try container.resolve(
            ProtocolA.self,
            using: Resolver.one,
            parameters: "PARAMETERS"
        ) as? SpyA

        XCTAssertEqual(resolved?.parameters, "PARAMETERS")
    }

    // MARK: - Options: []

    func testResolve_RegistrationOptionsIsEmpty_ResolvedInstanceIsNotShared() throws {
        let resolvedA = try container.resolve(
            ProtocolA.self,
            using: Resolver.one,
            parameters: ""
        )
        let resolvedB = try container.resolve(
            ProtocolA.self,
            using: Resolver.one,
            parameters: ""
        )

        XCTAssert(resolvedA !== resolvedB)
    }

    func testResolve_RegistrationOptionsIsEmpty_ResolvedInstanceIsNotRetained() throws {
        weak var resolved: ProtocolA? = try container.resolve(
            ProtocolA.self,
            using: Resolver.one,
            parameters: ""
        )

        XCTAssertNil(resolved)
    }

    // MARK: - Options: [.shared]

    func testResolve_RegistrationOptionsIsShared_ResolvedInstanceIsShared() throws {
        let resolvedA = try container.resolve(
            ProtocolA.self,
            using: Resolver.two,
            parameters: ""
        )
        let resolvedB = try container.resolve(
            ProtocolA.self,
            using: Resolver.two,
            parameters: ""
        )

        XCTAssert(resolvedA === resolvedB)
    }

    func testResolve_RegistrationOptionsIsShared_ResolvedInstanceIsNotRetained() throws {
        weak var resolved: ProtocolA? = try container.resolve(
            ProtocolA.self,
            using: Resolver.two,
            parameters: ""
        )

        XCTAssertNil(resolved)
    }

    // MARK: - Options: [.shared, .retained]

    func testResolve_RegistrationOptionsIsSharedAndRetained_ResolvedInstanceIsShared() throws {
        let resolvedA = try container.resolve(
            (ProtocolA & ProtocolB).self,
            using: Resolver.three,
            parameters: ""
        )
        let resolvedB = try container.resolve(
            (ProtocolA & ProtocolB).self,
            using: Resolver.three,
            parameters: ""
        )

        XCTAssert(resolvedA === resolvedB)
    }

    func testResolve_RegistrationOptionsIsSharedAndRetained_ResolvedInstanceIsRetained() throws {
        weak var resolved: (ProtocolA & ProtocolB)? = try container.resolve(
            (ProtocolA & ProtocolB).self,
            using: Resolver.three,
            parameters: ""
        )

        XCTAssertNotNil(resolved)
    }

}

private enum Resolver {
    case one, two, three
}

private protocol ProtocolA: AnyObject { }

private protocol ProtocolB: AnyObject { }

private class SpyA: ProtocolA {

    let resolver: Resolver
    let parameters: String

    init(resolver: Resolver, parameters: String) {
        self.resolver = resolver
        self.parameters = parameters
    }

}

private class SpyB: ProtocolA, ProtocolB {

    let resolver: Resolver
    let parameters: String

    init(resolver: Resolver, parameters: String) {
        self.resolver = resolver
        self.parameters = parameters
    }

}
