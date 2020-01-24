public protocol GeoJsonPolygon: GeoJsonClosedGeometry, GeodesicPolygon {
    var geoJsonLinearRings: [GeoJsonLineString] { get }
    var geoJsonMainRing: GeoJsonLineString { get }
    var geoJsonNegativeRings: [GeoJsonLineString] { get }
    var centroid: GeodesicPoint { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonPolygon
     */
    public func polygon(mainRing: GeoJsonLineString, negativeRings: [GeoJsonLineString]) -> GeoJsonPolygon? { Polygon(mainRing: mainRing, negativeRings: negativeRings) }
    
    public struct Polygon: GeoJsonPolygon {
        public let type: GeoJsonObjectType = .polygon
        
        public let geoJsonLinearRings: [GeoJsonLineString]
        
        internal static func invalidReasons(coordinatesJson: [Any]) -> [String]? {
            guard let linearRingsCoordinatesJson = coordinatesJson as? [[Any]] else { return ["A valid Polygon must have valid coordinates"] }
            
            guard linearRingsCoordinatesJson.count >= 1 else { return ["A valid Polygon must have at least one LinearRing"] }
            
            return linearRingsCoordinatesJson.compactMap { LinearRing.invalidReasons(coordinatesJson: $0) }.flatMap { $0 }.nilIfEmpty.flatMap { ["Invalid LinearRing in Polygon"] + $0 }
        }
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let linearRingsJson = coordinatesJson as! [[Any]]
            
            geoJsonLinearRings = linearRingsJson.map { LineString(coordinatesJson: $0) }
        }
        
        fileprivate init?(mainRing: GeoJsonLineString, negativeRings: [GeoJsonLineString]) {
            let linearRings = [mainRing] + negativeRings
            
            for linearRing in linearRings {
                guard linearRing.points.first! == linearRing.points.last! else { Log.warning("A valid Polygon LinearRing must have the first and last points equal"); return nil }
                
                guard linearRing.points.count >= 4 else { Log.warning("A valid Polygon LinearRing must have at least 4 points"); return nil }
            }
            
            geoJsonLinearRings = linearRings
        }
    }
}

extension GeoJson.Polygon {
    public var geoJsonCoordinates: [Any] { geoJsonLinearRings.map { $0.geoJsonCoordinates } }
    
    public var geoJsonMainRing: GeoJsonLineString { geoJsonLinearRings.first! }
    public var geoJsonNegativeRings: [GeoJsonLineString] { geoJsonLinearRings.tail ?? [] }
    
    public var linearRings: [GeodesicLine] { geoJsonLinearRings }
    public var mainRing: GeodesicLine { geoJsonMainRing }
    public var negativeRings: [GeodesicLine] { geoJsonNegativeRings }
    
    public var points: [GeodesicPoint] { linearRings.flatMap { $0.points } }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(geoJsonLinearRings.map { $0.boundingBox })! }
    
    public var centroid: GeodesicPoint { Calculator.centroid(polygon: self) }
    
    public var polygons: [GeoJsonPolygon] { [self] }
    
    public var hasHole: Bool { negativeRings.count > 0 }
    
    public var area: Double { Calculator.area(of: self) }
    
    public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.edgeDistance(from: point, to: self, tolerance: tolerance) }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: point, to: self, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
        // Must at least be within the bounding box.
        guard geoJsonMainRing.boundingBox.contains(point: point, tolerance: tolerance) else { return false }
        
        return Calculator.contains(point, in: self, tolerance: tolerance)
    }
    
    // SOMEDAY: See this helpful link for validations: https://github.com/mapbox/mapnik-vector-tile/issues/153
    
    // Checking winding order is valid
    // Triangle that reprojection to tile coordinates will cause winding order reversed
    // Polygon that will be reprojected into tile coordinates as a line
    // Polygon with "spike"
    // Polygon with hole that has a "spike"
    // Polygon where area threshold removes geometry AFTER clipping
    // Polygon with reversed winding order
    // Polygon with hole where hole has invalid winding order
}
