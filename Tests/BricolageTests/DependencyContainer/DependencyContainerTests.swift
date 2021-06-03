//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class DependencyResolverTests : XCTestCase {

    func test() throws {
        let container = DependencyContainer()
        try container.register("TestResolver", type: AbstractType.self) { (resolver, parameters: Void) in
            ConcreteType()
        }
        _ = try container.resolve(AbstractType.self, using: "TestResolver", parameters: ())
    }
}

private protocol AbstractType {
}

private class ConcreteType: AbstractType {
}
