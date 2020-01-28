public struct GeodesicLineSegment {
    public let point: GeodesicPoint
    public let otherPoint: GeodesicPoint
    
    public var midpoint: GeodesicPoint { Calculator.midpoint(from: point, to: otherPoint) }
    
    public var initialBearing: GeodesicBearing {
        let bearing = Calculator.initialBearing(from: point, to: otherPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return .init(bearing: bearing, back: back)
    }
    
    public var averageBearing: GeodesicBearing {
        let bearing = Calculator.averageBearing(from: point, to: otherPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return .init(bearing: bearing, back: back)
    }
    
    public var finalBearing: GeodesicBearing {
        let bearing = Calculator.finalBearing(from: point, to: otherPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return .init(bearing: bearing, back: back)
    }
}

public func == (lhs: GeodesicLineSegment, rhs: GeodesicLineSegment) -> Bool {
    return lhs.point == rhs.point && lhs.otherPoint == rhs.otherPoint
}

public func != (lhs: GeodesicLineSegment, rhs: GeodesicLineSegment) -> Bool {
    return !(lhs == rhs)
}
