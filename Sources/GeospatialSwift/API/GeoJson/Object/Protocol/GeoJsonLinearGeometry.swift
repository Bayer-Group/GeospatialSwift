/**
 A GeoJsonLinearGeometry is a geometry made of lines
 */
public protocol GeoJsonLinearGeometry: GeoJsonCoordinatesGeometry {
    var length: Double { get }
}
