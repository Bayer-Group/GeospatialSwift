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
    var objectBoundingBoxResult: GeoJsonBoundingBox?
    var objectBoundingBox: GeoJsonBoundingBox? {
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
    func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double? {
        objectDistanceCallCount += 1
        
        return objectDistanceResult
    }
    
    private(set) var containsCallCount = 0
    private(set) var containsErrorDistanceCallCount = 0
    var containsResult: Bool = false
    var containsErrorDistanceResult: Bool = false
    func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool {
        if errorDistance > 0 { containsErrorDistanceCallCount += 1 } else { containsCallCount += 1 }
        
        return errorDistance > 0 ? containsErrorDistanceResult : containsResult
    }
}
