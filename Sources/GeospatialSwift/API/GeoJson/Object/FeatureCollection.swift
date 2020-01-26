extension GeoJson {
    /**
     Creates a FeatureCollection
     */
    public func featureCollection(features: [Feature]) -> Result<FeatureCollection, InvalidGeoJson> {
        guard features.count >= 1 else { return .failure(.init(reason: "A valid FeatureCollection must have at least one feature")) }
        
        return .success(FeatureCollection(features: features))
    }
    
    public struct FeatureCollection: GeoJsonObject {
        public let type: GeoJsonObjectType = .featureCollection
        
        public let features: [Feature]
        
        internal init(geoJson: GeoJsonDictionary) {
            // swiftlint:disable:next force_cast
            let featuresJson = geoJson["features"] as! [GeoJsonDictionary]
            
            features = featuresJson.map { Feature(geoJson: $0) }
        }
        
        fileprivate init(features: [Feature]) {
            self.features = features
        }
    }
}

extension GeoJson.FeatureCollection {
    public var geoJson: GeoJsonDictionary { ["type": type.name, "features": features.map { $0.geoJson } ] }
    
    public var objectGeometries: [GeoJsonGeometry] { features.compactMap { $0.objectGeometries }.flatMap { $0 } }
    
    public var objectBoundingBox: GeodesicBoundingBox? { .best(objectGeometries.compactMap { $0.objectBoundingBox }) }
    
    public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { features.compactMap { $0.objectDistance(to: point, tolerance: tolerance) }.min() }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { features.first { $0.contains(point, tolerance: tolerance) } != nil }
}

extension GeoJson.FeatureCollection {
    internal static func validate(geoJson: GeoJsonDictionary) -> InvalidGeoJson? {
        guard let featuresJson = geoJson["features"] as? [GeoJsonDictionary] else { return .init(reason: "A valid FeatureCollection must have a \"features\" key") }
        
        guard featuresJson.count >= 1 else { return .init(reason: "A valid FeatureCollection must have at least one feature") }
        
        let validateFeatures = featuresJson.reduce(nil) { $0 + GeoJson.parser.validate(geoJson: $1, type: .feature) }
        
        return validateFeatures.flatMap { .init(reason: "Invalid Feature(s) in FeatureCollection") + $0 }
    }
}
