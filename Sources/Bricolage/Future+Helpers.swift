//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

#if canImport(Combine)

import Combine

public extension Future {

    convenience init(work: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                let result: Result<Output, Failure>
                do {
                    result = .success(try await work())
                } catch let failure as Failure {
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
