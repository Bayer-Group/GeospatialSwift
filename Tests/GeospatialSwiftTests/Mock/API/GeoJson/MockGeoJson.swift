@testable import GeospatialSwift

final class MockGeoJson: GeoJsonProtocol {
    private(set) var parseCallCount = 0
    var parseResult: GeoJsonObject = MockGeoJsonPoint()
    func parse(geoJson: GeoJsonDictionary) -> GeoJsonObject? {
        parseCallCount += 1
        
        return parseResult
    }
    
    private(set) var featureCollectionCallCount = 0
    var featureCollectionResult: GeoJsonFeatureCollection = MockGeoJsonFeatureCollection()
    func featureCollection(features: [GeoJsonFeature]) -> GeoJsonFeatureCollection? {
        featureCollectionCallCount += 1
        
        return featureCollectionResult
    }
    
    private(set) var featureCallCount = 0
    var featureResult: GeoJsonFeature = MockGeoJsonFeature()
    func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> GeoJsonFeature? {
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
    var multiPolygonResult: GeoJsonMultiPolygon = MockGeoJsonMultiPolygon()
    func multiPolygon(polygons: [GeoJsonPolygon]) -> GeoJsonMultiPolygon? {
        multiPolygonCallCount += 1
        
        return multiPolygonResult
    }
    
    private(set) var polygonCallCount = 0
    var polygonResult: GeoJsonPolygon = MockGeoJsonPolygon()
    func polygon(linearRings: [GeoJsonLineString]) -> GeoJsonPolygon? {
        polygonCallCount += 1
        
        return polygonResult
    }
    
    private(set) var multiLineStringCallCount = 0
    var multiLineStringResult: GeoJsonMultiLineString = MockGeoJsonMultiLineString()
    func multiLineString(lineStrings: [GeoJsonLineString]) -> GeoJsonMultiLineString? {
        multiLineStringCallCount += 1
        
        return multiLineStringResult
    }
    
    private(set) var lineStringCallCount = 0
    var lineStringResult: GeoJsonLineString = MockGeoJsonLineString()
    func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString? {
        lineStringCallCount += 1
        
        return lineStringResult
    }
    
    private(set) var multiPointCallCount = 0
    var multiPointResult: GeoJsonMultiPoint = MockGeoJsonMultiPoint()
    func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint? {
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
