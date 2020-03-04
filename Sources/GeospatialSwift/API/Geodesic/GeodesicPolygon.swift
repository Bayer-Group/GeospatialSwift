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
}

public func == (lhs: GeodesicPolygon, rhs: GeodesicPolygon) -> Bool {
    guard lhs.negativeRings.count == rhs.negativeRings.count else { return false }
    
    guard lhs.mainRing == rhs.mainRing else { return false }
    
    for linearRing in lhs.negativeRings where !(rhs.negativeRings).contains { $0 == linearRing } { return false }
    
    return true
}
