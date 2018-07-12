public protocol GeodesicPoint: CustomStringConvertible {
    var longitude: Double { get }
    var latitude: Double { get }
    var altitude: Double? { get }
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
    
    public var description: String { return "SimplePoint: (longitude: \(longitude), latitude: \(latitude)\(altitude != nil ? ", altitude: \(altitude!.description)" : ""))" }
}

public extension GeodesicPoint {
    public var degreesToRadians: GeodesicPoint { return SimplePoint(longitude: longitude.degreesToRadians, latitude: latitude.degreesToRadians, altitude: altitude) }
    public var radiansToDegrees: GeodesicPoint { return SimplePoint(longitude: longitude.radiansToDegrees, latitude: latitude.radiansToDegrees, altitude: altitude) }
}

public func == (lhs: GeodesicPoint, rhs: GeodesicPoint) -> Bool {
    let calculator = GeodesicCalculator()
    let lhs = calculator.normalize(point: lhs)
    let rhs = calculator.normalize(point: rhs)
    
    // SOMEDAY: Comparing strings rather than Doubles. Should Altitude be involved?
    return lhs.latitude.description == rhs.latitude.description && lhs.longitude.description == rhs.longitude.description && lhs.altitude?.description == rhs.altitude?.description
}
