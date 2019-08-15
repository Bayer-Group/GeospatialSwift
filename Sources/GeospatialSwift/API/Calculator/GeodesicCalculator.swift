import Foundation

// SOMEDAY: Altitude is not considered. Perhaps there should be 3D calculations as well.
// SOMEDAY: Break this up into pieces.
// swiftlint:disable file_length
public protocol GeodesicCalculatorProtocol {
    func area(of polygon: GeodesicPolygon) -> Double
    func length(of line: GeodesicLine) -> Double
    
    func centroid(polygon: GeodesicPolygon) -> GeodesicPoint
    func destinationPoint(origin: GeodesicPoint, bearing: Double, distance: Double) -> GeodesicPoint
    
    func haversineDistance(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    func lawOfCosinesDistance(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    
    func distance(from point: GeodesicPoint, to otherPoint: GeodesicPoint, tolerance: Double) -> Double
    func distance(from point: GeodesicPoint, to lineSegment: GeodesicLineSegment, tolerance: Double) -> Double
    func distance(from lineSegment: GeodesicLineSegment, to otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Double
    func distance(from point: GeodesicPoint, to line: GeodesicLine, tolerance: Double) -> Double
    func distance(from point: GeodesicPoint, to polygon: GeodesicPolygon, tolerance: Double) -> Double
    func edgeDistance(from point: GeodesicPoint, to polygon: GeodesicPolygon, tolerance: Double) -> Double
    
    func equals(_ points: [GeodesicPoint], tolerance: Double) -> Bool
    func indices(ofPoints points: [GeodesicPoint], clusteredWithinTolarance tolerance: Double) -> [[Int]]
    
    func hasIntersection(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool
    func hasIntersection(_ lineSegment: GeodesicLineSegment, with polygon: GeodesicPolygon, tolerance: Double) -> Bool
    func hasIntersection(_ line: GeodesicLine, tolerance: Double) -> Bool
    func hasIntersection(_ polygon: GeodesicPolygon, tolerance: Double) -> Bool
    
    func intersectionPoint(of lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment) -> GeodesicPoint?
    
    func contains(_ point: GeodesicPoint, in lineSegment: GeodesicLineSegment, tolerance: Double) -> Bool
    func contains(_ point: GeodesicPoint, in line: GeodesicLine, tolerance: Double) -> Bool
    func contains(_ point: GeodesicPoint, in polygon: GeodesicPolygon, tolerance: Double) -> Bool
    
    // SOMEDAY: Overlaps / Contains(Fully)? (Line to Line, Line in Multi/Polygon, Polygon in Multi/Polygon)
    //    func contains(_ lineSegment: GeodesicLineSegment, in polygon: GeodesicPolygon, tolerance: Double) -> Bool
    // SOMEDAY: Split Lines
    //    func canSplit(_ polygon: GeodesicPolygon, from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Bool
    //    func split(_ polygon: GeodesicPolygon, from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> (GeodesicPolygon, GeodesicPolygon)
    
    func midpoint(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> GeodesicPoint
    
    func initialBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    func averageBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    func finalBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    
    func normalize(longitude: Double) -> Double
    func normalize(latitude: Double) -> Double
    func normalize(_ point: GeodesicPoint) -> GeodesicPoint
    func normalizePositive(longitude: Double) -> Double
    func normalizePositive(latitude: Double) -> Double
    func normalizePositive(_ point: GeodesicPoint) -> GeodesicPoint
    
    func simpleViolationSelfIntersectionIndices(from line: GeoJsonLineString, tolerance: Double) -> [Int: [Int]]
    func simpleViolationIntersectionIndices(from lines: [GeoJsonLineString], tolerance: Double) -> [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]]
    func simpleViolationIntersectionIndices(from polygon: GeoJsonPolygon, tolerance: Double) -> [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]]
    func simpleViolationNegativeRingPointsOutsideMainRingIndices(from polygon: GeoJsonPolygon, tolerance: Double) -> [LineIndexBySegmentIndexByPointIndex]
    func simpleViolationNegativeRingInsideAnotherNegativeRingIndices(from polygon: GeoJsonPolygon, tolerance: Double) -> [Int]
    func simpleViolationMultipleVertexIntersectionIndices(from polygon: GeoJsonPolygon, tolerance: Double) -> [LineIndexBySegmentIndex: [LineIndexBySegmentIndexByPointIndex]]
    func simpleViolationIntersectionIndices(from multiPolygon: GeoJsonMultiPolygon, tolerance: Double) -> [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]]
    func simpleViolationPolygonPointsContainedInAnotherPolygonIndices(from multiPolygon: GeoJsonMultiPolygon, tolerance: Double) -> [Int]
}

internal let Calculator = GeodesicCalculator.shared

/**
 All calculation input and output is based in meters. Geospatial input and output is expected in longitude/latitude and degrees.
 */
public struct GeodesicCalculator: GeodesicCalculatorProtocol {
    internal static let shared: GeodesicCalculatorProtocol = GeodesicCalculator()
    
    private init() { }
    
    // Guess at the radius of the earth based on latitude
    private let earthRadiusEquator: Double = 6378137
    private let earthRadiusPole: Double = 6356752
    //√ [ (r1² * cos(B))² + (r2² * sin(B))² ] / [ (r1 * cos(B))² + (r2 * sin(B))² ]
    private func earthRadius(latitudeAverage: Double) -> Double {
        let part1 = (pow(pow(earthRadiusEquator, 2) * cos(latitudeAverage), 2) + pow(pow(earthRadiusPole, 2) * sin(latitudeAverage), 2))
        let part2 = (pow(earthRadiusEquator * cos(latitudeAverage), 2) + pow(earthRadiusPole * sin(latitudeAverage), 2))
        return sqrt(part1 / part2)
    }
    
    public func midpoint(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> GeodesicPoint {
        let point = point.degreesToRadians
        let otherPoint = otherPoint.degreesToRadians
        
        let φ1 = point.latitude
        let λ1 = point.longitude
        let φ2 = otherPoint.latitude
        let λ2 = otherPoint.longitude
        
        let Bx = cos(φ2) * cos(λ2 - λ1)
        let By = cos(φ2) * sin(λ2 - λ1)
        let φ3 = atan2(sin(point.latitude) + sin(φ2), sqrt((cos(point.latitude) + Bx) * (cos(point.latitude) + Bx) + By * By))
        let λ3 = λ1 + atan2(By, cos(φ1) + Bx)
        
        let altitude = point.altitude != nil && otherPoint.altitude != nil ? (point.altitude! + otherPoint.altitude!) / 2 : nil
        
        return SimplePoint(longitude: λ3.radiansToDegrees, latitude: φ3.radiansToDegrees, altitude: altitude)
    }
    
    public func bearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        let point = point.degreesToRadians
        let otherPoint = otherPoint.degreesToRadians
        
        let φ1 = point.latitude
        let φ2 = otherPoint.latitude
        let Δλ = otherPoint.longitude - point.longitude
        
        return atan2(sin(Δλ) * cos(φ2), cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)).radiansToDegrees
    }
    
    public func initialBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        return (bearing(from: point, to: otherPoint) + 360).truncatingRemainder(dividingBy: 360)
    }
    
