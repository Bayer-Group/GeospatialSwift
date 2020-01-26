public protocol GeoJsonLineString: GeoJsonLinearGeometry, GeodesicLine { }

extension GeoJson {
    /**
     Creates a GeoJsonLineString
     */
    public func lineString(points: [GeoJsonPoint]) -> Result<GeoJsonLineString, InvalidGeoJson> {
        guard points.count >= 2 else { return .failure(.init(reason: "A valid LineString must have at least two Points")) }
        
        return .success(LineString(points: points))
    }
    
    public struct LineString: GeoJsonLineString {
        public let type: GeoJsonObjectType = .lineString
        
        private let geoJsonPoints: [GeoJsonPoint]
        
        internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
            guard let pointsCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid LineString must have valid coordinates") }
            
            guard pointsCoordinatesJson.count >= 2 else { return .init(reason: "A valid LineString must have at least two Points") }
            
            let validatePoints = pointsCoordinatesJson.reduce(nil) { $0 + Point.validate(coordinatesJson: $1) }
            
            return validatePoints.flatMap { .init(reason: "Invalid Point(s) in LineString") + $0 }
        }
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let pointsJson = coordinatesJson as! [[Any]]
            
            geoJsonPoints = pointsJson.map { Point(coordinatesJson: $0) }
        }
        
        fileprivate init(points: [GeoJsonPoint]) {
            geoJsonPoints = points
        }
    }
    
    internal struct LinearRing {
        internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
            guard let pointsCoordinatesJson = coordinatesJson as? [[Double]] else { return .init(reason: "A valid LinearRing must have valid coordinates") }
            
            guard pointsCoordinatesJson.first! == pointsCoordinatesJson.last! else { return .init(reason: "A valid LinearRing must have the first and last points equal") }
            
            guard pointsCoordinatesJson.count >= 4 else { return .init(reason: "A valid LinearRing must have at least 4 points") }
            
            let validatePoints = pointsCoordinatesJson.reduce(nil) { $0 + Point.validate(coordinatesJson: $1) }
            
            return validatePoints.flatMap { .init(reason: "Invalid Point in LinearRing") + $0 }
        }
        
        internal static func validate(linearRing: GeoJsonLineString) -> InvalidGeoJson? {
            guard linearRing.points.first! == linearRing.points.last! else { return .init(reason: "A valid LinearRing must have the first and last points equal") }
            
            guard linearRing.points.count >= 4 else { return .init(reason: "A valid LinearRing must have at least 4 points")}
            
            return nil
        }
    }
}

extension GeoJson.LineString {
    public var points: [GeodesicPoint] { geoJsonPoints }
    
    public var lineStrings: [GeodesicLine] { [self] }
    
    public var segments: [GeodesicLineSegment] {
        points.enumerated().compactMap { (offset, point) in
            if points.count == offset + 1 { return nil }
            
            return LineSegment(point: point, otherPoint: points[offset + 1])
        }
    }
    
    public var geoJsonCoordinates: [Any] { geoJsonPoints.map { $0.geoJsonCoordinates } }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(geoJsonPoints.compactMap { $0.boundingBox })! }
    
    public var length: Double { Calculator.length(of: self) }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: point, to: self, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { Calculator.contains(point, in: self, tolerance: tolerance) }
}
