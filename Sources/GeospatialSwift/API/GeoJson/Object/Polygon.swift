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
        
        public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
            let ringSimpleViolations = geoJsonLinearRings.map { $0.simpleViolations(tolerance: tolerance) }.filter { $0.count>0 }.flatMap { $0 }

            guard ringSimpleViolations.isEmpty else { return ringSimpleViolations }
            
            let outsideSegmentIndices = Calculator.simpleViolationSegmentOutsideIndices(from: self, tolerance: tolerance)
            
            guard outsideSegmentIndices.isEmpty else {
                return outsideSegmentIndices.map { outsideSegmentIndex in
                    let segment = negativeRings[outsideSegmentIndex.lineIndex].segments[outsideSegmentIndex.segementIndex]
                    let point1 = Point(longitude: segment.startPoint.longitude, latitude: segment.startPoint.latitude)
                    let point2 = Point(longitude: segment.endPoint.longitude, latitude: segment.endPoint.latitude)
                    let line1 = LineString(points: [point1, point2])!
                    return GeoJsonSimpleViolation(problems: [point1, point2, line1], reason: .polygonHoleOutside)
                }
            }
            
            let negativeRingsContainedIndices = Calculator.simpleViolationNegativeRingContainedIndices(from: self, tolerance: tolerance)
            
            guard negativeRingsContainedIndices.isEmpty else {
                var violations = [GeoJsonSimpleViolation]()
                negativeRingsContainedIndices.forEach { index in
                    var geometries = [GeoJsonCoordinatesGeometry]()
                    negativeRings[index].segments.forEach { segment in
                        let point1 = Point(longitude: segment.startPoint.longitude, latitude: segment.startPoint.latitude)
                        let point2 = Point(longitude: segment.endPoint.longitude, latitude: segment.endPoint.latitude)
                        geometries.append(point1)
                        geometries.append(LineString(points: [point1, point2])!)
                    }
                    violations += [GeoJsonSimpleViolation(problems: geometries, reason: .polygonNegativeRingContained)]
                }
                return violations
            }
            
            let simpleViolationIntersectionIndices = Calculator.simpleViolationIntersectionIndices(from: self, tolerance: tolerance)
            
            guard simpleViolationIntersectionIndices.isEmpty else {
                var violations = [GeoJsonSimpleViolation]()
                simpleViolationIntersectionIndices.sorted(by: { $0.key < $1.key }).forEach { lineSegmentIndex1 in
                    let segment1 = linearRings[lineSegmentIndex1.key.lineIndex].segments[lineSegmentIndex1.key.segementIndex]
                    let point1 = Point(longitude: segment1.startPoint.longitude, latitude: segment1.startPoint.latitude)
                    let point2 = Point(longitude: segment1.endPoint.longitude, latitude: segment1.endPoint.latitude)
                    let line1 = LineString(points: [point1, point2])!
                    
                    lineSegmentIndex1.value.forEach { lineSegmentIndex2 in
                        let segment2 = linearRings[lineSegmentIndex2.lineIndex].segments[lineSegmentIndex2.segementIndex]
                        let point3 = Point(longitude: segment2.startPoint.longitude, latitude: segment2.startPoint.latitude)
                        let point4 = Point(longitude: segment2.endPoint.longitude, latitude: segment2.endPoint.latitude)
                        let line2 = LineString(points: [point3, point4])!
                        
                        violations += [GeoJsonSimpleViolation(problems: [point1, point2, line1, point3, point4, line2], reason: .multiLineIntersection)]
                    }
                }
                return violations
            }
            
            return []
        }
    }
}