    public func averageBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        return initialBearing(from: midpoint(from: point, to: otherPoint), to: otherPoint)
    }
    
    public func finalBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        return (bearing(from: otherPoint, to: point) + 180).truncatingRemainder(dividingBy: 360)
    }
}

// MARK: Measurement Functions

// SOMEDAY: Area calculations are not geodesic?
extension GeodesicCalculator {
    public func length(of line: GeodesicLine) -> Double {
        return line.segments.reduce(0.0) { $0 + distance(from: $1.startPoint, to: $1.endPoint, tolerance: 0) }
    }
    
    public func area(of polygon: GeodesicPolygon) -> Double {
        let earthRadius = self.earthRadius(latitudeAverage: centroid(polygon: polygon).latitude)
        
        let mainRingArea = area(of: polygon.mainRing.points, earthRadius: earthRadius)
        
        guard polygon.negativeRings.count > 0 else { return mainRingArea }
        
        return mainRingArea - polygon.negativeRings.map { $0.points }.reduce(0.0) {
            return $0 + area(of: $1, earthRadius: earthRadius)
        }
    }
    
    private func area(of linearRingPoints: [GeodesicPoint], earthRadius: Double) -> Double {
        let points = linearRingPoints.map { $0.degreesToRadians }
        
        var area = 0.0
        
        for index in 0 ..< points.count {
            let point = points[index > 0 ? index - 1 : points.count - 1]
            let otherPoint = points[index]
            
            area += (otherPoint.longitude - point.longitude) * (2 + sin(point.latitude) + sin(otherPoint.latitude))
        }
        
        area = -(area * earthRadius * earthRadius / 2)
        
        // In order not to worry about is polygon clockwise or counterclockwise defined.
        return max(area, -area)
    }
}

// MARK: Normalize Functions

extension GeodesicCalculator {
    public func normalize(longitude: Double) -> Double {
        return normalizeCoordinate(value: longitude, shift: 360.0)
    }
    
    public func normalize(latitude: Double) -> Double {
        return normalizeCoordinate(value: latitude, shift: 180.0)
    }
    
    public func normalizePositive(longitude: Double) -> Double {
        let normalizedLongitude = normalize(longitude: longitude)
        
        return normalizedLongitude < 0 ? normalizedLongitude + 360 : normalizedLongitude
    }
    
    public func normalizePositive(latitude: Double) -> Double {
        let normalizedLatitude = normalize(latitude: latitude)
        
        return normalizedLatitude < 0 ? normalizedLatitude + 180 : normalizedLatitude
    }
    
    public func normalize(_ point: GeodesicPoint) -> GeodesicPoint {
        return SimplePoint(longitude: normalize(longitude: point.longitude), latitude: normalize(latitude: point.latitude), altitude: point.altitude)
    }
    
    public func normalizePositive(_ point: GeodesicPoint) -> GeodesicPoint {
        return SimplePoint(longitude: normalizePositive(longitude: point.longitude), latitude: normalizePositive(latitude: point.latitude), altitude: point.altitude)
    }
    
    // A normalized value (longitude or latitude) is greater than the minimum and less than or equal to the maximum yet geospatially equal to the original.
    private func normalizeCoordinate(value: Double, shift: Double) -> Double {
        let shiftedValue = value.truncatingRemainder(dividingBy: shift)
        
        return shiftedValue > shift / 2 ? shiftedValue - shift : shiftedValue <= -shift / 2 ? shiftedValue + shift : shiftedValue
    }
}

// MARK: Distance Functions

extension GeodesicCalculator {
    // The default distance formula
    public func distance(from point: GeodesicPoint, to otherPoint: GeodesicPoint, tolerance: Double) -> Double {
        return max(haversineDistance(from: point, to: otherPoint) - tolerance, 0.0)
    }
    
    public func distance(from point: GeodesicPoint, to lineSegment: GeodesicLineSegment, tolerance: Double) -> Double {
        let distance1 = distancePartialResult(from: point, to: lineSegment)
        let reverseSegment = LineSegment(startPoint: lineSegment.endPoint, endPoint: lineSegment.startPoint)
        let distance2 = distancePartialResult(from: point, to: reverseSegment)
        
        return max(min(distance1, distance2) - tolerance, 0.0)
    }
    
