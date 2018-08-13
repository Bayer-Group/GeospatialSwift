import Foundation

// SOMEDAY: Altitude is not considered. Perhaps there should be 3D calculations as well.
// SOMEDAY: Break this up into pieces.
// swiftlint:disable file_length
public protocol GeodesicCalculatorProtocol {
    func area(of polygon: GeodesicPolygon) -> Double
    func length(of line: GeodesicLine) -> Double
    
    func centroid(polygon: GeodesicPolygon) -> GeodesicPoint
    
    func haversineDistance(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    func lawOfCosinesDistance(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    
    func distance(from point: GeodesicPoint, to otherPoint: GeodesicPoint, tolerance: Double) -> Double
    func distance(from point: GeodesicPoint, to lineSegment: GeodesicLineSegment, tolerance: Double) -> Double
    func distance(from lineSegment: GeodesicLineSegment, to otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Double
    func distance(from point: GeodesicPoint, to line: GeodesicLine, tolerance: Double) -> Double
    func distance(from point: GeodesicPoint, to polygon: GeodesicPolygon, tolerance: Double) -> Double
    func edgeDistance(from point: GeodesicPoint, to polygon: GeodesicPolygon, tolerance: Double) -> Double
    
    func equals(_ points: [GeodesicPoint], tolerance: Double) -> Bool
    func equalsIndices(_ points: [GeodesicPoint], tolerance: Double) -> [Int]
    
    func hasIntersection(_ lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Bool
    func hasIntersection(_ lineSegment: GeodesicLineSegment, with polygon: GeodesicPolygon, tolerance: Double) -> Bool
    func hasIntersection(_ line: GeodesicLine, tolerance: Double) -> Bool
    func hasIntersection(_ polygon: GeodesicPolygon, tolerance: Double) -> Bool
    
    func intersection(of lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment) -> GeodesicPoint?
    func intersectionIndices(from line: GeodesicLine, tolerance: Double) -> [Int]
    func intersectionIndices(from polygon: GeodesicPolygon, tolerance: Double) -> [[[Int]]]
    
    func contains(_ point: GeodesicPoint, in lineSegment: GeodesicLineSegment, tolerance: Double) -> Bool
    func contains(_ point: GeodesicPoint, in line: GeodesicLine, tolerance: Double) -> Bool
    func contains(_ point: GeodesicPoint, in polygon: GeodesicPolygon, tolerance: Double) -> Bool
    
    // SOMEDAY: Overlaps / Contains(Fully)? (Line to Line, Line in Multi/Polygon, Polygon in Multi/Polygon)
    
    func midpoint(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> GeodesicPoint
    
    func initialBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    func averageBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    func finalBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double
    
    func normalize(_ point: GeodesicPoint) -> GeodesicPoint
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
        return line.segments.reduce(0.0) { $0 + distance(from: $1.point, to: $1.otherPoint, tolerance: 0) }
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
    public func normalize(_ point: GeodesicPoint) -> GeodesicPoint {
        let normalizedLongitude = normalizeCoordinate(value: point.longitude, shift: 360.0)
        let normalizedLatitude = normalizeCoordinate(value: point.latitude, shift: 180.0)
        
        return SimplePoint(longitude: normalizedLongitude, latitude: normalizedLatitude, altitude: point.altitude)
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
        let reverseSegment = LineSegment(point: lineSegment.otherPoint, otherPoint: lineSegment.point)
        let distance2 = distancePartialResult(from: point, to: reverseSegment)
        
        return max(min(distance1, distance2) - tolerance, 0.0)
    }
    
    public func distance(from lineSegment: GeodesicLineSegment, to otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Double {
        guard intersection(of: lineSegment, with: otherLineSegment) == nil else { return 0 }
        
        return min(
            distance(from: lineSegment.point, to: otherLineSegment, tolerance: tolerance),
            distance(from: lineSegment.otherPoint, to: otherLineSegment, tolerance: tolerance),
            distance(from: otherLineSegment.point, to: lineSegment, tolerance: tolerance),
            distance(from: otherLineSegment.otherPoint, to: lineSegment, tolerance: tolerance)
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
        let earthRadius = self.earthRadius(latitudeAverage: midpoint(from: lineSegment.point, to: lineSegment.otherPoint).latitude)
        
        let θ12 = initialBearing(from: lineSegment.point, to: lineSegment.otherPoint).degreesToRadians
        let θ13 = initialBearing(from: lineSegment.point, to: point).degreesToRadians
        let δ13 = distance(from: lineSegment.point, to: point, tolerance: 0)
        
        guard abs(θ13 - θ12) <= .pi / 2.0 else { return δ13 }
        
        let δxt: Double = {
            let partialCalculation = sin(δ13 / earthRadius) * sin(θ13 - θ12)
            
            return partialCalculation > 1 || partialCalculation < -1 ? 0 : asin(partialCalculation) * earthRadius
        }()
        
        let δ12 = distance(from: lineSegment.point, to: lineSegment.otherPoint, tolerance: 0)
        
        let δ14: Double = {
            let partialCalculation = cos(δ13 / earthRadius) / cos(δxt / earthRadius)
            
            return partialCalculation > 1 || partialCalculation < -1 ? 0 : acos(partialCalculation) * earthRadius
        }()
        
        guard δ14 > δ12 else { return abs(δxt) }
        
        let δ23 = distance(from: lineSegment.otherPoint, to: point, tolerance: 0)
        
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
    
    // SOMEDAY: Negative Tolerance might be broken here.
    public func contains(_ point: GeodesicPoint, in polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        // Must at least be within the bounding box.
        //guard polygon.mainRing.boundingBox.contains(point: point, tolerance: tolerance) else { return 0 }
        
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
        
        vertices.forEach { vertex in
            let partial1 = (vertex.latitude > point.latitude) != (previousVertex.latitude > point.latitude)
            let partial2 = (previousVertex.longitude - vertex.longitude) * (point.latitude - vertex.latitude) / (previousVertex.latitude - vertex.latitude) + vertex.longitude
            let partial3 = point.longitude < partial2
            
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
    
    // SOMEDAY: Consider holes
    public func hasIntersection(_ lineSegment: GeodesicLineSegment, with polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        let polygonIntersects = polygon.linearRings.map { $0.segments }.contains {
            $0.contains { hasIntersection($0, with: lineSegment, tolerance: tolerance) }
        }
        
        return polygonIntersects || contains(lineSegment.point, in: polygon, tolerance: tolerance)
    }
    
    public func hasIntersection(_ line: GeodesicLine, tolerance: Double) -> Bool {
        return line.segments.enumerated().contains { currentLineIndex, currentLineSegment in
            line.segments.enumerated().contains { nextLineIndex, nextLineSegment in
                guard currentLineIndex < nextLineIndex else { return false }
                
                // If next line continues from previous ensure no overlapping
                if currentLineIndex == nextLineIndex - 1 && currentLineSegment.otherPoint == nextLineSegment.point {
                    return contains(nextLineSegment.otherPoint, in: currentLineSegment, tolerance: tolerance)
                }
                
                return hasIntersection(currentLineSegment, with: nextLineSegment, tolerance: tolerance)
            }
        }
    }
    
    public func hasIntersection(_ polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        return polygon.linearRings.contains { hasIntersection($0, tolerance: tolerance) }
    }
    
    public func equalsIndices(_ points: [GeodesicPoint], tolerance: Double) -> [Int] {
        return points.enumerated().filter { currentIndex, currentPoint in
            points.enumerated().contains { nextIndex, nextPoint in
                guard currentIndex < nextIndex else { return false }
                
                return distance(from: currentPoint, to: nextPoint, tolerance: tolerance) == 0
            }
            }.map { $0.offset }
    }
    
    // [Source Ring Index -> [Source Ring Segment Index -> [Compare Ring Intersecting Segement]]]
    public func intersectionIndices(from line: GeodesicLine, tolerance: Double) -> [Int] {
        return line.segments.enumerated().filter { currentLineIndex, currentLineSegment in
            line.segments.enumerated().contains { nextLineIndex, nextLineSegment in
                guard currentLineIndex < nextLineIndex else { return false }
                
                // If next line continues from previous ensure no overlapping
                if currentLineIndex == nextLineIndex - 1 && currentLineSegment.otherPoint == nextLineSegment.point {
                    return contains(nextLineSegment.otherPoint, in: currentLineSegment, tolerance: tolerance)
                }
                
                return hasIntersection(currentLineSegment, with: nextLineSegment, tolerance: tolerance)
            }
        }.map { $0.offset }
    }
    
    // SOMEDAY: Add this intersection rule
    // Polygon where hole intersects with same point as exterior edge point
    // [Source Ring Index -> [Source Ring Segment Index -> [Compare Ring Intersecting Segement]]]
    public func intersectionIndices(from polygon: GeodesicPolygon, tolerance: Double) -> [[[Int]]] {
        // TODO: Follow logic like func hasSelfIntersection(_ line: GeodesicLine, tolerance: Double) -> Bool instead?
        return polygon.linearRings.map { $0.segments }.map { ringSegments in
            return ringSegments.map { lineSegment in
                ringSegments.enumerated().filter {
                    intersection(of: $1, with: lineSegment) != nil
                }.map { $0.offset }
            }
        }
    }
    
    // Does not return a point if overlaping the path
    public func intersection(of lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment) -> GeodesicPoint? {
        let longitudeDeltaSegment2 = otherLineSegment.otherPoint.longitude - otherLineSegment.point.longitude
        let latitudeDeltaSegment2 = otherLineSegment.otherPoint.latitude - otherLineSegment.point.latitude
        let longitudeDeltaSegment1 = lineSegment.otherPoint.longitude - lineSegment.point.longitude
        let latitudeDeltaSegment1 = lineSegment.otherPoint.latitude - lineSegment.point.latitude
        let longitudeSegmentsOffset = lineSegment.point.longitude - otherLineSegment.point.longitude
        let latitudeSegmentsOffset = lineSegment.point.latitude - otherLineSegment.point.latitude
        
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
        
        let resultLongitude = lineSegment.point.longitude + (result1 * longitudeDeltaSegment1)
        let resultLatitude = lineSegment.point.latitude + (result1 * latitudeDeltaSegment1)
        
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
            return (point: SimplePoint(longitude: lineSegment.point.longitude - offsetLongitude, latitude: lineSegment.point.latitude - offsetLatitude), otherPoint: SimplePoint(longitude: lineSegment.otherPoint.longitude - offsetLongitude, latitude: lineSegment.otherPoint.latitude - offsetLatitude))
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
    
    private func destinationPoint(origin: GeodesicPoint, bearing: Double, distance: Double) -> GeodesicPoint {
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
}
