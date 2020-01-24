public protocol GeoJsonMultiPoint: GeoJsonCoordinatesGeometry {
    var geoJsonPoints: [GeoJsonPoint] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiPoint
     */
    public func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint? { MultiPoint(points: points) }
    
    public struct MultiPoint: GeoJsonMultiPoint {
        public let type: GeoJsonObjectType = .multiPoint
        
        public let geoJsonPoints: [GeoJsonPoint]
        
        internal static func invalidReasons(coordinatesJson: [Any]) -> [String]? {
            guard let pointsCoordinatesJson = coordinatesJson as? [[Any]] else { return ["A valid MultiPoint must have valid coordinates"] }
            
            guard pointsCoordinatesJson.count >= 1 else { return ["A valid MultiPoint must have at least one Point"] }
            
            return pointsCoordinatesJson.compactMap { Point.invalidReasons(coordinatesJson: $0) }.flatMap { $0 }.nilIfEmpty.flatMap { ["Invalid Point in MultiPoint"] + $0 }
        }
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let pointsJson = coordinatesJson as! [[Any]]
            
            geoJsonPoints = pointsJson.map { Point(coordinatesJson: $0) }
        }
        
        fileprivate init?(points: [GeoJsonPoint]) {
            guard points.count >= 1 else { Log.warning("A valid MultiPoint must have at least one Point"); return nil }
            
            geoJsonPoints = points
        }
    }
}

extension GeoJson.MultiPoint {
    public var geoJsonCoordinates: [Any] { geoJsonPoints.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { geoJsonPoints }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(geoJsonPoints.compactMap { $0.boundingBox })! }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { geoJsonPoints.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geoJsonPoints.first { $0.contains(point, tolerance: tolerance) } != nil }
}
