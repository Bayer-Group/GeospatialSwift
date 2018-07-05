public protocol GeodesicPoint: CustomStringConvertible {
    var longitude: Double { get }
    var latitude: Double { get }
    var altitude: Double? { get }
}

public extension GeodesicPoint {
    public var degreesToRadians: GeodesicPoint { return SimplePoint(longitude: longitude.degreesToRadians, latitude: latitude.degreesToRadians, altitude: altitude) }
    public var radiansToDegrees: GeodesicPoint { return SimplePoint(longitude: longitude.radiansToDegrees, latitude: latitude.radiansToDegrees, altitude: altitude) }
}

public func == (lhs: GeodesicPoint, rhs: GeodesicPoint) -> Bool {
    let lhs = GeodesicCalculator.normalize(point: lhs)
    let rhs = GeodesicCalculator.normalize(point: rhs)
    
    // TODO: Comparing strings rather than Doubles. Should Altitude be involved?
    return lhs.latitude.description == rhs.latitude.description && lhs.longitude.description == rhs.longitude.description && lhs.altitude?.description == rhs.altitude?.description
}
