//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

#if canImport(Combine)

import Combine

extension WebClient {

    public func invoke<E: Endpoint>(endpoint: E) -> Future<E.Success, Error<E>> {
        Future { promise in
            self.invoke(endpoint: endpoint, completionHandler: promise)
        }
    }

}

#endif
