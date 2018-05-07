@testable import GeospatialSwift

final class MockGeoJsonPoint: MockGeoJsonCoordinatesGeometry, GeoJsonPoint {
    private(set) var locationCallCount: Int = 0
    private(set) var locationCoordinateCallCount: Int = 0
    private(set) var longitudeCallCount: Int = 0
    private(set) var latitudeCallCount: Int = 0
    private(set) var altitudeCallCount: Int = 0
    private(set) var degreesToRadiansCallCount: Int = 0
    private(set) var radiansToDegreesCallCount: Int = 0
    private(set) var normalizeCallCount: Int = 0
    private(set) var initialBearingCallCount: Int = 0
    private(set) var averageBearingCallCount: Int = 0
    private(set) var finalBearingCallCount: Int = 0
    private(set) var midpointCallCount: Int = 0
    
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .point
    }
    
    var longitude: Double {
        longitudeCallCount += 1
        
        return 0
    }
    
    var latitude: Double {
        latitudeCallCount += 1
        
        return 0
    }
    
    var altitude: Double? {
        altitudeCallCount += 1
        
        return nil
    }
    
    var degreesToRadians: GeoJsonPoint {
        degreesToRadiansCallCount += 1
        
        return self
    }
    
    var radiansToDegrees: GeoJsonPoint {
        radiansToDegreesCallCount += 1
        
        return self
    }
    
    var normalize: GeodesicPoint {
        normalizeCallCount += 1
        
        return self
    }
    
    func initialBearing(to point: GeodesicPoint) -> Double {
        initialBearingCallCount += 1
        
        return 0
    }
    
    func averageBearing(to point: GeodesicPoint) -> Double {
        averageBearingCallCount += 1
        
        return 0
    }
    
    func finalBearing(to point: GeodesicPoint) -> Double {
        finalBearingCallCount += 1
        
        return 0
    }
    
    func midpoint(with point: GeodesicPoint) -> GeodesicPoint {
        midpointCallCount += 1
        
        return self
    }
}
