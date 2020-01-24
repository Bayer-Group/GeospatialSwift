internal protocol GeoJsonParserProtocol {
    func isGeoJsonValid(fromGeoJson geoJson: GeoJsonDictionary) -> Bool
    func invalidReasons(fromGeoJson geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> [String]?
    func geoJsonObjectType(geoJson: GeoJsonDictionary) -> GeoJsonObjectType?
    func geoJsonObject(fromGeoJson geoJson: GeoJsonDictionary) -> GeoJsonObject?
    func geoJsonObject(fromValidatedGeoJson geoJson: GeoJsonDictionary) -> GeoJsonObject
}

internal struct GeoJsonParser: GeoJsonParserProtocol {
    func isGeoJsonValid(fromGeoJson geoJson: GeoJsonDictionary) -> Bool { invalidReasons(fromGeoJson: geoJson) == nil }
    
    private func invalidReasons(fromGeoJson geoJson: GeoJsonDictionary) -> [String]? {
        if let invalidReason = self.typeInvalidReason(geoJson: geoJson) { return [invalidReason] }
        
        return invalidReasons(fromGeoJson: geoJson, type: geoJsonObjectType(geoJson: geoJson)!)
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func invalidReasons(fromGeoJson geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> [String]? {
        if let invalidReason = self.typeInvalidReason(geoJson: geoJson) { return [invalidReason] }
        if let invalidReason = self.coordinatesInvalidReason(geoJson: geoJson) { return [invalidReason] }
        
        switch type {
        case .point:
            return GeoJson.Point.invalidReasons(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiPoint:
            return GeoJson.MultiPoint.invalidReasons(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .lineString:
            return GeoJson.LineString.invalidReasons(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiLineString:
            return GeoJson.MultiLineString.invalidReasons(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .polygon:
            return GeoJson.Polygon.invalidReasons(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiPolygon:
            return GeoJson.MultiPolygon.invalidReasons(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .geometryCollection:
            return GeoJson.GeometryCollection.invalidReasons(geoJson: geoJson)
        case .feature:
            return GeoJson.Feature.invalidReasons(geoJson: geoJson)
        case .featureCollection:
            return GeoJson.FeatureCollection.invalidReasons(geoJson: geoJson)
        }
    }
    
    func geoJsonObjectType(geoJson: GeoJsonDictionary) -> GeoJsonObjectType? { (geoJson["type"] as? String).flatMap { GeoJsonObjectType(name: $0) } }
    
    func geoJsonObject(fromGeoJson geoJson: GeoJsonDictionary) -> GeoJsonObject? {
        guard isGeoJsonValid(fromGeoJson: geoJson) else { return nil }
        
        return geoJsonObject(fromValidatedGeoJson: geoJson)
    }
    
    func geoJsonObject(fromValidatedGeoJson geoJson: GeoJsonDictionary) -> GeoJsonObject {
        switch geoJsonObjectType(geoJson: geoJson)! {
        case .point:
            return GeoJson.Point(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiPoint:
            return GeoJson.MultiPoint(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .lineString:
            return GeoJson.LineString(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiLineString:
            return GeoJson.MultiLineString(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .polygon:
            return GeoJson.Polygon(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiPolygon:
            return GeoJson.MultiPolygon(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .geometryCollection:
            return GeoJson.GeometryCollection(geoJson: geoJson)
        case .feature:
            return GeoJson.Feature(geoJson: geoJson)
        case .featureCollection:
            return GeoJson.FeatureCollection(geoJson: geoJson)
        }
    }
}

private extension GeoJsonParser {
    private func typeInvalidReason(geoJson: GeoJsonDictionary) -> String? {
        guard let typeString = geoJson["type"] as? String else { return "A valid geoJson must have a \"type\" key" }
        
        return geoJsonObjectType(geoJson: geoJson) == nil ? "Invalid GeoJson Geometry type: \(typeString)" : nil
    }
    
    private func coordinatesInvalidReason(geoJson: GeoJsonDictionary) -> String? {
        guard geoJsonObjectType(geoJson: geoJson)!.isCoordinatesGeometry else { return nil }
        
        return coordinatesJson(geoJson: geoJson) == nil ? "A valid GeoJson Coordinates Geometry must have a valid \"coordinates\" array" : nil
    }
    
    private func coordinatesJson(geoJson: GeoJsonDictionary) -> [Any]? { (geoJson["coordinates"] as? [Any]) }
}
