import XCTest

@testable import GeospatialSwift

class GeometryCollectionTests: XCTestCase {
    var geometries: [GeoJsonGeometry]!
    var geometryCollection: GeometryCollection!
    var geometryCollectionNested: GeometryCollection!
    var nilGeometryCollection: GeometryCollection?
    var distancePoint: SimplePoint!
    
    var point: GeoJson.Point!
    
    override func setUp() {
        super.setUp()
        
        geometries = MockData.geometries
        
        geometryCollection = GeoTestHelper.geometryCollection(geometries)
        
        geometryCollectionNested = GeoTestHelper.geometryCollection([GeoTestHelper.geometryCollection([geometryCollection, geometryCollection])])
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
        
        point = GeoTestHelper.point(0, 0, 0)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(geometryCollection.type, .geometryCollection)
    }
    
    func testObjectGeometries() {
        XCTAssertEqual(geometryCollection.objectGeometries?.count, 6)
        XCTAssertTrue(geometryCollection.objectGeometries?[0] is Point)
        XCTAssertTrue(geometryCollection.objectGeometries?[1] is MultiPoint)
        XCTAssertTrue(geometryCollection.objectGeometries?[2] is LineString)
        XCTAssertTrue(geometryCollection.objectGeometries?[3] is MultiLineString)
        XCTAssertTrue(geometryCollection.objectGeometries?[4] is Polygon)
        XCTAssertTrue(geometryCollection.objectGeometries?[5] is MultiPolygon)
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(geometryCollection.coordinatesGeometries.count, 6)
        XCTAssertEqual(geometryCollection.linearGeometries.count, 2)
        XCTAssertEqual(geometryCollection.closedGeometries.count, 2)
        
        XCTAssertEqual(geometryCollectionNested.coordinatesGeometries.count, 12)
        XCTAssertEqual(geometryCollectionNested.linearGeometries.count, 4)
        XCTAssertEqual(geometryCollectionNested.closedGeometries.count, 4)
    }
    
    func testObjectBoundingBox() {
        let resultBoundingBox = geometryCollection.objectBoundingBox
        
        let boundingBox = GeodesicBoundingBox.best(geometryCollection.objectGeometries!.compactMap { $0.objectBoundingBox })
        
        XCTAssertEqual(resultBoundingBox, boundingBox)
    }
    
    func testGeoJson() {
        let geometries = (geometryCollection.geoJson["geometries"] as? [[String: Any]])
        XCTAssertEqual(geometryCollection.geoJson["type"] as? String, "GeometryCollection")
        XCTAssertEqual(geometries?.count, 6)
        XCTAssertEqual(geometries?[0]["type"] as? String, "Point")
        XCTAssertEqual(geometries?[0]["coordinates"] as? [Double], MockData.point.geoJsonCoordinates as? [Double])
        XCTAssertEqual(geometries?[1]["type"] as? String, "MultiPoint")
        XCTAssertEqual(geometries?[1]["coordinates"] as? [[Double]], MockData.points.compactMap { $0.geoJsonCoordinates as? [Double] })
        XCTAssertEqual(geometries?[2]["type"] as? String, "LineString")
        XCTAssertEqual(geometries?[2]["coordinates"] as? [[Double]], MockData.points.compactMap { $0.geoJsonCoordinates as? [Double] })
        XCTAssertEqual(geometries?[3]["type"] as? String, "MultiLineString")
        XCTAssertEqual(geometries?[3]["coordinates"] as? [[[Double]]], MockData.lineStrings.compactMap { $0.geoJsonCoordinates as? [[Double]] })
        XCTAssertEqual(geometries?[4]["type"] as? String, "Polygon")
        XCTAssertEqual(geometries?[4]["coordinates"] as? [[[Double]]], MockData.linearRings.compactMap { $0.geoJsonCoordinates as? [[Double]] })
        XCTAssertEqual(geometries?[5]["type"] as? String, "MultiPolygon")
        XCTAssertEqual(geometries?[5]["coordinates"] as? [[[[Double]]]], MockData.polygons.compactMap { $0.geoJsonCoordinates as? [[[Double]]] })
    }
    
    func testObjectDistance() {
        // SOMEDAY: Test me.
    }
    
    func testContains() {
        // SOMEDAY: Test me.
    }
    
    func testContainsWithTolerance() {
        // SOMEDAY: Test me.
    }
    
    // GeometryCollection Tests
    
    func testEquals() {
        XCTAssertEqual(geometryCollection, geometryCollection)
    }
    
    func testNotEquals_Geometries_Versus_Nil() {
        XCTAssertNotEqual(geometryCollection, nilGeometryCollection)
    }
    
    func testEquals_NoGeometries_Versus_NoGeometries() {
        XCTAssertEqual(GeoTestHelper.geometryCollection(nil), GeoTestHelper.geometryCollection(nil))
    }
    
    func testNotEquals_Geometries_Versus_NilGeometries() {
        XCTAssertNotEqual(GeoTestHelper.geometryCollection([point]), GeoTestHelper.geometryCollection(nil))
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testNotEquals_DifferentGeometries() {
        let polygon = GeoTestHelper.polygon(GeoTestHelper.lineString([point, point, point, point]))
        
        XCTAssertNotEqual(geometryCollection, GeoTestHelper.geometryCollection([GeoTestHelper.multiPolygon([polygon, polygon])]))
    }
}
