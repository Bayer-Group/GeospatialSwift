@testable import GeospatialSwift

class MockGeoJsonClosedGeometry: MockGeoJsonCoordinatesGeometry, GeoJsonClosedGeometry {
    private(set) var edgeDistanceCallCount = 0
    var edgeDistanceResult: Double = 0
    func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double {
        edgeDistanceCallCount += 1
        
        return edgeDistanceResult
    }
    
    private(set) var hasHoleCallCount = 0
    var hasHoleResult: Bool = false
    var hasHole: Bool {
        hasHoleCallCount += 1
        
        return hasHoleResult
    }
    
    private(set) var areaCallCount = 0
    var areaResult: Double = 0
    var area: Double {
        areaCallCount += 1
        
        return areaResult
    }
}
