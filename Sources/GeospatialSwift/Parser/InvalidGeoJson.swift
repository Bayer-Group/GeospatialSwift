public struct InvalidGeoJson: Error {
    public let reasons: [String]
}

internal extension InvalidGeoJson {
    init (reason: String) {
        reasons = [reason]
    }
}

internal func + (lhs: InvalidGeoJson?, rhs: InvalidGeoJson?) -> InvalidGeoJson? {
    guard let lhs = lhs else { return rhs }
    guard let rhs = rhs else { return lhs }
    return .init(reasons: lhs.reasons + rhs.reasons)
}
