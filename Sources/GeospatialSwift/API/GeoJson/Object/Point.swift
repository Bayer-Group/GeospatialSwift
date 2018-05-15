import Foundation

internal typealias Point = GeoJson.Point

public protocol GeoJsonPoint: GeodesicPoint, GeoJsonCoordinatesGeometry {
    var normalize: GeodesicPoint { get }
    
    func initialBearing(to point: GeodesicPoint) -> Double
    func averageBearing(to point: GeodesicPoint) -> Double
    func finalBearing(to point: GeodesicPoint) -> Double
    func midpoint(with point: GeodesicPoint) -> GeodesicPoint
}

extension GeoJson {
    /**
     Creates a GeoJsonPoint without altitiude
     */
    public func point(longitude: Double, latitude: Double) -> GeoJsonPoint {
        return Point(longitude: longitude, latitude: latitude)
    }
    
    /**
     Creates a GeoJsonPoint
     */
    public func point(longitude: Double, latitude: Double, altitude: Double?) -> GeoJsonPoint {
        return Point(longitude: longitude, latitude: latitude, altitude: altitude)
    }
    
    public struct Point: GeoJsonPoint {
        public var type: GeoJsonObjectType { return .point }
        
        public var geoJsonCoordinates: [Any] { return altitude != nil ? [longitude, latitude, altitude!] : [longitude, latitude] }
        
        public var normalize: GeodesicPoint { return Calculator.normalize(point: self) }
        
        public var description: String { return "Point: (longitude: \(longitude), latitude: \(latitude)\(altitude != nil ? ", altitude: \(altitude!.description)" : ""))" }
        
        public let longitude: Double
        public let latitude: Double
        // TODO: Need a better way to know when to include and exclude altitude in calculations. Currently excluded.
        public var altitude: Double?
        
        public var boundingBox: GeoJsonBoundingBox {
            return BoundingBox(boundingCoordinates: (minLongitude: longitude, minLatitude: latitude, maxLongitude: longitude, maxLatitude: latitude))
        }
        
        internal init?(coordinatesJson: [Any]) {
            guard let pointJson = (coordinatesJson as? [NSNumber])?.map({ $0.doubleValue }), pointJson.count >= 2 else { Log.warning("A valid Point must have at least 2 coordinates"); return nil }
            
            self.init(longitude: pointJson[0], latitude: pointJson[1], altitude: pointJson.count >= 3 ? pointJson[2] : nil)
        }
        
        internal init(longitude: Double, latitude: Double, altitude: Double? = nil) {
            self.longitude = longitude
            self.latitude = latitude
            self.altitude = altitude
        }
        
        // TODO: Consider Altitude? What to do if altitude is nil in some cases?
        public func distance(to point: GeodesicPoint, errorDistance: Double) -> Double {
            let distance = Calculator.distance(point1: self, point2: point) - errorDistance
            
            return distance < 0 ? 0 : distance
        }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return distance(to: point, errorDistance: errorDistance) == 0 }
        
        public func initialBearing(to point: GeodesicPoint) -> Double { return Calculator.initialBearing(point1: self, point2: point) }
        public func averageBearing(to point: GeodesicPoint) -> Double { return Calculator.averageBearing(point1: self, point2: point) }
        public func finalBearing(to point: GeodesicPoint) -> Double { return Calculator.finalBearing(point1: self, point2: point) }
        
        public func midpoint(with point: GeodesicPoint) -> GeodesicPoint { return Calculator.midpoint(point1: self, point2: point) }
    }
}
