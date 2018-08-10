@testable import GeospatialSwift

final class MockGeoJsonFeature: MockGeoJsonObject, GeoJsonFeature {
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .feature
    }
    
    private(set) var geometryCallCount: Int = 0
    var geometryResult: GeoJsonGeometry? = MockGeoJsonPolygon()
    var geometry: GeoJsonGeometry? {
        geometryCallCount += 1
        
        return geometryResult
    }
    
    private(set) var idCallCount: Int = 0
    var idResult: Any?
    var id: Any? {
        idCallCount += 1
        
        return idResult
    }
    
    private(set) var idAsStringCallCount: Int = 0
    var idAsStringResult: String?
    var idAsString: String? {
        idAsStringCallCount += 1
        
        return idAsStringResult
    }
    
    private(set) var propertiesCallCount: Int = 0
    var propertiesResult: GeoJsonDictionary?
    var properties: GeoJsonDictionary? {
        propertiesCallCount += 1
        
        return propertiesResult
    }
}
