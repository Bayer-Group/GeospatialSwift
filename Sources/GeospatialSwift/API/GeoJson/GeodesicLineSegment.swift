public protocol GeodesicLineSegment {
    var point1: GeodesicPoint { get }
    var point2: GeodesicPoint { get }
    
    var midpoint: GeodesicPoint { get }
    var initialBearing: (bearing: Double, back: Double) { get }
    var averageBearing: (bearing: Double, back: Double) { get }
    var finalBearing: (bearing: Double, back: Double) { get }
}

internal struct LineSegment: GeodesicLineSegment {
    let point1: GeodesicPoint
    let point2: GeodesicPoint
    
    public var midpoint: GeodesicPoint { return Calculator.midpoint(point1: point1, point2: point2) }
    
    public var initialBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.initialBearing(point1: point1, point2: point2)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
    
    public var averageBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.averageBearing(point1: point1, point2: point2)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
    
    public var finalBearing: (bearing: Double, back: Double) {
        let bearing = Calculator.finalBearing(point1: point1, point2: point2)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return (bearing, back)
    }
}