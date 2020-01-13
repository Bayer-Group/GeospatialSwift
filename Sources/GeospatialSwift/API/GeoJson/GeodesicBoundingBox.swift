#warning("The concept of minimums and maximums is not right. Crossing the Antimeridian will do odd things. Fix all things BoundingCoordinates and BoundingBox.")

public typealias BoundingCoordinates = (minLongitude: Double, minLatitude: Double, maxLongitude: Double, maxLatitude: Double)

public protocol GeodesicBoundingBox {
    var minLongitude: Double { get }
    var minLatitude: Double { get }
    var maxLongitude: Double { get }
    var maxLatitude: Double { get }
    
    var longitudeDelta: Double { get }
    var latitudeDelta: Double { get }
    
    var points: [GeodesicPoint] { get }
    var centroid: GeodesicPoint { get }
    var boundingCoordinates: BoundingCoordinates { get }
    var segments: [GeodesicLineSegment] { get }
    var box: GeodesicPolygon { get }
    
    func best(_ boundingBoxes: [GeodesicBoundingBox]) -> GeodesicBoundingBox
    func validBoundingBox(minimumAdjustment: Double) -> GeodesicBoundingBox
    func insetBoundingBox(topPercent: Double, leftPercent: Double, bottomPercent: Double, rightPercent: Double) -> GeodesicBoundingBox
    func contains(point: GeodesicPoint) -> Bool
    func contains(point: GeodesicPoint, tolerance: Double) -> Bool
    func overlaps(boundingBox: GeodesicBoundingBox) -> Bool
    func overlaps(boundingBox: GeodesicBoundingBox, tolerance: Double) -> Bool
}

extension GeodesicBoundingBox {
    public func insetBoundingBox(percent: Double) -> GeodesicBoundingBox {
        return insetBoundingBox(widthPercent: percent, heightPercent: percent)
    }
    
    public func insetBoundingBox(widthPercent: Double, heightPercent: Double) -> GeodesicBoundingBox {
        return insetBoundingBox(topPercent: heightPercent, leftPercent: widthPercent, bottomPercent: heightPercent, rightPercent: widthPercent)
    }
}

/**
 A bounding box intended to exactly fit a GeoJsonObject. Also known as a "Minimum Bounding Box", "Bounding Envelope".
 */
public struct BoundingBox: GeodesicBoundingBox {
    public let boundingCoordinates: BoundingCoordinates
    
    public var points: [GeodesicPoint] { [SimplePoint(longitude: minLongitude, latitude: minLatitude), SimplePoint(longitude: minLongitude, latitude: maxLatitude), SimplePoint(longitude: maxLongitude, latitude: maxLatitude), SimplePoint(longitude: maxLongitude, latitude: minLatitude)] }
    
    public var centroid: GeodesicPoint { SimplePoint(longitude: maxLongitude - (longitudeDelta / 2), latitude: maxLatitude - (latitudeDelta / 2)) }
    
    public var minLongitude: Double { boundingCoordinates.minLongitude }
    public var minLatitude: Double { boundingCoordinates.minLatitude }
    public var maxLongitude: Double { boundingCoordinates.maxLongitude }
    public var maxLatitude: Double { boundingCoordinates.maxLatitude }
    
    public var longitudeDelta: Double { maxLongitude - minLongitude }
    public var latitudeDelta: Double { maxLatitude - minLatitude }
    
    public var segments: [GeodesicLineSegment] {
        return [LineSegment(point: points[0], otherPoint: points[1]), LineSegment(point: points[1], otherPoint: points[2]), LineSegment(point: points[2], otherPoint: points[3]), LineSegment(point: points[3], otherPoint: points[0])]
    }
    
    public var box: GeodesicPolygon { return SimplePolygon(mainRing: SimpleLine(segments: segments)!)! }
    
    public init(boundingCoordinates: BoundingCoordinates) {
        self.boundingCoordinates = boundingCoordinates
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
            let boundingCoordinates = (minLongitude: min($0.minLongitude, $1.minLongitude), minLatitude: min($0.minLatitude, $1.minLatitude), maxLongitude: max($0.maxLongitude, $1.maxLongitude), maxLatitude: max($0.maxLatitude, $1.maxLatitude))
            
            return BoundingBox(boundingCoordinates: boundingCoordinates)
        }
    }
    
    public func validBoundingBox(minimumAdjustment: Double) -> GeodesicBoundingBox {
        let longitudeAdjustment = minLongitude == maxLongitude ? minimumAdjustment : 0
        let latitudeAdjustment = minLatitude == maxLatitude ? minimumAdjustment : 0
        
        let boundingCoordinates = (minLongitude: minLongitude - longitudeAdjustment, minLatitude: minLatitude - latitudeAdjustment, maxLongitude: maxLongitude + longitudeAdjustment, maxLatitude: maxLatitude + latitudeAdjustment)
        
        return BoundingBox(boundingCoordinates: boundingCoordinates)
    }
    
    public func insetBoundingBox(topPercent: Double, leftPercent: Double, bottomPercent: Double, rightPercent: Double) -> GeodesicBoundingBox {
        let boundingCoordinates = (minLongitude: minLongitude - (longitudeDelta * leftPercent), minLatitude: minLatitude - (longitudeDelta * bottomPercent), maxLongitude: maxLongitude + (longitudeDelta * rightPercent), maxLatitude: maxLatitude + (longitudeDelta * topPercent))
        
        return BoundingBox(boundingCoordinates: boundingCoordinates)
    }
}

public extension BoundingBox {
    static func best(_ boundingBoxes: [GeodesicBoundingBox]) -> GeodesicBoundingBox? {
        guard let firstBoundingBox = boundingBoxes.first else { return nil }
        
        guard let boundingBoxesTail = boundingBoxes.tail, !boundingBoxesTail.isEmpty else { return firstBoundingBox }
        
        return firstBoundingBox.best(boundingBoxesTail)
    }
}

public func == (lhs: GeodesicBoundingBox, rhs: GeodesicBoundingBox) -> Bool {
    return lhs.minLongitude == rhs.minLongitude && lhs.minLatitude == rhs.minLatitude && lhs.maxLongitude == rhs.maxLongitude && lhs.maxLatitude == rhs.maxLatitude
}
