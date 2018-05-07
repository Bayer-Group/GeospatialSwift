@testable import GeospatialSwift

final class MockGeoJsonLineString: MockGeoJsonMultiCoordinatesGeometry, GeoJsonLineString {
    var segments: [GeoJsonLineSegment] = []
    
    private(set) var lengthCallCount = 0
    
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .lineString
    }
    
    var length: Double {
        lengthCallCount += 1
        
        return 0.0
    }
}
