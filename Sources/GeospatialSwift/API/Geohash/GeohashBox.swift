public protocol GeoJsonGeohashBox {
    var geohash: String { get }
    var boundingBox: GeodesicBoundingBox { get }
}

public enum GeohashCompassPoint {
    case north, south, east, west
}

internal struct GeohashBox: GeoJsonGeohashBox {
    public let geohash: String
    public let boundingBox: GeodesicBoundingBox
    
    init(boundingCoordinates: BoundingCoordinates, geohash: String) {
        self.geohash = geohash
        
        boundingBox = BoundingBox(boundingCoordinates: boundingCoordinates)
    }
}
