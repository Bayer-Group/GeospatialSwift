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
        
        XCTAssertEqual(distance.description, "1178603.88358723")
    }
    
    func testDistance_NoErrorDistance() {
        let distance = lineString.distance(to: distancePoint, errorDistance: 0.0)
        
        XCTAssertEqual(distance.description, "1178603.88358723")
    }
    
    func testDistance_OutsideErrorDistance() {
        let distance = lineString.distance(to: distancePoint, errorDistance: 1178603)
        
        XCTAssertEqual(distance.description, "0.883587231626734")
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
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 0).description, "55625.8387686353")
        //55626.0657600516
        // On Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 2.0, 0), errorDistance: 0).description, "0.0")
        // On Line Geometrically but not geospatially
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.1, 2.0, 0), errorDistance: 0).description, "3.04949279781627")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.0, 0), errorDistance: 0).description, "8.47084773228069")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.9, 2.0, 0), errorDistance: 0).description, "3.0494927978385")
        // On Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0).description, "0.0")
        // Away From Line
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.5, 2.0, 0), errorDistance: 0).description, "55625.8381236702")
    }
    
    func testDistance_TravelingThroughHorizontally() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.75, 2.25, 0), errorDistance: 0).description, "39343.8372129913")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 2.25, 0), errorDistance: 0).description, "27829.8714075775")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.25, 2.25, 0), errorDistance: 0).description, "27823.5192499074")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.25, 0), errorDistance: 0).description, "27821.4018505861")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27808.4167390362")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.25, 0), errorDistance: 0).description, "27808.4167390362")
    }
    
    func testDistance_TravelingThroughVertically() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 3.25, 0), errorDistance: 0).description, "39328.1159053341")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 3.0, 0), errorDistance: 0).description, "27791.7327646141")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.75, 0), errorDistance: 0).description, "27797.8232377557")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.5, 0), errorDistance: 0).description, "27803.3846582459")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27808.4167390362")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.0, 0), errorDistance: 0).description, "6.35312571956565")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), errorDistance: 0).description, "27836.2255013466")
    }
    
    func testDistance_TravelingThroughDiagnally() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), errorDistance: 0).description, "248544.004481139")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), errorDistance: 0).description, "111166.927435153")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), errorDistance: 0).description, "55606.7683093096")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27808.4167390362")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), errorDistance: 0).description, "39346.8329368461")
    }
    
    func testDistance_TravelingThroughDiagnally_ErrorDistance() {
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), errorDistance: 100000).description, "148544.004481139")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), errorDistance: 100000).description, "11166.927435153")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), errorDistance: 100000).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 100000).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 100000).description, "0.0")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), errorDistance: 100000).description, "0.0")
    }
    
    func testDistance_DiagnalFromPoints_ShouldBeSimilar() {
        // Point 1
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(0.0, 1.0, 0), errorDistance: 0).description, "157401.561045836")
        // Point 2
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(3.0, 1.0, 0), errorDistance: 0).description, "157401.561045836")
        // Point 3
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(3.0, 4.0, 0), errorDistance: 0).description, "157281.772062802")
    }
    
    func testDistance_NearLineBySameAmount_ShouldBeSimilar() {
        // Line 1
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.5, 1.75, 0), errorDistance: 0).description, "27838.3435460507")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), errorDistance: 0).description, "27836.2255013466")
        // Line 2
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.5, 0), errorDistance: 0).description, "27803.3846582458")
        XCTAssertEqual(lineString.distance(to: GeoTestHelper.simplePoint(2.25, 2.75, 0), errorDistance: 0).description, "27797.8232377557")
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    func testPoints() {
        XCTAssertEqual((lineString.points as? [Point])!, points)
    }
    
    func testCentroid() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(lineString.centroid as! SimplePoint, GeoTestHelper.simplePoint(2.0, 2.00030459421549, 4.0))
    }
    
    func testCentroid_Negative() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(lineString.centroid as! SimplePoint, GeoTestHelper.simplePoint(2.0, 2.00030459421549, 4.0))
    }
    
    // GeoJsonLinearGeometry Tests
    
    // TODO: Verify
    func testLength() {
        XCTAssertEqual(lineString.length.description, "222571.167040614")
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
