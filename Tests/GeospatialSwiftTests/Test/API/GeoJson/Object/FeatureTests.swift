import XCTest

@testable import GeospatialSwift

class FeatureTests: XCTestCase {
    var geometry: GeoJsonGeometry!
    var feature: Feature!
    var featureWithPoint: Feature!
    var featureEmpty: Feature!
    var featureWithId1: Feature!
    var featureWithId2: Feature!
    var featureWithProperties1: Feature!
    var featureWithProperties2: Feature!
    var featureWithProperties1Mixed: Feature!
    
    var point: GeoJsonPoint!
    
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        geometry = GeoTestHelper.multiPolygon(MockData.polygons)
        
        let properties: GeoJsonDictionary = ["property1": "value1", "property2": ["key": "value"]]
        feature = GeoTestHelper.feature(geometry, "12345", properties)
        
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
    
    func testObjectBoundingBox() {
        let resultBoundingBox = feature.objectBoundingBox
        let boundingBox = BoundingBox.best([feature.geometry!.objectBoundingBox!])
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
        
        XCTAssertNil(featureEmpty.objectBoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(feature.geoJson.description, "[\"geometry\": [\"type\": \"MultiPolygon\", \"coordinates\": \(MockData.polygonsCoordinatesJson)], \"type\": \"Feature\", \"id\": \"12345\", \"properties\": [\"property2\": [\"key\": \"value\"], \"property1\": \"value1\"]]")
        
        XCTAssertEqual(featureEmpty.geoJson.description, "[\"type\": \"Feature\", \"geometry\": <null>, \"properties\": <null>]")
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
    
    // Feature Tests
    
    func testId() {
        // TODO: Test me.
    }
    
    func testIdAsString() {
        // TODO: Test me.
    }
    
    func testProperties() {
        // TODO: Test me.
    }
    
    func testGeometry() {
        XCTAssertTrue(feature.geometry is MultiPolygon)
        
        XCTAssertNil(featureEmpty.geometry)
    }
    
    // TODO: Comparing the Json test data and this is confusing.
    func testEquals() {
        XCTAssertEqual(feature, feature)
        
        XCTAssertEqual(featureEmpty, featureEmpty)
        
        XCTAssertEqual(featureWithId1, featureWithId1)
        XCTAssertEqual(featureWithProperties1, featureWithProperties1Mixed)
    }
    
    // TODO: Comparing the Json test data and this is confusing.
    func testNotEquals() {
        XCTAssertNotEqual(feature, featureWithPoint)
        
        XCTAssertNotEqual(featureWithId1, featureWithId2)
        XCTAssertNotEqual(featureWithProperties1, featureWithProperties2)
        
        XCTAssertNotEqual(featureEmpty, featureWithPoint)
        XCTAssertNotEqual(featureEmpty, featureWithProperties1)
        XCTAssertNotEqual(featureEmpty, featureWithId1)
    }
}
