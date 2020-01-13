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
        
        public let features: [GeoJsonFeature]
        
        public let objectGeometries: [GeoJsonGeometry]?
        public var objectBoundingBox: GeodesicBoundingBox? { objectGeometries.flatMap { BoundingBox.best($0.compactMap { $0.objectBoundingBox }) } }
        
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
        }
        
        public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? {
            return features.compactMap { $0.objectDistance(to: point, tolerance: tolerance) }.min()
        }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { return features.first { $0.contains(point, tolerance: tolerance) } != nil }
    }
}
