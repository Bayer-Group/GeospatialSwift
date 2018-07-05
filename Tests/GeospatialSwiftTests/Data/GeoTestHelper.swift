@testable import GeospatialSwift

// swiftlint:disable force_cast
class GeoTestHelper {
    static private let geoJson = GeoJson()
    
    static func parse(_ geoJsonDictionary: GeoJsonDictionary) -> GeoJsonObject {
        return geoJson.parse(geoJson: geoJsonDictionary)!
    }
    
    static func simplePoint(_ longitude: Double, _ latitude: Double, _ altitude: Double? = nil) -> SimplePoint {
        return SimplePoint(longitude: longitude, latitude: latitude, altitude: altitude)
    }
    
    static func point(_ longitude: Double, _ latitude: Double, _ altitude: Double? = nil) -> Point {
        return geoJson.point(longitude: longitude, latitude: latitude, altitude: altitude) as! Point
    }
    
    static func multiPoint(_ points: [GeoJsonPoint]) -> MultiPoint {
        return geoJson.multiPoint(points: points) as! MultiPoint
    }
    
    static func lineString(_ points: [GeoJsonPoint]) -> LineString {
        return geoJson.lineString(points: points) as! LineString
    }
    
    static func multiLineString(_ lineStrings: [GeoJsonLineString]) -> MultiLineString {
        return geoJson.multiLineString(lineStrings: lineStrings) as! MultiLineString
    }
    
    static func polygon(_ linearRings: [GeoJsonLineString]) -> Polygon {
        return geoJson.polygon(linearRings: linearRings) as! Polygon
    }
    
    static func multiPolygon(_ polygons: [GeoJsonPolygon]) -> MultiPolygon {
        return geoJson.multiPolygon(polygons: polygons) as! MultiPolygon
    }
    
    static func geometryCollection(_ geometries: [GeoJsonGeometry]? = nil) -> GeometryCollection {
        return geoJson.geometryCollection(geometries: geometries) as! GeometryCollection
    }
    
    static func feature(_ geometry: GeoJsonGeometry?, _ id: Any? = nil, _ properties: GeoJsonDictionary? = nil) -> Feature {
        return geoJson.feature(geometry: geometry, id: id, properties: properties) as! Feature
    }
    
    static func featureCollection(_ features: [GeoJsonFeature]) -> FeatureCollection {
        return geoJson.featureCollection(features: features) as! FeatureCollection
    }
}
