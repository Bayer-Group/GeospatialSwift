import XCTest

@testable import GeospatialSwift

class FeatureCollectionTests: XCTestCase {
    var features: [Feature]!
    var featureCollection: FeatureCollection!
    var featureCollectionNested: FeatureCollection!
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        features = MockData.features
        
        featureCollection = GeoTestHelper.featureCollection(features)
        
        featureCollectionNested = GeoTestHelper.featureCollection(features + [GeoTestHelper.feature(GeoTestHelper.geometryCollection(MockData.polygons))])
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(featureCollection.type, .featureCollection)
    }
    
    func testObjectGeometries() {
        XCTAssertEqual(featureCollection.objectGeometries?.count, 3)
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(featureCollection.coordinatesGeometries.count, 3)
        XCTAssertEqual(featureCollection.linearGeometries.count, 1)
        XCTAssertEqual(featureCollection.closedGeometries.count, 1)
        
        XCTAssertEqual(featureCollectionNested.coordinatesGeometries.count, 5)
        XCTAssertEqual(featureCollectionNested.linearGeometries.count, 1)
        XCTAssertEqual(featureCollectionNested.closedGeometries.count, 3)
    }
    
    func testObjectBoundingBox() {
        let resultBoundingBox = featureCollection.objectBoundingBox
        
        let boundingBox = GeodesicBoundingBox.best(featureCollection.features.compactMap { $0.geometry?.objectBoundingBox })
        
        XCTAssertEqual(resultBoundingBox, boundingBox)
    }
    
    func testGeoJson() {
        let features = (featureCollection.geoJson["features"] as? [[String: Any]])
        XCTAssertEqual(featureCollection.geoJson["type"] as? String, "FeatureCollection")
        XCTAssertEqual(features?.count, 3)
        XCTAssertEqual(features?[0]["type"] as? String, "Feature")
        XCTAssertEqual(features?[0]["properties"] as? NSNull, NSNull())
        let feature1 = features?[0]["geometry"] as? [String: Any]
        XCTAssertEqual(feature1?["type"] as? String, "Point")
        XCTAssertEqual(feature1?["coordinates"] as? [Double], MockData.point.geoJsonCoordinates as? [Double])
        
        XCTAssertEqual(features?[1]["type"] as? String, "Feature")
        XCTAssertEqual(features?[1]["properties"] as? NSNull, NSNull())
        let feature2 = features?[1]["geometry"] as? [String: Any]
        XCTAssertEqual(feature2?["type"] as? String, "LineString")
        XCTAssertEqual(feature2?["coordinates"] as? [[Double]], MockData.pointsCoordinatesJson)
        
        XCTAssertEqual(features?[2]["type"] as? String, "Feature")
        XCTAssertEqual(features?[2]["properties"] as? NSNull, NSNull())
        let feature3 = features?[2]["geometry"] as? [String: Any]
        XCTAssertEqual(feature3?["type"] as? String, "Polygon")
        XCTAssertEqual(feature3?["coordinates"] as? [[[Double]]], MockData.linearRingsCoordinatesJson)
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
    
    // Feature Collection Tests
    
    func testGeometry() {
        XCTAssertEqual(featureCollection.features.count, 3)
        
        XCTAssertTrue(featureCollection.features[0].geometry is Point)
        XCTAssertTrue(featureCollection.features[1].geometry is LineString)
        XCTAssertTrue(featureCollection.features[2].geometry is Polygon)
    }
    
    func testEquals() {
        XCTAssertEqual(featureCollection, featureCollection)
    }
    
    func testNotEquals_NilGeometry() {
        XCTAssertNotEqual(featureCollection, GeoTestHelper.featureCollection([GeoTestHelper.feature(nil, nil, nil)]))
    }
    
    func testNotEquals_DifferentFeature() {
        XCTAssertNotEqual(GeoTestHelper.featureCollection([GeoTestHelper.feature(GeoTestHelper.point(1, 2), nil, nil)]), GeoTestHelper.featureCollection([GeoTestHelper.feature(GeoTestHelper.point(1, 3), nil, nil)]))
    }
    
    func testNotEquals_DifferentFeatureCount() {
        let feature = GeoTestHelper.feature(nil, nil, nil)
        XCTAssertNotEqual(GeoTestHelper.featureCollection([feature, feature]), GeoTestHelper.featureCollection([feature]))
    }
}
