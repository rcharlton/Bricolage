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
        try await withCheckedThrowingContinuation { continuation in
            invoke(endpoint: endpoint) { (result: InvocationResult<E>) in
                switch result {
                case let .success(value):
                    continuation.resume(returning: value)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Starts a URLSessionDataTask for the given endpoint.
    /// - Parameters:
    ///   - endpoint: The endpoint to call.
    ///   - completionHandler: Closure is invoked once the data task has completed.
    /// - Returns: An object that can be used to cancel the data task.
    ///            This object does not need to be retained.
    @discardableResult
    public func invoke<E: Endpoint>(
        endpoint: E,
        completionHandler: @escaping (InvocationResult<E>) -> Void
    ) -> Cancellable? {
        guard let urlRequest = urlRequest(for: endpoint) else {
            completionHandler(.failure(.endpointIsMisconfigured(endpoint)))
            return nil
        }

        let task = urlSession.dataTask(with: urlRequest) {
            let result: InvocationResult<E> = makeResult(data: $0, response: $1, error: $2)
                .flatMap(validateResponse)
                .flatMap(decodeData(for: endpoint))

            completionHandler(result)
        }

        task.resume()
        return task
    }

    func urlRequest<E: Endpoint>(for endpoint: E) -> URLRequest? {
        endpoint.urlRequest(relativeTo: serviceURL)
            .map {
                configure($0) { urlRequest in
                    additionalHeaders.forEach {
                        urlRequest.setValue($0.1, forHTTPHeaderField: $0.0)
                    }
                }
            }
    }

}

// MARK: -

private func makeResult<E: Endpoint>(
    data: Data?,
    response: URLResponse?,
    error: Error?
) -> Result<(Data?, URLResponse?), InvocationError<E>> {
    error.map { .failure(.dataTaskFailedWithError($0 as NSError)) }
        ?? .success((data, response))
}

private func validateResponse<E: Endpoint>(
    data: Data?,
    response: URLResponse?
) -> Result<(Data?, HTTPURLResponse), InvocationError<E>> {
    (response as? HTTPURLResponse).map { .success((data, $0)) }
        ?? .failure(.urlResponseIsUnexpected)
}

private func decodeData<E: Endpoint>(
    for endpoint: E
) -> (Data?, HTTPURLResponse) -> InvocationResult<E> {
    { (data, response) in
        endpoint.decodeData(data, for: response)
            .mapError { InvocationError<E>.decodeFailedWithError($0) }
    }
}
