import XCTest

@testable import GeospatialSwift

class PointTests: XCTestCase {
    var point: Point!
    var distancePoint: GeoJsonPoint!
    
    override func setUp() {
        super.setUp()
        
        point = GeoTestHelper.point(1, 2, 3)
        
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
        XCTAssertEqual(point.multiCoordinatesGeometries.count, 0)
        XCTAssertEqual(point.closedGeometries.count, 0)
        XCTAssertEqual(point.linearGeometries.count, 0)
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(point.objectBoundingBox as? BoundingBox, point.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(point.geoJson.description, "[\"type\": \"Point\", \"coordinates\": [1.0, 2.0, 3.0]]")
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
    
    func testContains_NoErrorDistance() {
        let contains = point.contains(point, errorDistance: 0.0)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_OutsideErrorDistance() {
        let contains = point.contains(distancePoint, errorDistance: 1335734)
        
        XCTAssertEqual(contains, false)
    }
    
    func testContains_OnErrorDistance() {
        let contains = point.contains(distancePoint, errorDistance: 1335734.603511751163751)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_InsideErrorDistance() {
        let contains = point.contains(distancePoint, errorDistance: 1335735)
        
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
        
        AssertEqualAccuracy6(distance, 1335734.60351175)
    }
    
    func testDistance_Self() {
        let distance = point.distance(to: point)
        
        AssertEqualAccuracy10(distance, 0.0)
    }
    
    func testDistance_NoErrorDistance() {
        let distance = point.distance(to: distancePoint, errorDistance: 0.0)
        
        AssertEqualAccuracy6(distance, 1335734.60351175)
    }
    
    func testDistance_OutsideErrorDistance() {
        let distance = point.distance(to: distancePoint, errorDistance: 1335734)
        
        AssertEqualAccuracy6(distance, 0.603511751163751)
    }
    
    func testDistance_OnErrorDistance() {
        let distance = point.distance(to: distancePoint, errorDistance: 1335734.60351175069809)
        
        AssertEqualAccuracy6(distance, 0.0)
    }
    
    func testDistance_InsideErrorDistance() {
        let distance = point.distance(to: distancePoint, errorDistance: 1335735)
        
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
        let normalizedPoint = point.normalize
        
        AssertEqualAccuracy10(normalizedPoint.longitude, point.longitude)
        AssertEqualAccuracy10(normalizedPoint.latitude, point.latitude)
    }
    
    func testNormalize_Changes() {
        let point = GeoTestHelper.point(-540, 270)
        
        let normalizedPoint = point.normalize
        
        AssertEqualAccuracy10(normalizedPoint.longitude, 180.0)
        AssertEqualAccuracy10(normalizedPoint.latitude, 90.0)
    }
    
    func testInitialBearing() {
        let bearing = point.initialBearing(to: distancePoint)
        
        AssertEqualAccuracy10(bearing, 47.8193763709035)
    }
    
    func testInitialBearing_Reverse() {
        let bearing = distancePoint.initialBearing(to: point)
        
        AssertEqualAccuracy10(bearing, 228.764352221902)
    }
    
    func testAverageBearing() {
        let bearing = point.averageBearing(to: distancePoint)
        
        AssertEqualAccuracy10(bearing, 48.1320345260737)
    }
    
    func testAverageBearing_Reverse() {
        let bearing = distancePoint.averageBearing(to: point)
        
        AssertEqualAccuracy10(bearing, 228.132034526074)
    }
    
    func testFinalBearing() {
        let bearing = point.finalBearing(to: distancePoint)
        
        AssertEqualAccuracy10(bearing, 48.7643522219023)
    }
    
    func testFinalBearing_Reverse() {
        let bearing = distancePoint.finalBearing(to: point)
        
        AssertEqualAccuracy10(bearing, 227.819376370904)
    }
    
    func testMidpoint() {
        let midpoint = point.midpoint(with: distancePoint)
        
        AssertEqualAccuracy10(midpoint.latitude, 6.01841622677193)
        AssertEqualAccuracy10(midpoint.longitude, 5.46685861298068)
    }
    
    func testEquals() {
        XCTAssertEqual(point, point)
    }
    
    func testEquals_Normalizes() {
        let point1 = GeoTestHelper.point(-540, 270)
        let point2 = GeoTestHelper.point(540, -270)
        
        XCTAssertEqual(point1, point2)
    }
    
    func testNotEquals() {
        XCTAssertNotEqual(point, GeoTestHelper.point(0, 0, 0))
    }
}
