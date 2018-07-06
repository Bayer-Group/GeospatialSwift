import Foundation

public protocol GeodesicCalculatorProtocol {
    func area(polygon: GeoJsonPolygon) -> Double
    func length(lineSegments: [GeodesicLineSegment]) -> Double
    
    func centroid(polygon: GeoJsonPolygon) -> GeodesicPoint
    
    func distance(point: GeodesicPoint, lineSegment: GeodesicLineSegment) -> Double
    func distance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double
    func lawOfCosinesDistance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double
    func haversineDistance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double
    
    func contains(point: GeodesicPoint, polygon: GeoJsonPolygon) -> Bool
    
    func midpoint(point1: GeodesicPoint, point2: GeodesicPoint) -> GeodesicPoint
    
    func initialBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double
    func averageBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double
    func finalBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double
    
    func normalize(point: GeodesicPoint) -> GeodesicPoint
}

internal let Calculator = GeodesicCalculator.shared

/**
 All calculation input and output is based in meters. Geospatial input and output is expected in longitude/latitude and degrees.
 */
public struct GeodesicCalculator: GeodesicCalculatorProtocol {
    internal static let shared: GeodesicCalculatorProtocol = GeodesicCalculator()
    
    // Guess at the radius of the earth based on latitude
    private let earthRadiusEquator: Double = 6378137
    private let earthRadiusPole: Double = 6356752
    //√ [ (r1² * cos(B))² + (r2² * sin(B))² ] / [ (r1 * cos(B))² + (r2 * sin(B))² ]
    private func earthRadius(latitudeAverage: Double) -> Double {
        let part1 = (pow(pow(earthRadiusEquator, 2) * cos(latitudeAverage), 2) + pow(pow(earthRadiusPole, 2) * sin(latitudeAverage), 2))
        let part2 = (pow(earthRadiusEquator * cos(latitudeAverage), 2) + pow(earthRadiusPole * sin(latitudeAverage), 2))
        return sqrt(part1 / part2)
    }
    
    public func midpoint(point1: GeodesicPoint, point2: GeodesicPoint) -> GeodesicPoint {
        let point1 = point1.degreesToRadians
        let point2 = point2.degreesToRadians
        
        let φ1 = point1.latitude
        let λ1 = point1.longitude
        let φ2 = point2.latitude
        let λ2 = point2.longitude
        
        let Bx = cos(φ2) * cos(λ2 - λ1)
        let By = cos(φ2) * sin(λ2 - λ1)
        let φ3 = atan2(sin(point1.latitude) + sin(φ2), sqrt((cos(point1.latitude) + Bx) * (cos(point1.latitude) + Bx) + By * By))
        let λ3 = λ1 + atan2(By, cos(φ1) + Bx)
        
        let altitude = point1.altitude != nil && point2.altitude != nil ? (point1.altitude! + point2.altitude!) / 2 : nil
        
        return SimplePoint(longitude: λ3.radiansToDegrees, latitude: φ3.radiansToDegrees, altitude: altitude)
    }
    
    public func bearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        let point1 = point1.degreesToRadians
        let point2 = point2.degreesToRadians
        
        let φ1 = point1.latitude
        let φ2 = point2.latitude
        let Δλ = point2.longitude - point1.longitude
        
        return atan2(sin(Δλ) * cos(φ2), cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)).radiansToDegrees
    }
    
    public func initialBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        return (bearing(point1: point1, point2: point2) + 360).truncatingRemainder(dividingBy: 360)
    }
    
    public func averageBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        return initialBearing(point1: midpoint(point1: point1, point2: point2), point2: point2)
    }
    
    public func finalBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        return (bearing(point1: point2, point2: point1) + 180).truncatingRemainder(dividingBy: 360)
    }
}

// MARK: Measurement Functions

extension GeodesicCalculator {
    public func length(lineSegments: [GeodesicLineSegment]) -> Double {
        return lineSegments.reduce(0.0) { $0 + distance(point1: $1.point1, point2: $1.point2) }
    }
    
    // TODO: Not geodesic?
    public func area(polygon: GeoJsonPolygon) -> Double {
        let earthRadius = self.earthRadius(latitudeAverage: centroid(polygon: polygon).latitude)
        
        let mainRing = polygon.linearRings.first!
        let mainRingArea = area(linearRingPoints: mainRing.points, earthRadius: earthRadius)
        
        guard let negativeRings = polygon.linearRings.tail else { return mainRingArea }
        
        return mainRingArea - negativeRings.reduce(0.0) { return $0 + area(linearRingPoints: $1.points, earthRadius: earthRadius) }
    }
    
