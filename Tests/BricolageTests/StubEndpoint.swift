//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation
@testable import Bricolage

/// Stubs provide canned responses to calls during a test.
struct StubEndpoint: Endpoint {

    enum Error: Equatable, Swift.Error {
        case someError
    }

    typealias Success = (data: Data?, response: HTTPURLResponse)
    typealias Failure = Error

    enum Behaviour {
        case succeedWithInputs
        case succeed(Data?, HTTPURLResponse)
        case fail(Error)
    }

    let urlRequest: URLRequest?

    private let behaviour: Behaviour

    init(urlRequest: URLRequest?, behaviour: Behaviour = .succeedWithInputs) {
        self.urlRequest = urlRequest
        self.behaviour = behaviour
    }

    func urlRequest(relativeTo url: URL) -> URLRequest? {
        urlRequest
    }

    func decodeData(_ data: Data?, for response: HTTPURLResponse) -> Result<Success, Failure> {
        switch behaviour {
        case .succeedWithInputs:
            return .success((data, response))
        case let .succeed(data, response):
            return .success((data, response))
        case .fail:
            return .failure(Error.someError)
        }
    }

}

extension StubEndpoint {

    var url: URL? {
        urlRequest?.url
    }

}
