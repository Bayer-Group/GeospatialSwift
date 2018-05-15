public typealias GeoJsonLineSegment = (point1: GeodesicPoint, point2: GeodesicPoint)

internal typealias LineString = GeoJson.LineString

public protocol GeoJsonLineString: GeoJsonMultiCoordinatesGeometry {
    var segments: [GeoJsonLineSegment] { get }
    var length: Double { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonLineString
     */
    public func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString? {
        return LineString(points: points)
    }
    
    public final class LineString: GeoJsonLineString {
        public let type: GeoJsonObjectType = .lineString
        public var geoJsonCoordinates: [Any] { return points.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            LineString: \(
            """
            (\n\(points.enumerated().map { "\($0 + 1) - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let points: [GeoJsonPoint]
        
        public var boundingBox: GeoJsonBoundingBox {
            #if swift(>=4.1)
            return BoundingBox.best(points.compactMap { $0.boundingBox })!
            #else
            return BoundingBox.best(points.flatMap { $0.boundingBox })!
            #endif
        }
        
        public var centroid: GeodesicPoint {
            return Calculator.centroid(linePoints: points)
        }
        
        public var length: Double {
            return Calculator.length(lineSegments: segments)
        }
        
        public let segments: [GeoJsonLineSegment]
        
        internal convenience init?(coordinatesJson: [Any]) {
            guard let pointsJson = coordinatesJson as? [[Any]] else { Log.warning("A valid LineString must have valid coordinates"); return nil }
            
            var points = [GeoJsonPoint]()
            for pointJson in pointsJson {
                if let point = Point(coordinatesJson: pointJson) {
                    points.append(point)
                } else {
                    Log.warning("Invalid Point in LineString"); return nil
                }
            }
            
            self.init(points: points)
        }
        
        fileprivate init?(points: [GeoJsonPoint]) {
            guard points.count >= 2 else { Log.warning("A valid LineString must have at least two Points"); return nil }
            
            self.points = points
            
            #if swift(>=4.1)
            segments = points.enumerated().compactMap { (offset, point) in
                if points.count == offset + 1 { return nil }
                
                return (point, points[offset + 1])
            }
            #else
            segments = points.enumerated().flatMap { (offset, point) in
                if points.count == offset + 1 { return nil }
            
                return (point, points[offset + 1])
            }
            #endif
        }
        
        public func distance(to point: GeodesicPoint, errorDistance: Double) -> Double {
            var smallestDistance = Double.greatestFiniteMagnitude
            
            for lineSegment in segments {
                let distance = Calculator.distance(point: point, lineSegment: lineSegment) - errorDistance
                
                guard distance > 0 else { return 0 }
                
                smallestDistance = min(smallestDistance, distance)
            }
            
            return smallestDistance
        }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool {
            return distance(to: point, errorDistance: errorDistance) == 0
        }
    }
}
