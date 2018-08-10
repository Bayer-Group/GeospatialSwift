public protocol GeodesicPolygon: CustomStringConvertible {
    var ringSegements: [[GeodesicLineSegment]] { get }
    
    var mainRingSegments: [GeodesicLineSegment] { get }
    var negativeRingsSegments: [[GeodesicLineSegment]] { get }
}

public struct SimplePolygon: GeodesicPolygon {
    public var ringSegements: [[GeodesicLineSegment]] { return [mainRingSegments] + negativeRingsSegments }
    
    public let mainRingSegments: [GeodesicLineSegment]
    public let negativeRingsSegments: [[GeodesicLineSegment]]
    
    public init?(mainRingSegments: [GeodesicLineSegment], negativeRingsSegments: [[GeodesicLineSegment]] = []) {
        guard mainRingSegments.count >= 3, !negativeRingsSegments.contains(where: { $0.count < 3 }) else { return nil }
        
        self.mainRingSegments = mainRingSegments
        self.negativeRingsSegments = negativeRingsSegments
    }
    
    public var description: String { return "SimplePolygon: MainRing: (\(mainRingSegments.map { $0.point })" }
}
