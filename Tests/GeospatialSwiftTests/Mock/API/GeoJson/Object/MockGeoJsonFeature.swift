@testable import GeospatialSwift

final class MockGeoJsonFeature: MockGeoJsonGeometry, GeoJsonFeature {
    var geometryResult: GeoJsonGeometry? = MockGeoJsonPolygon()
    var idResult: Any?
    var idAsStringResult: String?
    var propertiesResult: GeoJsonDictionary?
    
    private(set) var geometryCallCount: Int = 0
    private(set) var idCallCount: Int = 0
    private(set) var idAsStringCallCount: Int = 0
    private(set) var propertiesCallCount: Int = 0
    
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .feature
    }
    
    var geometry: GeoJsonGeometry? {
        geometryCallCount += 1
        
        return geometryResult
    }
    
    var id: Any? {
        idCallCount += 1
        
        return idResult
    }
    
    var idAsString: String? {
        idAsStringCallCount += 1
        
        return idAsStringResult
    }
    
    var properties: GeoJsonDictionary? {
        propertiesCallCount += 1
        
        return propertiesResult
    }
}
