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
        
        internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
            guard let multiPolygonCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid MultiPolygon must have valid coordinates") }
            
            guard multiPolygonCoordinatesJson.count >= 1 else { return .init(reason: "A valid FeatureCollection must have at least one feature") }
            
            let validatePolygons = multiPolygonCoordinatesJson.reduce(nil) { $0 + Polygon.validate(coordinatesJson: $1) }
            
            return validatePolygons.flatMap { .init(reason: "Invalid Polygon(s) in MultiPolygon") + $0 }
        }
        
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
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geoJsonPolygons.first { $0.contains(point, tolerance: tolerance) } != nil }
}
