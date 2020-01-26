import class Foundation.NSNull

extension GeoJson {
    /**
     Creates a GeometryCollection
     */
    public func geometryCollection(geometries: [GeoJsonGeometry]?) -> GeometryCollection { GeometryCollection(geometries: geometries) }
    
    public struct GeometryCollection: GeoJsonGeometry {
        public let type: GeoJsonObjectType = .geometryCollection
        
        public let objectGeometries: [GeoJsonGeometry]?
        
        internal static func validate(geoJson: GeoJsonDictionary) -> InvalidGeoJson? {
            guard let geometriesJson = geoJson["geometries"] as? [GeoJsonDictionary] else { return .init(reason: "A valid GeometryCollection must have a \"geometries\" key") }
            
            let validateGeometries: InvalidGeoJson? = geometriesJson.reduce(nil) { result, geometryJson in
                guard let type = parser.geoJsonObjectType(geoJson: geometryJson) else { return .init(reason: "Not a valid feature geometry") }
                
                guard type.isGeometry else { return .init(reason: "Not a valid feature geometry: \(type.name)") }
                
                return result + parser.validate(geoJson: geometryJson, type: type)
            }
            
            return validateGeometries.flatMap { .init(reason: "Invalid Geometry(s) in GeometryCollection") + $0 }
        }
        
        internal init(geoJson: GeoJsonDictionary) {
            // swiftlint:disable:next force_cast
            let geometriesJson = geoJson["geometries"] as! [GeoJsonDictionary]
            
            // swiftlint:disable:next force_cast
            self.objectGeometries = geometriesJson.map { parser.geoJsonObject(fromValidatedGeoJson: $0) as! GeoJsonGeometry }
        }
        
        fileprivate init(geometries: [GeoJsonGeometry]?) {
            self.objectGeometries = geometries
        }
    }
}

extension GeoJson.GeometryCollection {
    public var geoJson: GeoJsonDictionary { ["type": type.name, "geometries": objectGeometries?.map { $0.geoJson } ?? [] ] }
    
    public var objectBoundingBox: GeodesicBoundingBox? { .best(objectGeometries?.compactMap { $0.objectBoundingBox } ?? []) }
    
    public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { objectGeometries?.compactMap { $0.objectDistance(to: point, tolerance: tolerance) }.min() }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { objectGeometries?.first { $0.contains(point, tolerance: tolerance) } != nil }
}
