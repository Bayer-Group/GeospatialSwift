public protocol GeoJsonMultiPolygon: GeoJsonClosedGeometry {
    var polygons: [GeoJsonPolygon] { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
}

public enum MultiPolygonSimpleViolation {
    case polygonInvalid(reasons: [Int: [PolygonSimpleViolation]])
    case polygonsIntersect(indices: [Int])
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
        
        public var points: [GeodesicPoint] { return polygons.flatMap { $0.points } }
        
        public var boundingBox: GeodesicBoundingBox { return BoundingBox.best(polygons.map { $0.boundingBox })! }
        
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
        
        // SOMEDAY: More strict additions:
        // Multipolygon where two polygons intersect - validate that two polygons are merged as well
        fileprivate init?(polygons: [GeoJsonPolygon]) {
            guard polygons.count >= 1 else { Log.warning("A valid MultiPolygon must have at least one Polygon"); return nil }
            
            self.polygons = polygons
        }
        
        public func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return polygons.map { $0.edgeDistance(to: point, tolerance: tolerance) }.min()!
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { return polygons.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
            for polygon in polygons {
                if polygon.contains(point) { return true }
            }
            
            return false
        }
        
        public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
            var reasons = [MultiPolygonSimpleViolation]()
            
//            //reasons.append(.polygonInvalid(reasons: polygons.map { $0.simpleViolations(tolerance: tolerance) }))
//            polygons.enumerated().forEach { index, polygon in
//                let reason = polygon.simpleViolations(tolerance: tolerance)
//                if reason.count>0 {
//                    reasons.append(.polygonInvalid(reasons: [index: polygon.simpleViolations(tolerance: tolerance)]))
//                }
//            }
//        
//            for index in 1..<polygons.count {
//                for indexOther in 0..<index {
//                    if hasIntersection(polygons[index], with: polygons[indexOther], tolerance: tolerance) {
//                        reasons.append(.polygonsIntersect(indices: [index, indexOther]))
//                    }
//                }
//            }
            
            return []
        }
        
        public func hasIntersection(_ polygon: GeoJsonPolygon, with otherPolygon: GeoJsonPolygon, tolerance: Double) -> Bool {
            for segment in polygon.mainRing.segments {
                if hasIntersection(segment, with: otherPolygon, tolerance: tolerance) { return true }
            }
            
            return false
        }
        
        private func hasIntersection(_ lineSegment: GeodesicLineSegment, with polygon: GeoJsonPolygon, tolerance: Double) -> Bool {
            let polygonIntersects = polygon.linearRings.map { $0.segments }.contains {
                $0.contains { hasIntersection($0, with: lineSegment, tolerance: tolerance) }
            }
            
            return polygonIntersects || (contains(lineSegment.point, tolerance: tolerance) && !isOnEdge(lineSegment.point, tolerance: tolerance) )  || (contains(lineSegment.otherPoint, tolerance: tolerance) && !isOnEdge(lineSegment.otherPoint, tolerance: tolerance))
        }
        
        private func isOnEdge(_ point: GeodesicPoint, tolerance: Double) -> Bool {
            // Exception: If it's on a line, we're done.
            for polygon in polygons {
                for segment in polygon.geoJsonLinearRings {
                    if segment.contains(point, tolerance: tolerance) {
                        return true
                    }
                }
            }
            
            return false
        }
        
        private func hasIntersection(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
            if Calculator.distance(from: lineSegment, to: otherLineSegment, tolerance: tolerance) == 0 {
                //segments touching is valid for MultiPolygon
                return !isTouching(lineSegment, with: otherLineSegment, tolerance: tolerance)
            }
            
            return false
        }
        
        private func isTouching(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
            if Calculator.contains(lineSegment.point, in: otherLineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.otherPoint, in: otherLineSegment, tolerance: tolerance) { return true }
            if !Calculator.contains(lineSegment.point, in: otherLineSegment, tolerance: tolerance) && Calculator.contains(lineSegment.otherPoint, in: otherLineSegment, tolerance: tolerance) { return true }
            if Calculator.contains(otherLineSegment.point, in: lineSegment, tolerance: tolerance) && !Calculator.contains(otherLineSegment.otherPoint, in: lineSegment, tolerance: tolerance) { return true }
            if !Calculator.contains(otherLineSegment.point, in: lineSegment, tolerance: tolerance) && Calculator.contains(otherLineSegment.otherPoint, in: lineSegment, tolerance: tolerance) { return true }
            
            return false
        }
    }
}