    // TODO: Not geodesic?
    private func area(linearRingPoints: [GeodesicPoint], earthRadius: Double) -> Double {
        let points = linearRingPoints.map { $0.degreesToRadians }
        
        var area = 0.0
        
        for index in 0 ..< points.count {
            let point1 = points[index > 0 ? index - 1 : points.count - 1]
            let point2 = points[index]
            
            area += (point2.longitude - point1.longitude) * (2 + sin(point1.latitude) + sin(point2.latitude))
        }
        
        area = -(area * earthRadius * earthRadius / 2)
        
        // In order not to worry about is polygon clockwise or counterclockwise defined.
        return max(area, -area)
    }
}

// MARK: Normalize Functions

extension GeodesicCalculator {
    public func normalize(point: GeodesicPoint) -> GeodesicPoint {
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
    public func distance(point: GeodesicPoint, lineSegment: GeodesicLineSegment) -> Double {
        let distance1 = distancePartialResult(point: point, lineSegment: lineSegment)
        let distance2 = distancePartialResult(point: point, lineSegment: LineSegment(point1: lineSegment.point2, point2: lineSegment.point1))
        
        return min(distance1, distance2)
    }
    
    // The default dinstance formula
    public func distance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        return haversineDistance(point1: point1, point2: point2)
    }
    
    // Law Of Cosines is not accurate under 0.5 meters. Also, acos can produce NaN if not protected.
    public func lawOfCosinesDistance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        // TODO: Which is the more accurate algorithm? Apple versus the custom algorithm. Custom algorithm does not vary earth radius with latitude.
        //return point1.location.distance(from: point2.location)
        let earthRadius = self.earthRadius(latitudeAverage: (point1.latitude + point2.latitude) / 2)
        
        let point1 = point1.degreesToRadians
        let point2 = point2.degreesToRadians

        let φ1 = point1.latitude
        let φ2 = point2.latitude
        let Δλ = point2.longitude - point1.longitude
        
        let partialCalculation = sin(φ1) * sin(φ2) + cos(φ1) * cos(φ2) * cos(Δλ)
        let angularDistance = partialCalculation > 1 || partialCalculation < -1 ? 0 : acos(partialCalculation)

        return angularDistance * earthRadius
    }
    
    // Haversine distance is accurate under 0.5 meters
    public func haversineDistance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        // TODO: Which is the more accurate algorithm? Apple versus the custom algorithm. Custom algorithm does not vary earth radius with latitude.
        //return point1.location.distance(from: point2.location)
        let earthRadius = self.earthRadius(latitudeAverage: (point1.latitude + point2.latitude) / 2)
        
        let point1 = point1.degreesToRadians
        let point2 = point2.degreesToRadians
        
        let dLat = point2.latitude - point1.latitude
        let dLon = point2.longitude - point1.longitude
        let partialCalculation1 = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(point1.latitude) * cos(point2.latitude)
        
        let partialCalculation2 = sqrt(partialCalculation1)
        let angularDistance = partialCalculation2 > 1 || partialCalculation2 < -1 ? 0 : 2 * asin(partialCalculation2)
        
        return angularDistance * earthRadius
    }
    
    // TODO: It would be nice to understand this better as there seems to be too much to calling this twice.
    private func distancePartialResult(point: GeodesicPoint, lineSegment: GeodesicLineSegment) -> Double {
        let earthRadius = self.earthRadius(latitudeAverage: midpoint(point1: lineSegment.point1, point2: lineSegment.point2).latitude)
        
        let θ12 = initialBearing(point1: lineSegment.point1, point2: lineSegment.point2).degreesToRadians
        let θ13 = initialBearing(point1: lineSegment.point1, point2: point).degreesToRadians
        let δ13 = distance(point1: lineSegment.point1, point2: point)
        
        guard abs(θ13 - θ12) <= .pi / 2.0 else { return δ13 }
        
        let δxt: Double = {
            let partialCalculation = sin(δ13 / earthRadius) * sin(θ13 - θ12)
            
            return partialCalculation > 1 || partialCalculation < -1 ? 0 : asin(partialCalculation) * earthRadius
        }()
        
        let δ12 = distance(point1: lineSegment.point1, point2: lineSegment.point2)
        
        let δ14: Double = {
            let partialCalculation = cos(δ13 / earthRadius) / cos(δxt / earthRadius)
            
            return partialCalculation > 1 || partialCalculation < -1 ? 0 : acos(partialCalculation) * earthRadius
        }()
        
        guard δ14 > δ12 else { return abs(δxt) }
        
        let δ23 = distance(point1: lineSegment.point2, point2: point)
        
        return δ23
    }
}

