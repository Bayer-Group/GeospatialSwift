import geos

extension GeoJson {
    /**
     Creates a LineString
     */
    public func lineString(points: [Point]) -> Result<LineString, InvalidGeoJson> {
        guard points.count >= 2 else { return .failure(.init(reason: "A valid LineString must have at least two Points")) }
        
        return .success(LineString(points: points))
    }
    
    public struct LineString: GeoJsonLinearGeometry, GeodesicLine {
        public let type: GeoJsonObjectType = .lineString
        
        internal let geoJsonPoints: [Point]
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let pointsJson = coordinatesJson as! [[Any]]
            
            geoJsonPoints = pointsJson.map { Point(coordinatesJson: $0) }
        }
        
        internal init(points: [Point]) {
            geoJsonPoints = points
        }
    }
}

extension GeoJson.LineString {
    public var points: [GeodesicPoint] { geoJsonPoints }
    
    public var lines: [GeodesicLine] { [self] }
    
    public var segments: [GeodesicLineSegment] {
        points.enumerated().compactMap { (offset, point) in
            if points.count == offset + 1 { return nil }
            
            return .init(startPoint: point, endPoint: points[offset + 1])
        }
    }
    
    public var geoJsonCoordinates: [Any] { geoJsonPoints.map { $0.geoJsonCoordinates } }
    
    public var boundingBox: GeodesicBoundingBox { .best(geoJsonPoints.compactMap { $0.boundingBox })! }
    
    public var length: Double { Calculator.length(of: self) }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: point, to: self, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { Calculator.contains(point, in: self, tolerance: tolerance) }
    
    public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
        let duplicatePoints = Calculator.simpleViolationDuplicateIndices(points: points, tolerance: tolerance).map { geoJsonPoints[$0[0]] }
        
        guard duplicatePoints.isEmpty else { return [GeoJsonSimpleViolation(problems: duplicatePoints, reason: .pointDuplication)] }
        
        let selfIntersectsIndices = Calculator.simpleViolationSelfIntersectionIndices(line: self, tolerance: tolerance)
        
        guard selfIntersectsIndices.isEmpty else {
            var simpleViolationGeometries = [GeoJsonCoordinatesGeometry]()
            selfIntersectsIndices.forEach { firstIndex, secondIndices in
                var point = GeoJson.Point(longitude: segments[firstIndex].startPoint.longitude, latitude: segments[firstIndex].startPoint.latitude)
                var otherPoint = GeoJson.Point(longitude: segments[firstIndex].endPoint.longitude, latitude: segments[firstIndex].endPoint.latitude)
                simpleViolationGeometries.append(point)
                simpleViolationGeometries.append(otherPoint)
                simpleViolationGeometries.append(GeoJson.LineString(points: [point, otherPoint]))
                
                secondIndices.forEach {
                    point = GeoJson.Point(longitude: segments[$0].startPoint.longitude, latitude: segments[$0].startPoint.latitude)
                    otherPoint = GeoJson.Point(longitude: segments[$0].endPoint.longitude, latitude: segments[$0].endPoint.latitude)
                    simpleViolationGeometries.append(point)
                    simpleViolationGeometries.append(otherPoint)
                    simpleViolationGeometries.append(GeoJson.LineString(points: [point, otherPoint]))
                }
            }
            
            return [GeoJsonSimpleViolation(problems: simpleViolationGeometries, reason: .lineIntersection)]
        }
        
        return []
    }
}

extension GeoJson.LineString {
    internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
        guard let pointsCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid LineString must have valid coordinates") }
        
        guard pointsCoordinatesJson.count >= 2 else { return .init(reason: "A valid LineString must have at least two Points") }
        
        let validatePoints = pointsCoordinatesJson.reduce(nil) { $0 + GeoJson.Point.validate(coordinatesJson: $1) }
        
        return validatePoints.flatMap { .init(reason: "Invalid Point(s) in LineString") + $0 }
    }
}

extension GeoJson.LineString: GEOSObjectConvertible {
    func geosObject(with context: GEOSContext) throws -> GEOSObject {
        try makeGEOSObject(with: context, points: geoJsonPoints) { (context, sequence) in
            GEOSGeom_createLinearRing_r(context.handle, sequence)
        }
    }
}

extension GeoJson.LineString: GEOSObjectInitializable {
    init(geosObject: GEOSObject) throws {
        guard case .some(.linearRing) = geosObject.type else {
            throw GEOSError.typeMismatch(actual: geosObject.type, expected: .linearRing)
        }
        try self.init(points: makePoints(from: geosObject))
    }
}
