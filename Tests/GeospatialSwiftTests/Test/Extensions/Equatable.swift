@testable import GeospatialSwift

extension SimplePoint: Equatable {
    public static func == (lhs: SimplePoint, rhs: SimplePoint) -> Bool { return lhs as GeodesicPoint == rhs as GeodesicPoint }
}

extension BoundingBox: Equatable {
    public static func == (lhs: BoundingBox, rhs: BoundingBox) -> Bool { return lhs as GeoJsonBoundingBox == rhs as GeoJsonBoundingBox }
}

extension Point: Equatable {
    public static func == (lhs: Point, rhs: Point) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension MultiPoint: Equatable {
    public static func == (lhs: MultiPoint, rhs: MultiPoint) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension LineString: Equatable {
    public static func == (lhs: LineString, rhs: LineString) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension MultiLineString: Equatable {
    public static func == (lhs: MultiLineString, rhs: MultiLineString) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension Polygon: Equatable {
    public static func == (lhs: Polygon, rhs: Polygon) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension MultiPolygon: Equatable {
    public static func == (lhs: MultiPolygon, rhs: MultiPolygon) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension GeometryCollection: Equatable {
    public static func == (lhs: GeometryCollection, rhs: GeometryCollection) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension Feature: Equatable {
    public static func == (lhs: Feature, rhs: Feature) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension FeatureCollection: Equatable {
    public static func == (lhs: FeatureCollection, rhs: FeatureCollection) -> Bool { return lhs as GeoJsonObject == rhs as GeoJsonObject }
}
