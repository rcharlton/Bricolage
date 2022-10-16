//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

public enum EndpointError<E: Endpoint>: Error {

    /// An underlying URL session error such as a dropped connection.
    case dataTaskFailedWithError(NSError)

    /// The endpoint was unable to provide a valid URL.
    case endpointIsMisconfigured(E)

    /// Failed to decode body data into expected model type.
    case failedToDecodeType(String, error: Error)

    /// HTTP response status code indicates failure.
    case statusCodeIsFailure(Int, error: E.Failure?)

    /// A problem with Foundation exists; this error cannot occur.
    case urlResponseIsUnexpected

}
