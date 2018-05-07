@testable import GeospatialSwift

class MockGeoJsonMultiCoordinatesGeometry: MockGeoJsonCoordinatesGeometry, GeoJsonMultiCoordinatesGeometry {
    private(set) var pointsCallCount = 0
    private(set) var centroidCallCount = 0
    
    var pointsResult: [GeoJsonPoint] = []
    var centroidResult: GeoJsonPoint = MockGeoJsonPoint()
    
    var points: [GeoJsonPoint] {
        pointsCallCount += 1
        
        return pointsResult
    }
    
    var centroid: GeodesicPoint {
        centroidCallCount += 1
        
        return centroidResult
    }
}
