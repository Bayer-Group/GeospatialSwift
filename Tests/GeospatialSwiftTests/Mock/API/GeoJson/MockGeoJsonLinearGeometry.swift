@testable import GeospatialSwift

class MockGeoJsonLinearGeometry: MockGeoJsonCoordinatesGeometry, GeoJsonLinearGeometry {
    private(set) var lengthCallCount = 0
    var lengthResult: Double = 0
    var length: Double {
        lengthCallCount += 1
        
        return lengthResult
    }
}
