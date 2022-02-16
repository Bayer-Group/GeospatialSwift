import XCTest

@testable import GeospatialSwift

// swiftlint:disable type_body_length
class PolygonTests: XCTestCase {
    var mainRing: LineString!
    var negativeRings: [LineString]!
    var linearRings: [LineString]!
    var polygon: Polygon!
    var polygonDistance: Polygon!
    var sharingCornerLinearRings: [LineString]!
    var sharingCornerPolygon: Polygon!
    var sharingCornerAndOverlappingLinearRings: [LineString]!
    var sharingCornerAndOverlappingPolygon: Polygon!
    var ringIntersectingLinearRings: [LineString]!
    var ringIntersectingPolygon: Polygon!
    var holeOutsideLinearRings: [LineString]!
    var holeOutsidePolygon: Polygon!
    var holeContainedLinearRings: [LineString]!
    var holeContainedPolygon: Polygon!
    var mShapeMainRingLinearRings: [LineString]!
    var mShapeMainRingPolygon: Polygon!
    var doubleMNegativeRingsLinearRings: [LineString]!
    var doubleMNegativeRingsPolygon: Polygon!
    var diamondNegativeRingLinearRings: [LineString]!
    var diamondNegativeRingPolygon: Polygon!
    var spikeLinearRing: [LineString]!
    var spikePolygon: Polygon!
    
    var distancePoint: SimplePoint!
    
    var point: GeoJson.Point!
    var otherPoint: GeoJson.Point!
    var point3: GeoJson.Point!
    
    var lineString1: GeoJson.LineString!
    var lineString2: GeoJson.LineString!
    var lineString3: GeoJson.LineString!
    
    override func setUp() {
        super.setUp()
        
        mainRing = MockData.linearRings.first!
        negativeRings = Array(MockData.linearRings.dropFirst())
        linearRings = [mainRing] + negativeRings
        
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
        polygonDistance = GeoTestHelper.polygon(GeoTestHelper.lineString([GeoTestHelper.point(1, 2, 3), GeoTestHelper.point(2, 2, 4), GeoTestHelper.point(2, 3, 5), GeoTestHelper.point(1, 2, 3)]))
        
        polygon = GeoTestHelper.polygon(mainRing, negativeRings)
        
        sharingCornerLinearRings = MockData.sharingCornerLinearRings
        sharingCornerPolygon = GeoTestHelper.polygon(sharingCornerLinearRings.first!, Array(sharingCornerLinearRings.dropFirst()))
        
        sharingCornerAndOverlappingLinearRings = MockData.sharingCornerAndOverlappingRings
        sharingCornerAndOverlappingPolygon = GeoTestHelper.polygon(sharingCornerAndOverlappingLinearRings.first!, Array(sharingCornerAndOverlappingLinearRings.dropFirst()))
        
        ringIntersectingLinearRings = MockData.ringIntersectingLinearRings
        ringIntersectingPolygon =  GeoTestHelper.polygon(ringIntersectingLinearRings.first!, Array(ringIntersectingLinearRings.dropFirst()))
        
        holeOutsideLinearRings = MockData.holeOutsideLinearRings
        holeOutsidePolygon =  GeoTestHelper.polygon(holeOutsideLinearRings.first!, Array(holeOutsideLinearRings.dropFirst()))
        
        holeContainedLinearRings = MockData.holeContainedLinearRings
        holeContainedPolygon =  GeoTestHelper.polygon(holeContainedLinearRings.first!, Array(holeContainedLinearRings.dropFirst()))
        
        mShapeMainRingLinearRings = MockData.mShapeMainRingLinearRings
        mShapeMainRingPolygon =  GeoTestHelper.polygon(mShapeMainRingLinearRings.first!, Array(mShapeMainRingLinearRings.dropFirst()))
        
        doubleMNegativeRingsLinearRings = MockData.doubleMNegativeRingsLinearRings
        doubleMNegativeRingsPolygon =  GeoTestHelper.polygon(doubleMNegativeRingsLinearRings.first!, Array(doubleMNegativeRingsLinearRings.dropFirst()))
        
        diamondNegativeRingLinearRings = MockData.diamondNegativeRingLinearRings
        diamondNegativeRingPolygon =  GeoTestHelper.polygon(diamondNegativeRingLinearRings.first!, Array(diamondNegativeRingLinearRings.dropFirst()))
        
        spikeLinearRing = MockData.spikeLinearRings
        spikePolygon = GeoTestHelper.polygon(spikeLinearRing.first!, [])
        
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
        XCTAssertEqual(polygon.simpleViolations(tolerance: 0).count, 0)
    }
    
