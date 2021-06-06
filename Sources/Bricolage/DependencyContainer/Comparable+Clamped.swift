//
// Copyright © 2021 Robin Charlton. All rights reserved.
//

extension Comparable {

    public func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }

}
