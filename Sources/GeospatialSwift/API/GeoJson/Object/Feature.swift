import class Foundation.NSNull

public protocol GeoJsonFeature: GeoJsonObject {
    var geometry: GeoJsonGeometry? { get }
    var id: Any? { get }
    var idAsString: String? { get }
    var properties: GeoJsonDictionary? { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonFeature
     */
    public func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> GeoJsonFeature? { Feature(geometry: geometry, id: id, properties: properties) }
    
    public struct Feature: GeoJsonFeature {
        public let type: GeoJsonObjectType = .feature
        
        public let geometry: GeoJsonGeometry?
        public let properties: GeoJsonDictionary?
        
        internal let idString: String?
        internal let idDouble: Double?
        internal let idInt: Int?
        
        internal static func invalidReasons(geoJson: GeoJsonDictionary) -> [String]? {
            func geometryInvalidReasons(geoJson: GeoJsonDictionary) -> [String]? {
                guard let geometryJson = geoJson["geometry"] else { return ["A valid Feature must have a \"geometry\" key"] }
                
                if geometryJson is NSNull { return nil }
                
                guard let geometryGeoJson = geometryJson as? GeoJsonDictionary, let type = parser.geoJsonObjectType(geoJson: geometryGeoJson) else { return ["Not a valid feature geometry"] }
                
                guard type.isGeometry else { return ["Not a valid feature geometry: \(type.name)"] }
                
                return parser.invalidReasons(fromGeoJson: geometryGeoJson, type: type)
            }
            
            var invalidReasons: [String] = []
            if geoJson["id"].flatMap({ !($0 is NSNull || $0 is String || $0 is Double || $0 is Int) }) ?? false {
                invalidReasons.append("Id must be of type null, String, Double, or Int")
            }
            
            if let geometryInvalidReasons = geometryInvalidReasons(geoJson: geoJson) {
                invalidReasons.append(contentsOf: geometryInvalidReasons)
            }
            
            return invalidReasons.nilIfEmpty
        }
        
        internal init(geoJson: GeoJsonDictionary) {
            let id: Any? = geoJson["id"]
            let geometryJson = geoJson["geometry"] as? GeoJsonDictionary
            let propertiesJson = geoJson["properties"] as? GeoJsonDictionary
            
            // swiftlint:disable:next force_cast
            geometry = geometryJson.flatMap { (parser.geoJsonObject(fromValidatedGeoJson: $0) as! GeoJsonGeometry) }
            idString = id as? String
            idDouble = id as? Double
            idInt = id as? Int
            properties = propertiesJson
        }
        
        fileprivate init?(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) {
            guard id == nil || id is NSNull || id is String || id is Double || id is Int else { return nil }

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
    
    public var objectGeometries: [GeoJsonGeometry]? { geometry.flatMap { [$0] } }
    public var objectBoundingBox: GeodesicBoundingBox? { geometry?.objectBoundingBox }
    
    public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { geometry?.objectDistance(to: point, tolerance: tolerance) }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { geometry?.contains(point, tolerance: tolerance) ?? false }
}
