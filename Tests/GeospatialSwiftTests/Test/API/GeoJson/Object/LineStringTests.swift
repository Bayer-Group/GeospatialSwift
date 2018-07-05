import XCTest

@testable import GeospatialSwift

class LineStringTests: XCTestCase {
    var points: [Point]!
    var lineString: LineString!
    var distancePoint: SimplePoint!
    
    override func setUp() {
        super.setUp()
        
        points = [GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 5)]
        
        lineString = GeoTestHelper.lineString(points)
        
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
        XCTAssertEqual(lineString.multiCoordinatesGeometries.count, 1)
        XCTAssertEqual(lineString.linearGeometries.count, 1)
        XCTAssertEqual(lineString.closedGeometries.count, 0)
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(lineString.objectBoundingBox as? BoundingBox, lineString.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(lineString.geoJson.description, "[\"type\": \"LineString\", \"coordinates\": \(MockData.pointsCoordinatesJson)]")
    }
    
    func testObjectDistance() {
        XCTAssertEqual(lineString.distance(to: distancePoint), lineString.distance(to: distancePoint))
    }
    
    func testContains() {
        // Away From Line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 0), false)
        // On Line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.0, 2.0, 0), errorDistance: 0), true)
        // On Line Geometrically but not geospatially
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.1, 2.0, 0), errorDistance: 0), false)
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.5, 2.0, 0), errorDistance: 0), false)
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.9, 2.0, 0), errorDistance: 0), false)
        // On Line Geometrically but not geospatially - With error to adjust for curvature to be close enough to the line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.1, 2.0, 0), errorDistance: 15), true)
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.5, 2.0, 0), errorDistance: 15), true)
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(1.9, 2.0, 0), errorDistance: 15), true)
        // On Line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0), true)
        // Away From Line
        XCTAssertEqual(lineString.contains(GeoTestHelper.simplePoint(2.5, 2.0, 0), errorDistance: 0), false)
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
        
        XCTAssertEqual(distance.description, "1178422.47118554")
    }
    
    func testDistance_NoErrorDistance() {
        let distance = lineString.distance(to: distancePoint, errorDistance: 0.0)
        
        XCTAssertEqual(distance.description, "1178422.47118554")
    }
    
    func testDistance_OutsideErrorDistance() {
        let distance = lineString.distance(to: distancePoint, errorDistance: 1178422)
        
        XCTAssertEqual(distance.description, "0.47118554264307")
    }
    
    func testDistance_OnErrorDistance() {
        let distance = lineString.distance(to: distancePoint, errorDistance: 1178603.883587234187871)
        
        XCTAssertEqual(distance.description, "0.0")
    }
    
    func testDistance_InsideErrorDistance() {
        let distance = lineString.distance(to: distancePoint, errorDistance: 1178604)
        
        XCTAssertEqual(distance.description, "0.0")
    }
    
    func testDistance_FollowingLine() {
        // Away From Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 0).description, "55471.8566967143")
        //55626.0657600516
        // On Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 2.0, 0), errorDistance: 0).description, "0.0")
        // On Line Geometrically but not geospatially
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.1, 2.0, 0), errorDistance: 0).description, "3.04105126725933")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.0, 0), errorDistance: 0).description, "8.44739894101213")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.9, 2.0, 0), errorDistance: 0).description, "3.0410512672544")
        // On Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0).description, "0.0")
        // Away From Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.5, 2.0, 0), errorDistance: 0).description, "55471.8560535347")
    }
    
    func testDistance_TravelingThroughHorizontally() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.75, 2.25, 0), errorDistance: 0).description, "39248.6795756426")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 2.25, 0), errorDistance: 0).description, "27762.5616330752")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.25, 2.25, 0), errorDistance: 0).description, "27756.2242840717")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.25, 0), errorDistance: 0).description, "27754.112314124")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27756.2242840717")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.25, 0), errorDistance: 0).description, "27741.159070823")
    }
    
    func testDistance_TravelingThroughVertically() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 3.25, 0), errorDistance: 0).description, "39328.079908396")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 3.0, 0), errorDistance: 0).description, "27789.8922694512")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.75, 0), errorDistance: 0).description, "27791.4048336645")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.5, 0), errorDistance: 0).description, "27789.9022346475")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27756.2242840717")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.0, 0), errorDistance: 0).description, "6.33553915404217")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), errorDistance: 0).description, "27751.3324991307")
    }
    
    func testDistance_TravelingThroughDiagnally() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), errorDistance: 0).description, "248442.216300368")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), errorDistance: 0).description, "111159.565454741")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), errorDistance: 0).description, "55538.6863442482")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27756.2242840717")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), errorDistance: 0).description, "39226.835607103")
    }
    
    func testDistance_TravelingThroughDiagnally_ErrorDistance() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), errorDistance: 100000).description, "148442.216300368")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), errorDistance: 100000).description, "11159.5654547411")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), errorDistance: 100000).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 100000).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 100000).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), errorDistance: 100000).description, "0.0")
    }
    
    func testDistance_DiagnalFromPoints_ShouldBeSimilar() {
        // Point 1
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 1.0, 0), errorDistance: 0).description, "156876.478521843")
        // Point 2
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(3.0, 1.0, 0), errorDistance: 0).description, "156876.478521843")
        // Point 3
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(3.0, 4.0, 0), errorDistance: 0).description, "157217.359221784")
    }
    
    func testDistance_NearLineBySameAmount_ShouldBeSimilar() {
        // Line 1
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 1.75, 0), errorDistance: 0).description, "27753.4442334685")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), errorDistance: 0).description, "27751.3324991307")
        // Line 2
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.5, 0), errorDistance: 0).description, "27747.1366851065")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.75, 0), errorDistance: 0).description, "27753.170416259")
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    func testPoints() {
        XCTAssertEqual((lineString.points as? [Point])!, points)
    }
    
    // GeoJsonLinearGeometry Tests
    
    // TODO: Verify
    func testLength() {
        XCTAssertEqual(lineString.length.description, "222130.2399313")
    }
    
    // LineString Tests
    
    func testSegments() {
        let segments = lineString.segments
        
        XCTAssertEqual(segments.count, 2)
    }
    
    // TODO: Test Bearing
    
    func testEquals() {
        XCTAssertEqual(lineString, lineString)
    }
    
    func testNotEquals() {
        let point = GeoTestHelper.point(0, 0)
        
        XCTAssertNotEqual(lineString, GeoTestHelper.lineString([point, point, point, point]))
    }
}
