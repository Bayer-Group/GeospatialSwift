public enum MultipointInvalidReason {
    case duplicates(indices: [Int])
}

public protocol GeoJsonMultiPoint: GeoJsonCoordinatesGeometry {
    var geoJsonPoints: [GeoJsonPoint] { get }
    
    func invalidReasons(tolerance: Double) -> [MultipointInvalidReason]
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiPoint
     */
    public func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint? { MultiPoint(points: points) }
    
    public struct MultiPoint: GeoJsonMultiPoint {
        public let type: GeoJsonObjectType = .multiPoint
        
        public let geoJsonPoints: [GeoJsonPoint]
        
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
    }
}

extension GeoJson.MultiPoint {
    public var geoJsonCoordinates: [Any] { geoJsonPoints.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { geoJsonPoints }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(geoJsonPoints.compactMap { $0.boundingBox })! }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { geoJsonPoints.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geoJsonPoints.first { $0.contains(point, tolerance: tolerance) } != nil }
    
    public func invalidReasons(tolerance: Double) -> [MultipointInvalidReason] {
        let duplicateIndices = Calculator.equalsIndices(points, tolerance: tolerance)
        
        guard duplicateIndices.isEmpty else { return [.duplicates(indices: duplicateIndices)] }
        
        return []
    }
}
