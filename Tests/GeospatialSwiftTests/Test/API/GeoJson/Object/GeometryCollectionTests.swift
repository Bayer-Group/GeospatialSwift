import XCTest

@testable import GeospatialSwift

class GeometryCollectionTests: XCTestCase {
    var geometries: [GeoJsonGeometry]!
    var geometryCollection: GeometryCollection!
    var nilGeometryCollection: GeometryCollection?
    var distancePoint: SimplePoint!
    
    var point: GeoJsonPoint!
    
    override func setUp() {
        super.setUp()
        
        geometries = MockData.geometries
        
        geometryCollection = GeoTestHelper.geometryCollection(geometries)
        
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
        XCTAssertTrue(geometryCollection.objectGeometries?[4] is GeospatialSwift.Polygon)
        XCTAssertTrue(geometryCollection.objectGeometries?[5] is MultiPolygon)
    }
    
    func testObjectBoundingBox() {
        let resultBoundingBox = geometryCollection.objectBoundingBox
        #if swift(>=4.1)
        let boundingBox = BoundingBox.best(geometryCollection.objectGeometries!.compactMap { $0.objectBoundingBox })
        #else
        let boundingBox = BoundingBox.best(geometryCollection.objectGeometries!.flatMap { $0.objectBoundingBox })
        #endif
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        let pointGeoJson = "[\"type\": \"Point\", \"coordinates\": [1.0, 2.0, 3.0]]"
        let multiPointGeoJson = "[\"type\": \"MultiPoint\", \"coordinates\": \(MockData.pointsCoordinatesJson)]"
        let lineStringGeoJson = "[\"type\": \"LineString\", \"coordinates\": \(MockData.pointsCoordinatesJson)]"
        let multiLineStringGeoJson = "[\"type\": \"MultiLineString\", \"coordinates\": \(MockData.lineStringsCoordinatesJson)]"
        let polygonGeoJson = "[\"type\": \"Polygon\", \"coordinates\": \(MockData.linearRingsCoordinatesJson)]"
        let multiPolygonGeoJson = "[\"type\": \"MultiPolygon\", \"coordinates\": \(MockData.polygonsCoordinatesJson)]"
        let geometriesGeoJson = "[\(pointGeoJson), \(multiPointGeoJson), \(lineStringGeoJson), \(multiLineStringGeoJson), \(polygonGeoJson), \(multiPolygonGeoJson)]"
        
        XCTAssertEqual(geometryCollection.geoJson.description, "[\"type\": \"GeometryCollection\", \"geometries\": \(geometriesGeoJson)]")
    }
    
    func testObjectDistance() {
        // TODO: Test me.
    }
    
    func testContains() {
        // TODO: Test me.
    }
    
    func testContainsWithErrorDistance() {
        // TODO: Test me.
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
    
    // TODO: Comparing the Json test data and this is confusing.
    func testNotEquals_DifferentGeometries() {
        let polygon = GeoTestHelper.polygon([GeoTestHelper.lineString([point, point, point, point])])
        
        XCTAssertNotEqual(geometryCollection, GeoTestHelper.geometryCollection([GeoTestHelper.multiPolygon([polygon, polygon])]))
    }
}
