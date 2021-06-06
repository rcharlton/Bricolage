//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

enum Reference<Type> {

    case strong(Type)
    case weak(Weak<Type>)

    static func weak(_ instance: Type) -> Reference {
        .weak(Weak(instance))
    }

    var instance: Type? {
        switch self {
        case let .strong(instance):
            return instance
        case let .weak(reference):
            return reference.instance
        }
    }

}
