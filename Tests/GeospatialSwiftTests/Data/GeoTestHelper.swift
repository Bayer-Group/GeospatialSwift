@testable import GeospatialSwift

// swiftlint:disable force_cast
class GeoTestHelper {
    static private let geoJsonHandler = GeoJson()
    
    static func parse(_ geoJson: GeoJsonDictionary) -> GeoJsonObject { geoJsonHandler.parse(geoJson: geoJson)! }
    
    static func simplePoint(_ longitude: Double, _ latitude: Double, _ altitude: Double? = nil) -> SimplePoint { SimplePoint(longitude: longitude, latitude: latitude, altitude: altitude) }
    
    static func point(_ longitude: Double, _ latitude: Double, _ altitude: Double? = nil) -> Point { geoJsonHandler.point(longitude: longitude, latitude: latitude, altitude: altitude) as! Point }
    
    static func multiPoint(_ points: [GeoJsonPoint]) -> MultiPoint { geoJsonHandler.multiPoint(points: points) as! MultiPoint }
    
    static func lineString(_ points: [GeoJsonPoint]) -> LineString { geoJsonHandler.lineString(points: points) as! LineString }
    
    static func multiLineString(_ lineStrings: [GeoJsonLineString]) -> MultiLineString { geoJsonHandler.multiLineString(lineStrings: lineStrings) as! MultiLineString }
    
    static func polygon(_ mainRing: GeoJsonLineString, _ negativeRings: [GeoJsonLineString] = []) -> Polygon { geoJsonHandler.polygon(mainRing: mainRing, negativeRings: negativeRings) as! Polygon }
    
    static func multiPolygon(_ polygons: [GeoJsonPolygon]) -> MultiPolygon { geoJsonHandler.multiPolygon(polygons: polygons) as! MultiPolygon }
    
    static func geometryCollection(_ geometries: [GeoJsonGeometry]? = nil) -> GeometryCollection { geoJsonHandler.geometryCollection(geometries: geometries) as! GeometryCollection }
    
    static func feature(_ geometry: GeoJsonGeometry?, _ id: Any? = nil, _ properties: GeoJsonDictionary? = nil) -> Feature { geoJsonHandler.feature(geometry: geometry, id: id, properties: properties) as! Feature }
    
    static func featureCollection(_ features: [GeoJsonFeature]) -> FeatureCollection { geoJsonHandler.featureCollection(features: features) as! FeatureCollection }
}
