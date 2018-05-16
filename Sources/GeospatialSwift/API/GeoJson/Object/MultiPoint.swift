internal typealias MultiPoint = GeoJson.MultiPoint

public protocol GeoJsonMultiPoint: GeoJsonMultiCoordinatesGeometry { }

extension GeoJson {
    /**
     Creates a GeoJsonMultiPoint
     */
    public func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint? {
        return MultiPoint(points: points)
    }
    
    public struct MultiPoint: GeoJsonMultiPoint {
        public var type: GeoJsonObjectType { return .multiPoint }
        public var geoJsonCoordinates: [Any] { return points.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            MultiPoint: \(
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
            return Calculator.centroid(points: points)
        }
        
        internal init?(coordinatesJson: [Any]) {
            guard let pointsJson = coordinatesJson as? [[Any]] else { Log.warning("A valid MultiPoint must have valid coordinates"); return nil }
            
            var points = [GeoJsonPoint]()
            for pointJson in pointsJson {
                if let point = Point(coordinatesJson: pointJson) {
                    points.append(point)
                } else {
                    Log.warning("Invalid Point in MultiPoint"); return nil
                }
            }
            
            self.init(points: points)
        }
        
        fileprivate init?(points: [GeoJsonPoint]) {
            guard points.count >= 1 else { Log.warning("A valid MultiPoint must have at least one Point"); return nil }
            
            self.points = points
        }
        
        public func distance(to point: GeodesicPoint, errorDistance: Double) -> Double { return points.map { $0.distance(to: point, errorDistance: errorDistance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return points.first { $0.contains(point, errorDistance: errorDistance) } != nil }
    }
}
