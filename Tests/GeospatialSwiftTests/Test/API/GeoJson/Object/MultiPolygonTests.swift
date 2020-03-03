import XCTest

@testable import GeospatialSwift

class MultiPolygonTests: XCTestCase {
    var polygons: [Polygon]!
    var multiPolygon: MultiPolygon!
    var touchingMultiPolygon: MultiPolygon!
    var sharingEdgeMultiPolygons: MultiPolygon!
    var containingMultiPolygons: MultiPolygon!
    
    var distancePoint: SimplePoint!
    
    var point: GeoJson.Point!
    
    override func setUp() {
        super.setUp()
        
        polygons = MockData.polygons
        
        multiPolygon = GeoTestHelper.multiPolygon(polygons)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
        
        point = GeoTestHelper.point(0, 0, 0)
        
        touchingMultiPolygon = GeoTestHelper.multiPolygon(MockData.touchingPolygons)
        
        sharingEdgeMultiPolygons = GeoTestHelper.multiPolygon(MockData.sharingEdgePolygons)
        
        containingMultiPolygons = GeoTestHelper.multiPolygon(MockData.containingPolygons)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(multiPolygon.type, .multiPolygon)
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(multiPolygon.objectGeometries as! [MultiPolygon], multiPolygon.geometries as! [MultiPolygon])
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(multiPolygon.coordinatesGeometries.count, 1)
        XCTAssertEqual(multiPolygon.linearGeometries.count, 0)
        XCTAssertEqual(multiPolygon.closedGeometries.count, 1)
    }
    
    func testTouchingMultiPolygonsIsValid() {
        XCTAssertEqual(touchingMultiPolygon.simpleViolations(tolerance: 0).count, 0)
    }
    
    func testSharingEdgeMultiPolygonsIsInvalid() {
        let simpleViolations = sharingEdgeMultiPolygons.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 1)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.multiPolygonIntersection)
        
        if let point1 = simpleViolations[0].problems[0] as? Point, let point2 = simpleViolations[0].problems[1] as? Point, let point3 = simpleViolations[0].problems[3] as? Point, let point4 = simpleViolations[0].problems[4] as? Point {
            XCTAssertEqual(point1.longitude, 21.0)
            XCTAssertEqual(point1.latitude, 21.0)
            XCTAssertEqual(point2.longitude, 21.0)
            XCTAssertEqual(point2.latitude, 20.0)
            XCTAssertEqual(point3.longitude, 21.0)
            XCTAssertEqual(point3.latitude, 21.0)
            XCTAssertEqual(point4.longitude, 21.0)
            XCTAssertEqual(point4.latitude, 20.0)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testContainedMultiPolygonsIsInvalid() {
        let simpleViolations = containingMultiPolygons.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 1)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.multiPolygonContained)
        
        if let point1 = simpleViolations[0].problems[0] as? Point, let point2 = simpleViolations[0].problems[2] as? Point, let point3 = simpleViolations[0].problems[4] as? Point, let point4 = simpleViolations[0].problems[6] as? Point {
            XCTAssertEqual(point1.longitude, 21.0)
            XCTAssertEqual(point1.latitude, 21.0)
            XCTAssertEqual(point2.longitude, 22.0)
            XCTAssertEqual(point2.latitude, 21.0)
            XCTAssertEqual(point3.longitude, 22.0)
            XCTAssertEqual(point3.latitude, 22.0)
            XCTAssertEqual(point4.longitude, 21.0)
            XCTAssertEqual(point4.latitude, 22.0)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(multiPolygon.objectBoundingBox, multiPolygon.boundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(multiPolygon.geoJson["type"] as? String, "MultiPolygon")
        XCTAssertEqual(multiPolygon.geoJson["coordinates"] as? [[[[Double]]]], MockData.polygonsCoordinatesJson)
    }
    
    func testObjectDistance() {
        XCTAssertEqual(multiPolygon.distance(to: distancePoint), multiPolygon.distance(to: distancePoint))
    }
    
    func testContains() {
        // SOMEDAY: Test me.
    }
    
    func testContainsWithTolerance() {
        // SOMEDAY: Test me.
    }
    
    // GeoJsonCoordinatesGeometry Tests
    
    func testGeoJsonCoordinates() {
        let coordinates = multiPolygon.geoJsonCoordinates
        
        XCTAssertTrue(coordinates is [[[[Double]]]])
        
        // swiftlint:disable force_cast
        XCTAssertEqual((coordinates as! [[[[Double]]]]).count, polygons.count)
        (coordinates as! [[[[Double]]]]).enumerated().forEach { polygonsOffset, element in
            XCTAssertEqual(element.count, polygons[polygonsOffset].linearRings.count)
            element.enumerated().forEach { linearRingsOffset, element in
                XCTAssertEqual(element.count, polygons[polygonsOffset].linearRings[linearRingsOffset].points.count)
                element.enumerated().forEach { pointsOffset, element in
                    XCTAssertEqual(element, (polygons[polygonsOffset].linearRings[linearRingsOffset].points[pointsOffset] as! Point).geoJsonCoordinates as! [Double] )
                }
            }
        }
        // swiftlint:enable force_cast
    }
    
    func testGeometries() {
        XCTAssertEqual(multiPolygon.geometries.count, 1)
        XCTAssertEqual(multiPolygon, multiPolygon.geometries[0] as? MultiPolygon)
    }
    
    func testBoundingBox() {
        let resultBoundingBox = multiPolygon.boundingBox
        
        let boundingBox = GeodesicBoundingBox.best(polygons.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox, boundingBox)
    }
    
    func testDistance() {
        // SOMEDAY: Test me.
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    func testPoints() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(multiPolygon.points as! [Point], multiPolygon.polygons.flatMap { $0.points as! [Point] })
    }
    
    // GeoJsonClosedGeometry Tests
    
    func testHasHole() {
        // SOMEDAY: Need to test multipolygon with and without holes.
    }
    
    func testArea() {
        XCTAssertEqual(multiPolygon.area, 98455858999.07483, accuracy: 10)
    }
    
    // SOMEDAY: Test Edge Distance
    
    // MultiPolygon Tests
    
    func testPolygons() {
        XCTAssertEqual((multiPolygon.polygons as? [Polygon])!, polygons)
    }
    
    func testEquals() {
        XCTAssertEqual(multiPolygon, multiPolygon)
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testNotEquals() {
        let polygon = GeoTestHelper.polygon(GeoTestHelper.lineString([point, point, point, point]))
        
        XCTAssertNotEqual(multiPolygon, GeoTestHelper.multiPolygon([polygon, polygon]))
    }
}
