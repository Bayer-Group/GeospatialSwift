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
        public var geoJson: GeoJsonDictionary { return ["type": type.name, "features": features.map { $0.geoJson } ] }
        
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
        public let objectBoundingBox: GeodesicBoundingBox?
        
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
            
            let geometries = features.compactMap { $0.objectGeometries }.flatMap { $0 }
            
            self.objectGeometries = geometries.count > 0 ? geometries : nil
            
            objectBoundingBox = BoundingBox.best(geometries.compactMap { $0.objectBoundingBox })
        }
        
        public func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double? {
            return features.compactMap { $0.objectDistance(to: point, errorDistance: errorDistance) }.min()
        }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return features.first { $0.contains(point, errorDistance: errorDistance) } != nil }
    }
}
