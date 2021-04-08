import Foundation

public protocol GeodesicPolygon {
    var points: [GeodesicPoint] { get }
    var mainRing: GeodesicLine { get }
    var negativeRings: [GeodesicLine] { get }
    var linearRings: [GeodesicLine] { get }
    
    var boundingBox: GeodesicBoundingBox { get }
    
    var centroid: GeodesicPoint { get }
}

public struct SimplePolygon: GeodesicPolygon {
    public var points: [GeodesicPoint] { linearRings.flatMap { $0.points } }
    public var linearRings: [GeodesicLine] { [mainRing] + negativeRings }
    public let mainRing: GeodesicLine
    public let negativeRings: [GeodesicLine]
    
    public var boundingBox: GeodesicBoundingBox { .best(linearRings.map { $0.boundingBox })! }
    
    public var centroid: GeodesicPoint { Calculator.centroid(polygon: self) }
    
    public init?(mainRing: GeodesicLine, negativeRings: [GeodesicLine] = []) {
        for linearRingSegments in ([mainRing.segments] + negativeRings.map { $0.segments }) {
            guard linearRingSegments.count >= 3 else { return nil }
            
            guard linearRingSegments.first!.startPoint == linearRingSegments.last!.endPoint else { return nil }
        }
        
        self.mainRing = mainRing
        self.negativeRings = negativeRings
    }
    
    public init?(centroid: GeodesicPoint, width: Double, height: Double) {
        guard width > 0, height > 0 else { return nil }
        
        let distance = sqrt(pow(width / 2, 2) + pow(height / 2, 2))
        
        let point1 = Calculator.destinationPoint(origin: centroid, bearing: 45, distance: distance)
        let point2 = Calculator.destinationPoint(origin: centroid, bearing: 135, distance: distance)
        let point3 = Calculator.destinationPoint(origin: centroid, bearing: 225, distance: distance)
        let point4 = Calculator.destinationPoint(origin: centroid, bearing: 315, distance: distance)
        
        self.init(mainRing: SimpleLine(points: [point1, point2, point3, point4, point1])!)!
    }
}

public func == (lhs: GeodesicPolygon, rhs: GeodesicPolygon) -> Bool {
    guard lhs.negativeRings.count == rhs.negativeRings.count else { return false }
    
    guard lhs.mainRing == rhs.mainRing else { return false }
    
    for linearRing in lhs.negativeRings where !(rhs.negativeRings).contains(where: { $0 == linearRing }) { return false }
    
    return true
}
