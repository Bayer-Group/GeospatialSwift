public enum PolygonInvalidReason {
    case duplicates(indices: [Int])
    case selfIntersects(ringIndices: [[[Int]]])
    case holeOutside(ringIndices: [Int])
    case ringInvalidReasons(_: [[LineStringInvalidReason]])
}

public protocol GeoJsonPolygon: GeoJsonClosedGeometry, GeodesicPolygon {
    var mainRing: GeoJsonLineString { get }
    var negativeRings: [GeoJsonLineString] { get }
    var linearRings: [GeoJsonLineString] { get }
    var centroid: GeodesicPoint { get }
    
    func invalidReasons(tolerance: Double) -> [PolygonInvalidReason]
}

// SOMEDAY: Create Polygon by mainRing and negativeRings instead of [LinearRings] which does not imply a main ring needs to exist to be valid.
extension GeoJson {
    /**
     Creates a GeoJsonPolygon
     */
    public func polygon(linearRings: [GeoJsonLineString]) -> GeoJsonPolygon? {
        return Polygon(linearRings: linearRings)
    }
    
    public struct Polygon: GeoJsonPolygon {
        public let type: GeoJsonObjectType = .polygon
        public var geoJsonCoordinates: [Any] { return linearRings.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            Polygon: \(
            """
            //\nMain Ring: \(mainRing)
            (\n\(negativeRings.enumerated().map { "\("Negative Ring \($0 + 1)") - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public var ringSegements: [[GeodesicLineSegment]] { return [mainRingSegments] + negativeRingsSegments }
        public var mainRingSegments: [GeodesicLineSegment] { return mainRing.segments }
        public var negativeRingsSegments: [[GeodesicLineSegment]] { return negativeRings.map { $0.segments } }
        
        public var linearRings: [GeoJsonLineString] { return [mainRing] + negativeRings }
        public let mainRing: GeoJsonLineString
        public let negativeRings: [GeoJsonLineString]
        
        public var points: [GeoJsonPoint] { return linearRings.flatMap { $0.points } }
        
        public var boundingBox: GeodesicBoundingBox { return BoundingBox.best(linearRings.map { $0.boundingBox })! }
        
        public var centroid: GeodesicPoint { return Calculator.centroid(polygon: self) }
        
        public var hasHole: Bool { return negativeRings.count > 0 }
        
        public var area: Double { return Calculator.area(of: self) }
        
        internal init?(coordinatesJson: [Any]) {
            guard let linearRingsJson = coordinatesJson as? [[Any]] else { Log.warning("A valid Polygon must have valid coordinates"); return nil }
            
            var linearRings = [GeoJsonLineString]()
            for linearRingJson in linearRingsJson {
                if let linearRing = LineString(coordinatesJson: linearRingJson) {
                    linearRings.append(linearRing)
                } else {
                    Log.warning("Invalid linear ring (LineString) in Polygon"); return nil
                }
            }
            
            self.init(linearRings: linearRings)
        }
        
        fileprivate init?(linearRings: [GeoJsonLineString]) {
            guard linearRings.count >= 1 else { Log.warning("A valid Polygon must have at least one LinearRing"); return nil }
            
            for linearRing in linearRings {
                guard linearRing.points.first! == linearRing.points.last! else { Log.warning("A valid Polygon LinearRing must have the first and last points equal"); return nil }
                
                guard linearRing.points.count >= 4 else { Log.warning("A valid Polygon LinearRing must have at least 4 points"); return nil }
            }
            
            self.mainRing = linearRings.first!
            self.negativeRings = linearRings.tail ?? []
        }
        
        public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return Calculator.edgeDistance(from: point, to: self, tolerance: tolerance)
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return Calculator.distance(from: point, to: self, tolerance: tolerance)
        }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
            // Must at least be within the bounding box.
            guard mainRing.boundingBox.contains(point: point, tolerance: tolerance) else { return false }
            
            return Calculator.contains(point, in: self, tolerance: tolerance)
        }
        
        // SOMEDAY: See this helpful link for validations: https://github.com/mapbox/mapnik-vector-tile/issues/153
        
        // Checking winding order is valid
        // Triangle that reprojection to tile coordinates will cause winding order reversed
        // Polygon that will be reprojected into tile coordinates as a line
        // Polygon with "spike"
        // Polygon with hole that has a "spike"
        // Polygon where area threshold removes geometry AFTER clipping
        // Polygon with reversed winding order
        // Polygon with hole where hole has invalid winding order
        public func invalidReasons(tolerance: Double) -> [PolygonInvalidReason] {
            let ringInvalidReasons = linearRings.compactMap { $0.invalidReasons(tolerance: tolerance) }
            
            guard ringInvalidReasons.isEmpty else { return [.ringInvalidReasons(ringInvalidReasons)] }
            
            let duplicateIndices = points.enumerated().filter { index, point in points.enumerated().contains { $0 > index && $1 == point } }.map { $0.offset }
            
            guard duplicateIndices.isEmpty else { return [.duplicates(indices: duplicateIndices)] }
            
            let selfIntersectsIndices = Calculator.intersectionIndices(from: self)
            
            guard selfIntersectsIndices.isEmpty else { return [.selfIntersects(ringIndices: selfIntersectsIndices)] }
            
            let holeOutsideIndices = negativeRings.enumerated().filter { _, negativeRing in negativeRing.points.contains { !Calculator.contains($0, in: mainRing.segments, tolerance: tolerance) } }.map { $0.offset }
            
            guard holeOutsideIndices.isEmpty else { return [.holeOutside(ringIndices: holeOutsideIndices)] }
            
            return []
        }
    }
}
