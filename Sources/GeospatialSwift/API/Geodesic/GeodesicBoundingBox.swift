// TODO: "The concept of minimums and maximums is not right. Crossing the Antimeridian will do odd things. Fix all things BoundingCoordinates and BoundingBox.

/**
 A bounding box intended to exactly fit a GeoJsonObject. Also known as a "Minimum Bounding Box", "Bounding Envelope".
 */
public struct GeodesicBoundingBox {
    public var points: [GeodesicPoint] { [SimplePoint(longitude: minLongitude, latitude: minLatitude), SimplePoint(longitude: minLongitude, latitude: maxLatitude), SimplePoint(longitude: maxLongitude, latitude: maxLatitude), SimplePoint(longitude: maxLongitude, latitude: minLatitude)] }
    
    public var centroid: GeodesicPoint { SimplePoint(longitude: maxLongitude - (longitudeDelta / 2), latitude: maxLatitude - (latitudeDelta / 2)) }
    
    public let minLongitude: Double
    public let minLatitude: Double
    public let maxLongitude: Double
    public let maxLatitude: Double
    
    public var longitudeDelta: Double { maxLongitude - minLongitude }
    public var latitudeDelta: Double { maxLatitude - minLatitude }
    
    public var segments: [GeodesicLineSegment] { [.init(startPoint: points[0], endPoint: points[1]), .init(startPoint: points[1], endPoint: points[2]), .init(startPoint: points[2], endPoint: points[3]), .init(startPoint: points[3], endPoint: points[0])] }
    
    public var box: GeodesicPolygon { SimplePolygon(mainRing: SimpleLine(segments: segments)!)! }
    
    public init(minLongitude: Double, minLatitude: Double, maxLongitude: Double, maxLatitude: Double) {
        self.minLongitude = minLongitude
        self.minLatitude = minLatitude
        self.maxLongitude = maxLongitude
        self.maxLatitude = maxLatitude
    }
    
    public func contains(point: GeodesicPoint) -> Bool { contains(point: point, tolerance: 0) }
    public func contains(point: GeodesicPoint, tolerance: Double) -> Bool {
        guard tolerance != 0 else {
            return point.latitude >= minLatitude &&
                point.latitude <= maxLatitude &&
                point.longitude >= minLongitude &&
                point.longitude <= maxLongitude
        }
        
        return Calculator.contains(point, in: box, tolerance: tolerance)
    }
    
    public func overlaps(boundingBox: GeodesicBoundingBox) -> Bool { overlaps(boundingBox: boundingBox, tolerance: 0) }
    public func overlaps(boundingBox: GeodesicBoundingBox, tolerance: Double) -> Bool {
        guard tolerance != 0 else {
            return minLongitude <= boundingBox.maxLongitude && boundingBox.minLongitude <= maxLongitude && minLatitude <= boundingBox.maxLatitude && boundingBox.minLatitude <= maxLatitude
        }
        
        return minLongitude + tolerance <= boundingBox.maxLongitude &&
            boundingBox.minLongitude + tolerance <= maxLongitude &&
            minLatitude + tolerance <= boundingBox.maxLatitude &&
            boundingBox.minLatitude + tolerance <= maxLatitude
    }
    
    // SOMEDAY: This should follow the rule "5.2. The Antimeridian" in the GeoJson spec.
    public func best(_ boundingBoxes: [GeodesicBoundingBox]) -> GeodesicBoundingBox {
        return boundingBoxes.reduce(self) {
            return GeodesicBoundingBox(minLongitude: min($0.minLongitude, $1.minLongitude), minLatitude: min($0.minLatitude, $1.minLatitude), maxLongitude: max($0.maxLongitude, $1.maxLongitude), maxLatitude: max($0.maxLatitude, $1.maxLatitude))
        }
    }
    
    public func validBoundingBox(minimumAdjustment: Double) -> GeodesicBoundingBox {
        let longitudeAdjustment = minLongitude == maxLongitude ? minimumAdjustment : 0
        let latitudeAdjustment = minLatitude == maxLatitude ? minimumAdjustment : 0
        
        return GeodesicBoundingBox(minLongitude: minLongitude - longitudeAdjustment, minLatitude: minLatitude - latitudeAdjustment, maxLongitude: maxLongitude + longitudeAdjustment, maxLatitude: maxLatitude + latitudeAdjustment)
    }
    
    public func insetBoundingBox(topPercent: Double, leftPercent: Double, bottomPercent: Double, rightPercent: Double) -> GeodesicBoundingBox {
        return GeodesicBoundingBox(minLongitude: minLongitude - (longitudeDelta * leftPercent), minLatitude: minLatitude - (longitudeDelta * bottomPercent), maxLongitude: maxLongitude + (longitudeDelta * rightPercent), maxLatitude: maxLatitude + (longitudeDelta * topPercent))
    }
    public func insetBoundingBox(percent: Double) -> GeodesicBoundingBox { insetBoundingBox(widthPercent: percent, heightPercent: percent) }
    public func insetBoundingBox(widthPercent: Double, heightPercent: Double) -> GeodesicBoundingBox { insetBoundingBox(topPercent: heightPercent, leftPercent: widthPercent, bottomPercent: heightPercent, rightPercent: widthPercent) }

}

public extension GeodesicBoundingBox {
    static func best(_ boundingBoxes: [GeodesicBoundingBox]) -> GeodesicBoundingBox? {
        guard let firstBoundingBox = boundingBoxes.first else { return nil }
        
        guard let boundingBoxesTail = boundingBoxes.tail, !boundingBoxesTail.isEmpty else { return firstBoundingBox }
        
        return firstBoundingBox.best(boundingBoxesTail)
    }
}

public func == (lhs: GeodesicBoundingBox, rhs: GeodesicBoundingBox) -> Bool {
    return lhs.minLongitude == rhs.minLongitude && lhs.minLatitude == rhs.minLatitude && lhs.maxLongitude == rhs.maxLongitude && lhs.maxLatitude == rhs.maxLatitude
}
