public protocol GeoJsonGeohashBox: GeoJsonBoundingBox {
    var geohash: String { get }
    
    func geohashNeighbor(direction: GeohashCompassPoint, precision: Int) -> GeoJsonGeohashBox
}

public enum GeohashCompassPoint {
    case north, south, east, west
}

internal final class GeohashBox: BoundingBox, GeoJsonGeohashBox {
    private let geohashCoder: GeohashCoderProtocol
    
    public let geohash: String
    
    init(boundingCoordinates: BoundingCoordinates, geohashCoder: GeohashCoderProtocol, geohash: String) {
        self.geohashCoder = geohashCoder
        
        self.geohash = geohash
        
        super.init(boundingCoordinates: boundingCoordinates)
    }
    
    public func geohashNeighbor(direction: GeohashCompassPoint, precision: Int) -> GeoJsonGeohashBox {
        let point: GeodesicPoint = {
            switch direction {
            case .north: return SimplePoint(longitude: centroid.longitude, latitude: centroid.latitude + latitudeDelta)
            case .south: return SimplePoint(longitude: centroid.longitude, latitude: centroid.latitude - latitudeDelta)
            case .east: return SimplePoint(longitude: centroid.longitude + longitudeDelta, latitude: centroid.latitude)
            case .west: return SimplePoint(longitude: centroid.longitude - longitudeDelta, latitude: centroid.latitude)
            }
        }()
        
        return geohashCoder.geohashBox(for: point, precision: precision)
    }
}
