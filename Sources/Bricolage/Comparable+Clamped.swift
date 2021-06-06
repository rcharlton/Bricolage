//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

public extension Comparable {

    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }

}

public extension Comparable where Self: Strideable, Self.Stride: SignedInteger {

    func clamped(to range: Range<Self>) -> Self {
        guard let ceiling = range.max() else { return self }
        return max(min(self, ceiling), range.lowerBound)
    }

}
