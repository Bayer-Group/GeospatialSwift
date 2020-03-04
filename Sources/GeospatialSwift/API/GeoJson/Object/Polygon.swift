extension GeoJson {
    /**
     Creates a Polygon
     */
    public func polygon(mainRing: LineString, negativeRings: [LineString]) -> Result<Polygon, InvalidGeoJson> {
        if let invalidGeoJson = LinearRing.validate(linearRing: mainRing) + negativeRings.reduce(nil, { $0 + LinearRing.validate(linearRing: $1) }) { return .failure(invalidGeoJson) }
        
        return .success(Polygon(mainRing: mainRing, negativeRings: negativeRings))
    }
    
    public struct Polygon: GeoJsonClosedGeometry, GeodesicPolygon {
        public let type: GeoJsonObjectType = .polygon
        
        private let geoJsonMainRing: LineString
        private let geoJsonNegativeRings: [LineString]
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let linearRingsJson = coordinatesJson as! [[Any]]
            
            geoJsonMainRing = LineString(coordinatesJson: linearRingsJson.first!)
            geoJsonNegativeRings = linearRingsJson.dropFirst().map { LineString(coordinatesJson: $0) }
        }
        
        fileprivate init(mainRing: LineString, negativeRings: [LineString]) {
            geoJsonMainRing = mainRing
            geoJsonNegativeRings = negativeRings
        }
    }
}

extension GeoJson.Polygon {
    public var mainRing: GeodesicLine { geoJsonMainRing }
    public var negativeRings: [GeodesicLine] { geoJsonNegativeRings }
    public var linearRings: [GeodesicLine] { geoJsonLinearRings }
    
    private var geoJsonLinearRings: [GeoJson.LineString] { [geoJsonMainRing] + geoJsonNegativeRings }
    
    public var geoJsonCoordinates: [Any] { geoJsonLinearRings.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { linearRings.flatMap { $0.points } }
    
    public var boundingBox: GeodesicBoundingBox { .best(linearRings.map { $0.boundingBox })! }
    
    public var centroid: GeodesicPoint { Calculator.centroid(polygon: self) }
    
    public var polygons: [GeodesicPolygon] { [self] }
    
    public var hasHole: Bool { negativeRings.count > 0 }
    
    public var area: Double { Calculator.area(of: self) }
    
    public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.edgeDistance(from: point, to: self, tolerance: tolerance) }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: point, to: self, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
        // Must at least be within the bounding box.
        guard mainRing.boundingBox.contains(point: point, tolerance: tolerance) else { return false }
        
