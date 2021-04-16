//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Bricolage
import Foundation

struct StubDecoder<Success, FailureDetails>: StatusCodeResponseDecoding {

    typealias Success = Success
    typealias Failure = StatusCodeResponseDecodingError<FailureDetails>
    typealias FailureDetails = FailureDetails

    let successStatusCodes: AnyCollection<Int>
    let success: Result<Success, Error>
    let failureDetails: Result<FailureDetails, Error>

    func decodeSuccess(from data: Data?) throws -> Success {
        try success.get()
    }

    func decodeFailureDetails(from data: Data?) throws -> FailureDetails {
        try failureDetails.get()
    }

}

extension StatusCodeResponseDecodingError: Equatable where FailureDetails: Equatable {

    public static func ==(
        lhs: StatusCodeResponseDecodingError,
        rhs: StatusCodeResponseDecodingError
    ) -> Bool {
        switch (lhs, rhs) {
        case let (.statusCodeIsFailure(lhsStatusCode, lhsFailureDetails),
                  .statusCodeIsFailure(rhsStatusCode, rhsFailureDetails)):
            return lhsStatusCode == rhsStatusCode && lhsFailureDetails == rhsFailureDetails

        case let (.failedToDecodeType(lhsType, _), .failedToDecodeType(rhsType, _)):
            return lhsType == rhsType

        default:
            return false
        }
    }

}
