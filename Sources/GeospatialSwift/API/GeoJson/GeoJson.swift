public typealias GeoJsonDictionary = [String: Any]

public enum GeoJsonObjectType: String {
    case point = "Point"
    case multiPoint = "MultiPoint"
    case lineString = "LineString"
    case multiLineString = "MultiLineString"
    case polygon = "Polygon"
    case multiPolygon = "MultiPolygon"
    case geometryCollection = "GeometryCollection"
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
}

/**
 GeoJsonObject Protocol
 
 Does not support projected coordinates, only geographic
 */
public protocol GeoJsonObject: CustomStringConvertible {
    var type: GeoJsonObjectType { get }
    
    var objectGeometries: [GeoJsonGeometry]? { get }
    
    var objectBoundingBox: GeoJsonBoundingBox? { get }
    
    var geoJson: GeoJsonDictionary { get }
    
    // TODO: Could this be expanded to more than point?
    func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double?
    
    // TODO: Could this be expanded to more than point?
    func contains(_ point: GeodesicPoint, errorDistance: Double) -> Bool
    
    // TODO: More fun!
    //func overlaps(geoJsonObject: GeoJsonObject, errorDistance: Double) -> Bool
}

extension GeoJsonObject {
    public func contains(_ point: GeodesicPoint) -> Bool { return contains(point, errorDistance: 0) }
    
    public func objectDistance(to point: GeodesicPoint) -> Double? { return objectDistance(to: point, errorDistance: 0) }
}

/**
 A GeoJsonObject which conform to the definition of Geometry Object as in the GeoJson specification.
 */
public protocol GeoJsonGeometry: GeoJsonObject { }

/**
 A Geometry Object which has Geo Json coordinates. Includes all of type GeoJsonGeometry except GeoJsonGeometryCollection.
 */
public protocol GeoJsonCoordinatesGeometry: GeoJsonGeometry {
    var geoJsonCoordinates: [Any] { get }
    
    var geometries: [GeoJsonGeometry] { get }
    
    var boundingBox: GeoJsonBoundingBox { get }
    
    func distance(to point: GeodesicPoint, errorDistance: Double) -> Double
}

public extension GeoJsonCoordinatesGeometry {
    public var objectGeometries: [GeoJsonGeometry]? { return geometries }
    
    public var objectBoundingBox: GeoJsonBoundingBox? { return boundingBox }
    
    public var geoJson: GeoJsonDictionary { return ["type": type.rawValue, "coordinates": geoJsonCoordinates] }
    
    public var geometries: [GeoJsonGeometry] { return [self] }
    
    public func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double? { return distance(to: point, errorDistance: errorDistance) }
    
    public func distance(to point: GeodesicPoint) -> Double { return distance(to: point, errorDistance: 0) }
}

/**
 A GeoJsonCoordinatesGeometry associated with multiple points. Includes all of type GeoJsonGeometry except GeoJsonPoint.
 */
public protocol GeoJsonMultiCoordinatesGeometry: GeoJsonCoordinatesGeometry {
    var points: [GeoJsonPoint] { get }
    
    var centroid: GeodesicPoint { get }
}

public protocol GeoJsonClosedGeometry: GeoJsonMultiCoordinatesGeometry {
    func edgeDistance(to point: GeodesicPoint, errorDistance: Double) -> Double
}

public extension GeoJsonClosedGeometry {
    public func edgeDistance(to point: GeodesicPoint) -> Double { return edgeDistance(to: point, errorDistance: 0) }
}

public protocol GeoJsonProtocol {
    func parse(geoJson: GeoJsonDictionary) -> GeoJsonObject?
    
    // GeoJsonObject Factory methods
    func featureCollection(features: [GeoJsonFeature]) -> GeoJsonFeatureCollection?
    func feature(geometry: GeoJsonGeometry?, id: Any?, properties: GeoJsonDictionary?) -> GeoJsonFeature?
    func geometryCollection(geometries: [GeoJsonGeometry]?) -> GeoJsonGeometryCollection
    func multiPolygon(polygons: [GeoJsonPolygon]) -> GeoJsonMultiPolygon?
    func polygon(linearRings: [GeoJsonLineString]) -> GeoJsonPolygon?
    func multiLineString(lineStrings: [GeoJsonLineString]) -> GeoJsonMultiLineString?
    func lineString(points: [GeoJsonPoint]) -> GeoJsonLineString?
    func multiPoint(points: [GeoJsonPoint]) -> GeoJsonMultiPoint?
    func point(longitude: Double, latitude: Double, altitude: Double?) -> GeoJsonPoint
    func point(longitude: Double, latitude: Double) -> GeoJsonPoint
}

public struct GeoJson: GeoJsonProtocol {
    private var geoJsonParser: GeoJsonParserProtocol!
    
    internal init() {
        geoJsonParser = GeoJsonParser()
    }
    
    /**
     Parses a GeoJsonDictionary into a GeoJsonObject.
     
     - geoJson: An JSON dictionary conforming to the GeoJson current spcification.
     
     - returns: A successfully parsed GeoJsonObject or nil if the specification was not correct
     */
    public func parse(geoJson: GeoJsonDictionary) -> GeoJsonObject? {
        return geoJsonParser.geoJsonObject(from: geoJson)
    }
}
