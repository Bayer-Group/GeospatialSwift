internal typealias FeatureCollection = GeoJson.FeatureCollection

public protocol GeoJsonFeatureCollection: GeoJsonObject {
    var features: [GeoJsonFeature] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonFeatureCollection
     */
    public func featureCollection(features: [GeoJsonFeature]) -> GeoJsonFeatureCollection? {
        return FeatureCollection(features: features)
    }
    
    public struct FeatureCollection: GeoJsonFeatureCollection {
        public let type: GeoJsonObjectType = .featureCollection
        public var geoJson: GeoJsonDictionary { return ["type": type.rawValue, "features": features.map { $0.geoJson } ] }
        
        public var description: String {
            return """
            FeatureCollection: \(
            """
            (\n\(features.enumerated().map { "Line \($0) - \($1)" }.joined(separator: ",\n"))
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let features: [GeoJsonFeature]
        
        public let objectGeometries: [GeoJsonGeometry]?
        public let objectBoundingBox: GeoJsonBoundingBox?
        
        internal init?(geoJsonDictionary: GeoJsonDictionary) {
            guard let featuresJson = geoJsonDictionary["features"] as? [GeoJsonDictionary] else { Log.warning("A valid FeatureCollection must have a \"features\" key: String : \(geoJsonDictionary)"); return nil }
            
            var features = [GeoJsonFeature]()
            for featureJson in featuresJson {
                if let feature = Feature(geoJsonDictionary: featureJson) {
                    features.append(feature)
                } else {
                    Log.warning("Invalid Feature in FeatureCollection")
                    return nil
                }
            }
            
            self.init(features: features)
        }
        
        fileprivate init?(features: [GeoJsonFeature]) {
            guard features.count >= 1 else { Log.warning("A valid FeatureCollection must have at least one feature."); return nil }
            
            self.features = features
            
            #if swift(>=4.1)
            let geometries = features.compactMap { $0.objectGeometries }.flatMap { $0 }
            #else
            let geometries = features.flatMap { $0.objectGeometries }.flatMap { $0 }
            #endif
            
            self.objectGeometries = geometries.count > 0 ? geometries : nil
            
            #if swift(>=4.1)
            objectBoundingBox = BoundingBox.best(geometries.compactMap { $0.objectBoundingBox })
            #else
            objectBoundingBox = BoundingBox.best(geometries.flatMap { $0.objectBoundingBox })
            #endif
        }
        
        public func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double? {
            #if swift(>=4.1)
            return features.compactMap { $0.objectDistance(to: point, errorDistance: errorDistance) }.min()
            #else
            return features.flatMap { $0.objectDistance(to: point, errorDistance: errorDistance) }.min()
            #endif
        }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return features.first { $0.contains(point, errorDistance: errorDistance) } != nil }
    }
}
