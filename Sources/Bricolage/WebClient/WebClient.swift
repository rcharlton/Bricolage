//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

public class WebClient: EndpointInvoking {

    /// Header fields to set on all endpoint URL requests.
    public var additionalHeaders: [String: String] = [:]

    private let serviceURL: URL
    private let urlSession: URLSession

    public init(
        serviceURL: URL,
        urlSessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.serviceURL = serviceURL
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }

    @discardableResult
    public func invoke<E: Endpoint>(endpoint: E) async throws -> E.Success {
        typealias Error = EndpointError<E>

        guard let urlRequest = urlRequest(for: endpoint) else {
            throw Error.endpointIsMisconfigured(endpoint)
        }

        let success: (Data, URLResponse)

        do {
            success = try await urlSession.data(for: urlRequest)
        } catch {
            throw Error.dataTaskFailedWithError(error as NSError)
        }

        try Task.checkCancellation()

        let data = success.0

        guard let response = success.1 as? HTTPURLResponse else {
            throw Error.urlResponseIsUnexpected
        }

        if endpoint.successStatusCodes.contains(response.statusCode) {
            do {
                return try endpoint.decodeSuccess(from: data, response: response)
            } catch {
                throw Error.failedToDecodeType("\(E.Success.self)", error: error)
            }
        } else {
            throw Error.statusCodeIsFailure(
                response.statusCode,
                error: try? endpoint.decodeFailure(from: data, response: response)
            )
        }
    }

    func urlRequest<E: Endpoint>(for endpoint: E) -> URLRequest? {
        var urlRequest = endpoint.urlRequest(relativeTo: serviceURL)
        additionalHeaders.forEach { urlRequest?.setValue($0.1, forHTTPHeaderField: $0.0) }
        return urlRequest
    }

}
