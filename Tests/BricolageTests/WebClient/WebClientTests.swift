//
//  File.swift
//  
//
//  Created by Robin Charlton on 27/09/2022.
//

import XCTest
@testable import Bricolage

class WebClientTests: XCTestCase {

    enum Constant {
        static let serviceURL = URL(string: "SERVICE://URL")!
        static let requestURL = URL(string: "REQUEST://URL")!
        static let someData = "DATA".data(using: .utf8)!
        static let someError = NSError(domain: "DOMAIN", code: 123)
    }

    typealias StubEndpointError = EndpointError<StubEndpoint>

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

    func given<E: Endpoint>(data: Data?, statusCode: Int? = 200, for endpoint: E) {
        guard
            let urlRequest = webClient.urlRequest(for: endpoint),
            let url = urlRequest.url
        else { return }

        let response = statusCode.map { HTTPURLResponse(url: url, statusCode: $0) }
        StubURLProtocol.set(data: data, response: response, for: urlRequest)
    }

    func given<E: Endpoint>(error: Error, for endpoint: E) {
        guard let urlRequest = webClient.urlRequest(for: endpoint) else { return }
        StubURLProtocol.set(error: error, for: urlRequest)
    }

    // MARK: -

    func testInvoke_URLRequestIsNil_ThrowsEndpointIsMisconfigured() async throws {
        let endpoint = StubEndpoint(url: nil)
        given(data: Constant.someData, for: endpoint)

        do {
            try await webClient.invoke(endpoint: endpoint)
            XCTFail("Failure expected")
        } catch EndpointError<StubEndpoint>.endpointIsMisconfigured(endpoint) {
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testInvoke_URLRequestFails_ThrowsDataTaskFailedWithError() async throws {
        let endpoint = StubEndpoint(url: Constant.requestURL)
        let nsError = NSError(domain: "WebClient", code: 123)
        given(error: nsError, for: endpoint)

        do {
            try await webClient.invoke(endpoint: endpoint)
            XCTFail("Failure expected")
        } catch let StubEndpointError.dataTaskFailedWithError(error) {
            XCTAssertEqual(error.domain, nsError.domain)
            XCTAssertEqual(error.code, nsError.code)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testInvoke_DecodingSuccessFails_ThrowsFailedToDecodeType() async throws {
        let endpoint = StubEndpoint(url: Constant.requestURL, decodingError: StubError.someError)
        given(data: Constant.someData, statusCode: 200, for: endpoint)

        do {
            try await webClient.invoke(endpoint: endpoint)
            XCTFail("Failure expected")
        } catch let StubEndpointError.failedToDecodeType(_, error) {
            XCTAssertEqual(error as? StubError, StubError.someError)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testInvoke_StatusCodeIsFailure_DataAndResponseAreCorrect() async throws {
        let endpoint = StubEndpoint(url: Constant.requestURL)
        given(data: Constant.someData, statusCode: 500, for: endpoint)

        do {
            try await webClient.invoke(endpoint: endpoint)
        } catch let StubEndpointError.statusCodeIsFailure(500, error: error) {
            XCTAssertEqual(error?.data, Constant.someData)
            XCTAssertEqual(error?.response.statusCode, 500)
       } catch {
            XCTFail("Unexpected error")
        }
    }

    func testInvoke_StatusCodeIsSuccess_DataAndResponseAreCorrect() async throws {
        let endpoint = StubEndpoint(url: Constant.requestURL)
        given(data: Constant.someData, statusCode: 200, for: endpoint)

        let success = try await webClient.invoke(endpoint: endpoint)

        XCTAssertEqual(success.data, Constant.someData)
        XCTAssertEqual(success.response.statusCode, 200)
    }

    func testInvoke_AdditionalHeadersAreSet_CompletedRequestHasCorrectHeaders() async throws {
        let headerFields = ["FIELD_1": "VALUE_1", "FIELD_2": "VALUE_2"]
        webClient.additionalHeaders = headerFields

        let endpoint = StubEndpoint(url: Constant.requestURL)
        given(data: Constant.someData, for: endpoint)

        try await webClient.invoke(endpoint: endpoint)

        XCTAssertEqual(
            StubURLProtocol.completedRequests.first?.allHTTPHeaderFields,
            headerFields
        )
    }

}
