internal struct GeoJsonParser {
    func validateGeoJsonObject(geoJson: GeoJsonDictionary, validTypes: [GeoJsonObjectType]? = nil) -> InvalidGeoJson? {
        let typeResult = self.geoJsonObjectTypeResult(geoJson: geoJson)
        
        switch typeResult {
        case .success(let type):
            if let invalidGeoJson = validateGeoJsonObject(geoJson: geoJson, type: type) { return invalidGeoJson }
            
            guard validTypes.flatMap({ $0.contains(type) }) ?? true else { return .init(reason: "Type not allowed: \(type)") }
            
            return nil
        case .failure(let invalidGeoJson): return invalidGeoJson
        }
    }
    
    func validateGeoJsonGeometry(geoJson: GeoJsonDictionary, validTypes: [GeoJsonObjectType]? = nil) -> InvalidGeoJson? {
        let typeResult = self.geoJsonObjectTypeResult(geoJson: geoJson)
        
        switch typeResult {
        case .success(let type):
            if let invalidGeoJson = validateGeoJsonGeometry(geoJson: geoJson, type: type) { return invalidGeoJson }
            
            guard validTypes.flatMap({ $0.contains(type) }) ?? true else { return .init(reason: "Type not allowed: \(type)") }
            
            return nil
        case .failure(let invalidGeoJson): return invalidGeoJson
        }
    }
    
    func validateGeoJsonCoordinatesGeometry(geoJson: GeoJsonDictionary, validTypes: [GeoJsonObjectType]? = nil) -> InvalidGeoJson? {
        let typeResult = self.geoJsonObjectTypeResult(geoJson: geoJson)
        
        switch typeResult {
        case .success(let type):
            if let invalidGeoJson = validateGeoJsonCoordinatesGeometry(geoJson: geoJson, type: type) { return invalidGeoJson }
            
            guard validTypes.flatMap({ $0.contains(type) }) ?? true else { return .init(reason: "Type not allowed: \(type)") }
            
            return nil
        case .failure(let invalidGeoJson): return invalidGeoJson
        }
    }
    
    func geoJsonObject(fromGeoJson geoJson: GeoJsonDictionary) -> Result<GeoJsonObject, InvalidGeoJson> {
        let typeResult = self.geoJsonObjectTypeResult(geoJson: geoJson)
        
        switch typeResult {
        case .success(let type):
            if let invalidGeoJson = validateGeoJsonObject(geoJson: geoJson, type: type) { return .failure(invalidGeoJson) }
            
            return .success(geoJsonObject(validatedGeoJson: geoJson, type: type))
        case .failure(let invalidGeoJson): return .failure(invalidGeoJson)
        }
    }
    
    func geoJsonObject(fromValidatedGeoJson geoJson: GeoJsonDictionary) -> GeoJsonObject {
        return geoJsonObject(validatedGeoJson: geoJson, type: geoJsonObjectTypeResult(geoJson: geoJson).success!)
    }
    
    func geoJsonGeometry(fromGeoJson geoJson: GeoJsonDictionary) -> Result<GeoJsonGeometry, InvalidGeoJson> {
        let typeResult = self.geoJsonObjectTypeResult(geoJson: geoJson)
        
        switch typeResult {
        case .success(let type):
            if let invalidGeoJson = validateGeoJsonGeometry(geoJson: geoJson, type: type) { return .failure(invalidGeoJson) }
            
            return .success(geoJsonGeometry(validatedGeoJson: geoJson, type: type))
        case .failure(let invalidGeoJson): return .failure(invalidGeoJson)
        }
    }
    
    func geoJsonGeometry(fromValidatedGeoJson geoJson: GeoJsonDictionary) -> GeoJsonGeometry {
        return geoJsonGeometry(validatedGeoJson: geoJson, type: geoJsonObjectTypeResult(geoJson: geoJson).success!)
    }
    
    func geoJsonCoordinatesGeometry(fromGeoJson geoJson: GeoJsonDictionary) -> Result<GeoJsonCoordinatesGeometry, InvalidGeoJson> {
        let typeResult = self.geoJsonObjectTypeResult(geoJson: geoJson)
        
        switch typeResult {
        case .success(let type):
            if let invalidGeoJson = validateGeoJsonCoordinatesGeometry(geoJson: geoJson, type: type) { return .failure(invalidGeoJson) }
            
            return .success(geoJsonCoordinatesGeometry(validatedGeoJson: geoJson, type: type))
        case .failure(let invalidGeoJson): return .failure(invalidGeoJson)
        }
    }
    
    func geoJsonCoordinatesGeometry(fromValidatedGeoJson geoJson: GeoJsonDictionary) -> GeoJsonCoordinatesGeometry {
        return geoJsonCoordinatesGeometry(validatedGeoJson: geoJson, type: geoJsonObjectTypeResult(geoJson: geoJson).success!)
    }
}

