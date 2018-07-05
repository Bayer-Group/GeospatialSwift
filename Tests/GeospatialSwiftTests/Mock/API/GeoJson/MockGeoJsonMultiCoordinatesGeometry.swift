@testable import GeospatialSwift

class MockGeoJsonMultiCoordinatesGeometry: MockGeoJsonCoordinatesGeometry, GeoJsonMultiCoordinatesGeometry {
    private(set) var pointsCallCount = 0
    var pointsResult: [GeoJsonPoint] = []
    var points: [GeoJsonPoint] {
        pointsCallCount += 1
        
        return pointsResult
    }
    
    private(set) var centroidCallCount = 0
    var centroidResult: GeoJsonPoint = MockGeoJsonPoint()
    var centroid: GeodesicPoint {
        centroidCallCount += 1
        
        return centroidResult
    }
}
