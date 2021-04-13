//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

public protocol Cancellable {
    func cancel()
}

extension URLSessionDataTask: Cancellable {
}
