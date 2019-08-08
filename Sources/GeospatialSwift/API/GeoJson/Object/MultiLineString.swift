public protocol GeoJsonMultiLineString: GeoJsonLinearGeometry {
    var lineStrings: [GeoJsonLineString] { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
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
        
        public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
            var violations = [GeoJsonSimpleViolation]()
            
            lineStrings.enumerated().forEach { index, lineString in
                let violation = lineString.simpleViolations(tolerance: tolerance)
                if violation.count > 0 {
                    violations += violation
                }
            }
            
            guard violations.isEmpty else {
                return violations
            }
            
            let simpleViolationIntersectionIndices = Calculator.simpleViolationIntersectionIndices(from: lineStrings, tolerance: tolerance)
            
            guard simpleViolationIntersectionIndices.isEmpty else {
                simpleViolationIntersectionIndices.sorted(by: { $0.key < $1.key }).forEach { lineSegmentIndex1 in
                    let segment1 = lineStrings[lineSegmentIndex1.key.lineIndex].segments[lineSegmentIndex1.key.segementIndex]
                    let point1 = Point(longitude: segment1.startPoint.longitude, latitude: segment1.startPoint.latitude)
                    let point2 = Point(longitude: segment1.endPoint.longitude, latitude: segment1.endPoint.latitude)
                    let line1 = LineString(points: [point1, point2])!
                    
                    lineSegmentIndex1.value.forEach { lineSegmentIndex2 in
                        let segment2 = lineStrings[lineSegmentIndex2.lineIndex].segments[lineSegmentIndex2.segementIndex]
                        let point3 = Point(longitude: segment2.startPoint.longitude, latitude: segment2.startPoint.latitude)
                        let point4 = Point(longitude: segment2.endPoint.longitude, latitude: segment2.endPoint.latitude)
                        let line2 = LineString(points: [point3, point4])!
                        
                        violations += [GeoJsonSimpleViolation(problems: [point1, point2, line1, point3, point4, line2], reason: .multiLineIntersection)]
                    }
                }
                
                return violations
            }
            return []
        }
    }
}
