import class Foundation.NSNull

extension GeoJson {
    /**
     Creates a Feature
     */
    public func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> Result<Feature, InvalidGeoJson> {
        guard id == nil || id is NSNull || id is String || id is Double || id is Int else { return .failure(.init(reason: "Id must be of type null, String, Double, or Int")) }
        
        return .success(Feature(geometry: geometry, id: id, properties: properties))
    }
    
    public struct Feature: GeoJsonObject {
        public let type: GeoJsonObjectType = .feature
        
        public let geometry: GeoJsonGeometry?
        public let properties: GeoJsonDictionary?
        
        internal let idString: String?
        internal let idDouble: Double?
        internal let idInt: Int?
        
        internal init(geoJson: GeoJsonDictionary) {
            let id: Any? = geoJson["id"]
            let geometryJson = geoJson["geometry"] as? GeoJsonDictionary
            let propertiesJson = geoJson["properties"] as? GeoJsonDictionary
            
            // swiftlint:disable:next force_cast
            geometry = geometryJson.flatMap { parser.geoJsonGeometry(fromValidatedGeoJson: $0) }
            idString = id as? String
            idDouble = id as? Double
            idInt = id as? Int
            properties = propertiesJson
        }
        
        fileprivate init(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) {
            self.geometry = geometry
            self.idString = id as? String
            self.idDouble = id as? Double
            self.idInt = id as? Int
            self.properties = properties
        }
    }
}

extension GeoJson.Feature {
    public var geoJson: GeoJsonDictionary {
        var geoJson: GeoJsonDictionary = ["type": type.name, "geometry": geometry?.geoJson ?? NSNull(), "properties": properties ?? NSNull()]
        if let id = id { geoJson["id"] = id }
        return geoJson
    }
    
    public var id: Any? { idString ?? idDouble ?? idInt }
    public var idAsString: String? { idString ?? idDouble?.description ?? idInt?.description }
    
    public var objectGeometries: [GeoJsonGeometry] { geometry.flatMap { [$0] } ?? [] }
    public var objectBoundingBox: GeodesicBoundingBox? { geometry?.objectBoundingBox }
    
    public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { geometry?.objectDistance(to: point, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geometry?.contains(point, tolerance: tolerance) ?? false }
    
    public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] { geometry.flatMap { $0.simpleViolations(tolerance: tolerance) } ?? [] }
}

extension GeoJson.Feature {
    internal static func validate(geoJson: GeoJsonDictionary) -> InvalidGeoJson? {
        func validateGeometry() -> InvalidGeoJson? {
            guard let geometryJson = geoJson["geometry"] else { return .init(reason: "A valid Feature must have a \"geometry\" key") }
            
            // No geometry value is valid
            if geometryJson is NSNull { return nil }
            
            guard let geometryGeoJson = geometryJson as? GeoJsonDictionary else { return .init(reason: "Not a valid feature geometry") }
            
            return GeoJson.parser.validateGeoJsonGeometry(geoJson: geometryGeoJson).flatMap { .init(reason: "Invalid Geometry in Feature") + $0 }
        }
        
        func validateId() -> InvalidGeoJson? {
            guard let id = geoJson["id"] else { return nil }
            
            return (id is NSNull || id is String || id is Double || id is Int) ? nil : .init(reason: "Id must be of type NSNull, String, Double, or Int")
        }
        
        return validateGeometry() + validateId()
    }
}
