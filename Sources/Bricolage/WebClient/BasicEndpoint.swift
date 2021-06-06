//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

public typealias BasicEndpoint = RequestProviding & StatusCodeResponseDecoding

public protocol StatusCodeResponseDecoding: ResponseDecoding
where Failure == StatusCodeResponseDecodingError<FailureDetails> {

    associatedtype FailureDetails

    var successStatusCodes: AnyCollection<Int> { get }

    var decoder: Decoding { get }

    func decodeSuccess(from data: Data?) throws -> Success

    func decodeFailureDetails(from data: Data?) throws -> FailureDetails

}

public extension StatusCodeResponseDecoding {

    var successStatusCodes: AnyCollection<Int> { AnyCollection(200..<400) }

    var decoder: Decoding { JSONDecoder() }

    func decodeData(_ data: Data?, for response: HTTPURLResponse) -> Result {
        if successStatusCodes.contains(response.statusCode) {
            return Swift.Result { try decodeSuccess(from: data) }
                .mapError { .failedToDecodeType("\(Success.self)", error: $0) }
        } else {
            return Swift.Result { try decodeFailureDetails(from: data) }
                .mapError { .failedToDecodeType("\(FailureDetails.self)", error: $0) }
                .flatMap { .failure(.statusCodeIsFailure(response.statusCode, details: $0)) }
        }
    }

}

public extension StatusCodeResponseDecoding where Success: Decodable {

    func decodeSuccess(from data: Data?) throws -> Success {
        let data = data ?? Data()
        return try decoder.decode(Success.self, from: data)
    }

}

public extension StatusCodeResponseDecoding where Success == Void {

    func decodeSuccess(from data: Data?) throws -> Success {
        ()
    }

}

public extension StatusCodeResponseDecoding where FailureDetails: Decodable {

    func decodeFailureDetails(from data: Data?) throws -> FailureDetails {
        let data = data ?? Data()
        return try decoder.decode(FailureDetails.self, from: data)
    }

}

public extension StatusCodeResponseDecoding where FailureDetails == Void {

    func decodeFailureDetails(from data: Data?) throws -> FailureDetails {
        ()
    }

}

// MARK: -

public enum StatusCodeResponseDecodingError<FailureDetails>: Error {

    case statusCodeIsFailure(Int, details: FailureDetails)

    case failedToDecodeType(String, error: Swift.Error)

}
