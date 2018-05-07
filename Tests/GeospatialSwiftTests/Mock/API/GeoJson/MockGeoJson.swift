@testable import GeospatialSwift

final class MockGeoJson: GeoJsonProtocol {
    private(set) var parseCallCount = 0
    private(set) var featureCollectionCallCount = 0
    private(set) var featureCallCount = 0
    private(set) var geometryCollectionCallCount = 0
    private(set) var multiPolygonCallCount = 0
    private(set) var polygonCallCount = 0
    private(set) var multiLineStringCallCount = 0
    private(set) var lineStringCallCount = 0
    private(set) var multiPointCallCount = 0
    private(set) var pointAltitudeCallCount = 0
    private(set) var pointCallCount = 0
    
    var parseResult: GeoJsonObject = MockGeoJsonPoint()
    var featureCollectionResult: GeoJsonFeatureCollection = MockGeoJsonFeatureCollection()
    var featureResult: GeoJsonFeature = MockGeoJsonFeature()
    var geometryCollectionResult: GeoJsonGeometryCollection = MockGeoJsonGeometryCollection()
    var multiPolygonResult: GeoJsonMultiPolygon = MockGeoJsonMultiPolygon()
    var polygonResult: GeoJsonPolygon = MockGeoJsonPolygon()
    var multiLineStringResult: GeoJsonMultiLineString = MockGeoJsonMultiLineString()
    var lineStringResult: GeoJsonLineString = MockGeoJsonLineString()
    var multiPointResult: GeoJsonMultiPoint = MockGeoJsonMultiPoint()
    var pointAltitudeResult: GeoJsonPoint = MockGeoJsonPoint()
    var pointResult: GeoJsonPoint = MockGeoJsonPoint()
    
    func parse(geoJson: GeoJsonDictionary) -> GeoJsonObject? {
        parseCallCount += 1
        
        return parseResult
    }
    
    func featureCollection(features: [GeoJsonFeature]) -> GeoJsonFeatureCollection? {
        featureCollectionCallCount += 1
        
        return featureCollectionResult
    }
    
    func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> GeoJsonFeature? {
        featureCallCount += 1
        
        return featureResult
    }
    
    func geometryCollection(geometries: [GeoJsonGeometry]?) -> GeoJsonGeometryCollection {
        geometryCollectionCallCount += 1
        
        return geometryCollectionResult
    }
    
    func multiPolygon(polygons: [GeoJsonPolygon]) -> GeoJsonMultiPolygon? {
        multiPolygonCallCount += 1
        
        return multiPolygonResult
    }
    
    func polygon(linearRings: [GeoJsonLineString]) -> GeoJsonPolygon? {
        polygonCallCount += 1
        
        return polygonResult
    }
    
    func multiLineString(lineStrings: [GeoJsonLineString]) -> GeoJsonMultiLineString? {
        multiLineStringCallCount += 1
        
        return multiLineStringResult
    }
    
    func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString? {
        lineStringCallCount += 1
        
        return lineStringResult
    }
    
    func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint? {
        multiPointCallCount += 1
        
        return multiPointResult
    }
    
    func point(longitude: Double, latitude: Double, altitude: Double?) -> GeoJsonPoint {
        pointAltitudeCallCount += 1
        
        return pointAltitudeResult
    }
    
    func point(longitude: Double, latitude: Double) -> GeoJsonPoint {
        pointCallCount += 1
        
        return pointResult
    }
}
