/**
 A Geometry Object which has Geo Json coordinates. Includes all of type GeoJsonGeometry except GeoJsonGeometryCollection.
 */
public protocol GeoJsonCoordinatesGeometry: GeoJsonGeometry {
    var geoJsonCoordinates: [Any] { get }
    
    var geometries: [GeoJsonGeometry] { get }
    
    var boundingBox: GeodesicBoundingBox { get }
    
    func distance(to point: GeodesicPoint, tolerance: Double) -> Double
    
    var points: [GeodesicPoint] { get }
    
    func simpleViolations(tolerance: Double) -> [GeoJsonSimpleViolation]
}

public extension GeoJsonCoordinatesGeometry {
    var objectGeometries: [GeoJsonGeometry]? { return geometries }
    
    var objectBoundingBox: GeodesicBoundingBox? { return boundingBox }
    
    var geoJson: GeoJsonDictionary { return ["type": type.name, "coordinates": geoJsonCoordinates] }
    
    var geometries: [GeoJsonGeometry] { return [self] }
    
    func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { return distance(to: point, tolerance: tolerance) }
    
    func distance(to point: GeodesicPoint) -> Double { return distance(to: point, tolerance: 0) }
}

public struct GeoJsonSimpleViolation {
    public let problems: [GeoJsonCoordinatesGeometry]
    public let reason: GeoJsonSimpleViolationReason
}

public enum GeoJsonSimpleViolationReason {
    case lineIntersection
    case multiLineIntersection
    case pointDuplication
    case polygonHoleOutside
    case polygonNegativeRingContained
    case polygonSelfIntersection
    case polygonMultipleVertexIntersection
    case multiPolygonContained
    case multiPolygonIntersection
}
