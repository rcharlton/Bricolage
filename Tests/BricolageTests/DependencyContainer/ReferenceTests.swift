//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class ReferenceTests: XCTestCase {

    private var strong: Protocol? = Class()

    private var value: Protocol {
        strong!
    }

    func releaseOtherReferences() {
        strong = nil
    }

    func testReleaseOtherReferences_StrongReference_InstanceIsNotNil() {
        let reference = Reference<Protocol>.strong(value)
        XCTAssertNotNil(reference.instance)

        releaseOtherReferences()

        XCTAssertNotNil(reference.instance)
    }

    func testReleaseOtherReferences_WeakReference_InstanceIsNil() {
        let reference = Reference<Protocol>.weak(value)
        XCTAssertNotNil(reference.instance)

        releaseOtherReferences()

        XCTAssertNil(reference.instance)
    }

}

private protocol Protocol { }

private class Class: Protocol { }