    public func distance(from lineSegment: GeodesicLineSegment, to otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Double {
        guard intersectionPoint(of: lineSegment, with: otherLineSegment) == nil else { return 0 }
        
        return min(
            distance(from: lineSegment.startPoint, to: otherLineSegment, tolerance: tolerance),
            distance(from: lineSegment.endPoint, to: otherLineSegment, tolerance: tolerance),
            distance(from: otherLineSegment.startPoint, to: lineSegment, tolerance: tolerance),
            distance(from: otherLineSegment.endPoint, to: lineSegment, tolerance: tolerance)
        )
    }
    
    public func distance(from point: GeodesicPoint, to line: GeodesicLine, tolerance: Double) -> Double {
        var smallestDistance = Double.greatestFiniteMagnitude
        
        for lineSegment in line.segments {
            let distance = self.distance(from: point, to: lineSegment, tolerance: tolerance)
            
            guard distance > 0 else { return 0 }
            
            smallestDistance = min(smallestDistance, distance)
        }
        
        return smallestDistance
    }
    
    public func distance(from point: GeodesicPoint, to polygon: GeodesicPolygon, tolerance: Double) -> Double {
        if contains(point, in: polygon, tolerance: tolerance) { return 0 }
        
        return edgeDistance(from: point, to: polygon, tolerance: tolerance)
    }
    
    public func edgeDistance(from point: GeodesicPoint, to polygon: GeodesicPolygon, tolerance: Double) -> Double {
        return polygon.linearRings.map { distance(from: point, to: $0, tolerance: tolerance) }.min()!
    }
    
    // Law Of Cosines is not accurate under 0.5 meters.
    public func lawOfCosinesDistance(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        let earthRadius = self.earthRadius(latitudeAverage: (point.latitude + otherPoint.latitude) / 2)
        
        let point = point.degreesToRadians
        let otherPoint = otherPoint.degreesToRadians
        
        let φ1 = point.latitude
        let φ2 = otherPoint.latitude
        let Δλ = otherPoint.longitude - point.longitude
        
        let partialCalculation = sin(φ1) * sin(φ2) + cos(φ1) * cos(φ2) * cos(Δλ)
        // acos can produce NaN if not protected.
        let angularDistance = partialCalculation > 1 || partialCalculation < -1 ? 0 : acos(partialCalculation)
        
        return angularDistance * earthRadius
    }
    
    // Haversine distance is accurate under 0.5 meters
    public func haversineDistance(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        let earthRadius = self.earthRadius(latitudeAverage: (point.latitude + otherPoint.latitude) / 2)
        
        let point = point.degreesToRadians
        let otherPoint = otherPoint.degreesToRadians
        
        let dLat = otherPoint.latitude - point.latitude
        let dLon = otherPoint.longitude - point.longitude
        let partialCalculation1 = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(point.latitude) * cos(otherPoint.latitude)
        
        let partialCalculation2 = sqrt(partialCalculation1)
        // asin can produce NaN if not protected.
        let angularDistance = partialCalculation2 > 1 || partialCalculation2 < -1 ? 0 : 2 * asin(partialCalculation2)
        
        return angularDistance * earthRadius
    }
    
    // SOMEDAY: It would be nice to understand this better as there seems to be too much to calling this twice but twice produces the correct result.
    private func distancePartialResult(from point: GeodesicPoint, to lineSegment: GeodesicLineSegment) -> Double {
        let earthRadius = self.earthRadius(latitudeAverage: midpoint(from: lineSegment.startPoint, to: lineSegment.endPoint).latitude)
        
        let θ12 = initialBearing(from: lineSegment.startPoint, to: lineSegment.endPoint).degreesToRadians
        let θ13 = initialBearing(from: lineSegment.startPoint, to: point).degreesToRadians
        let δ13 = distance(from: lineSegment.startPoint, to: point, tolerance: 0)
        
        guard abs(θ13 - θ12) <= .pi / 2.0 else { return δ13 }
        
        let δxt: Double = {
            let partialCalculation = sin(δ13 / earthRadius) * sin(θ13 - θ12)
            
            return partialCalculation > 1 || partialCalculation < -1 ? 0 : asin(partialCalculation) * earthRadius
        }()
        
        let δ12 = distance(from: lineSegment.startPoint, to: lineSegment.endPoint, tolerance: 0)
        
        let δ14: Double = {
            let partialCalculation = cos(δ13 / earthRadius) / cos(δxt / earthRadius)
            
            return partialCalculation > 1 || partialCalculation < -1 ? 0 : acos(partialCalculation) * earthRadius
        }()
        
        guard δ14 > δ12 else { return abs(δxt) }
        
        let δ23 = distance(from: lineSegment.endPoint, to: point, tolerance: 0)
        
        return δ23
    }
}

// MARK: Contains

extension GeodesicCalculator {
    public func contains(_ point: GeodesicPoint, in otherPoint: GeodesicPoint, tolerance: Double) -> Bool {
        return distance(from: point, to: otherPoint, tolerance: tolerance) == 0
    }
    
    public func contains(_ point: GeodesicPoint, in lineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
        return distance(from: point, to: lineSegment, tolerance: tolerance) == 0
    }
    
    public func contains(_ point: GeodesicPoint, in line: GeodesicLine, tolerance: Double) -> Bool {
        return distance(from: point, to: line, tolerance: tolerance) == 0
    }
    
    public func contains(_ point: GeodesicPoint, in polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        // Must at least be within the bounding box.
        // guard polygon.boundingBox.contains(point: point, tolerance: tolerance) else { return false }
        
        // If it's on a line, we're done.
        if (polygon.linearRings.map { contains(point, in: $0, tolerance: tolerance) }.first { $0 == true } ?? false) { return true }
        
        let mainRingContains = contains(point: point, vertices: polygon.mainRing.points)
        // Skip running hole contains calculations if mainRingContains is false
        let holeContains: () -> (Bool) = {
            return polygon.negativeRings.map { $0.points }.first { self.contains(point: point, vertices: $0) } != nil
        }
        
        let baseContains = mainRingContains && !holeContains()
        
        if tolerance < 0 && baseContains { return edgeDistance(from: point, to: polygon, tolerance: 0) >= -tolerance }
        
        if tolerance > 0 { return baseContains || edgeDistance(from: point, to: polygon, tolerance: 0) <= tolerance }
        
        return baseContains
    }
    
