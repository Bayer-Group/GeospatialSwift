import XCTest

@testable import GeospatialSwift

class FeatureTests: XCTestCase {
    var geometry: GeoJsonGeometry!
    var feature: Feature!
    var featureNested: Feature!
    var featureWithPoint: Feature!
    var featureEmpty: Feature!
    var featureWithId1: Feature!
    var featureWithId2: Feature!
    var featureWithProperties1: Feature!
    var featureWithProperties2: Feature!
    var featureWithProperties1Mixed: Feature!
    
    var point: GeoJson.Point!
    
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        geometry = GeoTestHelper.multiPolygon(MockData.polygons)
        
        let properties: GeoJsonDictionary = ["property1": "value1", "property2": ["key": "value"]]
        feature = GeoTestHelper.feature(geometry, "12345", properties)
        
        featureNested = GeoTestHelper.feature(GeoTestHelper.geometryCollection([geometry, geometry]))
        
        featureEmpty = GeoTestHelper.feature(nil, nil, nil)
        
        featureWithId1 = GeoTestHelper.feature(nil, "1", nil)
        featureWithId2 = GeoTestHelper.feature(nil, "2", nil)
        
        featureWithProperties1 = GeoTestHelper.feature(nil, nil, ["a": "b", "c": "d"])
        featureWithProperties2 = GeoTestHelper.feature(nil, nil, ["a": "b"])
        
        featureWithProperties1Mixed = GeoTestHelper.feature(nil, nil, ["c": "d", "a": "b"])
        
        point = GeoTestHelper.point(0, 0, 0)
        
        featureWithPoint = GeoTestHelper.feature(point, nil, nil)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(feature.type, .feature)
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(feature.objectGeometries as! [MultiPolygon], [feature.geometry as! MultiPolygon])
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(feature.coordinatesGeometries.count, 1)
        XCTAssertEqual(feature.linearGeometries.count, 0)
        XCTAssertEqual(feature.closedGeometries.count, 1)
        
        XCTAssertEqual(featureEmpty.coordinatesGeometries.count, 0)
        XCTAssertEqual(featureEmpty.linearGeometries.count, 0)
        XCTAssertEqual(featureEmpty.closedGeometries.count, 0)
        
        XCTAssertEqual(featureNested.coordinatesGeometries.count, 2)
        XCTAssertEqual(featureNested.linearGeometries.count, 0)
        XCTAssertEqual(featureNested.closedGeometries.count, 2)
    }
    
    func testObjectBoundingBox() {
        let resultBoundingBox = feature.objectBoundingBox
        let boundingBox = GeodesicBoundingBox.best([feature.geometry!.objectBoundingBox!])
        
        XCTAssertEqual(resultBoundingBox, boundingBox)
        
        XCTAssertNil(featureEmpty.objectBoundingBox)
    }
    
    func testGeoJson() {
        let properties = feature.geoJson["properties"] as? [String: Any]
        let geometry = feature.geoJson["geometry"] as? [String: Any]
        XCTAssertEqual(feature.geoJson["type"] as? String, "Feature")
        XCTAssertEqual(feature.geoJson["id"] as? String, "12345")
        XCTAssertEqual(properties?["property1"] as? String, "value1")
        XCTAssertEqual(properties?["property2"] as? [String: String], ["key": "value"])
        XCTAssertEqual(geometry?["type"] as? String, "MultiPolygon")
        XCTAssertEqual(geometry?["coordinates"] as? [[[[Double]]]], MockData.polygons.compactMap { $0.geoJsonCoordinates as? [[[Double]]] })
        
        XCTAssertEqual(featureEmpty.geoJson["type"] as? String, "Feature")
        XCTAssertEqual(featureEmpty.geoJson["geometry"] as? NSNull, NSNull())
        XCTAssertEqual(featureEmpty.geoJson["properties"] as? NSNull, NSNull())
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
    
    // Feature Tests
    
    func testId() {
        // SOMEDAY: Test me.
    }
    
    func testIdAsString() {
        // SOMEDAY: Test me.
    }
    
    func testProperties() {
        // SOMEDAY: Test me.
    }
    
    func testGeometry() {
        XCTAssertTrue(feature.geometry is MultiPolygon)
        
        XCTAssertNil(featureEmpty.geometry)
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testEquals() {
        XCTAssertEqual(feature, feature)
        
        XCTAssertEqual(featureEmpty, featureEmpty)
        
        XCTAssertEqual(featureWithId1, featureWithId1)
        XCTAssertEqual(featureWithProperties1, featureWithProperties1Mixed)
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testNotEquals() {
        XCTAssertNotEqual(feature, featureWithPoint)
        
        XCTAssertNotEqual(featureWithId1, featureWithId2)
        XCTAssertNotEqual(featureWithProperties1, featureWithProperties2)
        
        XCTAssertNotEqual(featureEmpty, featureWithPoint)
        XCTAssertNotEqual(featureEmpty, featureWithProperties1)
        XCTAssertNotEqual(featureEmpty, featureWithId1)
    }
}
