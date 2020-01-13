import Foundation

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
        
        internal init?(geoJsonDictionary: GeoJsonDictionary) {
            let id = geoJsonDictionary["id"] as? String ?? (geoJsonDictionary["id"] as? Double)?.description ?? (geoJsonDictionary["id"] as? Int)?.description
            
            let properties = geoJsonDictionary["properties"] as? GeoJsonDictionary
            
            if geoJsonDictionary["geometry"] is NSNull { self.init(geometry: nil, id: id, properties: properties); return }
            
            guard let geometryJson = geoJsonDictionary["geometry"] as? GeoJsonDictionary else { Log.warning("A valid Feature must have a \"geometry\" key: String : \(geoJsonDictionary)"); return nil }
            
            guard let geometry = parser.geoJsonObject(from: geometryJson) as? GeoJsonGeometry else { Log.warning("Feature must contain a valid geometry"); return nil }
            
            self.init(geometry: geometry, id: id, properties: properties)
        }
        
        fileprivate init?(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) {
            guard id == nil || id is String || id is Double || id is Int else { return nil }
            
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
