public enum LineStringInvalidReason {
    case duplicates(indices: [Int])
    case selfIntersects(segmentIndices: [Int])
}

public protocol GeoJsonLineString: GeoJsonLinearGeometry, GeodesicLine {
    var geoJsonPoints: [GeoJsonPoint] { get }
    
    func invalidReasons(tolerance: Double) -> [LineStringInvalidReason]
}

extension GeoJson {
    /**
     Creates a GeoJsonLineString
     */
    public func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString? { LineString(points: points) }
    
    public struct LineString: GeoJsonLineString {
        public let type: GeoJsonObjectType = .lineString
        
        public let geoJsonPoints: [GeoJsonPoint]
        
        internal init?(coordinatesJson: [Any]) {
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
            
            self.geoJsonPoints = points
        }
    }
}

extension GeoJson.LineString {
    public var segments: [GeodesicLineSegment] {
        geoJsonPoints.enumerated().compactMap { (offset, point) in
            if geoJsonPoints.count == offset + 1 { return nil }
            
            return LineSegment(point: point, otherPoint: geoJsonPoints[offset + 1])
        }
    }
    
    public var geoJsonCoordinates: [Any] { geoJsonPoints.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { geoJsonPoints }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(geoJsonPoints.compactMap { $0.boundingBox })! }
    
    public var lineStrings: [GeoJsonLineString] { [self] }
    
    public var length: Double { Calculator.length(of: self) }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: point, to: self, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { Calculator.contains(point, in: self, tolerance: tolerance) }
    
    public func invalidReasons(tolerance: Double) -> [LineStringInvalidReason] {
        let duplicateIndices = Calculator.equalsIndices(points, tolerance: tolerance)
        
        guard duplicateIndices.isEmpty else { return [.duplicates(indices: duplicateIndices)] }
        
        let selfIntersectsIndices = Calculator.intersectionIndices(from: self, tolerance: tolerance)
        
        guard selfIntersectsIndices.isEmpty else { return [.selfIntersects(segmentIndices: selfIntersectsIndices)] }
        
        return []
    }
}
