import XCTest

@testable import GeospatialSwift

class LineStringTests: XCTestCase {
    var points: [Point]!
    var selfIntersectingPoints: [Point]!
    var selfOverlappingPoints: [Point]!
    var lineString: LineString!
    var selfIntersectingLineString: LineString!
    var selfOverlappingLineString: LineString!
    
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        points = [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 3)]
        selfIntersectingPoints = [GeoTestHelper.point(2, 0, 0), GeoTestHelper.point(0, 0, 0), GeoTestHelper.point(1, 3, 0), GeoTestHelper.point(1, -4, 0)]
        selfOverlappingPoints = [GeoTestHelper.point(0, 0, 0), GeoTestHelper.point(3, 0, 0), GeoTestHelper.point(1, 0, 0), GeoTestHelper.point(2, 0, 0)]
        
        lineString = GeoTestHelper.lineString(points)
        selfIntersectingLineString = GeoTestHelper.lineString(selfIntersectingPoints)
        selfOverlappingLineString = GeoTestHelper.lineString(selfOverlappingPoints)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(lineString.type, .lineString)
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(lineString.objectGeometries as! [LineString], lineString.geometries as! [LineString])
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(lineString.coordinatesGeometries.count, 1)
        XCTAssertEqual(lineString.linearGeometries.count, 1)
        XCTAssertEqual(lineString.closedGeometries.count, 0)
    }
    
    func testLineString_IsValid() {
        XCTAssertEqual(lineString.invalidReasons(tolerance: 0).count, 0)
    }
    
    func testSelfInterSectingLineString_IsInvalid() {
        let reason = selfIntersectingLineString.invalidReasons(tolerance: 0)
        XCTAssertEqual(reason.count, 1)
        
        if case LineStringInvalidReason.selfIntersects(segmentIndices: [2: [0]]) = reason[0] {
            XCTAssertTrue(true)
        } else {
            XCTAssertTrue(false)
        }
    }
    
    func testSelfOverlappingLineString_IsInvalid() {
        let reason = selfOverlappingLineString.invalidReasons(tolerance: 0)
        XCTAssertEqual(reason.count, 1)
        //[2: [1]]
        if case LineStringInvalidReason.selfIntersects(segmentIndices: let segmentIndices) = reason[0] {
            XCTAssertEqual(segmentIndices.count, 2)
            XCTAssertEqual(segmentIndices[1]!.count, 1)
            XCTAssertEqual(segmentIndices[1]![0], 0)
            XCTAssertEqual(segmentIndices[2]!.count, 2)
            XCTAssertEqual(segmentIndices[2]![0], 0)
            XCTAssertEqual(segmentIndices[2]![1], 1)
        }
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(lineString.objectBoundingBox as? BoundingBox, lineString.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(lineString.geoJson["type"] as? String, "LineString")
        XCTAssertEqual(lineString.geoJson["coordinates"] as? [[Double]], MockData.pointsCoordinatesJson)
    }
    
    func testObjectDistance() {
        XCTAssertEqual(lineString.distance(to: distancePoint), lineString.distance(to: distancePoint))
    }
    
    func testContains() {
        // Away From Line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 0), false)
        // On Line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.0, 2.0, 0), tolerance: 0), true)
        // On Line Geometrically but not geospatially
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.1, 2.0, 0), tolerance: 0), false)
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.5, 2.0, 0), tolerance: 0), false)
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.9, 2.0, 0), tolerance: 0), false)
        // On Line Geometrically but not geospatially - With error to adjust for curvature to be close enough to the line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.1, 2.0, 0), tolerance: 15), true)
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.5, 2.0, 0), tolerance: 15), true)
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.9, 2.0, 0), tolerance: 15), true)
        // On Line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 0), true)
        // Away From Line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(2.5, 2.0, 0), tolerance: 0), false)
    }
    
    // GeoJsonCoordinatesGeometry Tests
    
    func testGeoJsonCoordinates() {
        let coordinates = lineString.geoJsonCoordinates
        
        XCTAssertTrue(coordinates is [[Double]])
        
        // swiftlint:disable force_cast
        (coordinates as! [[Double]]).enumerated().forEach { pointsOffset, element in
            XCTAssertEqual(element, points[pointsOffset].geoJsonCoordinates as! [Double] )
        }
        // swiftlint:enable force_cast
    }
    
    func testGeometries() {
        XCTAssertEqual(lineString.geometries.count, 1)
        XCTAssertEqual(lineString.geometries[0] as? LineString, lineString)
    }
    
    func testBoundingBox() {
        let resultBoundingBox = lineString.boundingBox
        
        let boundingBox = BoundingBox.best(points.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
    }
    
    func testDistance() {
        let distance = lineString.distance(to: distancePoint)
        
        XCTAssertEqual(distance, 1178422.47118554, accuracy: 10)
    }
    
    func testDistance_NoTolerance() {
        let distance = lineString.distance(to: distancePoint, tolerance: 0.0)
        
        XCTAssertEqual(distance, 1178422.47118554, accuracy: 10)
    }
    
    func testDistance_OutsideTolerance() {
        let distance = lineString.distance(to: distancePoint, tolerance: 1178422)
        
        XCTAssertEqual(distance, 0.47118554264307, accuracy: 10)
    }
    
    func testDistance_OnTolerance() {
        let distance = lineString.distance(to: distancePoint, tolerance: 1178603.883587234187871)
        
        XCTAssertEqual(distance, 0.0, accuracy: 10)
    }
    
    func testDistance_InsideTolerance() {
        let distance = lineString.distance(to: distancePoint, tolerance: 1178604)
        
        XCTAssertEqual(distance, 0.0, accuracy: 10)
    }
    
    func testDistance_FollowingLine() {
        // Away From Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 0), 55471.8566967143, accuracy: 10)
        //55626.0657600516
        // On Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        // On Line Geometrically but not geospatially
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.1, 2.0, 0), tolerance: 0), 3.04105126725933, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.0, 0), tolerance: 0), 8.44739894101213, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.9, 2.0, 0), tolerance: 0), 3.0410512672544, accuracy: 10)
        // On Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        // Away From Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.5, 2.0, 0), tolerance: 0), 55471.8560535347, accuracy: 10)
    }
    
    func testDistance_TravelingThroughHorizontally() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.75, 2.25, 0), tolerance: 0), 39248.6795756426, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 2.25, 0), tolerance: 0), 27762.5616330752, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.25, 2.25, 0), tolerance: 0), 27756.2242840717, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.25, 0), tolerance: 0), 27754.112314124, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 27756.2242840717, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.25, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.25, 0), tolerance: 0), 27741.159070823, accuracy: 10)
    }
    
    func testDistance_TravelingThroughVertically() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 3.25, 0), tolerance: 0), 39328.079908396, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 3.0, 0), tolerance: 0), 27789.8922694512, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.75, 0), tolerance: 0), 27791.4048336645, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.5, 0), tolerance: 0), 27789.9022346475, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 27756.2242840717, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.0, 0), tolerance: 0), 6.33553915404217, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), tolerance: 0), 27751.3324991307, accuracy: 10)
    }
    
    func testDistance_TravelingThroughDiagnally() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), tolerance: 0), 248442.216300368, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), tolerance: 0), 111159.565454741, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), tolerance: 0), 55538.6863442482, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 27756.2242840717, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), tolerance: 0), 39226.835607103, accuracy: 10)
    }
    
    func testDistance_TravelingThroughDiagnally_Tolerance() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), tolerance: 100000), 148442.216300368, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), tolerance: 100000), 11159.5654547411, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), tolerance: 100000), 0.0, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 100000), 0.0, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 100000), 0.0, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), tolerance: 100000), 0.0, accuracy: 10)
    }
    
    func testDistance_DiagnalFromPoints_ShouldBeSimilar() {
        // Point 1
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 1.0, 0), tolerance: 0), 156876.478521843, accuracy: 10)
        // Point 2
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(3.0, 1.0, 0), tolerance: 0), 156876.478521843, accuracy: 10)
        // Point 3
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(3.0, 4.0, 0), tolerance: 0), 157217.359221784, accuracy: 10)
    }
    
    func testDistance_NearLineBySameAmount_ShouldBeSimilar() {
        // Line 1
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 1.75, 0), tolerance: 0), 27753.4442334685, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), tolerance: 0), 27751.3324991307, accuracy: 10)
        // Line 2
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.5, 0), tolerance: 0), 27747.1366851065, accuracy: 10)
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.75, 0), tolerance: 0), 27753.170416259, accuracy: 10)
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    func testPoints() {
        XCTAssertEqual((lineString.points as? [Point])!, points)
    }
    
    // GeoJsonLinearGeometry Tests
    
    // SOMEDAY: Verify
    func testLength() {
        XCTAssertEqual(lineString.length, 222130.2399313, accuracy: 10)
    }
    
    // LineString Tests
    
    func testSegments() {
        let segments = lineString.segments
        
        XCTAssertEqual(segments.count, 2)
    }
    
    // SOMEDAY: Test Bearing
    
    func testEquals() {
        XCTAssertEqual(lineString, lineString)
    }
    
    func testNotEquals() {
        let point = GeoTestHelper.point(0, 0)
        
        XCTAssertNotEqual(lineString, GeoTestHelper.lineString([point, point, point, point]))
    }
}
