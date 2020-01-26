extension GeoJson {
    /**
     Creates a Polygon
     */
    public func polygon(mainRing: LineString, negativeRings: [LineString]) -> Result<Polygon, InvalidGeoJson> {
        if let invalidGeoJson = LinearRing.validate(linearRing: mainRing) + negativeRings.reduce(nil, { $0 + LinearRing.validate(linearRing: $1) }) { return .failure(invalidGeoJson) }
        
        return .success(Polygon(mainRing: mainRing, negativeRings: negativeRings))
    }
    
    public struct Polygon: GeoJsonClosedGeometry, GeodesicPolygon {
        public let type: GeoJsonObjectType = .polygon
        
        private let geoJsonMainRing: LineString
        private let geoJsonNegativeRings: [LineString]
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let linearRingsJson = coordinatesJson as! [[Any]]
            
            geoJsonMainRing = LineString(coordinatesJson: linearRingsJson.first!)
            geoJsonNegativeRings = linearRingsJson.dropFirst().map { LineString(coordinatesJson: $0) }
        }
        
        fileprivate init(mainRing: LineString, negativeRings: [LineString]) {
            geoJsonMainRing = mainRing
            geoJsonNegativeRings = negativeRings
        }
    }
}

extension GeoJson.Polygon {
    public var mainRing: GeodesicLine { geoJsonMainRing }
    public var negativeRings: [GeodesicLine] { geoJsonNegativeRings }
    public var linearRings: [GeodesicLine] { geoJsonLinearRings }

    private var geoJsonLinearRings: [GeoJson.LineString] { [geoJsonMainRing] + geoJsonNegativeRings }
    
    public var geoJsonCoordinates: [Any] { geoJsonLinearRings.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { linearRings.flatMap { $0.points } }
    
    public var boundingBox: GeodesicBoundingBox { .best(linearRings.map { $0.boundingBox })! }
    
    public var centroid: GeodesicPoint { Calculator.centroid(polygon: self) }
    
    public var polygons: [GeodesicPolygon] { [self] }
    
    public var hasHole: Bool { negativeRings.count > 0 }
    
    public var area: Double { Calculator.area(of: self) }
    
    public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.edgeDistance(from: point, to: self, tolerance: tolerance) }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { Calculator.distance(from: point, to: self, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
        // Must at least be within the bounding box.
        guard mainRing.boundingBox.contains(point: point, tolerance: tolerance) else { return false }
        
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

extension GeoJson.Polygon {
    internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
        guard let linearRingsCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid Polygon must have valid coordinates") }
        
        guard linearRingsCoordinatesJson.count >= 1 else { return .init(reason: "A valid Polygon must have at least one LinearRing") }
        
        let validateLinearRings = linearRingsCoordinatesJson.reduce(nil) { $0 + GeoJson.LinearRing.validate(coordinatesJson: $1) }
        
        return validateLinearRings.flatMap { .init(reason: "Invalid LinearRing(s) in Polygon") + $0 }
    }
}
