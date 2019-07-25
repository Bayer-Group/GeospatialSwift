import XCTest

@testable import GeospatialSwift

// swiftlint:disable type_body_length
class PolygonTests: XCTestCase {
    var linearRings: [LineString]!
    var polygon: Polygon!
    var polygonDistance: Polygon!
    var distancePoint: SimplePoint!
    
    var point: GeoJsonPoint!
    var otherPoint: GeoJsonPoint!
    var point3: GeoJsonPoint!
    
    var lineString1: GeoJsonLineString!
    var lineString2: GeoJsonLineString!
    var lineString3: GeoJsonLineString!
    
    override func setUp() {
        super.setUp()
        
        linearRings = MockData.linearRings as? [LineString]
        
        //3                   *
        //
        //2.5
        //
        //2         *         *
        //
        //1.5
        //
        //1
        //    0.5   1   1.5   2
        polygonDistance = GeoTestHelper.polygon([GeoTestHelper.lineString([GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 5), GeoTestHelper.point(1, 2, 3)])])
        
        polygon = GeoTestHelper.polygon(linearRings)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
        
        point = GeoTestHelper.point(0, 0, 0)
        otherPoint = GeoTestHelper.point(1, 0, 0)
        point3 = GeoTestHelper.point(1, 0, 0)
        
