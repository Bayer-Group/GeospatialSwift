import XCTest

@testable import GeospatialSwift

class PointTests: XCTestCase {
    var point: Point!
    var distancePoint: GeoJsonPoint!
    
    override func setUp() {
        super.setUp()
        
        point = MockData.point as? Point
        
        distancePoint = GeoTestHelper.point(10, 10, 10)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(point.type, .point)
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(point.objectGeometries as! [Point], point.geometries as! [Point])
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(point.coordinatesGeometries.count, 1)
        XCTAssertEqual(point.closedGeometries.count, 0)
        XCTAssertEqual(point.linearGeometries.count, 0)
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(point.objectBoundingBox as? BoundingBox, point.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(point.geoJson["type"] as? String, "Point")
        XCTAssertEqual(point.geoJson["coordinates"] as? [Double], MockData.point.geoJsonCoordinates as? [Double])
    }
    
    func testObjectDistance() {
        XCTAssertEqual(point.distance(to: distancePoint), point.distance(to: distancePoint))
    }
    
    func testContains_Same() {
        let contains = point.contains(point)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_Different() {
        let contains = point.contains(distancePoint)
        
        XCTAssertEqual(contains, false)
    }
    
    func testContains_NoTolerance() {
        let contains = point.contains(point, tolerance: 0.0)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_OutsideTolerance() {
        let contains = point.contains(distancePoint, tolerance: 1335387)
        
        XCTAssertEqual(contains, false)
    }
    
    func testContains_OnTolerance() {
        let contains = point.contains(distancePoint, tolerance: 1335387.647673850413412)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_InsideTolerance() {
        let contains = point.contains(distancePoint, tolerance: 1335388)
        
        XCTAssertEqual(contains, true)
    }
    
    // GeoJsonCoordinatesGeometry Tests
    
    func testGeoJsonCoordinates_WithAltitude() {
        let result = point.geoJsonCoordinates
        
        XCTAssertEqual(result.count, 3, "array of three when there is an altitude")
        XCTAssertEqual(result[0] as? Double, 1)
        XCTAssertEqual(result[1] as? Double, 2)
        XCTAssertEqual(result[2] as? Double, 3)
    }
    
    func testGeoJsonCoordinates_NoAltitude() {
        point = GeoTestHelper.point(1, 2)
        
        let result = point.geoJsonCoordinates
        
        XCTAssertEqual(result.count, 2, "array of two when there is no altitude")
        XCTAssertEqual(result[0] as? Double, 1)
        XCTAssertEqual(result[1] as? Double, 2)
    }
    
    func testGeometries() {
        XCTAssertEqual(point.geometries.count, 1)
        XCTAssertEqual(point, point.geometries.first as? Point)
    }
    
    func testBoundingBox() {
        let resultBoundingBox = point.boundingBox
        
        let boundingBox = BoundingBox(boundingCoordinates: (minLongitude: point.longitude, minLatitude: point.latitude, maxLongitude: point.longitude, maxLatitude: point.latitude))
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox)
    }
    
    func testDistance() {
        let distance = point.distance(to: distancePoint)
        
        AssertEqualAccuracy6(distance, 1335387.64767385)
    }
    
    func testDistance_Self() {
        let distance = point.distance(to: point)
        
        AssertEqualAccuracy10(distance, 0.0)
    }
    
    func testDistance_NoTolerance() {
        let distance = point.distance(to: distancePoint, tolerance: 0.0)
        
        AssertEqualAccuracy6(distance, 1335387.64767385)
    }
    
    func testDistance_OutsideTolerance() {
        let distance = point.distance(to: distancePoint, tolerance: 1335387)
        
        AssertEqualAccuracy6(distance, 0.647673850413412)
    }
    
    func testDistance_OnTolerance() {
        let distance = point.distance(to: distancePoint, tolerance: 1335387.647673850413412)
        
        AssertEqualAccuracy6(distance, 0.0)
    }
    
    func testDistance_InsideTolerance() {
        let distance = point.distance(to: distancePoint, tolerance: 1335735)
        
        AssertEqualAccuracy6(distance, 0.0)
    }
    
    // Point Tests
    
    func testDegreesToRadians() {
        let degreesPoint = GeoTestHelper.simplePoint(180, 180)
        let radiansPoint = degreesPoint.degreesToRadians
        
        AssertEqualAccuracy10(radiansPoint.latitude, Double.pi)
        AssertEqualAccuracy10(radiansPoint.longitude, Double.pi)
    }
    
    func testRadiansToDegrees() {
        let radiansPoint = GeoTestHelper.simplePoint(.pi, .pi)
        let degreesPoint = radiansPoint.radiansToDegrees
        
        AssertEqualAccuracy10(degreesPoint.latitude, 180.0)
        AssertEqualAccuracy10(degreesPoint.longitude, 180.0)
    }
    
    func testNormalize_StaysSame() {
        let point = GeoTestHelper.point(1, 1)
        
        let normalizedPoint = point.normalize
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 1.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 1.0)
    }
    
    func testNormalize_StaysSame_AlmostMax() {
        let point = GeoTestHelper.point(179, 89)
        
        let normalizedPoint = point.normalize
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 179.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 89.0)
    }
    
    func testNormalize_StaysSame_Max() {
        let point = GeoTestHelper.point(180, 90)
        
        let normalizedPoint = point.normalize
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 180.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 90.0)
    }
    
