public enum PolygonSimpleViolation {
    case duplicates(indices: [Int])
    case selfIntersects(ringIndices: [Int: [[Int]]])
    case holeOutside(ringIndices: [Int])
    case ringSimpleViolations(_: [[LineStringSimpleViolation]])
}

public protocol GeoJsonPolygon: GeoJsonClosedGeometry, GeodesicPolygon {
    var geoJsonLinearRings: [GeoJsonLineString] { get }
    var geoJsonMainRing: GeoJsonLineString { get }
    var geoJsonNegativeRings: [GeoJsonLineString] { get }
    var centroid: GeodesicPoint { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
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
        public var geoJsonCoordinates: [Any] { return geoJsonLinearRings.map { $0.geoJsonCoordinates } }
        
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
        
        public let geoJsonLinearRings: [GeoJsonLineString]
        public let geoJsonMainRing: GeoJsonLineString
        public let geoJsonNegativeRings: [GeoJsonLineString]
        
        public var linearRings: [GeodesicLine] { return geoJsonLinearRings }
        public var mainRing: GeodesicLine { return geoJsonMainRing }
        public var negativeRings: [GeodesicLine]  { return geoJsonNegativeRings }
        
        public var points: [GeodesicPoint] { return linearRings.flatMap { $0.points } }
        
        public var boundingBox: GeodesicBoundingBox { return BoundingBox.best(geoJsonLinearRings.map { $0.boundingBox })! }
        
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
            
            geoJsonLinearRings = linearRings
            geoJsonMainRing = linearRings.first!
            geoJsonNegativeRings = linearRings.tail ?? []
        }
        
        public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return Calculator.edgeDistance(from: point, to: self, tolerance: tolerance)
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return Calculator.distance(from: point, to: self, tolerance: tolerance)
        }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
            // Must at least be within the bounding box.
            guard geoJsonMainRing.boundingBox.contains(point: point, tolerance: tolerance) else { return false }
            
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
//        public func simpleViolations(tolerance: Double) -> [PolygonSimpleViolation] {
//            //Polygon repeats the first point at the end to close the shape
//            //To apply the logic for LineString, we need to drop the last point
//            var geoJsonLinearRingsDropLastPoint = [GeoJsonLineString]()
//            geoJsonLinearRings.forEach {
//                if let geoJsonLinearRingDropLastPoint = LineString(coordinatesJson: $0.geoJsonCoordinates.dropLast()) {
//                    geoJsonLinearRingsDropLastPoint.append(geoJsonLinearRingDropLastPoint)
//                }
//            }
//            let ringSimpleViolations = geoJsonLinearRingsDropLastPoint.compactMap { $0.simpleViolations(tolerance: tolerance) }.filter { $0.count>0 }
//
//            guard ringSimpleViolations.isEmpty else { return [.ringSimpleViolations(ringSimpleViolations)] }
//
//            let pointDropLast = geoJsonLinearRingsDropLastPoint.flatMap { $0.geoJsonPoints }
//            let duplicateIndices = Calculator.equalsIndices(pointDropLast, tolerance: tolerance)
//
//            guard duplicateIndices.isEmpty else { return [.duplicates(indices: duplicateIndices)] }
//
//            let selfIntersectsIndices = Calculator.intersectionIndices(from: self, tolerance: tolerance)
//
//            guard selfIntersectsIndices.isEmpty else { return [.selfIntersects(ringIndices: selfIntersectsIndices)] }
//
//            let holeOutsideIndices = negativeRings.enumerated().filter { _, negativeRing in negativeRing.points.contains { !Calculator.contains($0, in: self, tolerance: tolerance) } }.map { $0.offset }
//
//            guard holeOutsideIndices.isEmpty else { return [.holeOutside(ringIndices: holeOutsideIndices)] }
//
//            return []
//        }
        
        public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
            let ringSimpleViolations = geoJsonLinearRings.compactMap { $0.simpleViolations(tolerance: tolerance) }.filter { $0.count>0 }

            guard ringSimpleViolations.isEmpty else { return ringSimpleViolations.flatMap { $0 } }
            
            var dupPoints = [GeoJsonPoint]()
            (1..<linearRings.count).forEach { index in
                
                (0..<index).forEach { indexOther in
                    //drop last point, which equals the first point
                    let pointsDropLast = linearRings[index].points.dropLast()
                    let pointsOtherDropLast = linearRings[indexOther].points.dropLast()
                    //1 pair of duplicacy is allowed
                    let duplicatePoints = pointsDropLast.filter { point in
                        pointsOtherDropLast.contains(where: { point == $0 })
                    }
                    if duplicatePoints.count > 1 {
                        duplicatePoints.forEach { point in
                            if !dupPoints.contains(where: { point == $0 }) {
                                dupPoints.append(Point(longitude: point.longitude, latitude: point.latitude))
                            }
                        }
                    }
                }
            }
            guard dupPoints.isEmpty else { return [GeoJsonSimpleViolation(problems: dupPoints, reason: .duplicate)] }
            
            let selfIntersectsIndices = Calculator.intersectionIndices(from: self, tolerance: tolerance)
            
            guard selfIntersectsIndices.isEmpty else {
                var simpleViolationGeometries = [GeoJsonCoordinatesGeometry]()
                
                selfIntersectsIndices.forEach { intersection in
                    let segmentIndexPath = intersection.indexPath
                    //let segmentIndexPathOther = intersection.indexPathOther
                    let segment = linearRings[segmentIndexPath.ringIndex].segments[segmentIndexPath.segmentIndex]
                    
                    var point = Point(longitude: segment.point.longitude, latitude: segment.point.latitude)
                    var pointOther = Point(longitude: segment.otherPoint.longitude, latitude: segment.otherPoint.latitude)
                    
                    simpleViolationGeometries.append(point)
                    simpleViolationGeometries.append(pointOther)
                    simpleViolationGeometries.append(LineString(points: [point, pointOther])!)
                    
                }
                
                return [GeoJsonSimpleViolation(problems: simpleViolationGeometries, reason: .selfIntersection)]
            }
            
            return []
        }
    }
}
