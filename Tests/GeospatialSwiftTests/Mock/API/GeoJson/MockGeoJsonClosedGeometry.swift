@testable import GeospatialSwift

class MockGeoJsonClosedGeometry: MockGeoJsonMultiCoordinatesGeometry, GeoJsonClosedGeometry {
    private(set) var edgeDistanceCallCount = 0
    
    var edgeDistanceResult: Double = 0
    
    func edgeDistance(to point: GeodesicPoint, errorDistance: Double) -> Double {
        edgeDistanceCallCount += 1
        
        return edgeDistanceResult
    }
}
