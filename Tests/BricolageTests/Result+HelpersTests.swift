//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation
import XCTest
@testable import Bricolage

class Result_HelpersTests : XCTestCase {

    private enum Constant {
        static let someValue = "VALUE"
        static let someError = NSError(domain: "DOMAIN", code: 123)
    }

    private typealias Result = Swift.Result<String, NSError>

    func testQuerySuccess_ValueIsSuccess_ValueIsReturned() {
        let result = Result.success(Constant.someValue)
        XCTAssertEqual(result.success, Constant.someValue)
    }

    func testQuerySuccess_ValueIsFailure_NilIsReturned() {
        let result = Result.failure(Constant.someError)
        XCTAssertNil(result.success)
    }

    func testQueryFailure_ValueIsFailure_ErrorIsReturned() {
        let result = Result.failure(Constant.someError)
        XCTAssertEqual(result.failure, Constant.someError)
    }

    func testQueryFailure_ValueIsSuccess_NilIsReturned() {
        let result = Result.success(Constant.someValue)
        XCTAssertNil(result.failure)
    }

}

