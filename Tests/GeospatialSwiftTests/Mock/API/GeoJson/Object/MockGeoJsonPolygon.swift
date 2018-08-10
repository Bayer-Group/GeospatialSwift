@testable import GeospatialSwift

final class MockGeoJsonPolygon: MockGeoJsonClosedGeometry, GeoJsonPolygon {
    var ringSegements: [[GeodesicLineSegment]] = []
    var mainRingSegments: [GeodesicLineSegment] = []
    var negativeRingsSegments: [[GeodesicLineSegment]] = []
    
    var mainRing: GeoJsonLineString = MockData.lineStrings.first!
    var negativeRings: [GeoJsonLineString] = []
    
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .polygon
    }
    
    func invalidReasons(tolerance: Double) -> [PolygonInvalidReason] {
        return []
    }
    
    private(set) var linearRingsCallCount: Int = 0
    var linearRingsResult = [MockGeoJsonLineString()]
    var linearRings: [GeoJsonLineString] {
        linearRingsCallCount += 1
        
        return linearRingsResult
    }
    
    private(set) var centroidCallCount = 0
    var centroidResult: GeoJsonPoint = MockGeoJsonPoint()
    var centroid: GeodesicPoint {
        centroidCallCount += 1
        
        return centroidResult
    }
}
