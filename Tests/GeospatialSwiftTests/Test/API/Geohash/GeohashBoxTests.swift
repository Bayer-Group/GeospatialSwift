import XCTest

@testable import GeospatialSwift

class GeohashBoxTests: XCTestCase {
    var geohashCoder: GeohashCoderProtocol!
    
    private(set) var simpleGeohashBox: GeohashBox!
    
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
        
        let boundingCoordinates = (minLongitude: -90.422587, minLatitude: 38.7016155, maxLongitude: -90.4225445, maxLatitude: 38.7016585)
        
        simpleGeohashBox = GeohashBox(boundingCoordinates: boundingCoordinates, geohashCoder: geohashCoder, geohash: "9yzsnmkm3")
    }
    
    func testGeohash() {
        XCTAssertEqual(simpleGeohashBox.geohash, "9yzsnmkm3")
    }
    
    func testGeohashNeighbor_North() {
        let neighbor = simpleGeohashBox.geohashNeighbor(direction: .north, precision: 9)
        
        XCTAssertEqual(neighbor.geohash, "9yzsnmkm9")
    }
    
    func testGeohashNeighbor_South() {
        let neighbor = simpleGeohashBox.geohashNeighbor(direction: .south, precision: 9)
        
        XCTAssertEqual(neighbor.geohash, "9yzsnmkm1")
    }
    
    func testGeohashNeighbor_East() {
        let neighbor = simpleGeohashBox.geohashNeighbor(direction: .east, precision: 9)
        
        XCTAssertEqual(neighbor.geohash, "9yzsnmkm6")
    }
    
    func testGeohashNeighbor_West() {
        let neighbor = simpleGeohashBox.geohashNeighbor(direction: .west, precision: 9)
        
        XCTAssertEqual(neighbor.geohash, "9yzsnmkm2")
    }
    
    func testGeohashNeighbor_Northeast() {
        let neighbor = simpleGeohashBox.geohashNeighbor(direction: .north, precision: 9).geohashNeighbor(direction: .east, precision: 9)
        
        XCTAssertEqual(neighbor.geohash, "9yzsnmkmd")
    }
    
    func testGeohashNeighbor_Northwest() {
        let neighbor = simpleGeohashBox.geohashNeighbor(direction: .north, precision: 9).geohashNeighbor(direction: .west, precision: 9)
        
        XCTAssertEqual(neighbor.geohash, "9yzsnmkm8")
    }
    
    func testGeohashNeighbor_Southeast() {
        let neighbor = simpleGeohashBox.geohashNeighbor(direction: .south, precision: 9).geohashNeighbor(direction: .east, precision: 9)
        
        XCTAssertEqual(neighbor.geohash, "9yzsnmkm4")
    }
    
    func testGeohashNeighbor_Southwest() {
        let neighbor = simpleGeohashBox.geohashNeighbor(direction: .south, precision: 9).geohashNeighbor(direction: .west, precision: 9)
        
        XCTAssertEqual(neighbor.geohash, "9yzsnmkm0")
    }
}
