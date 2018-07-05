@testable import GeospatialSwift

final class MockGeoJsonPolygon: MockGeoJsonClosedGeometry, GeoJsonPolygon {
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .polygon
    }
    
    private(set) var linearRingsCallCount: Int = 0
    var linearRingsResult = [MockGeoJsonLineString()]
    var linearRings: [GeoJsonLineString] {
        linearRingsCallCount += 1
        
        return linearRingsResult
    }
}
