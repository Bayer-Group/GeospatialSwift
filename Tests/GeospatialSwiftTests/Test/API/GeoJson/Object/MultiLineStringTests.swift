import XCTest

@testable import GeospatialSwift

class MultiLineStringTests: XCTestCase {
    var lineStrings: [LineString]!
    var selfIntersectingLineStrings: [LineString]!
    var selfCrossingLineStrings: [LineString]!
    var sharingStartAndEndMultiLineStrings: [LineString]!
    var multiLineString: MultiLineString!
    var selfIntersectingMultiLineString: MultiLineString!
    var selfCrossingMultiLineString: MultiLineString!
    var sharingStartAndEndMultiLineString: MultiLineString!
    
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        lineStrings = MockData.lineStrings as? [LineString]
        selfIntersectingLineStrings = MockData.selfIntersectingLineStrings as? [LineString]
        selfCrossingLineStrings = MockData.selfCrossingLineStrings as? [LineString]
        sharingStartAndEndMultiLineStrings = MockData.sharingStartAndEndLineStrings as? [LineString]
        
        multiLineString = GeoTestHelper.multiLineString(lineStrings)
        selfIntersectingMultiLineString = GeoTestHelper.multiLineString(selfIntersectingLineStrings)
        selfCrossingMultiLineString = GeoTestHelper.multiLineString(selfCrossingLineStrings)
        sharingStartAndEndMultiLineString = GeoTestHelper.multiLineString(sharingStartAndEndMultiLineStrings)
        
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
    
    func testMultiLineString_StartAndEndTouching_IsValid() {
        XCTAssertEqual(multiLineString.invalidReasons(tolerance: 0).count, 0)
    }
    
    func testMultiLineString_SharingStartAndEnd_IsValid() {
        XCTAssertEqual(sharingStartAndEndMultiLineString.invalidReasons(tolerance: 0).count, 0)
    }
    
    func testSelfInterSectingMultiLineString_IsInvalid() {
        let invalidReasons = selfIntersectingMultiLineString.invalidReasons(tolerance: 0)
        XCTAssertEqual(invalidReasons.count, 1)
        
        if case MultiLineStringInvalidReason.lineStringsIntersect(intersection: let intersectionIndices) = invalidReasons[0] {
            XCTAssertEqual(intersectionIndices.count, 1)
            XCTAssertEqual(intersectionIndices[0].firstSegmentIndexPath.lineStringIndex, 1)
            XCTAssertEqual(intersectionIndices[0].firstSegmentIndexPath.segmentIndex, 0)
            XCTAssertEqual(intersectionIndices[0].secondSegmentIndexPath[0].lineStringIndex, 0)
            XCTAssertEqual(intersectionIndices[0].secondSegmentIndexPath[0].segmentIndex, 0)
        }
    }
    
    func testSelfCrossingMultiLine_IsInvalid() {
        let invalidReasons = selfCrossingMultiLineString.invalidReasons(tolerance: 0)
        XCTAssertEqual(invalidReasons.count, 1)

        if case MultiLineStringInvalidReason.lineStringsIntersect(intersection: let intersectionIndices) = invalidReasons[0] {
            XCTAssertEqual(intersectionIndices.count, 1)
            XCTAssertEqual(intersectionIndices[0].firstSegmentIndexPath.lineStringIndex, 1)
            XCTAssertEqual(intersectionIndices[0].firstSegmentIndexPath.segmentIndex, 0)
            XCTAssertEqual(intersectionIndices[0].secondSegmentIndexPath[0].lineStringIndex, 0)
            XCTAssertEqual(intersectionIndices[0].secondSegmentIndexPath[0].segmentIndex, 0)
        }
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(multiLineString.coordinatesGeometries.count, 1)
        XCTAssertEqual(multiLineString.linearGeometries.count, 1)
        XCTAssertEqual(multiLineString.closedGeometries.count, 0)
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(multiLineString.objectBoundingBox as? BoundingBox, multiLineString.boundingBox as? BoundingBox)
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
        
        XCTAssertEqual(multiLineString.contains(point), lineStrings.map { $0.contains(point) }.reduce(false) { $0 || $1 })
    }
    
    func testContains_DoesNot() {
        let point = distancePoint!
        
        XCTAssertEqual(multiLineString.contains(point), lineStrings.map { $0.contains(point) }.reduce(false) { $0 || $1 })
    }
    
    func testContains_WithTolerance() {
        let point = multiLineString.points.first!
        let tolerance = 0.0
        
        XCTAssertEqual(multiLineString.contains(point, tolerance: tolerance), lineStrings.map { $0.contains(point, tolerance: tolerance) }.reduce(false) { $0 || $1 })
    }
    
    func testContains_WithTolerance_Does_WithError() {
        let point = distancePoint!
        let tolerance = 200000000.0
        
        XCTAssertEqual(multiLineString.contains(point, tolerance: tolerance), lineStrings.map { $0.contains(point, tolerance: tolerance) }.reduce(false) { $0 || $1 })
    }
    
    func testContains_WithTolerance_DoesNot() {
        let point = distancePoint!
        let tolerance = 0.0
        
        XCTAssertEqual(multiLineString.contains(point, tolerance: tolerance), lineStrings.map { $0.contains(point, tolerance: tolerance) }.reduce(false) { $0 || $1 })
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
                XCTAssertEqual(element, lineStrings[lineStringsOffset].geoJsonPoints[pointsOffset].geoJsonCoordinates as! [Double] )
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
        
        let boundingBox = BoundingBox.best(lineStrings.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
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
        XCTAssertEqual((multiLineString.lineStrings as? [LineString])!, lineStrings)
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
