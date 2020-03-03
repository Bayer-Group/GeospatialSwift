extension GeoJson {
    /**
     Creates a MultiPoint
     */
    public func multiPoint(points: [Point]) -> Result<MultiPoint, InvalidGeoJson> {
        guard points.count >= 1 else { return .failure(.init(reason: "A valid MultiPoint must have at least one Point")) }
        
        return .success(MultiPoint(points: points))
    }
    
    public struct MultiPoint: GeoJsonCoordinatesGeometry {
        public let type: GeoJsonObjectType = .multiPoint
        
        private let geoJsonPoints: [Point]
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let pointsJson = coordinatesJson as! [[Any]]
            
            geoJsonPoints = pointsJson.map { Point(coordinatesJson: $0) }
        }
        
        fileprivate init(points: [Point]) {
            geoJsonPoints = points
        }
    }
}

extension GeoJson.MultiPoint {
    public var points: [GeodesicPoint] { geoJsonPoints }
    
    public var geoJsonCoordinates: [Any] { geoJsonPoints.map { $0.geoJsonCoordinates } }
    
    public var boundingBox: GeodesicBoundingBox { .best(geoJsonPoints.compactMap { $0.boundingBox })! }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { geoJsonPoints.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geoJsonPoints.first { $0.contains(point, tolerance: tolerance) } != nil }
    
    public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
        let duplicatePoints = Calculator.simpleViolationDuplicateIndices(points: points, tolerance: tolerance).map { geoJsonPoints[$0[0]] }
        
        guard duplicatePoints.isEmpty else { return [GeoJsonSimpleViolation(problems: duplicatePoints, reason: .pointDuplication)] }
        
        return []
    }
}

extension GeoJson.MultiPoint {
    internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
        guard let pointsCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid MultiPoint must have valid coordinates") }
        
        guard pointsCoordinatesJson.count >= 1 else { return .init(reason: "A valid MultiPoint must have at least one Point") }
        
        let validatePoints = pointsCoordinatesJson.reduce(nil) { $0 + GeoJson.Point.validate(coordinatesJson: $1) }
        
        return validatePoints.flatMap { .init(reason: "Invalid Point(s) in MultiPoint") + $0 }
    }
}
