import CoreLocation

public protocol GeodesicPoint {
    var longitude: Double { get }
    var latitude: Double { get }
    var altitude: Double? { get }
}

public extension GeodesicPoint {
    var degreesToRadians: GeodesicPoint { SimplePoint(longitude: longitude.degreesToRadians, latitude: latitude.degreesToRadians, altitude: altitude) }
    var radiansToDegrees: GeodesicPoint { SimplePoint(longitude: longitude.radiansToDegrees, latitude: latitude.radiansToDegrees, altitude: altitude) }
}

public extension GeodesicPoint {
    
    var mercatorProjection: GeodesicPoint {
        let radius: Double = 6378137.0 // Earth radius

        let latRad = self.latitude * .pi / 180.0
        let lonRad = self.longitude * .pi / 180.0

        let x = radius * lonRad
        let y = radius * log(tan(.pi / 4.0 + latRad / 2.0))

        return SimplePoint(longitude: x, latitude: y, altitude: altitude)
    }
    
    var mercatorInverseProjection: GeodesicPoint {
        let R = 6378137.0
        let x = self.longitude
        let y = self.latitude
        
        let lambda = x / R
        
        let phi = 2 * atan(exp(y / R)) - .pi / 2
        
        let latitude = phi * 180.0 / .pi
        let longitude = lambda * 180.0 / .pi
        
        return SimplePoint(longitude: longitude, latitude: latitude, altitude: altitude)
    }
    
    func distance(to point: GeodesicPoint) -> Double {
        let lhs = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let rhs = CLLocation(latitude: point.latitude, longitude: point.longitude)
        return rhs.distance(from: lhs)
    }
}

public struct SimplePoint: GeodesicPoint {
    public let longitude: Double
    public let latitude: Double
    public var altitude: Double?
    
    public init(longitude: Double, latitude: Double, altitude: Double? = nil) {
        self.longitude = longitude
        self.latitude = latitude
        self.altitude = altitude
    }
}

public func == (lhs: GeodesicPoint, rhs: GeodesicPoint) -> Bool {
    let lhs = Calculator.normalize(lhs)
    let rhs = Calculator.normalize(rhs)
    
    let altitudeIsSame = lhs.altitude != nil && rhs.altitude != nil ? lhs.altitude!.isEqual(to: rhs.altitude!) : lhs.altitude == rhs.altitude
    
    return lhs.latitude.isEqual(to: rhs.latitude) && lhs.longitude.isEqual(to: rhs.longitude) && altitudeIsSame
}
