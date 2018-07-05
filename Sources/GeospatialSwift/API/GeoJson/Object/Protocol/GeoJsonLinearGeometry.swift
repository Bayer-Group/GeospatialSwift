/**
 A GeoJsonLinearGeometry is a geometry made of lines
 */
public protocol GeoJsonLinearGeometry: GeoJsonMultiCoordinatesGeometry {
    var length: Double { get }
}
