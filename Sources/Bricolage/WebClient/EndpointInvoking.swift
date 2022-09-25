//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Foundation

public enum InvocationError<E: Endpoint>: Error {

    /// An underlying URL session error such as a dropped connection.
    case dataTaskFailedWithError(NSError)

    /// Failed to decode body data into expected model type.
    case decodeFailedWithError(E.Failure)

    /// The endpoint was unable to provide a valid URL.
    case endpointIsMisconfigured(E)

    /// A problem with Foundation exists; this error cannot occur.
    case urlResponseIsUnexpected

}

public typealias InvocationResult<E: Endpoint> = Result<E.Success, InvocationError<E>>

public protocol EndpointInvoking {

    @discardableResult
    func invoke<E: Endpoint>(
        endpoint: E,
        completionHandler: @escaping (InvocationResult<E>) -> Void
    ) -> Cancellable?

}
