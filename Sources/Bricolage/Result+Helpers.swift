//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

public extension Result {

    var success: Success? {
        if case let .success(success) = self {
            return success
        } else {
            return nil
        }
    }

    var failure: Failure? {
        if case let .failure(failure) = self {
            return failure
        } else {
            return nil
        }
    }

}
