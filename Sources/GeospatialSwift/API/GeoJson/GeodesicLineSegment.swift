public protocol GeodesicLineSegment {
    var point: GeodesicPoint { get }
    var otherPoint: GeodesicPoint { get }
    
    var midpoint: GeodesicPoint { get }
    var initialBearing: (bearing: Double, back: Double) { get }
    var averageBearing: (bearing: Double, back: Double) { get }
    var finalBearing: (bearing: Double, back: Double) { get }
}

internal struct LineSegment: GeodesicLineSegment {
    public let point: GeodesicPoint
    public let otherPoint: GeodesicPoint
    
    public var midpoint: GeodesicPoint { return Calculator.midpoint(from: point, to: otherPoint) }
    
    public var initialBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.initialBearing(from: point, to: otherPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
    
    public var averageBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.averageBearing(from: point, to: otherPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
    
    public var finalBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.finalBearing(from: point, to: otherPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
}

public func == (lhs: GeodesicLineSegment, rhs: GeodesicLineSegment) -> Bool {
    return lhs.point == rhs.point && lhs.otherPoint == rhs.otherPoint
}

public func != (lhs: GeodesicLineSegment, rhs: GeodesicLineSegment) -> Bool {
    return !(lhs == rhs)
}
