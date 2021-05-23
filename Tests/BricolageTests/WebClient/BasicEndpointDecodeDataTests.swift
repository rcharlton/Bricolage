//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class BasicEndpointDecodeDataTests : XCTestCase {

    private typealias StubDecoder = BricolageTests.StubDecoder<String, Int>

    private enum Constant {
        static let someURL = URL(string: "A://SOME_URL")!
        static let someError = NSError(domain: "TEST", code: 123)
        static let successStatusCodes = AnyCollection([123])
    }

    private func givenDecodingResults(
        success: Result<String, Error> = .success("SUCCESS"),
        failureDetails: Result<Int, Error> = .success(999)
    ) -> StubDecoder {
        StubDecoder(
            successStatusCodes: Constant.successStatusCodes,
            success: success,
            failureDetails: failureDetails
        )
    }

    private func whenDecodeResponse(using decoder: StubDecoder, statusCode: Int) -> StubDecoder.Result {
        let response = HTTPURLResponse(url: Constant.someURL, statusCode: statusCode)
        return decoder.decodeData(Data(), for: response)
    }

    // MARK: -

    func testDecodeDataWithSuccessStatusCode_DecoderSucceeds_ResultIsSuccess() {
        let decoder = givenDecodingResults(success: .success("SUCCESS"))

        let result = whenDecodeResponse(using: decoder, statusCode: 123)

        XCTAssertEqual(result.success, "SUCCESS")
    }

    func testDecodeDataWithFailureStatusCode_DecoderSucceeds_ResultIsStatusCodeIsFailure() {
        let decoder = givenDecodingResults(failureDetails: .success(999))

        let result = whenDecodeResponse(using: decoder, statusCode: 456)

        XCTAssertEqual(result.failure, .statusCodeIsFailure(456, details: 999))
    }

    func testDecodeDataWithSuccessStatusCode_DecoderFails_ResultIsFailedToDecodeType() {
        let decoder = givenDecodingResults(success: .failure(Constant.someError))

        let result = whenDecodeResponse(using: decoder, statusCode: 123)

        XCTAssertEqual(
            result.failure,
            .failedToDecodeType("\(StubDecoder.Success.self)", error: Constant.someError)
        )
    }

    func testDecodeDataWithFailureStatusCode_DecoderFails_ResultIsFailedToDecodeType() {
        let decoder = givenDecodingResults(failureDetails: .failure(Constant.someError))

        let result = whenDecodeResponse(using: decoder, statusCode: 456)

        XCTAssertEqual(
            result.failure,
            .failedToDecodeType("\(StubDecoder.FailureDetails.self)", error: Constant.someError)
        )
    }

}
