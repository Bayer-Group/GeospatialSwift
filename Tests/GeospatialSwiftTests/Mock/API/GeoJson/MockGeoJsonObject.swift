@testable import GeospatialSwift

class MockGeoJsonObject: GeoJsonObject {
    private(set) var geoJsonObjectTypeCallCount = 0
    private(set) var objectGeometriesCallCount = 0
    private(set) var objectBoundingBoxCallCount = 0
    private(set) var geoJsonCallCount = 0
    private(set) var objectDistanceCallCount = 0
    private(set) var containsCallCount = 0
    private(set) var containsErrorDistanceCallCount = 0
    
    var geoJsonObjectTypeResult: GeoJsonObjectType = .point
    var objectGeometriesResult: [GeoJsonGeometry]?
    var objectBoundingBoxResult: GeoJsonBoundingBox?
    var geoJsonResult: GeoJsonDictionary = [:]
    var objectDistanceResult: Double?
    var containsResult: Bool = false
    var containsErrorDistanceResult: Bool = false
    
    var description: String = ""
    
    var type: GeoJsonObjectType {
        geoJsonObjectTypeCallCount += 1
        
        return geoJsonObjectTypeResult
    }
    
    var objectGeometries: [GeoJsonGeometry]? {
        objectGeometriesCallCount += 1
        
        return objectGeometriesResult
    }
    
    var objectBoundingBox: GeoJsonBoundingBox? {
        objectBoundingBoxCallCount += 1
        
        return objectBoundingBoxResult
    }
    
    var geoJson: GeoJsonDictionary {
        geoJsonCallCount += 1
        
        return geoJsonResult
    }
    
    func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double? {
        objectDistanceCallCount += 1
        
        return objectDistanceResult
    }
    
    func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool {
        if errorDistance > 0 { containsErrorDistanceCallCount += 1 } else { containsCallCount += 1 }
        
        return errorDistance > 0 ? containsErrorDistanceResult : containsResult
    }
}
