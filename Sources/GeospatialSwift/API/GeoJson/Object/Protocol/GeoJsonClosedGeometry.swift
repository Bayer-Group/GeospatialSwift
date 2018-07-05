/**
 A GeoJsonClosedGeometry is a geometry made of polygons
 */
public protocol GeoJsonClosedGeometry: GeoJsonMultiCoordinatesGeometry {
    var hasHole: Bool { get }
    
    var area: Double { get }
    
    func edgeDistance(to point: GeodesicPoint, errorDistance: Double) -> Double
}

public extension GeoJsonClosedGeometry {
    public func edgeDistance(to point: GeodesicPoint) -> Double { return edgeDistance(to: point, errorDistance: 0) }
}
