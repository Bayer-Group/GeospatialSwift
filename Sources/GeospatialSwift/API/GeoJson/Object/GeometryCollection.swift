internal typealias GeometryCollection = GeoJson.GeometryCollection

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
        public var geoJson: GeoJsonDictionary { return ["type": type.rawValue, "geometries": objectGeometries?.map { $0.geoJson } ?? [] ] }
        
        public var description: String {
            return """
            GeometryCollection: \(
            """
            (\n\(objectGeometries != nil ? objectGeometries!.enumerated().map { "Line \($0) - \($1)" }.joined(separator: ",\n") : "null")
            """
            .replacingOccurrences(of: "\n", with: "\n\t")
            )\n)
            """
        }
        
        public let objectGeometries: [GeoJsonGeometry]?
        public let objectBoundingBox: GeoJsonBoundingBox?
        
        internal init?(geoJsonParser: GeoJsonParserProtocol, geoJsonDictionary: GeoJsonDictionary) {
            guard let geometriesJson = geoJsonDictionary["geometries"] as? [GeoJsonDictionary] else { Log.warning("A valid GeometryCollection must have a \"geometries\" key: String : \(geoJsonDictionary)"); return nil }
            
            var geometries = [GeoJsonGeometry]()
            for geometryJson in geometriesJson {
                guard let geometry = geoJsonParser.geoJsonObject(from: geometryJson) as? GeoJsonGeometry else { Log.warning("Invalid Geometry for GeometryCollection"); return nil }
                
                geometries.append(geometry)
            }
            
            self.init(geometries: geometries)
        }
        
        fileprivate init(geometries: [GeoJsonGeometry]?) {
            self.objectGeometries = geometries
            
            #if swift(>=4.1)
            objectBoundingBox = BoundingBox.best(geometries?.compactMap { $0.objectBoundingBox } ?? [])
            #else
            objectBoundingBox = BoundingBox.best(geometries?.flatMap { $0.objectBoundingBox } ?? [])
            #endif
        }
        
        public func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double? {
            #if swift(>=4.1)
            return objectGeometries?.compactMap { $0.objectDistance(to: point, errorDistance: errorDistance) }.min()
            #else
            return objectGeometries?.flatMap { $0.objectDistance(to: point, errorDistance: errorDistance) }.min()
            #endif
        }
        
        public func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool { return objectGeometries?.first { $0.contains(point, errorDistance: errorDistance) } != nil }
    }
}
