@testable import GeospatialSwift

final class MockGeodesicCalculator: GeodesicCalculatorProtocol {
    private(set) var destinationPointCallCount = 0
    func destinationPoint(origin: GeodesicPoint, bearing: Double, distance: Double) -> GeodesicPoint {
        destinationPointCallCount += 1
        
        return origin
    }
    
    private(set) var equalsCallCount = 0
    var equalsResult: Bool = false
    func equals(_ points: [GeodesicPoint], tolerance: Double) -> Bool {
        equalsCallCount += 1
        
        return equalsResult
    }
    
    private(set) var equalsIndicesCallCount = 0
    var equalsIndicesResult: [Int] = []
    func equalsIndices(_ points: [GeodesicPoint], tolerance: Double) -> [Int] {
        equalsIndicesCallCount += 1
        
        return equalsIndicesResult
    }
    
    private(set) var hasIntersectionLineCallCount = 0
    var hasIntersectionLineResult: Bool = false
    func hasIntersection(_ lineSegment1: GeodesicLineSegment, with lineSegment2: GeodesicLineSegment, tolerance: Double) -> Bool {
        hasIntersectionLineCallCount += 1
        
        return hasIntersectionLineResult
    }
    
    private(set) var hasIntersectionPolygonCallCount = 0
    var hasIntersectionPolygonResult: Bool = false
    func hasIntersection(_ lineSegment: GeodesicLineSegment, with polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        hasIntersectionPolygonCallCount += 1
        
        return hasIntersectionPolygonResult
    }
    
    private(set) var hasSelfIntersectionLineCallCount = 0
    var hasSelfIntersectionLineResult: Bool = false
    func hasIntersection(_ line: GeodesicLine, tolerance: Double) -> Bool {
        hasSelfIntersectionLineCallCount += 1
        
        return hasSelfIntersectionLineResult
    }
    
    private(set) var hasSelfIntersectionPolygonCallCount = 0
    var hasSelfIntersectionPolygonResult: Bool = false
    func hasIntersection(_ polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        hasSelfIntersectionPolygonCallCount += 1
        
        return hasSelfIntersectionPolygonResult
    }
    
    private(set) var intersectionLineCallCount = 0
    var intersectionLineResult: GeodesicPoint?
    func intersection(of lineSegment: GeodesicLineSegment, with otherLineSegment: GeodesicLineSegment) -> GeodesicPoint? {
        intersectionLineCallCount += 1
        
        return intersectionLineResult
    }
    
    private(set) var intersectionIndicesLineCallCount = 0
    var intersectionIndicesLineResult: [Int] = []
    func intersectionIndices(from line: GeodesicLine, tolerance: Double) -> [Int] {
        intersectionIndicesLineCallCount += 1
        
        return intersectionIndicesLineResult
    }
    
    private(set) var intersectionIndicesPolygonCallCount = 0
    var intersectionIndicesPolygonResult: [[[Int]]] = []
    func intersectionIndices(from polygon: GeodesicPolygon, tolerance: Double) -> [[[Int]]] {
        intersectionIndicesPolygonCallCount += 1
        
        return intersectionIndicesPolygonResult
    }
    
    private(set) var lineLengthCallCount = 0
    var lineLengthResult: Double = 0
    func length(of line: GeodesicLine) -> Double {
        lineLengthCallCount += 1
        
        return lineLengthResult
    }
    
    private(set) var polygonAreaCallCount = 0
    var polygonAreaResult: Double = 0
    func area(of polygon: GeodesicPolygon) -> Double {
        polygonAreaCallCount += 1
        
        return polygonAreaResult
    }
    
    func centroid(polygon: GeodesicPolygon) -> GeodesicPoint {
        return polygon.points.first!
    }
    
    private(set) var distanceToPointCallCount = 0
    var distanceToPointResult: Double = 0
    func distance(from point: GeodesicPoint, to otherPoint: GeodesicPoint, tolerance: Double) -> Double {
        distanceToPointCallCount += 1
        
        return distanceToPointResult
    }
    
    private(set) var distanceToLineCallCount = 0
    var distanceToLineResult: Double = 0
    func distance(from point: GeodesicPoint, to lineSegment: GeodesicLineSegment, tolerance: Double) -> Double {
        distanceToLineCallCount += 1
        
        return distanceToLineResult
    }
    
    private(set) var distanceToLinesCallCount = 0
    var distanceToLinesResult: Double = 0
    func distance(from point: GeodesicPoint, to line: GeodesicLine, tolerance: Double) -> Double {
        distanceToLinesCallCount += 1
        
        return distanceToLinesResult
    }
    
