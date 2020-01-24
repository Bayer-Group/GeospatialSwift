public protocol GeoJsonMultiPolygon: GeoJsonClosedGeometry {
    var polygons: [GeoJsonPolygon] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiPolygon
     */
    public func multiPolygon(polygons: [GeoJsonPolygon]) -> GeoJsonMultiPolygon? { MultiPolygon(polygons: polygons) }
    
    public struct MultiPolygon: GeoJsonMultiPolygon {
        public let type: GeoJsonObjectType = .multiPolygon
        
        public let polygons: [GeoJsonPolygon]
        
        internal static func invalidReasons(coordinatesJson: [Any]) -> [String]? {
            guard let multiPolygonCoordinatesJson = coordinatesJson as? [[Any]] else { return ["A valid MultiPolygon must have valid coordinates"] }
            
            guard multiPolygonCoordinatesJson.count >= 1 else { return ["A valid FeatureCollection must have at least one feature"] }
            
            return multiPolygonCoordinatesJson.compactMap { Polygon.invalidReasons(coordinatesJson: $0) }.flatMap { $0 }.nilIfEmpty.flatMap { ["Invalid Polygon in MultiPolygon"] + $0 }
        }
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let multiPolygonJson = coordinatesJson as! [[Any]]
            
            polygons = multiPolygonJson.map { Polygon(coordinatesJson: $0) }
        }
        
        // SOMEDAY: More strict additions:
        // Multipolygon where two polygons intersect - validate that two polygons are merged as well
        fileprivate init?(polygons: [GeoJsonPolygon]) {
            guard polygons.count >= 1 else { Log.warning("A valid MultiPolygon must have at least one Polygon"); return nil }
            
            self.polygons = polygons
        }
    }
}

extension GeoJson.MultiPolygon {
    public var geoJsonCoordinates: [Any] { polygons.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { polygons.flatMap { $0.points } }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(polygons.map { $0.boundingBox })! }
    
    public var hasHole: Bool { polygons.contains { $0.hasHole } }
    
    public var area: Double { polygons.reduce(0) { $0 + $1.area } }
    
    public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double { polygons.map { $0.edgeDistance(to: point, tolerance: tolerance) }.min()! }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { polygons.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { polygons.first { $0.contains(point, tolerance: tolerance) } != nil }
}
