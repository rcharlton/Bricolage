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
    associatedtype Failure

    var successStatusCodes: AnyCollection<Int> { get }

    var decoder: Decoding { get }

    func decodeSuccess(from data: Data, response: HTTPURLResponse) throws -> Success

    func decodeFailure(from data: Data, response: HTTPURLResponse) throws -> Failure
}

// MARK: -

public extension ResponseDecoding {
    var successStatusCodes: AnyCollection<Int> { AnyCollection(200..<400) }

    var decoder: Decoding { JSONDecoder() }
}

// MARK: -

public extension ResponseDecoding where Success: Decodable {
    func decodeSuccess(from data: Data, response: HTTPURLResponse) throws -> Success {
        try decoder.decode(Success.self, from: data)
    }
}

// MARK: -

public extension ResponseDecoding where Failure: Decodable {
    func decodeFailure(from data: Data, response: HTTPURLResponse) throws -> Failure {
        try decoder.decode(Failure.self, from: data)
    }
}

// MARK: -

public extension ResponseDecoding where Success == Void {
    func decodeSuccess(from data: Data, response: HTTPURLResponse) throws -> Success {
        ()
    }
}

// MARK: -

public extension ResponseDecoding where Failure == Void {
    func decodeFailure(from data: Data, response: HTTPURLResponse) throws -> Failure {
        ()
    }
}