    func testPolygonSharingCorner_IsValid() {
        XCTAssertEqual(sharingCornerPolygon.simpleViolations(tolerance: 0).count, 0)
    }
    
    func testPolygonSharingCornerAndOverlappingEdge_IsInvalid() {
        let simpleViolations = sharingCornerAndOverlappingPolygon.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 2)
        
        if let point1 = simpleViolations[0].problems[0] as? Point, let point2 = simpleViolations[0].problems[1] as? Point, let point3 = simpleViolations[0].problems[3] as? Point, let point4 = simpleViolations[0].problems[4] as? Point {
            XCTAssertEqual(point1.longitude, 20.0)
            XCTAssertEqual(point1.latitude, 0.0)
            XCTAssertEqual(point2.longitude, 23.0)
            XCTAssertEqual(point2.latitude, 0.0)
            XCTAssertEqual(point3.longitude, 20.0)
            XCTAssertEqual(point3.latitude, 0.0)
            XCTAssertEqual(point4.longitude, 21.0)
            XCTAssertEqual(point4.latitude, 0.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point1 = simpleViolations[1].problems[0] as? Point, let point2 = simpleViolations[1].problems[1] as? Point, let point3 = simpleViolations[1].problems[3] as? Point, let point4 = simpleViolations[1].problems[4] as? Point {
            XCTAssertEqual(point1.longitude, 20.0)
            XCTAssertEqual(point1.latitude, 3.0)
            XCTAssertEqual(point2.longitude, 20.0)
            XCTAssertEqual(point2.latitude, 0.0)
            XCTAssertEqual(point3.longitude, 20.0)
            XCTAssertEqual(point3.latitude, 1.0)
            XCTAssertEqual(point4.longitude, 20.0)
            XCTAssertEqual(point4.latitude, 0.0)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testPolygonringIntersecting_IsInvalid() {
        let simpleViolations = ringIntersectingPolygon.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 4)
        
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.polygonHoleOutside)
        if let point1 = simpleViolations[0].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 24.0)
            XCTAssertEqual(point1.latitude, 21.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        XCTAssertEqual(simpleViolations[1].reason, GeoJsonSimpleViolationReason.polygonHoleOutside)
        if let point1 = simpleViolations[1].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 24.0)
            XCTAssertEqual(point1.latitude, 21.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        XCTAssertEqual(simpleViolations[2].reason, GeoJsonSimpleViolationReason.polygonHoleOutside)
        if let point1 = simpleViolations[2].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 24.0)
            XCTAssertEqual(point1.latitude, 22.0)
            
        } else {
            XCTFail("Geometry not valid")
        }
        
