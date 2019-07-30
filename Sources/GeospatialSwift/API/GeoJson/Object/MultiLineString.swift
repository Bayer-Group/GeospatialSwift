public protocol GeoJsonMultiLineString: GeoJsonLinearGeometry {
    var lineStrings: [GeoJsonLineString] { get }
    
    func invalidReasons(tolerance: Double) -> [MultiLineStringInvalidReason]
}

public enum MultiLineStringInvalidReason {
    case lineStringInvalid(reasonByIndex: [Int: [LineStringInvalidReason]])
    case lineStringsIntersect(intersection: [LineStringsIntersection])
}

public struct LineStringsIntersection {
    let firstSegmentIndexPath: SegmentIndexPath
    let secondSegmentIndexPath: [SegmentIndexPath]
}

public struct SegmentIndexPath {
    let lineStringIndex: Int
    let segmentIndex: Int
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
                    reasons.append(.lineStringInvalid(reasonByIndex: [index: reason]))
                }
            }
            
            var lineStringsIntersections = [LineStringsIntersection]()
            (1..<lineStrings.count).forEach { index in
                (0..<index).forEach { indexOther in
                    let intersectionSegmentIndices = intersections(lineStrings[index], with: lineStrings[indexOther], tolerance: tolerance)
                    intersectionSegmentIndices.forEach { firstSegmentIndex, secondSegmentIndices in
                        lineStringsIntersections.append(LineStringsIntersection(firstSegmentIndexPath: SegmentIndexPath(lineStringIndex: index, segmentIndex: firstSegmentIndex), secondSegmentIndexPath: secondSegmentIndices.map { SegmentIndexPath(lineStringIndex: indexOther, segmentIndex: $0) }))
                    }
                }
            }
            if !lineStringsIntersections.isEmpty {
                reasons.append(.lineStringsIntersect(intersection: lineStringsIntersections))
            }
            return reasons
        }
        
        func intersections(_ lineString: GeoJsonLineString, with otherLineString: GeoJsonLineString, tolerance: Double) -> [Int: [Int]] {
            var intersectionSegmentIndices = [Int: [Int]]()
            
            if lineString.segments.count > 1 {
                let intersectionsStartPoint = intersectionsForStartPoint(otherLineString, with: lineString.segments[0], tolerance: tolerance)
                if !intersectionsStartPoint.isEmpty {
                    intersectionSegmentIndices[0] = intersectionsStartPoint
                }
                
                (1..<lineString.segments.count-1).forEach { index in
                    let indicesOther = intersections(otherLineString, with: lineString.segments[index], tolerance: tolerance)
                    if !indicesOther.isEmpty {
                        intersectionSegmentIndices[index] = indicesOther
                    }
                }
                
                let lastIndex = lineString.segments.count-1
                let intersectionsEndPoint = intersectionsForEndPoint(otherLineString, with: lineString.segments[lastIndex], tolerance: tolerance)
                if !intersectionsEndPoint.isEmpty {
                    intersectionSegmentIndices[lastIndex] = intersectionsEndPoint
                }
            } else {
                let intersectionsStartPoint = intersectionsForStartPoint(otherLineString, with: lineString.segments[0], tolerance: tolerance)
                if !intersectionsStartPoint.isEmpty {
                    intersectionSegmentIndices[0] = intersectionsStartPoint
                }
                
                let intersectionsEndPoint = intersectionsForEndPoint(otherLineString, with: lineString.segments[0], tolerance: tolerance)
                if !intersectionsEndPoint.isEmpty {
                    if intersectionSegmentIndices[0] == nil {
                        intersectionSegmentIndices[0] = intersectionsEndPoint
                    } else {
                        intersectionSegmentIndices[0]!.append(contentsOf: intersectionsEndPoint)
                    }
                }
            }
            
            return intersectionSegmentIndices
        }
        
        private func intersections(_ lineString: GeoJsonLineString, with lineSegment: GeodesicLineSegment, tolerance: Double) -> [Int] {
            var indices = [Int]()
            (0..<lineString.segments.count).forEach { index in
                if hasIntersection(lineString.segments[index], with: lineSegment, tolerance: tolerance) {
                    indices.append(index)
                }
            }
            
            return indices
        }
        
        //lineSegment is start point
        private func intersectionsForStartPoint(_ lineString: GeoJsonLineString, with lineSegment: GeodesicLineSegment, tolerance: Double) -> [Int] {
            var indices = [Int]()
            
            //first segment of lineString
            if Calculator.distance(from: lineString.segments[0], to: lineSegment, tolerance: tolerance) == 0 {
                //shares start point, not overlapping
                if lineString.segments[0].point == lineSegment.point && !Calculator.contains(lineString.segments[0].otherPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.otherPoint, in: lineString.segments[0], tolerance: tolerance) {
                    //do nothing
                } else {
                    indices.append(0)
                }
            }
            
            (1..<lineString.segments.count-1).forEach { index in
                if hasIntersection(lineString.segments[index], with: lineSegment, tolerance: tolerance) {
                    indices.append(index)
                }
            }
            
            let lastIndex = lineString.segments.count - 1
            //last segment of lineString
            if Calculator.distance(from: lineString.segments[lastIndex], to: lineSegment, tolerance: tolerance) == 0 {
                //last segment end is lineSegment start, not overlapping
                if lineString.segments[lastIndex].otherPoint == lineSegment.point && !Calculator.contains(lineString.segments[lastIndex].point, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.otherPoint, in: lineString.segments[lastIndex], tolerance: tolerance) {
                    //do nothing
                } else {
                    indices.append(lastIndex)
                }
            }
            
            return indices
        }
        
        //lineSegment is end point
        private func intersectionsForEndPoint(_ lineString: GeoJsonLineString, with lineSegment: GeodesicLineSegment, tolerance: Double) -> [Int] {
            var indices = [Int]()
            
            //first segment of lineString
            if Calculator.distance(from: lineString.segments[0], to: lineSegment, tolerance: tolerance) == 0 {
                //first segment start is lineSegment end, not overlapping
                if lineString.segments[0].point == lineSegment.otherPoint && !Calculator.contains(lineString.segments[0].otherPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.point, in: lineString.segments[0], tolerance: tolerance) {
                    //do nothing
                } else {
                    indices.append(0)
                }
            }
            
            (1..<lineString.segments.count-1).forEach { index in
                if hasIntersection(lineString.segments[index], with: lineSegment, tolerance: tolerance) {
                    indices.append(index)
                }
            }
            
            let lastIndex = lineString.segments.count - 1
            //last segment of lineString
            if Calculator.distance(from: lineString.segments[lastIndex], to: lineSegment, tolerance: tolerance) == 0 {
                //last segment end is lineSegment end, not overlapping
                if lineString.segments[lastIndex].otherPoint == lineSegment.otherPoint && !Calculator.contains(lineString.segments[lastIndex].point, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.point, in: lineString.segments[lastIndex], tolerance: tolerance) {
                    //do nothing
                } else {
                    indices.append(lastIndex)
                }
            }
            
            return indices
        }
        
        private func hasIntersection(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
            return Calculator.distance(from: lineSegment, to: otherLineSegment, tolerance: tolerance) == 0
        }

    }
}