    // SOMEDAY: Not geodesic.
    private func contains(point: GeodesicPoint, vertices: [GeodesicPoint]) -> Bool {
        guard !vertices.isEmpty else { return false }
        
        var contains = false
        var previousVertex = vertices.last!
        
        //shot a ray from point to right, parallel to latitude line
        //After hitting a segment, the ray goes inside out or outside in
        //If ray starts outside: out=>in=>...=>out
        //If inside: in=>out=>in...=>out
        //Thus, even number of hits: outside
        //Odd number of hits: inside
        for vertex in vertices {
            guard vertex != point else {
                return true
            }
            
            //point.latitude is in [vertex.latitude, previousVertex.latitude], so ray will intersect segment
            let partial1 = (vertex.latitude > point.latitude) != (previousVertex.latitude > point.latitude)
            //intersection with segment
            //If segment is to the left of the point, the ray will go around the earth and hit the segment. Bad hit
            //If segment is to the right, it will be a good hit
            let partial2 = (previousVertex.longitude - vertex.longitude) * (point.latitude - vertex.latitude) / (previousVertex.latitude - vertex.latitude) + vertex.longitude
            //The intersection is to the right of point
            let partial3 = point.longitude < partial2
            
            //Hit once
            if partial1 && partial3 { contains = !contains }
            
            previousVertex = vertex
        }
        
        return contains
    }
}

// MARK: Intersection

extension GeodesicCalculator {
    public func equals(_ points: [GeodesicPoint], tolerance: Double) -> Bool {
        return points.enumerated().contains { currentIndex, currentPoint in
            points.enumerated().contains { nextIndex, nextPoint in
                guard currentIndex < nextIndex else { return false }
                
                return distance(from: currentPoint, to: nextPoint, tolerance: tolerance) == 0
            }
        }
    }
    
    public func hasIntersection(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
        return distance(from: lineSegment, to: otherLineSegment, tolerance: tolerance) == 0
    }
    
    public func hasIntersection(_ lineSegment: GeodesicLineSegment, with polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        let polygonIntersects = polygon.linearRings.map { $0.segments }.contains {
            $0.contains { hasIntersection($0, with: lineSegment, tolerance: tolerance) }
        }
        
        return polygonIntersects || contains(lineSegment.startPoint, in: polygon, tolerance: tolerance)
    }
    
    public func hasIntersection(_ line: GeodesicLine, tolerance: Double) -> Bool {
        return line.segments.enumerated().contains { currentLineIndex, currentLineSegment in
            line.segments.enumerated().contains { nextLineIndex, nextLineSegment in
                guard currentLineIndex < nextLineIndex else { return false }
                
                // If next line continues from previous ensure no overlapping
                if currentLineIndex == nextLineIndex - 1 && currentLineSegment.endPoint == nextLineSegment.startPoint {
                    return contains(nextLineSegment.endPoint, in: currentLineSegment, tolerance: tolerance)
                }
                
                return hasIntersection(currentLineSegment, with: nextLineSegment, tolerance: tolerance)
            }
        }
    }
    
    public func hasIntersection(_ polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        return polygon.linearRings.contains { hasIntersection($0, tolerance: tolerance) }
    }
    
    public func indices(ofPoints points: [GeodesicPoint], clusteredWithinTolarance tolerance: Double) -> [[Int]] {
        var uniquePoints = [GeodesicPoint]()
        var duplicateIndices = [[Int]]()
        
        points.enumerated().forEach { pointIndex, point in
            var isUnique = true
            for index in (0..<uniquePoints.count) {
                if distance(from: point, to: uniquePoints[index], tolerance: tolerance) == 0 {
                    duplicateIndices[index].append(pointIndex)
                    isUnique = false
                    break
                }
            }
            if isUnique {
                uniquePoints.append(point)
                duplicateIndices.append([pointIndex])
            }
        }
        
        return duplicateIndices.filter { $0.count > 1 }
    }
    
    public func simpleViolationSelfIntersectionIndices(from line: GeoJsonLineString, tolerance: Double) -> [Int: [Int]] {
        func adjacentSegmentsOverlap(currentSegment: GeodesicLineSegment, nextSegment: GeodesicLineSegment) -> Bool {
            return contains(currentSegment.startPoint, in: nextSegment, tolerance: tolerance) || contains(nextSegment.endPoint, in: currentSegment, tolerance: tolerance)
        }

        var allIntersectionIndices = [Int: [Int]]()
        let lastSegmentIndex = line.segments.count - 1
        //Compare current segment to each of the segments from next to last segment
        line.segments.enumerated().forEach { currentIndex, currentSegment in
            let nextSegmentIndex = currentIndex + 1
            guard let nextSegment = line.segments.at(nextSegmentIndex) else { return }
            
            //Comparison of current segment and next segment is a special case
            //They always share a point, which cause intersection. As long as they don't overlap, they are good
            if adjacentSegmentsOverlap(currentSegment: currentSegment, nextSegment: nextSegment) {
                allIntersectionIndices[currentIndex] = [nextSegmentIndex]
            }
            
            let remainingSegmentsEnumerated = Array(line.segments.enumerated().drop { $0.offset <= nextSegmentIndex })
            guard !remainingSegmentsEnumerated.isEmpty else { return }
            
            //Compare to the remaining segments
            remainingSegmentsEnumerated.forEach { remainingIndex, remainingSegment in
                if hasIntersection(currentSegment, with: remainingSegment, tolerance: tolerance) &&
                    //An exception is that first segment is allowed to share a point with last segment
                    !(currentIndex == 0 && remainingIndex == lastSegmentIndex && currentSegment.startPoint == remainingSegment.endPoint && !adjacentSegmentsOverlap(currentSegment: remainingSegment, nextSegment: currentSegment)) {
                    allIntersectionIndices[currentIndex] = (allIntersectionIndices[currentIndex] ?? []) + [remainingIndex]
                }
            }
        }
        
        return allIntersectionIndices
    }
    
