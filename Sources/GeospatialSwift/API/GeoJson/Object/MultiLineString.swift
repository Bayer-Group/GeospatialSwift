public protocol GeoJsonMultiLineString: GeoJsonLinearGeometry {
    var lineStrings: [GeoJsonLineString] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiLineString
     */
    public func multiLineString(lineStrings: [GeoJsonLineString]) -> GeoJsonMultiLineString? { MultiLineString(lineStrings: lineStrings) }
    
    public struct MultiLineString: GeoJsonMultiLineString {
        public let type: GeoJsonObjectType = .multiLineString
        
        public let lineStrings: [GeoJsonLineString]
        
        internal static func invalidReasons(coordinatesJson: [Any]) -> [String]? {
            guard let lineStringsCoordinatesJson = coordinatesJson as? [[Any]] else { return ["A valid MultiLineString must have valid coordinates"] }
            
            guard lineStringsCoordinatesJson.count >= 1 else { return ["A valid MultiLineString must have at least one LineString"] }
            
            return lineStringsCoordinatesJson.compactMap { LineString.invalidReasons(coordinatesJson: $0) }.flatMap { $0 }.nilIfEmpty.flatMap { ["Invalid LineString in MultiLineString"] + $0 }
        }
        
        internal init(coordinatesJson: [Any]) {
            // swiftlint:disable:next force_cast
            let lineStringsJson = coordinatesJson as! [[Any]]
            
            lineStrings = lineStringsJson.map { LineString(coordinatesJson: $0) }
        }
        
        fileprivate init?(lineStrings: [GeoJsonLineString]) {
            guard lineStrings.count >= 1 else { Log.warning("A valid MultiLineString must have at least one LineString"); return nil }
            
            self.lineStrings = lineStrings
        }
    }
}

extension GeoJson.MultiLineString {
    public var geoJsonCoordinates: [Any] { lineStrings.map { $0.geoJsonCoordinates } }
    
    public var points: [GeodesicPoint] { lineStrings.flatMap { $0.points } }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(lineStrings.map { $0.boundingBox })! }
    
    public var length: Double { lineStrings.reduce(0) { $0 + $1.length } }
    
    public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { lineStrings.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { lineStrings.first { $0.contains(point, tolerance: tolerance) } != nil }
}
