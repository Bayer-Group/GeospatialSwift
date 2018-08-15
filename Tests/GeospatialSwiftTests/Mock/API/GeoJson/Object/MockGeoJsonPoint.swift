@testable import GeospatialSwift

final class MockGeoJsonPoint: MockGeoJsonCoordinatesGeometry, GeoJsonPoint {
    override init() {
        super.init()
        
        geoJsonObjectTypeResult = .point
    }
    
    private(set) var longitudeCallCount: Int = 0
    var longitudeResult: Double = 0
    var longitude: Double {
        longitudeCallCount += 1
        
        return longitudeResult
    }
    
    private(set) var latitudeCallCount: Int = 0
    var latitudeResult: Double = 0
    var latitude: Double {
        latitudeCallCount += 1
        
        return latitudeResult
    }
    
    private(set) var altitudeCallCount: Int = 0
    var altitudeResult: Double?
    var altitude: Double? {
        altitudeCallCount += 1
        
        return altitudeResult
    }
    
    private(set) var normalizeCallCount: Int = 0
    var normalizeResult: GeodesicPoint = SimplePoint(longitude: 0, latitude: 0)
    var normalize: GeodesicPoint {
        normalizeCallCount += 1
        
        return normalizeResult
    }
    
    private(set) var normalizePostitiveCallCount: Int = 0
    var normalizePostitiveResult: GeodesicPoint = SimplePoint(longitude: 0, latitude: 0)
    var normalizePostitive: GeodesicPoint {
        normalizePostitiveCallCount += 1
        
        return normalizePostitiveResult
    }
    
    private(set) var initialBearingCallCount: Int = 0
    var initialBearingResult: Double = 0
    func initialBearing(to point: GeodesicPoint) -> Double {
        initialBearingCallCount += 1
        
        return initialBearingResult
    }
    
    private(set) var averageBearingCallCount: Int = 0
    var averageBearingResult: Double = 0
    func averageBearing(to point: GeodesicPoint) -> Double {
        averageBearingCallCount += 1
        
        return averageBearingResult
    }
    
    private(set) var finalBearingCallCount: Int = 0
    var finalBearingResult: Double = 0
    func finalBearing(to point: GeodesicPoint) -> Double {
        finalBearingCallCount += 1
        
        return finalBearingResult
    }
    
    private(set) var midpointCallCount: Int = 0
    var midpointResult: GeodesicPoint = SimplePoint(longitude: 0, latitude: 0)
    func midpoint(with point: GeodesicPoint) -> GeodesicPoint {
        midpointCallCount += 1
        
        return midpointResult
    }
}