    public func simpleViolationIntersectionIndices(from lines: [GeoJsonLineString], tolerance: Double) -> [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]] {
        var allIntersectionIndices = [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]]()
        lines.enumerated().forEach { currentLineIndex, currentLine in
            //Compare current LineString to each of the Linestring from next to last
            let remainingLinesEnumerated = Array(lines.enumerated().drop { $0.offset <= currentLineIndex })
            
            remainingLinesEnumerated.forEach { remainingLineIndex, remainingLine in
                
                currentLine.segments.enumerated().forEach { currentSegmentIndex, currentSegment in
                    let currentLineSegmentIndex = LineIndexBySegmentIndex(lineIndex: currentLineIndex, segmentIndex: currentSegmentIndex)
                    
                    remainingLine.segments.enumerated().forEach { remainingSegmentIndex, remainingSegment in
                        let remainingLineSegmentIndex = LineIndexBySegmentIndex(lineIndex: remainingLineIndex, segmentIndex: remainingSegmentIndex)
                        
                        if hasIntersection(currentSegment, with: remainingSegment, tolerance: tolerance) {
                            if overlapping(segment: currentSegment, segmentOther: remainingSegment, tolerance: tolerance) {
                                allIntersectionIndices[currentLineSegmentIndex] = allIntersectionIndices[currentLineSegmentIndex] ?? [] + [remainingLineSegmentIndex]
                                return
                            }
                            
                            //CurrentLine start and end is allowed to be shared with remainingLine start and end
                            let currentIsLineStartPoint = currentSegmentIndex == 0
                            let remainingIsLineStartPoint = remainingSegmentIndex == 0
                            let currentIsLineEndPoint = currentSegmentIndex == currentLine.segments.count - 1
                            let remainingIsLineEndPoint = remainingSegmentIndex == remainingLine.segments.count - 1
                            
                            if currentIsLineStartPoint, remainingIsLineStartPoint, currentSegment.startPoint == remainingSegment.startPoint {
                                return
                            }
                            
                            if currentIsLineStartPoint, remainingIsLineEndPoint, currentSegment.startPoint == remainingSegment.endPoint {
                                return
                            }
                            
                            if currentIsLineEndPoint, remainingIsLineStartPoint, currentSegment.endPoint == remainingSegment.startPoint {
                                return
                            }
                            
                            if currentIsLineEndPoint, remainingIsLineEndPoint, currentSegment.endPoint == remainingSegment.endPoint {
                                return
                            }
                            
                            allIntersectionIndices[currentLineSegmentIndex] = (allIntersectionIndices[currentLineSegmentIndex] ?? []) + [remainingLineSegmentIndex]
                        }
                    }
                }
            }
        }
        
