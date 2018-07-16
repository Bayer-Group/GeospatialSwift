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
    
    func testGeometryTypes() {
        XCTAssertEqual(multiPoint.coordinatesGeometries.count, 1)
        XCTAssertEqual(multiPoint.linearGeometries.count, 0)
        XCTAssertEqual(multiPoint.closedGeometries.count, 0)
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
        let contains = multiPoint.contains(distancePoint, errorDistance: 1178422)
        
        XCTAssertEqual(contains, false)
    }
    
    func testContains_OnErrorDistance() {
        let contains = multiPoint.contains(distancePoint, errorDistance: 1178422.47118554264307)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_InsideErrorDistance() {
        let contains = multiPoint.contains(distancePoint, errorDistance: 1178423)
        
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
        
        XCTAssertEqual(distance.description, "1178422.47118554")
    }
    
    func testDistance_NoErrorDistance() {
        let distance = multiPoint.distance(to: distancePoint, errorDistance: 0.0)
        
        XCTAssertEqual(distance.description, "1178422.47118554")
    }
    
    func testDistance_OutsideErrorDistance() {
        let distance = multiPoint.distance(to: distancePoint, errorDistance: 1178422)
        
        XCTAssertEqual(distance.description, "0.47118554264307")
    }
    
    func testDistance_OnErrorDistance() {
        let distance = multiPoint.distance(to: distancePoint, errorDistance: 1178422.883587234187871)
        
        XCTAssertEqual(distance.description, "0.0")
    }
    
    func testDistance_InsideErrorDistance() {
        let distance = multiPoint.distance(to: distancePoint, errorDistance: 1178604)
        
        XCTAssertEqual(distance.description, "0.0")
    }
    
    func testDistance_ChooseCorrectPointForDistance() {
//        points = [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 5)]
        
        let distance1 = multiPoint.distance(to: GeoTestHelper.simplePoint(1, 2.1, 0), errorDistance: 11000)
        let distance2 = multiPoint.distance(to: GeoTestHelper.simplePoint(2, 3.1, 0), errorDistance: 11000)
        
        XCTAssertEqual(distance1.description, "102.612409978732")
        XCTAssertEqual(distance2.description, "131.639424653114")
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
