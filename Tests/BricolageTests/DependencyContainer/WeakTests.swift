//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class WeakTests: XCTestCase {

    func testReleaseOtherReferences_WeakReference_InstanceIsNil() {
        var strong: Class? = Class()
        let weak = Weak<Protocol>(strong!)
        XCTAssertNotNil(weak.instance)

        strong = nil

        XCTAssertNil(weak.instance)
    }

}

private protocol Protocol { }

private class Class: Protocol { }