// MARK: Contains

extension GeodesicCalculator {
    public func contains(point: GeodesicPoint, polygon: GeoJsonPolygon) -> Bool {
        guard polygon.linearRings.count > 0 else { return false }
        
        let mainRing = polygon.linearRings.first!
        
        // Must at least be within the bounding box.
        guard mainRing.boundingBox.contains(point: point) else { return false }
        
        // If it's on a line, we're done.
        if (polygon.linearRings.map { $0.contains(point) }.first { $0 == true } ?? false) { return true }
        
        let mainRingContains = contains(point: point, vertices: mainRing.points)
        // Skip running hole contains calculations if mainRingContains is false
        let holeContains: () -> (Bool) = {
            return polygon.linearRings.tail?.first { self.contains(point: point, vertices: $0.points) == true } != nil
        }
        
        return mainRingContains && !holeContains()
    }
    
    // TODO: Not geodesic.
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

// MARK: Centroid Functions

extension GeodesicCalculator {
    public func centroid(polygon: GeoJsonPolygon) -> GeodesicPoint {
        let mainRing = polygon.linearRings.first!
        var finalCentroid = centroid(linearRingSegments: mainRing.segments)
        
        let earthRadius = self.earthRadius(latitudeAverage: finalCentroid.latitude)
        
        // TODO: Negative Rings likely Broken
        if let negativeRings = polygon.linearRings.tail {
            let mainRingArea = area(linearRingPoints: mainRing.points, earthRadius: earthRadius)
            
            negativeRings.forEach { negativeRing in
                let negativeCentroid = centroid(linearRingSegments: negativeRing.segments)
                let negativeArea = area(linearRingPoints: negativeRing.points, earthRadius: earthRadius)
                
                let distanceToShiftCentroid = distance(point1: finalCentroid, point2: negativeCentroid) * 2 * negativeArea / mainRingArea
                let bearing = initialBearing(point1: negativeCentroid, point2: finalCentroid)
                
                finalCentroid = destinationPoint(origin: finalCentroid, bearing: bearing, distance: distanceToShiftCentroid)
            }
        }
        
        return finalCentroid
    }
    
    // TODO: Not geodesic. Estimation.
    private func centroid(linearRingSegments: [GeodesicLineSegment]) -> GeodesicPoint {
        var sumY = 0.0
        var sumX = 0.0
        var partialSum = 0.0
        var sum = 0.0
        
        let offset = linearRingSegments.first!.point1
        let offsetLongitude = offset.longitude * (offset.longitude < 0 ? -1 : 1)
        let offsetLatitude = offset.latitude * (offset.latitude < 0 ? -1 : 1)
        
        let offsetSegments = linearRingSegments.map { lineSegment in
            return (point1: SimplePoint(longitude: lineSegment.point1.longitude - offsetLongitude, latitude: lineSegment.point1.latitude - offsetLatitude),
                    point2: SimplePoint(longitude: lineSegment.point2.longitude - offsetLongitude, latitude: lineSegment.point2.latitude - offsetLatitude))
        }
        
        offsetSegments.forEach { point1, point2 in
            partialSum = point1.longitude * point2.latitude - point2.longitude * point1.latitude
            sum += partialSum
            sumX += (point1.longitude + point2.longitude) * partialSum
            sumY += (point1.latitude + point2.latitude) * partialSum
        }
        
        let area = 0.5 * sum
        
        // TODO: Altitude is just passed through for the first point right now.
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
        
        // TODO: Altitude is just passed through right now.
        let point = SimplePoint(longitude: longitude2.radiansToDegrees, latitude: latitude2.radiansToDegrees, altitude: origin.altitude)
        
        return point
    }
}
