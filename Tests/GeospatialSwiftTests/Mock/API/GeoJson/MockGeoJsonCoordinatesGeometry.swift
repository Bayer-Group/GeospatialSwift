@testable import GeospatialSwift

class MockGeoJsonCoordinatesGeometry: MockGeoJsonGeometry, GeoJsonCoordinatesGeometry {
    private(set) var geoJsonCoordinatesCallCount = 0
    private(set) var boundingBoxCallCount = 0
    private(set) var distanceCallCount = 0
    
    var geoJsonCoordinatesResult: [Any] = []
    lazy var boundingBoxResult: GeoJsonBoundingBox = MockGeoJsonBoundingBox()
    var distanceResult: Double = 0
    
    var geoJsonCoordinates: [Any] {
        geoJsonCoordinatesCallCount += 1
        
        return geoJsonCoordinatesResult
    }
    
    var boundingBox: GeoJsonBoundingBox {
        boundingBoxCallCount += 1
        
        return boundingBoxResult
    }
    
    func distance(to point: GeodesicPoint, errorDistance: Double) -> Double {
        distanceCallCount += 1
        
        return distanceResult
    }
}
