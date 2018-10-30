@testable import GeospatialSwift

final class MockGeohashCoder: GeohashCoderProtocol {
    private(set) var geohashFromPointCallCount = 0
    var geohashFromPointResult: String = ""
    func geohash(for point: GeodesicPoint, precision: Int) -> String {
        geohashFromPointCallCount += 1
        
        return geohashFromPointResult
    }
    
    private(set) var geohashBoxFromPointCallCount = 0
    lazy var geohashBoxFromPointResult: GeoJsonGeohashBox = MockGeoJsonGeohashBox()
    func geohashBox(for point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox {
        geohashBoxFromPointCallCount += 1
        
        return geohashBoxFromPointResult
    }
    
    private(set) var geohashBoxFromGeohashCallCount = 0
    lazy var geohashBoxFromGeohashResult: GeoJsonGeohashBox = MockGeoJsonGeohashBox()
    func geohashBox(geohash: String) -> GeoJsonGeohashBox? {
        geohashBoxFromGeohashCallCount += 1
        
        return geohashBoxFromGeohashResult
    }
    
    private(set) var geohashesCallCount = 0
    var geohashesResult: [String] = []
    func geohashes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [String] {
        geohashesCallCount += 1
        
        return geohashesResult
    }
    
    private(set) var geohashBoxesCallCount = 0
    var geohashBoxesResult: [GeoJsonGeohashBox] = []
    func geohashBoxes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [GeoJsonGeohashBox] {
        geohashBoxesCallCount += 1
        
        return geohashBoxesResult
    }
    
    private(set) var geohashWithNeighborsCallCount = 0
    var geohashWithNeighborsResult: [String] = []
    func geohashWithNeighbors(for point: GeodesicPoint, precision: Int) -> [String] {
        geohashWithNeighborsCallCount += 1
        
        return geohashWithNeighborsResult
    }
}