    private(set) var distanceToPolygonCallCount = 0
    var distanceToPolygoResult: Double = 0
    func distance(from point: GeodesicPoint, to polygon: GeodesicPolygon, tolerance: Double) -> Double {
        distanceToPolygonCallCount += 1
        
        return distanceToPolygoResult
    }
    
    private(set) var edgeDistanceToPolygonCallCount = 0
    var edgeDistanceToPolygoResult: Double = 0
    func edgeDistance(from point: GeodesicPoint, to polygon: GeodesicPolygon, tolerance: Double) -> Double {
        edgeDistanceToPolygonCallCount += 1
        
        return edgeDistanceToPolygoResult
    }
    
    private(set) var distanceFromLineToLineCallCount = 0
    var distanceFromLineToLineResult: Double = 0
    func distance(from lineSegment: GeodesicLineSegment, to otherLineSegment: GeodesicLineSegment, tolerance: Double) -> Double {
        distanceFromLineToLineCallCount += 1
        
        return distanceFromLineToLineResult
    }
    
    private(set) var lawOfCosinesDistanceCallCount = 0
    var lawOfCosinesDistanceResult: Double = 0
    func lawOfCosinesDistance(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        lawOfCosinesDistanceCallCount += 1
        
        return lawOfCosinesDistanceResult
    }
    
    private(set) var haversineDistanceCallCount = 0
    var haversineDistanceResult: Double = 0
    func haversineDistance(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        haversineDistanceCallCount += 1
        
        return haversineDistanceResult
    }
    
    private(set) var containsLineCallCount = 0
    var containsLineResult: Bool = false
    func contains(_ point: GeodesicPoint, in lineSegment: GeodesicLineSegment, tolerance: Double) -> Bool {
        containsLineCallCount += 1
        
        return containsLineResult
    }
    
    private(set) var containsLinesCallCount = 0
    var containsLinesResult: Bool = false
    func contains(_ point: GeodesicPoint, in line: GeodesicLine, tolerance: Double) -> Bool {
        containsLinesCallCount += 1
        
        return containsLinesResult
    }
    
    private(set) var containsPolygonCallCount = 0
    var containsPolygonResult: Bool = false
    func contains(_ point: GeodesicPoint, in polygon: GeodesicPolygon, tolerance: Double) -> Bool {
        containsPolygonCallCount += 1
        
        return containsPolygonResult
    }
    
    private(set) var midpointCallCount = 0
    func midpoint(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> GeodesicPoint {
        midpointCallCount += 1
        
        return point
    }
    
    private(set) var normalizeLongitudeCallCount = 0
    func normalize(longitude: Double) -> Double {
        normalizeLongitudeCallCount += 1
        
        return longitude
    }
    
    private(set) var normalizeLatitudeCallCount = 0
    func normalize(latitude: Double) -> Double {
        normalizeLatitudeCallCount += 1
        
        return latitude
    }
    
    private(set) var normalizeCallCount = 0
    func normalize(_ point: GeodesicPoint) -> GeodesicPoint {
        normalizeCallCount += 1
        
        return point
    }
    
    private(set) var normalizePositiveLongitudeCallCount = 0
    func normalizePositive(longitude: Double) -> Double {
        normalizePositiveLongitudeCallCount += 1
        
        return longitude
    }
    
    private(set) var normalizePositiveLatitudeCallCount = 0
    func normalizePositive(latitude: Double) -> Double {
        normalizePositiveLatitudeCallCount += 1
        
        return latitude
    }
    
    private(set) var normalizePositiveCallCount = 0
    func normalizePositive(_ point: GeodesicPoint) -> GeodesicPoint {
        normalizePositiveCallCount += 1
        
        return point
    }
    
    private(set) var initialBearingCallCount = 0
    var initialBearingResult: Double = 0
    func initialBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        initialBearingCallCount += 1
        
        return initialBearingResult
    }
    
    private(set) var averageBearingCallCount = 0
    var averageBearingResult: Double = 0
    func averageBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        averageBearingCallCount += 1
        
        return averageBearingResult
    }
    
    private(set) var finalBearingCallCount = 0
    var finalBearingResult: Double = 0
    func finalBearing(from point: GeodesicPoint, to otherPoint: GeodesicPoint) -> Double {
        finalBearingCallCount += 1
        
        return finalBearingResult
    }
}
