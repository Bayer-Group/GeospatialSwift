@testable import GeospatialSwift

final class MockGeoJsonGeohashBox: MockGeoJsonBoundingBox, GeoJsonGeohashBox {
    private(set) var geohashCallCount = 0
    private(set) var geohashNeighborCallCount = 0
    
    var geohashResult: String = ""
    lazy var geohashNeighborResult: GeoJsonGeohashBox = MockGeoJsonGeohashBox()
    
    var geohash: String {
        geohashCallCount += 1
        
        return geohashResult
    }
    
    func geohashNeighbor(direction: GeohashCompassPoint, precision: Int) -> GeoJsonGeohashBox {
        geohashNeighborCallCount += 1
        
        return geohashNeighborResult
    }
}
