extension GeoJson {
    /**
     Creates a MultiPolygon
     */
    public func multiPolygon(polygons: [Polygon]) -> Result<MultiPolygon, InvalidGeoJson> {
        guard polygons.count >= 1 else { return .failure(.init(reason: "A valid MultiPolygon must have at least one Polygon")) }
        
        return .success(MultiPolygon(polygons: polygons))
    }
    
    public struct MultiPolygon: GeoJsonClosedGeometry {
        public let type: GeoJsonObjectType = .multiPolygon
        
        public let geoJsonPolygons: [Polygon]
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let multiPolygonJson = coordinatesJson as! [[Any]]
            
            geoJsonPolygons = multiPolygonJson.map { Polygon(coordinatesJson: $0) }
        }
        
        // SOMEDAY: More strict additions:
        // Multipolygon where two polygons intersect - validate that two polygons are merged as well
        fileprivate init(polygons: [Polygon]) {
            geoJsonPolygons = polygons
        }
    }
}

extension GeoJson.MultiPolygon {
    public var polygons: [GeodesicPolygon] { geoJsonPolygons }
    
    public var geoJsonCoordinates: [Any] { geoJsonPolygons.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { polygons.flatMap { $0.points } }
    
    public var boundingBox: GeodesicBoundingBox { .best(polygons.map { $0.boundingBox })! }
    
    public var hasHole: Bool { geoJsonPolygons.contains { $0.hasHole } }
    
    public var area: Double { geoJsonPolygons.reduce(0) { $0 + $1.area } }
    
    public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double { geoJsonPolygons.map { $0.edgeDistance(to: point, tolerance: tolerance) }.min()! }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { geoJsonPolygons.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geoJsonPolygons.contains { $0.contains(point, tolerance: tolerance) } }
    
    public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
        let polygonSimpleViolation = geoJsonPolygons.map { $0.simpleViolations(tolerance: tolerance) }.filter { !$0.isEmpty }.flatMap { $0 }
        
        guard polygonSimpleViolation.isEmpty else {
            return polygonSimpleViolation
        }
        
        let polygonContainedIndices = Calculator.simpleViolationPolygonPointsContainedInAnotherPolygonIndices(from: polygons, tolerance: tolerance)
        
        guard polygonContainedIndices.isEmpty else {
            var violations = [GeoJsonSimpleViolation]()
            polygonContainedIndices.forEach { index in
                var geometries = [GeoJsonCoordinatesGeometry]()
                polygons[index].mainRing.segments.forEach { segment in
                    let point1 = GeoJson.Point(longitude: segment.startPoint.longitude, latitude: segment.startPoint.latitude)
                    let point2 = GeoJson.Point(longitude: segment.endPoint.longitude, latitude: segment.endPoint.latitude)
                    geometries.append(point1)
                    geometries.append(GeoJson.LineString(points: [point1, point2]))
                }
                violations += [GeoJsonSimpleViolation(problems: geometries, reason: .multiPolygonContained)]
            }
            return violations
        }
        
        let polygonLineSegmentIndiciesByIndex = Calculator.simpleViolationIntersectionIndices(from: polygons, tolerance: tolerance)
        
        guard polygonLineSegmentIndiciesByIndex.isEmpty else {
            var violations = [GeoJsonSimpleViolation]()
            polygonLineSegmentIndiciesByIndex.sorted(by: { $0.key < $1.key }).forEach { lineSegmentIndicies in
                let segment1 = polygons[lineSegmentIndicies.key.lineIndex].mainRing.segments[lineSegmentIndicies.key.segmentIndex]
                let point1 = GeoJson.Point(longitude: segment1.startPoint.longitude, latitude: segment1.startPoint.latitude)
                let point2 = GeoJson.Point(longitude: segment1.endPoint.longitude, latitude: segment1.endPoint.latitude)
                let line1 = GeoJson.LineString(points: [point1, point2])
                
                lineSegmentIndicies.value.forEach { lineSegmentIndex in
                    let segment2 = polygons[lineSegmentIndex.lineIndex].mainRing.segments[lineSegmentIndex.segmentIndex]
                    let point3 = GeoJson.Point(longitude: segment2.startPoint.longitude, latitude: segment2.startPoint.latitude)
                    let point4 = GeoJson.Point(longitude: segment2.endPoint.longitude, latitude: segment2.endPoint.latitude)
                    let line2 = GeoJson.LineString(points: [point3, point4])
                    
                    violations += [GeoJsonSimpleViolation(problems: [point1, point2, line1, point3, point4, line2], reason: .multiPolygonIntersection)]
                }
            }
            
            return violations
        }
        
        return []
    }
}

extension GeoJson.MultiPolygon {
    internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
        guard let multiPolygonCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid MultiPolygon must have valid coordinates") }
        
        guard multiPolygonCoordinatesJson.count >= 1 else { return .init(reason: "A valid FeatureCollection must have at least one feature") }
        
        let validatePolygons = multiPolygonCoordinatesJson.reduce(nil) { $0 + GeoJson.Polygon.validate(coordinatesJson: $1) }
        
        return validatePolygons.flatMap { .init(reason: "Invalid Polygon(s) in MultiPolygon") + $0 }
    }
}
