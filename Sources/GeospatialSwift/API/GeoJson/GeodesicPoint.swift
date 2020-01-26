public protocol GeodesicPoint {
    var longitude: Double { get }
    var latitude: Double { get }
    var altitude: Double? { get }
}

public extension GeodesicPoint {
    var degreesToRadians: GeodesicPoint { SimplePoint(longitude: longitude.degreesToRadians, latitude: latitude.degreesToRadians, altitude: altitude) }
    var radiansToDegrees: GeodesicPoint { SimplePoint(longitude: longitude.radiansToDegrees, latitude: latitude.radiansToDegrees, altitude: altitude) }
}

public struct SimplePoint: GeodesicPoint {
    public let longitude: Double
    public let latitude: Double
    public var altitude: Double?
    
    public init(longitude: Double, latitude: Double, altitude: Double? = nil) {
        self.longitude = longitude
        self.latitude = latitude
        self.altitude = altitude
    }
}

public func == (lhs: GeodesicPoint, rhs: GeodesicPoint) -> Bool {
    let lhs = Calculator.normalize(lhs)
    let rhs = Calculator.normalize(rhs)
    
    let altitudeIsSame = lhs.altitude != nil && rhs.altitude != nil ? lhs.altitude!.isEqual(to: rhs.altitude!) : lhs.altitude == rhs.altitude
    
    return lhs.latitude.isEqual(to: rhs.latitude) && lhs.longitude.isEqual(to: rhs.longitude) && altitudeIsSame
}
