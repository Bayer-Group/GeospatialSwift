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

            var simpleViolationGeometries = [GeoJsonCoordinatesGeometry]()
            (1..<lineStrings.count).forEach { index in
                (0..<index).forEach { indexOther in
                    let intersectionSegmentIndices = intersections(lineStrings[index], with: lineStrings[indexOther], tolerance: tolerance)
                    intersectionSegmentIndices.forEach { firstSegmentIndex, secondSegmentIndices in
                        
                        var point = Point(longitude: lineStrings[index].segments[firstSegmentIndex].startPoint.longitude, latitude: lineStrings[index].segments[firstSegmentIndex].startPoint.latitude)
                        var otherPoint = Point(longitude: lineStrings[index].segments[firstSegmentIndex].endPoint.longitude, latitude: lineStrings[index].segments[firstSegmentIndex].endPoint.latitude)
                        simpleViolationGeometries.append(point)
                        simpleViolationGeometries.append(otherPoint)
                        simpleViolationGeometries.append(LineString(coordinatesJson: [point.geoJsonCoordinates, otherPoint.geoJsonCoordinates])!)
                        
                        secondSegmentIndices.forEach {
                            point = Point(longitude: lineStrings[indexOther].segments[$0].startPoint.longitude, latitude: lineStrings[indexOther].segments[$0].startPoint.latitude)
                            otherPoint = Point(longitude: lineStrings[indexOther].segments[$0].endPoint.longitude, latitude: lineStrings[indexOther].segments[$0].endPoint.latitude)
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
                        if otherLineSegmentFirstSegment.startPoint == lineSegment.startPoint && !Calculator.contains(otherLineSegmentFirstSegment.endPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.endPoint, in: otherLineSegmentFirstSegment, tolerance: tolerance) {
                            //do nothing
                        } else if otherLineSegmentFirstSegment.startPoint == lineSegment.endPoint && !Calculator.contains(lineSegment.endPoint, in: otherLineSegmentFirstSegment, tolerance: tolerance) && !Calculator.contains(otherLineSegmentFirstSegment.startPoint, in: lineSegment, tolerance: tolerance) {
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
                        if otherLineSegmentLastSegment.endPoint == lineSegment.startPoint && !Calculator.contains(otherLineSegmentLastSegment.startPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.endPoint, in: otherLineSegmentLastSegment, tolerance: tolerance) {
                            //do nothing
                        } else if otherLineSegmentLastSegment.endPoint == lineSegment.endPoint && !Calculator.contains(lineSegment.startPoint, in: otherLineSegmentLastSegment, tolerance: tolerance) && !Calculator.contains(otherLineSegmentLastSegment.startPoint, in: lineSegment, tolerance: tolerance) {
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
                    if lineString.segments[0].startPoint == lineSegment.startPoint && !Calculator.contains(lineString.segments[0].endPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.endPoint, in: lineString.segments[0], tolerance: tolerance) {
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
                    if lineString.segments[lastIndex].endPoint == lineSegment.startPoint && !Calculator.contains(lineString.segments[lastIndex].startPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.endPoint, in: lineString.segments[lastIndex], tolerance: tolerance) {
                        //do nothing
                    } else {
                        indices.append(lastIndex)
                    }
                }
            } else {
                //only 1 segment
                if Calculator.distance(from: lineString.segments[0], to: lineSegment, tolerance: tolerance) == 0 {
                    //shares start point, not overlapping
                    if lineString.segments[0].startPoint == lineSegment.startPoint && !Calculator.contains(lineString.segments[0].endPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.endPoint, in: lineString.segments[0], tolerance: tolerance) {
                        //do nothing
                    } else if lineString.segments[0].endPoint == lineSegment.startPoint && !Calculator.contains(lineString.segments[0].endPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.endPoint, in: lineString.segments[0], tolerance: tolerance) {
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
                    if lineString.segments[0].startPoint == lineSegment.endPoint && !Calculator.contains(lineString.segments[0].endPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.startPoint, in: lineString.segments[0], tolerance: tolerance) {
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
                    if lineString.segments[lastIndex].endPoint == lineSegment.endPoint && !Calculator.contains(lineString.segments[lastIndex].startPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.startPoint, in: lineString.segments[lastIndex], tolerance: tolerance) {
                        //do nothing
                    } else {
                        indices.append(lastIndex)
                    }
                }
            } else {
                //When only 1 segment
                if Calculator.distance(from: lineString.segments[0], to: lineSegment, tolerance: tolerance) == 0 {
                    //segment start is lineSegment end, not overlapping
                    if lineString.segments[0].startPoint == lineSegment.endPoint && !Calculator.contains(lineString.segments[0].endPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.startPoint, in: lineString.segments[0], tolerance: tolerance) {
                        //do nothing
                    } else if lineString.segments[0].endPoint == lineSegment.endPoint && !Calculator.contains(lineString.segments[0].startPoint, in: lineSegment, tolerance: tolerance) && !Calculator.contains(lineSegment.startPoint, in: lineString.segments[0], tolerance: tolerance) {
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
                if lineSegment.startPoint == otherLineSegment.startPoint { return true }
                if lineSegment.startPoint == otherLineSegment.endPoint { return true }
                if lineSegment.endPoint == otherLineSegment.endPoint { return true }
                if lineSegment.endPoint == otherLineSegment.startPoint { return true }
            }
            return false
        }

    }
}
