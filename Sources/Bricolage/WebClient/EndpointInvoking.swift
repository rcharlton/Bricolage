//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

public protocol EndpointInvoking {

    @discardableResult
    func invoke<E: Endpoint>(endpoint: E) async throws -> E.Success

}
