@testable import GeospatialSwift

class MockGeoJsonCoordinatesGeometry: MockGeoJsonGeometry, GeoJsonCoordinatesGeometry {
    private(set) var geoJsonCoordinatesCallCount = 0
    var geoJsonCoordinatesResult: [Any] = []
    var geoJsonCoordinates: [Any] {
        geoJsonCoordinatesCallCount += 1
        
        return geoJsonCoordinatesResult
    }
    
    private(set) var boundingBoxCallCount = 0
    lazy var boundingBoxResult: GeodesicBoundingBox = MockGeoJsonBoundingBox()
    var boundingBox: GeodesicBoundingBox {
        boundingBoxCallCount += 1
        
        return boundingBoxResult
    }
    
    private(set) var distanceCallCount = 0
    var distanceResult: Double = 0
    func distance(to point: GeodesicPoint, tolerance: Double) -> Double {
        distanceCallCount += 1
        
        return distanceResult
    }
    
    private(set) var pointsCallCount = 0
    var pointsResult: [GeoJsonPoint] = []
    var points: [GeodesicPoint] {
        pointsCallCount += 1
        
        return pointsResult
    }
}
