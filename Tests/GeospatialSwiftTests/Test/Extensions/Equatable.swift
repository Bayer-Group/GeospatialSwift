@testable import GeospatialSwift

public typealias Point = GeoJson.Point
public typealias MultiPoint = GeoJson.MultiPoint
public typealias LineString = GeoJson.LineString
public typealias MultiLineString = GeoJson.MultiLineString
public typealias Polygon = GeoJson.Polygon
public typealias MultiPolygon = GeoJson.MultiPolygon
public typealias GeometryCollection = GeoJson.GeometryCollection
public typealias Feature = GeoJson.Feature
public typealias FeatureCollection = GeoJson.FeatureCollection

extension SimplePoint: Equatable {
    public static func == (lhs: SimplePoint, rhs: SimplePoint) -> Bool { lhs as GeodesicPoint == rhs as GeodesicPoint }
}

extension GeodesicBoundingBox: Equatable { }

extension Point: Equatable {
    public static func == (lhs: Point, rhs: Point) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension MultiPoint: Equatable {
    public static func == (lhs: MultiPoint, rhs: MultiPoint) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension LineString: Equatable {
    public static func == (lhs: LineString, rhs: LineString) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension MultiLineString: Equatable {
    public static func == (lhs: MultiLineString, rhs: MultiLineString) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension Polygon: Equatable {
    public static func == (lhs: Polygon, rhs: Polygon) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension MultiPolygon: Equatable {
    public static func == (lhs: MultiPolygon, rhs: MultiPolygon) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension GeometryCollection: Equatable {
    public static func == (lhs: GeometryCollection, rhs: GeometryCollection) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension Feature: Equatable {
    public static func == (lhs: Feature, rhs: Feature) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}

extension FeatureCollection: Equatable {
    public static func == (lhs: FeatureCollection, rhs: FeatureCollection) -> Bool { lhs as GeoJsonObject == rhs as GeoJsonObject }
}
