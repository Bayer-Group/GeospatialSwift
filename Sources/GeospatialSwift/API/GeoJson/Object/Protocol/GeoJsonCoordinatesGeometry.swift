/**
 A Geometry Object which has Geo Json coordinates. Includes all of type GeoJsonGeometry except GeoJsonGeometryCollection.
 */
public protocol GeoJsonCoordinatesGeometry: GeoJsonGeometry {
    var geoJsonCoordinates: [Any] { get }
    
    var geometries: [GeoJsonGeometry] { get }
    
    var boundingBox: GeodesicBoundingBox { get }
    
    func distance(to point: GeodesicPoint, tolerance: Double) -> Double
    
    var points: [GeodesicPoint] { get }
}

public extension GeoJsonCoordinatesGeometry {
    var objectGeometries: [GeoJsonGeometry]? { return geometries }
    
    var objectBoundingBox: GeodesicBoundingBox? { return boundingBox }
    
    var geoJson: GeoJsonDictionary { return ["type": type.name, "coordinates": geoJsonCoordinates] }
    
    var geometries: [GeoJsonGeometry] { return [self] }
    
    func objectDistance(to point: GeodesicPoint, tolerance: Double) -> Double? { return distance(to: point, tolerance: tolerance) }
    
    func distance(to point: GeodesicPoint) -> Double { return distance(to: point, tolerance: 0) }
}
