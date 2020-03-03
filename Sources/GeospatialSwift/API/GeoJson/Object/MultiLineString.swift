extension GeoJson {
    /**
     Creates a MultiLineString
     */
    public func multiLineString(lineStrings: [LineString]) -> Result<MultiLineString, InvalidGeoJson> {
        guard lineStrings.count >= 1 else { return .failure(.init(reason: "A valid MultiLineString must have at least one LineString")) }
        
        return .success(MultiLineString(lineStrings: lineStrings))
    }
    
    public struct MultiLineString: GeoJsonLinearGeometry {
        public let type: GeoJsonObjectType = .multiLineString
        
        private let geoJsonLineStrings: [LineString]
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let lineStringsJson = coordinatesJson as! [[Any]]
            
            geoJsonLineStrings = lineStringsJson.map { LineString(coordinatesJson: $0) }
        }
        
        fileprivate init(lineStrings: [LineString]) {
            geoJsonLineStrings = lineStrings
        }
    }
}

extension GeoJson.MultiLineString {
    public var lines: [GeodesicLine] { geoJsonLineStrings }
    
    public var geoJsonCoordinates: [Any] { geoJsonLineStrings.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { lines.flatMap { $0.points } }
    
    public var boundingBox: GeodesicBoundingBox { .best(lines.map { $0.boundingBox })! }
    
    public var length: Double { geoJsonLineStrings.reduce(0) { $0 + $1.length } }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { geoJsonLineStrings.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geoJsonLineStrings.first { $0.contains(point, tolerance: tolerance) } != nil }
    
    public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
        let lineSimpleViolations = geoJsonLineStrings.map { $0.simpleViolations(tolerance: tolerance) }.filter { $0.count>0 }.flatMap { $0 }
        
        guard lineSimpleViolations.isEmpty else {
            return lineSimpleViolations
        }
        
        let simpleViolationIntersectionIndices = Calculator.simpleViolationIntersectionIndices(lines: lines, tolerance: tolerance)
        
        guard simpleViolationIntersectionIndices.isEmpty else {
            var violations = [GeoJsonSimpleViolation]()
            simpleViolationIntersectionIndices.sorted(by: { $0.key < $1.key }).forEach { lineSegmentIndex1 in
                let segment1 = lines[lineSegmentIndex1.key.lineIndex].segments[lineSegmentIndex1.key.segmentIndex]
                let point1 = GeoJson.Point(longitude: segment1.startPoint.longitude, latitude: segment1.startPoint.latitude)
                let point2 = GeoJson.Point(longitude: segment1.endPoint.longitude, latitude: segment1.endPoint.latitude)
                let line1 = GeoJson.LineString(points: [point1, point2])
                
                lineSegmentIndex1.value.forEach { lineSegmentIndex2 in
                    let segment2 = lines[lineSegmentIndex2.lineIndex].segments[lineSegmentIndex2.segmentIndex]
                    let point3 = GeoJson.Point(longitude: segment2.startPoint.longitude, latitude: segment2.startPoint.latitude)
                    let point4 = GeoJson.Point(longitude: segment2.endPoint.longitude, latitude: segment2.endPoint.latitude)
                    let line2 = GeoJson.LineString(points: [point3, point4])
                    
                    violations += [GeoJsonSimpleViolation(problems: [point1, point2, line1, point3, point4, line2], reason: .multiLineIntersection)]
                }
            }
            
            return violations
        }
        
        return []
    }
}

extension GeoJson.MultiLineString {
    internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
        guard let lineStringsCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid MultiLineString must have valid coordinates") }
        
        guard lineStringsCoordinatesJson.count >= 1 else { return .init(reason: "A valid MultiLineString must have at least one LineString") }
        
        let validateLineStrings = lineStringsCoordinatesJson.reduce(nil) { $0 + GeoJson.LineString.validate(coordinatesJson: $1) }
        
        return validateLineStrings.flatMap { .init(reason: "Invalid LineString(s) in MultiLineString") + $0 }
    }
}
