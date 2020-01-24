import XCTest

@testable import GeospatialSwift

class GeohashCoderTests: XCTestCase {
    var geohashCoder: GeohashCoderProtocol!
    
    var geohash: String!
    var geohashNeighbors: [String]!
    var geohashWithNeighbors: [String]!
    
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
    
    // GeoJson for 9yzsnmkm3 (Geohash) and 9yzsnmkm9 (North neighbor)
    //    {
    //      "type": "FeatureCollection",
    //      "features": [
    //        {
    //          "type": "Feature",
    //          "properties": {
    //            "name": "9yzsnmkm3"
    //          },
    //          "geometry": {
    //            "type": "Polygon",
    //            "coordinates": [
    //              [
    //                [
    //                  -90.4225873947144,
    //                  38.7016153335571
    //                ],
    //                [
    //                  -90.4225873947144,
    //                  38.7016582489014
    //                ],
    //                [
    //                  -90.4225444793701,
    //                  38.7016582489014
    //                ],
    //                [
    //                  -90.4225444793701,
    //                  38.7016153335571
    //                ],
    //                [
    //                  -90.4225873947144,
    //                  38.7016153335571
    //                ]
    //              ]
    //            ]
    //          }
    //        },
    //        {
    //          "type": "Feature",
    //          "properties": {
    //            "name": "9yzsnmkm9"
    //          },
    //          "geometry": {
    //            "type": "Polygon",
    //            "coordinates": [
    //              [
    //                [
    //                  -90.42258739471436,
    //                  38.70165824890137
    //                ],
    //                [
    //                  -90.42258739471436,
    //                  38.701701164245605
    //                ],
    //                [
    //                  -90.42254447937012,
    //                  38.701701164245605
    //                ],
    //                [
    //                  -90.42254447937012,
    //                  38.70165824890137
    //                ],
    //                [
    //                  -90.42258739471436,
    //                  38.70165824890137
    //                ]
    //              ]
    //            ]
    //          }
    //        }
    //      ]
    //    }
    
    override func setUp() {
        geohashCoder = GeohashCoder()
        
        geohash = "9yzsnmkm3"
        // Order matters! Starts with north and goes clockwise.
        geohashNeighbors = ["9yzsnmkm9", "9yzsnmkmd", "9yzsnmkm6", "9yzsnmkm4", "9yzsnmkm1", "9yzsnmkm0", "9yzsnmkm2", "9yzsnmkm8"]
        // Order matters! Starts with the geohash and appends the geohashNeighbors
        geohashWithNeighbors = ["9yzsnmkm3"] + geohashNeighbors
        geohashCenterPoint = SimplePoint(longitude: -90.422566, latitude: 38.701637)
    }
    
    func testGeohash() {
        let geohash = geohashCoder.geohash(for: geohashCenterPoint, precision: 9)
        
        XCTAssertEqual(geohash, geohash)
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
        
        XCTAssertEqual(geohash, geohash)
    }
    
    func testGeohashBoxFromPoint() {
        let geohashBox = geohashCoder.geohashBox(for: SimplePoint(longitude: -450.422566, latitude: -321.298363), precision: 9)
        
        XCTAssertEqual(geohashBox.geohash, geohash)
        XCTAssertEqual(geohashBox.boundingBox.minLongitude, -90.4225873947144, accuracy: 10)
        XCTAssertEqual(geohashBox.boundingBox.minLatitude, 38.7016153335571, accuracy: 10)
        XCTAssertEqual(geohashBox.boundingBox.maxLongitude, -90.4225444793701, accuracy: 10)
        XCTAssertEqual(geohashBox.boundingBox.maxLatitude, 38.7016582489014, accuracy: 10)
    }
    
    func testGeohashBoxFromGeohash() {
        let geohashBox = geohashCoder.geohashBox(forGeohash: geohash)
        
        XCTAssertEqual(geohashBox.geohash, geohash)
        XCTAssertEqual(geohashBox.boundingBox.minLongitude, -90.4225873947144, accuracy: 10)
        XCTAssertEqual(geohashBox.boundingBox.minLatitude, 38.7016153335571, accuracy: 10)
        XCTAssertEqual(geohashBox.boundingBox.maxLongitude, -90.4225444793701, accuracy: 10)
        XCTAssertEqual(geohashBox.boundingBox.maxLatitude, 38.7016582489014, accuracy: 10)
    }
    
