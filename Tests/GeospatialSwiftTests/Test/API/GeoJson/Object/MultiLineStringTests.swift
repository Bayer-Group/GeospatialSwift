import XCTest

@testable import GeospatialSwift

class MultiLineStringTests: XCTestCase {
    var lineStrings: [LineString]!
    var selfIntersectingLineStrings: [LineString]!
    var selfCrossingLineStrings: [LineString]!
    var sharingStartAndEndLineStrings: [LineString]!
    var doubleNLineStrings: [LineString]!
    
    var multiLineString: MultiLineString!
    var selfIntersectingMultiLineString: MultiLineString!
    var selfCrossingMultiLineString: MultiLineString!
    var sharingStartAndEndMultiLineString: MultiLineString!
    var doubleNMultiLineString: MultiLineString!
    
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        lineStrings = MockData.lineStrings
        selfIntersectingLineStrings = MockData.selfIntersectingLineStrings
        selfCrossingLineStrings = MockData.selfCrossingLineStrings
        sharingStartAndEndLineStrings = MockData.sharingStartAndEndLineStrings
        doubleNLineStrings = MockData.doubleNLineStrings
        
        multiLineString = GeoTestHelper.multiLineString(lineStrings)
        selfIntersectingMultiLineString = GeoTestHelper.multiLineString(selfIntersectingLineStrings)
        selfCrossingMultiLineString = GeoTestHelper.multiLineString(selfCrossingLineStrings)
        sharingStartAndEndMultiLineString = GeoTestHelper.multiLineString(sharingStartAndEndLineStrings)
        doubleNMultiLineString = GeoTestHelper.multiLineString(doubleNLineStrings)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(multiLineString.type, .multiLineString)
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(multiLineString.objectGeometries as! [MultiLineString], multiLineString.geometries as! [MultiLineString])
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(multiLineString.coordinatesGeometries.count, 1)
        XCTAssertEqual(multiLineString.linearGeometries.count, 1)
        XCTAssertEqual(multiLineString.closedGeometries.count, 0)
    }
    
    func testMultiLineString_StartAndEndTouching_IsValid() {
        XCTAssertEqual(multiLineString.simpleViolations(tolerance: 0).count, 0)
    }
    
    func testMultiLineString_SharingStartAndEnd_IsValid() {
        XCTAssertEqual(sharingStartAndEndMultiLineString.simpleViolations(tolerance: 0).count, 0)
    }
    
    func testSelfInterSectingMultiLineString_IsInvalid() {
        let simpleViolations = selfIntersectingMultiLineString.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 2)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.multiLineIntersection)
        
        let problem0 = simpleViolations[0].problems
        XCTAssertEqual(problem0.count, 6)
        if let point0 = problem0[0] as? Point, let point1 = problem0[1] as? Point, let point2 = problem0[3] as? Point, let point3 = problem0[4] as? Point {
            XCTAssertEqual(point0.longitude, 21.0)
            XCTAssertEqual(point0.latitude, 20.0)
            XCTAssertEqual(point1.longitude, 20.0)
            XCTAssertEqual(point1.latitude, 21.0)
            XCTAssertEqual(point2.longitude, 19.0)
            XCTAssertEqual(point2.latitude, 20.0)
            XCTAssertEqual(point3.longitude, 23.0)
            XCTAssertEqual(point3.latitude, 20.0)
        } else {
            XCTFail("Geometry type is wrong")
        }
        
        let problem1 = simpleViolations[1].problems
        XCTAssertEqual(problem1.count, 6)
        if let point0 = problem1[0] as? Point, let point1 = problem1[1] as? Point, let point2 = problem1[3] as? Point, let point3 = problem1[4] as? Point {
            XCTAssertEqual(point0.longitude, 20.0)
            XCTAssertEqual(point0.latitude, 21.0)
            XCTAssertEqual(point1.longitude, 20.0)
            XCTAssertEqual(point1.latitude, 19.0)
            XCTAssertEqual(point2.longitude, 19.0)
            XCTAssertEqual(point2.latitude, 20.0)
            XCTAssertEqual(point3.longitude, 23.0)
            XCTAssertEqual(point3.latitude, 20.0)
        } else {
            XCTFail("Geometry type is wrong")
        }
        
    }
    
    func testSelfCrossingMultiLineString_IsInvalid() {
        let simpleViolations = selfCrossingMultiLineString.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 1)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.multiLineIntersection)
        
        let problem0 = simpleViolations[0].problems
        XCTAssertEqual(problem0.count, 6)
        if let point0 = problem0[0] as? Point, let point1 = problem0[1] as? Point, let point2 = problem0[3] as? Point, let point3 = problem0[4] as? Point {
            XCTAssertEqual(point0.longitude, 1.0)
            XCTAssertEqual(point0.latitude, -1.0)
            XCTAssertEqual(point1.longitude, 0.0)
            XCTAssertEqual(point1.latitude, 1.0)
            XCTAssertEqual(point2.longitude, 0.0)
            XCTAssertEqual(point2.latitude, 0.0)
            XCTAssertEqual(point3.longitude, 3.0)
            XCTAssertEqual(point3.latitude, 0.0)
        } else {
            XCTFail("Geometry type is wrong")
        }
    }
    
    func testDoubleNMultiLineString_IsInvalid() {
        let simpleViolations = doubleNMultiLineString.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 9)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.multiLineIntersection)
        
        let problem0 = simpleViolations[0].problems
        XCTAssertEqual(problem0.count, 6)
        if let point0 = problem0[0] as? Point, let point1 = problem0[1] as? Point, let point2 = problem0[3] as? Point, let point3 = problem0[4] as? Point {
            XCTAssertEqual(point0.longitude, 0.0)
            XCTAssertEqual(point0.latitude, 0.0)
            XCTAssertEqual(point1.longitude, 3.0)
            XCTAssertEqual(point1.latitude, 0.0)
            XCTAssertEqual(point2.longitude, 1.0)
            XCTAssertEqual(point2.latitude, -1.0)
            XCTAssertEqual(point3.longitude, 1.0)
            XCTAssertEqual(point3.latitude, 2.0)
        } else {
            XCTFail("Geometry type is wrong")
        }
    }
    
    
    func testObjectBoundingBox() {
        XCTAssertEqual(multiLineString.objectBoundingBox, multiLineString.boundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(multiLineString.geoJson["type"] as? String, "MultiLineString")
        XCTAssertEqual(multiLineString.geoJson["coordinates"] as? [[[Double]]], MockData.lineStringsCoordinatesJson)
    }
    
    func testObjectDistance() {
        XCTAssertEqual(multiLineString.distance(to: distancePoint), multiLineString.distance(to: distancePoint))
    }
    
    func testContains() {
        let point = multiLineString.points.first!
        
        XCTAssertEqual(multiLineString.contains(point), lineStrings.map { $0.contains(point) }.contains { $0 })
    }
    
    func testContains_DoesNot() {
        let point = distancePoint!
        
        XCTAssertEqual(multiLineString.contains(point), lineStrings.map { $0.contains(point) }.contains { $0 })
    }
    
    func testContains_WithTolerance() {
        let point = multiLineString.points.first!
        let tolerance = 0.0
        
        XCTAssertEqual(multiLineString.contains(point, tolerance: tolerance), lineStrings.map { $0.contains(point, tolerance: tolerance) }.contains { $0 })
    }
    
    func testContains_WithTolerance_Does_WithError() {
        let point = distancePoint!
        let tolerance = 200000000.0
        
        XCTAssertEqual(multiLineString.contains(point, tolerance: tolerance), lineStrings.map { $0.contains(point, tolerance: tolerance) }.contains { $0 })
    }
    
    func testContains_WithTolerance_DoesNot() {
        let point = distancePoint!
        let tolerance = 0.0
        
        XCTAssertEqual(multiLineString.contains(point, tolerance: tolerance), lineStrings.map { $0.contains(point, tolerance: tolerance) }.contains { $0 })
    }
    
    // GeoJsonCoordinatesGeometry Tests
    
    func testGeoJsonCoordinates() {
        let coordinates = multiLineString.geoJsonCoordinates
        
        XCTAssertTrue(coordinates is [[[Double]]])
        // swiftlint:disable force_cast
        XCTAssertEqual((coordinates as! [[[Double]]]).count, lineStrings.count )
        
        (coordinates as! [[[Double]]]).enumerated().forEach { lineStringsOffset, element in
            XCTAssertEqual(element.count, lineStrings[lineStringsOffset].points.count)
            element.enumerated().forEach { pointsOffset, element in
                XCTAssertEqual(element, (lineStrings[lineStringsOffset].points[pointsOffset] as! Point).geoJsonCoordinates as! [Double] )
            }
        }
        // swiftlint:enablce force_cast
    }
    
    func testGeometries() {
        XCTAssertEqual(multiLineString.geometries.count, 1)
        XCTAssertEqual(multiLineString, multiLineString.geometries[0] as? MultiLineString)
    }
    
    func testBoundingBox() {
        let resultBoundingBox = multiLineString.boundingBox
        
        let boundingBox = GeodesicBoundingBox.best(lineStrings.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox, boundingBox)
    }
    
    func testDistance_On() {
        let point = multiLineString.points.first!
        
        XCTAssertEqual(multiLineString.distance(to: point), lineStrings.map { $0.distance(to: point) }.reduce(Double.greatestFiniteMagnitude) { min($0, $1) })
    }
    
    func testDistance_Outside() {
        let point = distancePoint!
        
        XCTAssertEqual(multiLineString.distance(to: point), lineStrings.map { $0.distance(to: point) }.reduce(Double.greatestFiniteMagnitude) { min($0, $1) })
    }
    
    func testDistance_WithTolerance_On() {
        let point = multiLineString.points.first!
        let tolerance = 0.0
        
        XCTAssertEqual(multiLineString.distance(to: point, tolerance: tolerance), lineStrings.map { $0.distance(to: point, tolerance: tolerance) }.reduce(Double.greatestFiniteMagnitude) { min($0, $1) })
    }
    
    func testDistance_WithTolerance_On_WithError() {
        let point = distancePoint!
        let tolerance = 200000000.0
        
        XCTAssertEqual(multiLineString.distance(to: point, tolerance: tolerance), lineStrings.map { $0.distance(to: point, tolerance: tolerance) }.reduce(Double.greatestFiniteMagnitude) { min($0, $1) })
    }
    
    func testDistance_WithTolerance_Outside() {
        let point = distancePoint!
        let tolerance = 0.0
        
        XCTAssertEqual(multiLineString.distance(to: point, tolerance: tolerance), lineStrings.map { $0.distance(to: point, tolerance: tolerance) }.reduce(Double.greatestFiniteMagnitude) { min($0, $1) })
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    func testPoints() {
        XCTAssertEqual(multiLineString.points as! [Point], lineStrings.flatMap { $0.points as! [Point] })
    }
    
    // GeoJsonLinearGeometry Tests
    
    func testLength() {
        XCTAssertEqual(multiLineString.length, 601246.341145017, accuracy: 10)
    }
    
    // MultiLineString Tests
    
    func testLineStrings() {
        XCTAssertEqual((multiLineString.lines as? [LineString])!, lineStrings)
    }
    
    func testEquals() {
        XCTAssertEqual(multiLineString, multiLineString)
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testNotEquals() {
        let point = GeoTestHelper.point(0, 0, 0)
        
        XCTAssertFalse(multiLineString == GeoTestHelper.multiLineString([GeoTestHelper.lineString([point, point, point, point])]))
    }
}
