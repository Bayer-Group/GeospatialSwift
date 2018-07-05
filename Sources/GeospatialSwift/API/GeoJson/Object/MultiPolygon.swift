internal typealias MultiPolygon = GeoJson.MultiPolygon

public protocol GeoJsonMultiPolygon: GeoJsonClosedGeometry {
    var polygons: [GeoJsonPolygon] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiPolygon
     */
    public func multiPolygon(polygons: [GeoJsonPolygon]) -> GeoJsonMultiPolygon? {
        return MultiPolygon(polygons: polygons)
    }
    
    public struct MultiPolygon: GeoJsonMultiPolygon {
        public let type: GeoJsonObjectType = .multiPolygon
        public var geoJsonCoordinates: [Any] { return polygons.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            MultiPolygon: \(
            """
            (\n\(polygons.enumerated().map { "Line \($0) - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let polygons: [GeoJsonPolygon]
        
        public var points: [GeoJsonPoint] { return polygons.flatMap { $0.points } }
        
        public var boundingBox: GeoJsonBoundingBox { return BoundingBox.best(polygons.map { $0.boundingBox })! }
        
        public var centroid: GeodesicPoint { return Calculator.centroid(polygons: polygons) }
        
        public var hasHole: Bool { return polygons.contains { $0.hasHole } }
        
        public var area: Double { return polygons.reduce(0) { $0 + $1.area } }
        
        internal init?(coordinatesJson: [Any]) {
            guard let multiPolygonJson = coordinatesJson as? [[Any]] else { Log.warning("A valid MultiPolygon must have valid coordinates"); return nil }
            
            var polygons = [GeoJsonPolygon]()
            for polygonJson in multiPolygonJson {
                if let polygon = Polygon(coordinatesJson: polygonJson) {
                    polygons.append(polygon)
                } else {
                    Log.warning("Invalid Polygon in MultiPolygon"); return nil
                }
            }
            
            self.init(polygons: polygons)
        }
        
        // TODO: More strict additions:
        // Multipolygon where two polygons intersect - validate that two polygons are merged as well
        fileprivate init?(polygons: [GeoJsonPolygon]) {
            guard polygons.count >= 1 else { Log.warning("A valid MultiPolygon must have at least one Polygon"); return nil }
            
            self.polygons = polygons
        }
        
        public func edgeDistance(to point: GeodesicPoint, errorDistance: Double) -> Double {
            return polygons.map { $0.edgeDistance(to: point, errorDistance: errorDistance) }.min()!
        }
        
        public func distance(to point: GeodesicPoint, errorDistance: Double) -> Double { return polygons.map { $0.distance(to: point, errorDistance: errorDistance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return polygons.first { $0.contains(point, errorDistance: errorDistance) } != nil }
    }
}
