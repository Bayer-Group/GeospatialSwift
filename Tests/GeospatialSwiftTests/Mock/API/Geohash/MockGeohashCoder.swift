@testable import GeospatialSwift

final class MockGeohashCoder: GeohashCoderProtocol {
    private(set) var geohashFromPointCallCount = 0
    private(set) var geohashBoxFromPointCallCount = 0
    private(set) var geohashBoxFromGeohashCallCount = 0
    private(set) var geohashesCallCount = 0
    private(set) var geohashBoxesCallCount = 0
    private(set) var geohashWithNeighborsCallCount = 0
    
    var geohashFromPointResult: String = ""
    lazy var geohashBoxFromPointResult: GeoJsonGeohashBox = MockGeoJsonGeohashBox()
    lazy var geohashBoxFromGeohashResult: GeoJsonGeohashBox = MockGeoJsonGeohashBox()
    var geohashesResult: [String] = []
    var geohashBoxesResult: [GeoJsonGeohashBox] = []
    var geohashWithNeighborsResult: [String] = []
    
    func geohash(for point: GeodesicPoint, precision: Int) -> String {
        geohashFromPointCallCount += 1
        
        return geohashFromPointResult
    }
    
    func geohashBox(for point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox {
        geohashBoxFromPointCallCount += 1
        
        return geohashBoxFromPointResult
    }
    
    func geohashBox(geohash: String) -> GeoJsonGeohashBox? {
        geohashBoxFromGeohashCallCount += 1
        
        return geohashBoxFromGeohashResult
    }
    
    func geohashes(for boundingBox: GeoJsonBoundingBox, precision: Int) -> [String] {
        geohashesCallCount += 1
        
        return geohashesResult
    }
    
    func geohashBoxes(for boundingBox: GeoJsonBoundingBox, precision: Int) -> [GeoJsonGeohashBox] {
        geohashBoxesCallCount += 1
        
        return geohashBoxesResult
    }
    
    func geohashWithNeighbors(for point: GeodesicPoint, precision: Int) -> [String] {
        geohashWithNeighborsCallCount += 1
        
        return geohashWithNeighborsResult
    }
}