        lineString1 = GeoTestHelper.lineString([point, point, point, point])
        lineString2 = GeoTestHelper.lineString([otherPoint, point, point, otherPoint])
        lineString3 = GeoTestHelper.lineString([otherPoint, point3, point3, otherPoint])
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(polygon.type, .polygon)
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(polygon.objectGeometries as! [Polygon], polygon.geometries as! [Polygon])
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(polygon.coordinatesGeometries.count, 1)
        XCTAssertEqual(polygon.linearGeometries.count, 0)
        XCTAssertEqual(polygon.closedGeometries.count, 1)
    }
    
    func testPolygonIsValid() {
        XCTAssertEqual(polygon.invalidReasons(tolerance: 0).count, 0)
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(polygon.objectBoundingBox as? BoundingBox, polygon.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(polygon.geoJson["type"] as? String, "Polygon")
        XCTAssertEqual(polygon.geoJson["coordinates"] as? [[[Double]]], MockData.polygonsCoordinatesJson[0])
    }
    
    func testObjectDistance() {
        XCTAssertEqual(polygon.distance(to: distancePoint), polygon.distance(to: distancePoint))
    }
    
    func testContains() {
        // Away From Polygon
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 0), false)
        // In Polygon
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.0, 2.0, 0), tolerance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.1, 2.0, 0), tolerance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.0, 0), tolerance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.9, 2.0, 0), tolerance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 0), true)
        // Away From Polygon
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(2.5, 2.0, 0), tolerance: 0), false)
    }
    
    func testContains_WithTolerance() {
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 0), false)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 55471), false)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 55471.856696714341524), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 100000), true)
    }
    
    func testContains_WithNegativeTolerance() {
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.25, 0), tolerance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.25, 0), tolerance: -19614), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.25, 0), tolerance: -19614.612530981), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.25, 0), tolerance: -20000), false)
    }
    
    // GeoJsonCoordinatesGeometry Tests
    
    func testGeoJsonCoordinates() {
        let coordinates = polygon.geoJsonCoordinates
        
        XCTAssertTrue(coordinates is [[[Double]]])
        
        // swiftlint:disable force_cast
        XCTAssertEqual((coordinates as! [[[Double]]]).count, linearRings.count)
        
        (coordinates as! [[[Double]]]).enumerated().forEach { linearRingsOffset, element in
            XCTAssertEqual(element.count, linearRings[linearRingsOffset].points.count)
            element.enumerated().forEach { pointsOffset, element in
                XCTAssertEqual(element, linearRings[linearRingsOffset].geoJsonPoints[pointsOffset].geoJsonCoordinates as! [Double] )
            }
        }
        // swiftlint:enable force_cast
    }
    
    func testGeometries() {
        XCTAssertEqual(polygon.geometries.count, 1)
        XCTAssertEqual(polygon.geometries[0] as? Polygon, polygon)
    }
    
    func testBoundingBox() {
        let resultBoundingBox = polygon.boundingBox
        
        let boundingBox = BoundingBox.best(linearRings.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
    }
    
    func testDistance_FollowingLine() {
        // Away From Line
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 0), 55471.8566967143, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 55471), 0.856696714341524, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 55471.856696714341524), 0.0, accuracy: 10)
        // On Line
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        // On Line Geometrically but not geospatially
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.1, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.9, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        // On Line
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        // Away From Line
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.5, 2.0, 0), tolerance: 0), 55471.8560535347, accuracy: 10)
    }
    
    //3                   *
    //
    //2.5
    //
    //2         *         *
    //
    //1.5
    //
    //1
    //    0.5   1   1.5   2
    func testDistance_TravelingThroughHorizontally() {
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.75, 2.25, 0), tolerance: 0), 39248.6795756426, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.0, 2.25, 0), tolerance: 0), 19614.612530981, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.25, 2.25, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 2.25, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.0, 2.25, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.25, 2.25, 0), tolerance: 0), 27741.159070823, accuracy: 10)
    }
    
    func testDistance_TravelingThroughVertically() {
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 3.25, 0), tolerance: 0), 39328.079908396, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 3.0, 0), tolerance: 0), 19631.959529833, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.75, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.5, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), tolerance: 0), 27751.3324991307, accuracy: 10)
    }
    
    func testDistance_TravelingThroughDiagnally() {
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), tolerance: 0), 235831.498448783, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), tolerance: 0), 78552.8579841262, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.25, 2.75, 0), tolerance: 0), 39251.0773445417, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), tolerance: 0), 39226.835607103, accuracy: 10)
    }
    
    // SOMEDAY: Need distance tests with a hole
    
    // SOMEDAY: Need edge distance tests
    
    func testDistance_DiagnalFromPoints_ShouldBeSimilar() {
        // Point 1
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.0, 1.0, 0), tolerance: 0), 156876.478521843, accuracy: 10)
        // Point 2
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(3.0, 1.0, 0), tolerance: 0), 156876.478521843, accuracy: 10)
        // Point 3
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(3.0, 4.0, 0), tolerance: 0), 157217.359221784, accuracy: 10)
    }
    
    func testDistance_NearLineBySameAmount_ShouldBeSimilar() {
        // Line 1
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 1.75, 0), tolerance: 0), 27753.4442334685, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), tolerance: 0), 27751.3324991307, accuracy: 10)
        // Line 2
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.25, 2.5, 0), tolerance: 0), 27747.1366851065, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.25, 2.75, 0), tolerance: 0), 27753.170416259, accuracy: 10)
        // Line 3
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.25, 2.5, 0), tolerance: 0), 19609.3114569387, accuracy: 10)
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 2.75, 0), tolerance: 0), 19614.8864286195, accuracy: 10)
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    // swiftlint:disable force_cast
    func testPoints() {
        XCTAssertEqual(polygon.points as! [Point], polygon.linearRings.flatMap { $0.points as! [Point] })
    }
    
    func testCentroid_NoHoles() {
        XCTAssertEqual(polygonDistance.centroid as! SimplePoint, GeoTestHelper.simplePoint(1.6666666666666666, 2.3333333333333333, 3.0))
    }
    
    // SOMEDAY: Wrong?
    func testCentroid_NoHoles2() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(-88.3254122, 39.5206294), GeoTestHelper.point(-88.3254123, 39.520643), GeoTestHelper.point(-88.3254549, 39.5206432), GeoTestHelper.point(-88.3254549, 39.5206296), GeoTestHelper.point(-88.3254122, 39.5206294)])
        let polygon = GeoTestHelper.polygon([mainRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(-88.325433565181825, 39.520636297343238))
    }
    // swiftlint:enable force_cast
    
    func testDistance_Small() {
        let distancePoint = GeoTestHelper.simplePoint(50.00010005, 50.00010005)
        
        let points = [
            GeoTestHelper.point(50, 50),
            GeoTestHelper.point(50.0001, 50),
            GeoTestHelper.point(50.0001, 50.0001),
            GeoTestHelper.point(50, 50.0001),
            GeoTestHelper.point(50, 50)
        ]
        let linearRings = [GeoTestHelper.lineString(points)]
        let polygon = GeoTestHelper.polygon(linearRings)
        //let feature = geospatial.geoJson.feature(geometry: polygon, id: 1, properties: nil)
        
        let distance = polygon.distance(to: distancePoint)
        
        XCTAssertEqual(distance, 0.00661514939644603, accuracy: 10)
    }
    
    // SOMEDAY: Test distance with holes
    
    // swiftlint:disable force_cast
    func testCentroid_SmallHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(0.5, 1.5, 3), GeoTestHelper.point(0.5, 3.5, 4), GeoTestHelper.point(2.5, 3.5, 5), GeoTestHelper.point(2.5, 1.5, 3), GeoTestHelper.point(0.5, 1.5, 3)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(1.0, 2.0, 3), GeoTestHelper.point(1.9, 2.5, 4), GeoTestHelper.point(1.9, 2.9, 5), GeoTestHelper.point(1.5, 2.5, 3), GeoTestHelper.point(1.0, 2.0, 3)])
        let polygon = GeoTestHelper.polygon([mainRing, negativeRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(1.4909997590845703, 2.5030003816872175, 3.0))
    }
    
    func testCentroid_LargeHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(100.0, 0.0, 3), GeoTestHelper.point(101.0, 0.0, 4), GeoTestHelper.point(101.0, 1.0, 5), GeoTestHelper.point(100.0, 1.0, 3), GeoTestHelper.point(100.0, 0.0, 3)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(100.05, 0.05, 3), GeoTestHelper.point(100.5, 0.05), GeoTestHelper.point(100.5, 0.95, 5), GeoTestHelper.point(100.05, 0.95, 3), GeoTestHelper.point(100.05, 0.05, 3)])
        let polygon = GeoTestHelper.polygon([mainRing, negativeRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(100.68225043951259, 0.50000059329894664, 3.0))
    }
    
    func testCentroid_CenterHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(100.0, 0.0), GeoTestHelper.point(101.0, 0.0), GeoTestHelper.point(101.0, 1.0), GeoTestHelper.point(100.0, 1.0), GeoTestHelper.point(100.0, 0.0)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(100.2, 0.2), GeoTestHelper.point(100.8, 0.2), GeoTestHelper.point(100.8, 0.8), GeoTestHelper.point(100.2, 0.8), GeoTestHelper.point(100.2, 0.2)])
        let polygon = GeoTestHelper.polygon([mainRing, negativeRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(100.5, 0.49999999999999994))
    }
    // swiftlint:enable force_cast
    
    // GeoJsonClosedGeometry Tests
    
    func testEdgeDistance_FollowingLine() {
        // Away From Line
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 0), 55471.8566967143, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 55471), 0.856696714341524, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), tolerance: 55471.856696714341524), 0.0, accuracy: 10)
        // On Line
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        // On Line Geometrically but not geospatially
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.1, 2.0, 0), tolerance: 0), 3.04105126725933, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 2.0, 0), tolerance: 0), 8.44739894101213, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.9, 2.0, 0), tolerance: 0), 3.0410512672544, accuracy: 10)
        // On Line
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        // Away From Line
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.5, 2.0, 0), tolerance: 0), 55471.8560535347, accuracy: 10)
    }
    
    func testEdgeDistance_TravelingThroughHorizontally() {
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.75, 2.25, 0), tolerance: 0), 39248.6795756426, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.0, 2.25, 0), tolerance: 0), 19614.612530981, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.25, 2.25, 0), tolerance: 0), 16.2521007346569, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 2.25, 0), tolerance: 0), 19643.7591709725, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 27756.2242840717, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.0, 2.25, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.25, 2.25, 0), tolerance: 0), 27741.159070823, accuracy: 10)
    }
    
    func testEdgeDistance_TravelingThroughVertically() {
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 3.25, 0), tolerance: 0), 39328.079908396, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 3.0, 0), tolerance: 0), 19631.959529833, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.75, 0), tolerance: 0), 17.3848323302551, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.5, 0), tolerance: 0), 19650.4282021363, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 27756.2242840717, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.0, 0), tolerance: 0), 6.33553915404217, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), tolerance: 0), 27751.3324991307, accuracy: 10)
    }
    
    func testEdgeDistance_TravelingThroughDiagnally() {
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), tolerance: 0), 235831.498448783, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), tolerance: 0), 78552.8579841262, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.25, 2.75, 0), tolerance: 0), 39251.0773445417, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), tolerance: 0), 22.4242585217697, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), tolerance: 0), 27756.2242840717, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), tolerance: 0), 0.0, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), tolerance: 0), 39226.835607103, accuracy: 10)
    }
    
    func testEdgeDistance_DiagnalFromPoints_ShouldBeSimilar() {
        // Point 1
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.0, 1.0, 0), tolerance: 0), 156876.478521843, accuracy: 10)
        // Point 2
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(3.0, 1.0, 0), tolerance: 0), 156876.478521843, accuracy: 10)
        // Point 3
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(3.0, 4.0, 0), tolerance: 0), 157217.359221784, accuracy: 10)
    }
    
    func testEdgeDistance_NearLineBySameAmount_ShouldBeSimilar() {
        // Line 1
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 1.75, 0), tolerance: 0), 27753.4442334685, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), tolerance: 0), 27751.3324991307, accuracy: 10)
        // Line 2
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.25, 2.5, 0), tolerance: 0), 27747.1366851065, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.25, 2.75, 0), tolerance: 0), 27753.170416259, accuracy: 10)
        // Line 3
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.25, 2.5, 0), tolerance: 0), 19609.3114569387, accuracy: 10)
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 2.75, 0), tolerance: 0), 19614.8864286195, accuracy: 10)
    }
    
    // SOMEDAY: Test edge distance with holes
    
    func testHasHole() {
        // SOMEDAY: Need to test polygon with and without holes.
    }
    
    // SOMEDAY: Verify
    func testArea() {
        //XCTAssertEqual(polygon.area, 11301732.6333942, accuracy: 10)
    }
    
    // Polygon Tests
    
    func testLinearRings() {
        XCTAssertEqual((polygon.linearRings as? [LineString])!, linearRings)
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testEquals() {
        XCTAssertEqual(polygon, polygon)
        
        XCTAssertEqual(GeoTestHelper.polygon([lineString1]), GeoTestHelper.polygon([lineString1]))
        
        XCTAssertEqual(GeoTestHelper.polygon([lineString1, lineString2]), GeoTestHelper.polygon([lineString1, lineString2]))
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testNotEquals() {
        XCTAssertNotEqual(polygon, GeoTestHelper.polygon([lineString1]))
        
        XCTAssertNotEqual(GeoTestHelper.polygon([lineString1, lineString2]), GeoTestHelper.polygon([lineString1, lineString3]))
    }
}
