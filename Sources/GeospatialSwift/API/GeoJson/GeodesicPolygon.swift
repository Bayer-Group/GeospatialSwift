public protocol GeodesicPolygon {
    var points: [GeodesicPoint] { get }
    var mainRing: GeodesicLine { get }
    var negativeRings: [GeodesicLine] { get }
    var linearRings: [GeodesicLine] { get }
    
    var boundingBox: GeodesicBoundingBox { get }
}

public struct SimplePolygon: GeodesicPolygon {
    public var points: [GeodesicPoint] { linearRings.flatMap { $0.points } }
    public var linearRings: [GeodesicLine] { [mainRing] + negativeRings }
    public let mainRing: GeodesicLine
    public let negativeRings: [GeodesicLine]
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(linearRings.map { $0.boundingBox })! }
    
    public init?(mainRing: GeodesicLine, negativeRings: [GeodesicLine] = []) {
        for linearRingSegments in ([mainRing.segments] + negativeRings.map { $0.segments }) {
            guard linearRingSegments.count >= 3 else { return nil }
            
            guard linearRingSegments.first!.point == linearRingSegments.last!.otherPoint else { return nil }
        }
        
        self.mainRing = mainRing
        self.negativeRings = negativeRings
    }
}
