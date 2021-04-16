//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class BasicEndpointDecodingOverridesTests : XCTestCase {

    private enum Constant {
        static let someURL = URL(string: "A://SOME_URL")!
        static let someModel = StubModel(value: "MODEL")
        static let validData = try! JSONEncoder().encode(someModel)
        static let invalidData = "DATA".data(using: .utf8)!
    }

    // MARK: - decodeSuccess: Success is Decodable

    func testDecodeDecodableSuccess_DataIsValid_ResultIsModel() throws {
        let decoder = ModelVoidDecoder()

        let success = try decoder.decodeSuccess(from: Constant.validData)

        XCTAssertEqual(success, Constant.someModel)
    }

    func testDecodeDecodableSuccess_DataIsInvalid_ExceptionIsThrown() throws {
        let decoder = ModelVoidDecoder()

        XCTAssertThrowsError(try decoder.decodeSuccess(from: Constant.invalidData))
    }

    func testDecodeDecodableSuccess_DataIsNil_ExceptionIsThrown() throws {
        let decoder = ModelVoidDecoder()

        XCTAssertThrowsError(try decoder.decodeSuccess(from: nil))
    }

    // MARK: - decodeSuccess: Success is Void

    func testDecodeVoidSuccess_DataIsInvalid_VoidIsReturned() throws {
        let decoder = VoidModelDecoder()

        let success: Void = try decoder.decodeSuccess(from: Constant.invalidData)

        XCTAssert(success == ())
    }

    func testDecodeVoidSuccess_DataIsNil_VoidIsReturned() throws {
        let decoder = VoidModelDecoder()

        let success: Void = try decoder.decodeSuccess(from: nil)

        XCTAssert(success == ())
   }

    // MARK: - decodeFailureDetails: FailureDetails is Decodable

    func testDecodeDecodableFailureDetails_DataIsValid_ResultIsModel() throws {
        let decoder = VoidModelDecoder()

        let success = try decoder.decodeFailureDetails(from: Constant.validData)

        XCTAssertEqual(success, Constant.someModel)
    }

    func testDecodeDecodableFailureDetails_DataIsInvalid_ExceptionIsThrown() throws {
        let decoder = VoidModelDecoder()

        XCTAssertThrowsError(try decoder.decodeFailureDetails(from: Constant.invalidData))
    }

    func testDecodeDecodableFailureDetails_DataIsNil_ExceptionIsThrown() throws {
        let decoder = VoidModelDecoder()

        XCTAssertThrowsError(try decoder.decodeFailureDetails(from: nil))
    }

    // MARK: - decodeFailureDetails: FailureDetails is Void

    func testDecodeVoidFailureDetails_DataIsInvalid_VoidIsReturned() throws {
        let decoder = ModelVoidDecoder()

        let success: Void = try decoder.decodeFailureDetails(from: Constant.invalidData)

        XCTAssert(success == ())
    }

    func testDecodeVoidFailureDetails_DataIsNil_VoidIsReturned() throws {
        let decoder = ModelVoidDecoder()

        let success: Void = try decoder.decodeFailureDetails(from: nil)

        XCTAssert(success == ())
   }

}

private struct ModelVoidDecoder: StatusCodeResponseDecoding {

    typealias Success = StubModel
    typealias Failure = StatusCodeResponseDecodingError<Void>
    typealias FailureDetails = Void

}

private struct VoidModelDecoder: StatusCodeResponseDecoding {

    typealias Success = Void
    typealias Failure = StatusCodeResponseDecodingError<StubModel>
    typealias FailureDetails = StubModel

}

private struct StubModel: Codable, Equatable {
    let value: String
}
