import XCTest

@testable import GeospatialSwift

class MultiPolygonTests: XCTestCase {
    var polygons: [GeospatialSwift.Polygon]!
    var multiPolygon: MultiPolygon!
    var distancePoint: SimplePoint!
    
    var point: GeoJsonPoint!
    
    override func setUp() {
        super.setUp()
        
        // swiftlint:disable:next force_cast
        polygons = MockData.polygons as! [GeospatialSwift.Polygon]
        
        multiPolygon = GeoTestHelper.multiPolygon(polygons)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
        
        point = GeoTestHelper.point(0, 0, 0)
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
        XCTAssertEqual(multiPolygon.multiCoordinatesGeometries.count, 1)
        XCTAssertEqual(multiPolygon.linearGeometries.count, 0)
        XCTAssertEqual(multiPolygon.closedGeometries.count, 1)
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(multiPolygon.objectBoundingBox as? BoundingBox, multiPolygon.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(multiPolygon.geoJson.description, "[\"type\": \"MultiPolygon\", \"coordinates\": \(MockData.polygonsCoordinatesJson)]")
    }
    
    func testObjectDistance() {
        XCTAssertEqual(multiPolygon.distance(to: distancePoint), multiPolygon.distance(to: distancePoint))
    }
    
    func testContains() {
        // TODO: Test me.
    }
    
    func testContainsWithErrorDistance() {
        // TODO: Test me.
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
                    XCTAssertEqual(element, polygons[polygonsOffset].linearRings[linearRingsOffset].points[pointsOffset].geoJsonCoordinates as! [Double] )
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
        
        let boundingBox = BoundingBox.best(polygons.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
    }
    
    func testDistance() {
        // TODO: Test me.
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    func testPoints() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(multiPolygon.points as! [Point], multiPolygon.polygons.flatMap { $0.points as! [Point] })
    }
    
    func testCentroid() {
        // TODO: Test me.
    }
    
    // GeoJsonClosedGeometry Tests
    
    func testHasHole() {
        // TODO: Need to test multipolygon with and without holes.
    }
    
    func testArea() {
        XCTAssertEqual(multiPolygon.area.description, "37490216.3337727")
    }
    
    // TODO: Test Edge Distance
    
    // MultiPolygon Tests
    
    func testPolygons() {
        XCTAssertEqual((multiPolygon.polygons as? [GeospatialSwift.Polygon])!, polygons)
    }
    
    func testEquals() {
        XCTAssertEqual(multiPolygon, multiPolygon)
    }
    
    // TODO: Comparing the Json test data and this is confusing.
    func testNotEquals() {
        let polygon = GeoTestHelper.polygon([GeoTestHelper.lineString([point, point, point, point])])
        
        XCTAssertNotEqual(multiPolygon, GeoTestHelper.multiPolygon([polygon, polygon]))
    }
}
