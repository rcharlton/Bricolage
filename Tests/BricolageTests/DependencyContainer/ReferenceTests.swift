//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class ReferenceTests: XCTestCase {

    private var strong: P? = C()

    private var value: P {
        strong!
    }

    func releaseOtherReferences() {
        strong = nil
    }

    func testReleaseOtherReferences_StrongReference_InstanceIsNotNil() {
        let reference = Reference<P>.strong(value)
        XCTAssertNotNil(reference.instance)

        releaseOtherReferences()

        XCTAssertNotNil(reference.instance)
    }

    func testReleaseOtherReferences_WeakReference_InstanceIsNil() {
        let reference = Reference<P>.weak(value)
        XCTAssertNotNil(reference.instance)

        releaseOtherReferences()

        XCTAssertNil(reference.instance)
    }

}

private protocol P { }

private class C: P { }
