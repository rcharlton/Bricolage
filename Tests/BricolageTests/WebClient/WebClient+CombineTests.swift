//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

#if canImport(Combine)

import Combine
import XCTest
@testable import Bricolage

extension WebClientTests {

    func whenInvokeEndpointReturningFuture<E: Endpoint>(
        _ endpoint: E,
        then: @escaping (InvocationResult<E>) -> Void
    ) {
        let expectation = self.expectation(description: "Task completes")
        var cancellable: Combine.Cancellable?

        let complete = { (result: InvocationResult<E>) in
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
        let endpoint = StubEndpoint(urlRequest: nil)

        whenInvokeEndpointReturningFuture(endpoint) { result in
            XCTAssertEqual(
                result.failure,
                InvocationError<StubEndpoint>.endpointIsMisconfigured(endpoint)
            )
        }
    }

    func testInvokeEndpointReturningFuture_URLRequestSucceeds_DataAndResponseAreCorrect() {
        let endpoint = StubEndpoint(urlRequest: Constant.someURLRequest)

        given(data: Constant.someData, statusCode: 200, for: endpoint)

        whenInvokeEndpointReturningFuture(endpoint) { result in
            XCTAssertEqual(result.success?.data, Constant.someData)
            XCTAssertEqual(result.success?.response.statusCode, 200)
        }
    }

    func testInvokeEndpointReturning_EndpointFails_ResultIsFailedToDecodeData() throws {
        let endpoint = StubEndpoint(
            urlRequest: Constant.someURLRequest,
            behaviour: .fail(StubEndpoint.Error.someError)
        )

        given(data: Constant.someData, statusCode: 200, for: endpoint)

        whenInvokeEndpointReturningFuture(endpoint) { result in
            XCTAssertEqual(result.failure, .decodeFailedWithError(StubEndpoint.Error.someError))
        }
    }

}

#endif
