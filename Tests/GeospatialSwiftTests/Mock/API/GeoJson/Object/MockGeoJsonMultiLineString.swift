@testable import GeospatialSwift

final class MockGeoJsonMultiLineString: MockGeoJsonLinearGeometry, GeoJsonMultiLineString {
    func invalidReasons(tolerance: Double) -> [[LineStringInvalidReason]] {
        return []
    }
    
    private(set) var lineStringsCallCount = 0
    var lineStringsResult: [GeoJsonLineString] = []
    var lineStrings: [GeoJsonLineString] {
        lineStringsCallCount += 1
        
        return lineStringsResult
    }
}
