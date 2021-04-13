//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

public class WebClient {

    public indirect enum Error<E: Endpoint>: Swift.Error {

        /// An underlying URL session error such as a dropped connection.
        case dataTaskFailedWithError(NSError)

        /// Failed to decode body data into expected model type.
        case failedToDecodeData(E.Failure)

        /// The endpoint was unable to provide a valid URL.
        case misconfiguredEndpoint(E)

        /// A problem with Foundation exists; this error cannot occur.
        case urlResponseIsUnexpected

    }

    public typealias Result<E: Endpoint> = Swift.Result<E.Success, Error<E>>

    private let serviceURL: URL
    private let urlSession: URLSession

    public init(
        serviceURL: URL,
        urlSessionConfiguration: URLSessionConfiguration
    ) {
        self.serviceURL = serviceURL
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
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
        completionHandler: @escaping (Result<E>) -> Void
    ) -> Cancellable? {
        guard let urlRequest = endpoint.urlRequest(relativeTo: serviceURL) else {
            completionHandler(.failure(.misconfiguredEndpoint(endpoint)))
            return nil
        }

        let task = urlSession.dataTask(with: urlRequest) {
            let result: Result<E> = makeResult(data: $0, response: $1, error: $2)
                .flatMap(validateResponse)
                .flatMap(decodeData(for: endpoint))

            completionHandler(result)
        }
        task.resume()
        return task
    }

}

// MARK: -

private func makeResult<E: Endpoint>(
    data: Data?,
    response: URLResponse?,
    error: Error?
) -> Result<(Data?, URLResponse?), WebClient.Error<E>> {
    error.map { .failure(.dataTaskFailedWithError($0 as NSError)) }
        ?? .success((data, response))
}

private func validateResponse<E: Endpoint>(
    data: Data?,
    response: URLResponse?
) -> Result<(Data?, HTTPURLResponse), WebClient.Error<E>> {
    (response as? HTTPURLResponse).map { .success((data, $0)) }
        ?? .failure(.urlResponseIsUnexpected)
}

private func decodeData<E: Endpoint>(
    for endpoint: E
) -> (Data?, HTTPURLResponse) -> WebClient.Result<E> {
    { (data, response) in
        endpoint.decodeData(data, for: response)
            .mapError { WebClient.Error<E>.failedToDecodeData($0) }
    }
}
