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
        return Point(logger: logger, geodesicCalculator: geodesicCalculator, longitude: longitude, latitude: latitude)
    }
    
    /**
     Creates a GeoJsonPoint
     */
    public func point(longitude: Double, latitude: Double, altitude: Double?) -> GeoJsonPoint {
        return Point(logger: logger, geodesicCalculator: geodesicCalculator, longitude: longitude, latitude: latitude, altitude: altitude)
    }
    
    public final class Point: GeoJsonPoint {
        public let type: GeoJsonObjectType = .point
        public var geoJsonCoordinates: [Any] { return altitude != nil ? [longitude, latitude, altitude!] : [longitude, latitude] }
        
        public var normalize: GeodesicPoint { return geodesicCalculator.normalize(point: self) }
        
        public var description: String { return "Point: (longitude: \(longitude), latitude: \(latitude)\(altitude != nil ? ", altitude: \(altitude!.description)" : ""))" }
        
        private let logger: LoggerProtocol
        private let geodesicCalculator: GeodesicCalculatorProtocol
        
        public let longitude: Double
        public let latitude: Double
        // TODO: Need a better way to know when to include and exclude altitude in calculations. Currently excluded.
        public let altitude: Double?
        
        public var boundingBox: GeoJsonBoundingBox {
            return BoundingBox(boundingCoordinates: (minLongitude: longitude, minLatitude: latitude, maxLongitude: longitude, maxLatitude: latitude))
        }
        
        public let hashValue: Int
        
        internal convenience init?(logger: LoggerProtocol, geodesicCalculator: GeodesicCalculatorProtocol, coordinatesJson: [Any]) {
            guard let pointJson = (coordinatesJson as? [NSNumber])?.map({ $0.doubleValue }), pointJson.count >= 2 else { logger.error("A valid Point must have at least 2 coordinates"); return nil }
            
            self.init(logger: logger, geodesicCalculator: geodesicCalculator, longitude: pointJson[0], latitude: pointJson[1], altitude: pointJson.count >= 3 ? pointJson[2] : nil)
        }
        
        fileprivate init(logger: LoggerProtocol, geodesicCalculator: GeodesicCalculatorProtocol, longitude: Double, latitude: Double, altitude: Double?) {
            self.logger = logger
            self.geodesicCalculator = geodesicCalculator
            
            self.longitude = longitude
            self.latitude = latitude
            self.altitude = altitude
            
            hashValue = [longitude.hashValue, latitude.hashValue, altitude?.hashValue ?? 0].reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
        }
        
        internal convenience init(logger: LoggerProtocol, geodesicCalculator: GeodesicCalculatorProtocol, longitude: Double, latitude: Double) {
            self.init(logger: logger, geodesicCalculator: geodesicCalculator, longitude: longitude, latitude: latitude, altitude: nil)
        }
        
        // TODO: Consider Altitude? What to do if altitude is nil in some cases?
        public func distance(to point: GeodesicPoint, errorDistance: Double) -> Double {
            let distance = geodesicCalculator.distance(point1: self, point2: point) - errorDistance
            
            return distance < 0 ? 0 : distance
        }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return distance(to: point, errorDistance: errorDistance) == 0 }
        
        public func initialBearing(to point: GeodesicPoint) -> Double { return geodesicCalculator.initialBearing(point1: self, point2: point) }
        public func averageBearing(to point: GeodesicPoint) -> Double { return geodesicCalculator.averageBearing(point1: self, point2: point) }
        public func finalBearing(to point: GeodesicPoint) -> Double { return geodesicCalculator.finalBearing(point1: self, point2: point) }
        
        public func midpoint(with point: GeodesicPoint) -> GeodesicPoint { return geodesicCalculator.midpoint(point1: self, point2: point) }
    }
}
