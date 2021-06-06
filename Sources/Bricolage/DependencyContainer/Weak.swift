//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

struct Weak<Type> {

    /// Workaround for Swift error: Generic struct 'Weak' requires that 'Type' be a class type
    /// which arises when attempting to weakly reference a class object using a protocol type.
    private weak var privateInstance: AnyObject?

    var instance: Type? {
        privateInstance as? Type
    }

    init(_ instance: Type) {
        privateInstance = instance as AnyObject
    }

}
