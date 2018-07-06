@testable import GeospatialSwift

final class MockGeodesicCalculator: GeodesicCalculatorProtocol {
    private(set) var lineLengthCallCount = 0
    var lineLengthResult: Double = 0
    func length(lineSegments: [GeodesicLineSegment]) -> Double {
        lineLengthCallCount += 1
        
        return lineLengthResult
    }
    
    private(set) var polygonAreaCallCount = 0
    var polygonAreaResult: Double = 0
    func area(polygon: GeoJsonPolygon) -> Double {
        polygonAreaCallCount += 1
        
        return polygonAreaResult
    }
    
    func centroid(polygon: GeoJsonPolygon) -> GeodesicPoint {
        return polygon.linearRings.first!.points.first!
    }
    
    private(set) var distanceToLineCallCount = 0
    var distanceToLineResult: Double = 0
    func distance(point: GeodesicPoint, lineSegment: GeodesicLineSegment) -> Double {
        distanceToLineCallCount += 1
        
        return distanceToLineResult
    }
    
    private(set) var distanceToPointCallCount = 0
    var distanceToPointResult: Double = 0
    func distance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        distanceToPointCallCount += 1
        
        return distanceToPointResult
    }
    
    private(set) var containsCallCount = 0
    var containsResult: Bool = false
    func contains(point: GeodesicPoint, polygon: GeoJsonPolygon) -> Bool {
        containsCallCount += 1
        
        return containsResult
    }
    
    private(set) var midpointCallCount = 0
    func midpoint(point1: GeodesicPoint, point2: GeodesicPoint) -> GeodesicPoint {
        midpointCallCount += 1
        
        return point1
    }
    
    private(set) var normalizeCallCount = 0
    func normalize(point: GeodesicPoint) -> GeodesicPoint {
        normalizeCallCount += 1
        
        return point
    }
    
    private(set) var initialBearingCallCount = 0
    var initialBearingResult: Double = 0
    func initialBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        initialBearingCallCount += 1
        
        return initialBearingResult
    }
    
    private(set) var averageBearingCallCount = 0
    var averageBearingResult: Double = 0
    func averageBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        averageBearingCallCount += 1
        
        return averageBearingResult
    }
    
    private(set) var finalBearingCallCount = 0
    var finalBearingResult: Double = 0
    func finalBearing(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        finalBearingCallCount += 1
        
        return finalBearingResult
    }
    
    private(set) var lawOfCosinesDistanceCallCount = 0
    var lawOfCosinesDistanceResult: Double = 0
    func lawOfCosinesDistance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        lawOfCosinesDistanceCallCount += 1
        
        return lawOfCosinesDistanceResult
    }
    
    private(set) var haversineDistanceCallCount = 0
    var haversineDistanceResult: Double = 0
    func haversineDistance(point1: GeodesicPoint, point2: GeodesicPoint) -> Double {
        haversineDistanceCallCount += 1
        
        return haversineDistanceResult
    }
}
