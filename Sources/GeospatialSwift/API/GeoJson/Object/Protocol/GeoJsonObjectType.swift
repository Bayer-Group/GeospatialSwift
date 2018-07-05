public enum GeoJsonObjectType: String, Codable {
    case point = "Point"
    case multiPoint = "MultiPoint"
    case lineString = "LineString"
    case multiLineString = "MultiLineString"
    case polygon = "Polygon"
    case multiPolygon = "MultiPolygon"
    case geometryCollection = "GeometryCollection"
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
    
    var name: String { return rawValue }
    
    init?(name: String) {
        self.init(rawValue: name)
    }
}
