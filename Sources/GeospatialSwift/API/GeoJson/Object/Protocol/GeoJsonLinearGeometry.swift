/**
 A GeoJsonLinearGeometry is a geometry made of lines
 */
public protocol GeoJsonLinearGeometry: GeoJsonCoordinatesGeometry {
    var lineStrings: [GeoJsonLineString] { get }
    
    var length: Double { get }
}
