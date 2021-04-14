//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

public typealias Endpoint = RequestProviding & ResponseDecoding

public protocol RequestProviding {
    func urlRequest(relativeTo url: URL) -> URLRequest?
}

public protocol ResponseDecoding {

    associatedtype Success
    associatedtype Failure: Error

    typealias Result = Swift.Result<Success, Failure>

    func decodeData(_ data: Data?, for response: HTTPURLResponse) -> Result

}
