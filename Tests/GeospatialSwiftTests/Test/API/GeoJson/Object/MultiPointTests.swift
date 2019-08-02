import XCTest

@testable import GeospatialSwift

class MultiPointTests: XCTestCase {
    var points: [Point]!
    var multiPoint: MultiPoint!
    var pointsWithDuplicate: [Point]!
    var multiPointWithDuplicate: MultiPoint!
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        points = [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 3)]
        pointsWithDuplicate = [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(1, 3, 3), GeoTestHelper.point(1, 2, 3)]
        
        multiPoint = GeoTestHelper.multiPoint(points)
        multiPointWithDuplicate = GeoTestHelper.multiPoint(pointsWithDuplicate)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(multiPoint.type, .multiPoint)
    }
    
    func testMultiPoints_AllUnique_IsValid() {
        let invalidReasons = multiPoint.invalidReasons(tolerance: 0)
        XCTAssertEqual(invalidReasons.count, 0)
    }
    
    func testMultiPoints_WithDuplicate_IsInvalid() {
        let invalidReasons = multiPointWithDuplicate.invalidReasons(tolerance: 0)
        XCTAssertEqual(invalidReasons.count, 1)
        
        if case MultipointInvalidReason.duplicates(indices: let indices) = invalidReasons[0] {
            XCTAssertEqual(indices.count, 1)
            XCTAssertEqual(indices[0], 0)
        } else {
            XCTFail("Not a multiPoint")
        }
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(multiPoint.objectGeometries as! [MultiPoint], multiPoint.geometries as! [MultiPoint])
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(multiPoint.coordinatesGeometries.count, 1)
        XCTAssertEqual(multiPoint.linearGeometries.count, 0)
        XCTAssertEqual(multiPoint.closedGeometries.count, 0)
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(multiPoint.objectBoundingBox as? BoundingBox, multiPoint.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(multiPoint.geoJson["type"] as? String, "MultiPoint")
        XCTAssertEqual(multiPoint.geoJson["coordinates"] as? [[Double]], MockData.pointsCoordinatesJson)
    }
    
    func testObjectDistance() {
        XCTAssertEqual(multiPoint.distance(to: distancePoint), multiPoint.distance(to: distancePoint))
    }
    
    func testContains_Same() {
        let contains = multiPoint.contains(multiPoint.points.first!)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_Different() {
        let contains = multiPoint.contains(distancePoint)
        
        XCTAssertEqual(contains, false)
    }
    
    func testContains_NoTolerance() {
        let contains = multiPoint.contains(multiPoint.points.first!, tolerance: 0.0)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_OutsideTolerance() {
        let contains = multiPoint.contains(distancePoint, tolerance: 1178422)
        
        XCTAssertEqual(contains, false)
    }
    
    func testContains_OnTolerance() {
        let contains = multiPoint.contains(distancePoint, tolerance: 1178422.47118554264307)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_InsideTolerance() {
        let contains = multiPoint.contains(distancePoint, tolerance: 1178423)
        
        XCTAssertEqual(contains, true)
    }
    
    // GeoJsonCoordinatesGeometry Tests
    
    func testGeoJsonCoordinates() {
        let coordinates = multiPoint.geoJsonCoordinates
        
        XCTAssertTrue(coordinates is [[Double]])
        
        // swiftlint:disable force_cast
        (coordinates as! [[Double]]).enumerated().forEach { pointsOffset, element in
            XCTAssertEqual(element, points[pointsOffset].geoJsonCoordinates as! [Double] )
        }
        // swiftlint:enable force_cast
    }
    
    func testGeometries() {
        XCTAssertEqual(multiPoint.geometries.count, 1)
        XCTAssertEqual(multiPoint, multiPoint.geometries[0] as? MultiPoint)
    }
    
    func testBoundingBox() {
        let resultBoundingBox = multiPoint.boundingBox
        
        let boundingBox = BoundingBox.best(points.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
    }
    
    func testDistance() {
        let distance = multiPoint.distance(to: distancePoint)
        
        XCTAssertEqual(distance, 1178422.47118554, accuracy: 10)
    }
    
    func testDistance_NoTolerance() {
        let distance = multiPoint.distance(to: distancePoint, tolerance: 0.0)
        
        XCTAssertEqual(distance, 1178422.47118554, accuracy: 10)
    }
    
    func testDistance_OutsideTolerance() {
        let distance = multiPoint.distance(to: distancePoint, tolerance: 1178422)
        
        XCTAssertEqual(distance, 0.47118554264307, accuracy: 10)
    }
    
    func testDistance_OnTolerance() {
        let distance = multiPoint.distance(to: distancePoint, tolerance: 1178422.883587234187871)
        
        XCTAssertEqual(distance.description, "0.0")
    }
    
    func testDistance_InsideTolerance() {
        let distance = multiPoint.distance(to: distancePoint, tolerance: 1178604)
        
        XCTAssertEqual(distance.description, "0.0")
    }
    
    func testDistance_ChooseCorrectPointForDistance() {
//        points = [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 5)]
        
        let distance1 = multiPoint.distance(to: GeoTestHelper.simplePoint(1, 2.1, 0), tolerance: 11000)
        let distance2 = multiPoint.distance(to: GeoTestHelper.simplePoint(2, 3.1, 0), tolerance: 11000)
        
        XCTAssertEqual(distance1, 102.612409978732, accuracy: 10)
        XCTAssertEqual(distance2, 131.639424653114, accuracy: 10)
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    // swiftlint:disable force_cast
    func testPoints() {
        XCTAssertEqual(multiPoint.points.map { $0 as! Point }, points)
    }
    
    // MultiPoint Tests
    
    func testEquals() {
        XCTAssertEqual(multiPoint, multiPoint)
    }
    
    func testNotEquals() {
        XCTAssertNotEqual(multiPoint, GeoTestHelper.multiPoint([GeoTestHelper.point(0, 0, 0)]))
    }
}
