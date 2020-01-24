import class Foundation.NSNull

public protocol GeoJsonGeometryCollection: GeoJsonGeometry { }

extension GeoJson {
    /**
     Creates a GeoJsonGeometryCollection
     */
    public func geometryCollection(geometries: [GeoJsonGeometry]?) -> GeoJsonGeometryCollection { GeometryCollection(geometries: geometries) }
    
    public struct GeometryCollection: GeoJsonGeometryCollection {
        public let type: GeoJsonObjectType = .geometryCollection
        
        public let objectGeometries: [GeoJsonGeometry]?
        
        internal static func invalidReasons(geoJson: GeoJsonDictionary) -> [String]? {
            guard let geometriesJson = geoJson["geometries"] as? [GeoJsonDictionary] else { return ["A valid GeometryCollection must have a \"geometries\" key"] }
            
            let geometriesInvalidReasons: [[String]] = geometriesJson.compactMap { geometryJson in
                guard let type = parser.geoJsonObjectType(geoJson: geometryJson) else { return ["Not a valid feature geometry"] }
                
                guard type.isGeometry else { return ["Not a valid feature geometry: \(type.name)"] }
                
                return parser.invalidReasons(fromGeoJson: geometryJson, type: type)
            }
            
            return geometriesInvalidReasons.flatMap { $0 }.nilIfEmpty.flatMap { ["Invalid Geometry in GeometryCollection"] + $0 }
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
    
    public var objectBoundingBox: GeodesicBoundingBox? { BoundingBox.best(objectGeometries?.compactMap { $0.objectBoundingBox } ?? []) }
    
    public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { objectGeometries?.compactMap { $0.objectDistance(to: point, tolerance: tolerance) }.min() }
    
    public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { objectGeometries?.first { $0.contains(point, tolerance: tolerance) } != nil }
}
