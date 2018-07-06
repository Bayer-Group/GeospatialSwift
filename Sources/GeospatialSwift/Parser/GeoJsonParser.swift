internal protocol GeoJsonParserProtocol {
    func geoJsonObject(from geoJson: GeoJsonDictionary) -> GeoJsonObject?
}

internal struct GeoJsonParser: GeoJsonParserProtocol {
    // TODO does not handle optional "bbox" or "crs" members
    func geoJsonObject(from geoJsonDictionary: GeoJsonDictionary) -> GeoJsonObject? {
        guard let type = geoJsonObjectType(geoJsonDictionary: geoJsonDictionary) else { return nil }
        
        switch type {
        case .feature:
            return GeoJson.Feature(geoJsonDictionary: geoJsonDictionary)
        case .featureCollection:
            return GeoJson.FeatureCollection(geoJsonDictionary: geoJsonDictionary)
        default: return geometry(geoJsonDictionary: geoJsonDictionary, geoJsonObjectType: type)
        }
    }
}

private extension GeoJsonParser {
    private func geoJsonObjectType(geoJsonDictionary: GeoJsonDictionary) -> GeoJsonObjectType? {
        guard let typeString = geoJsonDictionary["type"] as? String else { Log.warning("A valid geoJson must have a \"type\" key: String : \(geoJsonDictionary)"); return nil }
        guard let type = GeoJsonObjectType(name: typeString) else { Log.warning("Invalid GeoJson Geometry type: \(typeString)"); return nil }
        
        return type
    }
    
    private func geometry(geoJsonDictionary: GeoJsonDictionary, geoJsonObjectType: GeoJsonObjectType) -> GeoJsonGeometry? {
        if geoJsonObjectType == .geometryCollection { return GeoJson.GeometryCollection(geoJsonDictionary: geoJsonDictionary) }
        
        guard let coordinates = geoJsonDictionary["coordinates"] as? [Any] else { Log.warning("A valid GeoJson Coordinates Geometry must have a valid \"coordinates\" array: String : \(geoJsonDictionary)"); return nil }
        
        switch geoJsonObjectType {
        case .point:
            return GeoJson.Point(coordinatesJson: coordinates)
        case .multiPoint:
            return GeoJson.MultiPoint(coordinatesJson: coordinates)
        case .lineString:
            return GeoJson.LineString(coordinatesJson: coordinates)
        case .multiLineString:
            return GeoJson.MultiLineString(coordinatesJson: coordinates)
        case .polygon:
            return GeoJson.Polygon(coordinatesJson: coordinates)
        case .multiPolygon:
            return GeoJson.MultiPolygon(coordinatesJson: coordinates)
        default:
            Log.warning("\(geoJsonObjectType.name) is not a valid Coordinates Geometry.")
            return nil
        }
    }
}
