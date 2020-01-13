public protocol GeoJsonGeometryCollection: GeoJsonGeometry { }

extension GeoJson {
    /**
     Creates a GeoJsonGeometryCollection
     */
    public func geometryCollection(geometries: [GeoJsonGeometry]?) -> GeoJsonGeometryCollection {
        return GeometryCollection(geometries: geometries)
    }
    
    public struct GeometryCollection: GeoJsonGeometryCollection {
        public let type: GeoJsonObjectType = .geometryCollection
        public var geoJson: GeoJsonDictionary { return ["type": type.name, "geometries": objectGeometries?.map { $0.geoJson } ?? [] ] }
        
        public let objectGeometries: [GeoJsonGeometry]?
        public var objectBoundingBox: GeodesicBoundingBox? { BoundingBox.best(objectGeometries?.compactMap { $0.objectBoundingBox } ?? []) }
        
        internal init?(geoJsonDictionary: GeoJsonDictionary) {
            guard let geometriesJson = geoJsonDictionary["geometries"] as? [GeoJsonDictionary] else { Log.warning("A valid GeometryCollection must have a \"geometries\" key: String : \(geoJsonDictionary)"); return nil }
            
            var geometries = [GeoJsonGeometry]()
            for geometryJson in geometriesJson {
                guard let geometry = parser.geoJsonObject(from: geometryJson) as? GeoJsonGeometry else { Log.warning("Invalid Geometry for GeometryCollection"); return nil }
                
                geometries.append(geometry)
            }
            
            self.init(geometries: geometries)
        }
        
        fileprivate init(geometries: [GeoJsonGeometry]?) {
            self.objectGeometries = geometries
        }
        
        public func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? {
            return objectGeometries?.compactMap { $0.objectDistance(to: point, tolerance: tolerance) }.min()
        }
        
        public func contains(_ point: GeodesicPoint, tolerance: Double) -> Bool { return objectGeometries?.first { $0.contains(point, tolerance: tolerance) } != nil }
    }
}
