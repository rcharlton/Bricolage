//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import XCTest
@testable import Bricolage

class WebClientTests: XCTestCase {

    private enum Constant {
        static let serviceURL = URL(string: "A://SERVICE_URL")!
        static let someURLRequest = URLRequest(url: URL(string: "A://REQUEST_URL")!)
        static let someData = "DATA".data(using: .utf8)!
        static let someError = NSError(domain: "DOMAIN", code: 123)
    }

    var webClient: WebClient!

    override func setUpWithError() throws {
        StubURLProtocol.clear()
        webClient = WebClient(serviceURL: Constant.serviceURL, urlSessionConfiguration: .test)
    }

    override func tearDownWithError() throws {
        StubURLProtocol.clear()
        webClient = nil
    }

    // MARK: -

    func given<E: Endpoint>(data: Data?, statusCode: Int?, for endpoint: E) {
        let urlRequest = webClient.urlRequest(for: endpoint)!
        let response = statusCode.map { HTTPURLResponse(url: urlRequest.url!, statusCode: $0) }
        StubURLProtocol.set(data: data, response: response, for: urlRequest)
    }

    func given<E: Endpoint>(error: Error, for endpoint: E) {
        let urlRequest = webClient.urlRequest(for: endpoint)!
        StubURLProtocol.set(error: error, for: urlRequest)
    }

    func whenInvokeEndpoint<E: Endpoint>(
        _ endpoint: E,
        then: @escaping (Cancellable?, WebClient.Result<E>) -> Void
    ) {
        let expectation = self.expectation(description: "Task completes")
        var result: WebClient.Result<E>?

        let cancellable = webClient.invoke(endpoint: endpoint) { (r: WebClient.Result<E>) in
            result = r
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        then(cancellable, result!)
    }

    // MARK: -

    func testInvokeEndpoint_URLRequestIsNil_CancellableIsNil() {
        let endpoint = StubEndpoint(urlRequest: nil)

        whenInvokeEndpoint(endpoint) { (cancellable, _) in
            XCTAssertNil(cancellable)
        }
    }

    func testInvokeEndpoint_URLRequestIsNil_ResultIsMisconfiguredEndpoint() {
        let endpoint = StubEndpoint(urlRequest: nil)

        whenInvokeEndpoint(endpoint) { (_, result) in
            XCTAssertEqual(
                result.failure,
                WebClient.Error<StubEndpoint>.endpointIsMisconfigured(endpoint)
            )
        }
    }

    func testInvokeEndpoint_URLRequestIsNotNil_CancellableIsNotNil() {
        let endpoint = StubEndpoint(urlRequest: Constant.someURLRequest)

        whenInvokeEndpoint(endpoint) { (cancellable, _) in
            XCTAssertNotNil(cancellable)
        }
    }

    func testInvokeEndpoint_URLRequestSucceeds_DataAndResponseAreCorrect() {
        let endpoint = StubEndpoint(urlRequest: Constant.someURLRequest)

        given(data: Constant.someData, statusCode: 200, for: endpoint)

        whenInvokeEndpoint(endpoint) { (_, result) in
            XCTAssertEqual(result.success?.data, Constant.someData)
            XCTAssertEqual(result.success?.response.statusCode, 200)
        }
    }

    func testInvokeEndpoint_EndpointFails_ResultIsFailedToDecodeData() throws {
        let endpoint = StubEndpoint(
            urlRequest: Constant.someURLRequest,
            behaviour: .fail(StubEndpoint.Error.someError)
        )

        given(data: Constant.someData, statusCode: 200, for: endpoint)

        whenInvokeEndpoint(endpoint) { (_, result) in
            XCTAssertEqual(result.failure, .decodeFailedWithError(StubEndpoint.Error.someError))
        }
    }

    func testInvokeEndpoint_URLResponseIsNil_ResultIsURLResponseIsUnexpected() {
        let endpoint = StubEndpoint(urlRequest: Constant.someURLRequest)

        given(data: Constant.someData, statusCode: nil, for: endpoint)

        whenInvokeEndpoint(endpoint) { (_, result) in
            XCTAssertEqual(result.failure, .urlResponseIsUnexpected)
        }
    }

    func testInvokeEndpoint_URLRequestFails_ResultIsDataTaskFailedWithError() {
        let endpoint = StubEndpoint(urlRequest: Constant.someURLRequest)

        given(error: Constant.someError, for: endpoint)

        whenInvokeEndpoint(endpoint) { (_, result) in
            if case let .dataTaskFailedWithError(error) = result.failure {
                XCTAssertEqual(error.domain, Constant.someError.domain)
                XCTAssertEqual(error.code, Constant.someError.code)
            } else {
                XCTFail()
            }
        }
    }

    func testInvokeEndpoint_AdditionalHeadersAreSet_CompletedRequestHasCorrectHeaders() {
        let headerFields = ["FIELD_1": "VALUE_1", "FIELD_2": "VALUE_2"]
        webClient.additionalHeaders = headerFields

        let endpoint = StubEndpoint(urlRequest: Constant.someURLRequest)

        given(data: Constant.someData, statusCode: 200, for: endpoint)
        
        whenInvokeEndpoint(endpoint) { (_, result) in
            XCTAssertEqual(
                StubURLProtocol.completedRequests.first?.allHTTPHeaderFields,
                headerFields
            )
        }

    }

}

extension WebClient.Error: Equatable where E.Failure: Equatable {

    public static func ==(lhs: WebClient.Error<E>, rhs: WebClient.Error<E>) -> Bool {
        switch (lhs, rhs) {
        case let (.dataTaskFailedWithError(lhsError), .dataTaskFailedWithError(rhsError)):
            return lhsError == rhsError
        case let (.decodeFailedWithError(lhsError), .decodeFailedWithError(rhsError)):
            return lhsError == rhsError
        case let (.endpointIsMisconfigured(lhsEndpoint), .endpointIsMisconfigured(rhsEndpoint)):
            return type(of: lhsEndpoint) == type(of: rhsEndpoint)
        case (.urlResponseIsUnexpected, .urlResponseIsUnexpected):
            return true
        default:
            return false
        }
    }

}
