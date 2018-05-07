import XCTest

@testable import GeospatialSwift

class WktParserTests: XCTestCase {
    var geoJson: GeoJsonProtocol!
    
    let wktTestData = MockData.wktTestData
    
    var wktParser: WktParser!
    
    override func setUp() {
        super.setUp()
        
        geoJson = GeoJson(logger: MockLogger(), geodesicCalculator: MockGeodesicCalculator())
        
        wktParser = WktParser(logger: MockLogger(), geoJson: geoJson)
    }
    
    func testEmptyWkt() {
        let geoJsonObject = wktParser.geoJsonObject(from: "")
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testPoint() {
        let geoJsonObject = wktParser.geoJsonObject(from: MockData.testWkt("Point"))
        
        XCTAssertTrue(geoJsonObject is Point)
        XCTAssertEqual((geoJsonObject as? Point)?.longitude, 30.0)
        XCTAssertEqual((geoJsonObject as? Point)?.latitude, 10.0)
        XCTAssertNil((geoJsonObject as? Point)?.altitude)
    }
    
    func testMultiPoint_Unsupported() {
        let geoJsonObject = wktParser.geoJsonObject(from: MockData.testWkt("Unsupported MultiPoint"))
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testMultiPointAlternative_Unsupported() {
        let geoJsonObject = wktParser.geoJsonObject(from: MockData.testWkt("Unsupported MultiPoint Alternative"))
        
        XCTAssertNil(geoJsonObject)
    }
    
    func testLineString() {
        let geoJsonObject = wktParser.geoJsonObject(from: MockData.testWkt("LineString"))
        
        XCTAssertTrue(geoJsonObject is LineString)
        XCTAssertEqual((geoJsonObject as? LineString)?.points.count, 3)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[0].longitude, 30.0)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[0].longitude, 30.0)
        XCTAssertNil((geoJsonObject as? LineString)?.points[0].altitude)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[1].longitude, 10.0)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[1].longitude, 10.0)
        XCTAssertNil((geoJsonObject as? LineString)?.points[1].altitude)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[2].longitude, 40.0)
        XCTAssertEqual((geoJsonObject as? LineString)?.points[2].longitude, 40.0)
        XCTAssertNil((geoJsonObject as? LineString)?.points[2].altitude)
    }
    
    func testMultiLineString() {
        let geoJsonObject = wktParser.geoJsonObject(from: MockData.testWkt("MultiLineString"))
        
        XCTAssertTrue(geoJsonObject is MultiLineString)
    }
    
    func testPolygon() {
        let geoJsonObject = wktParser.geoJsonObject(from: MockData.testWkt("Polygon"))
        
        XCTAssertTrue(geoJsonObject is GeospatialSwift.Polygon)
    }
    
    func testMultiPolygon() {
        let geoJsonObject = wktParser.geoJsonObject(from: MockData.testWkt("MultiPolygon"))
        
        XCTAssertTrue(geoJsonObject is MultiPolygon)
    }
    
    // TODO: A ton of other unsupported tests.
    
    func testAllMockData() {
        XCTAssertEqual(wktTestData.count, 21)
        
        wktTestData.forEach { wktData in
            // TODO: Lots of Unsupported types, check WktTestData.json for names with prefix "Unsupported"
            guard !((wktData["name"] as? String)?.hasPrefix("Unsupported ") ?? false) else {
                wktParser.logger.warning("Test Unsupported: \(wktData["name"] ?? "")")
                return
            }
            
            // swiftlint:disable:next force_cast
            let geoJsonObject = wktParser.geoJsonObject(from: wktData["wkt"] as! String)
            
            XCTAssertNotNil(geoJsonObject)
            
            wktParser.logger.warning("Test \(geoJsonObject == nil ? "Failed" : "Passed"): \(wktData["name"] ?? "")")
        }
    }
}
