/**
 A Geometry Object which has Geo Json coordinates. Includes all of type GeoJsonGeometry except GeoJsonGeometryCollection.
 */
public protocol GeoJsonCoordinatesGeometry: GeoJsonGeometry {
    var geoJsonCoordinates: [Any] { get }
    
    var geometries: [GeoJsonGeometry] { get }
    
    var boundingBox: GeodesicBoundingBox { get }
    
    func distance(to point: GeodesicPoint, errorDistance: Double) -> Double
}

public extension GeoJsonCoordinatesGeometry {
    public var objectGeometries: [GeoJsonGeometry]? { return geometries }
    
    public var objectBoundingBox: GeodesicBoundingBox? { return boundingBox }
    
    public var geoJson: GeoJsonDictionary { return ["type": type.name, "coordinates": geoJsonCoordinates] }
    
    public var geometries: [GeoJsonGeometry] { return [self] }
    
    public func objectDistance(to point: GeodesicPoint, errorDistance: Double) -> Double? { return distance(to: point, errorDistance: errorDistance) }
    
    public func distance(to point: GeodesicPoint) -> Double { return distance(to: point, errorDistance: 0) }
}
