import Foundation

internal typealias Feature = GeoJson.Feature

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
    public func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> GeoJsonFeature? {
        return Feature(geometry: geometry, id: id, properties: properties)
    }
    
    public struct Feature: GeoJsonFeature {
        public let type: GeoJsonObjectType = .feature
        public var geoJson: GeoJsonDictionary {
            var geoJson: GeoJsonDictionary = ["type": type.rawValue, "geometry": geometry?.geoJson ?? NSNull(), "properties": properties ?? NSNull()]
            if let id = id { geoJson["id"] = id }
            return geoJson
        }
        
        public var id: Any? { return idString ?? idDouble ?? idInt }
        public var idAsString: String? { return idString ?? idDouble?.description ?? idInt?.description }
        
        public var description: String {
            return """
            Feature: \(
            """
            (\n\(geometry != nil ? "Geometry - \(geometry!)" : "null")
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let geometry: GeoJsonGeometry?
        public let properties: GeoJsonDictionary?
        
        public let objectGeometries: [GeoJsonGeometry]?
        public let objectBoundingBox: GeoJsonBoundingBox?
        
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
            
            objectGeometries = geometry != nil ? [geometry!] : nil
            
            objectBoundingBox = geometry?.objectBoundingBox
        }
        
        public func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double? { return geometry?.objectDistance(to: point, errorDistance: errorDistance) }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return geometry?.contains(point, errorDistance: errorDistance) ?? false }
    }
}
