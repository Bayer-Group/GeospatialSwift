public protocol GeoJsonLineString: GeoJsonLinearGeometry, GeodesicLine {
    var geoJsonPoints: [GeoJsonPoint] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonLineString
     */
    public func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString? { LineString(points: points) }
    
    public struct LineString: GeoJsonLineString {
        public let type: GeoJsonObjectType = .lineString
        
        public let geoJsonPoints: [GeoJsonPoint]
        
        internal static func invalidReasons(coordinatesJson: [Any]) -> [String]? {
            guard let pointsCoordinatesJson = coordinatesJson as? [[Any]] else { return ["A valid LineString must have valid coordinates"] }
            
            guard pointsCoordinatesJson.count >= 2 else { return ["A valid LineString must have at least two Points"] }
            
            return pointsCoordinatesJson.compactMap { Point.invalidReasons(coordinatesJson: $0) }.flatMap { $0 }.nilIfEmpty.flatMap { ["Invalid Point in LineString"] + $0 }
        }
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let pointsJson = coordinatesJson as! [[Any]]
            
            geoJsonPoints = pointsJson.map { Point(coordinatesJson: $0) }
        }
        
        fileprivate init?(points: [GeoJsonPoint]) {
            guard points.count >= 2 else { Log.warning("A valid LineString must have at least two Points"); return nil }
            
            self.geoJsonPoints = points
        }
    }
    
    internal struct LinearRing {
        internal static func invalidReasons(coordinatesJson: [Any]) -> [String]? {
            guard let pointsCoordinatesJson = coordinatesJson as? [[Double]] else { return ["A valid LinearRing must have valid coordinates"] }
            
            guard pointsCoordinatesJson.first! == pointsCoordinatesJson.last! else { return ["A valid LinearRing must have the first and last points equal"] }
            
            guard pointsCoordinatesJson.count >= 4 else { return ["A valid Polygon LinearRing must have at least 4 points"] }
            
            return pointsCoordinatesJson.compactMap { Point.invalidReasons(coordinatesJson: $0) }.flatMap { $0 }.nilIfEmpty.flatMap { ["Invalid Point in LinearRing"] + $0 }
        }
    }
}

extension GeoJson.LineString {
    public var segments: [GeodesicLineSegment] {
        geoJsonPoints.enumerated().compactMap { (offset, point) in
            if geoJsonPoints.count == offset + 1 { return nil }
            
            return LineSegment(point: point, otherPoint: geoJsonPoints[offset + 1])
        }
    }
    
    public var geoJsonCoordinates: [Any] { geoJsonPoints.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { geoJsonPoints }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(geoJsonPoints.compactMap { $0.boundingBox })! }
    
    public var lineStrings: [GeoJsonLineString] { [self] }
    
    public var length: Double { Calculator.length(of: self) }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: point, to: self, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { Calculator.contains(point, in: self, tolerance: tolerance) }
}
