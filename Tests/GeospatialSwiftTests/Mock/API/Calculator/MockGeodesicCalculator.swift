@testable import GeospatialSwift

final class MockGeodesicCalculator: GeodesicCalculatorProtocol {
    private(set) var lineLengthCallCount = 0
    private(set) var polygonAreaCallCount = 0
    private(set) var distanceToPointCallCount = 0
    private(set) var distanceToLineCallCount = 0
    private(set) var containsCallCount = 0
    private(set) var midpointCallCount = 0
    private(set) var initialBearingCallCount = 0
    private(set) var averageBearingCallCount = 0
    private(set) var finalBearingCallCount = 0
    private(set) var normalizeCallCount = 0
    private(set) var lawOfCosinesDistanceCallCount = 0
    private(set) var haversineDistanceCallCount = 0
    
    private(set) static var normalizeStaticCallCount = 0
    
    var lineLengthResult: Double = 0
    var polygonAreaResult: Double = 0
    var distanceToPointResult: Double = 0
    var distanceToLineResult: Double = 0
    var containsResult: Bool = false
    var bearingResult: Double = 0
    var lawOfCosinesDistanceResult: Double = 0
    var haversineDistanceResult: Double = 0
    
    init() {
        MockGeodesicCalculator.normalizeStaticCallCount = 0
    }
    
    func length(lineSegments: [GeoJsonLineSegment]) -> Double {
        lineLengthCallCount += 1
        
        return lineLengthResult
    }
    
    func area(polygonRings linearRings: [GeoJsonLineString]) -> Double {
        polygonAreaCallCount += 1
        
        return polygonAreaResult
    }
    
    func centroid(polygons: [GeoJsonPolygon]) -> GeodesicPoint {
        return polygons.first!.points.first!
    }
    
    func centroid(polygonRings: [GeoJsonLineString]) -> GeodesicPoint {
        return polygonRings.first!.points.first!
    }
    
    func centroid(linearRingSegments: [GeoJsonLineSegment]) -> GeodesicPoint {
        return linearRingSegments.first!.point1
    }
    
    func centroid(lines: [GeoJsonLineString]) -> GeodesicPoint {
        return lines.first!.points.first!
    }
    
    func centroid(linePoints: [GeodesicPoint]) -> GeodesicPoint {
        return linePoints.first!
    }
    
    func centroid(points: [GeodesicPoint]) -> GeodesicPoint {
        return points.first!
    }
    
    func distance(point: GeodesicPoint, lineSegment: GeoJsonLineSegment) -> Double {
        distanceToLineCallCount += 1
        
        return distanceToLineResult
    }
    
    func distance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        distanceToPointCallCount += 1
        
        return distanceToPointResult
    }
    
    func contains(point: GeodesicPoint, polygonRings: [GeoJsonLineString]) -> Bool {
        containsCallCount += 1
        
        return containsResult
    }
    
    func midpoint(point1: GeodesicPoint, point2: GeodesicPoint) -> GeodesicPoint {
        midpointCallCount += 1
        
        return point1
    }
    
    func normalize(point: GeodesicPoint) -> GeodesicPoint {
        normalizeCallCount += 1
        
        return point
    }
    
    func initialBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        initialBearingCallCount += 1
        
        return bearingResult
    }
    
    func averageBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        averageBearingCallCount += 1
        
        return bearingResult
    }
    
    func finalBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        finalBearingCallCount += 1
        
        return bearingResult
    }
    
    func lawOfCosinesDistance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        lawOfCosinesDistanceCallCount += 1
        
        return lawOfCosinesDistanceResult
    }
    
    func haversineDistance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        haversineDistanceCallCount += 1
        
        return haversineDistanceResult
    }
    
    static func normalize(point: GeodesicPoint) -> GeodesicPoint {
        normalizeStaticCallCount += 1
        
        return point
    }
}
