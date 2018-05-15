import XCTest

@testable import GeospatialSwift

class GeohashCoderTests: XCTestCase {
    var geohashCoder: GeohashCoderProtocol!
    
    var geohashCenterPoint: SimplePoint!
    
    // Neighbors
    //    9yzsnmkm8               9yzsnmkm9               9yzsnmkmd
    //    9yzsnmkm2               9yzsnmkm3               9yzsnmkm6
    //    9yzsnmkm0               9yzsnmkm1               9yzsnmkm4
    
    // Centers
    //    -90.422609, 38.701594   -90.422566, 38.701594   -90.422523, 38.701594
    //    -90.422609, 38.701637   -90.422566, 38.701637   -90.422523, 38.701637
    //    -90.422609, 38.70168    -90.422566, 38.70168    -90.422523, 38.70168
    
    // BoundingBox for 9yzsnmkm3
    //    -90.422587, 38.7016155  -90.4225445, 38.7016585
    
    override func setUp() {
        geohashCoder = GeohashCoder()
        
        geohashCenterPoint = SimplePoint(longitude: -90.422566, latitude: 38.701637)
    }
    
    func testGeohash() {
        let geohash = geohashCoder.geohash(for: geohashCenterPoint, precision: 9)
        
        XCTAssertEqual(geohash, "9yzsnmkm3")
    }
    
    func testGeohash_NoPrecision() {
        let geohash = geohashCoder.geohash(for: geohashCenterPoint, precision: 0)
        
        XCTAssertEqual(geohash, "")
    }
    
    func testGeohash_LowPrecision() {
        let geohash = geohashCoder.geohash(for: geohashCenterPoint, precision: 1)
        
        XCTAssertEqual(geohash, "9")
    }
    
    func testGeohash_HighPrecision() {
        let geohash = geohashCoder.geohash(for: geohashCenterPoint, precision: 30)
        
        // Precision can only go to 22.
        XCTAssertEqual(geohash, "9yzsnmkm3kpcnrzgm8nuuz00000000")
    }
    
    func testGeohash_NormalizesPoint() {
        let geohash = geohashCoder.geohash(for: SimplePoint(longitude: -450.422566, latitude: -321.298363), precision: 9)
        
        XCTAssertEqual(geohash, "9yzsnmkm3")
    }
    
    func testGeohashBoxFromPoint() {
        let geohashBox = geohashCoder.geohashBox(for: SimplePoint(longitude: -450.422566, latitude: -321.298363), precision: 9)
        
        XCTAssertEqual(geohashBox.geohash, "9yzsnmkm3")
        XCTAssertEqual(geohashBox.minLongitude.description, "-90.4225873947144")
        XCTAssertEqual(geohashBox.minLatitude.description, "38.7016153335571")
        XCTAssertEqual(geohashBox.maxLongitude.description, "-90.4225444793701")
        XCTAssertEqual(geohashBox.maxLatitude.description, "38.7016582489014")
    }
    
    func testGeohashBoxFromGeohash() {
        let geohashBox = geohashCoder.geohashBox(geohash: "9yzsnmkm3")!
        
        XCTAssertEqual(geohashBox.geohash, "9yzsnmkm3")
        XCTAssertEqual(geohashBox.minLongitude.description, "-90.4225873947144")
        XCTAssertEqual(geohashBox.minLatitude.description, "38.7016153335571")
        XCTAssertEqual(geohashBox.maxLongitude.description, "-90.4225444793701")
        XCTAssertEqual(geohashBox.maxLatitude.description, "38.7016582489014")
    }
    
    func testGeohashBoxFromGeohash_BadGeohash() {
        let geohashBox = geohashCoder.geohashBox(geohash: "!!!!!")
        
        XCTAssertNil(geohashBox)
    }
    
    func testGeohashes() {
        let boundingCoordinates = (minLongitude: -90.422609, minLatitude: 38.701594, maxLongitude: -90.422523, maxLatitude: 38.70168)
        let boundingBox = BoundingBox(boundingCoordinates: boundingCoordinates)
        let geohashes = geohashCoder.geohashes(for: boundingBox, precision: 9)
        
        XCTAssertEqual(geohashes.count, 9)
        XCTAssertEqual(geohashes, ["9yzsnmkm0", "9yzsnmkm2", "9yzsnmkm8", "9yzsnmkm1", "9yzsnmkm3", "9yzsnmkm9", "9yzsnmkm4", "9yzsnmkm6", "9yzsnmkmd"])
    }
    
    func testGeohashBoxes() {
        let boundingCoordinates = (minLongitude: -90.422609, minLatitude: 38.701594, maxLongitude: -90.422523, maxLatitude: 38.70168)
        let boundingBox = BoundingBox(boundingCoordinates: boundingCoordinates)
        let geohashBoxes = geohashCoder.geohashBoxes(for: boundingBox, precision: 9)
        
        XCTAssertEqual(geohashBoxes.count, 9)
        XCTAssertEqual(geohashBoxes.map { $0.geohash }, ["9yzsnmkm0", "9yzsnmkm2", "9yzsnmkm8", "9yzsnmkm1", "9yzsnmkm3", "9yzsnmkm9", "9yzsnmkm4", "9yzsnmkm6", "9yzsnmkmd"])
    }
    
    func testGeohashWithNeighbors() {
        let geohashWithNeighbors = geohashCoder.geohashWithNeighbors(for: geohashCenterPoint, precision: 9)
        
        XCTAssertEqual(geohashWithNeighbors.count, 9)
        XCTAssertEqual(geohashWithNeighbors, ["9yzsnmkm8", "9yzsnmkm9", "9yzsnmkmd", "9yzsnmkm6", "9yzsnmkm4", "9yzsnmkm1", "9yzsnmkm0", "9yzsnmkm2", "9yzsnmkm3"])
    }
}
