public protocol GeodesicLine {
    var points: [GeodesicPoint] { get }
    var segments: [GeodesicLineSegment] { get }
    
    var boundingBox: GeodesicBoundingBox { get }
}

public struct SimpleLine: GeodesicLine {
    public let points: [GeodesicPoint]
    
    public var segments: [GeodesicLineSegment] {
        points.enumerated().compactMap { (offset, point) in
            if points.count == offset + 1 { return nil }
            
            return LineSegment(point: point, otherPoint: points[offset + 1])
        }
    }
    
    public var boundingBox: GeodesicBoundingBox { BoundingBox.best(points.map { BoundingBox(boundingCoordinates: (minLongitude: $0.longitude, minLatitude: $0.latitude, maxLongitude: $0.longitude, maxLatitude: $0.latitude)) })! }
    
    public init?(points: [GeodesicPoint]) {
        guard points.count >= 2 else { return nil }
        
        self.points = points
    }
    
    init?(segments: [GeodesicLineSegment]) {
        guard segments.count >= 1 else { return nil }
        
        for (index, segment) in segments.enumerated() {
            guard index == 0 || segment.point == segments[index - 1].otherPoint else { return nil }
        }
        
        self.points = segments.map { $0.point } + [segments.last!.otherPoint]
    }
}
