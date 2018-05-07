import XCTest

@testable import GeospatialSwift

class MultiPointTests: XCTestCase {
    var points: [Point]!
    var multiPoint: MultiPoint!
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        points = [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 5)]
        
        multiPoint = GeoTestHelper.multiPoint(points)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(multiPoint.type, .multiPoint)
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(multiPoint.objectGeometries as! [MultiPoint], multiPoint.geometries as! [MultiPoint])
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(multiPoint.objectBoundingBox as? BoundingBox, multiPoint.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(multiPoint.geoJson.description, "[\"type\": \"MultiPoint\", \"coordinates\": \(MockData.pointsCoordinatesJson)]")
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
    
    func testContains_NoErrorDistance() {
        let contains = multiPoint.contains(multiPoint.points.first!, errorDistance: 0.0)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_OutsideErrorDistance() {
        let contains = multiPoint.contains(distancePoint, errorDistance: 1178603)
        
        XCTAssertEqual(contains, false)
    }
    
    func testContains_OnErrorDistance() {
        let contains = multiPoint.contains(distancePoint, errorDistance: 1178603.883587234187871)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_InsideErrorDistance() {
        let contains = multiPoint.contains(distancePoint, errorDistance: 1178604)
        
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
        
        #if swift(>=4.1)
        let boundingBox = BoundingBox.best(points.compactMap { $0.boundingBox })
        #else
        let boundingBox = BoundingBox.best(points.flatMap { $0.boundingBox })
        #endif
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
    }
    
    func testDistance() {
        let distance = multiPoint.distance(to: distancePoint)
        
        XCTAssertEqual(distance.description, "1178603.88358723")
    }
    
    func testDistance_NoErrorDistance() {
        let distance = multiPoint.distance(to: distancePoint, errorDistance: 0.0)
        
        XCTAssertEqual(distance.description, "1178603.88358723")
    }
    
    func testDistance_OutsideErrorDistance() {
        let distance = multiPoint.distance(to: distancePoint, errorDistance: 1178603)
        
        XCTAssertEqual(distance.description, "0.883587231626734")
    }
    
    func testDistance_OnErrorDistance() {
        let distance = multiPoint.distance(to: distancePoint, errorDistance: 1178603.883587234187871)
        
        XCTAssertEqual(distance.description, "0.0")
    }
    
    func testDistance_InsideErrorDistance() {
        let distance = multiPoint.distance(to: distancePoint, errorDistance: 1178604)
        
        XCTAssertEqual(distance.description, "0.0")
    }
    
    func testDistance_ChooseCorrectPointForDistance() {
        let distance1 = multiPoint.distance(to: GeoTestHelper.simplePoint(1, 2.1, 0), errorDistance: 11000)
        let distance2 = multiPoint.distance(to: GeoTestHelper.simplePoint(2, 3.1, 0), errorDistance: 11000)
        
        XCTAssertEqual(distance1.description, "131.949079327373")
        XCTAssertEqual(distance2.description, "131.949079327373")
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    // swiftlint:disable force_cast
    func testPoints() {
        XCTAssertEqual(multiPoint.points.map { $0 as! Point }, points)
    }
    
    func testCentroid() {
        XCTAssertEqual(multiPoint.centroid as! SimplePoint, GeoTestHelper.simplePoint(1.74990474937385, 2.50006181604718, 3))
    }
    // swiftlint:enable force_cast
    
    func testCentroid_Negative_To_Positive() {
        let centroid = GeoTestHelper.multiPoint([GeoTestHelper.point(-5, -5), GeoTestHelper.point(5, 5)]).centroid
        let expectedPoint = GeoTestHelper.simplePoint(0, 0, nil)
        
        AssertEqualAccuracy10(centroid.longitude, expectedPoint.longitude)
        AssertEqualAccuracy10(centroid.latitude, expectedPoint.latitude)
    }
    
    func testCentroid_Negative_To_Negative() {
        let centroid = GeoTestHelper.multiPoint([GeoTestHelper.point(-20, -10), GeoTestHelper.point(-10, -5)]).centroid
        let expectedPoint = GeoTestHelper.simplePoint(-14.9711864618099, -7.52831985539658, nil)
        
        AssertEqualAccuracy10(centroid.longitude, expectedPoint.longitude)
        AssertEqualAccuracy10(centroid.latitude, expectedPoint.latitude)
    }
    
    // MultiPoint Tests
    
    func testEquals() {
        XCTAssertEqual(multiPoint, multiPoint)
    }
    
    func testNotEquals() {
        XCTAssertNotEqual(multiPoint, GeoTestHelper.multiPoint([GeoTestHelper.point(0, 0, 0)]))
    }
}