    func testNormalize_Changes_Min() {
        let point = GeoTestHelper.point(-180, -90)
        
        let normalizedPoint = point.normalize
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 180.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 90.0)
    }
    
    func testNormalize_Changes_PastMin() {
        let point = GeoTestHelper.point(-181, -91)
        
        let normalizedPoint = point.normalize
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 179.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 89.0)
    }
    
    func testNormalize_Changes_PastMax() {
        let point = GeoTestHelper.point(181, 91)
        
        let normalizedPoint = point.normalize
        
        AssertEqualAccuracy10(normalizedPoint.longitude, -179.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, -89.0)
    }
    
    func testNormalizePostitive_StaysSame_Min() {
        let point = GeoTestHelper.point(0, 0)
        
        let normalizedPoint = point.normalizePostitive
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 0.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 0.0)
    }
    
    func testNormalizePostitive_StaysSame() {
        let point = GeoTestHelper.point(1, 1)
        
        let normalizedPoint = point.normalizePostitive
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 1.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 1.0)
    }
    
    func testNormalizePostitive_StaysSame_AlmostMax() {
        let point = GeoTestHelper.point(359, 179)
        
        let normalizedPoint = point.normalizePostitive
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 359.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 179.0)
    }
    
    func testNormalizePostitive_Negative_Changes() {
        let point = GeoTestHelper.point(-1, -1)
        
        let normalizedPoint = point.normalizePostitive
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 359.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 179.0)
    }
    
    func testNormalizePostitive_Changes_Max() {
        let point = GeoTestHelper.point(360, 180)
        
        let normalizedPoint = point.normalizePostitive
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 0.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 0.0)
    }
    
    func testEquals() {
        XCTAssertEqual(point, point)
    }
    
    func testEquals_Normalizes() {
        let point = GeoTestHelper.point(-540, 270)
        let otherPoint = GeoTestHelper.point(540, -270)
        
        XCTAssertEqual(point, otherPoint)
    }
    
    func testNotEquals() {
        XCTAssertNotEqual(point, GeoTestHelper.point(0, 0, 0))
    }
    
    func testEquals_PrecisionInequality() {
        XCTAssertNotEqual(GeoTestHelper.point(-92.82512167000001, 10), GeoTestHelper.point(-92.82512167, 10))
    }
    
    func testEquals_MaxedOutPrecisionForDouble_ShowsEqual() {
        XCTAssertEqual(GeoTestHelper.point(-92.825121670000001, 10), GeoTestHelper.point(-92.82512167, 10))
    }
    
    func testNotEquals_AltitudeAndNoAltitude() {
        XCTAssertNotEqual(GeoTestHelper.point(0, 0), GeoTestHelper.point(0, 0, 0))
    }
    
    func testNotEquals_AltitudeAndNoAltitude_Alternate() {
        XCTAssertNotEqual(GeoTestHelper.point(0, 0, 1), GeoTestHelper.point(0, 0, nil))
    }
    
    func testNotEquals_AltitudeMatches() {
        XCTAssertEqual(GeoTestHelper.point(0, 0, 1), GeoTestHelper.point(0, 0, 1))
    }
    
    func testNotEquals_AltitudeDoesNotMatch() {
        XCTAssertNotEqual(GeoTestHelper.point(0, 0, 1), GeoTestHelper.point(0, 0, 0))
    }
}
