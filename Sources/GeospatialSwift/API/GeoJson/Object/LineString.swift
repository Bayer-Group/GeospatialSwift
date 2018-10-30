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
    public func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString? {
        return LineString(points: points)
    }
    
    public struct LineString: GeoJsonLineString {
        public let type: GeoJsonObjectType = .lineString
        public var geoJsonCoordinates: [Any] { return geoJsonPoints.map { $0.geoJsonCoordinates } }
        
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
        
        public let points: [GeodesicPoint]
        public let geoJsonPoints: [GeoJsonPoint]
        
        public var boundingBox: GeodesicBoundingBox {
            return BoundingBox.best(geoJsonPoints.compactMap { $0.boundingBox })!
        }
        
        public var length: Double {
            return Calculator.length(of: self)
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
            self.geoJsonPoints = points
            
            segments = points.enumerated().compactMap { (offset, point) in
                if points.count == offset + 1 { return nil }
                
                return LineSegment(point: point, otherPoint: points[offset + 1])
            }
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return Calculator.distance(from: point, to: self, tolerance: tolerance)
        }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
            return Calculator.contains(point, in: self, tolerance: tolerance)
        }
        
        public func invalidReasons(tolerance: Double) -> [LineStringInvalidReason] {
            let duplicateIndices = Calculator.equalsIndices(points, tolerance: tolerance)
            
            guard duplicateIndices.isEmpty else { return [.duplicates(indices: duplicateIndices)] }
            
            let selfIntersectsIndices = Calculator.intersectionIndices(from: self, tolerance: tolerance)
            
            guard selfIntersectsIndices.isEmpty else { return [.selfIntersects(segmentIndices: selfIntersectsIndices)] }
            
            return []
        }
    }
}
