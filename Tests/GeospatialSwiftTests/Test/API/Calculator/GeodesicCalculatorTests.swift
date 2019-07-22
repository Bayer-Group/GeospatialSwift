import XCTest

@testable import GeospatialSwift

class GeodesicCalculatorTests: XCTestCase {
    private let geodesicCalculator = GeodesicCalculator.shared
    
    override func setUp() {
        super.setUp()
    }
    
    func testHasIntersection_SameLine() {
        let point = SimplePoint(longitude: 1, latitude: 2)
        let otherPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment = LineSegment(point: point, otherPoint: otherPoint)
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment, with: lineSegment, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_Overlaps_InsideLine_NotEnoughTolerence() {
        var point = SimplePoint(longitude: 1, latitude: 2)
        var otherPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment1 = LineSegment(point: point, otherPoint: otherPoint)
        
        point = SimplePoint(longitude: 1.2, latitude: 2.2)
        otherPoint = SimplePoint(longitude: 1.7, latitude: 2.7)
        let lineSegment2 = LineSegment(point: point, otherPoint: otherPoint)
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment1, with: lineSegment2, tolerance: 4)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_Overlaps_InsideLine_EnoughTolerence() {
        var point = SimplePoint(longitude: 1, latitude: 2)
        var otherPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment1 = LineSegment(point: point, otherPoint: otherPoint)
        
        point = SimplePoint(longitude: 1.2, latitude: 2.2)
        otherPoint = SimplePoint(longitude: 1.7, latitude: 2.7)
        let lineSegment2 = LineSegment(point: point, otherPoint: otherPoint)
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment1, with: lineSegment2, tolerance: 5)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_SameTrajectoryNoOverlap_Ahead() {
        var point = SimplePoint(longitude: 1, latitude: 2)
        var otherPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment1 = LineSegment(point: point, otherPoint: otherPoint)
        
        point = SimplePoint(longitude: 2, latitude: 3)
        otherPoint = SimplePoint(longitude: 2.5, latitude: 3.5)
        let lineSegment2 = LineSegment(point: point, otherPoint: otherPoint)
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment1, with: lineSegment2, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_SameTrajectoryNoOverlap_Behind() {
        var point = SimplePoint(longitude: 1, latitude: 2)
        var otherPoint = SimplePoint(longitude: 1.5, latitude: 2.5)
        let lineSegment1 = LineSegment(point: point, otherPoint: otherPoint)
        
        point = SimplePoint(longitude: 0, latitude: 1)
        otherPoint = SimplePoint(longitude: 0.5, latitude: 1.5)
        let lineSegment2 = LineSegment(point: point, otherPoint: otherPoint)
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment1, with: lineSegment2, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_LineIntersectingPolygon_Inside() {
        let lineSegment = LineSegment(point: SimplePoint(longitude: 0.2, latitude: 0.5), otherPoint: SimplePoint(longitude: 0.8, latitude: 0.5))
        let polygon = MockData.box
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineIntersectingPolygon_OnLine() {
        let lineSegment = LineSegment(point: SimplePoint(longitude: 1.5, latitude: 0.5), otherPoint: SimplePoint(longitude: 0.8, latitude: 0.5))
        let polygon = MockData.box
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineIntersectingPolygon_CrossesTwice() {
        let lineSegment = LineSegment(point: SimplePoint(longitude: 0.9, latitude: 0.5), otherPoint: SimplePoint(longitude: 2.0, latitude: 1.5))
        let polygon = MockData.box
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineIntersectingPolygon_LineCrossesThrough() {
        let lineSegment = LineSegment(point: SimplePoint(longitude: -1.0, latitude: 0.5), otherPoint: SimplePoint(longitude: 2.0, latitude: 0.5))
        let polygon = MockData.box
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineIntersectingPolygon_LineOutside() {
        let lineSegment = LineSegment(point: SimplePoint(longitude: 1.5, latitude: 0.5), otherPoint: SimplePoint(longitude: 2.0, latitude: 0.5))
        let polygon = MockData.box
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_LineTouchingPolygon_LineOutside() {
        let lineSegment = LineSegment(point: SimplePoint(longitude: 0.5, latitude: 1.5), otherPoint: SimplePoint(longitude: 2.0, latitude: 0))
        let polygon = MockData.box
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineTouchingPolygon_PointOutside_OtherPointTouching() {
        let lineSegment = LineSegment(point: SimplePoint(longitude: 2.0, latitude: 2.0), otherPoint: SimplePoint(longitude: 1.0, latitude: 1.0))
        let polygon = MockData.box
        
        let intersects = geodesicCalculator.hasIntersection(lineSegment, with: polygon, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_LineSegments_Cross() {
        let line = SimpleLine(points: [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 2),
            SimplePoint(longitude: -1, latitude: 1),
            SimplePoint(longitude: 1, latitude: 1)
            ])!
        
        let intersects = geodesicCalculator.hasIntersection(line, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineSegments_Continuous_Overlaps() {
        let line = SimpleLine(points: [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 1),
            SimplePoint(longitude: 0, latitude: 0)
            ])!
        
        let intersects = geodesicCalculator.hasIntersection(line, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
    
    func testHasIntersection_LineSegments_Continuous() {
        let line = SimpleLine(points: [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 1),
            SimplePoint(longitude: 0, latitude: 2)
            ])!
        
        let intersects = geodesicCalculator.hasIntersection(line, tolerance: 0)
        
        XCTAssertEqual(intersects, false)
    }
    
    func testHasIntersection_LineSegments_Closed() {
        let line = SimpleLine(points: [
            SimplePoint(longitude: 0, latitude: 0),
            SimplePoint(longitude: 0, latitude: 1),
            SimplePoint(longitude: 1, latitude: 1),
            SimplePoint(longitude: 0, latitude: 0)
            ])!
        
        let intersects = geodesicCalculator.hasIntersection(line, tolerance: 0)
        
        XCTAssertEqual(intersects, true)
    }
}
