public protocol GeodesicLineSegment {
    var startPoint: GeodesicPoint { get }
    var endPoint: GeodesicPoint { get }
    
    var midpoint: GeodesicPoint { get }
    var initialBearing: (bearing: Double, back: Double) { get }
    var averageBearing: (bearing: Double, back: Double) { get }
    var finalBearing: (bearing: Double, back: Double) { get }
}

internal struct LineSegment: GeodesicLineSegment {
    public let startPoint: GeodesicPoint
    public let endPoint: GeodesicPoint
    
    public var midpoint: GeodesicPoint { return Calculator.midpoint(from: startPoint, to: endPoint) }
    
    public var initialBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.initialBearing(from: startPoint, to: endPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
    
    public var averageBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.averageBearing(from: startPoint, to: endPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
    
    public var finalBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.finalBearing(from: startPoint, to: endPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
}

public func == (lhs: GeodesicLineSegment, rhs: GeodesicLineSegment) -> Bool {
    return lhs.startPoint == rhs.startPoint && lhs.endPoint == rhs.endPoint
}

public func != (lhs: GeodesicLineSegment, rhs: GeodesicLineSegment) -> Bool {
    return !(lhs == rhs)
}
