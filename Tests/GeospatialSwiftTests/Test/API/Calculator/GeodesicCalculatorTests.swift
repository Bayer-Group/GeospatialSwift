import XCTest

@testable import GeospatialSwift

class GeodesicCalculatorTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func testHasIntersection_SameLine() {
        let startPoint = SimplePoint(longitude: 1, latitude: 2)
        let endPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        let intersects = Calculator.hasIntersection(lineSegment, with: lineSegment, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_Overlaps_InsideLine_NotEnoughTolerence() {
        var startPoint = SimplePoint(longitude: 1, latitude: 2)
        var endPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment1 = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        startPoint = SimplePoint(longitude: 1.2, latitude: 2.2)
        endPoint = SimplePoint(longitude: 1.7, latitude: 2.7)
        let lineSegment2 = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        let intersects = Calculator.hasIntersection(lineSegment1, with: lineSegment2, tolerance: 4)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_Overlaps_InsideLine_EnoughTolerence() {
        var startPoint = SimplePoint(longitude: 1, latitude: 2)
        var endPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment1 = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        startPoint = SimplePoint(longitude: 1.2, latitude: 2.2)
        endPoint = SimplePoint(longitude: 1.7, latitude: 2.7)
        let lineSegment2 = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        let intersects = Calculator.hasIntersection(lineSegment1, with: lineSegment2, tolerance: 5)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_SameTrajectoryNoOverlap_Ahead() {
        var startPoint = SimplePoint(longitude: 1, latitude: 2)
        var endPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment1 = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        startPoint = SimplePoint(longitude: 2, latitude: 3)
        endPoint = SimplePoint(longitude: 2.5, latitude: 3.5)
        let lineSegment2 = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        let intersects = Calculator.hasIntersection(lineSegment1, with: lineSegment2, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_SameTrajectoryNoOverlap_Behind() {
        var startPoint = SimplePoint(longitude: 1, latitude: 2)
        var endPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment1 = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        startPoint = SimplePoint(longitude: 0, latitude: 1)
        endPoint = SimplePoint(longitude: 0.5, latitude: 1.5)
        let lineSegment2 = GeodesicLineSegment(startPoint: startPoint, endPoint: endPoint)
        
        let intersects = Calculator.hasIntersection(lineSegment1, with: lineSegment2, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_LineIntersectingPolygon_Inside() {
        let lineSegment = GeodesicLineSegment(startPoint: SimplePoint(longitude: 0.2, latitude: 0.5), endPoint: SimplePoint(longitude: 0.8, latitude: 0.5))
        let polygon = MockData.box
        
        let intersects = Calculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineIntersectingPolygon_OnLine() {
        let lineSegment = GeodesicLineSegment(startPoint: SimplePoint(longitude: 1.5, latitude: 0.5), endPoint: SimplePoint(longitude: 0.8, latitude: 0.5))
        let polygon = MockData.box
        
        let intersects = Calculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineIntersectingPolygon_CrossesTwice() {
        let lineSegment = GeodesicLineSegment(startPoint: SimplePoint(longitude: 0.9, latitude: 0.5), endPoint: SimplePoint(longitude: 2.0, latitude: 1.5))
        let polygon = MockData.box
        
        let intersects = Calculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineIntersectingPolygon_LineCrossesThrough() {
        let lineSegment = GeodesicLineSegment(startPoint: SimplePoint(longitude: -1.0, latitude: 0.5), endPoint: SimplePoint(longitude: 2.0, latitude: 0.5))
        let polygon = MockData.box
        
        let intersects = Calculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineIntersectingPolygon_LineOutside() {
        let lineSegment = GeodesicLineSegment(startPoint: SimplePoint(longitude: 1.5, latitude: 0.5), endPoint: SimplePoint(longitude: 2.0, latitude: 0.5))
        let polygon = MockData.box
        
        let intersects = Calculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_LineSegments_Cross() {
        let line = SimpleLine(points: [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 2),
            SimplePoint(longitude: -1, latitude: 1),
            SimplePoint(longitude: 1, latitude: 1)
            ])!
        
        let intersects = Calculator.hasIntersection(line, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineSegments_Continuous_Overlaps() {
        let line = SimpleLine(points: [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 1),
            SimplePoint(longitude: 0, latitude: 0)
            ])!
        
        let intersects = Calculator.hasIntersection(line, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineSegments_Continuous() {
        let line = SimpleLine(points: [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 1),
            SimplePoint(longitude: 0, latitude: 2)
            ])!
        
        let intersects = Calculator.hasIntersection(line, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_LineTouchingPolygon_LineOutside() {
        let lineSegment = GeodesicLineSegment(startPoint: SimplePoint(longitude: 0.5, latitude: 1.5), endPoint: SimplePoint(longitude: 2.0, latitude: 0))
        let polygon = MockData.box
        
        let intersects = Calculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineSegments_Closed() {
        let line = SimpleLine(points: [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 1),
            SimplePoint(longitude: 1, latitude: 1),
            SimplePoint(longitude: 0, latitude: 0)
            ])!
        
        let intersects = Calculator.hasIntersection(line, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    // swiftlint:disable:next function_body_length
    func testContainsInPolygon() {
        let points = [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 2),
            SimplePoint(longitude: 1, latitude: 4),
            SimplePoint(longitude: 2, latitude: 2),
            SimplePoint(longitude: 3, latitude: 4),
            SimplePoint(longitude: 4, latitude: 2),
            SimplePoint(longitude: 4, latitude: 0),
            SimplePoint(longitude: 0, latitude: 0)
        ]
        
        let pointToTest1 = SimplePoint(longitude: -1, latitude: 5)
        let pointToTest2 = SimplePoint(longitude: -1, latitude: 4)
        let pointToTest3 = SimplePoint(longitude: -1, latitude: 3)
        let pointToTest4 = SimplePoint(longitude: -1, latitude: 2)
        let pointToTest5 = SimplePoint(longitude: -1, latitude: 1)
        let pointToTest6 = SimplePoint(longitude: -1, latitude: 0)
        let pointToTest7 = SimplePoint(longitude: -1, latitude: -1)
        
        XCTAssertEqual(Calculator.contains(point: pointToTest1, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest2, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest3, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest4, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest5, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest6, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest7, vertices: points), false)
        
        let pointToTest11 = SimplePoint(longitude: 0, latitude: 5)
        let pointToTest12 = SimplePoint(longitude: 0, latitude: 4)
        let pointToTest13 = SimplePoint(longitude: 0, latitude: 3)
        let pointToTest14 = SimplePoint(longitude: 0, latitude: 2)
        let pointToTest15 = SimplePoint(longitude: 0, latitude: 1)
        let pointToTest16 = SimplePoint(longitude: 0, latitude: 0)
        let pointToTest17 = SimplePoint(longitude: 0, latitude: -1)
        
        XCTAssertEqual(Calculator.contains(point: pointToTest11, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest12, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest13, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest14, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest15, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest16, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest17, vertices: points), false)
        
        let pointToTest21 = SimplePoint(longitude: 1, latitude: 5)
        let pointToTest22 = SimplePoint(longitude: 1, latitude: 4)
        let pointToTest23 = SimplePoint(longitude: 1, latitude: 3)
        let pointToTest24 = SimplePoint(longitude: 1, latitude: 2)
        let pointToTest25 = SimplePoint(longitude: 1, latitude: 1)
        let pointToTest26 = SimplePoint(longitude: 1, latitude: 0)
        let pointToTest27 = SimplePoint(longitude: 1, latitude: -1)
        
        XCTAssertEqual(Calculator.contains(point: pointToTest21, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest22, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest23, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest24, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest25, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest26, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest27, vertices: points), false)
        
        let pointToTest31 = SimplePoint(longitude: 2, latitude: 5)
        let pointToTest32 = SimplePoint(longitude: 2, latitude: 4)
        let pointToTest33 = SimplePoint(longitude: 2, latitude: 3)
        let pointToTest34 = SimplePoint(longitude: 2, latitude: 2)
        let pointToTest35 = SimplePoint(longitude: 2, latitude: 1)
        let pointToTest36 = SimplePoint(longitude: 2, latitude: 0)
        let pointToTest37 = SimplePoint(longitude: 2, latitude: -1)
        
        XCTAssertEqual(Calculator.contains(point: pointToTest31, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest32, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest33, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest34, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest35, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest36, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest37, vertices: points), false)
        
        let pointToTest41 = SimplePoint(longitude: 3, latitude: 5)
        let pointToTest42 = SimplePoint(longitude: 3, latitude: 4)
        let pointToTest43 = SimplePoint(longitude: 3, latitude: 3)
        let pointToTest44 = SimplePoint(longitude: 3, latitude: 2)
        let pointToTest45 = SimplePoint(longitude: 3, latitude: 1)
        let pointToTest46 = SimplePoint(longitude: 3, latitude: 0)
        let pointToTest47 = SimplePoint(longitude: 3, latitude: -1)
        
        XCTAssertEqual(Calculator.contains(point: pointToTest41, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest42, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest43, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest44, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest45, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest46, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest47, vertices: points), false)
        
        let pointToTest51 = SimplePoint(longitude: 4, latitude: 5)
        let pointToTest52 = SimplePoint(longitude: 4, latitude: 4)
        let pointToTest53 = SimplePoint(longitude: 4, latitude: 3)
        let pointToTest54 = SimplePoint(longitude: 4, latitude: 2)
        let pointToTest55 = SimplePoint(longitude: 4, latitude: 1)
        let pointToTest56 = SimplePoint(longitude: 4, latitude: 0)
        let pointToTest57 = SimplePoint(longitude: 4, latitude: -1)
        
        XCTAssertEqual(Calculator.contains(point: pointToTest51, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest52, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest53, vertices: points), false)
        XCTAssertEqual(Calculator.contains(point: pointToTest54, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest55, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest56, vertices: points), true)
        XCTAssertEqual(Calculator.contains(point: pointToTest57, vertices: points), false)
    }
}
