import XCTest

@testable import GeospatialSwift

// swiftlint:disable type_body_length
class PolygonTests: XCTestCase {
    var linearRings: [LineString]!
    var polygon: GeospatialSwift.Polygon!
    var polygonDistance: GeospatialSwift.Polygon!
    var distancePoint: SimplePoint!
    
    var point1: GeoJsonPoint!
    var point2: GeoJsonPoint!
    var point3: GeoJsonPoint!
    
    var lineString1: GeoJsonLineString!
    var lineString2: GeoJsonLineString!
    var lineString3: GeoJsonLineString!
    
    override func setUp() {
        super.setUp()
        
        // swiftlint:disable:next force_cast
        linearRings = MockData.linearRings as! [LineString]
        
        //2                   *
        //
        //1.5
        //
        //1         *         *
        //
        //0.5
        //
        //0
        //    0.5   1   1.5   2
        polygonDistance = GeoTestHelper.polygon([GeoTestHelper.lineString([GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 5), GeoTestHelper.point(1, 2, 3)])])
        
        polygon = GeoTestHelper.polygon(linearRings)
        
        distancePoint = GeoTestHelper.simplePoint(10, 10, 10)
        
        point1 = GeoTestHelper.point(0, 0, 0)
        point2 = GeoTestHelper.point(1, 0, 0)
        point3 = GeoTestHelper.point(1, 0, 0)
        
