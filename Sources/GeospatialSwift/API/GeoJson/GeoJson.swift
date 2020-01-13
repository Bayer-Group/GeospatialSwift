public protocol GeoJsonProtocol {
    func parse(geoJson: GeoJsonDictionary) -> GeoJsonObject?
    
    // GeoJsonObject Factory methods
    func featureCollection(features: [GeoJsonFeature]) -> GeoJsonFeatureCollection?
    func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> GeoJsonFeature?
    func geometryCollection(geometries: [GeoJsonGeometry]?) -> GeoJsonGeometryCollection
    func multiPolygon(polygons: [GeoJsonPolygon]) -> GeoJsonMultiPolygon?
    func polygon(linearRings: [GeoJsonLineString]) -> GeoJsonPolygon?
    func multiLineString(lineStrings: [GeoJsonLineString]) -> GeoJsonMultiLineString?
    func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString?
    func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint?
    func point(longitude: Double, latitude: Double, altitude: Double?) -> GeoJsonPoint
    func point(longitude: Double, latitude: Double) -> GeoJsonPoint
}

public struct GeoJson: GeoJsonProtocol {
    internal static let parser = GeoJsonParser()
    
    /**
     Parses a GeoJsonDictionary into a GeoJsonObject.
     
     - geoJson: An JSON dictionary conforming to the GeoJson current spcification.
     
     - returns: A successfully parsed GeoJsonObject or nil if the specification was not correct
     */
    public func parse(geoJson: GeoJsonDictionary) -> GeoJsonObject? { GeoJson.parser.geoJsonObject(from: geoJson) }
}
