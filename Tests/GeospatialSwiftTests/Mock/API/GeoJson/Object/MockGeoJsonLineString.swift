@testable import GeospatialSwift

final class MockGeoJsonLineString: MockGeoJsonLinearGeometry, GeoJsonLineString {
    var geoJsonPoints: [GeoJsonPoint] = []
    
    func invalidReasons(tolerance: Double) -> [LineStringInvalidReason] {
        return []
    }
    
    var invalidReason: LineStringInvalidReason?
    
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .lineString
    }
    
    private(set) var segmentsCallCount = 0
    var segmentsResult: [GeodesicLineSegment] = []
    var segments: [GeodesicLineSegment] {
        segmentsCallCount += 1
        
        return segmentsResult
    }
    
    private(set) var bearingCallCount = 0
    var bearingResult: (average: Double, back: Double)? = (0, 0)
    var bearing: (average: Double, back: Double)? {
        bearingCallCount += 1
        
        return bearingResult
    }
}
