public protocol GeoJsonFeatureCollection: GeoJsonObject {
    var features: [GeoJsonFeature] { get }
}

extension GeoJson {
    /**
     Creates a GeoJsonFeatureCollection
     */
    public func featureCollection(features: [GeoJsonFeature]) -> GeoJsonFeatureCollection? { FeatureCollection(features: features) }
    
    public struct FeatureCollection: GeoJsonFeatureCollection {
        public let type: GeoJsonObjectType = .featureCollection
        
        public let features: [GeoJsonFeature]
        
        internal static func invalidReasons(geoJson: GeoJsonDictionary) -> [String]? {
            guard let featuresJson = geoJson["features"] as? [GeoJsonDictionary] else { return ["A valid FeatureCollection must have a \"features\" key"] }
            
            guard featuresJson.count >= 1 else { return ["A valid FeatureCollection must have at least one feature"] }
            
            return featuresJson.compactMap { parser.invalidReasons(fromGeoJson: $0, type: .feature) }.flatMap { $0 }.nilIfEmpty.flatMap { ["Invalid Feature in FeatureCollection"] + $0 }
        }
        
        internal init(geoJson: GeoJsonDictionary) {
            // swiftlint:disable:next force_cast
            let featuresJson = geoJson["features"] as! [GeoJsonDictionary]
            
            features = featuresJson.map { Feature(geoJson: $0) }
        }
        
        fileprivate init?(features: [GeoJsonFeature]) {
            guard features.count >= 1 else { Log.warning("A valid FeatureCollection must have at least one feature"); return nil }
            
            self.features = features
        }
    }
}

extension GeoJson.FeatureCollection {
    public var geoJson: GeoJsonDictionary { ["type": type.name, "features": features.map { $0.geoJson } ] }
    
    public var objectGeometries: [GeoJsonGeometry]? { features.compactMap { $0.objectGeometries }.flatMap { $0 }.nilIfEmpty }
    
    public var objectBoundingBox: GeodesicBoundingBox? { objectGeometries.flatMap { BoundingBox.best($0.compactMap { $0.objectBoundingBox }) } }
    
    public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { features.compactMap { $0.objectDistance(to: point, tolerance: tolerance) }.min() }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { features.first { $0.contains(point, tolerance: tolerance) } != nil }
}
