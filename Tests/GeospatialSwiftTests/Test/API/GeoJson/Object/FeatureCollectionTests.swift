import XCTest

@testable import GeospatialSwift

class FeatureCollectionTests: XCTestCase {
    var features: [Feature]!
    var featureCollection: FeatureCollection!
    var featureCollectionNested: FeatureCollection!
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        // swiftlint:disable:next force_cast
        features = MockData.features as! [Feature]
        
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
        XCTAssertEqual(featureCollection.multiCoordinatesGeometries.count, 2)
        XCTAssertEqual(featureCollection.linearGeometries.count, 1)
        XCTAssertEqual(featureCollection.closedGeometries.count, 1)
        
        XCTAssertEqual(featureCollectionNested.coordinatesGeometries.count, 5)
        XCTAssertEqual(featureCollectionNested.multiCoordinatesGeometries.count, 4)
        XCTAssertEqual(featureCollectionNested.linearGeometries.count, 1)
        XCTAssertEqual(featureCollectionNested.closedGeometries.count, 3)
    }
    
    func testObjectBoundingBox() {
        let resultBoundingBox = featureCollection.objectBoundingBox
        
        let boundingBox = BoundingBox.best(featureCollection.features.compactMap { $0.geometry?.objectBoundingBox })
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        let lineStringGeoJson = "[\"type\": \"LineString\", \"coordinates\": \(MockData.pointsCoordinatesJson)]"
        let polygonGeoJson = "[\"type\": \"Polygon\", \"coordinates\": \(MockData.linearRingsCoordinatesJson)]"
        let featureGeoJson1 = "[\"type\": \"Feature\", \"geometry\": [\"type\": \"Point\", \"coordinates\": [1.0, 2.0, 3.0]], \"properties\": <null>]"
        let featureGeoJson2 = "[\"type\": \"Feature\", \"geometry\": \(lineStringGeoJson), \"properties\": <null>]"
        let featureGeoJson3 = "[\"type\": \"Feature\", \"geometry\": \(polygonGeoJson), \"properties\": <null>]"
        let featuresGeoJson = "[\(featureGeoJson1), \(featureGeoJson2), \(featureGeoJson3)]"
        
        XCTAssertEqual(featureCollection.geoJson.description, "[\"type\": \"FeatureCollection\", \"features\": \(featuresGeoJson)]")
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
    
    // Feature Collection Tests
    
    func testGeometry() {
        XCTAssertEqual(featureCollection.features.count, 3)
        
        XCTAssertTrue(featureCollection.features[0].geometry is Point)
        XCTAssertTrue(featureCollection.features[1].geometry is LineString)
        XCTAssertTrue(featureCollection.features[2].geometry is GeospatialSwift.Polygon)
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
