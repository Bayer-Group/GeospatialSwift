@testable import GeospatialSwift

class MockGeoJsonMultiCoordinatesGeometry: MockGeoJsonCoordinatesGeometry, GeoJsonMultiCoordinatesGeometry {
    private(set) var pointsCallCount = 0
    var pointsResult: [GeoJsonPoint] = []
    var points: [GeoJsonPoint] {
        pointsCallCount += 1
        
        return pointsResult
    }
}
