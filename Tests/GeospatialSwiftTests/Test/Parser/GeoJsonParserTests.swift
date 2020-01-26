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
        let result = geoJsonParser.geoJsonObject(fromGeoJson: [:])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid geoJson must have a \"type\" key"])
    }
    
    func testBadGeoJsonType() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Nothing"])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid GeoJson Geometry type: Nothing"])
    }
    
    func testPoint() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Point"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is Point)
        XCTAssertEqual((geoJsonObject as? Point)?.longitude, 100.0)
        XCTAssertEqual((geoJsonObject as? Point)?.latitude, 0.0)
        XCTAssertNil((geoJsonObject as? Point)?.altitude)
    }
    
    func testPoint_ValidatedJson() {
        let geoJson = MockData.testGeoJson("Point")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
        XCTAssertTrue(geoJsonObject is Point)
        XCTAssertEqual((geoJsonObject as? Point)?.longitude, 100.0)
        XCTAssertEqual((geoJsonObject as? Point)?.latitude, 0.0)
        XCTAssertNil((geoJsonObject as? Point)?.altitude)
    }
    
    func testPointWithAltitude() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Point", "coordinates": [1, 2, 3]])
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is Point)
        XCTAssertEqual((geoJsonObject as? Point)?.longitude, 1)
        XCTAssertEqual((geoJsonObject as? Point)?.latitude, 2)
        XCTAssertEqual((geoJsonObject as? Point)?.altitude, 3)
    }
    
    func testPointNoCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Point", "coordinates": NSNull()])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid GeoJson Coordinates Geometry must have a valid \"coordinates\" array"])
    }
    
    func testPointBadCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Point", "coordinates": [1]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid Point must have at least a longitude and latitude"])
    }
    
    func testMultiPoint() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("MultiPoint"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
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
        let geoJson = MockData.testGeoJson("MultiPoint")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
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
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPoint", "coordinates": []])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid MultiPoint must have at least one Point"])
    }
    
    func testMultiPointBadCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPoint", "coordinates": [[""]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid Point(s) in MultiPoint", "A valid Point must have at least a longitude and latitude"])
    }
    
    func testLineString() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("LineString"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
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
        let geoJson = MockData.testGeoJson("LineString")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
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
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "LineString", "coordinates": []])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid LineString must have at least two Points"])
    }
    
    func testLineStringNotEnoughCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "LineString", "coordinates": [[0, 1]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid LineString must have at least two Points"])
    }
    
    func testLineStringBadCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "LineString", "coordinates": [[""], [""]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid Point(s) in LineString", "A valid Point must have at least a longitude and latitude", "A valid Point must have at least a longitude and latitude"])
    }
    
    func testMultiLineString() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("MultiLineString"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is MultiLineString)
        XCTAssertEqual((geoJsonObject as? MultiLineString)?.lines.count, 2)
    }
    
    func testMultiLineString_ValidatedJson() {
        let geoJson = MockData.testGeoJson("MultiLineString")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
        XCTAssertTrue(geoJsonObject is MultiLineString)
        XCTAssertEqual((geoJsonObject as? MultiLineString)?.lines.count, 2)
    }
    
    func testMultiLineStringNoCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiLineString", "coordinates": []])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid MultiLineString must have at least one LineString"])
    }
    
    func testMultiLineStringNotEnoughCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiLineString", "coordinates": [[[0, 1]]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid LineString(s) in MultiLineString", "A valid LineString must have at least two Points"])
    }
    
    func testMultiLineStringBadCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiLineString", "coordinates": [[""], [""]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid LineString(s) in MultiLineString", "A valid LineString must have valid coordinates", "A valid LineString must have valid coordinates"])
    }
    
    func testPolygon() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Polygon"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is Polygon)
        XCTAssertEqual((geoJsonObject as? Polygon)?.linearRings.count, 1)
    }
    
    func testPolygon_ValidatedJson() {
        let geoJson = MockData.testGeoJson("Polygon")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
        XCTAssertTrue(geoJsonObject is Polygon)
        XCTAssertEqual((geoJsonObject as? Polygon)?.linearRings.count, 1)
    }
    
    func testPolygonMultipleRings() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Polygon: Multiple Rings"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is Polygon)
        XCTAssertEqual((geoJsonObject as? Polygon)?.linearRings.count, 2)
    }
    
    func testPolygonNoCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Polygon", "coordinates": []])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid Polygon must have at least one LinearRing"])
    }
    
    func testPolygonNotEnoughCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Polygon", "coordinates": [[[]]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid LinearRing(s) in Polygon", "A valid LinearRing must have at least 4 points"])
    }
    
    func testPolygonBadCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Polygon", "coordinates": [[[""], [""]]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid LinearRing(s) in Polygon", "A valid LinearRing must have valid coordinates"])
    }
    
    func testPolygonNotALinearRing() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Polygon", "coordinates": [[[0, 1], [0, 2], [0, 3], [0, 4]]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid LinearRing(s) in Polygon", "A valid LinearRing must have valid coordinates"])
    }
    
    func testMultiPolygon() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("MultiPolygon"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is MultiPolygon)
        XCTAssertEqual((geoJsonObject as? MultiPolygon)?.polygons.count, 2)
    }
    
    func testMultiPolygon_ValidatedJson() {
        let geoJson = MockData.testGeoJson("MultiPolygon")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
        XCTAssertTrue(geoJsonObject is MultiPolygon)
        XCTAssertEqual((geoJsonObject as? MultiPolygon)?.polygons.count, 2)
    }
    
    func testMultiPolygonNoCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPolygon", "coordinates": []])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid FeatureCollection must have at least one feature"])
    }
    
    func testMultiPolygonNotEnoughCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPolygon", "coordinates": [[[[]]]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid Polygon(s) in MultiPolygon", "Invalid LinearRing(s) in Polygon", "A valid LinearRing must have at least 4 points"])
    }
    
    func testMultiPolygonBadCoordinates() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "MultiPolygon", "coordinates": [[[[""], [""]]]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid Polygon(s) in MultiPolygon", "Invalid LinearRing(s) in Polygon", "A valid LinearRing must have valid coordinates"])
    }
    
    func testGeometryCollection() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("GeometryCollection"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is GeometryCollection)
        XCTAssertNotNil((geoJsonObject as? GeometryCollection)?.objectGeometries)
        XCTAssertEqual((geoJsonObject as? GeometryCollection)?.objectGeometries.count, 2)
    }
    
    func testGeometryCollection_ValidatedJson() {
        let geoJson = MockData.testGeoJson("GeometryCollection")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
        XCTAssertTrue(geoJsonObject is GeometryCollection)
        XCTAssertNotNil((geoJsonObject as? GeometryCollection)?.objectGeometries)
        XCTAssertEqual((geoJsonObject as? GeometryCollection)?.objectGeometries.count, 2)
    }
    
    func testGeometryCollectionEmptyGeometries() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("GeometryCollection: Empty geometries"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is GeometryCollection)
        XCTAssertEqual((geoJsonObject as? GeometryCollection)?.objectGeometries.count ?? -1, 0)
    }
    
    func testGeometryCollectionNoGeometriesKey() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "GeometryCollection"])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid GeometryCollection must have a \"geometries\" key"])
    }
    
    func testGeometryCollectionBadGeometry() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "GeometryCollection", "geometries": [["type": "Point", "coordinates": [1]]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid Geometry(s) in GeometryCollection", "A valid Point must have at least a longitude and latitude"])
    }
    
    func testFeature() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Feature"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is Feature)
        XCTAssertTrue((geoJsonObject as? Feature)?.geometry is Polygon)
        XCTAssertEqual((geoJsonObject as? Feature)?.idAsString, "12345")
        XCTAssertEqual((geoJsonObject as? Feature)?.properties?["prop0"] as? String, "value0")
        XCTAssertEqual(((geoJsonObject as? Feature)?.properties?["prop1"] as? [String: String])?["this"], "that")
    }
    
    func testFeature_ValidatedJson() {
        let geoJson = MockData.testGeoJson("Feature")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
        XCTAssertTrue(geoJsonObject is Feature)
        XCTAssertTrue((geoJsonObject as? Feature)?.geometry is Polygon)
        XCTAssertEqual((geoJsonObject as? Feature)?.idAsString, "12345")
        XCTAssertEqual((geoJsonObject as? Feature)?.properties?["prop0"] as? String, "value0")
        XCTAssertEqual(((geoJsonObject as? Feature)?.properties?["prop1"] as? [String: String])?["this"], "that")
    }
    
    func testFeatureGeometryCollection() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Feature: Geometry Collection"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is Feature)
        XCTAssertTrue((geoJsonObject as? Feature)?.geometry is GeometryCollection)
    }
    
    func testFeatureNullGeometry() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("Feature: null geometry"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is Feature)
        XCTAssertNil((geoJsonObject as? Feature)?.geometry)
        XCTAssertNil((geoJsonObject as? Feature)?.id)
        XCTAssertNil((geoJsonObject as? Feature)?.properties)
    }
    
    func testFeatureNoGeometryKey() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Feature"])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid Feature must have a \"geometry\" key"])
    }
    
    func testFeatureBadGeometry() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "Feature", "geometry": ["type": "Point", "coordinates": [1]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid Geometry in Feature", "A valid Point must have at least a longitude and latitude"])
    }
    
    func testFeatureCollection() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("FeatureCollection"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is FeatureCollection)
        XCTAssertEqual((geoJsonObject as? FeatureCollection)?.features.count, 3)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[0].geometry is Point)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[1].geometry is LineString)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[2].geometry is Polygon)
    }
    
    func testFeatureCollection_ValidatedJson() {
        let geoJson = MockData.testGeoJson("FeatureCollection")
        
        let isGeoJsonValid = geoJsonParser.validate(geoJson: geoJson) == nil
        
        guard isGeoJsonValid else { XCTFail("ValidatedJson"); return }
        
        let geoJsonObject = geoJsonParser.geoJsonObject(fromValidatedGeoJson: geoJson)
        
        XCTAssertTrue(geoJsonObject is FeatureCollection)
        XCTAssertEqual((geoJsonObject as? FeatureCollection)?.features.count, 3)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[0].geometry is Point)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[1].geometry is LineString)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[2].geometry is Polygon)
    }
    
    func testFeatureCollection2Features1NullGeometry() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("FeatureCollection: 2 Features, 1 null geometry"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is FeatureCollection)
        XCTAssertEqual((geoJsonObject as? FeatureCollection)?.features.count, 2)
        XCTAssertNil((geoJsonObject as? FeatureCollection)?.features[0].geometry)
        XCTAssertTrue((geoJsonObject as? FeatureCollection)?.features[1].geometry is LineString)
    }
    
    func testFeatureCollection1FeatureNullGeometry() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: MockData.testGeoJson("FeatureCollection: 1 Feature, null geometry"))
        
        guard case .success(let geoJsonObject) = result else { XCTFail("Failed to parse GeoJson"); return }
        
        XCTAssertTrue(geoJsonObject is FeatureCollection)
        XCTAssertEqual((geoJsonObject as? FeatureCollection)?.features.count, 1)
        XCTAssertNil((geoJsonObject as? FeatureCollection)?.features[0].geometry)
    }
    
    func testFeatureCollectionNoFeaturesKey() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "FeatureCollection"])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["A valid FeatureCollection must have a \"features\" key"])
    }
    
    func testFeatureCollectionBadFeature() {
        let result = geoJsonParser.geoJsonObject(fromGeoJson: ["type": "FeatureCollection", "features": [["": ""]]])
        
        guard case .failure(let invalidGeoJson) = result else { XCTFail("Successfully parsed invalid GeoJson"); return }
        
        XCTAssertEqual(invalidGeoJson.reasons, ["Invalid Feature(s) in FeatureCollection", "A valid geoJson must have a \"type\" key"])
    }
    
    func testAllMockData() {
        XCTAssertEqual(MockData.geoJsonTestData.count, 15)
        
        var success = true
        MockData.geoJsonTestData.forEach { geoJsonData in
            // swiftlint:disable:next force_cast
            let result = geoJsonParser.geoJsonObject(fromGeoJson: geoJsonData["geoJson"] as! GeoJsonDictionary)
            
            if case .failure = result {
                XCTFail("Failed to parse GeoJson")
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
