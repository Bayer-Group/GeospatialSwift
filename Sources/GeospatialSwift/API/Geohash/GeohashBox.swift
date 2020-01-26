public protocol GeoJsonGeohashBox {
    var boundingBox: GeodesicBoundingBox { get }
    var geohash: String { get }
}

public enum GeohashCompassPoint {
    case north, south, east, west
}

internal struct GeohashBox: GeoJsonGeohashBox {
    public let boundingBox: GeodesicBoundingBox
    public let geohash: String
}
