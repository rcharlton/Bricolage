//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class ResponseDecodingTests : XCTestCase {

    private enum Constant {
        static let someURL = URL(string: "A://SOME_URL")!
        static let someModel = StubModel(value: "MODEL")
        static let validData = try! JSONEncoder().encode(someModel)
        static let invalidData = "DATA".data(using: .utf8)!
        static let response = HTTPURLResponse()
    }

    // MARK: - decodeSuccess: Success is Decodable

    func testDecodeSuccess_DecodableDataIsValid_ResultIsModel() throws {
        let decoder = ModelVoidDecoder()

        let success = try decoder.decodeSuccess(from: Constant.validData, response: Constant.response)

        XCTAssertEqual(success, Constant.someModel)
    }

    func testDecodeSuccess_DecodableDataIsInvalid_ExceptionIsThrown() throws {
        let decoder = ModelVoidDecoder()

        XCTAssertThrowsError(
            try decoder.decodeSuccess(from: Constant.invalidData, response: Constant.response)
        )
    }

    // MARK: - decodeSuccess: Success is Void

    func testDecodeSuccess_VoidDataIsInvalid_VoidIsReturned() throws {
        let decoder = VoidModelDecoder()

        let success: Void = try decoder.decodeSuccess(from: Constant.invalidData, response: Constant.response)

        XCTAssert(success == ())
    }

    // MARK: - decodeFailure: Failure is Decodable

    func testDecodeFailureDetails_DecodableDataIsValid_ResultIsModel() throws {
        let decoder = VoidModelDecoder()

        let failure = try decoder.decodeFailure(from: Constant.validData, response: Constant.response)

        XCTAssertEqual(failure, Constant.someModel)
    }

    func testDecodeFailureDetails_DecodableDataIsInvalid_NoExceptionIsThrown() throws {
        let decoder = VoidModelDecoder()

        XCTAssertThrowsError(
            try decoder.decodeFailure(from: Constant.invalidData, response: Constant.response)
        )
    }

    // MARK: - decodeFailure: Failure is Void

    func testDecodeFailure_VoidDataIsInvalid_VoidIsReturned() throws {
        let decoder = ModelVoidDecoder()

        let failure: Void = try decoder.decodeFailure(from: Constant.invalidData, response: Constant.response)

        XCTAssert(failure == ())
    }

}

private struct ModelVoidDecoder: ResponseDecoding {

    typealias Success = StubModel
    typealias Failure = Void

}

private struct VoidModelDecoder: ResponseDecoding {

    typealias Success = Void
    typealias Failure = StubModel

}

private struct StubModel: Codable, Equatable {
    let value: String
}
