public protocol GeoJsonProtocol {
    func parse(geoJson: GeoJsonDictionary) -> Result<GeoJsonObject, InvalidGeoJson>
    func parse(validatedGeoJson: GeoJsonDictionary) -> GeoJsonObject
    
    // GeoJsonObject Factory methods
    func featureCollection(features: [GeoJsonFeature]) -> Result<GeoJsonFeatureCollection, InvalidGeoJson>
    func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> Result<GeoJsonFeature, InvalidGeoJson>
    func geometryCollection(geometries: [GeoJsonGeometry]?) -> GeoJsonGeometryCollection
    func multiPolygon(polygons: [GeoJsonPolygon]) -> Result<GeoJsonMultiPolygon, InvalidGeoJson>
    func polygon(mainRing: GeoJsonLineString, negativeRings: [GeoJsonLineString]) -> Result<GeoJsonPolygon, InvalidGeoJson>
    func multiLineString(lineStrings: [GeoJsonLineString]) -> Result<GeoJsonMultiLineString, InvalidGeoJson>
    func lineString(points: [GeoJsonPoint]) -> Result<GeoJsonLineString, InvalidGeoJson>
    func multiPoint(points: [GeoJsonPoint]) -> Result<GeoJsonMultiPoint, InvalidGeoJson>
    func point(longitude: Double, latitude: Double, altitude: Double?) -> GeoJsonPoint
    func point(longitude: Double, latitude: Double) -> GeoJsonPoint
}

public struct GeoJson: GeoJsonProtocol {
    internal static let parser = GeoJsonParser()
    
    internal static func coordinates(geoJson: GeoJsonDictionary) -> [Any]? { geoJson["coordinates"] as? [Any] }
    
    /**
     Parses a GeoJsonDictionary into a GeoJsonObject.
     
     - geoJson: An JSON dictionary conforming to the GeoJson current spcification.
     
     - returns: A successfully parsed GeoJsonObject or nil if the specification was not correct
     */
    public func parse(geoJson: GeoJsonDictionary) -> Result<GeoJsonObject, InvalidGeoJson> { GeoJson.parser.geoJsonObject(fromGeoJson: geoJson) }
    
    /**
     Parses a validated GeoJsonDictionary into a GeoJsonObject.
     Assumes validated GeoJson for performance and will crash otherwise!
     
     - geoJson: An JSON dictionary conforming to the GeoJson current spcification.
     
     - returns: A GeoJsonObject or nil if the specification was not correct
     */
    public func parse(validatedGeoJson: GeoJsonDictionary) -> GeoJsonObject { GeoJson.parser.geoJsonObject(fromValidatedGeoJson: validatedGeoJson) }
}
