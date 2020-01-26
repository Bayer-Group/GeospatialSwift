internal struct GeoJsonParser {
    func validate(geoJson: GeoJsonDictionary) -> InvalidGeoJson? {
        if let invalidGeoJson = self.typeInvalidReason(geoJson: geoJson) { return invalidGeoJson }
        
        return validate(geoJson: geoJson, type: geoJsonObjectType(geoJson: geoJson)!)
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func validate(geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> InvalidGeoJson? {
        if let invalidReason = self.typeInvalidReason(geoJson: geoJson) { return invalidReason }
        if let invalidReason = self.coordinatesInvalidReason(geoJson: geoJson) { return invalidReason }
        
        switch type {
        case .point:
            return GeoJson.Point.validate(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiPoint:
            return GeoJson.MultiPoint.validate(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .lineString:
            return GeoJson.LineString.validate(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiLineString:
            return GeoJson.MultiLineString.validate(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .polygon:
            return GeoJson.Polygon.validate(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .multiPolygon:
            return GeoJson.MultiPolygon.validate(coordinatesJson: coordinatesJson(geoJson: geoJson)!)
        case .geometryCollection:
            return GeoJson.GeometryCollection.validate(geoJson: geoJson)
        case .feature:
            return GeoJson.Feature.validate(geoJson: geoJson)
        case .featureCollection:
            return GeoJson.FeatureCollection.validate(geoJson: geoJson)
        }
    }
    
    func geoJsonObjectType(geoJson: GeoJsonDictionary) -> GeoJsonObjectType? { (geoJson["type"] as? String).flatMap { GeoJsonObjectType(name: $0) } }
    
    func geoJsonObject(fromGeoJson geoJson: GeoJsonDictionary) -> Result<GeoJsonObject, InvalidGeoJson> {
        if let invalidGeoJson = validate(geoJson: geoJson) { return .failure(invalidGeoJson) }
        
        return .success(geoJsonObject(fromValidatedGeoJson: geoJson))
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
    private func typeInvalidReason(geoJson: GeoJsonDictionary) -> InvalidGeoJson? {
        guard let typeString = geoJson["type"] as? String else { return InvalidGeoJson(reason: "A valid geoJson must have a \"type\" key") }
        
        return geoJsonObjectType(geoJson: geoJson) == nil ? InvalidGeoJson(reason: "Invalid GeoJson Geometry type: \(typeString)") : nil
    }
    
    private func coordinatesInvalidReason(geoJson: GeoJsonDictionary) -> InvalidGeoJson? {
        guard geoJsonObjectType(geoJson: geoJson)!.isCoordinatesGeometry else { return nil }
        
        return coordinatesJson(geoJson: geoJson) == nil ? InvalidGeoJson(reason: "A valid GeoJson Coordinates Geometry must have a valid \"coordinates\" array") : nil
    }
    
    private func coordinatesJson(geoJson: GeoJsonDictionary) -> [Any]? { (geoJson["coordinates"] as? [Any]) }
}
