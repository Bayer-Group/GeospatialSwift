import class Foundation.NSNull

extension GeoJson {
    /**
     Creates a GeometryCollection
     */
    public func geometryCollection(geometries: [GeoJsonGeometry]) -> GeometryCollection { GeometryCollection(geometries: geometries) }
    
    public struct GeometryCollection: GeoJsonGeometry {
        public let type: GeoJsonObjectType = .geometryCollection
        
        public let objectGeometries: [GeoJsonGeometry]
        
        internal init(geoJson: GeoJsonDictionary) {
            // swiftlint:disable:next force_cast
            let geometriesJson = geoJson["geometries"] as! [GeoJsonDictionary]
            
            // swiftlint:disable:next force_cast
            self.objectGeometries = geometriesJson.map { parser.geoJsonObject(fromValidatedGeoJson: $0) as! GeoJsonGeometry }
        }
        
        fileprivate init(geometries: [GeoJsonGeometry]) {
            self.objectGeometries = geometries
        }
    }
}

extension GeoJson.GeometryCollection {
    public var geoJson: GeoJsonDictionary { ["type": type.name, "geometries": objectGeometries.map { $0.geoJson } ] }
    
    public var objectBoundingBox: GeodesicBoundingBox? { .best(objectGeometries.compactMap { $0.objectBoundingBox }) }
    
    public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { objectGeometries.compactMap { $0.objectDistance(to: point, tolerance: tolerance) }.min() }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { objectGeometries.first { $0.contains(point, tolerance: tolerance) } != nil }
    
    public func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation] { objectGeometries.flatMap { $0.simpleViolations(tolerance: tolerance) } }
}

extension GeoJson.GeometryCollection {
    internal static func validate(geoJson: GeoJsonDictionary) -> InvalidGeoJson? {
        guard let geometriesGeoJson = geoJson["geometries"] as? [GeoJsonDictionary] else { return .init(reason: "A valid GeometryCollection must have a \"geometries\" key") }
        
        let validateGeometries: InvalidGeoJson? = geometriesGeoJson.reduce(nil) { result, geometryGeoJson in
            return result + GeoJson.parser.validateGeoJsonGeometry(geoJson: geometryGeoJson)
        }
        
        return validateGeometries.flatMap { .init(reason: "Invalid Geometry(s) in GeometryCollection") + $0 }
    }
}
