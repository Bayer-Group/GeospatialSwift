internal protocol GeoJsonParserProtocol {
    func geoJsonObject(from geoJson: GeoJsonDictionary) -> GeoJsonObject?
}

internal struct GeoJsonParser: GeoJsonParserProtocol {
    let logger: LoggerProtocol
    let geodesicCalculator: GeodesicCalculatorProtocol
    
    // TODO does not handle optional "bbox" or "crs" members
    func geoJsonObject(from geoJsonDictionary: GeoJsonDictionary) -> GeoJsonObject? {
        guard let type = geoJsonObjectType(geoJsonDictionary: geoJsonDictionary) else { return nil }
        
        switch type {
        case .feature:
            return Feature(logger: logger, geoJsonParser: self, geoJsonDictionary: geoJsonDictionary)
        case .featureCollection:
            return FeatureCollection(logger: logger, geoJsonParser: self, geoJsonDictionary: geoJsonDictionary)
        default: return geometry(geoJsonDictionary: geoJsonDictionary, geoJsonObjectType: type)
        }
    }
}

internal extension GeoJsonParser {
    fileprivate func geoJsonObjectType(geoJsonDictionary: GeoJsonDictionary) -> GeoJsonObjectType? {
        guard let typeString = geoJsonDictionary["type"] as? String else { logger.error("A valid geoJson must have a \"type\" key: String : \(geoJsonDictionary)"); return nil }
        guard let type = GeoJsonObjectType(rawValue: typeString) else { logger.error("Invalid GeoJson Geometry type: \(typeString)"); return nil }
        
        return type
    }
    
    fileprivate func geometry(geoJsonDictionary: GeoJsonDictionary, geoJsonObjectType: GeoJsonObjectType) -> GeoJsonGeometry? {
        if geoJsonObjectType == .geometryCollection { return GeometryCollection(logger: logger, geoJsonParser: self, geoJsonDictionary: geoJsonDictionary) }
        
        guard let coordinates = geoJsonDictionary["coordinates"] as? [Any] else { logger.error("A valid GeoJson Coordinates Geometry must have a valid \"coordinates\" array: String : \(geoJsonDictionary)"); return nil }
        
        switch geoJsonObjectType {
        case .point:
            return Point(logger: logger, geodesicCalculator: geodesicCalculator, coordinatesJson: coordinates)
        case .multiPoint:
            return MultiPoint(logger: logger, geodesicCalculator: geodesicCalculator, coordinatesJson: coordinates)
        case .lineString:
            return LineString(logger: logger, geodesicCalculator: geodesicCalculator, coordinatesJson: coordinates)
        case .multiLineString:
            return MultiLineString(logger: logger, geodesicCalculator: geodesicCalculator, coordinatesJson: coordinates)
        case .polygon:
            return Polygon(logger: logger, geodesicCalculator: geodesicCalculator, coordinatesJson: coordinates)
        case .multiPolygon:
            return MultiPolygon(logger: logger, geodesicCalculator: geodesicCalculator, coordinatesJson: coordinates)
        default:
            logger.error("\(geoJsonObjectType.rawValue) is not a valid Coordinates Geometry.")
            return nil
        }
    }
}
