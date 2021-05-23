//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

public protocol Decoding {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: Decoding {
}
