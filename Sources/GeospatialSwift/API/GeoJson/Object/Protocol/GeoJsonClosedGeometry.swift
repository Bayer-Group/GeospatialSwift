/**
 A GeoJsonClosedGeometry is a geometry made of polygons
 */
public protocol GeoJsonClosedGeometry: GeoJsonCoordinatesGeometry {
    var hasHole: Bool { get }
    
    var area: Double { get }
    
    func edgeDistance(to point: GeodesicPoint, tolerance: Double) -> Double
}

public extension GeoJsonClosedGeometry {
    func edgeDistance(to point: GeodesicPoint) -> Double { return edgeDistance(to: point, tolerance: 0) }
}
