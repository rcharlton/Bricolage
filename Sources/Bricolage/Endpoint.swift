//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

public protocol Endpoint {

    associatedtype Success
    associatedtype Failure: Error

    func urlRequest(relativeTo url: URL) -> URLRequest?

    func decodeData(_ data: Data?, for response: HTTPURLResponse) -> Result<Success, Failure>

}