        lineString1 = GeoTestHelper.lineString([point1, point1, point1, point1])
        lineString2 = GeoTestHelper.lineString([point2, point1, point1, point2])
        lineString3 = GeoTestHelper.lineString([point2, point3, point3, point2])
    }
    
    // GeoJsonObject Tests
    
    func testGeoJsonObjectType() {
        XCTAssertEqual(polygon.type, .polygon)
    }
    
    func testObjectGeometries() {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(polygon.objectGeometries as! [GeospatialSwift.Polygon], polygon.geometries as! [GeospatialSwift.Polygon])
    }
    
    func testGeometryTypes() {
        XCTAssertEqual(polygon.coordinatesGeometries.count, 1)
        XCTAssertEqual(polygon.multiCoordinatesGeometries.count, 1)
        XCTAssertEqual(polygon.linearGeometries.count, 0)
        XCTAssertEqual(polygon.closedGeometries.count, 1)
    }
    
    func testObjectBoundingBox() {
        XCTAssertEqual(polygon.objectBoundingBox as? BoundingBox, polygon.boundingBox as? BoundingBox)
    }
    
    func testGeoJson() {
        XCTAssertEqual(polygon.geoJson.description, "[\"type\": \"Polygon\", \"coordinates\": \(MockData.linearRingsCoordinatesJson)]")
    }
    
    func testObjectDistance() {
        XCTAssertEqual(polygon.distance(to: distancePoint), polygon.distance(to: distancePoint))
    }
    
    func testContains() {
        // Away From Polygon
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 0), false)
        // In Polygon
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.0, 2.0, 0), errorDistance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.1, 2.0, 0), errorDistance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.0, 0), errorDistance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.9, 2.0, 0), errorDistance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0), true)
        // Away From Polygon
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(2.5, 2.0, 0), errorDistance: 0), false)
    }
    
    func testContains_WithErrorDistance() {
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 0), false)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 55471), false)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 55471.856696714341524), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 100000), true)
    }
    
    func testContains_WithNegativeErrorDistance() {
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.25, 0), errorDistance: 0), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.25, 0), errorDistance: -19614), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.25, 0), errorDistance: -19614.612530981), true)
        XCTAssertEqual(polygonDistance.contains(GeoTestHelper.simplePoint(1.5, 2.25, 0), errorDistance: -20000), false)
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
                XCTAssertEqual(element, linearRings[linearRingsOffset].points[pointsOffset].geoJsonCoordinates as! [Double] )
            }
        }
        // swiftlint:enable force_cast
    }
    
    func testGeometries() {
        XCTAssertEqual(polygon.geometries.count, 1)
        XCTAssertEqual(polygon.geometries[0] as? GeospatialSwift.Polygon, polygon)
    }
    
    func testBoundingBox() {
        let resultBoundingBox = polygon.boundingBox
        
        let boundingBox = BoundingBox.best(linearRings.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox as? BoundingBox, boundingBox as? BoundingBox)
    }
    
    func testDistance_FollowingLine() {
        // Away From Line
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 0).description, "55471.8566967143")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 55471).description, "0.856696714341524")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 55471.856696714341524), 0.0)
        // On Line
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.0, 2.0, 0), errorDistance: 0).description, "0.0")
        // On Line Geometrically but not geospatially
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.1, 2.0, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 2.0, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.9, 2.0, 0), errorDistance: 0).description, "0.0")
        // On Line
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0).description, "0.0")
        // Away From Line
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.5, 2.0, 0), errorDistance: 0).description, "55471.8560535347")
    }
    
    func testDistance_TravelingThroughHorizontally() {
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.75, 2.25, 0), errorDistance: 0).description, "39248.6795756426")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.0, 2.25, 0), errorDistance: 0).description, "19614.612530981")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.25, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.0, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.25, 2.25, 0), errorDistance: 0).description, "27741.159070823")
    }
    
    func testDistance_TravelingThroughVertically() {
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 3.25, 0), errorDistance: 0).description, "39328.079908396")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 3.0, 0), errorDistance: 0).description, "19631.959529833")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.75, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.5, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.0, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), errorDistance: 0).description, "27751.3324991307")
    }
    
    func testDistance_TravelingThroughDiagnally() {
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), errorDistance: 0).description, "235831.498448783")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), errorDistance: 0).description, "78552.8579841262")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.25, 2.75, 0), errorDistance: 0).description, "39251.0773445417")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), errorDistance: 0).description, "39226.835607103")
    }
    
    // TODO: Need distance tests with a hole
    
    // TODO: Need edge distance tests
    
    func testDistance_DiagnalFromPoints_ShouldBeSimilar() {
        // Point 1
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(0.0, 1.0, 0), errorDistance: 0).description, "156876.478521843")
        // Point 2
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(3.0, 1.0, 0), errorDistance: 0).description, "156876.478521843")
        // Point 3
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(3.0, 4.0, 0), errorDistance: 0).description, "157217.359221784")
    }
    
    func testDistance_NearLineBySameAmount_ShouldBeSimilar() {
        // Line 1
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 1.75, 0), errorDistance: 0).description, "27753.4442334685")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), errorDistance: 0).description, "27751.3324991307")
        // Line 2
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.25, 2.5, 0), errorDistance: 0).description, "27747.1366851065")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(2.25, 2.75, 0), errorDistance: 0).description, "27753.170416259")
        // Line 3
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.25, 2.5, 0), errorDistance: 0).description, "19609.3114569387")
        XCTAssertEqual(polygonDistance.distance(to: GeoTestHelper.simplePoint(1.5, 2.75, 0), errorDistance: 0).description, "19614.8864286195")
    }
    
    // GeoJsonMultiCoordinatesGeometry Tests
    
    // swiftlint:disable force_cast
    func testPoints() {
        XCTAssertEqual(polygon.points as! [Point], polygon.linearRings.flatMap { $0.points as! [Point] })
    }
    
    func testCentroid_NoHoles() {
        XCTAssertEqual(polygonDistance.centroid as! SimplePoint, GeoTestHelper.simplePoint(1.66666666666667, 2.33333333333333, 3.0))
    }
    
    // TODO: Wrong
    func testCentroid_NoHoles2() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(-88.3254122, 39.5206294), GeoTestHelper.point(-88.3254123, 39.520643), GeoTestHelper.point(-88.3254549, 39.5206432), GeoTestHelper.point(-88.3254549, 39.5206296), GeoTestHelper.point(-88.3254122, 39.5206294)])
        let polygon = GeoTestHelper.polygon([mainRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(-88.3254335651818, 39.5206362973432))
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
        
        XCTAssertEqual(distance.description, "0.00661514939644603")
    }
    
    // TODO: Test distance with holes
    
    // swiftlint:disable force_cast
    func testCentroid_SmallHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(0.5, 1.5, 3), GeoTestHelper.point(0.5, 3.5, 4), GeoTestHelper.point(2.5, 3.5, 5), GeoTestHelper.point(2.5, 1.5, 3), GeoTestHelper.point(0.5, 1.5, 3)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(1.0, 2.0, 3), GeoTestHelper.point(1.9, 2.5, 4), GeoTestHelper.point(1.9, 2.9, 5), GeoTestHelper.point(1.5, 2.5, 3), GeoTestHelper.point(1.0, 2.0, 3)])
        let polygon = GeoTestHelper.polygon([mainRing, negativeRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(1.49099975908457, 2.50300038168722, 3.0))
    }
    
    func testCentroid_LargeHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(100.0, 0.0, 3), GeoTestHelper.point(101.0, 0.0, 4), GeoTestHelper.point(101.0, 1.0, 5), GeoTestHelper.point(100.0, 1.0, 3), GeoTestHelper.point(100.0, 0.0, 3)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(100.05, 0.05, 3), GeoTestHelper.point(100.5, 0.05), GeoTestHelper.point(100.5, 0.95, 5), GeoTestHelper.point(100.05, 0.95, 3), GeoTestHelper.point(100.05, 0.05, 3)])
        let polygon = GeoTestHelper.polygon([mainRing, negativeRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(100.682250439513, 0.500000593298947, 3.0))
    }
    
    func testCentroid_CenterHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(100.0, 0.0), GeoTestHelper.point(101.0, 0.0), GeoTestHelper.point(101.0, 1.0), GeoTestHelper.point(100.0, 1.0), GeoTestHelper.point(100.0, 0.0)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(100.2, 0.2), GeoTestHelper.point(100.8, 0.2), GeoTestHelper.point(100.8, 0.8), GeoTestHelper.point(100.2, 0.8), GeoTestHelper.point(100.2, 0.2)])
        let polygon = GeoTestHelper.polygon([mainRing, negativeRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(100.5, 0.5))
    }
    // swiftlint:enable force_cast
    
    // GeoJsonClosedGeometry Tests
    
    func testEdgeDistance_FollowingLine() {
        // Away From Line
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 0).description, "55471.8566967143")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 55471).description, "0.856696714341524")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.5, 2.0, 0), errorDistance: 55471.856696714341524), 0.0)
        // On Line
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.0, 2.0, 0), errorDistance: 0).description, "0.0")
        // On Line Geometrically but not geospatially
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.1, 2.0, 0), errorDistance: 0).description, "3.04105126725933")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 2.0, 0), errorDistance: 0).description, "8.44739894101213")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.9, 2.0, 0), errorDistance: 0).description, "3.0410512672544")
        // On Line
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0).description, "0.0")
        // Away From Line
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.5, 2.0, 0), errorDistance: 0).description, "55471.8560535347")
    }
    
    func testEdgeDistance_TravelingThroughHorizontally() {
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.75, 2.25, 0), errorDistance: 0).description, "39248.6795756426")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.0, 2.25, 0), errorDistance: 0).description, "19614.612530981")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.25, 2.25, 0), errorDistance: 0).description, "16.2521007346569")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 2.25, 0), errorDistance: 0).description, "19643.7591709725")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27756.2242840717")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.0, 2.25, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.25, 2.25, 0), errorDistance: 0).description, "27741.159070823")
    }
    
    func testEdgeDistance_TravelingThroughVertically() {
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 3.25, 0), errorDistance: 0).description, "39328.079908396")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 3.0, 0), errorDistance: 0).description, "19631.959529833")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.75, 0), errorDistance: 0).description, "17.3848323302551")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.5, 0), errorDistance: 0).description, "19650.4282021363")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27756.2242840717")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.0, 0), errorDistance: 0).description, "6.33553915404217")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), errorDistance: 0).description, "27751.3324991307")
    }
    
    func testEdgeDistance_TravelingThroughDiagnally() {
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.0, 4.0, 0), errorDistance: 0).description, "235831.498448783")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.0, 3.0, 0), errorDistance: 0).description, "78552.8579841262")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.25, 2.75, 0), errorDistance: 0).description, "39251.0773445417")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 2.5, 0), errorDistance: 0).description, "22.4242585217697")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 2.25, 0), errorDistance: 0).description, "27756.2242840717")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.0, 2.0, 0), errorDistance: 0).description, "0.0")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.25, 1.75, 0), errorDistance: 0).description, "39226.835607103")
    }
    
    func testEdgeDistance_DiagnalFromPoints_ShouldBeSimilar() {
        // Point 1
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(0.0, 1.0, 0), errorDistance: 0).description, "156876.478521843")
        // Point 2
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(3.0, 1.0, 0), errorDistance: 0).description, "156876.478521843")
        // Point 3
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(3.0, 4.0, 0), errorDistance: 0).description, "157217.359221784")
    }
    
    func testEdgeDistance_NearLineBySameAmount_ShouldBeSimilar() {
        // Line 1
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 1.75, 0), errorDistance: 0).description, "27753.4442334685")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.75, 1.75, 0), errorDistance: 0).description, "27751.3324991307")
        // Line 2
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.25, 2.5, 0), errorDistance: 0).description, "27747.1366851065")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(2.25, 2.75, 0), errorDistance: 0).description, "27753.170416259")
        // Line 3
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.25, 2.5, 0), errorDistance: 0).description, "19609.3114569387")
        XCTAssertEqual(polygonDistance.edgeDistance(to: GeoTestHelper.simplePoint(1.5, 2.75, 0), errorDistance: 0).description, "19614.8864286195")
    }
    
    // TODO: Test edge distance with holes
    
    func testHasHole() {
        // TODO: Need to test polygon with and without holes.
    }
    
    // TODO: Verify
    func testArea() {
        XCTAssertEqual(polygon.area.description, "11301732.6333942")
    }
    
    // Polygon Tests
    
    func testLinearRings() {
        XCTAssertEqual((polygon.linearRings as? [LineString])!, linearRings)
    }
    
    // TODO: Comparing the Json test data and this is confusing.
    func testEquals() {
        XCTAssertEqual(polygon, polygon)
        
        XCTAssertEqual(GeoTestHelper.polygon([lineString1]), GeoTestHelper.polygon([lineString1]))
        
        XCTAssertEqual(GeoTestHelper.polygon([lineString1, lineString2]), GeoTestHelper.polygon([lineString1, lineString2]))
    }
    
    // TODO: Comparing the Json test data and this is confusing.
    func testNotEquals() {
        XCTAssertNotEqual(polygon, GeoTestHelper.polygon([lineString1]))
        
        XCTAssertNotEqual(GeoTestHelper.polygon([lineString1, lineString2]), GeoTestHelper.polygon([lineString1, lineString3]))
    }
}
