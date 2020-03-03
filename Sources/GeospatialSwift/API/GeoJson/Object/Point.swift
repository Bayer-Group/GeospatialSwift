import class Foundation.NSNumber

extension GeoJson {
    /**
     Creates a Point without altitiude
     */
    public func point(longitude: Double, latitude: Double) -> Point { Point(longitude: longitude, latitude: latitude) }
    
    /**
     Creates a Point
     */
    public func point(longitude: Double, latitude: Double, altitude: Double?) -> Point { Point(longitude: longitude, latitude: latitude, altitude: altitude) }
    
    public struct Point: GeodesicPoint, GeoJsonCoordinatesGeometry {
        public let type: GeoJsonObjectType = .point
        
        public let longitude: Double
        public let latitude: Double
        // SOMEDAY: Need a better way to know when to include and exclude altitude in calculations. Currently excluded.
        // SOMEDAY: Maybe a new type for altitude, Point3D?
        public var altitude: Double?
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let pointJson = (coordinatesJson as! [NSNumber]).map { $0.doubleValue }
            
            self.init(longitude: pointJson[0], latitude: pointJson[1], altitude: pointJson.count >= 3 ? pointJson[2] : nil)
        }
        
        internal init(longitude: Double, latitude: Double, altitude: Double? = nil) {
            self.longitude = longitude
            self.latitude = latitude
            self.altitude = altitude
        }
    }
}

extension GeoJson.Point {
    public var geoJsonCoordinates: [Any] { altitude != nil ? [longitude, latitude, altitude!] : [longitude, latitude] }
    
    public var normalize: GeodesicPoint { Calculator.normalize(self) }
    public var normalizePostitive: GeodesicPoint { Calculator.normalizePositive(self) }
    
    public var points: [GeodesicPoint] { [self] }
    
    public var boundingBox: GeodesicBoundingBox { .init(minLongitude: longitude, minLatitude: latitude, maxLongitude: longitude, maxLatitude: latitude) }
    
    // SOMEDAY: Consider Altitude? What to do if altitude is nil in some cases?
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: self, to: point, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { Calculator.distance(from: self, to: point, tolerance: tolerance) == 0 }
    
    public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] { [] }
}

extension GeoJson.Point {
    internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
        guard (coordinatesJson as? [NSNumber])?.map({ $0.doubleValue }).count ?? 0 >= 2 else { return .init(reason: "A valid Point must have at least a longitude and latitude") }
        
        return nil
    }
}
