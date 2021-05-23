//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {

    /// A test configuration that uses StubURLProtocol.
    /// Test networking code using URLSession(configuration: .test).
    class var test: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return configuration
    }

}
