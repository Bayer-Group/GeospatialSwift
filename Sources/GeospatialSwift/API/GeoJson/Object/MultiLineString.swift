extension GeoJson {
    /**
     Creates a MultiLineString
     */
    public func multiLineString(lineStrings: [LineString]) -> Result<MultiLineString, InvalidGeoJson> {
        guard lineStrings.count >= 1 else { return .failure(.init(reason: "A valid MultiLineString must have at least one LineString")) }
        
        return .success(MultiLineString(lineStrings: lineStrings))
    }
    
    public struct MultiLineString: GeoJsonLinearGeometry {
        public let type: GeoJsonObjectType = .multiLineString
        
        private let geoJsonLineStrings: [LineString]
        
        internal static func validate(coordinatesJson: [Any]) -> InvalidGeoJson? {
            guard let lineStringsCoordinatesJson = coordinatesJson as? [[Any]] else { return .init(reason: "A valid MultiLineString must have valid coordinates") }
            
            guard lineStringsCoordinatesJson.count >= 1 else { return .init(reason: "A valid MultiLineString must have at least one LineString") }
            
            let validateLineStrings = lineStringsCoordinatesJson.reduce(nil) { $0 + LineString.validate(coordinatesJson: $1) }
            
            return validateLineStrings.flatMap { .init(reason: "Invalid LineString(s) in MultiLineString") + $0 }
        }
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let lineStringsJson = coordinatesJson as! [[Any]]
            
            geoJsonLineStrings = lineStringsJson.map { LineString(coordinatesJson: $0) }
        }
        
        fileprivate init(lineStrings: [LineString]) {
            geoJsonLineStrings = lineStrings
        }
    }
}

extension GeoJson.MultiLineString {
    public var lineStrings: [GeodesicLine] { geoJsonLineStrings }
    
    public var geoJsonCoordinates: [Any] { geoJsonLineStrings.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { lineStrings.flatMap { $0.points } }
    
    public var boundingBox: GeodesicBoundingBox { .best(lineStrings.map { $0.boundingBox })! }
    
    public var length: Double { geoJsonLineStrings.reduce(0) { $0 + $1.length } }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { geoJsonLineStrings.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geoJsonLineStrings.first { $0.contains(point, tolerance: tolerance) } != nil }
}
