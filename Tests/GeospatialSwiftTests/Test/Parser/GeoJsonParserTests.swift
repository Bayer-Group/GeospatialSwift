import XCTest

@testable import GeospatialSwift

// swiftlint:disable type_body_length file_length
class GeoJsonParserTests: XCTestCase {
    var geoJsonParser: GeoJsonParser!
    
    override func setUp() {
        super.setUp()
        
        geoJsonParser = GeoJsonParser()
    }
    
    func testBadGeoJson() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: [:])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testBadGeoJsonType() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Nothing"])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testPoint() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Point"))
        
        XCTAssertTrue(geoJsonObject is Point)
        XCTAssertEqual((geoJsonObject as? Point)?.longitude, 100.0)
        XCTAssertEqual((geoJsonObject as? Point)?.latitude, 0.0)
        XCTAssertNil((geoJsonObject as? Point)?.altitude)
    }
    
    func testPoint_ValidatedJson() {
        let pointJson = MockData.testGeoJson("Point")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: pointJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: pointJson)
        
        XCTAssertTrue(geoJsonObject is Point)
        XCTAssertEqual((geoJsonObject as? Point)?.longitude, 100.0)
        XCTAssertEqual((geoJsonObject as? Point)?.latitude, 0.0)
        XCTAssertNil((geoJsonObject as? Point)?.altitude)
    }
    
    func testPointWithAltitude() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Point", "coordinates": [1, 2, 3]])
        
        XCTAssertTrue(geoJsonObject is Point)
        XCTAssertEqual((geoJsonObject as? Point)?.longitude, 1)
        XCTAssertEqual((geoJsonObject as? Point)?.latitude, 2)
        XCTAssertEqual((geoJsonObject as? Point)?.altitude, 3)
    }
    
    func testPointNoCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Point", "coordinates": NSNull()])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testPointBadCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Point", "coordinates": [1]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiPoint() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("MultiPoint"))
        
        XCTAssertTrue(geoJsonObject is MultiPoint)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points.count, 2)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points[0].longitude, 100.0)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points[0].longitude, 100.0)
        XCTAssertNil((geoJsonObject as? MultiPoint)?.points[0].altitude)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points[1].longitude, 101.0)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points[1].longitude, 101.0)
        XCTAssertNil((geoJsonObject as? MultiPoint)?.points[1].altitude)
    }
    
    func testMultiPoint_ValidatedJson() {
        let multiPointJson = MockData.testGeoJson("MultiPoint")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: multiPointJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: multiPointJson)
        
        XCTAssertTrue(geoJsonObject is MultiPoint)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points.count, 2)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points[0].longitude, 100.0)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points[0].longitude, 100.0)
        XCTAssertNil((geoJsonObject as? MultiPoint)?.points[0].altitude)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points[1].longitude, 101.0)
        XCTAssertEqual((geoJsonObject as? MultiPoint)?.points[1].longitude, 101.0)
        XCTAssertNil((geoJsonObject as? MultiPoint)?.points[1].altitude)
    }
    
    func testMultiPointNoCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPoint", "coordinates": []])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiPointBadCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPoint", "coordinates": [[""]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testLineString() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("LineString"))
        
        XCTAssertTrue(geoJsonObject is LineString)
        XCTAssertEqual((geoJsonObject as? LineString)?.points.count, 2)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[0].longitude, 100.0)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[0].longitude, 100.0)
        XCTAssertNil((geoJsonObject as? LineString)?.points[0].altitude)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[1].longitude, 101.0)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[1].longitude, 101.0)
        XCTAssertNil((geoJsonObject as? LineString)?.points[1].altitude)
    }
    
    func testLineString_ValidatedJson() {
        let lineStringJson = MockData.testGeoJson("LineString")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: lineStringJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: lineStringJson)
        
        XCTAssertTrue(geoJsonObject is LineString)
        XCTAssertEqual((geoJsonObject as? LineString)?.points.count, 2)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[0].longitude, 100.0)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[0].longitude, 100.0)
        XCTAssertNil((geoJsonObject as? LineString)?.points[0].altitude)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[1].longitude, 101.0)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[1].longitude, 101.0)
        XCTAssertNil((geoJsonObject as? LineString)?.points[1].altitude)
    }
    
    func testLineStringNoCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "LineString", "coordinates": []])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testLineStringNotEnoughCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "LineString", "coordinates": [[0, 1]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testLineStringBadCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "LineString", "coordinates": [[""], [""]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiLineString() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("MultiLineString"))
        
        XCTAssertTrue(geoJsonObject is MultiLineString)
        XCTAssertEqual((geoJsonObject as? MultiLineString)?.lineStrings.count, 2)
    }
    
    func testMultiLineString_ValidatedJson() {
        let multiLineStringJson = MockData.testGeoJson("MultiLineString")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: multiLineStringJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: multiLineStringJson)
        
        XCTAssertTrue(geoJsonObject is MultiLineString)
        XCTAssertEqual((geoJsonObject as? MultiLineString)?.lineStrings.count, 2)
    }
    
    func testMultiLineStringNoCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiLineString", "coordinates": []])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiLineStringNotEnoughCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiLineString", "coordinates": [[[0, 1]]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiLineStringBadCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiLineString", "coordinates": [[""], [""]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testPolygon() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Polygon"))
        
        XCTAssertTrue(geoJsonObject is Polygon)
        XCTAssertEqual((geoJsonObject as? Polygon)?.linearRings.count, 1)
    }
    
    func testPolygon_ValidatedJson() {
        let polygonJson = MockData.testGeoJson("Polygon")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: polygonJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: polygonJson)
        
        XCTAssertTrue(geoJsonObject is Polygon)
        XCTAssertEqual((geoJsonObject as? Polygon)?.linearRings.count, 1)
    }
    
    func testPolygonMultipleRings() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Polygon: Multiple Rings"))
        
        XCTAssertTrue(geoJsonObject is Polygon)
        XCTAssertEqual((geoJsonObject as? Polygon)?.linearRings.count, 2)
    }
    
    func testPolygonNoCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Polygon", "coordinates": []])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testPolygonNotEnoughCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Polygon", "coordinates": [[[]]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testPolygonBadCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Polygon", "coordinates": [[[""], [""]]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testPolygonNotALinearRing() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Polygon", "coordinates": [[[0, 1], [0, 2], [0, 3], [0, 4]]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiPolygon() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("MultiPolygon"))
        
        XCTAssertTrue(geoJsonObject is MultiPolygon)
        XCTAssertEqual((geoJsonObject as? MultiPolygon)?.polygons.count, 2)
    }
    
    func testMultiPolygon_ValidatedJson() {
        let multiPolygonJson = MockData.testGeoJson("MultiPolygon")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: multiPolygonJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: multiPolygonJson)
        
        XCTAssertTrue(geoJsonObject is MultiPolygon)
        XCTAssertEqual((geoJsonObject as? MultiPolygon)?.polygons.count, 2)
    }
    
    func testMultiPolygonNoCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPolygon", "coordinates": []])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiPolygonNotEnoughCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPolygon", "coordinates": [[[[]]]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiPolygonBadCoordinates() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPolygon", "coordinates": [[[[""], [""]]]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testGeometryCollection() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("GeometryCollection"))
        
        XCTAssertTrue(geoJsonObject is GeometryCollection)
        XCTAssertNotNil((geoJsonObject as? GeometryCollection)?.objectGeometries)
        XCTAssertEqual((geoJsonObject as? GeometryCollection)?.objectGeometries?.count, 2)
    }
    
    func testGeometryCollection_ValidatedJson() {
        let geometryCollectionJson = MockData.testGeoJson("GeometryCollection")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: geometryCollectionJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geometryCollectionJson)
        
        XCTAssertTrue(geoJsonObject is GeometryCollection)
        XCTAssertNotNil((geoJsonObject as? GeometryCollection)?.objectGeometries)
        XCTAssertEqual((geoJsonObject as? GeometryCollection)?.objectGeometries?.count, 2)
    }
    
    func testGeometryCollectionEmptyGeometries() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("GeometryCollection: Empty geometries"))
        
        XCTAssertTrue(geoJsonObject is GeometryCollection)
        XCTAssertEqual((geoJsonObject as? GeometryCollection)?.objectGeometries?.count ?? -1, 0)
    }
    
    func testGeometryCollectionNoGeometriesKey() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "GeometryCollection"])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testGeometryCollectionBadGeometry() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "GeometryCollection", "geometries": [["type": "Point", "coordinates": [1]]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testFeature() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Feature"))
        
        XCTAssertTrue(geoJsonObject is Feature)
        XCTAssertTrue((geoJsonObject as? Feature)?.geometry is Polygon)
        XCTAssertEqual((geoJsonObject as? Feature)?.idAsString, "12345")
        XCTAssertEqual((geoJsonObject as? Feature)?.properties?["prop0"] as? String, "value0")
        XCTAssertEqual(((geoJsonObject as? Feature)?.properties?["prop1"] as? [String: String])?["this"], "that")
    }
    
    func testFeature_ValidatedJson() {
        let featureJson = MockData.testGeoJson("Feature")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: featureJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: featureJson)
        
        XCTAssertTrue(geoJsonObject is Feature)
        XCTAssertTrue((geoJsonObject as? Feature)?.geometry is Polygon)
        XCTAssertEqual((geoJsonObject as? Feature)?.idAsString, "12345")
        XCTAssertEqual((geoJsonObject as? Feature)?.properties?["prop0"] as? String, "value0")
        XCTAssertEqual(((geoJsonObject as? Feature)?.properties?["prop1"] as? [String: String])?["this"], "that")
    }
    
    func testFeatureGeometryCollection() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Feature: Geometry Collection"))
        
        XCTAssertTrue(geoJsonObject is Feature)
        XCTAssertTrue((geoJsonObject as? Feature)?.geometry is GeometryCollection)
    }
    
    func testFeatureNullGeometry() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Feature: null geometry"))
        
        XCTAssertTrue(geoJsonObject is Feature)
        XCTAssertNil((geoJsonObject as? Feature)?.geometry)
        XCTAssertNil((geoJsonObject as? Feature)?.id)
        XCTAssertNil((geoJsonObject as? Feature)?.properties)
    }
    
    func testFeatureNoGeometryKey() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Feature"])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testFeatureBadGeometry() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Feature", "geometry": ["type": "Point", "coordinates": [1]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testFeatureCollection() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("FeatureCollection"))
        
        XCTAssertTrue(geoJsonObject is FeatureCollection)
        XCTAssertEqual((geoJsonObject as? FeatureCollection)?.features.count, 3)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[0].geometry is Point)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[1].geometry is LineString)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[2].geometry is Polygon)
    }
    
    func testFeatureCollection_ValidatedJson() {
        let featureCollectionJson = MockData.testGeoJson("FeatureCollection")
        
        let isGeoJsonValid = geoJsonParser.isGeoJsonValid(fromGeoJson: featureCollectionJson)
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: featureCollectionJson)
        
        XCTAssertTrue(geoJsonObject is FeatureCollection)
        XCTAssertEqual((geoJsonObject as? FeatureCollection)?.features.count, 3)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[0].geometry is Point)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[1].geometry is LineString)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[2].geometry is Polygon)
    }
    
    func testFeatureCollection2Features1NullGeometry() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("FeatureCollection: 2 Features, 1 null geometry"))
        
        XCTAssertTrue(geoJsonObject is FeatureCollection)
        XCTAssertEqual((geoJsonObject as? FeatureCollection)?.features.count, 2)
        XCTAssertNil((geoJsonObject as? FeatureCollection)?.features[0].geometry)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[1].geometry is LineString)
    }
    
    func testFeatureCollection1FeatureNullGeometry() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("FeatureCollection: 1 Feature, null geometry"))
        
        XCTAssertTrue(geoJsonObject is FeatureCollection)
        XCTAssertEqual((geoJsonObject as? FeatureCollection)?.features.count, 1)
        XCTAssertNil((geoJsonObject as? FeatureCollection)?.features[0].geometry)
    }
    
    func testFeatureCollectionNoFeaturesKey() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "FeatureCollection"])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testFeatureCollectionBadFeature() {
        let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "FeatureCollection", "features": [["": ""]]])
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testAllMockData() {
        XCTAssertEqual(MockData.geoJsonTestData.count, 15)
        
        var success = true
        MockData.geoJsonTestData.forEach { geoJsonData in
            // swiftlint:disable:next force_cast
            let geoJsonObject = geoJsonParser.geoJsonObject(fromGeoJson: geoJsonData["geoJson"] as! GeoJsonDictionary)
            
            XCTAssertNotNil(geoJsonObject)
            
            if geoJsonObject != nil {
                Log.warning("Test Passed: \(geoJsonData["name"] ?? "")")
            } else {
                success = false
            }
        }
        
        guard success else { XCTFail("AllMockData"); return }
        
        MockData.geoJsonTestData.forEach { geoJsonData in
            // swiftlint:disable:next force_cast
            let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJsonData["geoJson"] as! GeoJsonDictionary)
            
            XCTAssertNotNil(geoJsonObject)
        }
    }
}
