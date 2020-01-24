@testable import GeospatialSwift

final class MockGeoJsonGeohashBox: MockGeoJsonBoundingBox, GeoJsonGeohashBox {
    private(set) var geohashCallCount = 0
    var geohashResult: String = ""
    var geohash: String {
        geohashCallCount += 1
        
        return geohashResult
    }
    
    private(set) var boundingBoxCallCount = 0
    var boundingBoxResult: GeodesicBoundingBox = MockGeoJsonBoundingBox()
    var boundingBox: GeodesicBoundingBox {
        boundingBoxCallCount += 1
        
        return boundingBoxResult
    }
}
