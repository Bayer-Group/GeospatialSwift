@testable import GeospatialSwift

// swiftlint:disable force_cast
class GeoTestHelper {
    static private let geoJson = GeoJson()
    
    static func parse(_ geoJsonDictionary: GeoJsonDictionary) -> GeoJsonObject { geoJson.parse(geoJson: geoJsonDictionary)! }
    
    static func simplePoint(_ longitude: Double, _ latitude: Double, _ altitude: Double? = nil) -> SimplePoint { SimplePoint(longitude: longitude, latitude: latitude, altitude: altitude) }
    
    static func point(_ longitude: Double, _ latitude: Double, _ altitude: Double? = nil) -> Point { geoJson.point(longitude: longitude, latitude: latitude, altitude: altitude) as! Point }
    
    static func multiPoint(_ points: [GeoJsonPoint]) -> MultiPoint { geoJson.multiPoint(points: points) as! MultiPoint }
    
    static func lineString(_ points: [GeoJsonPoint]) -> LineString { geoJson.lineString(points: points) as! LineString }
    
    static func multiLineString(_ lineStrings: [GeoJsonLineString]) -> MultiLineString { geoJson.multiLineString(lineStrings: lineStrings) as! MultiLineString }
    
    static func polygon(_ linearRings: [GeoJsonLineString]) -> Polygon { geoJson.polygon(linearRings: linearRings) as! Polygon }
    
    static func multiPolygon(_ polygons: [GeoJsonPolygon]) -> MultiPolygon { geoJson.multiPolygon(polygons: polygons) as! MultiPolygon }
    
    static func geometryCollection(_ geometries: [GeoJsonGeometry]? = nil) -> GeometryCollection { geoJson.geometryCollection(geometries: geometries) as! GeometryCollection }
    
    static func feature(_ geometry: GeoJsonGeometry?, _ id: Any? = nil, _ properties: GeoJsonDictionary? = nil) -> Feature { geoJson.feature(geometry: geometry, id: id, properties: properties) as! Feature }
    
    static func featureCollection(_ features: [GeoJsonFeature]) -> FeatureCollection { geoJson.featureCollection(features: features) as! FeatureCollection }
}
