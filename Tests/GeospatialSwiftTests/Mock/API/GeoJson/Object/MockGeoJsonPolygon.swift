@testable import GeospatialSwift

final class MockGeoJsonPolygon: MockGeoJsonClosedGeometry, GeoJsonPolygon {
    private(set) var linearRingsCallCount: Int = 0
    private(set) var areaCallCount: Int = 0
    
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .polygon
    }
    
    var linearRings: [GeoJsonLineString] {
        linearRingsCallCount += 1
        
        return [MockGeoJsonLineString()]
    }
    
    var area: Double {
        areaCallCount += 1
        
        return 0
    }
}
