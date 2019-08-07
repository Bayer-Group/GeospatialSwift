public protocol GeodesicLine {
    var points: [GeodesicPoint] { get }
    var segments: [GeodesicLineSegment] { get }
    
    var boundingBox: GeodesicBoundingBox { get }
}

public struct SimpleLine: GeodesicLine {
    public let points: [GeodesicPoint]
    public let segments: [GeodesicLineSegment]
    
    public var boundingBox: GeodesicBoundingBox {
        return BoundingBox.best(points.map { BoundingBox(boundingCoordinates: (minLongitude: $0.longitude, minLatitude: $0.latitude, maxLongitude: $0.longitude, maxLatitude: $0.latitude)) })!
    }
    
    public init?(points: [GeodesicPoint]) {
        guard points.count >= 2 else { return nil }
        
        self.points = points
        
        segments = points.enumerated().compactMap { (offset, point) in
            if points.count == offset + 1 { return nil }
            
            return LineSegment(startPoint: point, endPoint: points[offset + 1])
        }
    }
    
    init?(segments: [GeodesicLineSegment]) {
        guard segments.count >= 1 else { return nil }
        
        for (index, segment) in segments.enumerated() {
            guard index == 0 || segment.startPoint == segments[index - 1].endPoint else { return nil }
        }
        
        self.points = segments.map { $0.startPoint } + [segments.last!.endPoint]
        self.segments = segments
    }
}
