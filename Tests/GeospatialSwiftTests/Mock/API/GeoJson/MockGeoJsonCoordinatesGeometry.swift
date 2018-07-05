@testable import GeospatialSwift

class MockGeoJsonCoordinatesGeometry: MockGeoJsonGeometry, GeoJsonCoordinatesGeometry {
    private(set) var geoJsonCoordinatesCallCount = 0
    var geoJsonCoordinatesResult: [Any] = []
    var geoJsonCoordinates: [Any] {
        geoJsonCoordinatesCallCount += 1
        
        return geoJsonCoordinatesResult
    }
    
    private(set) var boundingBoxCallCount = 0
    lazy var boundingBoxResult: GeoJsonBoundingBox = MockGeoJsonBoundingBox()
    var boundingBox: GeoJsonBoundingBox {
        boundingBoxCallCount += 1
        
        return boundingBoxResult
    }
    
    private(set) var distanceCallCount = 0
    var distanceResult: Double = 0
    func distance(to point: GeodesicPoint, errorDistance: Double) -> Double {
        distanceCallCount += 1
        
        return distanceResult
    }
}
