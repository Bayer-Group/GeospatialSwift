public enum MultipointInvalidReason {
    case duplicates(indices: [Int])
}

public protocol GeoJsonMultiPoint: GeoJsonCoordinatesGeometry {
    func invalidReasons(tolerance: Double) -> [MultipointInvalidReason]
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiPoint
     */
    public func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint? {
        return MultiPoint(points: points)
    }
    
    public struct MultiPoint: GeoJsonMultiPoint {
        public var type: GeoJsonObjectType { return .multiPoint }
        public var geoJsonCoordinates: [Any] { return points.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            MultiPoint: \(
            """
            (\n\(points.enumerated().map { "\($0 + 1) - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let points: [GeoJsonPoint]
        
        public var boundingBox: GeodesicBoundingBox {
            return BoundingBox.best(points.compactMap { $0.boundingBox })!
        }
        
        internal init?(coordinatesJson: [Any]) {
            guard let pointsJson = coordinatesJson as? [[Any]] else { Log.warning("A valid MultiPoint must have valid coordinates"); return nil }
            
            var points = [GeoJsonPoint]()
            for pointJson in pointsJson {
                if let point = Point(coordinatesJson: pointJson) {
                    points.append(point)
                } else {
                    Log.warning("Invalid Point in MultiPoint"); return nil
                }
            }
            
            self.init(points: points)
        }
        
        fileprivate init?(points: [GeoJsonPoint]) {
            guard points.count >= 1 else { Log.warning("A valid MultiPoint must have at least one Point"); return nil }
            
            self.points = points
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { return points.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { return points.first { $0.contains(point, tolerance: tolerance) } != nil }
        
        public func invalidReasons(tolerance: Double) -> [MultipointInvalidReason] {
            let duplicateIndices = points.enumerated().filter { index, point in points.enumerated().contains { $0 > index && $1 == point } }.map { $0.offset }
            
            // SOMEDAY: If the other doesn't work...
            //            let duplicates = points.enumerated().filter { _, point in
            //                points.contains { otherPoint in
            //                    guard point != otherPoint else { return false }
            //
            //                    return Calculator.equals(point, otherPoint, tolerance: tolerance)
            //                }
            //            }
            //
            //            let duplicateIndices = duplicates.map { $0.offset }
            
            guard duplicateIndices.isEmpty else { return [.duplicates(indices: duplicateIndices)] }
            
            return []
        }
    }
}
