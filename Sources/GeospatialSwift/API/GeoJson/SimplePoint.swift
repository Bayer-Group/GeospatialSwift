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
