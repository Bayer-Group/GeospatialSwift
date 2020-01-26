@testable import GeospatialSwift

final class MockGeoJson: GeoJsonProtocol {
    private(set) var parseGeoJsonCallCount = 0
    var parseGeoJsonResult: Result<GeoJsonObject, InvalidGeoJson> = .failure(.init(reason: "Test"))
    func parse(geoJson: GeoJsonDictionary) -> Result<GeoJsonObject, InvalidGeoJson> {
        parseGeoJsonCallCount += 1
        
        return parseGeoJsonResult
    }
    
    private(set) var parseValidatedGeoJsonCallCount = 0
    var parseValidatedGeoJsonResult: GeoJsonObject = MockGeoJsonPoint()
    func parse(validatedGeoJson: GeoJsonDictionary) -> GeoJsonObject {
        parseValidatedGeoJsonCallCount += 1
        
        return parseValidatedGeoJsonResult
    }
    
    private(set) var featureCollectionCallCount = 0
    var featureCollectionResult: Result<GeoJsonFeatureCollection, InvalidGeoJson> = .failure(.init(reason: "Test"))
    func featureCollection(features: [GeoJsonFeature]) -> Result<GeoJsonFeatureCollection, InvalidGeoJson> {
        featureCollectionCallCount += 1
        
        return featureCollectionResult
    }
    
    private(set) var featureCallCount = 0
    var featureResult: Result<GeoJsonFeature, InvalidGeoJson> = .failure(.init(reason: "Test"))
    func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> Result<GeoJsonFeature, InvalidGeoJson> {
        featureCallCount += 1
        
        return featureResult
    }
    
    private(set) var geometryCollectionCallCount = 0
    var geometryCollectionResult: GeoJsonGeometryCollection = MockGeoJsonGeometryCollection()
    func geometryCollection(geometries: [GeoJsonGeometry]?) -> GeoJsonGeometryCollection {
        geometryCollectionCallCount += 1
        
        return geometryCollectionResult
    }
    
    private(set) var multiPolygonCallCount = 0
    var multiPolygonResult: Result<GeoJsonMultiPolygon, InvalidGeoJson> = .failure(.init(reason: "Test"))
    func multiPolygon(polygons: [GeoJsonPolygon]) -> Result<GeoJsonMultiPolygon, InvalidGeoJson> {
        multiPolygonCallCount += 1
        
        return multiPolygonResult
    }
    
    private(set) var polygonCallCount = 0
    var polygonResult: Result<GeoJsonPolygon, InvalidGeoJson> = .failure(.init(reason: "Test"))
    func polygon(mainRing: GeoJsonLineString, negativeRings: [GeoJsonLineString]) -> Result<GeoJsonPolygon, InvalidGeoJson> {
        polygonCallCount += 1
        
        return polygonResult
    }
    
    private(set) var multiLineStringCallCount = 0
    var multiLineStringResult: Result<GeoJsonMultiLineString, InvalidGeoJson> = .failure(.init(reason: "Test"))
    func multiLineString(lineStrings: [GeoJsonLineString]) -> Result<GeoJsonMultiLineString, InvalidGeoJson> {
        multiLineStringCallCount += 1
        
        return multiLineStringResult
    }
    
    private(set) var lineStringCallCount = 0
    var lineStringResult: Result<GeoJsonLineString, InvalidGeoJson> = .failure(.init(reason: "Test"))
    func lineString(points: [GeoJsonPoint]) -> Result<GeoJsonLineString, InvalidGeoJson> {
        lineStringCallCount += 1
        
        return lineStringResult
    }
    
    private(set) var multiPointCallCount = 0
    var multiPointResult: Result<GeoJsonMultiPoint, InvalidGeoJson> = .failure(.init(reason: "Test"))
    func multiPoint(points: [GeoJsonPoint]) -> Result<GeoJsonMultiPoint, InvalidGeoJson> {
        multiPointCallCount += 1
        
        return multiPointResult
    }
    
    private(set) var pointAltitudeCallCount = 0
    var pointAltitudeResult: GeoJsonPoint = MockGeoJsonPoint()
    func point(longitude: Double, latitude: Double, altitude: Double?) -> GeoJsonPoint {
        pointAltitudeCallCount += 1
        
        return pointAltitudeResult
    }
    
    private(set) var pointCallCount = 0
    var pointResult: GeoJsonPoint = MockGeoJsonPoint()
    func point(longitude: Double, latitude: Double) -> GeoJsonPoint {
        pointCallCount += 1
        
        return pointResult
    }
}
