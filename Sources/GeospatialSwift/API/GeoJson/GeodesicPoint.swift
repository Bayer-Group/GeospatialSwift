public protocol GeodesicPoint: CustomStringConvertible {
    var longitude: Double { get }
    var latitude: Double { get }
    var altitude: Double? { get }
    
    var degreesToRadians: GeodesicPoint { get }
    var radiansToDegrees: GeodesicPoint { get }
}

public extension GeodesicPoint {
    public var degreesToRadians: GeodesicPoint { return SimplePoint(longitude: longitude.degreesToRadians, latitude: latitude.degreesToRadians, altitude: altitude) }
    public var radiansToDegrees: GeodesicPoint { return SimplePoint(longitude: longitude.radiansToDegrees, latitude: latitude.radiansToDegrees, altitude: altitude) }
}

public struct SimplePoint: GeodesicPoint, Hashable {
    public let hashValue: Int
    
    public let longitude: Double
    public let latitude: Double
    public let altitude: Double?
    
    public var description: String { return "SimplePoint: (longitude: \(longitude), latitude: \(latitude)\(altitude != nil ? ", altitude: \(altitude!.description)" : ""))" }
    
    public init(longitude: Double, latitude: Double, altitude: Double?) {
        self.longitude = longitude
        self.latitude = latitude
        self.altitude = altitude
        
        hashValue = [longitude.hashValue, latitude.hashValue, altitude?.hashValue ?? 0].reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
    
    public init(longitude: Double, latitude: Double) {
        self.init(longitude: longitude, latitude: latitude, altitude: nil)
    }
    
    public static func == (lhs: SimplePoint, rhs: SimplePoint) -> Bool { return lhs as GeodesicPoint == rhs as GeodesicPoint }
}