        XCTAssertEqual(simpleViolations[3].reason, GeoJsonSimpleViolationReason.polygonHoleOutside)
        if let point1 = simpleViolations[3].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 24.0)
            XCTAssertEqual(point1.latitude, 22.0)
            
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testPolygonWithHoleOutside_IsInvalid() {
        let simpleViolations = holeOutsidePolygon.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 8)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.polygonHoleOutside)
        XCTAssertEqual(simpleViolations[1].reason, GeoJsonSimpleViolationReason.polygonHoleOutside)
        XCTAssertEqual(simpleViolations[2].reason, GeoJsonSimpleViolationReason.polygonHoleOutside)
        XCTAssertEqual(simpleViolations[3].reason, GeoJsonSimpleViolationReason.polygonHoleOutside)
        
        if let point1 = simpleViolations[0].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 25.0)
            XCTAssertEqual(point1.latitude, 25.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point1 = simpleViolations[1].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 26.0)
            XCTAssertEqual(point1.latitude, 25.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point1 = simpleViolations[2].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 26.0)
            XCTAssertEqual(point1.latitude, 25.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point1 = simpleViolations[3].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 26.0)
            XCTAssertEqual(point1.latitude, 26.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point1 = simpleViolations[4].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 26.0)
            XCTAssertEqual(point1.latitude, 26.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point1 = simpleViolations[5].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 25.0)
            XCTAssertEqual(point1.latitude, 26.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point1 = simpleViolations[6].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 25.0)
            XCTAssertEqual(point1.latitude, 26.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point1 = simpleViolations[7].problems[0] as? Point {
            XCTAssertEqual(point1.longitude, 25.0)
            XCTAssertEqual(point1.latitude, 25.0)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testPolygonWithHoleContainingHole_IsInvalid() {
        let simpleViolations = holeContainedPolygon.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 1)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.polygonNegativeRingContained)
        
        if let point1 = simpleViolations[0].problems[0] as? Point, let point2 = simpleViolations[0].problems[2] as? Point, let point3 = simpleViolations[0].problems[4] as? Point, let point4 = simpleViolations[0].problems[6] as? Point {
            XCTAssertEqual(point1.longitude, 22.0)
            XCTAssertEqual(point1.latitude, 22.0)
            XCTAssertEqual(point2.longitude, 23.0)
            XCTAssertEqual(point2.latitude, 22.0)
            XCTAssertEqual(point3.longitude, 23.0)
            XCTAssertEqual(point3.latitude, 23.0)
            XCTAssertEqual(point4.longitude, 22.0)
            XCTAssertEqual(point4.latitude, 23.0)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testMShapePolygon_WithNegativeRingEdgeOutside_IsInvalid() {
        let simpleViolations = mShapeMainRingPolygon.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 2)
        
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.polygonSelfIntersection)
        if let point1 = simpleViolations[0].problems[0] as? Point, let point2 = simpleViolations[0].problems[1] as? Point, let point3 = simpleViolations[0].problems[3] as? Point, let point4 = simpleViolations[0].problems[4] as? Point {
            XCTAssertEqual(point1.longitude, 24.0)
            XCTAssertEqual(point1.latitude, 26.0)
            XCTAssertEqual(point2.longitude, 22.0)
            XCTAssertEqual(point2.latitude, 22.0)
            XCTAssertEqual(point3.longitude, 23.0)
            XCTAssertEqual(point3.latitude, 23.0)
            XCTAssertEqual(point4.longitude, 21.0)
            XCTAssertEqual(point4.latitude, 23.0)
        } else {
            XCTFail("Geometry not valid")
        }
        
        XCTAssertEqual(simpleViolations[1].reason, GeoJsonSimpleViolationReason.polygonSelfIntersection)
        if let point1 = simpleViolations[1].problems[0] as? Point, let point2 = simpleViolations[1].problems[1] as? Point, let point3 = simpleViolations[1].problems[3] as? Point, let point4 = simpleViolations[1].problems[4] as? Point {
            XCTAssertEqual(point1.longitude, 22.0)
            XCTAssertEqual(point1.latitude, 22.0)
            XCTAssertEqual(point2.longitude, 20.0)
            XCTAssertEqual(point2.latitude, 26.0)
            XCTAssertEqual(point3.longitude, 23.0)
            XCTAssertEqual(point3.latitude, 23.0)
            XCTAssertEqual(point4.longitude, 21.0)
            XCTAssertEqual(point4.latitude, 23.0)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testPolygon_WithDoubleMNegativeRing_IsInvalid() {
        let simpleViolations = doubleMNegativeRingsPolygon.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 8)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.polygonMultipleVertexIntersection)
        
        if let point = simpleViolations[0].problems[3] as? Point {
            XCTAssertEqual(point.longitude, 23)
            XCTAssertEqual(point.latitude, 21)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point = simpleViolations[4].problems[3] as? Point {
            XCTAssertEqual(point.longitude, 23)
            XCTAssertEqual(point.latitude, 23)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testPolygon_WithDiamondNegativeRing_IsInvalid() {
        let simpleViolations = diamondNegativeRingPolygon.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 8)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.polygonMultipleVertexIntersection)
        
        if let point = simpleViolations[0].problems[3] as? Point {
            XCTAssertEqual(point.longitude, 20)
            XCTAssertEqual(point.latitude, 20)
        } else {
            XCTFail("Geometry not valid")
        }
        
        if let point = simpleViolations[4].problems[3] as? Point {
            XCTAssertEqual(point.longitude, 24)
            XCTAssertEqual(point.latitude, 24)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    func testPolygon_WithSpike_IsInvalid() {
        let simpleViolations = spikePolygon.simpleViolations(tolerance: 0)
        XCTAssertEqual(simpleViolations.count, 1)
        XCTAssertEqual(simpleViolations[0].reason, GeoJsonSimpleViolationReason.polygonSpikeIndices)

        if let point = simpleViolations[0].problems[0] as? Point {
            XCTAssertEqual(point.longitude, -5.0)
            XCTAssertEqual(point.latitude, 150.0)
        } else {
            XCTFail("Geometry not valid")
        }
    }
    
    
    func testObjectBoundingBox() {
        XCTAssertEqual(polygon.objectBoundingBox, polygon.boundingBox)
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
                XCTAssertEqual(element, (linearRings[linearRingsOffset].points[pointsOffset] as! Point).geoJsonCoordinates as! [Double] )
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
        
        let boundingBox = GeodesicBoundingBox.best(linearRings.compactMap { $0.boundingBox })
        
        XCTAssertEqual(resultBoundingBox, boundingBox)
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
        let polygon = GeoTestHelper.polygon(mainRing)
        
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
        let polygon = GeoTestHelper.polygon(linearRings.first!, Array(linearRings.dropFirst()))
        //let feature = geospatial.geoJson.feature(geometry: polygon, id: 1, properties: nil)
        
        let distance = polygon.distance(to: distancePoint)
        
        XCTAssertEqual(distance, 0.00661514939644603, accuracy: 10)
    }
    
    // SOMEDAY: Test distance with holes
    
    // swiftlint:disable force_cast
    func testCentroid_SmallHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(0.5, 1.5, 3), GeoTestHelper.point(0.5, 3.5, 4), GeoTestHelper.point(2.5, 3.5, 5), GeoTestHelper.point(2.5, 1.5, 3), GeoTestHelper.point(0.5, 1.5, 3)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(1.0, 2.0, 3), GeoTestHelper.point(1.9, 2.5, 4), GeoTestHelper.point(1.9, 2.9, 5), GeoTestHelper.point(1.5, 2.5, 3), GeoTestHelper.point(1.0, 2.0, 3)])
        let polygon = GeoTestHelper.polygon(mainRing, [negativeRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(1.4909997590845703, 2.5030003816872175, 3.0))
    }
    
    func testCentroid_LargeHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(100.0, 0.0, 3), GeoTestHelper.point(101.0, 0.0, 4), GeoTestHelper.point(101.0, 1.0, 5), GeoTestHelper.point(100.0, 1.0, 3), GeoTestHelper.point(100.0, 0.0, 3)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(100.05, 0.05, 3), GeoTestHelper.point(100.5, 0.05), GeoTestHelper.point(100.5, 0.95, 5), GeoTestHelper.point(100.05, 0.95, 3), GeoTestHelper.point(100.05, 0.05, 3)])
        let polygon = GeoTestHelper.polygon(mainRing, [negativeRing])
        
        XCTAssertEqual(polygon.centroid as! SimplePoint, GeoTestHelper.simplePoint(100.68225043951259, 0.50000059329894664, 3.0))
    }
    
    func testCentroid_CenterHole() {
        let mainRing = GeoTestHelper.lineString([GeoTestHelper.point(100.0, 0.0), GeoTestHelper.point(101.0, 0.0), GeoTestHelper.point(101.0, 1.0), GeoTestHelper.point(100.0, 1.0), GeoTestHelper.point(100.0, 0.0)])
        let negativeRing = GeoTestHelper.lineString([GeoTestHelper.point(100.2, 0.2), GeoTestHelper.point(100.8, 0.2), GeoTestHelper.point(100.8, 0.8), GeoTestHelper.point(100.2, 0.8), GeoTestHelper.point(100.2, 0.2)])
        let polygon = GeoTestHelper.polygon(mainRing, [negativeRing])
        
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
        XCTAssertEqual(polygon.area, 98429670515.37445, accuracy: 10)
    }
    
    // Polygon Tests
    
    func testLinearRings() {
        XCTAssertEqual((polygon.linearRings as? [LineString])!, linearRings)
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testEquals() {
        XCTAssertEqual(polygon, polygon)
        
        XCTAssertEqual(GeoTestHelper.polygon(lineString1), GeoTestHelper.polygon(lineString1))
        
        XCTAssertEqual(GeoTestHelper.polygon(lineString1, [lineString2]), GeoTestHelper.polygon(lineString1, [lineString2]))
    }
    
    // SOMEDAY: Comparing the Json test data and this is confusing.
    func testNotEquals() {
        XCTAssertNotEqual(polygon, GeoTestHelper.polygon(lineString1))
        
        XCTAssertNotEqual(GeoTestHelper.polygon(lineString1, [lineString2]), GeoTestHelper.polygon(lineString1, [lineString3]))
    }
}
