//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class WeakTests: XCTestCase {

    func testReleaseOtherReferences_WeakReference_InstanceIsNil() {
        var strong: C? = C()
        let weak = Weak<P>(strong!)
        XCTAssertNotNil(weak.instance)

        strong = nil

        XCTAssertNil(weak.instance)
    }

}

private protocol P { }

private class C: P { }
