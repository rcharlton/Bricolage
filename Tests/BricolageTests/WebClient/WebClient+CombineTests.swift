//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

#if canImport(Combine)

import Combine
import XCTest
@testable import Bricolage

extension WebClientTests {
    typealias EndpointResult<E: Endpoint> = Result<E.Success, Error>

    func whenInvokeEndpointReturningFuture<E: Endpoint>(
        _ endpoint: E,
        then: @escaping (EndpointResult<E>) -> Void
    ) {
        let expectation = self.expectation(description: "Task completes")
        var cancellable: Combine.Cancellable?

        let complete = { (result: EndpointResult<E>) in
            _ = cancellable
            cancellable = nil
            expectation.fulfill()
            then(result)
        }

        cancellable = webClient.invoke(endpoint: endpoint)
            .sink { completion in
                if case let .failure(error) = completion {
                    complete(.failure(error))
                }
            } receiveValue: { value in
                complete(.success(value))
            }

        waitForExpectations(timeout: 1)
    }

    // MARK: -

    func testInvokeEndpointReturningFuture_URLRequestIsNil_ResultIsMisconfiguredEndpoint() {
        let endpoint = StubEndpoint(url: nil)

        whenInvokeEndpointReturningFuture(endpoint) { result in
            if let failure = result.failure,
               case EndpointError<StubEndpoint>.endpointIsMisconfigured(endpoint) = failure {
            } else {
                XCTFail("Unexpected result")
            }
        }
    }

    func testInvokeEndpointReturningFuture_URLRequestFails_ThrowsDataTaskFailedWithError() {
        let endpoint = StubEndpoint(url: Constant.requestURL)
        let nsError = NSError(domain: "WebClient", code: 123)
        given(error: nsError, for: endpoint)

        whenInvokeEndpointReturningFuture(endpoint) { result in
            if let failure = result.failure,
               case let StubEndpointError.dataTaskFailedWithError(error) = failure {
                XCTAssertEqual(error.domain, nsError.domain)
                XCTAssertEqual(error.code, nsError.code)
            } else {
                XCTFail("Unexpected result")
            }
        }
    }

}

#endif
