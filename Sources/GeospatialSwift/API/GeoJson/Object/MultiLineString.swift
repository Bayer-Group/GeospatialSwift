public protocol GeoJsonMultiLineString: GeoJsonLinearGeometry {
    var lineStrings: [GeoJsonLineString] { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
}

public enum MultiLineStringSimpleViolation {
    case lineStringInvalid(reasonByIndex: [Int: [LineStringSimpleViolation]])
    case lineStringsIntersect(intersection: [LineStringsIntersection])
}

public struct LineStringsIntersection {
    public let firstSegmentIndexPath: SegmentIndexPath
    public let secondSegmentIndexPath: [SegmentIndexPath]
}

public struct SegmentIndexPath {
    public let lineStringIndex: Int
    public let segmentIndex: Int
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

            var simpleViolationGeometries = [GeoJsonCoordinatesGeometry]()
            (1..<lineStrings.count).forEach { index in
                (0..<index).forEach { indexOther in
                    let intersectionSegmentIndices = intersections(lineStrings[index], with: lineStrings[indexOther], tolerance: tolerance)
                    intersectionSegmentIndices.forEach { firstSegmentIndex, secondSegmentIndices in
                        
                        var point = Point(longitude: lineStrings[index].segments[firstSegmentIndex].point.longitude, latitude: lineStrings[index].segments[firstSegmentIndex].point.latitude)
                        var otherPoint = Point(longitude: lineStrings[index].segments[firstSegmentIndex].otherPoint.longitude, latitude: lineStrings[index].segments[firstSegmentIndex].otherPoint.latitude)
                        simpleViolationGeometries.append(point)
                        simpleViolationGeometries.append(otherPoint)
                        simpleViolationGeometries.append(LineString(coordinatesJson: [point.geoJsonCoordinates, otherPoint.geoJsonCoordinates])!)
                        
                        secondSegmentIndices.forEach {
                            point = Point(longitude: lineStrings[indexOther].segments[$0].point.longitude, latitude: lineStrings[indexOther].segments[$0].point.latitude)
                            otherPoint = Point(longitude: lineStrings[indexOther].segments[$0].otherPoint.longitude, latitude: lineStrings[indexOther].segments[$0].otherPoint.latitude)
                            simpleViolationGeometries.append(point)
                            simpleViolationGeometries.append(otherPoint)
                            simpleViolationGeometries.append(LineString(coordinatesJson: [point.geoJsonCoordinates, otherPoint.geoJsonCoordinates])!)
                        }
                    }
                }
            }
            if !simpleViolationGeometries.isEmpty {
                violations.append(GeoJsonSimpleViolation(problems: simpleViolationGeometries, reason: .selfIntersection))
            }
            
            return violations
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
                //lineString having 1 segment is a corner case that is hard to deal with together with otherLineString having 1 segment
                //both lineString have 1 segment
                if otherLineString.segments.count == 1 {
                    if hasIntersection(lineString.segments[0], with: otherLineString.segments[0], tolerance: tolerance) {
                        if !isSharingPoint(lineString.segments[0], with: otherLineString.segments[0], tolerance: tolerance) {
                            intersectionSegmentIndices[0] = [0]
                        }
                    }
                } else {
                    var indices = [Int]()
                    
                    //first segment of otherLineString
                    let lineSegment = lineString.segments[0]
                    let otherLineSegmentFirstSegment = otherLineString.segments[0]
                    if hasIntersection(lineSegment, with: otherLineSegmentFirstSegment, tolerance: tolerance) {
                        //shares start point, not overlapping
                        if otherLineSegmentFirstSegment.point == lineSegment.point && !Calculator.contains(otherLineSegmentFirstSegment.otherPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.otherPoint, in: otherLineSegmentFirstSegment, tolerance: tolerance) {
                            //do nothing
                        } else if otherLineSegmentFirstSegment.point == lineSegment.otherPoint && !Calculator.contains(lineSegment.otherPoint, in: otherLineSegmentFirstSegment, tolerance: tolerance) && !Calculator.contains(otherLineSegmentFirstSegment.point, in: lineSegment, tolerance: tolerance) {
                            //do nothing
                        } else {
                            indices.append(0)
                        }
                    }
                    
                    (1..<otherLineString.segments.count - 1).forEach { index in
                        if hasIntersection(otherLineString.segments[index], with: lineSegment, tolerance: tolerance) {
                            indices.append(index)
                        }
                    }
                    
                    let lastIndex = otherLineString.segments.count - 1
                    let otherLineSegmentLastSegment = otherLineString.segments[lastIndex]
                    if hasIntersection(lineSegment, with: otherLineSegmentLastSegment, tolerance: tolerance) {
                        //shares start point, not overlapping
                        if otherLineSegmentLastSegment.otherPoint == lineSegment.point && !Calculator.contains(otherLineSegmentLastSegment.point, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.otherPoint, in: otherLineSegmentLastSegment, tolerance: tolerance) {
                            //do nothing
                        } else if otherLineSegmentLastSegment.otherPoint == lineSegment.otherPoint && !Calculator.contains(lineSegment.point, in: otherLineSegmentLastSegment, tolerance: tolerance) && !Calculator.contains(otherLineSegmentLastSegment.point, in: lineSegment, tolerance: tolerance) {
                            //do nothing
                        } else {
                            indices.append(lastIndex)
                        }
                    }
                    
                    if !indices.isEmpty {
                        return [0: indices]
                    } else {
                        return [:]
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
            
            if lineString.segments.count > 1 {
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
            } else {
                //only 1 segment
                if Calculator.distance(from: lineString.segments[0], to: lineSegment, tolerance: tolerance) == 0 {
                    //shares start point, not overlapping
                    if lineString.segments[0].point == lineSegment.point && !Calculator.contains(lineString.segments[0].otherPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.otherPoint, in: lineString.segments[0], tolerance: tolerance) {
                        //do nothing
                    } else if lineString.segments[0].otherPoint == lineSegment.point && !Calculator.contains(lineString.segments[0].otherPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.otherPoint, in: lineString.segments[0], tolerance: tolerance) {
                        //do nothing
                    } else {
                        indices.append(0)
                    }
                }
            }
            return indices
        }
        
        //lineSegment is end point
        private func intersectionsForEndPoint(_ lineString: GeoJsonLineString, with lineSegment: GeodesicLineSegment, tolerance: Double) -> [Int] {
            var indices = [Int]()
            
            if lineString.segments.count > 1 {
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
            } else {
                //When only 1 segment
                if Calculator.distance(from: lineString.segments[0], to: lineSegment, tolerance: tolerance) == 0 {
                    //segment start is lineSegment end, not overlapping
                    if lineString.segments[0].point == lineSegment.otherPoint && !Calculator.contains(lineString.segments[0].otherPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.point, in: lineString.segments[0], tolerance: tolerance) {
                        //do nothing
                    } else if lineString.segments[0].otherPoint == lineSegment.otherPoint && !Calculator.contains(lineString.segments[0].point, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.point, in: lineString.segments[0], tolerance: tolerance) {
                        //do nothing
                    } else {
                        indices.append(0)
                    }
                }
            }
            
            return indices
        }
        
        private func hasIntersection(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
            return Calculator.distance(from: lineSegment, to: otherLineSegment, tolerance: tolerance) == 0
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