        return allIntersectionIndices
    }
    
    public func simpleViolationNegativeRingPointsOutsideMainRingIndices(from polygon: GeoJsonPolygon, tolerance: Double) -> [LineIndexBySegmentIndexByPointIndex] {
        let mainRing = polygon.mainRing
        var outsideSegmentIndices = [LineIndexBySegmentIndexByPointIndex]()
        polygon.negativeRings.enumerated().forEach { negativeRingIndex, negativeRing in
            negativeRing.segments.enumerated().forEach { negativeSegmentIndex, negativeSegment in
                #warning("Vernon wrote a contains func that doesn't work")
                if !contains(point: negativeSegment.startPoint, vertices: mainRing.points)  {
                    outsideSegmentIndices.append(LineIndexBySegmentIndexByPointIndex(lineIndex: negativeRingIndex, segmentIndex: negativeSegmentIndex, pointIndex: .startPoint))
                }
                if !contains(point: negativeSegment.endPoint, vertices: mainRing.points) {
                    outsideSegmentIndices.append(LineIndexBySegmentIndexByPointIndex(lineIndex: negativeRingIndex, segmentIndex: negativeSegmentIndex, pointIndex: .endPoint))
                }
            }
        }
        
        return outsideSegmentIndices
    }
    
    private func isOnEdge(point: GeodesicPoint, polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        let distanceToEdge = polygon.mainRing.segments.map { distance(from: point, to: $0, tolerance: tolerance) }
        
        return distanceToEdge.contains(0)
    }
    
    #warning("have a better name")
    //Ring intersecting and crossing another Ring
    public func simpleViolationIntersectionIndices(from polygon: GeoJsonPolygon, tolerance: Double) -> [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]] {
        var allIntersectionIndices = [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]]()
        polygon.linearRings.enumerated().forEach { currentRingIndex, currentRing in
            //Compare current ring to each of the ring from next to last
            let remainingRingsEnumerated = Array(polygon.linearRings.enumerated().drop { $0.offset <= currentRingIndex })
            
            remainingRingsEnumerated.forEach { remainingRingIndex, remainingRing in
                
                currentRing.segments.enumerated().forEach { currentSegmentIndex, currentSegment in
                    let currentSegmentIndex = LineIndexBySegmentIndex(lineIndex: currentRingIndex, segmentIndex: currentSegmentIndex)
                    
                    remainingRing.segments.enumerated().forEach { remainingSegmentIndex, remainingSegment in
                        let remainingSegmentIndex = LineIndexBySegmentIndex(lineIndex: remainingRingIndex, segmentIndex: remainingSegmentIndex)

                        if overlapping(segment: currentSegment, segmentOther: remainingSegment, tolerance: tolerance) {
                            allIntersectionIndices[currentSegmentIndex] = (allIntersectionIndices[currentSegmentIndex] ?? []) + [remainingSegmentIndex]
                            return
                        }
                        
                        if hasIntersection(currentSegment, with: remainingSegment, tolerance: tolerance) {
                            //Intersecting and crossing
                            if  !contains(currentSegment.startPoint, in: remainingSegment, tolerance: tolerance) &&
                                !contains(currentSegment.endPoint, in: remainingSegment, tolerance: tolerance) &&
                                !contains(remainingSegment.startPoint, in: currentSegment, tolerance: tolerance) &&
                                !contains(remainingSegment.endPoint, in: currentSegment, tolerance: tolerance) {
                                allIntersectionIndices[currentSegmentIndex] = (allIntersectionIndices[currentSegmentIndex] ?? []) + [remainingSegmentIndex]
                            }
                        }
                    }
                }
            }
        }
        
        return allIntersectionIndices
    }

    #warning("This func by itself is not right")
    public func simpleViolationMultipleVertexIntersectionIndices(from polygon: GeoJsonPolygon, tolerance: Double) -> [LineIndexBySegmentIndex: [LineIndexBySegmentIndexByPointIndex]] {
        var allIntersectionIndices = [LineIndexBySegmentIndex: [LineIndexBySegmentIndexByPointIndex]]()
        polygon.linearRings.enumerated().forEach { currentRingIndex, currentRing in
            //Compare current ring to each of the ring from next to last
            let remainingRingsEnumerated = polygon.linearRings.enumerated().filter { $0.offset != currentRingIndex }
            
            remainingRingsEnumerated.forEach { remainingRingIndex, remainingRing in
                var intersectionPoints = [GeodesicPoint]()
                currentRing.segments.enumerated().forEach { currentSegmentIndex, currentSegment in
                    let currentSegmentIndex = LineIndexBySegmentIndex(lineIndex: currentRingIndex, segmentIndex: currentSegmentIndex)
                    
                    remainingRing.segments.enumerated().forEach { remainingSegmentIndex, remainingSegment in
                        //We have checked intersection and cross already, and will terminate if there is any
                        //so we can assume that any intersection here is vertex intersection.
                        if hasIntersection(currentSegment, with: remainingSegment, tolerance: tolerance) {
                            //Vertex Intersection
                            if contains(remainingSegment.startPoint, in: currentSegment, tolerance: tolerance) {
                                let remainingPointIndex = LineIndexBySegmentIndexByPointIndex(lineIndex: remainingRingIndex, segmentIndex: remainingSegmentIndex, pointIndex: .startPoint)
                                allIntersectionIndices[currentSegmentIndex] = (allIntersectionIndices[currentSegmentIndex] ?? []) + [remainingPointIndex]
                                if !contains(point: remainingSegment.startPoint, in: intersectionPoints, tolerance: tolerance) {
                                    intersectionPoints.append(remainingSegment.startPoint)
                                }
                            } else {
                                let remainingPointIndex = LineIndexBySegmentIndexByPointIndex(lineIndex: remainingRingIndex, segmentIndex: remainingSegmentIndex, pointIndex: .endPoint)
                                allIntersectionIndices[currentSegmentIndex] = (allIntersectionIndices[currentSegmentIndex] ?? []) + [remainingPointIndex]
                                if !contains(point: remainingSegment.endPoint, in: intersectionPoints, tolerance: tolerance) {
                                    intersectionPoints.append(remainingSegment.endPoint)
                                }
                            }
                        }
                    }
                }
                
                if intersectionPoints.count < 2 {
                    allIntersectionIndices.forEach { lineIndexBySegmentIndex, _ in
                        if lineIndexBySegmentIndex.lineIndex == currentRingIndex {
                            allIntersectionIndices[lineIndexBySegmentIndex] = nil
                        }
                    }
                }
                
            }
        }
        
        return allIntersectionIndices
    }
    
    private func contains(point: GeodesicPoint, in points: [GeodesicPoint], tolerance: Double) -> Bool {
        for pointMember in points {
            if contains(point, in: pointMember, tolerance: tolerance) { return true }
        }
        
        return false
    }
    
    public func simpleViolationNegativeRingInsideAnotherNegativeRingIndices(from polygon: GeoJsonPolygon, tolerance: Double) -> [Int] {
        let negativeRing = polygon.negativeRings
        
        var containedRingIndices = [Int]()
        negativeRing.enumerated().forEach { ringIndex, ring in
            let remainingNegativeRingsEnumerated = negativeRing.enumerated().filter { $0.offset != ringIndex }
            remainingNegativeRingsEnumerated.forEach { remainingRingIndex, remainingRing in
                //all point in remainingRing is contained in ring
                let remainingRingPointsAreContained = remainingRing.points.map { contains(point: $0, vertices: ring.points) }
                if !remainingRingPointsAreContained.contains(false) {
                    containedRingIndices.append(remainingRingIndex)
                }
            }
        }
        
        return containedRingIndices
    }
    
    public func simpleViolationPolygonPointsContainedInAnotherPolygonIndices(from multiPolygon: GeoJsonMultiPolygon, tolerance: Double) -> [Int] {
        var containedRingIndices = [Int]()
        multiPolygon.polygons.enumerated().forEach { currentPolygonIndex, currentPolygon in
            let currentMainRing = currentPolygon.mainRing
            
            let remainingPolygonEnumerated = multiPolygon.polygons.enumerated().filter { $0.offset != currentPolygonIndex }
            remainingPolygonEnumerated.forEach { remainingPolygonIndex, remainingPolygon in
                let remainingMainRing = remainingPolygon.mainRing
                let remainingMainRingPointsAreContained = remainingMainRing.points.map { contains(point: $0, vertices: currentMainRing.points) && !isOnEdge(point: $0, polygon: currentPolygon, tolerance: tolerance) }
                if remainingMainRingPointsAreContained.contains(true) {
                    containedRingIndices.append(remainingPolygonIndex)
                }
            }
        }
        
        return containedRingIndices
    }
    
    public func simpleViolationIntersectionIndices(from multiPolygon: GeoJsonMultiPolygon, tolerance: Double) -> [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]] {
        var allIntersectionIndices = [LineIndexBySegmentIndex: [LineIndexBySegmentIndex]]()
        multiPolygon.polygons.enumerated().forEach { currentPolygonIndex, currentPolygon in
            let currentMainRing = currentPolygon.mainRing
            
            let remainingPolygonEnumerated = Array(multiPolygon.polygons.enumerated().drop(while: { $0.offset <= currentPolygonIndex }))
            remainingPolygonEnumerated.forEach { remainingPolygonIndex, remainingPolygon in
                let remainingMainRing = remainingPolygon.mainRing
                
                currentMainRing.segments.enumerated().forEach { currentSegmentIndex, currentSegment in
                    let currentSegmentIndex = LineIndexBySegmentIndex(lineIndex: currentPolygonIndex, segmentIndex: currentSegmentIndex)
                    
                    remainingMainRing.segments.enumerated().forEach { remainingSegmentIndex, remainingSegment in
                        let remainingSegmentIndex = LineIndexBySegmentIndex(lineIndex: remainingPolygonIndex, segmentIndex: remainingSegmentIndex)
                        //2 rings can intersect at a tangent point but never cross.
                        //A second intersection is not allowed.
                        if overlapping(segment: currentSegment, segmentOther: remainingSegment, tolerance: tolerance) {
                            allIntersectionIndices[currentSegmentIndex] = (allIntersectionIndices[currentSegmentIndex] ?? []) + [remainingSegmentIndex]
                            return
                        }
                        
                        if hasIntersection(currentSegment, with: remainingSegment, tolerance: tolerance) {
                            //If the segments are not crossing each other, there is no violation
                            if !(contains(currentSegment.startPoint, in: remainingSegment, tolerance: tolerance) ||
                                contains(currentSegment.endPoint, in: remainingSegment, tolerance: tolerance) ||
                                contains(remainingSegment.startPoint, in: currentSegment, tolerance: tolerance) ||
                                contains(remainingSegment.endPoint, in: currentSegment, tolerance: tolerance)) {
                                allIntersectionIndices[currentSegmentIndex] = (allIntersectionIndices[currentSegmentIndex] ?? []) + [remainingSegmentIndex]
                            }
                        }
                    }
                }
            }
        }
        
        return allIntersectionIndices
    }
    
    // Overlapping returns true only if the lines are overlapping more than a single point.
    private func overlapping(segment: GeodesicLineSegment, segmentOther: GeodesicLineSegment, tolerance: Double) -> Bool {
        //segment inside segmentOther
        if contains(segment.startPoint, in: segmentOther, tolerance: tolerance)
            && contains(segment.endPoint, in: segmentOther, tolerance: tolerance) {
            return true
        }
        
        //segmentOther inside segment
        if contains(segmentOther.startPoint, in: segment, tolerance: tolerance)
            && contains(segmentOther.endPoint, in: segment, tolerance: tolerance) {
            return true
        }
        
        //sharing point
        if contains(segment.startPoint, in: segmentOther.startPoint, tolerance: tolerance)
            && !contains(segment.endPoint, in: segmentOther, tolerance: tolerance)
            && !contains(segmentOther.endPoint, in: segment, tolerance: tolerance) {
            return false
        }
        
        if contains(segment.startPoint, in: segmentOther.endPoint, tolerance: tolerance)
            && !contains(segment.endPoint, in: segmentOther, tolerance: tolerance)
            && !contains(segmentOther.startPoint, in: segment, tolerance: tolerance) {
            return false
        }
        
        if contains(segment.endPoint, in: segmentOther.startPoint, tolerance: tolerance)
            && !contains(segment.startPoint, in: segmentOther, tolerance: tolerance)
            && !contains(segmentOther.endPoint, in: segment, tolerance: tolerance) {
            return false
        }
        
        if contains(segment.endPoint, in: segmentOther.endPoint, tolerance: tolerance)
            && !contains(segment.startPoint, in: segmentOther, tolerance: tolerance)
            && !contains(segmentOther.startPoint, in: segment, tolerance: tolerance) {
            return false
        }
        
        //part of segment is inside segmentOther, and part of segmentOther is inside segment
        if contains(segment.startPoint, in: segmentOther, tolerance: tolerance) {
            if contains(segmentOther.startPoint, in: segment, tolerance: tolerance) {
                return true
            }
            if contains(segmentOther.endPoint, in: segment, tolerance: tolerance) {
                return true
            }
        }
        if contains(segment.endPoint, in: segmentOther, tolerance: tolerance) {
            if contains(segmentOther.startPoint, in: segment, tolerance: tolerance) {
                return true
            }
            if contains(segmentOther.endPoint, in: segment, tolerance: tolerance) {
                return true
            }
        }
        
        return false
    }
    
    // Does not return a point if overlaping the path OR if they simply only share a point
    public func intersectionPoint(of lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment) -> GeodesicPoint? {
        let longitudeDeltaSegment2 = otherLineSegment.endPoint.longitude - otherLineSegment.startPoint.longitude
        let latitudeDeltaSegment2 = otherLineSegment.endPoint.latitude - otherLineSegment.startPoint.latitude
        let longitudeDeltaSegment1 = lineSegment.endPoint.longitude - lineSegment.startPoint.longitude
        let latitudeDeltaSegment1 = lineSegment.endPoint.latitude - lineSegment.startPoint.latitude
        let longitudeSegmentsOffset = lineSegment.startPoint.longitude - otherLineSegment.startPoint.longitude
        let latitudeSegmentsOffset = lineSegment.startPoint.latitude - otherLineSegment.startPoint.latitude
        
        let denominator = (latitudeDeltaSegment2 * longitudeDeltaSegment1) - (longitudeDeltaSegment2 * latitudeDeltaSegment1)
        let numerator1 = (longitudeDeltaSegment2 * latitudeSegmentsOffset) - (latitudeDeltaSegment2 * longitudeSegmentsOffset)
        let numerator2 = (longitudeDeltaSegment1 * latitudeSegmentsOffset) - (latitudeDeltaSegment1 * longitudeSegmentsOffset)
        
        guard denominator != 0 && (numerator1 != 0 || numerator2 != 0) else {
            Log.debug("denominator: \(denominator), numerator1: \(numerator1), numerator2: \(numerator2)")
            return nil
        }
        
        let result1 = numerator1 / denominator
        let result2 = numerator2 / denominator
        
        guard case 0...1 = result1, case 0...1 = result2 else {
            return nil
        }
        
        let resultLongitude = lineSegment.startPoint.longitude + (result1 * longitudeDeltaSegment1)
        let resultLatitude = lineSegment.startPoint.latitude + (result1 * latitudeDeltaSegment1)
        
        return SimplePoint(longitude: resultLongitude, latitude: resultLatitude)
    }
}

