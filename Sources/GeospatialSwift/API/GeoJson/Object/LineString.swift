public enum LineStringSimpleViolation {
    case duplicates(indices: [Int])
    case selfIntersects(segmentIndices: [Int: [Int]])
}

public protocol GeoJsonLineString: GeoJsonLinearGeometry, GeodesicLine {
    var geoJsonPoints: [GeoJsonPoint] { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
}

extension GeoJson {
    /**
     Creates a GeoJsonLineString
     */
    public func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString? {
        return LineString(points: points)
    }
    
    public struct LineString: GeoJsonLineString {
        public let type: GeoJsonObjectType = .lineString
        public var geoJsonCoordinates: [Any] { return geoJsonPoints.map { $0.geoJsonCoordinates } }
        
        public var description: String {
            return """
            LineString: \(
            """
            (\n\(points.enumerated().map { "\($0 + 1) - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let points: [GeodesicPoint]
        public let geoJsonPoints: [GeoJsonPoint]
        
        public var boundingBox: GeodesicBoundingBox {
            return BoundingBox.best(geoJsonPoints.compactMap { $0.boundingBox })!
        }
        
        public var length: Double {
            return Calculator.length(of: self)
        }
        
        public let segments: [GeodesicLineSegment]
        
        internal init?(coordinatesJson: [Any]) {
            guard let pointsJson = coordinatesJson as? [[Any]] else { Log.warning("A valid LineString must have valid coordinates"); return nil }
            
            var points = [GeoJsonPoint]()
            for pointJson in pointsJson {
                if let point = Point(coordinatesJson: pointJson) {
                    points.append(point)
                } else {
                    Log.warning("Invalid Point in LineString"); return nil
                }
            }
            
            self.init(points: points)
        }
        
        internal init?(points: [GeoJsonPoint]) {
            guard points.count >= 2 else { Log.warning("A valid LineString must have at least two Points"); return nil }
            
            self.points = points
            self.geoJsonPoints = points
            
            segments = points.enumerated().compactMap { (offset, point) in
                if points.count == offset + 1 { return nil }
                
                return LineSegment(startPoint: point, endPoint: points[offset + 1])
            }
        }
        
        public func distance(to point: GeodesicPoint, tolerance: Double) -> Double {
            return Calculator.distance(from: point, to: self, tolerance: tolerance)
        }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
            return Calculator.contains(point, in: self, tolerance: tolerance)
        }
        
        public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] {
            //For polygons, each ring is a simple lineString, whose start = end
            //We drop last if last = first. If there is a pointMid = last = first, we lose the violation pointMid = last, but we still capture pointMid = first, which is at the same location.
            var pointsForDuplicateCheck = [GeodesicPoint]()
            
            if points[0] == points[points.count - 1] {
                pointsForDuplicateCheck = points.dropLast()
            } else {
                pointsForDuplicateCheck = points
            }
            
            let duplicatePoints = Calculator.indices(ofPoints: pointsForDuplicateCheck, clusteredWithinTolarance: tolerance).map { geoJsonPoints[$0[0]] }
            
            guard duplicatePoints.isEmpty else { return [GeoJsonSimpleViolation(problems: duplicatePoints, reason: .pointDuplication)] }
            
            let selfIntersectsIndices = Calculator.simpleViolationSelfIntersectionIndices(from: self)
            
            guard selfIntersectsIndices.isEmpty else {
                #warning("Need to remove all duplicates")
                var simpleViolationGeometries = [GeoJsonCoordinatesGeometry]()
                selfIntersectsIndices.forEach { firstIndex, secondIndices in
                    var point = Point(longitude: segments[firstIndex].startPoint.longitude, latitude: segments[firstIndex].startPoint.latitude)
                    var otherPoint = Point(longitude: segments[firstIndex].endPoint.longitude, latitude: segments[firstIndex].endPoint.latitude)
                    simpleViolationGeometries.append(point)
                    simpleViolationGeometries.append(otherPoint)
                    simpleViolationGeometries.append(LineString(points: [point, otherPoint])!)
                    
                    secondIndices.forEach {
                        point = Point(longitude: segments[$0].startPoint.longitude, latitude: segments[$0].startPoint.latitude)
                        otherPoint = Point(longitude: segments[$0].endPoint.longitude, latitude: segments[$0].endPoint.latitude)
                        simpleViolationGeometries.append(point)
                        simpleViolationGeometries.append(otherPoint)
                        simpleViolationGeometries.append(LineString(points: [point, otherPoint])!)
                    }
                }
                
                return [GeoJsonSimpleViolation(problems: simpleViolationGeometries, reason: .lineIntersection)]
            }
            
            return []
        }
    }
}
