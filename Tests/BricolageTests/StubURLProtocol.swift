//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

/// Stubs the URLSession to permit testing of URLSessionTask.
class StubURLProtocol: URLProtocol {

    enum Error: Swift.Error {
        case missingResultForRequest(URLRequest)
    }

    private struct Result {

        let data: Data?
        let response: URLResponse?
        let error: Swift.Error?

        init(data: Data? = nil, response: URLResponse? = nil, error: Swift.Error? = nil) {
            self.data = data
            self.response = response
            self.error = error
        }

    }

    /// The stubbed results keyed by the request.
    private static var resultByRequest = [URLRequest: Result]()

    // MARK: -

    static func set(data: Data? = nil, response: URLResponse?, forRequest request: URLRequest) {
        resultByRequest[request] = Result(data: data, response: response)
    }

    static func set(error: Swift.Error, forRequest request: URLRequest) {
        resultByRequest[request] = Result(error: error)
    }

    static func clear() {
        resultByRequest.removeAll()
    }

    // MARK: - URLProtocol overrides

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let client = self.client else { return }

        guard let result = StubURLProtocol.resultByRequest[request] else {
            client.urlProtocol(self, didFailWithError: Error.missingResultForRequest(request))
            return
        }

        if let data = result.data {
            client.urlProtocol(self, didLoad: data)
        }
        if let response = result.response {
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let error = result.error {
            client.urlProtocol(self, didFailWithError: error)
        }

        client.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }

}

// MARK: - Convenience methods

extension StubURLProtocol {

    static func set<Model: Encodable>(
        model: Model,
        response: URLResponse?,
        forRequest request: URLRequest
    ) throws {
        let data = try JSONEncoder().encode(model)
        set(data: data, response: response, forRequest: request)
    }

}

extension HTTPURLResponse {

    convenience init(url: URL, statusCode: Int = 200) {
        self.init(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
    }

}