// MARK: Centroid Functions

extension GeodesicCalculator {
    public func centroid(polygon: GeodesicPolygon) -> GeodesicPoint {
        var finalCentroid = centroid(linearRing: polygon.mainRing)
        
        let earthRadius = self.earthRadius(latitudeAverage: finalCentroid.latitude)
        
        // TODO: Easier way to get points for a line.
        // SOMEDAY: Multiple negative rings might be producing a bad result
        let mainRingArea = area(of: polygon.mainRing.points, earthRadius: earthRadius)
        
        polygon.negativeRings.forEach { negativeRing in
            let negativeCentroid = centroid(linearRing: negativeRing)
            let negativeArea = area(of: negativeRing.points, earthRadius: earthRadius)
            
            let distanceToShiftCentroid = distance(from: finalCentroid, to: negativeCentroid, tolerance: 0) * 2 * negativeArea / mainRingArea
            let bearing = initialBearing(from: negativeCentroid, to: finalCentroid)
            
            finalCentroid = destinationPoint(origin: finalCentroid, bearing: bearing, distance: distanceToShiftCentroid)
        }
        
        return finalCentroid
    }
    
    public func destinationPoint(origin: GeodesicPoint, bearing: Double, distance: Double) -> GeodesicPoint {
        let earthRadius = self.earthRadius(latitudeAverage: origin.latitude)
        
        let bearing = bearing.degreesToRadians
        let latitude1 = origin.latitude.degreesToRadians
        let longitude1 = origin.longitude.degreesToRadians
        let centralAngle = distance / earthRadius
        
        let partialCalculation = sin(latitude1) * cos(centralAngle) + cos(latitude1) * sin(centralAngle) * cos(bearing)
        let latitude2 = partialCalculation > 1 || partialCalculation < -1 ? 0 : asin(partialCalculation)
        
        let longitude2 = longitude1 + atan2(sin(bearing) * sin(centralAngle) * cos(latitude1), cos(centralAngle) - sin(latitude1) * sin(latitude2))
        
        let point = SimplePoint(longitude: longitude2.radiansToDegrees, latitude: latitude2.radiansToDegrees, altitude: origin.altitude)
        
        return point
    }
    
