public protocol GeoJsonMultiPoint: GeoJsonCoordinatesGeometry {
    var geoJsonPoints: [GeoJsonPoint] { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiPoint
     */
    public func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint? {
        return MultiPoint(points: points)
    }
    
    public struct MultiPoint: GeoJsonMultiPoint {
        public var type: GeoJsonObjectType { return .multiPoint }
        public var geoJsonCoordinates: [Any] { return geoJsonPoints.map { $0.geoJsonCoordinates } }
        
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
        
        public var points: [GeodesicPoint] { return geoJsonPoints }
        public let geoJsonPoints: [GeoJsonPoint]
        
        public var boundingBox: GeodesicBoundingBox {
            return BoundingBox.best(geoJsonPoints.compactMap { $0.boundingBox })!
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
            
            geoJsonPoints = points
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { return geoJsonPoints.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { return geoJsonPoints.first { $0.contains(point, tolerance: tolerance) } != nil }
        
        public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
            let duplicatePoints = Calculator.indices(ofPoints: points, clusteredWithinTolarance: tolerance).map { geoJsonPoints[$0[0]] }
            
            guard duplicatePoints.isEmpty else { return [GeoJsonSimpleViolation(problems: duplicatePoints, reason: .pointDuplication)] }
            
            return []
        }
        
    }
}
