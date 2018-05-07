internal typealias MultiPolygon = GeoJson.MultiPolygon

public protocol GeoJsonMultiPolygon: GeoJsonClosedGeometry {
    var polygons: [GeoJsonPolygon] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiPolygon
     */
    public func multiPolygon(polygons: [GeoJsonPolygon]) -> GeoJsonMultiPolygon? {
        return MultiPolygon(logger: logger, geodesicCalculator: geodesicCalculator, polygons: polygons)
    }
    
    public final class MultiPolygon: GeoJsonMultiPolygon {
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
        
        private let logger: LoggerProtocol
        private let geodesicCalculator: GeodesicCalculatorProtocol
        
        public let polygons: [GeoJsonPolygon]
        
        public var points: [GeoJsonPoint] { return polygons.flatMap { $0.points } }
        
        public var boundingBox: GeoJsonBoundingBox { return BoundingBox.best(polygons.map { $0.boundingBox })! }
        
        public var centroid: GeodesicPoint { return geodesicCalculator.centroid(polygons: polygons) }
        
        internal convenience init?(logger: LoggerProtocol, geodesicCalculator: GeodesicCalculatorProtocol, coordinatesJson: [Any]) {
            guard let multiPolygonJson = coordinatesJson as? [[Any]] else { logger.error("A valid MultiPolygon must have valid coordinates"); return nil }
            
            var polygons = [GeoJsonPolygon]()
            for polygonJson in multiPolygonJson {
                if let polygon = Polygon(logger: logger, geodesicCalculator: geodesicCalculator, coordinatesJson: polygonJson) {
                    polygons.append(polygon)
                } else {
                    logger.error("Invalid Polygon in MultiPolygon"); return nil
                }
            }
            
            self.init(logger: logger, geodesicCalculator: geodesicCalculator, polygons: polygons)
        }
        
        // TODO: More strict additions:
        // Multipolygon where two polygons intersect - validate that two polygons are merged as well
        fileprivate init?(logger: LoggerProtocol, geodesicCalculator: GeodesicCalculatorProtocol, polygons: [GeoJsonPolygon]) {
            guard polygons.count >= 1 else { logger.error("A valid MultiPolygon must have at least one Polygon"); return nil }
            
            self.logger = logger
            self.geodesicCalculator = geodesicCalculator
            
            self.polygons = polygons
        }
        
        public func edgeDistance(to point: GeodesicPoint, errorDistance: Double) -> Double {
            return polygons.map { $0.edgeDistance(to: point, errorDistance: errorDistance) }.min()!
        }
        
        public func distance(to point: GeodesicPoint, errorDistance: Double) -> Double { return polygons.map { $0.distance(to: point, errorDistance: errorDistance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return polygons.first { $0.contains(point, errorDistance: errorDistance) } != nil }
    }
}