        return Calculator.contains(point, in: self, tolerance: tolerance)
    }
    
    // SOMEDAY: See this helpful link for validations: https://github.com/mapbox/mapnik-vector-tile/issues/153
    
    // Checking winding order is valid
    // Triangle that reprojection to tile coordinates will cause winding order reversed
    // Polygon that will be reprojected into tile coordinates as a line
    // Polygon where area threshold removes geometry AFTER clipping
    // Polygon with reversed winding order
    // Polygon with hole where hole has invalid winding order
    
    public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
        //Ring self intersection
        let ringSimpleViolations = geoJsonLinearRings.map { GeoJson.LinearRing.simpleViolations(linearRing: $0, tolerance: tolerance) }.filter { $0.count > 0 }.flatMap { $0 }
        
        guard ringSimpleViolations.isEmpty else { return ringSimpleViolations }
        
        //Any negative ring points are outside of the main ring
        let outsideLineSegmentPointIndexs = Calculator.simpleViolationNegativeRingPointsOutsideMainRingIndices(from: self, tolerance: tolerance)
        
        guard outsideLineSegmentPointIndexs.isEmpty else {
            return outsideLineSegmentPointIndexs.map { outsideLineSegmentPointIndex in
                let lineSegmentIndex = outsideLineSegmentPointIndex.lineSegmentIndex
                let segment = negativeRings[lineSegmentIndex.lineIndex].segments[lineSegmentIndex.segmentIndex]
                
                let point1: GeoJson.Point
                if outsideLineSegmentPointIndex.pointIndex == .startPoint {
                    point1 = GeoJson.Point(longitude: segment.startPoint.longitude, latitude: segment.startPoint.latitude)
                } else {
                    point1 = GeoJson.Point(longitude: segment.endPoint.longitude, latitude: segment.endPoint.latitude)
                }
                return GeoJsonSimpleViolation(problems: [point1], reason: .polygonHoleOutside)
            }
        }
        
        //Any negative ring points are inside another negative ring
        let negativeRingsInsideIndices = Calculator.simpleViolationNegativeRingInsideAnotherNegativeRingIndices(from: self, tolerance: tolerance)
        
        guard negativeRingsInsideIndices.isEmpty else {
            var violations = [GeoJsonSimpleViolation]()
            negativeRingsInsideIndices.forEach { index in
                var geometries = [GeoJsonCoordinatesGeometry]()
                negativeRings[index].segments.forEach { segment in
                    let point1 = GeoJson.Point(longitude: segment.startPoint.longitude, latitude: segment.startPoint.latitude)
                    let point2 = GeoJson.Point(longitude: segment.endPoint.longitude, latitude: segment.endPoint.latitude)
                    geometries.append(point1)
                    geometries.append(GeoJson.LineString(points: [point1, point2]))
                }
                violations += [GeoJsonSimpleViolation(problems: geometries, reason: .polygonNegativeRingContained)]
            }
            return violations
        }
        
        //Ring intersects another ring
        let simpleViolationIntersectionIndices = Calculator.simpleViolationIntersectionIndices(from: self, tolerance: tolerance)
        
        guard simpleViolationIntersectionIndices.isEmpty else {
            var violations = [GeoJsonSimpleViolation]()
            simpleViolationIntersectionIndices.sorted(by: { $0.key < $1.key }).forEach { lineSegmentIndex1 in
                let segment1 = linearRings[lineSegmentIndex1.key.lineIndex].segments[lineSegmentIndex1.key.segmentIndex]
                let point1 = GeoJson.Point(longitude: segment1.startPoint.longitude, latitude: segment1.startPoint.latitude)
                let point2 = GeoJson.Point(longitude: segment1.endPoint.longitude, latitude: segment1.endPoint.latitude)
                let line1 = GeoJson.LineString(points: [point1, point2])
                
                lineSegmentIndex1.value.forEach { lineSegmentIndex2 in
                    let segment2 = linearRings[lineSegmentIndex2.lineIndex].segments[lineSegmentIndex2.segmentIndex]
                    let point3 = GeoJson.Point(longitude: segment2.startPoint.longitude, latitude: segment2.startPoint.latitude)
                    let point4 = GeoJson.Point(longitude: segment2.endPoint.longitude, latitude: segment2.endPoint.latitude)
                    let line2 = GeoJson.LineString(points: [point3, point4])
                    
                    violations += [GeoJsonSimpleViolation(problems: [point1, point2, line1, point3, point4, line2], reason: .polygonSelfIntersection)]
                }
            }
            return violations
        }
        
        //Ring has multiple vertex intersections with another ring
        let simpleViolationMultipleVertexIntersectionIndices = Calculator.simpleViolationMultipleVertexIntersectionIndices(from: self, tolerance: tolerance)
        
        guard simpleViolationMultipleVertexIntersectionIndices.isEmpty else {
            var violations = [GeoJsonSimpleViolation]()
            simpleViolationMultipleVertexIntersectionIndices.sorted(by: { $0.key < $1.key }).forEach { lineSegmentPointIndiciesIndex in
                let segment1 = linearRings[lineSegmentPointIndiciesIndex.key.lineIndex].segments[lineSegmentPointIndiciesIndex.key.segmentIndex]
                let point1 = GeoJson.Point(longitude: segment1.startPoint.longitude, latitude: segment1.startPoint.latitude)
                let point2 = GeoJson.Point(longitude: segment1.endPoint.longitude, latitude: segment1.endPoint.latitude)
                let line1 = GeoJson.LineString(points: [point1, point2])
                
                let lineSegmentIndex1 = lineSegmentPointIndiciesIndex.key
                for lineSegmentPointIndex in lineSegmentPointIndiciesIndex.value {
                    //remove duplicacy
                    let lineSegmentIndex2 = lineSegmentPointIndex.lineSegmentIndex
                    let lineSegmentStartPointIndex = LineSegmentPointIndex(lineSegmentIndex: lineSegmentIndex1, pointIndex: .startPoint)
                    let lineSegmentEndPointIndex = LineSegmentPointIndex(lineSegmentIndex: lineSegmentIndex1, pointIndex: .endPoint)
                    if let lineSegmentPointIndices = simpleViolationMultipleVertexIntersectionIndices[lineSegmentIndex2], lineSegmentIndex2 < lineSegmentPointIndiciesIndex.key {
                        guard !lineSegmentPointIndices.contains(lineSegmentStartPointIndex) && !lineSegmentPointIndices.contains(lineSegmentEndPointIndex) else { continue }
                    }
                    
                    let segment2 = linearRings[lineSegmentIndex2.lineIndex].segments[lineSegmentIndex2.segmentIndex]
                    if lineSegmentPointIndex.pointIndex == .startPoint {
                        let point3 = GeoJson.Point(longitude: segment2.startPoint.longitude, latitude: segment2.startPoint.latitude)
                        violations += [GeoJsonSimpleViolation(problems: [point1, point2, line1, point3], reason: .polygonMultipleVertexIntersection)]
                    } else {
                        let point3 = GeoJson.Point(longitude: segment2.endPoint.longitude, latitude: segment2.endPoint.latitude)
                        violations += [GeoJsonSimpleViolation(problems: [point1, point2, line1, point3], reason: .polygonMultipleVertexIntersection)]
                    }
                }
            }
            return violations
        }
        
        return []
    }
}

extension GeoJson.Polygon {
    internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
        guard let linearRingsCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid Polygon must have valid coordinates") }
        
        guard linearRingsCoordinatesJson.count >= 1 else { return .init(reason: "A valid Polygon must have at least one LinearRing") }
        
        let validateLinearRings = linearRingsCoordinatesJson.reduce(nil) { $0 + GeoJson.LinearRing.validate(coordinatesJson: $1) }
        
        return validateLinearRings.flatMap { .init(reason: "Invalid LinearRing(s) in Polygon") + $0 }
    }
}
