public protocol GeodesicLine {
    var points: [GeodesicPoint] { get }
    var segments: [GeodesicLineSegment] { get }
}

public struct SimpleLine: GeodesicLine {
    public let points: [GeodesicPoint]
    public let segments: [GeodesicLineSegment]
    
    init?(points: [GeodesicPoint]) {
        guard points.count >= 2 else { return nil }
        
        self.points = points
        
        segments = points.enumerated().compactMap { (offset, point) in
            if points.count == offset + 1 { return nil }
            
            return LineSegment(point: point, otherPoint: points[offset + 1])
        }
    }
    
    init?(segments: [GeodesicLineSegment]) {
        guard segments.count >= 1 else { return nil }
        
        for (index, segment) in segments.enumerated() {
            guard index == 0 || segment.point == segments[index - 1].otherPoint else { return nil }
        }
        
        self.points = segments.map { $0.point } + [segments.last!.otherPoint]
        self.segments = segments
    }
}
