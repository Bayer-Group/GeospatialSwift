public protocol GeoJsonMultiLineString: GeoJsonLinearGeometry {
    var lineStrings: [GeoJsonLineString] { get }
    
    func invalidReasons(tolerance: Double) -> [[LineStringInvalidReason]]
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiLineString
     */
    public func multiLineString(lineStrings: [GeoJsonLineString]) -> GeoJsonMultiLineString? { MultiLineString(lineStrings: lineStrings) }
    
    public struct MultiLineString: GeoJsonMultiLineString {
        public let type: GeoJsonObjectType = .multiLineString
        
        public let lineStrings: [GeoJsonLineString]
        
        internal init?(coordinatesJson: [Any]) {
            guard let lineStringsJson = coordinatesJson as? [[Any]] else { Log.warning("A valid MultiLineString must have valid coordinates"); return nil }
            
            var lineStrings = [GeoJsonLineString]()
            for lineStringJson in lineStringsJson {
                if let lineString = LineString(coordinatesJson: lineStringJson) {
                    lineStrings.append(lineString)
                } else {
                    Log.warning("Invalid LineString in MultiLineString"); return nil
                }
            }
            
            self.init(lineStrings: lineStrings)
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
    
    public func invalidReasons(tolerance: Double) -> [[LineStringInvalidReason]] { lineStrings.map { $0.invalidReasons(tolerance: tolerance) } }
}
