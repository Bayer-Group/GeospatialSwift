import XCTest

@testable import GeospatialSwift

class GeodesicLineSegmentTests: XCTestCase {
    private var lineSegment: GeodesicLineSegment!
    private var reversedLineSegment: GeodesicLineSegment!
    private var startPoint: GeodesicPoint!
    private var endPoint: GeodesicPoint!
    
    override func setUp() {
        super.setUp()
        
        startPoint = SimplePoint(longitude: 1, latitude: 2, altitude: 3)
        endPoint = SimplePoint(longitude: 10, latitude: 10, altitude: 10)
        
        lineSegment = .init(startPoint: startPoint, endPoint: endPoint)
        reversedLineSegment = .init(startPoint: endPoint, endPoint: startPoint)
    }
    
    func testInitialBearing() {
        let initialBearing = lineSegment.initialBearing
        
        AssertEqualAccuracy10(initialBearing.bearing, 47.8193763709035)
        AssertEqualAccuracy10(initialBearing.back, 227.819376370904)
    }
    
    func testInitialBearing_Reverse() {
        let initialBearing = reversedLineSegment.initialBearing
        
        AssertEqualAccuracy10(initialBearing.bearing, 228.764352221902)
        AssertEqualAccuracy10(initialBearing.back, 48.7643522219023)
    }
    
    func testAverageBearing() {
        let averageBearing = lineSegment.averageBearing
        
        AssertEqualAccuracy10(averageBearing.bearing, 48.1320345260737)
        AssertEqualAccuracy10(averageBearing.back, 228.132034526074)
    }
    
    func testAverageBearing_Reverse() {
        let averageBearing = reversedLineSegment.averageBearing
        
        AssertEqualAccuracy10(averageBearing.bearing, 228.132034526074)
        AssertEqualAccuracy10(averageBearing.back, 48.1320345260736)
    }
    
    func testFinalBearing() {
        let finalBearing = lineSegment.finalBearing
        
        AssertEqualAccuracy10(finalBearing.bearing, 48.7643522219023)
        AssertEqualAccuracy10(finalBearing.back, 228.764352221902)
    }
    
    func testFinalBearing_Reverse() {
        let finalBearing = reversedLineSegment.finalBearing
        
        AssertEqualAccuracy10(finalBearing.bearing, 227.819376370904)
        AssertEqualAccuracy10(finalBearing.back, 47.8193763709035)
    }
    
    func testMidpoint() {
        let midpoint = lineSegment.midpoint
        
        AssertEqualAccuracy10(midpoint.latitude, 6.01841622677193)
        AssertEqualAccuracy10(midpoint.longitude, 5.46685861298068)
    }
}
