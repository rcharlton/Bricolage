//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

#if canImport(Combine)

import Combine

public extension WebClient {

    func invoke<E: Endpoint>(endpoint: E) -> Future<E.Success, EndpointError<E>> {
        Future {
            try await self.invoke(endpoint: endpoint)
        }
    }
    
}

#endif
