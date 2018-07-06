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
    
    private(set) var centroidCallCount = 0
    var centroidResult: GeoJsonPoint = MockGeoJsonPoint()
    var centroid: GeodesicPoint {
        centroidCallCount += 1
        
        return centroidResult
    }
}
