//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class Comparable_ClampedTests: XCTestCase {

    // MARK: - ClosedRange

    let closedRange = -10...10

    func testClampedToClosedRange_InputIsVerySmall_LowerBoundIsReturned() {
        XCTAssertEqual(Int.min.clamped(to: closedRange), range.lowerBound)
    }

    func testClampedToClosedRange_InputIsWithinRange_InputIsReturned() {
       XCTAssertEqual(0.clamped(to: closedRange), 0)
    }

    func testClampedToClosedRange_InputIsVeryLarge_UpperBoundIsReturned() {
        XCTAssertEqual(Int.max.clamped(to: closedRange), range.upperBound)
    }

    // MARK: - Range

    let range = -10..<10

    func testClampedToRange_InputIsVerySmall_LowerBoundIsReturned() {
        XCTAssertEqual(Int.min.clamped(to: range), range.lowerBound)
    }

    func testClampedToRange_InputIsWithinRange_InputIsReturned() {
       XCTAssertEqual(0.clamped(to: range), 0)
    }

    func testClampedToRange_InputIsVeryLarge_MaxIsReturned() {
        XCTAssertEqual(Int.max.clamped(to: range), range.max()!)
    }

}
