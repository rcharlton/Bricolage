//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class ConfigureTests: XCTestCase {

    private class ReferenceType {
        var value: String

        init(value: String) {
            self.value = value
        }
    }

    func testConfigureValueType_ClosureMutatesInput_OutputIsModified() {
        let input = "one"
        let output = configure(input) { $0 += " two" }
        XCTAssertEqual(input, "one")
        XCTAssertEqual(output, "one two")
    }

    func testConfigureReferenceType_ClosureMutatesInput_OutputIsModified() {
        let input = ReferenceType(value: "one")
        let output = configure(input) { $0.value += " two" }
        XCTAssertEqual(output.value, "one two")
    }

}