extension GeoJsonParser {
    private func validateGeoJsonObject(geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> InvalidGeoJson? {
        switch type {
        case .feature: return GeoJson.Feature.validate(geoJson: geoJson)
        case .featureCollection: return GeoJson.FeatureCollection.validate(geoJson: geoJson)
        case .geometryCollection, .point, .multiPoint, .lineString, .multiLineString, .polygon, .multiPolygon:
            return validateGeoJsonGeometry(geoJson: geoJson, type: type)
        }
    }
    
    private func validateGeoJsonGeometry(geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> InvalidGeoJson? {
        switch type {
        case .geometryCollection: return GeoJson.GeometryCollection.validate(geoJson: geoJson)
        case .point, .multiPoint, .lineString, .multiLineString, .polygon, .multiPolygon:
            return validateGeoJsonCoordinatesGeometry(geoJson: geoJson, type: type)
        case .feature, .featureCollection: return .init(reason: "Not a GeoJsonGeometry")
        }
    }
    
    private func validateGeoJsonCoordinatesGeometry(geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> InvalidGeoJson? {
        let coordinatesJson = self.coordinatesJson(geoJson: geoJson)
        
        switch coordinatesJson {
        case .success(let coordinatesJson):
            switch type {
            case .point: return GeoJson.Point.validate(coordinatesJson: coordinatesJson)
            case .multiPoint: return GeoJson.MultiPoint.validate(coordinatesJson: coordinatesJson)
            case .lineString: return GeoJson.LineString.validate(coordinatesJson: coordinatesJson)
            case .multiLineString: return GeoJson.MultiLineString.validate(coordinatesJson: coordinatesJson)
            case .polygon: return GeoJson.Polygon.validate(coordinatesJson: coordinatesJson)
            case .multiPolygon: return GeoJson.MultiPolygon.validate(coordinatesJson: coordinatesJson)
            case .geometryCollection, .feature, .featureCollection: return .init(reason: "Not a GeoJsonCoordinatesGeometry")
            }
        case .failure(let invalidGeoJson): return invalidGeoJson
        }
    }
    
    private func geoJsonObjectTypeResult(geoJson: GeoJsonDictionary) -> Result<GeoJsonObjectType, InvalidGeoJson> {
        guard let typeName = geoJson["type"] as? String else { return .failure(InvalidGeoJson(reason: "A valid geoJson must have a \"type\" key")) }
        
        return GeoJsonObjectType(name: typeName).flatMap { .success($0) } ?? .failure(InvalidGeoJson(reason: "Invalid GeoJson Geometry type: \(typeName)"))
    }
    
    private func geoJsonObject(validatedGeoJson geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> GeoJsonObject {
        switch type {
        case .feature: return GeoJson.Feature(geoJson: geoJson)
        case .featureCollection: return GeoJson.FeatureCollection(geoJson: geoJson)
        case .geometryCollection, .point, .multiPoint, .lineString, .multiLineString, .polygon, .multiPolygon:
            return geoJsonGeometry(validatedGeoJson: geoJson, type: type)
        }
    }
    
    private func geoJsonGeometry(validatedGeoJson geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> GeoJsonGeometry {
        switch type {
        case .geometryCollection: return GeoJson.GeometryCollection(geoJson: geoJson)
        case .point, .multiPoint, .lineString, .multiLineString, .polygon, .multiPolygon:
            return geoJsonCoordinatesGeometry(validatedGeoJson: geoJson, type: type)
        case .feature, .featureCollection: fatalError("Not a GeoJsonGeometry")
        }
    }
    
    private func geoJsonCoordinatesGeometry(validatedGeoJson geoJson: GeoJsonDictionary, type: GeoJsonObjectType) -> GeoJsonCoordinatesGeometry {
        let coordinatesJson = self.coordinatesJson(geoJson: geoJson).success!
        
        switch type {
        case .point: return GeoJson.Point(coordinatesJson: coordinatesJson)
        case .multiPoint: return GeoJson.MultiPoint(coordinatesJson: coordinatesJson)
        case .lineString: return GeoJson.LineString(coordinatesJson: coordinatesJson)
        case .multiLineString: return GeoJson.MultiLineString(coordinatesJson: coordinatesJson)
        case .polygon: return GeoJson.Polygon(coordinatesJson: coordinatesJson)
        case .multiPolygon: return GeoJson.MultiPolygon(coordinatesJson: coordinatesJson)
        case .geometryCollection, .feature, .featureCollection: fatalError("Not a GeoJsonCoordinatesGeometry")
        }
    }
    
    private func coordinatesJson(geoJson: GeoJsonDictionary) -> Result<[Any], InvalidGeoJson> {
        (geoJson["coordinates"] as? [Any]).flatMap { .success($0) } ?? .failure(.init(reason: "A valid GeoJson Coordinates Geometry must have a valid \"coordinates\" array"))
    }
}
