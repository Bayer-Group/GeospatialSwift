public protocol GeoJsonMultiPolygon: GeoJsonClosedGeometry {
    var polygons: [GeoJsonPolygon] { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
}

public enum MultiPolygonSimpleViolation {
    case polygonInvalid(reasons: [Int: [PolygonSimpleViolation]])
    case polygonsIntersect(indices: [Int])
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiPolygon
     */
    public func multiPolygon(polygons: [GeoJsonPolygon]) -> GeoJsonMultiPolygon? {
        return MultiPolygon(polygons: polygons)
    }
    
    public struct MultiPolygon: GeoJsonMultiPolygon {
        public let type: GeoJsonObjectType = .multiPolygon
        public var geoJsonCoordinates: [Any] { return polygons.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            MultiPolygon: \(
            """
            (\n\(polygons.enumerated().map { "Line \($0) - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let polygons: [GeoJsonPolygon]
        
        public var points: [GeodesicPoint] { return polygons.flatMap { $0.points } }
        
        public var boundingBox: GeodesicBoundingBox { return BoundingBox.best(polygons.map { $0.boundingBox })! }
        
        public var hasHole: Bool { return polygons.contains { $0.hasHole } }
        
        public var area: Double { return polygons.reduce(0) { $0 + $1.area } }
        
        internal init?(coordinatesJson: [Any]) {
            guard let multiPolygonJson = coordinatesJson as? [[Any]] else { Log.warning("A valid MultiPolygon must have valid coordinates"); return nil }
            
            var polygons = [GeoJsonPolygon]()
            for polygonJson in multiPolygonJson {
                if let polygon = Polygon(coordinatesJson: polygonJson) {
                    polygons.append(polygon)
                } else {
                    Log.warning("Invalid Polygon in MultiPolygon"); return nil
                }
            }
            
            self.init(polygons: polygons)
        }
        
        // SOMEDAY: More strict additions:
        // Multipolygon where two polygons intersect - validate that two polygons are merged as well
        fileprivate init?(polygons: [GeoJsonPolygon]) {
            guard polygons.count >= 1 else { Log.warning("A valid MultiPolygon must have at least one Polygon"); return nil }
            
            self.polygons = polygons
        }
        
        public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return polygons.map { $0.edgeDistance(to: point, tolerance: tolerance) }.min()!
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { return polygons.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
            for polygon in polygons {
                if polygon.contains(point) { return true }
            }
            
            return false
        }
        
        public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
            let polygonSimpleViolation = polygons.map { $0.simpleViolations(tolerance: tolerance) }.filter { !$0.isEmpty }.flatMap { $0 }
            
            guard polygonSimpleViolation.isEmpty else {
                return polygonSimpleViolation
            }
            
            let polygonContainedIndices = Calculator.simpleViolationPolygonPointsContainedInAnotherPolygonIndices(from: self, tolerance: tolerance)
            
            guard polygonContainedIndices.isEmpty else {
                var violations = [GeoJsonSimpleViolation]()
                polygonContainedIndices.forEach { index in
                    var geometries = [GeoJsonCoordinatesGeometry]()
                    polygons[index].mainRing.segments.forEach { segment in
                        let point1 = Point(longitude: segment.startPoint.longitude, latitude: segment.startPoint.latitude)
                        let point2 = Point(longitude: segment.endPoint.longitude, latitude: segment.endPoint.latitude)
                        geometries.append(point1)
                        geometries.append(LineString(points: [point1, point2])!)
                    }
                    violations += [GeoJsonSimpleViolation(problems: geometries, reason: .multiPolygonContained)]
                }
                return violations
            }
            
            let simpleViolationIntersectionIndices = Calculator.simpleViolationIntersectionIndices(from: self, tolerance: tolerance)
            
            guard simpleViolationIntersectionIndices.isEmpty else {
                var violations = [GeoJsonSimpleViolation]()
                simpleViolationIntersectionIndices.sorted(by: { $0.key < $1.key }).forEach { lineSegmentIndex1 in
                    let segment1 = polygons[lineSegmentIndex1.key.lineIndex].mainRing.segments[lineSegmentIndex1.key.segmentIndex]
                    let point1 = Point(longitude: segment1.startPoint.longitude, latitude: segment1.startPoint.latitude)
                    let point2 = Point(longitude: segment1.endPoint.longitude, latitude: segment1.endPoint.latitude)
                    let line1 = LineString(points: [point1, point2])!
                    
                    lineSegmentIndex1.value.forEach { lineSegmentIndex2 in
                        let segment2 = polygons[lineSegmentIndex2.lineIndex].mainRing.segments[lineSegmentIndex2.segmentIndex]
                        let point3 = Point(longitude: segment2.startPoint.longitude, latitude: segment2.startPoint.latitude)
                        let point4 = Point(longitude: segment2.endPoint.longitude, latitude: segment2.endPoint.latitude)
                        let line2 = LineString(points: [point3, point4])!
                        
                        violations += [GeoJsonSimpleViolation(problems: [point1, point2, line1, point3, point4, line2], reason: .multiPolygonIntersection)]
                    }
                }
                
                return violations
            }
            
            return []
        }
    }
}
