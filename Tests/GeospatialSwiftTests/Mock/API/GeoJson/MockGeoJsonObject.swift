@testable import GeospatialSwift

class MockGeoJsonObject: GeoJsonObject {
    private(set) var geoJsonObjectTypeCallCount = 0
    var geoJsonObjectTypeResult: GeoJsonObjectType = .point
    
    var description: String = ""
    
    var type: GeoJsonObjectType {
        geoJsonObjectTypeCallCount += 1
        
        return geoJsonObjectTypeResult
    }
    
    private(set) var objectGeometriesCallCount = 0
    var objectGeometriesResult: [GeoJsonGeometry]?
    var objectGeometries: [GeoJsonGeometry]? {
        objectGeometriesCallCount += 1
        
        return objectGeometriesResult
    }
    
    private(set) var objectBoundingBoxCallCount = 0
    var objectBoundingBoxResult: GeodesicBoundingBox?
    var objectBoundingBox: GeodesicBoundingBox? {
        objectBoundingBoxCallCount += 1
        
        return objectBoundingBoxResult
    }
    
    private(set) var geoJsonCallCount = 0
    var geoJsonResult: GeoJsonDictionary = [:]
    var geoJson: GeoJsonDictionary {
        geoJsonCallCount += 1
        
        return geoJsonResult
    }
    
    private(set) var objectDistanceCallCount = 0
    var objectDistanceResult: Double?
    func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? {
        objectDistanceCallCount += 1
        
        return objectDistanceResult
    }
    
    private(set) var containsCallCount = 0
    private(set) var containsToleranceCallCount = 0
    var containsResult: Bool = false
    var containsToleranceResult: Bool = false
    func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool {
        if tolerance > 0 { containsToleranceCallCount += 1 } else { containsCallCount += 1 }
        
        return tolerance > 0 ? containsToleranceResult : containsResult
    }
}
