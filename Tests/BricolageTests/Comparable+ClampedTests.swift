//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class Comparable_ClampedTests: XCTestCase {

    let range = 0...10

    func testClamped_InputIsVerySmall_LowerBoundIsReturned() {
        XCTAssertEqual(Int.min.clamped(to: range), range.lowerBound)
    }

    func testClamped_InputIsWithinRange_InputIsReturned() {
       XCTAssertEqual(0.clamped(to: range), 0)
    }

    func testClamped_InputIsVeryLarge_UpperBoundIsReturned() {
        XCTAssertEqual(Int.max.clamped(to: range), range.upperBound)
    }

}
