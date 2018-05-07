internal typealias MultiLineString = GeoJson.MultiLineString

public protocol GeoJsonMultiLineString: GeoJsonMultiCoordinatesGeometry {
    var lineStrings: [GeoJsonLineString] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiLineString
     */
    public func multiLineString(lineStrings: [GeoJsonLineString]) -> GeoJsonMultiLineString? {
        return MultiLineString(logger: logger, geodesicCalculator: geodesicCalculator, lineStrings: lineStrings)
    }
    
    public final class MultiLineString: GeoJsonMultiLineString {
        public let type: GeoJsonObjectType = .multiLineString
        public var geoJsonCoordinates: [Any] { return lineStrings.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            MultiLineString: \(
            """
            (\n\(lineStrings.enumerated().map { "Line \($0) - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        private let logger: LoggerProtocol
        private let geodesicCalculator: GeodesicCalculatorProtocol
        
        public let lineStrings: [GeoJsonLineString]
        
        public var points: [GeoJsonPoint] {
            return lineStrings.flatMap { $0.points }
        }
        
        public var boundingBox: GeoJsonBoundingBox {
            return BoundingBox.best(lineStrings.map { $0.boundingBox })!
        }
        
        public var centroid: GeodesicPoint {
            return geodesicCalculator.centroid(lines: lineStrings)
        }
        
        internal convenience init?(logger: LoggerProtocol, geodesicCalculator: GeodesicCalculatorProtocol, coordinatesJson: [Any]) {
            guard let lineStringsJson = coordinatesJson as? [[Any]] else { logger.error("A valid MultiLineString must have valid coordinates"); return nil }
            
            var lineStrings = [GeoJsonLineString]()
            for lineStringJson in lineStringsJson {
                if let lineString = LineString(logger: logger, geodesicCalculator: geodesicCalculator, coordinatesJson: lineStringJson) {
                    lineStrings.append(lineString)
                } else {
                    logger.error("Invalid LineString in MultiLineString"); return nil
                }
            }
            
            self.init(logger: logger, geodesicCalculator: geodesicCalculator, lineStrings: lineStrings)
        }
        
        fileprivate init?(logger: LoggerProtocol, geodesicCalculator: GeodesicCalculatorProtocol, lineStrings: [GeoJsonLineString]) {
            guard lineStrings.count >= 1 else { logger.error("A valid MultiLineString must have at least one LineString"); return nil }
            
            self.logger = logger
            self.geodesicCalculator = geodesicCalculator
            
            self.lineStrings = lineStrings
        }
        
        public func distance(to point: GeodesicPoint, errorDistance: Double) -> Double { return lineStrings.map { $0.distance(to: point, errorDistance: errorDistance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return lineStrings.first { $0.contains(point, errorDistance: errorDistance) } != nil }
    }
}
