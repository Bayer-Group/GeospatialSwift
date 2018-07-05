/**
 A GeoJsonCoordinatesGeometry associated with multiple points. Includes all of type GeoJsonGeometry except GeoJsonPoint.
 */
public protocol GeoJsonMultiCoordinatesGeometry: GeoJsonCoordinatesGeometry {
    var points: [GeoJsonPoint] { get }
}