    func testGeohashes() {
        let boundingCoordinates = (minLongitude: -90.422609, minLatitude: 38.701594, maxLongitude: -90.422523, maxLatitude: 38.70168)
        let boundingBox = BoundingBox(boundingCoordinates: boundingCoordinates)
        let geohashes = geohashCoder.geohashes(for: boundingBox, precision: 9)
        
        XCTAssertEqual(geohashes.count, 9)
        XCTAssertEqual(geohashes, ["9yzsnmkm0", "9yzsnmkm2", "9yzsnmkm8", "9yzsnmkm1", geohash, "9yzsnmkm9", "9yzsnmkm4", "9yzsnmkm6", "9yzsnmkmd"])
    }
    
    func testGeohashBoxes() {
        let boundingCoordinates = (minLongitude: -90.422609, minLatitude: 38.701594, maxLongitude: -90.422523, maxLatitude: 38.70168)
        let boundingBox = BoundingBox(boundingCoordinates: boundingCoordinates)
        let geohashBoxes = geohashCoder.geohashBoxes(for: boundingBox, precision: 9)
        
        XCTAssertEqual(geohashBoxes.count, 9)
        XCTAssertEqual(geohashBoxes.map { $0.geohash }, ["9yzsnmkm0", "9yzsnmkm2", "9yzsnmkm8", "9yzsnmkm1", geohash, "9yzsnmkm9", "9yzsnmkm4", "9yzsnmkm6", "9yzsnmkmd"])
    }
    
    func testGeohashNeighbor_North() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .north)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkm9")
    }
    
    func testGeohashNeighbor_South() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .south)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkm1")
    }
    
    func testGeohashNeighbor_East() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .east)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkm6")
    }
    
    func testGeohashNeighbor_West() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .west)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkm2")
    }
    
    func testGeohashNeighbor_Northeast() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .north), direction: .east)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkmd")
    }
    
    func testGeohashNeighbor_Northwest() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .north), direction: .west)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkm8")
    }
    
    func testGeohashNeighbor_Southeast() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .south), direction: .east)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkm4")
    }
    
    func testGeohashNeighbor_Southwest() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .south), direction: .west)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkm0")
    }
    
    func testGeohashBoxNeighbor_North() {
        let geohashNeighbor = geohashCoder.geohashNeighbor(forGeohash: geohash, direction: .north)
        let geohashBoxNeighbor = geohashCoder.geohashBox(forGeohash: geohashNeighbor)
        
        XCTAssertEqual(geohashNeighbor, "9yzsnmkm9")
        XCTAssertEqual(geohashBoxNeighbor.geohash, "9yzsnmkm9")
        XCTAssertEqual(geohashBoxNeighbor.boundingBox.boundingCoordinates.minLongitude, -90.42258739471436, accuracy: 10)
        XCTAssertEqual(geohashBoxNeighbor.boundingBox.boundingCoordinates.minLatitude, 38.70165824890137, accuracy: 10)
        XCTAssertEqual(geohashBoxNeighbor.boundingBox.boundingCoordinates.maxLongitude, -90.42254447937012, accuracy: 10)
        XCTAssertEqual(geohashBoxNeighbor.boundingBox.boundingCoordinates.maxLatitude, 38.701701164245605, accuracy: 10)
    }
    
    func testGeohashNeighbors() {
        let geohashNeighbors = geohashCoder.geohashNeighbors(forGeohash: geohash)
        
        XCTAssertEqual(geohashNeighbors.count, 8)
        XCTAssertEqual(geohashNeighbors, self.geohashNeighbors)
    }
    
    func testGeohashWithNeighbors() {
        let geohashWithNeighbors = geohashCoder.geohashWithNeighbors(forGeohash: geohash)
        
        XCTAssertEqual(geohashWithNeighbors.count, 9)
        XCTAssertEqual(geohashWithNeighbors, self.geohashWithNeighbors)
    }
    
    func testGeohashNeighbors_EdgePrefixDoesNotMatch() {
        let geohashNeighbors = geohashCoder.geohashNeighbors(forGeohash: "u000")
        
        XCTAssertEqual(geohashNeighbors.count, 8)
        XCTAssertEqual(geohashNeighbors, ["u001", "u003", "u002", "spbr", "spbp", "ezzz", "gbpb", "gbpc"])
    }
}
