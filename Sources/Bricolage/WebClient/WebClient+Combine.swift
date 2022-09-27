//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

#if canImport(Combine)

import Combine

extension WebClient {

    public func invoke<E: Endpoint>(endpoint: E) -> Future<E.Success, EndpointError<E>> {
        Future { promise in
            typealias Error = EndpointError<E>

            Task {
                let result: Result<E.Success, Error>
                do {
                    result = .success(try await self.invoke(endpoint: endpoint))
                } catch let failure as Error {
                    result = .failure(failure)
                } catch {
                    preconditionFailure("Unexpected error type")
                }
                promise(result)
            }
        }
    }

}

#endif