    // SOMEDAY: Not geodesic. Estimation.
    private func centroid(linearRing: GeodesicLine) -> GeodesicPoint {
        var sumY = 0.0
        var sumX = 0.0
        var partialSum = 0.0
        var sum = 0.0
        
        let offset = linearRing.points.first!
        let offsetLongitude = offset.longitude * (offset.longitude < 0 ? -1 : 1)
        let offsetLatitude = offset.latitude * (offset.latitude < 0 ? -1 : 1)
        
        let offsetSegments = linearRing.segments.map { lineSegment in
            return (point: SimplePoint(longitude: lineSegment.startPoint.longitude - offsetLongitude, latitude: lineSegment.startPoint.latitude - offsetLatitude), otherPoint: SimplePoint(longitude: lineSegment.endPoint.longitude - offsetLongitude, latitude: lineSegment.endPoint.latitude - offsetLatitude))
        }
        
        offsetSegments.forEach { point, otherPoint in
            partialSum = point.longitude * otherPoint.latitude - otherPoint.longitude * point.latitude
            sum += partialSum
            sumX += (point.longitude + otherPoint.longitude) * partialSum
            sumY += (point.latitude + otherPoint.latitude) * partialSum
        }
        
        let area = 0.5 * sum
        
        return SimplePoint(longitude: sumX / 6 / area + offsetLongitude, latitude: sumY / 6 / area + offsetLatitude, altitude: offset.altitude)
    }
}

#warning("better name")
public struct LineIndexBySegmentIndex: Hashable, Comparable {
    let lineIndex: Int
    let segmentIndex: Int
    
    public static func < (lhs: LineIndexBySegmentIndex, rhs: LineIndexBySegmentIndex) -> Bool {
        if lhs.lineIndex != rhs.lineIndex {
            return lhs.lineIndex < rhs.lineIndex
        } else {
            return lhs.segmentIndex < rhs.segmentIndex
        }
    }
}

public struct LineIndexBySegmentIndexByPointIndex: Hashable, Comparable {
    enum PointIndex {
        case startPoint
        case endPoint
    }
    
    let lineIndex: Int
    let segmentIndex: Int
    let pointIndex: PointIndex
    
    public static func < (lhs: LineIndexBySegmentIndexByPointIndex, rhs: LineIndexBySegmentIndexByPointIndex) -> Bool {
        if lhs.lineIndex != rhs.lineIndex {
            return lhs.lineIndex < rhs.lineIndex
        } else {
            return lhs.segmentIndex < rhs.segmentIndex
        }
    }
}
