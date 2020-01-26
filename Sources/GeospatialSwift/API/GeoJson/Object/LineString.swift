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

extension GeoJson.LineString {
    public var points: [GeodesicPoint] { geoJsonPoints }
    
    public var lineStrings: [GeodesicLine] { [self] }
    
    public var segments: [GeodesicLineSegment] {
        points.enumerated().compactMap { (offset, point) in
            if points.count == offset + 1 { return nil }
            
            return .init(point: point, otherPoint: points[offset + 1])
        }
    }
    
    public var geoJsonCoordinates: [Any] { geoJsonPoints.map { $0.geoJsonCoordinates } }
    
    public var boundingBox: GeodesicBoundingBox { .best(geoJsonPoints.compactMap { $0.boundingBox })! }
    
    public var length: Double { Calculator.length(of: self) }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: point, to: self, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { Calculator.contains(point, in: self, tolerance: tolerance) }
}

extension GeoJson.LineString {
    internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
        guard let pointsCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid LineString must have valid coordinates") }
        
        guard pointsCoordinatesJson.count >= 2 else { return .init(reason: "A valid LineString must have at least two Points") }
        
        let validatePoints = pointsCoordinatesJson.reduce(nil) { $0 + GeoJson.Point.validate(coordinatesJson: $1) }
        
        return validatePoints.flatMap { .init(reason: "Invalid Point(s) in LineString") + $0 }
    }
}
