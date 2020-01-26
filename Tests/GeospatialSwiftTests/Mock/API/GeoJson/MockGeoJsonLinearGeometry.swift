@testable import GeospatialSwift

class MockGeoJsonLinearGeometry: MockGeoJsonCoordinatesGeometry, GeoJsonLinearGeometry {
    private(set) var lineStringsCallCount = 0
    var lineStringsResult: [GeodesicLine] = []
    var lineStrings: [GeodesicLine] {
        lineStringsCallCount += 1
        
        return lineStringsResult
    }
    
    private(set) var lengthCallCount = 0
    var lengthResult: Double = 0
    var length: Double {
        lengthCallCount += 1
        
        return lengthResult
    }
}
