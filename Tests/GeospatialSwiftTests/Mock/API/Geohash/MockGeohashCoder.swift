@testable import GeospatialSwift

//func geohash(for point: GeodesicPoint, precision: Int) -> String
//func geohashes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [String]
//
//func geohashBox(forGeohash geohash: String) -> GeoJsonGeohashBox
//func geohashBox(for point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox
//func geohashBoxes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [GeoJsonGeohashBox]
//
//func geohashNeighbor(forGeohash geohash: String, direction: GeohashCompassPoint) -> String
//func geohashNeighbors(forGeohash geohash: String) -> [String]
//func geohashWithNeighbors(forGeohash geohash: String) -> [String]

final class MockGeohashCoder: GeohashCoderProtocol {
    private(set) var validateCallCount = 0
    var validateResult: Bool = false
    func validate(geohash: String) -> Bool {
        validateCallCount += 1
        
        return validateResult
    }
    
    private(set) var geohashForPointCallCount = 0
    var geohashForPointResult: String = ""
    func geohash(for point: GeodesicPoint, precision: Int) -> String {
        geohashForPointCallCount += 1
        
        return geohashForPointResult
    }
    
    private(set) var geohashesForBoundingBoxCallCount = 0
    var geohashesForBoundingBoxResult: [String] = []
    func geohashes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [String] {
        geohashesForBoundingBoxCallCount += 1
        
        return geohashesForBoundingBoxResult
    }
    
    private(set) var geohashBoxForGeohashCallCount = 0
    var geohashBoxForGeohashResult: GeoJsonGeohashBox = MockGeoJsonGeohashBox()
    func geohashBox(forGeohash geohash: String) -> GeoJsonGeohashBox {
        geohashBoxForGeohashCallCount += 1
        
        return geohashBoxForGeohashResult
    }
    
    private(set) var geohashBoxForPointCallCount = 0
    var geohashBoxForPointResult: GeoJsonGeohashBox = MockGeoJsonGeohashBox()
    func geohashBox(for point: GeodesicPoint, precision: Int) -> GeoJsonGeohashBox {
        geohashBoxForPointCallCount += 1
        
        return geohashBoxForPointResult
    }
    
    private(set) var geohashBoxesForBoundingBoxCallCount = 0
    var geohashBoxesForBoundingBoxResult: [GeoJsonGeohashBox] = []
    func geohashBoxes(for boundingBox: GeodesicBoundingBox, precision: Int) -> [GeoJsonGeohashBox] {
        geohashBoxesForBoundingBoxCallCount += 1
        
        return geohashBoxesForBoundingBoxResult
    }
    
    private(set) var geohashNeighborCallCount = 0
    var geohashNeighborResult: String = ""
    func geohashNeighbor(forGeohash geohash: String, direction: GeohashCompassPoint) -> String {
        geohashNeighborCallCount += 1
        
        return geohashNeighborResult
    }
    
    private(set) var geohashNeighborsCallCount = 0
    var geohashNeighborsResult: [String] = []
    func geohashNeighbors(forGeohash geohash: String) -> [String] {
        geohashNeighborsCallCount += 1
        
        return geohashNeighborsResult
    }
    
    private(set) var geohashWithNeighborsCallCount = 0
    var geohashWithNeighborsResult: [String] = []
    func geohashWithNeighbors(forGeohash geohash: String) -> [String] {
        geohashWithNeighborsCallCount += 1
        
        return geohashWithNeighborsResult
    }
}
