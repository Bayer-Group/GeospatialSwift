public struct GeoJson {
    internal static let parser = GeoJsonParser()
    
    internal static func coordinates(geoJson: GeoJsonDictionary) -> [Any]? { geoJson["coordinates"] as? [Any] }
    
    /**
     Parses a GeoJsonDictionary into a GeoJsonObject.
     
     - geoJson: An JSON dictionary conforming to the GeoJson current spcification.
     
     - returns: A successfully parsed GeoJsonObject or nil if the specification was not correct
     */
    public func parseObject(fromGeoJson geoJson: GeoJsonDictionary) -> Result<GeoJsonObject, InvalidGeoJson> { GeoJson.parser.geoJsonObject(fromGeoJson: geoJson) }
    public func parseCoordinatesGeometry(fromGeoJson geoJson: GeoJsonDictionary) -> Result<GeoJsonCoordinatesGeometry, InvalidGeoJson> { GeoJson.parser.geoJsonCoordinatesGeometry(fromGeoJson: geoJson) }
    
    /**
     Parses a validated GeoJsonDictionary into a GeoJsonObject.
     Assumes validated GeoJson for performance and will crash if invalid!
     
     - geoJson: An JSON dictionary conforming to the GeoJson current spcification.
     
     - returns: A GeoJsonObject or nil if the specification was not correct
     */
    public func parseObject(fromValidatedGeoJson geoJson: GeoJsonDictionary) -> GeoJsonObject { GeoJson.parser.geoJsonObject(fromValidatedGeoJson: geoJson) }
    public func parseCoordinatesGeometry(fromValidatedGeoJson geoJson: GeoJsonDictionary) -> GeoJsonCoordinatesGeometry { GeoJson.parser.geoJsonCoordinatesGeometry(fromValidatedGeoJson: geoJson) }
}
