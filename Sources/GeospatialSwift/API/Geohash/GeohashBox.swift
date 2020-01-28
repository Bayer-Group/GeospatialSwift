public enum GeohashCompassPoint {
    case north, south, east, west
}

public struct GeohashBox {
    public let boundingBox: GeodesicBoundingBox
    public let geohash: String
}
