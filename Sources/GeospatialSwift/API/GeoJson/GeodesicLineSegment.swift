public struct GeodesicLineSegment {
    public let startPoint: GeodesicPoint
    public let endPoint: GeodesicPoint
    
    public var midpoint: GeodesicPoint { Calculator.midpoint(from: startPoint, to: endPoint) }
    
    public var initialBearing: GeodesicBearing {
        let bearing = Calculator.initialBearing(from: startPoint, to: endPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return .init(bearing: bearing, back: back)
    }
    
    public var averageBearing: GeodesicBearing {
        let bearing = Calculator.averageBearing(from: startPoint, to: endPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return .init(bearing: bearing, back: back)
    }
    
    public var finalBearing: GeodesicBearing {
        let bearing = Calculator.finalBearing(from: startPoint, to: endPoint)
        let back = bearing > 180 ? bearing - 180 : bearing + 180
        return .init(bearing: bearing, back: back)
    }
}

public func == (lhs: GeodesicLineSegment, rhs: GeodesicLineSegment) -> Bool {
    return lhs.startPoint == rhs.startPoint && lhs.endPoint == rhs.endPoint
}

public func != (lhs: GeodesicLineSegment, rhs: GeodesicLineSegment) -> Bool {
    return !(lhs == rhs)
}
