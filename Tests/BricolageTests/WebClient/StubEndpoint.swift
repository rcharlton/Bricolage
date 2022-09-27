//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation
@testable import Bricolage

/// Stubs provide canned responses to calls during a test.
struct StubEndpoint: Endpoint {

    typealias Success = (data: Data, response: HTTPURLResponse)
    typealias Failure = (data: Data, response: HTTPURLResponse)

    let successStatusCodes: AnyCollection<Int>

    private let urlRequest: URLRequest?

    private let decodingError: Error?

    init(
        url: URL?,
        successStatusCodes: AnyCollection<Int> = AnyCollection([200]),
        decodingError: Error? = nil
    ) {
        self.urlRequest = url.map { URLRequest(url: $0) }
        self.successStatusCodes = successStatusCodes
        self.decodingError = decodingError
    }

    func urlRequest(relativeTo url: URL) -> URLRequest? {
        urlRequest
    }

    func decodeSuccess(from data: Data, response: HTTPURLResponse) throws -> Success {
        guard let decodingError = self.decodingError else {
            return (data: data, response: response)
        }
        throw decodingError
    }

    func decodeFailure(from data: Data, response: HTTPURLResponse) throws -> Failure {
        (data: data, response: response)
    }
}

enum StubError: Equatable, Error {
    case someError
}

extension StubEndpoint: Equatable {

    static func == (lhs: StubEndpoint, rhs: StubEndpoint) -> Bool {
        guard lhs.successStatusCodes.count == rhs.successStatusCodes.count else { return false }

        let lhsStatusCodes = lhs.successStatusCodes.reduce(into: Set<Int>()) { $0.insert($1) }
        let rhsStatusCodes = rhs.successStatusCodes.reduce(into: Set<Int>()) { $0.insert($1) }

        return lhsStatusCodes == rhsStatusCodes && lhs.urlRequest == rhs.urlRequest
    }

}
