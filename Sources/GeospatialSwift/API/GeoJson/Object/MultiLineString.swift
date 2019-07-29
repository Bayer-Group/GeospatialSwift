public protocol GeoJsonMultiLineString: GeoJsonLinearGeometry {
    var lineStrings: [GeoJsonLineString] { get }
    
    func invalidReasons(tolerance: Double) -> [MultiLineStringInvalidReason]
}

public enum MultiLineStringInvalidReason {
    case lineStringInValid(reason: [Int: [LineStringInvalidReason]])
    case lineStringsIntersect(indices: [Int])
}

extension GeoJson {
    /**
     Creates a GeoJsonMultiLineString
     */
    public func multiLineString(lineStrings: [GeoJsonLineString]) -> GeoJsonMultiLineString? {
        return MultiLineString(lineStrings: lineStrings)
    }
    
    public struct MultiLineString: GeoJsonMultiLineString {
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
        
        public let lineStrings: [GeoJsonLineString]
        
        public var points: [GeodesicPoint] {
            return lineStrings.flatMap { $0.points }
        }
        
        public var boundingBox: GeodesicBoundingBox {
            return BoundingBox.best(lineStrings.map { $0.boundingBox })!
        }
        
        public var length: Double {
            return lineStrings.reduce(0) { $0 + $1.length }
        }
        
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
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double { return lineStrings.map { $0.distance(to: point, tolerance: tolerance) }.min()! }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { return lineStrings.first { $0.contains(point, tolerance: tolerance) } != nil }
        
        public func invalidReasons(tolerance: Double) -> [MultiLineStringInvalidReason] {
            var reasons = [MultiLineStringInvalidReason]()
            lineStrings.enumerated().forEach { index, lineString in
                let reason = lineString.invalidReasons(tolerance: tolerance)
                if reason.count > 0 {
                    reasons.append(.lineStringInValid(reason: [index: reason]))
                }
            }
            
            for index in 1..<lineStrings.count {
                for indexOther in 0..<index {
                    if hasIntersection(lineStrings[index], with: lineStrings[indexOther], tolerance: tolerance) {
                        reasons.append(.lineStringsIntersect(indices: [index, indexOther]))
                    }
                }
            }
            
            return reasons
        }
        
        func hasIntersection(_ lineString: GeoJsonLineString, with otherLineString: GeoJsonLineString, tolerance: Double) -> Bool {
            for segment in lineString.segments {
                if hasIntersection(otherLineString, with: segment, tolerance: tolerance) {
                    return true
                }
            }
            
            return false
        }
        
        private func hasIntersection(_ lineString: GeoJsonLineString, with lineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
            for segment in lineString.segments {
                if hasIntersection(segment, with: lineSegment, tolerance: tolerance) {
                    return true
                }
            }
            
            return false
        }
        
        private func hasIntersection(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
            if Calculator.distance(from: lineSegment, to: otherLineSegment, tolerance: tolerance) == 0 {
                //sharing points is valid for MultiPolygon
                return !isSharingPoint(lineSegment, with: otherLineSegment, tolerance: tolerance)
            }
            
            return false
        }
        
        private func isSharingPoint(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
            if lineSegment != otherLineSegment {
                if lineSegment.point == otherLineSegment.point { return true }
                if lineSegment.point == otherLineSegment.otherPoint { return true }
                if lineSegment.otherPoint == otherLineSegment.otherPoint { return true }
                if lineSegment.otherPoint == otherLineSegment.point { return true }
            }
            
            return false
        }
    }
}
