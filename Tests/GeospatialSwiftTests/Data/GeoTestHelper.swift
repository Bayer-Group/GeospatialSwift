@testable import GeospatialSwift

class GeoTestHelper {
    static private let geoJsonHandler = GeoJson()
    
    static func parse(_ geoJson: GeoJsonDictionary) -> GeoJsonObject { geoJsonHandler.parse(validatedGeoJson: geoJson) }
    
    static func simplePoint(_ longitude: Double, _ latitude: Double, _ altitude: Double? = nil) -> SimplePoint { SimplePoint(longitude: longitude, latitude: latitude, altitude: altitude) }
    
    static func point(_ longitude: Double, _ latitude: Double, _ altitude: Double? = nil) -> Point { geoJsonHandler.point(longitude: longitude, latitude: latitude, altitude: altitude) }
    
    static func multiPoint(_ points: [GeoJson.Point]) -> MultiPoint { geoJsonHandler.multiPoint(points: points).success! }
    
    static func lineString(_ points: [GeoJson.Point]) -> LineString { geoJsonHandler.lineString(points: points).success! }
    
    static func multiLineString(_ lineStrings: [GeoJson.LineString]) -> MultiLineString { geoJsonHandler.multiLineString(lineStrings: lineStrings).success! }
    
    static func polygon(_ mainRing: GeoJson.LineString, _ negativeRings: [GeoJson.LineString] = []) -> Polygon { geoJsonHandler.polygon(mainRing: mainRing, negativeRings: negativeRings).success! }
    
    static func multiPolygon(_ polygons: [GeoJson.Polygon]) -> MultiPolygon { geoJsonHandler.multiPolygon(polygons: polygons).success! }
    
    static func geometryCollection(_ geometries: [GeoJsonGeometry]) -> GeometryCollection { geoJsonHandler.geometryCollection(geometries: geometries) }
    
    static func feature(_ geometry: GeoJsonGeometry?, _ id: Any? = nil, _ properties: GeoJsonDictionary? = nil) -> Feature { geoJsonHandler.feature(geometry: geometry, id: id, properties: properties).success! }
    
    static func featureCollection(_ features: [GeoJson.Feature]) -> FeatureCollection { geoJsonHandler.featureCollection(features: features).success! }
}
