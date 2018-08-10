public enum LineStringInvalidReason {
    case duplicates(indices: [Int])
    case selfIntersects(segmentIndices: [Int])
}

public protocol GeoJsonLineString: GeoJsonLinearGeometry {
    var segments: [GeodesicLineSegment] { get }
    
    func invalidReasons(tolerance: Double) -> [LineStringInvalidReason]
}

extension GeoJson {
    /**
     Creates a GeoJsonLineString
     */
    public func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString? {
        return LineString(points: points)
    }
    
    public struct LineString: GeoJsonLineString {
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
        
        public var boundingBox: GeodesicBoundingBox {
            return BoundingBox.best(points.compactMap { $0.boundingBox })!
        }
        
        public var length: Double {
            return Calculator.length(of: segments)
        }
        
        public let segments: [GeodesicLineSegment]
        
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
            
            self.points = points
            
            segments = points.enumerated().compactMap { (offset, point) in
                if points.count == offset + 1 { return nil }
                
                return LineSegment(point: point, otherPoint: points[offset + 1])
            }
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return Calculator.distance(from: point, to: segments, tolerance: tolerance)
        }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
            return Calculator.contains(point, in: segments, tolerance: tolerance)
        }
        
        public func invalidReasons(tolerance: Double) -> [LineStringInvalidReason] {
            let duplicateIndices = points.enumerated().filter { index, point in points.enumerated().contains { $0 > index && $1 == point } }.map { $0.offset }
            
            guard duplicateIndices.isEmpty else { return [.duplicates(indices: duplicateIndices)] }
            
            let selfIntersectsIndices = Calculator.intersectionIndices(from: segments)
            
            guard selfIntersectsIndices.isEmpty else { return [.selfIntersects(segmentIndices: selfIntersectsIndices)] }
            
            return []
        }
    }
}
